# 🛡 Nginx Reverse Proxy Configuration

This directory contains the production Nginx web server configuration, SSL automation snippets, and rate limiting rules.

---

## 🗂 File Structure

- `nginx.conf`: Main Nginx daemon settings (worker processes, logging, connection pools).
- `conf.d/default.conf`: Baseline HTTP reverse proxy configuration forwarding traffic to `api:8000`.
- `conf.d/ssl.conf.template`: Production HTTPS configuration with SSL certificates and HTTP-to-HTTPS redirects.
- `snippets/security-headers.conf`: OWASP security hardening headers (HSTS, CSP, X-Frame-Options).
- `snippets/gzip.conf`: Dynamic response compression parameters.
- `snippets/rate-limit.conf`: Shared-memory leaky-bucket rate limiting zones.

---

## 🧪 Testing Configuration
Validate configuration files using the test script:

```bash
# Bash
./scripts/test-proxy.sh

# PowerShell
.\scripts\test-proxy.ps1
```
