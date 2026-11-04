# 🛡 Azure Linux VM Hardening & Operations Guide

This runbook outlines the zero-trust security postures and operational procedures implemented for the host Azure Virtual Machine.

---

## 🔒 Security Hardening Controls

### 1. Zero Password Authentication
- The VM is provisioned with `disable_password_authentication = true`.
- Authentication is strictly restricted to cryptographic 4096-bit RSA or Ed25519 keypairs.
- Direct root login is completely forbidden.

### 2. Automated Cloud-Init Provisioning
During first-boot initialization, `cloud-init` runs privileged system tasks defined in `terraform/scripts/cloud-init.yaml`:
- Upgrades all base OS repositories and security patches (`apt-get update && apt-get upgrade`).
- Installs the official Docker Engine, Buildx, and Docker Compose plugin from Docker's official signed APT repository.
- Grants non-root execution privileges by adding `azureuser` to the `docker` system group.

### 3. Layered Defense (UFW + Fail2Ban)
- **Host Firewall (UFW)**:
  - Default incoming policy: **DENY ALL**.
  - Default outgoing policy: **ALLOW ALL**.
  - Explicit ingress allowances: Port `22` (SSH), Port `80` (HTTP), Port `443` (HTTPS).
- **Intrusion Prevention (Fail2Ban)**:
  - Monitors `/var/log/auth.log` for repeated authentication failures.
  - Automatically issues temporary IP bans (1 hour) after 5 failed login attempts.

### 4. Storage at Rest Encryption
- Managed OS disk is encrypted using Azure Storage Service Encryption (SSE) with Platform-Managed Keys (PMK).

---

## 🔍 Verification & Troubleshooting

### Inspecting Cloud-Init Bootstrap Logs
To verify that all dependencies and Docker were installed properly during boot:

```bash
# View complete provisioning stdout/stderr
sudo cat /var/log/cloud-init-output.log

# Check completion milestone marker
cat /var/log/cloud-init-bootstrap-complete.log
```

### Verifying Docker Engine
```bash
docker --version
docker compose version
docker info
```

### Checking Active Firewall & Intrusion Prevention
```bash
# UFW Status
sudo ufw status verbose

# Fail2Ban SSH Jail Status
sudo fail2ban-client status sshd
```

### Testing Connection Helper
From your workstation root directory:
```bash
# Linux / macOS
./scripts/connect-vm.sh

# Windows PowerShell
.\scripts\connect-vm.ps1
```
