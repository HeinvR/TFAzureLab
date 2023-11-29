# To configure dsc pull configuration use the folliwng dsc extension, dsc config and dsc node config resources:

resource "azurerm_virtual_machine_extension" "srv1_dsc_pull" {
  name                 = "srv1_dsc_pull"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm_srv1.id
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.9"

  settings = <<SETTINGS_JSON
        {
          "configurationArguments": {
              "RegistrationUrl": "${azurerm_automation_account.aa.dsc_server_endpoint}",
              "NodeConfigurationName": "${azurerm_windows_virtual_machine.vm_srv1.name}.localhost",
              "ConfigurationMode": "ApplyandAutoCorrect",
              "ConfigurationModeFrequencyMins": 15,
              "RefreshFrequencyMins": 30,
              "RebootNodeIfNeeded": false,
              "ActionAfterReboot": "continueConfiguration",
              "AllowModuleOverwrite": true
          }
        }
    SETTINGS_JSON

  protected_settings = <<PROTECTED_SETTINGS_JSON
    {
      "configurationArguments": {
         "RegistrationKey": {
                  "UserName": "PLACEHOLDER_DONOTUSE",
                  "Password": "${azurerm_automation_account.aa.dsc_primary_access_key}"
                }
      }
    }
PROTECTED_SETTINGS_JSON
depends_on = [azurerm_virtual_machine_extension.srv1_dsc_push]
}

resource "azurerm_automation_dsc_configuration" "dsc_config_pull" {
  name                    = "${azurerm_windows_virtual_machine.vm_srv1.name}"
  resource_group_name     = azurerm_resource_group.aa_rg.name
  automation_account_name = azurerm_automation_account.aa.name
  location                = azurerm_resource_group.aa_rg.location
  content_embedded        = "configuration ${azurerm_windows_virtual_machine.vm_srv1.name} {}"
}

resource "azurerm_automation_dsc_nodeconfiguration" "dsc_node_config_pull" {
  name                    = "${azurerm_windows_virtual_machine.vm_srv1.name}.localhost"
  resource_group_name     = azurerm_resource_group.aa_rg.name
  automation_account_name = azurerm_automation_account.aa.name
  content_embedded = file("${path.module}/unusedExampleCode/mof/srv1_pull.mof")
}