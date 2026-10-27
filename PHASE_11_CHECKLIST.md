# Phase 11 Checklist — End-to-End Attendance Workflow

- [x] Extend `AttendanceSession` model with `CREATED` / `ACTIVE` / `COMPLETED` lifecycle states
- [x] Implement database-level `UniqueConstraint('session_id', 'student_id', name='uq_session_student')`
- [x] Create session lifecycle endpoints (`/sessions`, `/sessions/{id}/start`, `/sessions/{id}/stop`)
- [x] Implement `POST /api/attendance/recognize` linking camera frames -> ML embedding -> pgvector matching -> attendance creation
- [x] Enforce duplicate prevention at application and database level (`ALREADY_MARKED`)
- [x] Transactional attendance insertion with graceful rollback on concurrent race conditions
- [x] Handle all edge outcomes: `MATCHED`, `ALREADY_MARKED`, `UNKNOWN`, `LOW_QUALITY`, `NO_FACE`, `NO_ACTIVE_SESSION`
- [x] Expose session attendance rosters (`GET /api/attendance/sessions/{id}/records`)
- [x] Connect Reports & Analytics to real backend records (`GET /api/attendance/reports`)
- [x] Upgrade frontend `AttendancePage` to browser WebRTC camera capture (`getUserMedia`)
- [x] Implement controlled interval capture loop (2.5s) to avoid frame saturation
- [x] Create automated test suite (`tests/test_attendance.py`) verifying full workflow, duplicate prevention, and lifecycle states
- [x] Preserve explicit threshold status: "PRODUCTION RECOGNITION THRESHOLD NOT CALIBRATED — REAL IDENTITY-AWARE DATA REQUIRED"
- [x] Documented in `docs/PHASE_11_ATTENDANCE.md` and `docs/PHASE_11_CHECKLIST.md`
