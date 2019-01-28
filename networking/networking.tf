resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "${var.resource_group}-vnet1"
  location            = "${var.location}"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = "${azurerm_resource_group.rg.name}"

}

resource "azurerm_virtual_network" "vnet2" {
  name                = "${var.resource_group}-vnet2"
  location            = "${var.location}"
  address_space       = ["192.168.0.0/24"]
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet1.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet1.name}"
  address_prefix       = "10.0.2.0/24"
}


resource "azurerm_virtual_network_peering" "peer1" {
  name                         = "vNet1-to-vNet2"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  virtual_network_name         = "${azurerm_virtual_network.vnet1.name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.vnet2.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "peer2" {
  name                         = "vNet2-to-vNet1"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  virtual_network_name         = "${azurerm_virtual_network.vnet2.name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.vnet1.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_public_ip" "test" {
  name                         = "PublicIPForLB"
  location                     = "South Central US"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_lb" "test" {
  name                = "TestLoadBalancer"
  location            = "South Central US"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.test.id}"
  }
}

resource "azurerm_lb_rule" "test" {
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.test.id}"
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.test.id}"
  probe_id                       = "${azurerm_lb_probe.test.id}"
}

resource "azurerm_lb_nat_rule" "test" {
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.test.id}"
  name                           = "SSHAccess"
  protocol                       = "Tcp"
  frontend_port                  = 3200
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_probe" "test" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.test.id}"
  name                = "ssh-running-probe"
  port                = 22
}

resource "azurerm_lb_backend_address_pool" "test" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.test.id}"
  name                = "BackEndAddressPool"
}


resource "azurerm_network_interface" "nic" {
    name                = "${var.prefix}"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    enable_accelerated_networking = "True"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.internal.id}"
        private_ip_address_allocation = "dynamic"
	}
}

resource "azurerm_virtual_machine" "main" {
    name                  = "${var.prefix}-vm"
    location              = "${var.location}"
    resource_group_name   = "${azurerm_resource_group.rg.name}"
    network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
    vm_size               = "Standard_DS2_v2_Promo"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

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
}

resource "azurerm_network_interface_nat_rule_association" "nic" {
  network_interface_id  = "${azurerm_network_interface.nic.id}"
  ip_configuration_name = "myNicConfiguration"
  nat_rule_id           = "${azurerm_lb_nat_rule.test.id}"
}

resource "azurerm_network_interface_backend_address_pool_association" "test" {
  network_interface_id    = "${azurerm_network_interface.nic.id}"
  ip_configuration_name   = "myNicConfiguration"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.test.id}"
}

resource "azurerm_network_security_group" "test" {
  name                = "SecurityGroup1"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
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
    resource_group_name         = "${azurerm_resource_group.rg.name}"
    network_security_group_name = "${azurerm_network_security_group.test.name}"
  }

resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = "${azurerm_subnet.internal.id}"
  network_security_group_id = "${azurerm_network_security_group.test.id}"
}

resource "azurerm_public_ip" "azurefirewallpip" {
  name                         = "PublicIPForFW"
  location                     = "South Central US"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
  sku                          = "Standard"
}

resource "azurerm_firewall" "test" {
  name                = "AzureFirewall"
  location            = "South Central US"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = "${azurerm_subnet.firewall.id}"
    internal_public_ip_address_id = "${azurerm_public_ip.azurefirewallpip.id}"
  }
}