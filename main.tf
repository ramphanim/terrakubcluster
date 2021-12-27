provider "azurerm" {
  version ="~>2.0"
  features {}
  subscription_id = var.subscription_id
  client_secret = var.client_secret
  client_id = var.client_id
  tenant_id = var.tenant_id
}

resource "azurerm_resource_group" "bsrsg" {
  name = "bookstore-rg"
  location = "eastus"
}

resource "azurerm_log_analytics_workspace" "cluster-logs" {
  name                = "bookstore-logs"
  location            = azurerm_resource_group.bsrsg.location
  resource_group_name = azurerm_resource_group.bsrsg.name
  retention_in_days   = 30
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "bookstore-cluster"
  location            = azurerm_resource_group.bsrsg.location
  resource_group_name = azurerm_resource_group.bsrsg.name
  dns_prefix          = "bsrsg-cluster"

  default_node_pool {
    name                 = "systempool"
    vm_size              = "Standard_DS2_v2"
    availability_zones   = [1, 2, 3]
    enable_auto_scaling  = true
    max_count            = 3
    min_count            = 1
    os_disk_size_gb      = 30
    type                 = "VirtualMachineScaleSets"
    node_labels = {
      "nodepool-type"    = "system"
      "environment"      = "dev"
      "nodepoolos"       = "linux"
      "app"              = "system-apps" 
    } 
   tags = {
      "nodepool-type"    = "system"
      "environment"      = "dev"
      "nodepoolos"       = "linux"
      "app"              = "system-apps" 
   } 
  }

# Identity (System Assigned or Service Principal)
  identity {
    type = "SystemAssigned"
  }

# Add On Profiles
  addon_profile {
    azure_policy {enabled =  true}
    oms_agent {
      enabled =  true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.cluster-logs.id
    }
  }


# Windows Profile
  windows_profile {
    admin_username = "azureadmin"
    admin_password = "azureadmin@1234"
  }

# Linux Profile
  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file("C:/Users/home/.ssh/aks-dev-sshkeys/aksdev.pub")
    }
  }

# Network Profile
  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "Standard"
  }

  tags = {
    Environment = "dev"
  }
}