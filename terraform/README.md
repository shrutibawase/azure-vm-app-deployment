# 🛠 Terraform Azure Network, Compute & Foundation Module

This module provisions the enterprise networking and compute foundation on Microsoft Azure required to host secure, containerized workloads.

---

## 📋 Provisioned Resources

- **Azure Resource Group (`azurerm_resource_group`)**: Isolated lifecycle and tag governance boundary.
- **Virtual Network (`azurerm_virtual_network`)**: Dedicated RFC 1918 private address space (`10.0.0.0/16`).
- **Public Subnet (`azurerm_subnet`)**: Subnet segment (`10.0.1.0/24`) housing the public ingress network interface.
- **Network Security Group (`azurerm_network_security_group`)**: State-level firewall with inbound security rules for Port 22 (SSH), Port 80 (HTTP), and Port 443 (HTTPS).
- **Subnet NSG Association (`azurerm_subnet_network_security_group_association`)**: Direct binding ensuring all subnet traffic traverses NSG evaluation.
- **Public IP (`azurerm_public_ip`)**: Standard SKU static IPv4 resource.
- **Network Interface (`azurerm_network_interface`)**: Primary NIC bound to the public subnet and static public IP.
- **TLS Private Key (`tls_private_key`)**: Automated generation of 4096-bit RSA SSH keypair.
- **Azure Linux VM (`azurerm_linux_virtual_machine`)**: Hardened Ubuntu 22.04 LTS instance bootstrapped with Docker, UFW, and Fail2Ban via Cloud-Init.

---

## ⚙️ Input Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `project_name` | `string` | `"cloudapp"` | Name prefix used across all naming conventions. |
| `environment` | `string` | `"prod"` | Target deployment tier (`dev`, `staging`, `prod`). |
| `location` | `string` | `"eastus"` | Azure geographical datacenter region. |
| `vnet_cidr` | `string` | `"10.0.0.0/16"` | CIDR range for Virtual Network. |
| `subnet_cidr` | `string` | `"10.0.1.0/24"` | CIDR range for Public Subnet. |
| `vm_size` | `string` | `"Standard_B2s"` | Virtual Machine instance SKU. |
| `admin_username` | `string` | `"azureuser"` | Linux administrative SSH username. |
| `os_disk_type` | `string` | `"StandardSSD_LRS"` | Storage tier for managed OS disk. |
| `os_disk_size_gb` | `number` | `30` | Size of OS disk in Gigabytes. |
| `os_disk_caching` | `string` | `"ReadWrite"` | Disk caching policy (`None`, `ReadOnly`, `ReadWrite`). |
| `tags` | `map(string)` | *(see `variables.tf`)* | Resource metadata tags. |

---

## 🚀 Execution Commands

### 1. Authenticate to Azure
```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
```

### 2. Initialize Terraform
```bash
cd terraform
terraform init
```

### 3. Validate Configuration
```bash
terraform fmt -check
terraform validate
```

### 4. Plan and Review
```bash
terraform plan -var-file="terraform.tfvars.example" -out=tfplan
```

### 5. Apply
```bash
terraform apply tfplan
```

### 6. Connect to Provisioned VM
Using the automated helper scripts:
```bash
# Bash
./scripts/connect-vm.sh

# PowerShell
.\scripts\connect-vm.ps1
```
Or directly via SSH:
```bash
ssh -i terraform/id_rsa_cloudapp-prod.pem azureuser@<PUBLIC_IP>
```
