terraform {
  required_version = ">= 1.0.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.40.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.96.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
  }
}

# provider "hcloud" {
#   # prefer passing token as var.hcloud_token
#   #token = var.hetzner_cloud_api_token != "" ? var.hetzner_cloud_api_token : (try(env("HCLOUD_API_TOKEN"), ""))
#   token = data.azurerm_key_vault_secret.hcloud_api_token.value
# }

provider "azurerm" {
  features {}
}

provider "hcloud" {
  token = data.azurerm_key_vault_secret.hcloud_api_token.value
}