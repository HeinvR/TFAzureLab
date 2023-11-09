variable env_prefix {
  type        = string
  description = "Env short prefix"
}

variable location {
  type        = string
  description = "Location to deploy"
}

variable address_space {
  type        = list
  description = "Address space for the vnet"
}

variable subnets {
  type = map(object({
    name    = string
    address = string
  }))
  description = "Subnets to create in the vnet"
}

variable local_username {
  type = string
  description = "local admin username"
}

variable local_password {
  type = string
  description = "local admin password"
}

variable vm_size {
    type = string
    description = "Size of the virtual machine"
}