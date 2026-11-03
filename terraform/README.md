# 🛠 Terraform Azure Network & Foundation Module

This module provisions the baseline networking foundation on Microsoft Azure required to host a secure Virtual Machine.

---

## 📋 Provisioned Resources

- **Azure Resource Group (`azurerm_resource_group`)**: Isolated lifecycle and tag governance boundary.
- **Virtual Network (`azurerm_virtual_network`)**: Dedicated RFC 1918 private address space (`10.0.0.0/16`).
- **Public Subnet (`azurerm_subnet`)**: Subnet segment (`10.0.1.0/24`) housing the public ingress network interface.
- **Network Security Group (`azurerm_network_security_group`)**: State-level firewall with inbound security rules for Port 22 (SSH), Port 80 (HTTP), and Port 443 (HTTPS).
- **Subnet NSG Association (`azurerm_subnet_network_security_group_association`)**: Direct binding ensuring all subnet traffic traverses NSG evaluation.
- **Public IP (`azurerm_public_ip`)**: Standard SKU static IPv4 resource.
- **Network Interface (`azurerm_network_interface`)**: Primary NIC bound to the public subnet and static public IP.

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
