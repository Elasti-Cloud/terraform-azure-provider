provider "azurerm" {
  version = ">= 2.0.0"
  features {}
}

# Create RG
resource "azurerm_resource_group" "rg" {
  name     = var.rg["name"]
  location = var.rg["location"]
}

# Create VNET
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet["name"]
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.rg["location"]
  address_space       = var.vnet["cidr"]
  dns_servers         = []
  tags                = var.tags
}

# Create subnets
resource "azurerm_subnet" "subnet" {
  for_each             = var.subnet
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}

# Create NSG for subnets
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.nsg
  name                = each.key
  location            = var.rg["location"]
  resource_group_name = azurerm_resource_group.rg.name

  dynamic "security_rule" {
    for_each = each.value
    content {
      name                       = security_rule.value["name"]
      priority                   = security_rule.value["priority"]
      direction                  = security_rule.value["direction"]
      access                     = security_rule.value["access"]
      protocol                   = security_rule.value["protocol"]
      source_port_range          = security_rule.value["source_port_range"]
      destination_port_range     = security_rule.value["destination_port_range"]
      source_address_prefix      = security_rule.value["source_address_prefix"]
      destination_address_prefix = security_rule.value["destination_address_prefix"]
    }
  }
  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "nsgforsubnet" {
  for_each                  = azurerm_subnet.subnet
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg[each.value.name].id
}