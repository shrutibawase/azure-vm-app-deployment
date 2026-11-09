# 📝 Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-11-09

### 🚀 Added
- **Infrastructure as Code (Terraform)**:
  - Azure Resource Group, Virtual Network (`10.0.0.0/16`), and Public Subnet (`10.0.1.0/24`).
  - Network Security Group (NSG) restricting ingress strictly to Ports 22, 80, and 443.
  - Standard SKU static Public IP and Network Interface (NIC).
  - Ubuntu 22.04 LTS Linux Virtual Machine (`Standard_B2s`).
  - Automated 4096-bit RSA SSH key generation and local `.pem` export (`0600` permissions).
  - Cloud-Init bootstrap script for automated Docker Engine, UFW, and Fail2Ban installation.
- **Application Microservice (FastAPI + PostgreSQL)**:
  - Containerized Python 3.11 web service with non-root user UID `10001`.
  - SQLAlchemy 2.0 async engine and connection pooling.
  - RESTful CRUD endpoints (`/api/v1/resources`) with pagination and filtering.
  - Container liveness (`/healthz`) and readiness (`/readyz`) probes.
  - Automated Pytest test suite with in-memory SQLite fixtures.
- **Reverse Proxy & Ingress (Nginx + Let's Encrypt)**:
  - Reverse proxy upstream pooling and connection reuse.
  - OWASP recommended security headers (HSTS, CSP, X-Frame-Options).
  - Leaky-bucket rate limiting (10 req/s, burst buffer 20) with custom JSON 429 response.
  - Certbot ACME HTTP-01 automated SSL issuance and renewal background container.
- **Continuous Integration & Delivery (GitHub Actions)**:
  - Automated code linting (`black`, `flake8`, `terraform validate`, `shellcheck`).
  - Automated test workflow with ephemeral PostgreSQL 15 service container.
  - Multi-arch Docker image packaging and publishing to GitHub Container Registry (`ghcr.io`).
  - Remote SSH rolling zero-downtime deployment with automated rollback on healthcheck failure.
  - Post-deployment smoke test suite.
- **Observability & Telemetry**:
  - Prometheus Node Exporter `v1.7.0` for host hardware telemetry.
  - Prometheus `v2.51.0` with predefined infrastructure and application alerting rules.
  - Pre-configured Grafana `v10.4.0` dashboard with real-time gauges and time-series panels.
- **Operations & Disaster Recovery**:
  - Automated one-click bootstrap (`scripts/bootstrap.sh`) and teardown (`scripts/destroy.sh`).
  - PostgreSQL automated daily backup with Gzip compression and 7-day retention (`scripts/backup-db.sh`).
  - Disaster recovery database restore script with SHA256 integrity verification (`scripts/restore-db.sh`).
  - API benchmark and latency stress testing script (`scripts/benchmark.sh`).
  - Production incident response and emergency runbook (`docs/RUNBOOK.md`).
