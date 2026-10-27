# Phase 0 Requirements & Architecture

## 1. Project Objective
Build a robust AI-Based Face Recognition Attendance System. The core functionality is to register students, generate their facial embeddings, and reliably recognize them in real-time or from images to mark attendance, securely rejecting unknown individuals.

## 2. Functional Requirements
- **Student Registration**: Capture 3-5 face samples per student, perform quality checks, extract and store embeddings.
- **Attendance Marking**: Process images/video frames to detect, align, embed, and recognize faces. Mark attendance for recognized students within an active session.
- **Session Management**: Admin capability to start, stop, and manage attendance sessions.
- **Reporting**: Provide attendance records and system health metrics.

## 3. Non-functional Requirements
- **Accuracy**: High precision in recognition with strict thresholding to prevent false positives (marking the wrong student).
- **Performance**: Real-time or near real-time inference.
- **Scalability**: Microservices architecture separating Frontend, Backend, and ML Service.
- **Security & Privacy**: Secure biometric storage (embeddings, not necessarily raw images indefinitely), RBAC, JWT.

## 4. Recognition Workflow
1. Image Input -> 2. Face Detection -> 3. Face Alignment -> 4. Feature Extraction (Embedding) -> 5. Similarity Matching against Gallery -> 6. Identity Assignment or UNKNOWN.

## 5. Student Registration Workflow
Student Details Input -> Capture 3-5 images -> Quality Validation (blur, size, pose) -> Detect & Align -> Extract Embeddings -> L2 Normalize -> Store in Database Gallery linked to Student ID.

## 6. Attendance Workflow
Active Session -> Receive Classroom Image -> Detect & Align all faces -> Extract Embeddings -> Compare each against Database -> Filter by Threshold -> Pass recognized IDs to Backend -> Backend validates and marks attendance (preventing duplicates).

## 7. Face detection → alignment → embedding → matching architecture
- **Detection**: Locate bounding boxes and key facial landmarks (eyes, nose, mouth).
- **Alignment**: Use landmarks to affine-transform the face to a standard canonical pose.
- **Embedding**: Pass aligned face through a CNN/ViT to output a high-dimensional vector (e.g., 512D).
- **Matching**: Calculate Cosine Similarity between query embedding and stored embeddings.

## 8. Recommended pretrained recognition model
**ArcFace (via InsightFace)**. It provides state-of-the-art accuracy, excellent inter-class discrepancy, and robust pretrained models (e.g., ResNet-50/100 trained on WebFace or MS1M). 

## 9. Recommended detector
**SCRFD or RetinaFace (via InsightFace)**. They jointly output bounding boxes and 5 facial landmarks required for highly accurate alignment, which is critical for ArcFace.

## 10. Recommended embedding strategy
- L2 normalize all embeddings upon extraction.
- Store 3-5 embeddings per student to capture intra-class variation.
- Store model version alongside embeddings to allow future migrations.

## 11. Similarity metric
**Cosine Similarity**. Since vectors are L2 normalized, cosine similarity equates to the dot product, which is computationally efficient.

## 12. Unknown-face handling strategy
Any face yielding a max similarity score below the calibrated threshold is classified as UNKNOWN. UNKNOWN faces are logged for analytics but NEVER automatically create a student or trigger an attendance event.

## 13. Threshold calibration strategy
Gather a validation set of enrolled vs. unenrolled faces. Plot False Accept Rate (FAR) vs. False Reject Rate (FRR). Select a strict threshold prioritizing low FAR (e.g., FAR=0.1%) to minimize false attendance.

## 14. Data model proposal
- `users`: id, role, password_hash
- `students`: id, student_id, name
- `face_embeddings`: id, student_id, embedding (vector), model_version, quality_score
- `sessions`: id, course, start_time, end_time
- `attendance_records`: id, session_id, student_id, timestamp, similarity_score

## 15. Backend architecture
FastAPI orchestrating business logic, interacting with PostgreSQL via SQLAlchemy. Handles Auth, Sessions, and acts as the gatekeeper to the ML Service.

## 16. ML service architecture
Isolated FastAPI service. Loads PyTorch/ONNX models in memory at startup. Exposes endpoints for `POST /extract-embeddings` (for registration) and `POST /recognize` (if matching is done in ML) or simply returns embeddings to the backend for DB matching.

## 17. API architecture proposal
Frontend communicates solely with Backend. Backend forwards images to ML Service for processing.
- `POST /api/students/register` (Frontend -> Backend -> ML Service)
- `POST /api/attendance/mark` (Frontend -> Backend -> ML Service)

## 18. Security architecture
- JWT for state-free auth.
- RBAC (Admin vs User).
- No direct database/ML exposure to Frontend.

## 19. Biometric-data privacy considerations
- Store irreversible embeddings, not raw facial images (if policy dictates).
- Embeddings are mathematically bound to the specific model (meaningless outside the system).

## 20. Error-handling strategy
Standardized JSON error responses. ML timeouts gracefully handled by Backend. Strict quality rejection at registration returns actionable errors (e.g., "Face too blurry").

## 21. Logging/monitoring strategy
Log inference times, face counts, and average similarities. Do not log raw biometrics or PII in plain text.

## 22. Project directory structure
```text
project/
├── backend/
├── ml-service/
├── frontend/
├── dataset/
├── docs/
└── tests/
```

## 23. Phase 0 assumptions
- The 10k comic/face dataset is for auxiliary purposes and does NOT provide student identities.
- Hardware is sufficient for near real-time inference (GPU preferred).

## 24. Risks and mitigation strategies
- **Risk**: High False Accept Rate marking wrong students. **Mitigation**: Strict thresholding and requiring multiple high-quality registration samples.
- **Risk**: Database latency for vector matching. **Mitigation**: Use `pgvector` or FAISS if student count grows significantly.

## 25. Dependencies that must be validated before Phase 1
- `insightface`, `onnxruntime`, `torch`, `fastapi`, `psycopg2-binary`, `pgvector` availability in environment.
