resource "azurerm_virtual_network" "vnet" {
  name = "helloCloudVnet"
  address_space = [
    "${var.vnet_cidr}"]
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_subnet" "subnet" {
  name = "helloCloudSubnet"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix = "${var.subnet1_cidr}"
}


resource "azurerm_public_ip" "publicIp" {
  name = "vmss-public-ip"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  public_ip_address_allocation = "static"
  #Domain must be lower-case. Originally used resource group name.
  domain_name_label = "lapis-hello-cloud"

  tags {
    environment = "helloCloud"
  }
}

resource "azurerm_lb" "loadBalancer" {
  name = "vmss-lb"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.publicIp.id}"
  }

  tags {
    environment = "helloCloud"
  }
}


resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id = "${azurerm_lb.loadBalancer.id}"
  name = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "vmss" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id = "${azurerm_lb.loadBalancer.id}"
  name = "ssh-running-probe"
  port = "${var.application_port}"
}

resource "azurerm_lb_rule" "lbnatrule" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id = "${azurerm_lb.loadBalancer.id}"
  name = "http"
  protocol = "Tcp"
  frontend_port = "${var.application_port}"
  backend_port = "${var.application_port}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.bpepool.id}"
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id = "${azurerm_lb_probe.vmss.id}"
}

resource "azurerm_virtual_machine_scale_set" "vmss" {
  name = "vmscaleset"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  upgrade_policy_mode = "Manual"

  sku {
    name = "Standard_DS1_v2"
    tier = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    id = "/subscriptions/97cb539a-2f7f-42c7-b421-8343c7e9e73e/resourceGroups/HelloCloud/providers/Microsoft.Compute/images/helloCloudImage6"
  }

  storage_profile_os_disk {
    name = ""
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun = 0
    caching = "ReadWrite"
    create_option = "Empty"
    disk_size_gb = 10
  }

  extension {
    name = "vmInstallExtension"
    publisher = "Microsoft.OSTCExtensions"
    type = "CustomScriptForLinux"
    type_handler_version = "1.2"
    settings = "{\"commandToExecute\": \"sh /opt/webapp/start_server.sh\"}"
  }

  extension {
    name = "MSILinuxExtension"
    publisher = "Microsoft.ManagedIdentity"
    type = "ManagedIdentityExtensionForLinux"
    type_handler_version = "1.0"
    settings = "{\"port\": 50342}"
  }

  os_profile {
    computer_name_prefix = "vmlab"
    admin_username = "azureuser"
    admin_password = "Passwword1234"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path = "/home/azureuser/.ssh/authorized_keys"
      key_data = "${var.ssh_key_data}"
    }
  }

  network_profile {
    name = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name = "IPConfiguration"
      subnet_id = "${azurerm_subnet.subnet.id}"
      load_balancer_backend_address_pool_ids = [
        "${azurerm_lb_backend_address_pool.bpepool.id}"]
    }
  }

  tags {
    environment = "helloCloud"
  }
}