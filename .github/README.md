# ⚙️ GitHub Actions CI/CD Ecosystem

This directory contains the automated workflows orchestrating code verification, testing, container publishing, and production deployment onto Microsoft Azure.

---

## 📂 Active Workflows

| Workflow | File | Triggers | Responsibility |
|---|---|---|---|
| **Lint & Quality** | `workflows/lint.yml` | Push, PR, Manual | Checks formatting (Black), Python lint (Flake8), Terraform syntax, ShellCheck |
| **Test Matrix** | `workflows/test.yml` | Push, PR, Manual | Runs unit and integration test suite with PostgreSQL service container |
| **Container Build** | `workflows/build-publish.yml` | Push to `main`, Tags | Multi-stage Docker build, layer caching, and publishing to `ghcr.io` |
| **Deployment** | `workflows/cd.yml` | After build, Manual | SSH connection to Azure VM, rolling container update, smoke testing |

---

## 🚀 Triggering Manual Deployment
1. Navigate to **Actions** in your GitHub repository.
2. Select **Continuous Deployment (CD) to Azure VM**.
3. Click **Run workflow** > Select branch `main` > Click **Run workflow**.
