terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.42.0"
    }
  }
  required_version = ">= 1.3.8"
  backend "azurerm" {}
}
