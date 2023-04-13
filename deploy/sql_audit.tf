# Uncomment the following if you'd like to enable the optional mssql auditing policy

# Deploys a SQL Server and a SQL Database
#resource "azurecaf_name" "nasa" {
#  name          = "NotesApp"
#  resource_type = "azurerm_storage_account"
#  random_length = 5
#  random_seed   = random_integer.seed.result
#  clean_input   = true
#}

#resource "azurerm_mssql_database_extended_auditing_policy" "nadbap" {
#  database_id                             = azurerm_mssql_database.nadb.id
#  storage_endpoint                        = azurerm_storage_account.nasa.primary_blob_endpoint
#  storage_account_access_key              = azurerm_storage_account.nasa.primary_access_key
#  storage_account_access_key_is_secondary = false
#  retention_in_days                       = 6
#}

#resource "azurerm_storage_account" "nasa" {
#  name                          = azurecaf_name.nasa.result
#  resource_group_name           = azurerm_resource_group.narg.name
#  location                      = azurerm_resource_group.narg.location
#  account_tier                  = "Standard"
#  account_replication_type      = "LRS"
#  min_tls_version               = "TLS1_2"
#  public_network_access_enabled = false
#}