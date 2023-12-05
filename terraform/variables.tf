#--Subscription
variable "subscription_id" {
  type        = string
  description = "Subscription id"
  default     = "SUBSCRIPTION-ID"
}

#--Tenant
variable "tenant_id" {
  type        = string
  description = "Tenant id"
  default     = "TENANT-ID"
}

variable "resource_group" {
  description = "Resource Group"
  type        = string
  default     = "RESOURCE-GROUP"
}

#--Base VNet
variable "base_vnet" {
  description = "Base Vnet"
  type        = string
  default     = "ENCC-IPsec"
}

variable "location" {
  description = "Location"
  type        = string
  default     = "westus2"
}

#--Subnet Address Spaces
variable "peer_subnet_address_spaces" {
  description = "On-prem subnets"
  type        = list(string)
  default     = ["192.168.150.1/32"]
}

variable "local_vpn_gateway" {
  description = "VPN Gateway"
  type        = string
  default     = "encc_ipsec_vpn_gateway"
}

variable "peer_vpn_gateway" {
  description = "Peer VPN Gateway"
  type        = string
  default     = "encc_ipsec_vpn_peer"
}

variable "vpn_connection" {
  description = "VPN Connection"
  type        = string
  default     = "encc_ipsec_vpn_connection"
}

variable "vpn_public_ip" {
  description = "VPN Public IP"
  type        = string
  default     = "encc_ipsec_vpn_ip"
}

variable "public_ip" {
  description = "Local public IP"
  type        = string
  default     = "LOCAL-PUBLIC-IP"
}

variable "vpn_psk" {
  type        = string
  description = "VPN preshared key"
}