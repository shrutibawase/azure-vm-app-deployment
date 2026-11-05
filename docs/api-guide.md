# 📖 API Specification & Schema Reference

This reference covers request/response payloads, authentication boundaries, and error codes for the CloudApp API microservice.

---

## 📌 Standard Response Envelopes

### Successful Resource Creation (`POST /api/v1/resources`)
**Status**: `201 Created`
```json
{
  "id": 1,
  "resource_uuid": "c39a88e4-84c6-4318-a621-e37452d1ea2e",
  "name": "primary-azure-vm",
  "category": "compute",
  "description": "Ubuntu 22.04 LTS host instance",
  "status": "active",
  "created_at": "2026-11-05T12:00:00Z",
  "updated_at": "2026-11-05T12:00:00Z"
}
```

### Resource Not Found Error
**Status**: `404 Not Found`
```json
{
  "detail": "Resource with ID 999 not found"
}
```

### Validation Error
**Status**: `422 Unprocessable Entity`
```json
{
  "detail": [
    {
      "loc": ["body", "name"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

---

## 🔍 Database Health Check (`GET /api/v1/health/db`)
**Status**: `200 OK`
```json
{
  "database": "PostgreSQL",
  "status": "connected",
  "connected": true,
  "timestamp": "2026-11-05T12:00:00Z"
}
```
