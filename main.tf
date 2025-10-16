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



#create Azure Kubernetes Service
module "aks" {
  source                  = "./modules/aks"
  aks_cluster_name        = var.cluster-name
  location                = var.location
  resource_group_name     = var.rgname
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
