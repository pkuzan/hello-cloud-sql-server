resource "azurerm_public_ip" "jumpbox" {
  name = "jumpbox-public-ip"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  public_ip_address_allocation = "static"
  domain_name_label = "lapis-hello-cloud-ssh"

  tags {
    environment = "helloCloud"
  }
}

resource "azurerm_network_interface" "jumpbox" {
  name = "jumpbox-nic"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name = "IPConfiguration"
    subnet_id = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${azurerm_public_ip.jumpbox.id}"
  }

  tags {
    environment = "helloCloud"
  }
}

resource "azurerm_virtual_machine" "jumpbox" {
  name = "jumpbox"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  network_interface_ids = [
    "${azurerm_network_interface.jumpbox.id}"]
  vm_size = "Standard_DS1_v2"

  storage_image_reference {
    id = "/subscriptions/97cb539a-2f7f-42c7-b421-8343c7e9e73e/resourceGroups/HelloCloud/providers/Microsoft.Compute/images/jumpBoxImage2"
  }

  storage_os_disk {
    name = "jumpbox-osdisk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = "jumpbox"
    admin_username = "azureuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path = "/home/azureuser/.ssh/authorized_keys"
      key_data = "${var.ssh_key_data}"
    }
  }

  tags {
    environment = "helloCloud"
  }
}