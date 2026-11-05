# 📦 CloudApp Microservice Application

A production-grade, containerized REST API microservice built with **FastAPI**, **SQLAlchemy**, and **PostgreSQL**. Designed for deployment onto Azure Virtual Machines with automated CI/CD and Nginx reverse proxy routing.

---

## 🛠 Tech Stack

- **Framework**: FastAPI (Python 3.11)
- **ASGI Server**: Uvicorn
- **ORM & Data Layer**: SQLAlchemy 2.0 with connection pooling
- **Database**: PostgreSQL 15
- **Validation**: Pydantic v2
- **Testing**: Pytest & HTTPX (with in-memory SQLite isolation)
- **Containerization**: Multi-stage Dockerfile running under unprivileged UID `10001`

---

## 🚀 Local Development

### 1. Python Virtual Environment
```bash
python -m venv venv
# On Windows:
.\venv\Scripts\activate
# On Linux/macOS:
source venv/bin/activate

pip install -r requirements.txt
```

### 2. Run Local Development Server
```bash
uvicorn app.main:app --reload --port 8000
```
API Documentation will be live at:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

---

## 🐳 Running with Docker Compose

To start both the API and PostgreSQL database with health checks and persistent volume storage:

```bash
# Start services in the background
docker compose up -d --build

# View container logs
docker compose logs -f

# Check running status and health probes
docker compose ps

# Tear down services (preserves database volume)
docker compose down

# Tear down including database volumes
docker compose down -v
```

---

## 🧪 Running Automated Tests

```bash
pytest
```
All unit tests leverage an isolated in-memory database fixture to ensure test idempotency and high performance without requiring external services.

---

## 🔌 API Endpoint Catalogue

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/` | Root entrypoint with service metadata |
| `GET` | `/healthz` | Kubernetes/Docker container liveness probe |
| `GET` | `/readyz` | Readiness probe with service uptime metrics |
| `GET` | `/api/v1/info` | Diagnostic runtime information |
| `GET` | `/api/v1/health/db` | Database connectivity & latency check |
| `GET` | `/api/v1/resources` | List paginated cloud resources |
| `POST` | `/api/v1/resources` | Register a new cloud resource |
| `GET` | `/api/v1/resources/{id}` | Retrieve specific resource by ID |
| `PUT` | `/api/v1/resources/{id}` | Update cloud resource fields |
| `DELETE` | `/api/v1/resources/{id}` | Delete cloud resource |
