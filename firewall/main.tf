#refer to a subnet
data "azurerm_resource_group" "hub" {
  name     = "myrg"
}

data "azurerm_subnet" "subnet" {
  name                 = "AzureFirewallSubnet"
  virtual_network_name = "myrg-vnet1"
  resource_group_name  = "${data.azurerm_resource_group.hub.name}"
}

resource "azurerm_public_ip" "test" {
  name                         = "PublicIPForFW"
  location                     = "South Central US"
  resource_group_name          = "${data.azurerm_resource_group.hub.name}"
  public_ip_address_allocation = "static"
  sku                          = "Standard"
}

resource "azurerm_firewall" "test" {
  name                = "AzureFirewall"
  location            = "South Central US"
  resource_group_name = "${data.azurerm_resource_group.hub.name}"

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    internal_public_ip_address_id = "${azurerm_public_ip.test.id}"
  }
}
