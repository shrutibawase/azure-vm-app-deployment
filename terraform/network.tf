# -----------------------------------------------------------------------------
# Public IP Address (Static, Standard SKU)
# -----------------------------------------------------------------------------
resource "azurerm_public_ip" "main" {
  name                = "pip-${local.naming_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# -----------------------------------------------------------------------------
# Network Interface (NIC)
# -----------------------------------------------------------------------------
resource "azurerm_network_interface" "main" {
  name                = "nic-${local.naming_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "ipconfig-primary"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}
