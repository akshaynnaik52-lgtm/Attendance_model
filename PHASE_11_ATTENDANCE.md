# Phase 11 — End-to-End Attendance Workflow

## 1. Objective
Establish the full end-to-end biometric attendance pipeline:
```
Browser WebRTC Camera
        ↓
FastAPI Backend (/api/attendance/recognize)
        ↓
FastAPI ML Service (/api/v1/embed)
        ├── SCRFD Detection
        ├── 5-Point Landmark Alignment
        └── ArcFace (w600k_r50) 512-D L2 Embedding
        ↓
PostgreSQL + pgvector Gallery Matching (Cosine Distance <=>)
        ↓
Threshold & Quality Decision
        ↓
Attendance Session Validation & Duplicate Check
        ↓
Transactional Attendance Record Creation
```

## 2. Session Lifecycle
Attendance sessions transition through strict states:
- `CREATED`: Session created by instructor/admin with metadata (title, course code). Attendance cannot yet be taken.
- `ACTIVE`: Session activated. The camera capture loop can now verify and record attendance.
- `COMPLETED`: Session closed. No further attendance can be marked.

## 3. Duplicate Prevention & Database Integrity
A student can receive attendance **ONLY ONCE** per session. This is strictly enforced across three layers:
1. **Frontend State**: Visual indicator `ALREADY_MARKED` prevents redundant requests for verified students.
2. **Backend Application Logic**: Checks existing records for `(session_id, student_id)` before attempting insert.
3. **Database Constraint (Authoritative)**: Enforced via `UniqueConstraint('session_id', 'student_id', name='uq_session_student')` in `attendance_records` table. Any concurrent duplicate race condition raises `IntegrityError`, caught gracefully and returned as `ALREADY_MARKED`.

## 4. Recognition Outcomes
The endpoint `POST /api/attendance/recognize` yields structured outcomes per face:
- `MATCHED`: Similarity >= Threshold, session active, attendance successfully marked.
- `ALREADY_MARKED`: Student recognized, but attendance was already recorded for this session.
- `UNKNOWN`: Similarity < Threshold. No attendance created.
- `LOW_QUALITY`: Blur, extreme angle, or insufficient lighting. No attendance created.
- `NO_FACE`: Zero faces detected in capture. No attendance created.
- `NO_ACTIVE_SESSION`: Session not currently active. No attendance created.

## 5. WebRTC Camera Flow
- Browser captures user media using `navigator.mediaDevices.getUserMedia`.
- Controlled periodic loop captures frames onto an offscreen canvas at configurable intervals (2.5 seconds) rather than unconstrained frame streaming.
- Frames are posted as JPEG blobs to `/api/attendance/recognize`.
- Results render instantly with live roster polling.

## 6. Threshold Notice
**CRITICAL NOTICE**:
`PRODUCTION RECOGNITION THRESHOLD NOT CALIBRATED — REAL IDENTITY-AWARE DATA REQUIRED.`
The attendance engine operates with a configurable development threshold (`RECOGNITION_THRESHOLD=0.5`). Threshold optimization will be calibrated once consented real-world dataset captures are completed.

## 7. Attendance API Contracts
- `POST /api/attendance/sessions`: Create new session (Admin only)
- `GET /api/attendance/sessions`: List all sessions
- `GET /api/attendance/sessions/{id}`: Detailed session metadata
- `POST /api/attendance/sessions/{id}/start`: Transition session to `ACTIVE`
- `POST /api/attendance/sessions/{id}/stop`: Transition session to `COMPLETED`
- `POST /api/attendance/recognize`: Live frame biometric attendance verification
- `GET /api/attendance/sessions/{id}/records`: Session attendance roster
- `GET /api/attendance/reports`: Historical and aggregated analytics
