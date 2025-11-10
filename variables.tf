// ------------------------------
// Application Settings   
// ------------------------------
variable "app_fqdn" {
  description = "Fully Qualified Domain Name for the Moodle application"
  type        = string  
}

variable "app_name" {
  description = "A single word name for the application"
  type        = string  
}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "nbg1" # nbg1, hel1, nbg1, fsn1
}

variable "network_zone" {
  description = "Hetzner network zone corresponding to location"
  type        = string
  default     = "eu-central" # eu-central for nbg1, fsn1; eu-west for hel1
}

variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
}

# ------------------------------
# Existing Resources  
# ------------------------------

variable "existing_ssh_key_name" { 
  description = "Name of the SSH Key in Hetzner"
  type        = string  
}

# ------------------------------
# VM Configuration 
# ------------------------------
variable "vm_server_name" {
  description = "Name of the Hetzner server"
  type        = string
  default     = "snipe-it-server"
}

variable "vm_server_type" {
  description = "Hetzner server type (e.g. cx11, cx21, cpx11)"
  type        = string
  default     = "cx21"
} 

variable "vm_server_image" {
  description = "Server image (e.g. ubuntu-22.04)"
  type        = string
  default     = "ubuntu-22.04"
}

# optional specific private IP for the server inside private network; set to null to auto-assign
variable "vm_server_private_ip" {
  description = "Specific private IP to assign inside the private network (optional)"
  type        = string
  default     = null
}

# --- Floating/Public IP ---
variable "vm_assign_floating_ip" {
  description = "Whether to create and assign a Floating IP"
  type        = bool
  default     = true
}

# --- Firewall rules (simple SSH & HTTP example) ---
variable "vm_allow_ssh" {
  type    = bool
  default = true
}

variable "vm_allow_http" {
  type    = bool
  default = true
}

variable "vm_allow_https" {
  type    = bool
  default = true
}

# ------------------------------
# Database Configuration
# ------------------------------
variable "db_database" {
  description = "Name of the Moodle database"
  type        = string
}

variable "db_user" {
  description = "Database user for Moodle"
  type        = string
}

variable "db_password" {
  description = "Password for the Moodle database user"
  type        = string
  sensitive   = true
} 

variable "db_root_password" {
  description = "Root password for the database server"
  type        = string
  sensitive   = true
}



