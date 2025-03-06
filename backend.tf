terraform {
  backend "azurerm" {
    resource_group_name  = "rg-adolearn-epam-cloud-and-devops-practice-tfstate"
    storage_account_name = "adolearntfstatestorag"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
