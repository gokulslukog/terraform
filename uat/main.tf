provider "azurerm" {
  features {}
}


module "box" {
 source = "../module/box"
 env = var.env
 loc = var.location
}

#module "Ansible" {
# source = "../module/Ansible"
#  master_host = "${master_host}"
#  slave_host = "${slave_host}"
#}