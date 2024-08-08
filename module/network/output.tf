output "network_id" {
  value = "${azurerm_network_interface.main.id}"
  
}

output "network_id_slave" {
  value = "${azurerm_network_interface.slave.id}"
  
}

output "master_host" {
  value = "${azurerm_public_ip.Master_public_ip.ip_address}"
}

output "slave_host" {
  value = "${azurerm_public_ip.Slave_public_ip.ip_address}"
}