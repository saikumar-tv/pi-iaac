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
provider "azurerm" {
  features {}
  subscription_id = "7bface60-33c3-419f-a359-2be340218241"
}

provider "helm" {
  kubernetes = {
    host                   = module.aks.kube_config[0].host
    client_certificate     = base64decode(module.aks.kube_config[0].client_certificate)
    client_key             = base64decode(module.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(module.aks.kube_config[0].cluster_ca_certificate)
  }
}

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
  filename = "kube_config"
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true

  set = [
    {
      name  = "grafana.service.type"
      value = "LoadBalancer"
    }
  ]

  depends_on = [
    module.aks,
    local_file.kube_config
  ]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  create_namespace = true

  set = [
    {
      name  = "server.service.type"
      value = "LoadBalancer"
    }
  ]

  depends_on = [
    module.aks,
    local_file.kube_config
  ]
}