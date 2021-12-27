terraform {
    backend "azurerm"{
        resource_group_name = "terrakubcluster"
        storage_account_name = "terrakubclus"
        container_name = "terrcont"
        key = "dev.terraform.terrcont"
        access_key = "igvxf4dN70EDcqZfA9HFypcYbX8ElG7ESM8SxMGw9ho5qbAFlUvsovVDPV9spXP/IzAVE0G1UtkgPT0GlmEqlA=="
    }
}