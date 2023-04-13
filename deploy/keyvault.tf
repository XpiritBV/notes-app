# Create a Key Vault instance
resource "azurecaf_name" "kv" {
  name          = "NotesAppSecrets"
  resource_type = "azurerm_key_vault"
  random_length = 5
  random_seed   = random_integer.seed.result
  clean_input   = true
}

resource "azurerm_key_vault" "nakv" {
  name                          = azurecaf_name.kv.result
  location                      = azurerm_resource_group.narg.location
  resource_group_name           = azurerm_resource_group.narg.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption   = true
  purge_protection_enabled      = true
  public_network_access_enabled = true
  soft_delete_retention_days    = 7

  sku_name = "standard"

  network_acls {
    bypass = "AzureServices"

    # NOTE: This is a temporary workaround to enable access to the Key Vault from your WAN IP during deployment
    # You can disable public access once the deployment is complete and the SQL admin password is populated
    # The Notes App App Service will access Key Vault via a private endpoint per its configuration
    ip_rules = ["${chomp(data.http.wanip.response_body)}"]

    default_action = "Deny"
  }
}

# Key Vault access policy for the current user
resource "azurerm_key_vault_access_policy" "nakvap-sp" {
  key_vault_id = azurerm_key_vault.nakv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "Set",
    "Delete",
    "Purge",
    "List",
  ]
}

# Key Vault access policy for the App Service
resource "azurerm_key_vault_access_policy" "nakvap-app" {
  key_vault_id = azurerm_key_vault.nakv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.nakvid.principal_id

  secret_permissions = [
    "Get",
    "Set",
  ]
}

# Store the database password in Key Vault
resource "azurecaf_name" "dbpass" {
  name          = "NotesAppSQLPassword"
  resource_type = "azurerm_key_vault_secret"
  random_length = 5
  random_seed   = random_integer.seed.result
  clean_input   = true
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = azurecaf_name.dbpass.result
  value        = random_string.admin_password.result
  key_vault_id = azurerm_key_vault.nakv.id
  content_type = "password"

  depends_on = [azurerm_key_vault_access_policy.nakvap-sp]
}