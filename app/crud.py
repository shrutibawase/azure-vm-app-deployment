from typing import List, Optional
from sqlalchemy.orm import Session
from app.models import CloudResource
from app.schemas import CloudResourceCreate, CloudResourceUpdate


def get_resources(
    db: Session, skip: int = 0, limit: int = 50, category: Optional[str] = None
) -> List[CloudResource]:
    """Retrieve paginated cloud resources with optional category filter."""
    query = db.query(CloudResource)
    if category:
        query = query.filter(CloudResource.category == category)
    return query.offset(skip).limit(limit).all()


def get_resource_by_id(db: Session, resource_id: int) -> Optional[CloudResource]:
    """Fetch single cloud resource by integer primary key."""
    return db.query(CloudResource).filter(CloudResource.id == resource_id).first()


def get_resource_by_uuid(db: Session, resource_uuid: str) -> Optional[CloudResource]:
    """Fetch single cloud resource by public UUID."""
    return db.query(CloudResource).filter(CloudResource.resource_uuid == resource_uuid).first()


def create_resource(db: Session, resource_in: CloudResourceCreate) -> CloudResource:
    """Create and persist a new cloud resource."""
    db_resource = CloudResource(
        name=resource_in.name,
        category=resource_in.category,
        description=resource_in.description,
        status=resource_in.status,
    )
    db.add(db_resource)
    db.commit()
    db.refresh(db_resource)
    return db_resource


def update_resource(
    db: Session, db_resource: CloudResource, resource_in: CloudResourceUpdate
) -> CloudResource:
    """Update fields on an existing cloud resource."""
    update_data = resource_in.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_resource, field, value)
    db.commit()
    db.refresh(db_resource)
    return db_resource


def delete_resource(db: Session, resource_id: int) -> bool:
    """Remove a cloud resource record by ID."""
    db_resource = get_resource_by_id(db, resource_id)
    if not db_resource:
        return False
    db.delete(db_resource)
    db.commit()
    return True
