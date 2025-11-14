terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "4.1.0"
        }
    }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

}

resource "azurerm_resource_group" "my_rg" {
    name = "my_rg"
    location = "Australia Southeast"

    tags = {
        environment = "dev"
        source = "Terraform"
    }
}

