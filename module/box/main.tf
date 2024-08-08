module "rg" {
  source = "../rg"
  loc = var.loc
  env = var.env
 }

module "network" {
  source = "../network"
  loc = var.loc
  env = var.env
  resource_group_name = "${module.rg.resource_group_name}"

  depends_on = [
    module.rg
  ]
}



resource "azurerm_virtual_machine" "main" {
  name                  = "${var.env}-Masterinstance"
  location              = var.loc
  resource_group_name   = "${module.rg.resource_group_name}"
  network_interface_ids = ["${module.network.network_id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
   delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
  provisioner "file" {
      connection {
    type     = "ssh"
    user = "${var.username}"
    password = "${var.password}"
    host     = "${module.network.master_host}"
  }

    source      = "ansible_installation.sh"
    destination = "/tmp/ansible_installation.sh"
  }
#   provisioner "remote-exec" {
#       connection {
#     type     = "ssh"
#     user = "${var.username}"
#     password = "${var.password}"
#     host     = "${module.network.master_host}"
#   }
#   inline = [
#     "echo working",
#     "touch didit.txt",
#     "pwd"
#   ]
 

#  }

  depends_on = [
    module.network
   ]
}

resource "azurerm_virtual_machine_extension" "ansible" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_virtual_machine.main.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "commandToExecute": "sh /tmp/ansible_installation.sh >> /tmp/output.txt"
 }
SETTINGS


  tags = {
    environment = "Production"
  }
}

resource "azurerm_virtual_machine" "slave" {
  name                  = "${var.env}-Slaveinstance"
  location              = "${var.loc}"
  resource_group_name   = "${module.rg.resource_group_name}"
  network_interface_ids = ["${module.network.network_id_slave}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
   delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }

  
  
  depends_on = [
    module.network
   ]
}