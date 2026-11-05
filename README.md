# 🌐 Enterprise Azure VM Infrastructure & Containerized Application Deployment

[![Terraform](https://img.shields.io/badge/Terraform-1.5%2B-844FBA?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Engine-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Nginx](https://img.shields.io/badge/Nginx-Reverse_Proxy-009639?logo=nginx&logoColor=white)](https://nginx.org/)
[![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

An end-to-end, production-grade infrastructure and continuous delivery ecosystem deployed on **Microsoft Azure**. Provisions secure Virtual Network topology, hardened Linux VM compute, containerized web microservices, automated TLS/SSL certificate issuance, and GitOps CI/CD pipelines.

---

## 🏛 System Architecture

```mermaid
graph TD
    User["🌍 End User / HTTPS Traffic"] -->|Port 443 / SSL| PIP["Azure Static Public IP"]
    PIP --> NSG["Network Security Group (NSG)"]
    
    subgraph Azure_VNet ["Azure Virtual Network (10.0.0.0/16)"]
        subgraph Public_Subnet ["Public Subnet (10.0.1.0/24)"]
            NIC["Virtual Network Interface (NIC)"]
            
            subgraph Azure_VM ["Hardened Ubuntu 22.04 LTS VM"]
                UFW["UFW Firewall (Port 80/443/22)"]
                NGINX["Nginx Reverse Proxy & TLS Ingress"]
                DOCKER["Docker Engine (Container Runtime)"]
                
                subgraph Container_Network ["Bridge Network"]
                    APP["Web App Service (Container)"]
                    DB["PostgreSQL Database (Persistent Volume)"]
                    PROM["Prometheus Node Exporter (Metrics)"]
                end
            end
        end
    end

    NSG --> NIC
    NIC --> UFW
    UFW --> NGINX
    NGINX -->|Reverse Proxy| APP
    APP -->|TCP 5432| DB
    NGINX -->|Certbot ACME| LetsEncrypt["Let's Encrypt Authority"]
    DOCKER --> APP
    DOCKER --> DB
    DOCKER --> PROM
```

---

## 🗂 Directory Structure

```plaintext
azure-vm-app-deployment/
├── .github/
│   └── workflows/              # GitHub Actions CI/CD pipelines
├── app/                        # Containerized application source & tests
│   ├── Dockerfile              # Multi-stage container build
│   └── docker-compose.yml      # Local and testing container orchestration
├── docs/                       # Architectural specifications and runbooks
│   └── architecture.md         # Detailed infrastructure deep dive
├── nginx/                      # Nginx reverse proxy configuration & SSL certbot
├── scripts/                    # Automation, backup, and deployment scripts
├── terraform/                  # Infrastructure as Code (IaC) modules
│   ├── main.tf                 # Core infrastructure composition
│   ├── variables.tf            # Configurable parameters & validation
│   ├── outputs.tf              # Connection strings and IP addresses
│   ├── providers.tf            # AzureRM provider configuration
│   └── terraform.tfvars.example# Template parameter inputs
├── .editorconfig               # Code style & whitespace conventions
├── .gitignore                  # Git ignore rules for state and credentials
├── .pre-commit-config.yaml     # Pre-commit formatting & security linters
└── README.md                   # Project documentation
```

---

## 🛡 Key Features & Best Practices

1. **Infrastructure as Code (IaC)**: Modular Terraform definitions with explicit dependency graphs and remote-state readiness.
2. **Zero-Trust Network Security**:
   - NSG rules restrict incoming connections strictly to HTTP (`80`), HTTPS (`443`), and SSH (`22`).
   - SSH password authentication is disabled; strict Ed25519 public key authentication enforced.
3. **Automated Provisioning**: Cloud-init bootstrap scripts dynamically install Docker, configure user privileges, and initiate system security updates.
4. **Resilient Container Runtime**: Multi-stage lightweight containers managed via Docker Compose with health checks and volume persistence.
5. **TLS/SSL Encryption**: Automated certificate issuing and renewal via Certbot / Let's Encrypt.
6. **Automated CI/CD**: GitHub Actions pipeline covering linting, test suite execution, container image packaging, and zero-downtime SSH deployment.
