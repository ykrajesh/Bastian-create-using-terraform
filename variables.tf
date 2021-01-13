variable "resource_group_name" {
    type = string
    default = "VMMachine"
  }
variable "resource_group_location" {
  type = string
  default = "East us"
}

variable "Virtual_Machine_name" {
      default = ["TESTDC","TESTDC1"] 
    description = "Test Server"
}
variable "dc_ips" {
    type = list(string)
    default = ["10.0.2.5", "10.0.0.6"]
    description = "Test DC Ip Address "
}
####################  New Resource Info ###########################
variable "vm_name" {
    type = string
      default = "TESTDC"
    description = "Provide Server name"
}
variable "vm_ip" {
    type = string
      default = "10.0.2.8"
    description = " Server private ip address"
}