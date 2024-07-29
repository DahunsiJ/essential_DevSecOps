# Resource group
resource "azurerm_resource_group" "DevSecOps_rg" {
  name     = "DevSecOpsResourceGroup"
  location = "South Africa North"
  tags = {
    evironment = "dev"
    source     = "Terraform"
    owner      = "justus"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "DevSecOps_vnet" {
  name                = "DevSecOps_virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.DevSecOps_rg.location
  resource_group_name = azurerm_resource_group.DevSecOps_rg.name
}

# Subnet
resource "azurerm_subnet" "DevSecOps_subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.DevSecOps_rg.name
  virtual_network_name = azurerm_virtual_network.DevSecOps_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "DevSecOps_NSG" {
  name                = "DevSecOps_NSG"
  location            = azurerm_resource_group.DevSecOps_rg.location
  resource_group_name = azurerm_resource_group.DevSecOps_rg.name

  security_rule {
    name                       = "allow_sonarqube"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_jenkins"
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
    name                       = "AllowSSH"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface
resource "azurerm_network_interface" "DevSecOps_nic" {
  name                = "DevSecOps-nic"
  location            = azurerm_resource_group.DevSecOps_rg.location
  resource_group_name = azurerm_resource_group.DevSecOps_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.DevSecOps_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.DevSecOps-Public_IP.id
  }
}

resource "azurerm_network_interface_security_group_association" "DevSecOps_nic_SGA" {
  network_interface_id      = azurerm_network_interface.DevSecOps_nic.id
  network_security_group_id = azurerm_network_security_group.DevSecOps_NSG.id
}

# VM Public IP
resource "azurerm_public_ip" "DevSecOps-Public_IP" {
  name                = "DevSecOps-PublicIP"
  location            = azurerm_resource_group.DevSecOps_rg.location
  resource_group_name = azurerm_resource_group.DevSecOps_rg.name
  allocation_method   = "Static"
}