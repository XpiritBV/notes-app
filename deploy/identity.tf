# Managed Identity for the App Service to access Key Vault
resource "azurerm_user_assigned_identity" "nakvid" {
  location            = azurerm_resource_group.narg.location
  name                = "NotesAppKVIdentity"
  resource_group_name = azurerm_resource_group.narg.name
}

# TODO: Manage SQL Server administrative access with AAD
# Create an AAD group
# Add MI of the app service to the group
# Set in ASQL the AAD group object ID as the AAD Admin for the SQL Server

