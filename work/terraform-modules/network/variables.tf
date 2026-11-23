variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "vnet_name" { type = string }
variable "address_space" { type = list(string) }
variable "function_subnet_prefixes" { type = list(string) }
variable "private_subnet_prefixes" { type = list(string) }
variable "appservice_subnet_prefixes" { type = list(string) }