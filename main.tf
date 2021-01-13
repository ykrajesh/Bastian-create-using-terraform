provider "azurerm" {
  features { }
}
# create the resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}
resource "azurerm_resource_group" "rg-net" {
  name     = "${azurerm_resource_group.rg.name}-Network"
  location = var.resource_group_location
}

# create virtual network 
resource "azurerm_virtual_network" "vnet" {
  name                = "Vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg-net.location
  resource_group_name = azurerm_resource_group.rg-net.name
}
# create subnet in vnet
resource "azurerm_subnet" "subnet" {
  name                 = "Subnet"
  resource_group_name  = azurerm_resource_group.rg-net.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

#create Network interface 
resource "azurerm_network_interface" "Interface" {
  name                = "${var.Virtual_Machine_name[1]}-Nic"
  location            = azurerm_resource_group.rg-net.location
  resource_group_name = azurerm_resource_group.rg-net.name

  ip_configuration {
    name                          = "${var.Virtual_Machine_name[1]}-IP"
    subnet_id                     = azurerm_subnet.subnet.id
    //private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public.id
    private_ip_address_allocation = "Static"
    private_ip_address = var.dc_ips[0]
  }
}

#create public ip address
resource "azurerm_public_ip" "public" {
  name                    = "${var.Virtual_Machine_name[1]}-PIP"
  location                = azurerm_resource_group.rg-net.location
  resource_group_name     = azurerm_resource_group.rg-net.name
  allocation_method       = "Dynamic"
  
}

# create the  Vm machine 
resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.Virtual_Machine_name[1]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "vmadmin"
  admin_password      = "Welcome@1234"
  network_interface_ids = [
    azurerm_network_interface.Interface.id,
  ]
# Disk type define here
  os_disk {
    name = "${var.Virtual_Machine_name[1]}-OS-Disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
# os Source 
 source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

######################### Add new VM ###########################

#create Network interface 
resource "azurerm_network_interface" "Interface1" {
  name = "${var.vm_name}-Nic"
  //name                = "${var.info["name"]}-Nic"
  location            = azurerm_resource_group.rg-net.location
  resource_group_name = azurerm_resource_group.rg-net.name

  ip_configuration {
    name = "${var.vm_name}-IP"
    //name                          = "${var.info["name"]}-IP"
    subnet_id                     = azurerm_subnet.subnet.id
    //private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public1.id
    private_ip_address_allocation = "Static"
    private_ip_address = var.vm_ip
  }
}

#create public ip address
resource "azurerm_public_ip" "public1" {
  name                    = "${var.vm_name}-PIP"
  location                = azurerm_resource_group.rg-net.location
  resource_group_name     = azurerm_resource_group.rg-net.name
  allocation_method       = "Dynamic"
  
}

# create the  Vm machine 
resource "azurerm_windows_virtual_machine" "vm1" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "vmadmin"
  admin_password      = "Welcome@1234"
  network_interface_ids = [
    azurerm_network_interface.Interface1.id,
  ]
# Disk type define here
  os_disk {
    name = "${var.vm_name}-OS-Disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
# os Source 
 source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

#################################### Create Bastion  ############################
resource "azurerm_resource_group" "bastion" {
  name = "${azurerm_resource_group.rg.name}-bastion"
  location = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "bsubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  =azurerm_resource_group.rg-net.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/27"]
}

resource "azurerm_public_ip" "Bastion-pip" {
  name                = "Bastion-pip"
  location            = azurerm_resource_group.bastion.location
  resource_group_name = azurerm_resource_group.bastion.name
  allocation_method   = "Static"
  sku                 = "Standard"
  
}

resource "azurerm_bastion_host" "bastion" {
  name                = "Eastus-bastion"
  location            = azurerm_resource_group.bastion.location
  resource_group_name = azurerm_resource_group.bastion.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bsubnet.id
    public_ip_address_id = azurerm_public_ip.Bastion-pip.id
  }
}
