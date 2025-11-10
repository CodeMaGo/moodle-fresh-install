# 🌐 Terraform Hetzner Moodle Deployment

This Terraform project provisions a fresh Moodle instance on a VM on **Hetzner Cloud** in docker containers. The Docker Compose deployment uses **cloud-init**.
Securely integrates with Azure Key Vault for secrets management and Azure Blob Storage for Terraform state backend.The Hetzner Cloud API token is securely stored in an **Azure Key Vault (SharedInfra)** and retrieved at runtime by Terraform.

---

## ✨ Features

* 🖥️ Provision a VM on Hetzner Cloud
* 🐳 Install Docker and Docker Compose via cloud-init
* 🔐 Deploy Snipe‑IT in Docker with environment variables and SSL configured
* 🗝️ Securely fetch Hetzner Cloud API token from Azure Key Vault at runtime
* ⚡ Fully automated provisioning and deployment

---
## 📘 Overview

This project provisions a **Moodle web application** hosted on **Hetzner Cloud**, with infrastructure fully managed by **Terraform**.

It automates:

- Network setup (private subnet, firewall)
- Hetzner Cloud VM creation
- SSL, Apache, and Moodle configuration (via cloud-init)
- Secure secrets retrieval from **Azure Key Vault**
- Remote Terraform state stored in **Azure Blob Storage**

---

## 🧱 Architecture

```
                   ┌──────────────────────────────┐
                   │        Azure Key Vault       │
                   │  - hcloud-api-token          │
                   │  - DB credentials            │
                   └──────────────┬───────────────┘
                                  │
             (Terraform Data Sources via azurerm)
                                  │
 ┌────────────────────────────────┼────────────────────────────────┐
 │                             Terraform                           │
 │                                                                 │
 │  - Reads secrets from Azure Key Vault                           │
 │  - Creates Hetzner private network + subnet                     │
 │  - Provisions VM (Ubuntu + Docker + Moodle)                     │
 │  - Configures SSL, Apache, DB via cloud-init                    │
 │  - Applies Firewall Rules (HTTP/HTTPS/SSH)                      │
 └────────────────────────────────┼────────────────────────────────┘
                                  │
                           Hetzner Cloud API
                                  │
                     ┌────────────┴────────────┐
                     │   Hetzner Cloud Server  │
                     │   (Moodle + MariaDB)    │
                     └─────────────────────────┘

```

---

## 📂 Project Structure

```
terraform-moodle/
├── main.tf               # Core resources (network, VM, firewall, outputs)
├── variables.tf          # Input variables and defaults
├── provider.tf           # Providers configuration (Hetzner + Azure)
├── backend.tf            # Remote backend using Azure Storage
├── cloud-init.yaml       # Cloud-init bootstrap (Docker, Moodle, SSL setup)
├── terraform.tfvars.example # Example terrform.tfvars file   
└── assets/
    ├── certs/                # Create this folder and add your wildcard-ssl.crt and wildcard-ssl.key files
    │   ├── wildcard-ssl.crt  #If you change the name of your .crt file, make sure you change the name in cloud-init.yaml
    │   └── wildcard-ssl.key  #If you change the name of your .key file, make sure you change the name in cloud-init.yaml
    ├── apache-conf/
    │   └── site.conf
    └── moodle-conf/
        └── config.php

```

---

## ⚙️ Key Components

### 1. **Azure Integration**

- Fetches Hetzner Cloud API token from **Azure Key Vault** (`hcloud-api-token`).
- Terraform backend state stored securely in **Azure Blob Storage**.

### 2. **Hetzner Infrastructure**

- Creates:
    - Private network (`10.0.0.0/16`)
    - Subnet (`10.0.1.0/24`)
    - Moodle VM (`Ubuntu 22.04`)
    - Optional floating IP and firewall

### 3. **Cloud-Init Automation**

Automatically configures:

- Docker & Docker Compose
- Apache with SSL
- MariaDB & Moodle containers
- Base64-decoded configuration and certificates
- Systemd-enabled services

### 4. **Security**

- Secrets stored and fetched from **Azure Key Vault**
- HTTPS & SSL certificates baked into cloud-init
- Minimal open ports (22, 80, 443)
- SSH key from existing Hetzner key

---

## 🔧 Prerequisites

| Requirement | Description |
| --- | --- |
| Terraform ≥ 1.0.0 | Required to run the configuration |
| Hetzner Cloud account | For server provisioning |
| Azure Key Vault | To store the Hetzner API token |
| Azure Storage Account | For Terraform remote state |
| SSH key in Hetzner | To attach to the VM |
| Domain & SSL cert | For Moodle HTTPS setup |

---

## ⚙️ Setup

### 1. Clone the repo

```bash
git clone https://github.com/your-org/terraform-hetzner-moodle.git
cd terraform-hetzner-moodle

```

### 2. Update backend configuration (`backend.tf`)

```hcl
terraform  { 
    backend "azurerm" { 
        resource_group_name = "your-azure-resource-group" 
        storage_account_name = "terraformstatestorage"
        container_name = "terraformstatecontainer" 
        key = "your-terraform-state-file.tfstate" // unique name for this project's state file - can't use variables 
    } 
}

```
---

### 3. Create your variable file

Copy the example variables file and customize it for your environment:

```bash
cp terraform.tfvars.example terraform.tfvars

```

Then edit `terraform.tfvars`:

```hcl
app_fqdn = "your-moodle-domain.org"
app_name = "moodle"

location               = "nbg1"       # e.g., nbg1, fsn1, hel1
network_zone           = "eu-central" # corresponds to nbg1, fsn1, hel1
resource_prefix        = "yourprefix" # used for naming resources
existing_ssh_key_name  = "existing-keypair-name-in-hetzner" # SSH keypair name already uploaded to Hetzner

# VM Configuration
vm_server_type         = "cax11"   # e.g., cpx11, cax11, ccx11
vm_server_image        = "ubuntu-22.04" # e.g., ubuntu-20.04, ubuntu-22.04
vm_server_name         = "your-moodle-server" # Name of the VM
vm_assign_floating_ip  = true
vm_allow_ssh           = true
vm_allow_http          = true
vm_allow_https         = true

# Database Configuration
db_database         = "moodle"
db_user             = "moodleuser"
db_password         = "yourdbpassword"       # TODO: Move to Key Vault secret
db_root_password    = "yourdbrootpassword"   # TODO: Move to Key Vault secret

```
---

### 4. **Log in to Azure CLI**

```bash
az login
```

### 5. **Export Azure credentials as environment variables (PowerShell)**

```powershell
$env:AZURE_SUBSCRIPTION_ID = "<your-subscription-id>"
$env:AZURE_TENANT_ID       = "<your-tenant-id>"
$env:AZURE_CLIENT_ID       = "<your-client-id>"
$env:AZURE_CLIENT_SECRET   = "<your-client-secret>"
```
Linux/Mac:

```bash
export ARM_CLIENT_ID="xxxx"
export ARM_CLIENT_SECRET="xxxx"
export ARM_TENANT_ID="xxxx"
export ARM_SUBSCRIPTION_ID="xxxx"

```

### 6. **Verify environment variables**

```powershell
Get-ChildItem Env:AZURE_SUBSCRIPTION_ID, Env:AZURE_TENANT_ID, Env:AZURE_CLIENT_ID, Env:AZURE_CLIENT_SECRET
```

### 7. **Initialize Terraform**

```bash
terraform init --reconfigure
```

### 8. **Plan Terraform deployment**

```bash
terraform plan
```

### 9. **Apply Terraform deployment**

```bash
terraform apply
```

---

## 📖 How It Works

1. **Terraform reads the Hetzner API token** directly from Azure Key Vault
2. Terraform provisions the **VM on Hetzner Cloud**
3. **Cloud-init** installs Docker, sets up SSL certificates and environment files, and deploys Snipe‑IT via Docker Compose
4. **Snipe‑IT runs in Docker**, fully configured, accessible over HTTPS

---

## 💡 Notes

* SSL certificates and environment variables are injected via cloud-init `write_files`.
* Ensure that sensitive secrets are stored **only** in Azure Key Vault and **not** in Terraform files or version control.
* The Snipe‑IT Docker container is configured to use Apache with SSL and persistent storage volumes.

---

## 🖼️ Expected Moodle Installation Screens

After deploying and accessing your Moodle instance via its **public IP** or **domain (FQDN)**, you should see the following installation pages.

These screenshots show the expected setup flow for **Moodle 4.5.7+ (Build 20251107)**.

| Step | Description | Screenshot |
| --- | --- | --- |
| 1 | Moodle installation welcome screen | [Moodle Installation – screen 1](https://github.com/CodeMaGo/moodle-fresh-install/c/screenshots/Moodle%20Installation%20_%204.5.7%2B%20(Build_%2020251107)%20-%20screen%201.png) |
| 2 | Environment checks and dependency validation | [Moodle Installation – screen 2](https://github.com/CodeMaGo/moodle-fresh-install/c/screenshots/Moodle%20Installation%20_%204.5.7%2B%20(Build_%2020251107)%20-%20screen%202.png) |
| 3-1 | Database configuration input page | [Moodle Installation – screen 3-1](https://github.com/CodeMaGo/moodle-fresh-install/c/screenshots/Moodle%20Installation%20_%204.5.7%2B%20(Build_%2020251107)%20-%20screen%203-1.png) |
| 3-2 | Database setup progress page | [Moodle Installation – screen 3-2](https://github.com/CodeMaGo/moodle-fresh-install/c/screenshots/Moodle%20Installation%20_%204.5.7%2B%20(Build_%2020251107)%20-%20screen%203-2.png) |
| 4 | Admin user creation and site settings page | [Moodle Installation – screen 4](https://github.com/CodeMaGo/moodle-fresh-install/c/screenshots/Moodle%20Installation%20_%204.5.7%2B%20(Build_%2020251107)%20-%20screen%204.png) |
| 5 | Initial Moodle dashboard after installation | [Moodle Installation – screen 5](https://github.com/CodeMaGo/moodle-fresh-install/c/screenshots/Moodle%20Installation%20_%204.5.7%2B%20(Build_%2020251107)%20-%20screen%205.png) |
| 6 | Final site home page (installation complete) | [Moodle Installation – screen 6](https://github.com/CodeMaGo/moodle-fresh-install/c/screenshots/Moodle%20Installation%20_%204.5.7%2B%20(Build_%2020251107)%20-%20screen%206.png) |

---

## 📄 License

MIT License 📝

---

