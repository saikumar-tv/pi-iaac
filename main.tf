terraform {
  backend "azurerm" {
    resource_group_name  = "PI-AKS-rg-nrg"
    storage_account_name = "pitfstatefile"
    container_name       = "pitfstatefile"
    key                  = "terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
    local = {
      source = "hashicorp/local"
      version = ">= 2.1.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
}
# Configure the Microsoft Azure Provider




resource "azurerm_resource_group" "rg1" {
  name     = var.rgname
  location = var.location
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  sku                 = "PerGB2018"
}

resource "azurerm_key_vault" "kv" {
  name                        = "${var.cluster-name}-kv"
  location                    = azurerm_resource_group.rg1.location
  resource_group_name         = azurerm_resource_group.rg1.name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  sku_name                    = "Premium"
  soft_delete_enabled         = true
  purge_protection_enabled    = true
  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  access_policy {
    tenant_id = var.tenant_id
    object_id = azurerm_disk_encryption_set.aks_des.identity[0].principal_id

    key_permissions = [
      "Get",
      "UnwrapKey",
      "WrapKey",
    ]

    secret_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_key_vault_key" "kv_key" {
  name         = "${var.cluster-name}-key"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA-HSM"
  key_size     = 2048
  expiration_date = "2099-12-31T00:00:00Z"
  key_opts     = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_disk_encryption_set" "aks_des" {
  name                = "${var.cluster-name}-des"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  key_vault_key_id    = azurerm_key_vault_key.kv_key.id
  identity {
    type = "SystemAssigned"
  }
}

#create Azure Kubernetes Service
module "aks" {
  source                  = "./modules/aks"
  aks_cluster_name        = var.cluster-name
  location                = var.location
  resource_group_name     = var.rgname
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  aks_disk_encryption_set_id = azurerm_disk_encryption_set.aks_des.id
}

# Create Azure Container Registry
module "acr" {
  source              = "./modules/acr"
  acr_name            = "pipocwebapp"
  resource_group_name = var.rgname
  location            = var.location
  aks_principal_id    = module.aks.aks_principal_id
}

resource "local_file" "kube_config" {
  content  = module.aks.kube_config_raw
  filename = "/tmp/kube_config"
}
