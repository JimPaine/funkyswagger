variable "subscription_id" {}
variable "container" {}
variable "functionname" {}

provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  version         = "~> 1.6"
}

provider "random" {
  version = "~> 1.3"
}

resource "azurerm_resource_group" "funkyswagger" {
  name     = "${var.functionname}"
  location = "northeurope"
}

resource "random_id" "funkyswagger" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.funkyswagger.name}"
  }

  byte_length = 2
}

resource "azurerm_storage_account" "funkyswagger" {
  name                     = "funkyswagger${random_id.funkyswagger.dec}"
  resource_group_name      = "${azurerm_resource_group.funkyswagger.name}"
  location                 = "${azurerm_resource_group.funkyswagger.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "funkyswagger" {
  name                  = "${var.container}"
  resource_group_name   = "${azurerm_resource_group.funkyswagger.name}"
  storage_account_name  = "${azurerm_storage_account.funkyswagger.name}"
  container_access_type = "container"
}

resource "azurerm_app_service_plan" "funkyswagger" {
  name                = "azure-functions-funkyswagger-service-plan"
  location            = "${azurerm_resource_group.funkyswagger.location}"
  resource_group_name = "${azurerm_resource_group.funkyswagger.name}"
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "funkyswagger" {
  name                      = "${var.functionname}"
  location                  = "${azurerm_resource_group.funkyswagger.location}"
  resource_group_name       = "${azurerm_resource_group.funkyswagger.name}"
  app_service_plan_id       = "${azurerm_app_service_plan.funkyswagger.id}"
  storage_connection_string = "${azurerm_storage_account.funkyswagger.primary_connection_string}"
}

data "azurerm_storage_account" "funkyswagger" {
  name                = "${azurerm_storage_account.funkyswagger.name}"
  resource_group_name = "${azurerm_resource_group.funkyswagger.name}"
}

output "storage_connection_string" {
  value = "${data.azurerm_storage_account.funkyswagger.primary_blob_endpoint}"
}

output "account_name" {
  value = "${data.azurerm_storage_account.funkyswagger.name}"
}

output "primary_connection_string" {
  value = "${data.azurerm_storage_account.funkyswagger.primary_connection_string}"
}
