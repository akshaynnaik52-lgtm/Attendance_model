# Phase 8 Checklist

- [x] Scaffold FastAPI backend structure
- [x] Create SQLAlchemy models (`Student`, `FaceEmbedding`, `AttendanceSession`, `AttendanceRecord`)
- [x] Use `pgvector` for FaceEmbedding column
- [x] Create Alembic migration setup (`alembic.ini`, `env.py`, `001_initial.py`)
- [x] Implement HTTP client for ML Service
- [x] Create endpoints for student creation and enrollment
- [x] Implement `/api/recognize` utilizing pgvector cosine distance sorting
- [x] Add `/api/health`, `/api/ml/health`
- [x] Mask raw embeddings from all frontend JSON outputs
- [x] Enforce model version tracking on embeddings
- [x] Provide configurable threshold via environment variable
- [x] Write unittests overriding DB dependency and mocking HTTPX client
- [x] Add Phase 8 documentation and checklists
