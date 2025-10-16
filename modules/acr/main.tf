resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = false
  public_network_access_enabled = false
  zone_redundancy_enabled = true
  data_endpoint_enabled = true
  content_trust_enabled = true

  retention_policy {
    enabled = true
    days    = 7
  }

  georeplications {
    location                = var.location
    zone_redundancy_enabled = true
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = var.aks_principal_id
}
