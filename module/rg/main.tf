resource "azurerm_resource_group" "RG" {
  name     = "${var.env}-resources"
  location = "${var.loc}"
}