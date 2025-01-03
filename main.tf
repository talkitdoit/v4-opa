# basic terraform file for demo testing

provider "azurerm" {
  features {}
}

################################
# Protected Production Resources
################################

# Protected resource group
resource "azurerm_resource_group" "rg" {
  name     = "rg-talkitdoit-terraform-protected-youtube"
  location = "West Europe"

  # Protected tags
  tags = {
    environment = "production"
    critical    = "true"
  }
}

# Protected vnet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-talkitdoit-terraform-protected"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["172.16.0.0/16"]

  # Protected tags
  tags = {
    environment = "production"
    critical    = "true"
  }
}

# Protected subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-talkitdoit-terraform-protected"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.16.1.0/24"]
}

#####################################
# Non-Protected Development Resources
#####################################

# Development resource group
resource "azurerm_resource_group" "rg_dev" {
  name     = "rg-talkitdoit-terraform-non-protected"
  location = "West Europe"

  # Non-protected tags
  tags = {
    environment = "development"
    critical    = "false"
  }
}

# Development vnet
resource "azurerm_virtual_network" "vnet_dev" {
  name                = "vnet-talkitdoit-terraform-non-protected"
  location            = azurerm_resource_group.rg_dev.location
  resource_group_name = azurerm_resource_group.rg_dev.name
  address_space       = ["10.0.0.0/16"]

  # Non-protected tags
  tags = {
    environment = "development"
    critical    = "false"
  }
}

# Development subnet
resource "azurerm_subnet" "subnet_dev" {
  name                 = "subnet-talkitdoit-terraform-non-protected"
  resource_group_name  = azurerm_resource_group.rg_dev.name
  virtual_network_name = azurerm_virtual_network.vnet_dev.name
  address_prefixes     = ["10.0.1.0/24"]
}