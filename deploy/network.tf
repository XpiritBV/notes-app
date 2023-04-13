# Notes App Virtual Network
resource "azurecaf_name" "vnet" {
  name          = "NotesApp"
  resource_type = "azurerm_virtual_network"
  random_length = 5
  random_seed   = random_integer.seed.result
  clean_input   = true
}

resource "azurerm_virtual_network" "navn" {
  name                = azurecaf_name.vnet.result
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.narg.location
  resource_group_name = azurerm_resource_group.narg.name
}

# Notes App Subnets

# App Service Subnet
resource "azurecaf_name" "snet-svc" {
  name          = "NotesAppService"
  resource_type = "azurerm_subnet"
  random_length = 5
  random_seed   = random_integer.seed.result
  clean_input   = true
}

resource "azurerm_subnet" "nasn" {
  name                 = azurecaf_name.snet-svc.result
  resource_group_name  = azurerm_resource_group.narg.name
  virtual_network_name = azurerm_virtual_network.navn.name
  address_prefixes     = ["10.1.2.0/24"]

  delegation {
    name = "AppServiceDelegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

# Private Link Subnet
resource "azurecaf_name" "snet-pl" {
  name          = "NotesAppPrivateServices"
  resource_type = "azurerm_subnet"
  random_length = 5
  random_seed   = random_integer.seed.result
  clean_input   = true
}

resource "azurerm_subnet" "naplsn" {
  name                 = azurecaf_name.snet-pl.result
  resource_group_name  = azurerm_resource_group.narg.name
  virtual_network_name = azurerm_virtual_network.navn.name
  address_prefixes     = ["10.1.1.0/24"]
}

# SQL Server Private Endpoint
resource "azurecaf_name" "pe-sql" {
  name          = "NotesAppSQL"
  resource_type = "azurerm_private_endpoint"
  random_length = 5
  random_seed   = random_integer.seed.result
  clean_input   = true
}

resource "azurecaf_name" "psc-sql" {
  name          = "NotesAppSQL"
  resource_type = "azurerm_private_service_connection"
  random_length = 5
  random_seed   = random_integer.seed.result
  clean_input   = true
}

resource "azurerm_private_endpoint" "nape-sql" {
  name                = azurecaf_name.pe-sql.result
  location            = azurerm_resource_group.narg.location
  resource_group_name = azurerm_resource_group.narg.name

  subnet_id = azurerm_subnet.naplsn.id

  private_dns_zone_group {
    name = "privatelink.database.windows.net"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.napdz["db-windows"].id
    ]
  }

  private_service_connection {
    name                           = azurecaf_name.psc-sql.result
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
    private_connection_resource_id = azurerm_mssql_server.nasqls.id
  }

  depends_on = [
    azurerm_mssql_server.nasqls,
    azurerm_private_dns_zone.napdz
  ]
}

# Key Vault Private Endpoint
resource "azurecaf_name" "pe-kv" {
  name          = "NotesAppKV"
  resource_type = "azurerm_private_endpoint"
  random_length = 5
  random_seed   = random_integer.seed.result
  clean_input   = true
}

resource "azurecaf_name" "psc-kv" {
  name          = "NotesAppKV"
  resource_type = "azurerm_private_service_connection"
  random_length = 5
  random_seed   = random_integer.seed.result
  clean_input   = true
}

resource "azurerm_private_endpoint" "nape-kv" {
  name                = azurecaf_name.pe-kv.result
  location            = azurerm_resource_group.narg.location
  resource_group_name = azurerm_resource_group.narg.name

  subnet_id = azurerm_subnet.naplsn.id

  private_dns_zone_group {
    name = "privatelink.database.windows.net"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.napdz["pl-vault-core"].id
    ]
  }

  private_service_connection {
    name                           = azurecaf_name.psc-kv.result
    is_manual_connection           = false
    subresource_names              = ["vault"]
    private_connection_resource_id = azurerm_key_vault.nakv.id
  }

  depends_on = [
    azurerm_key_vault.nakv,
    azurerm_private_dns_zone.napdz
  ]
}

# Private DNS
locals {
  private_dns_zones = {
    #    az-automation           = "privatelink.azure-automation.net"
    #    pl-sql                  = "privatelink.sql.azuresynapse.net"
    #    pl-dev-azuresynapse-net = "privatelink.dev.azuresynapse.net"
    #    pl-blob-core            = "privatelink.blob.core.windows.net"
    db-windows    = "privatelink.database.windows.net"
    pl-vault-core = "privatelink.vaultcore.azure.net"
  }
}

resource "azurerm_private_dns_zone" "napdz" {
  for_each            = local.private_dns_zones
  name                = each.value
  resource_group_name = azurerm_resource_group.narg.name
}

resource "azurecaf_name" "pdns" {
  name          = "NotesAppDNS"
  resource_type = "azurerm_private_dns_zone"
  suffixes      = ["link"]
  random_length = 5
  random_seed   = random_integer.seed.result
  clean_input   = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_network_links" {
  for_each              = local.private_dns_zones
  name                  = azurecaf_name.pdns.result
  resource_group_name   = azurerm_resource_group.narg.name
  private_dns_zone_name = each.value
  virtual_network_id    = azurerm_virtual_network.navn.id
  depends_on            = [azurerm_private_dns_zone.napdz]
}