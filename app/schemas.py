from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict


class CloudResourceBase(BaseModel):
    """Base schema for cloud resource attributes."""

    name: str = Field(..., min_length=2, max_length=100, examples=["production-api-vm"])
    category: str = Field(default="compute", examples=["compute", "storage", "database", "network"])
    description: Optional[str] = Field(default=None, examples=["Primary backend VM instance"])
    status: str = Field(default="active", examples=["active", "stopped", "provisioning"])


class CloudResourceCreate(CloudResourceBase):
    """Schema for creating a new cloud resource."""

    pass


class CloudResourceUpdate(BaseModel):
    """Schema for updating an existing resource."""

    name: Optional[str] = Field(None, min_length=2, max_length=100)
    category: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None


class CloudResourceResponse(CloudResourceBase):
    """Response schema returning serialized cloud resource."""

    id: int
    resource_uuid: str
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class DatabaseHealthResponse(BaseModel):
    """Response schema for database health verification."""

    database: str
    status: str
    connected: bool
    timestamp: str
