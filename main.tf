variable "subscription_id" {
    type = string
    default = "01a46e55-cf0d-4474-baff-2fa9355746ad"
    description = "Azure subscription id"
}

variable "client_id" {
    type = string
    default = "5c910eb9-676c-472c-b251-59e4105ea41a"
    description = "Azure client id"
}

variable "client_secret" {
    type = string
    default = "VD47Q~Q6CPjUbTq.GjBqj~BRxlX_m-~wdBty4"
    description = "Azure client secret"
}

variable "tenant_id" {
    type = string
    default = "0685ede4-80f7-4213-a5b1-2b820487d3a2"
    description = "Azure tenant id"
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
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
