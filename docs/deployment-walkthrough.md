# 🚀 End-to-End Production Deployment Walkthrough

A complete, production-grade guide for standing up the entire infrastructure, application container layer, reverse proxy, CI/CD pipeline, and telemetry stack.

---

## 📋 Phase 1: Infrastructure Provisioning (Terraform)

1. **Log in to Microsoft Azure**:
   ```bash
   az login
   az account set --subscription "<YOUR_AZURE_SUBSCRIPTION_ID>"
   ```

2. **Execute Infrastructure Bootstrap**:
   ```bash
   ./scripts/bootstrap.sh
   ```
   *This automatically plans and applies the Terraform network, security groups, public IP, and Linux VM.*

3. **Verify Created Resources**:
   ```bash
   cd terraform
   terraform output
   ```

---

## 🔑 Phase 2: Host Connection & Provisioning Verification

1. **Connect via SSH**:
   ```bash
   ./scripts/connect-vm.sh
   ```

2. **Verify Cloud-Init Bootstrap Completion**:
   ```bash
   cat /var/log/cloud-init-bootstrap-complete.log
   docker --version
   docker compose version
   ```

---

## 🌐 Phase 3: Domain DNS & Let's Encrypt SSL

1. Point your domain's DNS **A Record** to the `public_ip_address` output by Terraform.
2. Initialize production TLS on the VM:
   ```bash
   ./scripts/init-ssl.sh api.yourdomain.com admin@yourdomain.com
   ```

---

## 🔄 Phase 4: GitHub Actions CI/CD Pipeline

Add these repository secrets under **GitHub Repository > Settings > Secrets and variables > Actions**:

- `AZURE_VM_HOST`: Output of `terraform output -raw public_ip_address`
- `AZURE_VM_USER`: `azureuser`
- `AZURE_VM_SSH_KEY`: Full content of `terraform/id_rsa_cloudapp-prod.pem`

Push a commit or trigger the workflow manually to execute your first automated deployment!

---

## 📊 Phase 5: Monitoring & Telemetry

Boot up Prometheus and Grafana on the host:
```bash
cd monitoring
docker compose -f docker-compose.monitoring.yml up -d
```
Access Grafana on your workstation via SSH tunnel:
```bash
ssh -L 3000:localhost:3000 azureuser@<VM_PUBLIC_IP>
```
Visit `http://localhost:3000` (User: `admin` / Password: `AdminSecurePass123!`).

---

## 🛠 Troubleshooting Matrix

| Issue | Root Cause | Solution |
|---|---|---|
| `SSH Connection Refused` | NSG or UFW blocking port 22 | Verify Azure NSG rule `Allow-SSH` on port 22 and host `sudo ufw status`. |
| `502 Bad Gateway` | Python API container not ready | Check container status: `docker compose -f docker-compose.prod.yml logs api`. |
| `Let's Encrypt ACME Fail` | DNS not yet propagated or Port 80 blocked | Ensure Port 80 is open and DNS resolves to Public IP using `dig +short yourdomain.com`. |
| `Database Connection Refused` | DB container initializing | Verify Postgres healthcheck: `docker compose -f docker-compose.prod.yml ps`. |
