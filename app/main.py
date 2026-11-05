import time
from datetime import datetime, timezone
from contextlib import asynccontextmanager
from fastapi import FastAPI, status
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.database import engine, Base
from app.routes import router as api_router

START_TIME = time.time()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application startup and shutdown events."""
    print(f"🚀 Starting {settings.APP_NAME} v{settings.APP_VERSION} [{settings.ENVIRONMENT}]")
    try:
        # Create database tables if database is reachable
        Base.metadata.create_all(bind=engine)
        print("✅ Database schema initialized successfully.")
    except Exception as exc:
        print(f"⚠️ Notice: Database initialization deferred (will connect on demand): {exc}")
    yield
    print(f"🛑 Shutting down {settings.APP_NAME}")


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Production-grade RESTful API service deployed on Azure Linux VM.",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
    lifespan=lifespan,
)

# Configure Cross-Origin Resource Sharing (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register API Router
app.include_router(api_router)


@app.get("/", tags=["Root"])
def read_root():
    """Root entrypoint returning service metadata."""
    return {
        "service": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "environment": settings.ENVIRONMENT,
        "status": "online",
        "documentation": "/docs",
    }


@app.get("/healthz", status_code=status.HTTP_200_OK, tags=["Health"])
def liveness_probe():
    """Liveness probe endpoint for orchestrators (Docker / K8s)."""
    return {"status": "healthy", "timestamp": datetime.now(timezone.utc).isoformat()}


@app.get("/readyz", status_code=status.HTTP_200_OK, tags=["Health"])
def readiness_probe():
    """Readiness probe indicating application is accepting traffic."""
    uptime_seconds = round(time.time() - START_TIME, 2)
    return {
        "status": "ready",
        "uptime_seconds": uptime_seconds,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


@app.get("/api/v1/info", tags=["System"])
def system_info():
    """System diagnostic and runtime information."""
    return {
        "app_name": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "environment": settings.ENVIRONMENT,
        "debug_mode": settings.DEBUG,
        "server_time": datetime.now(timezone.utc).isoformat(),
    }
