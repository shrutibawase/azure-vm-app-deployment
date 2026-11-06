# 🌐 Nginx Reverse Proxy & TLS Ingress Guide

This guide documents the edge routing, SSL/TLS automation, and defense-in-depth traffic hardening implemented for the Azure VM deployment.

---

## 🏛 Edge Traffic Architecture

```plaintext
                                      [ Internet Clients ]
                                                │
                                       (HTTPS Port 443 / 80)
                                                ▼
                             [ Azure Network Security Group (NSG) ]
                                                │
                                                ▼
                                    [ Host UFW Firewall ]
                                                │
                                                ▼
                           ┌────────────────────────────────────────┐
                           │   Nginx Reverse Proxy (Container)     │
                           │  - TLS Termination (Let's Encrypt)    │
                           │  - OWASP Security Headers & HSTS       │
                           │  - Leaky-Bucket Rate Limiting (10r/s)  │
                           │  - Gzip Dynamic Compression            │
                           └──────────────────┬─────────────────────┘
                                              │ (HTTP Keepalive Pool)
                                              ▼
                             [ CloudApp FastAPI Backend (Port 8000) ]
```

---

## 🛡 Security Hardening Modules

### 1. OWASP Security Headers (`nginx/snippets/security-headers.conf`)
- `X-Frame-Options: DENY`: Mitigates clickjacking attacks.
- `X-Content-Type-Options: nosniff`: Prevents MIME-sniffing exploits.
- `Referrer-Policy: strict-origin-when-cross-origin`: Restricts leak of query strings and referrers across domains.
- `Content-Security-Policy`: Disallows untrusted cross-origin script execution.
- `Strict-Transport-Security (HSTS)`: Enforces HTTPS communication for modern browsers for 2 years (`max-age=63072000`).

### 2. Rate Limiting & DDoS Shield (`nginx/snippets/rate-limit.conf`)
- Leverages Nginx `binary_remote_addr` shared memory zones.
- API traffic is capped at **10 requests/second** with a burst buffer of **20 requests**.
- When clients exceed the rate limit, Nginx responds instantly with an `HTTP 429 Too Many Requests` JSON body without burdening the Python application server.

### 3. Automated TLS / Let's Encrypt Certbot
- **ACME Challenge**: Webroot challenge directory mapped to `/.well-known/acme-challenge/`.
- **Certbot Renewal**: Dedicated `certbot` container checks every 12 hours for certificate expiration.
- **Auto Reload**: Nginx reloads in-memory certificates without dropping active connections (`nginx -s reload`).

---

## 🚀 SSL Initialization Walkthrough

1. Map your domain's DNS **A Record** to the Azure VM Static Public IP.
2. Run the automated initialization script on the host VM:
   ```bash
   ./scripts/init-ssl.sh app.example.com admin@example.com
   ```
3. Test your SSL grade on Qualys SSL Labs or via curl:
   ```bash
   curl -I https://app.example.com/healthz
   ```
