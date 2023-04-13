# Deploy an App Service Plan and App configured to connect to SQL Server and Key Vault via private endpoints 
resource "azurecaf_name" "plan" {
  name          = "NotesApp"
  resource_type = "azurerm_app_service_plan"
  random_length = 5
  random_seed   = random_integer.seed.result
  clean_input   = true
}

resource "azurerm_service_plan" "nasp" {
  name                = azurecaf_name.plan.result
  location            = azurerm_resource_group.narg.location
  resource_group_name = azurerm_resource_group.narg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurecaf_name" "app" {
  name          = "NotesApp"
  resource_type = "azurerm_app_service"
  random_length = 5
  random_seed   = random_integer.seed.result
  clean_input   = true
  use_slug      = false
}

resource "azurerm_linux_web_app" "naas" {
  name                = azurecaf_name.app.result
  location            = azurerm_resource_group.narg.location
  resource_group_name = azurerm_resource_group.narg.name
  service_plan_id     = azurerm_service_plan.nasp.id
  https_only          = true

  app_settings = {
    "WEBSITES_PORT" = "8080"
    "BIND_PORT"     = "8080"
    "DB_ADAPTER"    = "sqlserver"
    "DB_HOST"       = azurerm_mssql_server.nasqls.fully_qualified_domain_name
    "DB_PORT"       = "1433"
    "DB_USERNAME"   = "azdbuser"
    "DB_PASSWORD"   = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.nakv.name};SecretName=${azurerm_key_vault_secret.db_password.name})"
    "DB_DATABASE"   = azurerm_mssql_database.nadb.name
    "DB_IS_AZURE"   = "true"
  }

  # Access vaults with a user-assigned identity
  # https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references?tabs=azure-cli#access-vaults-with-a-user-assigned-identity
  key_vault_reference_identity_id = azurerm_user_assigned_identity.nakvid.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.nakvid.id]
  }

  site_config {
    always_on                = true
    http2_enabled            = true
    minimum_tls_version      = 1.2
    health_check_path        = "/"
    remote_debugging_enabled = false

    application_stack {
      docker_image     = var.container_image
      docker_image_tag = var.container_image_tag
    }

    # Per docs:
    # "Linux applications attempting to use private endpoints additionally require that the app be explicitly configured to have all traffic route through the virtual network. This requirement will be removed in a forthcoming update.""
    # https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references?tabs=azure-cli
    # Remove this once the requirement is removed
    vnet_route_all_enabled = true
  }

  virtual_network_subnet_id = azurerm_subnet.nasn.id

  depends_on = [
    azurerm_private_endpoint.nape-sql,
    azurerm_private_endpoint.nape-kv,
  ]
}
