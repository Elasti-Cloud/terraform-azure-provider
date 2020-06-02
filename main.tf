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
  count                = length(var.subnet["names"])
  name                 = var.subnet["names"][count.index]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet["cidrs"][count.index]]
}
/*
data "azurerm_subnet" "import" {
  for_each             = var.nsg_ids
  name                 = each.key
  resource_group_name  = data.azurerm_resource_group.vnet.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  depends_on = ["azurerm_subnet.subnet"]
}

resource "azurerm_subnet_network_security_group_association" "vnet" {
  for_each                  = var.nsg_ids
  subnet_id                 = data.azurerm_subnet.import[each.key].id
  network_security_group_id = each.value

  depends_on = ["data.azurerm_subnet.import"]
}
*/