provider "azurerm" {
  features = {}
}

# Resource group
resource "azurerm_resource_group" "tf-jenkins-rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "tf-jenkins-vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.tf-jenkins-rg.location
  resource_group_name = azurerm_resource_group.tf-jenkins-rg.name
}

# Subnet
resource "azurerm_subnet" "tf-jenkins-subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.tf-jenkins-rg.name
  virtual_network_name = azurerm_virtual_network.tf-jenkins-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group (NSG) - Restrict to essential ports
resource "azurerm_network_security_group" "tf-jenkins-nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.tf-jenkins-rg.location
  resource_group_name = azurerm_resource_group.tf-jenkins-rg.name

  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow_Jenkins"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # No SSH port (22) rule for enhanced security
}

# Network Interface (NIC)
resource "azurerm_network_interface" "tf-jenkins-nic" {
  name                = var.nic_name
  location            = azurerm_resource_group.tf-jenkins-rg.location
  resource_group_name = azurerm_resource_group.tf-jenkins-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tf-jenkins-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tf-jenkins-pubip.id
  }
}

# Public IP Address
resource "azurerm_public_ip" "tf-jenkins-pubip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.tf-jenkins-rg.location
  resource_group_name = azurerm_resource_group.tf-jenkins-rg.name
  allocation_method   = "Dynamic"
}

# Virtual Machine without SSH
resource "azurerm_linux_virtual_machine" "tf-jenkins-vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.tf-jenkins-rg.name
  location            = azurerm_resource_group.tf-jenkins-rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.tf-jenkins-nic.id]
  
  # Removed SSH key block for increased security
  os_disk {
    name              = "${var.vm_name}-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb      = 16
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    Name   = var.jenkins_server_tag
    Server = "Jenkins"
  }

  # Custom script for Jenkins installation
  custom_data = filebase64("jenkinsdata.sh")
}

# Network Interface Security Association
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.tf-jenkins-nic.id
  network_security_group_id = azurerm_network_security_group.tf-jenkins-nsg.id
}

# Output the Jenkins URL
output "JenkinsURL" {
  value = "http://${azurerm_public_ip.tf-jenkins-pubip.ip_address}:8080"
}
