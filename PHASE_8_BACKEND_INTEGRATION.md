# Phase 8 Backend Integration

## Objective
Build the FastAPI backend acting as the core application API layer. The backend owns the students, face enrollment records, database connections (`PostgreSQL` + `pgvector`), and communicates with the `ML Service`.

## Architecture
- **Framework**: FastAPI
- **Database**: PostgreSQL (via SQLAlchemy)
- **Vector Search**: `pgvector`
- **Migrations**: Alembic
- **ML Integration**: `MLServiceClient` (HTTPX)

## Database Models
- `Student`: Basic student details.
- `FaceEmbedding`: Contains the raw 512D `pgvector` array alongside critical versioning information (`model_name`, `model_version`, `preprocessing_version`).
- `AttendanceSession` & `AttendanceRecord`: Base structure for future Phase 11 functionality.

## Enrollment Validation
Student registration submits exactly five live camera frames to `POST /students/register`. The backend validates each frame through the ML Service's `/embed` endpoint and persists the student plus all embeddings in one transaction. Additional face samples use `POST /students/{id}/enroll`, also validating exactly one face. Raw embeddings and original images are never exposed or persisted.

## Recognition Flow
Uses `pgvector` operators (`cosine_distance`) to identify candidate faces natively in PostgreSQL. If similarity >= `RECOGNITION_THRESHOLD`, it records a MATCH.

**Notice**: The current recognition threshold is marked as `NOT CALIBRATED - DEVELOPMENT ONLY`.

## Known Limitations
- The authentication and RBAC mechanisms are omitted per the phased instructions (Phase 10 will cover it).
- Testing environment isolates PostgreSQL and uses mocked sessions/SQLite fallbacks to ensure CI passes cleanly without heavy DB containers.
