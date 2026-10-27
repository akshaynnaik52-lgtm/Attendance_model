# Real-Time Multi-Face Detection System for Automated Attendance

## Project Description
A comprehensive system for multi-face detection in academic environments. The solution strictly segregates concerns across a React Frontend, a Python FastAPI Backend, and a Python FastAPI ML Service using YOLO.

## Phases
Phase 0 — Requirements & Architecture
Phase 1 — Dataset Audit
Phase 2 — Dataset Preparation & Annotation
Phase 3 — YOLO Baseline
Phase 4 — Model Training
Phase 5 — Model Evaluation
Phase 6 — Model Optimization
Phase 7 — ML FastAPI Service
Phase 8 — Backend Integration
Phase 9 — React Frontend Integration
Phase 10 — Authentication & RBAC
Phase 11 — End-to-End Integration
Phase 12 — Testing & Benchmarking

## Documentation
- [Phase 0 Architecture](docs/PHASE_0_ARCHITECTURE.md)
- [Project Spec](PROJECT_SPEC.md)
- [Architecture](ARCHITECTURE.md)
- [Agent Rules](AGENTS.md)

## Windows Development
Create the project-root `.venv` with the backend and ML service dependencies installed, and run `npm install` from `frontend` once. Then launch `start_system.bat` to open the ML service, backend, and frontend in separate windows. Use `stop_system.bat` to close those windows or `restart_system.bat` to restart them.
