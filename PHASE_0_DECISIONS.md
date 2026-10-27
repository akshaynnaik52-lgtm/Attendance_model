# Phase 0 Decisions

## Selected Recognition Model
**ArcFace (via InsightFace)**. Highly accurate, widely adopted, and available with robust pretrained weights. Avoids training from scratch.

## Selected Detector
**SCRFD or RetinaFace**. Provide both precise bounding boxes and 5-point facial landmarks essential for proper alignment before ArcFace embedding.

## Embedding Strategy
- Extract 512D vectors.
- L2-normalize vectors immediately.
- Store 3-5 reference embeddings per student (a gallery) rather than a single averaged embedding, to preserve varying poses/lighting.

## Similarity Metric
**Cosine Similarity** (implemented as Dot Product on L2-normalized vectors).

## Proposed Threshold-Calibration Approach
Empirical calibration using a dedicated validation set. Plot FAR vs FRR and select a threshold that heavily penalizes False Accepts (e.g., aiming for 99.9% precision) to ensure no incorrect attendance is marked.

## Database Approach
**PostgreSQL + pgvector**. `pgvector` allows native cosine distance matching directly in the database (`<#>`), preventing the need to load all embeddings into Python memory as the student base grows.

## Service Architecture
Microservices approach: React Frontend -> FastAPI Backend -> FastAPI ML Service. Backend holds the database connection; ML Service only processes pixels into vectors.

## Important Assumptions
- Face alignment is non-negotiable for high recognition accuracy.
- Student identities will be enrolled manually via a dedicated registration UI, not scraped from the raw 10k dataset.

## Unresolved Decisions
- Exact model weights (e.g., ResNet50 vs MobileFaceNet) will be chosen based on hardware constraints (CPU vs GPU deployment) during Phase 3/4.
- Strategy for updating a student's gallery over time (e.g., adaptive updating if their appearance changes).
