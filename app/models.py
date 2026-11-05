import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Text, DateTime
from app.database import Base


class CloudResource(Base):
    """SQLAlchemy model representing a tracked cloud or infrastructure resource."""

    __tablename__ = "cloud_resources"

    id = Column(Integer, primary_key=True, index=True)
    resource_uuid = Column(String(36), unique=True, index=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(100), nullable=False, index=True)
    category = Column(String(50), nullable=False, default="compute")
    description = Column(Text, nullable=True)
    status = Column(String(30), nullable=False, default="active")
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(
        DateTime,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )
