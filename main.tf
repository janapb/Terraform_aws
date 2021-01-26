locals {
  lz = jsondecode(file("lz_input.json"))
}

# Create a resource group
resource "azurerm_resource_group" "lz_rg" {
  count = length(local.lz.ResourceGroup)
  #name     = lookup(element(var.rg, count.index), "name")
  name = lookup(element(local.lz.ResourceGroup,count.index),"Name")
  location = lookup(element(local.lz.ResourceGroup,count.index),"Location")
  tags     = merge(local.lz.Tags[count.index],{
    Resourcetype="ResourceGroup"
  })
}

# Creates Virtual Networks 
resource "azurerm_virtual_network" "lz_vnet" {
  count = length(local.lz.Vnet)
  name                = lookup(element(local.lz.Vnet, count.index), "Vnet_Name")
  location            = lookup(element(local.lz.Vnet, count.index), "Region")
  resource_group_name = lookup(element(local.lz.Vnet, count.index), "Resourcegroup_Name")
  address_space       = [lookup(element(local.lz.Vnet, count.index), "Addres_Space")]
  tags     = merge(local.lz.Tags[0],{
    Resourcetype="VirtualNetwork"
  })
  depends_on = [azurerm_resource_group.lz_rg]
  }

      
# Creates Subnets 
resource "azurerm_subnet" "lz_subnet" {
  count = length(local.lz.Subnet)
  name                 = lookup(element(local.lz.Subnet, count.index), "Subnet_Name")
  resource_group_name  = lookup(element(local.lz.Subnet, count.index), "Resourcegroup_Name")
  virtual_network_name = lookup(element(local.lz.Subnet, count.index), "Vnet_Name")
  address_prefix       = lookup(element(local.lz.Subnet, count.index), "Address_Space")
  depends_on = [azurerm_virtual_network.lz_vnet]
}

# Creates Network Security Group  
resource "azurerm_network_security_group" "lz_nsg" {
  count               = length(local.lz.Subnet)
  name                = lookup(element(local.lz.Subnet, count.index), "NSG")
  location            = lookup(element(local.lz.Subnet, count.index), "Region")
  resource_group_name = lookup(element(local.lz.Subnet, count.index), "Resourcegroup_Name")
  tags     = merge(local.lz.Tags[0],{
    Resourcetype="NSG"
  })
  depends_on = [azurerm_resource_group.lz_rg]
}

resource "azurerm_subnet_network_security_group_association" "lz_nsg_association" {
  count                     = length(local.lz.Subnet)
  subnet_id                 = azurerm_subnet.lz_subnet[count.index].id
  network_security_group_id = azurerm_network_security_group.lz_nsg[count.index].id
  depends_on = [azurerm_network_security_group.lz_nsg]
}
/*

data "azurerm_virtual_network" "example" {
  count = length(local.lz.Peering)
  name                = lookup(element(local.lz.Peering, count.index), "remote_virtual_network")
  resource_group_name = lookup(element(local.lz.Peering, count.index), "resource_group_name")
  depends_on = [azurerm_virtual_network.lz_vnet]
  }


# Peering of Hub VNET to Spoke VNET
resource "azurerm_virtual_network_peering" "Hub-Spoke_Peer" {
  count                        = length(local.lz.Peering)
  name                         = lookup(element(local.lz.Peering,count.index),"name")
  resource_group_name          = lookup(element(local.lz.Peering, count.index), "resource_group_name")
  virtual_network_name         = lookup(element(local.lz.Peering, count.index), "virtual_network_name")
  remote_virtual_network_id    = data.azurerm_virtual_network.example[count.index].id
  allow_virtual_network_access = lookup(element(local.lz.Peering, count.index), "allow_virtual_network_access")
  allow_forwarded_traffic      = lookup(element(local.lz.Peering, count.index), "allow_forwarded_traffic")
  depends_on = [azurerm_virtual_network.lz_vnet]
}


locals {
  security_group_rules = csvdecode(file("rules.csv"))
}

resource "azurerm_network_security_rule" "lz-nsg" {
  count                       = length(local.security_group_rules)
  name                        = "${local.security_group_rules[count.index].name}-${count.index}"
  priority                    = local.security_group_rules[count.index].priority
  direction                   = local.security_group_rules[count.index].direction
  access                      = local.security_group_rules[count.index].access
  protocol                    = local.security_group_rules[count.index].protocol
  source_port_range           = local.security_group_rules[count.index].source_port
  destination_port_range      = local.security_group_rules[count.index].destination_port
  source_address_prefix       = local.security_group_rules[count.index].source_address_prefix
  destination_address_prefix  = local.security_group_rules[count.index].destination_address_prefix
  resource_group_name         = local.security_group_rules[count.index].resource_group_name
  network_security_group_name = local.security_group_rules[count.index].network_security_group_name
  depends_on = [azurerm_network_security_group.lz_nsg]
}

*/
