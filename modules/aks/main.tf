# Datasource to get Latest Azure AKS latest Version
data "azurerm_kubernetes_service_versions" "current" {
  location = var.location
  include_preview = false  
}
 
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                  = var.aks_cluster_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  dns_prefix            = "${var.resource_group_name}-cluster"           
  kubernetes_version    =  data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${var.resource_group_name}-nrg"
  sku_tier              = "Standard"
  private_cluster_enabled = true
  private_cluster_public_fqdn_enabled = true
  local_account_disabled = true
  automatic_channel_upgrade = "stable"
  # private_dns_zone_id = null # Replace with actual private DNS zone ID if needed
  azure_policy_enabled = true

  identity {
    type = "SystemAssigned"
  }
  
  default_node_pool {
    name       = "defaultpool"
    vm_size    = "Standard_D2s_v3"
    mode       = "System"

    os_disk_size_gb      = 30
    os_disk_type          = "Ephemeral"
    enable_host_encryption = true
    disk_encryption_set_id = var.aks_disk_encryption_set_id
    type                 = "VirtualMachineScaleSets"
    max_pods             = 50
    node_taints = ["CriticalAddonsOnly=true:NoSchedule"]
    node_labels = {
      "nodepool-type"    = "system"
      "environment"      = "staging"
      "nodepoolos"       = "linux"
     } 
   tags = {
      "nodepool-type"    = "system"
      "environment"      = "staging"
      "nodepoolos"       = "linux"
   } 
  }



  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
        key_data = tls_private_key.pk.public_key_openssh
    }
    
  }

    network_profile {

            network_plugin = "azure"
        
            load_balancer_sku = "standard"
        
            network_policy = "azure"
    }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  

    lifecycle {

      ignore_changes = [

        default_node_pool[0].upgrade_settings,

      ]

    }

  }


resource "azurerm_kubernetes_cluster_node_pool" "monitoring" {
  name                  = "monitoring"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-cluster.id
  vm_size               = "Standard_D2s_v3"
  node_count            = 1
  os_disk_size_gb       = 30
  os_disk_type           = "Ephemeral"
  os_type               = "Linux"
  enable_host_encryption = true
  disk_encryption_set_id = var.aks_disk_encryption_set_id
  max_pods              = 50

  lifecycle {
    ignore_changes = [
      upgrade_settings,
    ]
  }
}
