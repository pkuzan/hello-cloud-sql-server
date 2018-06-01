resource "azurerm_resource_group" "resourcegroup" {
  name = "${var.resource_group_name}"
  location = "${var.location}"

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name = "helloCloudVnet"
  address_space = [
    "${var.vnet_cidr}"]
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_subnet" "subnet" {
  name = "helloCloudSubnet"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix = "${var.subnet1_cidr}"
}

resource "azurerm_public_ip" "publicip" {
  name = "helloCloudPublicIP"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  public_ip_address_allocation = "dynamic"

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_network_security_group" "nsg" {
  name = "helloCloudNetworkSecurityGroup"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  security_rule {
    name = "SSH"
    priority = 1002
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "HTTP"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_network_interface" "nic" {
  name = "helloCloudNIC"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"

  ip_configuration {
    name = "myNicConfiguration"
    subnet_id = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${azurerm_public_ip.publicip.id}"
  }

  tags {
    environment = "${var.environment}"
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "virtual_machine" {
  name = "helloCloudVM"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = [
    "${azurerm_network_interface.nic.id}"]
  vm_size = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_os_disk {
    name = "myOsDisk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id = "/subscriptions/97cb539a-2f7f-42c7-b421-8343c7e9e73e/resourceGroups/HelloCloud/providers/Microsoft.Compute/images/helloCloudImage7"
  }

  os_profile {
    computer_name = "myvm"
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/azureuser/.ssh/authorized_keys"
      key_data = "${var.ssh_key_data}"
    }
  }

  boot_diagnostics {
    enabled = "true"
    storage_uri = "${azurerm_storage_account.storageaccount.primary_blob_endpoint}"
  }

  tags {
    environment = "${var.environment}"
  }
}




