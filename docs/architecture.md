# 🏗 Architecture & Infrastructure Specification

## 1. Network Topology

The network layer implements a dedicated Virtual Network (VNet) in Azure designed for single-tier and multi-tier public workload hosting:

- **Address Space**: `10.0.0.0/16`
- **Subnet Space**: `10.0.1.0/24` (Public Subnet)
- **Public IP Allocation**: Static IPv4 with Standard SKU to support production SSL bindings and DNS resolution.
- **Traffic Ingress Routing**:
  - `Internet -> Public IP -> NIC -> Network Security Group (NSG) -> VM OS Network -> UFW -> Reverse Proxy (Nginx) -> App Services`.

## 2. Security & Compliance Posture

### Network Security Group (NSG) Rules
| Priority | Direction | Access | Protocol | Port(s) | Source | Purpose |
|---|---|---|---|---|---|---|
| 100 | Inbound | Allow | TCP | 22 | Admin IP / Any | SSH remote administration |
| 110 | Inbound | Allow | TCP | 80 | Internet | HTTP (redirects to HTTPS) |
| 120 | Inbound | Allow | TCP | 443 | Internet | HTTPS secure application traffic |
| 4096 | Inbound | Deny | Any | Any | Any | Default Azure Deny All |

### Compute Hardening
- Base OS: **Ubuntu 22.04 LTS**.
- Root Login: Disabled.
- Password Authentication: Disabled (`ssh_pwauth: false`).
- SSH Key Exchange: Restricted to Modern Ed25519 or RSA 4096-bit keys.

## 3. Application & Container Architecture
- The application runtime is decoupled from the host operating system using Docker Engine.
- The web application and relational database communicate inside an isolated Docker bridge network (`backend-net`).
- Host port exposure is limited strictly to ports `80` and `443` through the Nginx reverse proxy container.
