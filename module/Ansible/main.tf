resource "azurerm_virtual_machine" "ansible_install" {

provisioner "remote-exec" {
  inline = [
    "echo working",
    "touch didit.txt",
    "pwd"
  ]
connection {
    type     = "ssh"
    user = "${var.username}"
    password = "${var.password}"
    host     = "${var.master_host}"
  }



  }
  }