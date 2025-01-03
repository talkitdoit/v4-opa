terraform {
  backend "azurerm" {
    resource_group_name = "rg-talkitdoit-terraform-state"
    storage_account_name = "sttalkitdoitterraform"
    container_name = "tfstate"
    key = "terraform.tfstate"
  }
}