# -----------------------------------------------------------------------------
# SSH Key Management & TLS Key Generation
# -----------------------------------------------------------------------------
resource "tls_private_key" "vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save generated private key locally with restricted permissions
resource "local_file" "private_key" {
  content         = tls_private_key.vm_ssh.private_key_pem
  filename        = "${path.module}/id_rsa_${local.naming_prefix}.pem"
  file_permission = "0600"
}

# Optional: Store the public key in Azure as a managed resource
resource "azurerm_ssh_public_key" "main" {
  name                = "sshkey-${local.naming_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  public_key          = tls_private_key.vm_ssh.public_key_openssh
  tags                = local.common_tags
}
