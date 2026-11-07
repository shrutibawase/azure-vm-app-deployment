# 📊 Telemetry, Metrics & Observability Stack

This directory contains the Prometheus, Node Exporter, and Grafana configuration for host-level and container-level monitoring.

---

## 🗂 Architecture & Components

- **Node Exporter (`prom/node-exporter:v1.7.0`)**: Collects low-level kernel and hardware metrics (CPU, memory, disk I/O, network traffic).
- **Prometheus (`prom/prometheus:v2.51.0`)**: Time-series database scraping metrics at 15-second intervals with built-in alerting rules (`alert_rules.yml`).
- **Grafana (`grafana/grafana:10.4.0`)**: Visualization engine with pre-provisioned datasource and dashboard (`system-overview.json`).
- **Fail2Ban (`monitoring/fail2ban/`)**: Host-level intrusion defense tracking unauthorized SSH attempts.

---

## 🚀 Running the Monitoring Subsystem

```bash
docker compose -f docker-compose.monitoring.yml up -d
```
All ports are bound strictly to `127.0.0.1` on the host to adhere to zero-trust security best practices. Access via SSH port forwarding:
```bash
ssh -L 3000:localhost:3000 -L 9090:localhost:9090 azureuser@<VM_PUBLIC_IP>
```
