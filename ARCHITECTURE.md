# System Architecture

## Overview
The system relies on a microservices-inspired architecture isolating the ML capabilities from business logic and presentation.

### 1. React Frontend
- Provides the UI for Admin/Users.
- Communicates only via REST to the FastAPI Backend.

### 2. FastAPI Backend
- Central gateway for all business logic, data persistence, and system coordination.
- Handles Auth, RBAC, Data management.

### 3. ML Service (FastAPI)
- Pure detection service.
- Isolated from Postgres.
- Exposes endpoints to process images and return bounding boxes.

### 4. Database (PostgreSQL)
- Relational storage for users, sessions, attendance.

## Communication Boundaries
- Frontend <--> Backend (Allowed)
- Backend <--> Database (Allowed)
- Backend <--> ML Service (Allowed)
- Frontend <--> ML Service (FORBIDDEN)
- ML Service <--> Database (FORBIDDEN)

## Attendance Operations
- Attendance records can be exported as UTF-8 CSV from the authenticated reports API.
- The browser sends camera snapshots to the backend over the existing authenticated REST endpoint.
- An authenticated WebSocket channel broadcasts recognition outcomes and proxy alerts to session viewers; it does not stream raw video.
- Recognized faces must complete a randomized head-movement challenge before attendance is recorded. The current check uses detector bounding-box motion as a lightweight liveness signal, not a trained presentation-attack detector.
- Challenge state is currently held in backend process memory. Run a single backend worker or provide sticky routing until challenge state is moved to shared storage.
- Proxy evidence, logs, and aggregate security metrics are available to admins only.
