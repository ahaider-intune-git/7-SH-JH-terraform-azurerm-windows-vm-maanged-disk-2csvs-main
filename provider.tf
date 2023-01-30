#############################################################################
# Provider File
#############################################################################

provider "azurerm" { # azurerm is the provider form terraform for microsoft Azure 
  features {}
  skip_provider_registration = "true"
}