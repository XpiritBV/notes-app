# This set of Terraform configuration files to deploy Notes App to Azure App Service.

# The following resources are deployed:
# - Virtual network
# - Key Vault
# - Managed Identity
# - SQL server
# - SQL database
# - Private endpoints
# - Network Interfaces
# - Private DNS zones
# - App Service plan
# - App Service

# You can learn more about the resources used in the following example scenario from Azure's documentation:
# https://learn.microsoft.com/en-us/azure/architecture/example-scenario/private-web-app/private-web-app

# In order to run this example, you need to have the following prerequisites:
# - An Azure subscription
# - Terraform installed
# - The Azure CLI installed & logged in
# - Terraform Azure Provider installed
# - Terraform Azure CAF Provider installed

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.51.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.24"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "random" {}

data "azurerm_client_config" "current" {
}

# Get the current WAN IP address
# This is used to allow access to Key Vault from Terraform
# when the SQL Server password is stored, without exposing 
# Key Vault to the public internet
data "http" "wanip" {
  url = "http://whatismyip.akamai.com"
}

# Azure CAF random seed
resource "random_integer" "seed" {
  min = 1
  max = 500000
}

# Generate globally unique resource names
# Names are generated using the azurecaf_name resource
# See https://registry.terraform.io/providers/aztfmod/azurecaf/2.0.0-preview3 for more information
resource "azurecaf_name" "rg" {
  name          = "NotesApp"
  resource_type = "azurerm_resource_group"
  random_length = 5
  random_seed   = random_integer.seed.result
  clean_input   = true
}

# Create a resource group
resource "azurerm_resource_group" "narg" {
  name     = azurecaf_name.rg.result
  location = var.target_region
}
