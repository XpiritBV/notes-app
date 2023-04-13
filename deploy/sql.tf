# Deploys a SQL Server and a SQL Database
resource "azurecaf_name" "sql" {
  name          = "NotesApp"
  resource_type = "azurerm_mssql_server"
  random_length = 5
  random_seed   = random_integer.seed.result
  clean_input   = true
}

# Generate a random password for the database user
resource "random_string" "admin_password" {
  length  = 32
  special = true
}

resource "azurerm_mssql_server" "nasqls" {
  name                          = azurecaf_name.sql.result
  resource_group_name           = azurerm_resource_group.narg.name
  location                      = azurerm_resource_group.narg.location
  version                       = "12.0"
  administrator_login           = "azdbuser"
  administrator_login_password  = random_string.admin_password.result
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"
}

resource "azurecaf_name" "sqldb" {
  name          = "NotesApp"
  resource_type = "azurerm_mssql_database"
  random_length = 5
  random_seed   = random_integer.seed.result
  clean_input   = true
}

resource "azurerm_mssql_database" "nadb" {
  name      = azurecaf_name.sqldb.result
  server_id = azurerm_mssql_server.nasqls.id
  sku_name  = "S0"
  collation = "SQL_Latin1_General_CP1_CI_AS"
}
