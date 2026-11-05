import time
from datetime import datetime, timezone
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from app.database import get_db, check_db_health
from app.schemas import (
    CloudResourceCreate,
    CloudResourceUpdate,
    CloudResourceResponse,
    DatabaseHealthResponse,
)
from app import crud

router = APIRouter(prefix="/api/v1", tags=["Cloud Resources"])


@router.get("/health/db", response_model=DatabaseHealthResponse, tags=["Health"])
def health_database():
    """Verify live database connectivity and ping latency."""
    t0 = time.time()
    connected = check_db_health()
    latency_ms = round((time.time() - t0) * 1000, 2)
    return {
        "database": "PostgreSQL",
        "status": "connected" if connected else "unreachable",
        "connected": connected,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


@router.get("/resources", response_model=List[CloudResourceResponse])
def list_resources(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    category: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """List all tracked infrastructure and cloud resources."""
    return crud.get_resources(db, skip=skip, limit=limit, category=category)


@router.post(
    "/resources",
    response_model=CloudResourceResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_resource(
    resource_in: CloudResourceCreate,
    db: Session = Depends(get_db),
):
    """Register a new cloud resource."""
    return crud.create_resource(db, resource_in=resource_in)


@router.get("/resources/{resource_id}", response_model=CloudResourceResponse)
def get_resource(
    resource_id: int,
    db: Session = Depends(get_db),
):
    """Retrieve details for a specific cloud resource by ID."""
    resource = crud.get_resource_by_id(db, resource_id=resource_id)
    if not resource:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Resource with ID {resource_id} not found",
        )
    return resource


@router.put("/resources/{resource_id}", response_model=CloudResourceResponse)
def update_resource(
    resource_id: int,
    resource_in: CloudResourceUpdate,
    db: Session = Depends(get_db),
):
    """Update fields on an existing cloud resource."""
    db_resource = crud.get_resource_by_id(db, resource_id=resource_id)
    if not db_resource:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Resource with ID {resource_id} not found",
        )
    return crud.update_resource(db, db_resource=db_resource, resource_in=resource_in)


@router.delete("/resources/{resource_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_resource(
    resource_id: int,
    db: Session = Depends(get_db),
):
    """Delete a cloud resource by ID."""
    deleted = crud.delete_resource(db, resource_id=resource_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Resource with ID {resource_id} not found",
        )
    return None
