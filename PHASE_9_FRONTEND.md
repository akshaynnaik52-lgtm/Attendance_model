# Phase 9 React Frontend

## Objective
Build a professional, academic React Single Page Application (SPA) using Vite, TypeScript, and Tailwind CSS. The frontend must interact exclusively with the Backend via a centralized API client.

## Architecture
- **Framework**: React + Vite
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Routing**: React Router DOM
- **HTTP Client**: Axios (`src/api/api.ts`)

## Strict Backend Communication
All API endpoints are centralized in `src/api/api.ts`. Components must not use raw `fetch()` or inline API calls. 
Backend URL is configured via environment variable `VITE_API_BASE_URL`.

## Pages & UI State
Implemented responsive layouts mapping to Backend endpoints:
- **Dashboard**: High-level system status and counts.
- **Students**: List, search, detail view, live-camera registration, and admin-only deletion.
- **Face Enrollment**: Webcam-only capture workflow that surfaces validation scores from the Backend API. New student registration automatically captures five valid frames and saves the student and embeddings atomically.
- **Recognition**: Live processing view displaying candidate similarities and distinct `MATCH` / `UNKNOWN` / `LOW QUALITY` states without leaking internal vector arrays.
- **System Health**: Connects to `/api/health`.

## Camera Requirements
- Browser camera permission is required for student enrollment and live attendance.
- `getUserMedia` requires HTTPS in deployed environments; `localhost` is permitted for local development.
- Raw camera frames are sent to the Backend for validation and recognition; the frontend does not communicate with the ML service or database directly.
- Live attendance begins scanning automatically when the camera starts with an active session selected. A session must be started by an administrator before attendance can be marked.
