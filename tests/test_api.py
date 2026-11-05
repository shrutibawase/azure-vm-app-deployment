import pytest
from fastapi import status


def test_root_endpoint(client):
    """Verify root endpoint responds with metadata."""
    response = client.get("/")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["status"] == "online"
    assert "version" in data
    assert "service" in data


def test_liveness_probe(client):
    """Verify liveness probe returns healthy status."""
    response = client.get("/healthz")
    assert response.status_code == status.HTTP_200_OK
    assert response.json()["status"] == "healthy"


def test_readiness_probe(client):
    """Verify readiness probe returns uptime information."""
    response = client.get("/readyz")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["status"] == "ready"
    assert "uptime_seconds" in data


def test_create_and_get_resource(client):
    """Verify resource creation and retrieval workflow."""
    payload = {
        "name": "test-vnet",
        "category": "network",
        "description": "Production network testing resource",
        "status": "active",
    }
    # Create Resource
    create_res = client.post("/api/v1/resources", json=payload)
    assert create_res.status_code == status.HTTP_201_CREATED
    created = create_res.json()
    assert created["name"] == payload["name"]
    assert "resource_uuid" in created
    resource_id = created["id"]

    # Retrieve by ID
    get_res = client.get(f"/api/v1/resources/{resource_id}")
    assert get_res.status_code == status.HTTP_200_OK
    assert get_res.json()["resource_uuid"] == created["resource_uuid"]


def test_list_resources(client):
    """Verify listing resources with pagination and category filter."""
    # Seed resources
    client.post("/api/v1/resources", json={"name": "vm-01", "category": "compute"})
    client.post("/api/v1/resources", json={"name": "st-01", "category": "storage"})

    res = client.get("/api/v1/resources?category=compute")
    assert res.status_code == status.HTTP_200_OK
    items = res.json()
    assert len(items) >= 1
    for item in items:
        assert item["category"] == "compute"


def test_update_resource(client):
    """Verify partial updates to an existing resource."""
    create_res = client.post("/api/v1/resources", json={"name": "app-vm", "category": "compute"})
    resource_id = create_res.json()["id"]

    update_payload = {"name": "app-vm-renamed", "status": "stopped"}
    update_res = client.put(f"/api/v1/resources/{resource_id}", json=update_payload)
    assert update_res.status_code == status.HTTP_200_OK
    updated = update_res.json()
    assert updated["name"] == "app-vm-renamed"
    assert updated["status"] == "stopped"


def test_delete_resource(client):
    """Verify deleting a resource and handling non-existent ID."""
    create_res = client.post("/api/v1/resources", json={"name": "temp-res", "category": "test"})
    resource_id = create_res.json()["id"]

    delete_res = client.delete(f"/api/v1/resources/{resource_id}")
    assert delete_res.status_code == status.HTTP_204_NO_CONTENT

    # Second fetch should return 404
    fetch_res = client.get(f"/api/v1/resources/{resource_id}")
    assert fetch_res.status_code == status.HTTP_404_NOT_FOUND


def test_resource_not_found(client):
    """Verify 404 response for invalid resource ID."""
    response = client.get("/api/v1/resources/999999")
    assert response.status_code == status.HTTP_404_NOT_FOUND
