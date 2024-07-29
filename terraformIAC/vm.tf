

# Virtual Machine
resource "azurerm_linux_virtual_machine" "DevSecOps_vm" {
  name                = "DevSecOps_v-machine"
  resource_group_name = azurerm_resource_group.DevSecOps_rg.name
  location            = azurerm_resource_group.DevSecOps_rg.location
  size                = "Standard_B2s"
  admin_username      = "DevSecOps_Admin"
  network_interface_ids = [
    azurerm_network_interface.DevSecOps_nic.id,
  ]

  admin_ssh_key {
    username   = "DevSecOps_Admin"
    public_key = file("~/.ssh/DevSecOps.pub")
  }

  os_disk {
    name                 = "DevSecOpsOSDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 30 # Set the OS disk size
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  disable_password_authentication = true


  computer_name = "essentials"
}

# Azure Backup for VM
resource "azurerm_recovery_services_vault" "DevSecOps-vault" {
  name                = "DevSecOps-recovery-vault"
  location            = azurerm_resource_group.DevSecOps_rg.location
  resource_group_name = azurerm_resource_group.DevSecOps_rg.name
  sku                 = "Standard"

  #   soft_delete_enabled = true
}

resource "azurerm_backup_policy_vm" "DevSecOps-backup_policy" {
  name                = "DevSecOps-recovery-vault-policy"
  resource_group_name = azurerm_resource_group.DevSecOps_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.DevSecOps-vault.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }
  retention_daily {
    count = 10
  }
}

resource "azurerm_backup_protected_vm" "vm1" {
  resource_group_name = azurerm_resource_group.DevSecOps_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.DevSecOps-vault.name
  source_vm_id        = azurerm_linux_virtual_machine.DevSecOps_vm.id
  backup_policy_id    = azurerm_backup_policy_vm.DevSecOps-backup_policy.id
}