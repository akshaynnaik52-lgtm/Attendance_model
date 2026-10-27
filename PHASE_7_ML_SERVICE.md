# Phase 7 ML Service

## Objective
Convert the recognition engine into a clean, independently runnable stateless FastAPI ML service. 

## Architecture
The FastAPI ML service wraps the core ML pipeline implemented in Phase 3 and Phase 4 (detector, aligner, embedding). It acts strictly as an inference engine and is isolated from business logic, users, and the PostgreSQL database.

## Model Loading
The model (`SCRFD` + `ArcFace`) is initialized once at startup using FastAPI's `lifespan` manager, avoiding the overhead of loading ONNX weights on each request. The ML models are tracked using `ml_manager`.

## Stateless Design
The service contains NO database connections. For identification (`/recognize`), it relies on the backend to supply a pre-filtered list of candidate embeddings within the request itself (`candidates_json`), or simply provides the embeddings via `/embed` and the backend uses `pgvector` for scalable querying.

## Benchmark Results
- Hardware: CPU (Mock inference mode detected since `insightface` is missing on this machine, which evaluates framework overhead).
- Cold-start time: Minimal.
- E2E Request Latency: ~5ms average (Mock mode). 
- *(Note: Real ONNX inference will add ~100-200ms per request on CPU).*

## Known Limitations
1. The ML service requires GPU acceleration (`ONNXRuntime-GPU`) for high-throughput concurrency. 
2. Passing large JSON candidates to `/recognize` may cause network overhead. Ultimately, querying embeddings via `pgvector` in PostgreSQL will be preferred in production.
