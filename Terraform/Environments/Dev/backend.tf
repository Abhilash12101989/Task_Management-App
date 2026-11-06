
terraform {
  backend "azurerm" {
    resource_group_name  = "Abhi-RG"
    storage_account_name = "backend47534"
    container_name       = "taskmanagementbackend"
    key                  = "dev.terraform.tfstate"
  }
}
