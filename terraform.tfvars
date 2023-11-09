env_prefix = "hta"
location = "westeurope"
address_space = ["10.0.0.0/16"]
subnets = {
    "LAN" = { name = "LAN", address = "10.0.1.0/24"},
    "DMZ" = { name = "DMZ", address = "10.0.2.0/24"}
}
vm_size = "Standard_F2"
local_username = "localuser"
local_password = "98*V>q0BrNKQ"
