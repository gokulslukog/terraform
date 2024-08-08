resource "azurerm_virtual_network" "main" {
  name                = "${var.env}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.loc}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "Master_public_ip" {
  name                = "myPublicIP_master"
  location            = "${var.loc}"
  resource_group_name = "${var.resource_group_name}"
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "Slave_public_ip" {
  name                = "myPublicIP_slave"
  location            = "${var.loc}"
  resource_group_name = "${var.resource_group_name}"
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "my_terraform_nsg_master" {
  name                = "myNetworkSecurityGroup"
  location            = "${var.loc}"
  resource_group_name = "${var.resource_group_name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "my_terraform_nsg_slave" {
  name                = "myNetworkSecurityGroup"
  location            = "${var.loc}"
  resource_group_name = "${var.resource_group_name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "main" {
  name                = "${var.env}-nic"
  location            = "${var.loc}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Master_public_ip.id
  }
  
}
  
resource "azurerm_network_interface" "slave" {
  name                = "${var.env}-slavenic"
  location            = "${var.loc}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "testconfiguration2"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Slave_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "MasterAssociation" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg_master.id
}

resource "azurerm_network_interface_security_group_association" "SlaveAssociation" {
  network_interface_id      = azurerm_network_interface.slave.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg_slave.id
}