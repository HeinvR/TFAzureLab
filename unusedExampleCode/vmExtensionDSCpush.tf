# to push dsc config via VM extension use the following code. Make sure de zip, referenced in de url is reachable.
resource "azurerm_virtual_machine_extension" "srv1_dsc_push" {
  name                 = "srv1_dsc_push"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm_srv1.id
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.83"

  settings = <<SETTINGS_JSON
            {
                "WmfVersion": "latest",
                "configuration": {
                    "url": "https://github.com/HeinvR/TFAzureLab/raw/main/iis_setup.zip",
                    "script": "iis_setup.ps1",
                    "function": "iis_setup"
                }
            }
    SETTINGS_JSON
  depends_on = [azurerm_windows_virtual_machine.vm_srv1]
}