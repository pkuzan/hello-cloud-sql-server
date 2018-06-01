resource "azurerm_virtual_machine_extension" "virtual_machine_extension" {
  name = "msiExtension"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  virtual_machine_name = "${azurerm_virtual_machine.virtual_machine.name}"
  publisher = "Microsoft.ManagedIdentity"
  type = "ManagedIdentityExtensionForLinux"
  type_handler_version = "1.0"

  settings = <<SETTINGS
    {
        "port": 50342
    }
  SETTINGS
}

resource "azurerm_virtual_machine_extension" "custom_script_extension" {
  name = "vmInstallExtension"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  virtual_machine_name = "${azurerm_virtual_machine.virtual_machine.name}"
  publisher = "Microsoft.OSTCExtensions"
  type = "CustomScriptForLinux"
  type_handler_version = "1.2"

  settings = <<SETTINGS
  {
  "commandToExecute": "sh /opt/webapp/start_server.sh"
  }
SETTINGS

  tags {
    environment = "${var.environment}"
  }
}


#https://gist.github.com/pkuzan/a8fbc202af4a365f94d541bfc3676221/raw/vm-config.sh
#https://gist.github.com/[gist_user]/[gist_id]/raw/[file_name]