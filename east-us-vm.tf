




# Resource group
resource "azurerm_resource_group" "DevSecOps-east-usRG" {
  name     = "DevSecOps-east-usRG"
  location = "East US"
  tags = {
    evironment = "dev"
    source     = "Terraform"
    owner      = "Justus"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "DevSecOps-east-us-vNet" {
  name                = "DevSecOps-east-us-vNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.DevSecOps-east-usRG.location
  resource_group_name = azurerm_resource_group.DevSecOps-east-usRG.name
}

# Subnet
resource "azurerm_subnet" "DevSecOps-east-us-subNet" {
  name                 = "DevSecOps-east-us-subNet"
  resource_group_name  = azurerm_resource_group.DevSecOps-east-usRG.name
  virtual_network_name = azurerm_virtual_network.DevSecOps-east-us-vNet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IP
resource "azurerm_public_ip" "DevSecOps-east-us-PublicIp" {
  name                = "DevSecOps-east-us-PublicIp"
  resource_group_name = azurerm_resource_group.DevSecOps-east-usRG.name
  location            = azurerm_resource_group.DevSecOps-east-usRG.location
  allocation_method   = "Static"

  tags = {
    environment = "dev"
  }
}


# Network Interface
resource "azurerm_network_interface" "DevSecOps-east-us-NIC" {
  name                = "DevSecOps-east-us-NIC"
  location            = azurerm_resource_group.DevSecOps-east-usRG.location
  resource_group_name = azurerm_resource_group.DevSecOps-east-usRG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.DevSecOps-east-us-subNet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.DevSecOps-east-us-PublicIp.id
  }
}

# Network Security Group
resource "azurerm_network_security_group" "DevSecOps-east-us-NSG" {
  name                = "DevSecOps-east-us-NSG"
  location            = azurerm_resource_group.DevSecOps-east-usRG.location
  resource_group_name = azurerm_resource_group.DevSecOps-east-usRG.name

  security_rule {
    name                       = "allow_sonarqube9000"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_jenkins8080"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH22"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface Security Group Association
resource "azurerm_network_interface_security_group_association" "DevSecOps-east-us-NISGA" {
  network_interface_id      = azurerm_network_interface.DevSecOps-east-us-NIC.id
  network_security_group_id = azurerm_network_security_group.DevSecOps-east-us-NSG.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "DevSecOps-east-us-VM" {
  name                = "DevSecOps-east-us-VM"
  location            = azurerm_resource_group.DevSecOps-east-usRG.location
  resource_group_name = azurerm_resource_group.DevSecOps-east-usRG.name
  size                = "Standard_B2ms"
  admin_username      = "DevSecOps_Admin"
  network_interface_ids = [
    azurerm_network_interface.DevSecOps-east-us-NIC.id
  ]

  admin_ssh_key {
    username   = "DevSecOps_Admin"
    public_key = file("~/.ssh/DevSecOps.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    name                 = "DevSecOps-east-us-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    # managed_disk_type = "StandardSSD_LRS"
    disk_size_gb = 30 # OS disk size in GiB
  }


  disable_password_authentication = true


  computer_name = "essentials"

}
