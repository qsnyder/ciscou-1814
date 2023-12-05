# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

resource "azurerm_virtual_network" "encc_ipsec_vpn_vnet" {
  name                = var.base_vnet
  location            = var.location
  resource_group_name = var.resource_group
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "default_subnet" {
  name                 = "default"
  resource_group_name  = var.resource_group
  virtual_network_name = var.base_vnet
  address_prefixes     = ["10.0.0.0/24"]
  depends_on = [
    azurerm_virtual_network.encc_ipsec_vpn_vnet
  ]
}

resource "azurerm_subnet" "vpn_transport_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group
  virtual_network_name = var.base_vnet
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [
    azurerm_virtual_network.encc_ipsec_vpn_vnet
  ]
}

resource "azurerm_local_network_gateway" "encc_vpn_peer_gateway" {
  name                = var.peer_vpn_gateway
  location            = var.location
  resource_group_name = var.resource_group
  gateway_address     = var.public_ip
  address_space       = var.peer_subnet_address_spaces
  bgp_settings {
    asn                 = 65000
    bgp_peering_address = "192.168.150.1"
  }
}

resource "azurerm_public_ip" "encc_ipsec_vpn_ip" {
  name                = var.vpn_public_ip
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "encc_vpn_gateway" {
  name                = var.local_vpn_gateway
  location            = var.location
  resource_group_name = var.resource_group
  type                = "Vpn"
  vpn_type            = "RouteBased"
  enable_bgp          = true
  sku                 = "VpnGw2"
  bgp_settings {
    asn = 65515
  }
  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.encc_ipsec_vpn_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vpn_transport_subnet.id
  }
}

resource "azurerm_virtual_network_gateway_connection" "encc_ipsec_vpn_connection" {
  name                       = var.vpn_connection
  location                   = var.location
  resource_group_name        = var.resource_group
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.encc_vpn_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.encc_vpn_peer_gateway.id
  shared_key                 = var.vpn_psk
  enable_bgp                 = true
  ipsec_policy {
    dh_group         = "DHGroup24"
    ike_encryption   = "GCMAES256"
    ike_integrity    = "SHA384"
    ipsec_encryption = "GCMAES256"
    ipsec_integrity  = "GCMAES256"
    pfs_group        = "PFS24"
  }
}

output "azure_bgp_info" {
  value = {
    "ASN": azurerm_virtual_network_gateway.encc_vpn_gateway.bgp_settings[0].asn
    "Azure BGP Peer IP": azurerm_virtual_network_gateway.encc_vpn_gateway.bgp_settings[0].peering_addresses[0].default_addresses[0]
    "Tunnel Public IP": azurerm_virtual_network_gateway.encc_vpn_gateway.bgp_settings[0].peering_addresses[0].tunnel_ip_addresses[0]
    }
}