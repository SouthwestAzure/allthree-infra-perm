data "azurerm_resource_group" "hub" {
  name     = "myrg"
}

data "azurerm_subnet" "subnet" {
  name                 = "subnet1"
  virtual_network_name = "myrg-vnet2"
  resource_group_name  = "${data.azurerm_resource_group.hub.name}"
}

resource "azurerm_network_security_group" "test" {
  name                = "acceptanceTestSecurityGroup1"
  location            = "${data.azurerm_resource_group.hub.location}"
  resource_group_name = "${data.azurerm_resource_group.hub.name}"
}

resource "azurerm_network_security_rule" "test" {
    name                        = "ssh_22"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "${data.azurerm_resource_group.hub.name}"
    network_security_group_name = "${azurerm_network_security_group.test.name}"
  }

resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = "${data.azurerm_subnet.subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.test.id}"
}
