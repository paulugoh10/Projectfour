terraform {
  backend "azurerm" {
    resource_group_name  = "tfstateRG1"
    storage_account_name = "tfstatestorage054"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}