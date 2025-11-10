# ---------------------------------------
# Hetzner Cloud Provider Token from Azure Key Vault
# ---------------------------------------
data "azurerm_key_vault" "azure_kv"{
  name                = "SharedInfra"
  resource_group_name = "infosec_rg"
}

data "azurerm_key_vault_secret" "hcloud_api_token" {
  name         = "hcloud-api-token"
  key_vault_id = data.azurerm_key_vault.azure_kv.id
}

data "hcloud_ssh_key" "ssh_key" {
  name = var.existing_ssh_key_name
}

resource "hcloud_network_subnet" "private_subnet" {
  network_id   = hcloud_network.private.id
  type         = "cloud"
  network_zone = var.network_zone # corresponds to nbg1, fsn1, hel1
  ip_range     = "10.0.1.0/24"
}
resource "hcloud_network" "private" {
  name     = "${var.resource_prefix}-private-net"
  ip_range = "10.0.0.0/16"
}

# Create the Moodle server
resource "hcloud_server" "moodle" {
  name        = var.vm_server_name
  server_type = var.vm_server_type
  image       = var.vm_server_image
  location    = var.location

  # attach ssh key if one is provided
  ssh_keys = var.existing_ssh_key_name != "" ? [data.hcloud_ssh_key.ssh_key.id] : []

  # attach to private network; optionally request a specific private IP (helps pick subnet)
  dynamic "network" {
    for_each = [hcloud_network.private]
    content {
      network_id = network.value.id
      # If you want to request a specific IP inside the private network's subnet, set server_private_ip
      #ip = var.server_private_ip
    }
  }
  depends_on = [hcloud_network_subnet.private_subnet]

  # ensure ephemeral/detachable disks behavior per needs:
  keep_disk = false

  user_data = local.rendered_cloud_init # file("${path.module}/cloud-init.yaml")

  labels = {
    role = "moodle"
  }
}

# Optional: simple firewall for HTTP, HTTPS, and SSH
resource "hcloud_firewall" "nsg" {
  name = "${var.vm_server_name}-fw"

  dynamic "rule" {
    for_each = [
      var.vm_allow_ssh ? {
        direction = "in"
        protocol  = "tcp"
        port      = "22"
        source_ips = ["0.0.0.0/0"]
        description = "Allow SSH"
      } : null,
      var.vm_allow_http ? {
        direction = "in"
        protocol  = "tcp"
        port      = "80"
        source_ips = ["0.0.0.0/0"]
        description = "Allow HTTP"
      } : null,
      var.vm_allow_https ? {
        direction = "in"
        protocol  = "tcp"
        port      = "443"
        source_ips = ["0.0.0.0/0"]
        description = "Allow HTTPS"
      } : null
    ]
    content {
      direction   = rule.value.direction
      protocol    = rule.value.protocol
      port        = rule.value.port
      source_ips  = rule.value.source_ips
      description = rule.value.description
    }
  }
}

# Attach firewall to server
resource "hcloud_firewall_attachment" "attach" {
  firewall_id = hcloud_firewall.nsg.id
  server_ids   = [hcloud_server.moodle.id]
}

output "moodle_server_ip" {
  description = "Public IP of Moodle instance"
  value       = hcloud_server.moodle.ipv4_address
}


locals {
  ssl_crt_content_b64 = base64encode(file("${path.module}/assets/certs/wildcard-ssl.crt"))
  ssl_key_content_b64 = base64encode(file("${path.module}/assets/certs/wildcard-ssl.key"))
  apache_conf_b64 = base64encode(file("${path.module}/assets/apache-conf/site.conf"))
  moodle_conf_php_b64 = base64encode(file("${path.module}/assets/moodle-conf/config.php"))

  rendered_cloud_init = templatefile("${path.module}/cloud-init.yaml", {
    ssl_crt_content_b64         = local.ssl_crt_content_b64
    ssl_key_content_b64         = local.ssl_key_content_b64
    apache_conf_b64     = local.apache_conf_b64
    moodle_conf_php_b64 = local.moodle_conf_php_b64
    app_fqdn                 = var.app_fqdn
    app_url                 = var.vm_allow_https ? "https://${var.app_fqdn}" : "http://${var.app_fqdn}"
    app_name                = var.app_name
    db_database          = var.db_database
    db_user              = var.db_user
    db_password          = var.db_password
    db_root_password     = var.db_root_password
  })
}