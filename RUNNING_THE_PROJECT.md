# Running the AI-Powered Face Recognition Attendance System

## Overview
This document describes how to configure, start, operate, and shut down the complete end-to-end AI Face Recognition Attendance System on Windows.

> **Architecture Notice:**  
> **Docker is intentionally not used for this academic project.** The system uses native Windows development services and provides automated one-click startup and shutdown via `start_system.bat` and `stop_system.bat`.

---

## 1. Prerequisites

Before running the application, ensure the following software is installed on your Windows machine:

1. **Python**: Version `3.11` through `3.14` (64-bit).
   * Install the version you want if it is missing; for Python 3.14, use `winget install --exact --id Python.Python.3.14`. Alternatively, install Python from python.org and enable the Python launcher.
   * Open a new PowerShell window and verify with `py -3.14 --version` (replace `3.14` with your installed version).
2. **Node.js & npm**: Node.js `v18.0.0` or higher (LTS recommended).
   * Verify with: `node -v` and `npm -v`.
3. **PostgreSQL**: Version `15` or `16` with the `pgvector` extension.
   * Default port: `5432`.
   * Database name: `attendance_db`.

---

## 2. Database Setup

1. Open PostgreSQL command line (`psql`) or pgAdmin:
   ```sql
   CREATE DATABASE attendance_db;
   \c attendance_db
   CREATE EXTENSION IF NOT EXISTS vector;
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
   ```

   If PostgreSQL reports `extension "vector" is not available`, installing the Python `pgvector` package is not sufficient; the server extension must also be installed. On Windows, install Git and Visual Studio Build Tools with the C++ build tools and Windows SDK, then open an elevated x64 Native Tools Command Prompt for Visual Studio and run:
   ```cmd
   git clone --depth 1 --branch v0.8.7 https://github.com/pgvector/pgvector.git "%TEMP%\pgvector"
   cd /d "%TEMP%\pgvector"
   nmake /F Makefile.win "PGROOT=C:\Program Files\PostgreSQL\16"
   nmake /F Makefile.win "PGROOT=C:\Program Files\PostgreSQL\16" install
   ```
   For PostgreSQL 15, change `PGROOT` to its installation directory. Then rerun `CREATE EXTENSION IF NOT EXISTS vector;` in `attendance_db`.

2. Confirm your database credentials match the configuration in `.env` (or default `postgresql+asyncpg://postgres:postgres@localhost:5432/attendance_db`).

---

## 3. Configuration & Environment Variables

Copy `.env.example` to `.env` in the project root if it does not already exist:

```ini
# Backend Configuration
DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/attendance_db
ML_SERVICE_URL=http://localhost:8001/api/v1
SECRET_KEY=change-me-in-production-super-secret-key-phase-12
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_MINUTES=1440
CORS_ORIGINS=["http://localhost:5173","http://localhost:3000"]

# ML Service Configuration
ML_PORT=8001
ML_HOST=127.0.0.1
```

---

## 4. First-Time Setup vs. Normal Startup

### First-Time Setup (Run Once)
Before your very first run:

1. **InsightFace models**: Place `det_10g.onnx` at `models\detection\scrfd\det_10g.onnx` and `w600k_r50.onnx` at `models\recognition\arcface\w600k_r50.onnx`. The ML service loads these project-local files directly and refuses to start without the real models.
2. **Python Dependencies**:
   ```powershell
   py -3.14 --version
   if ($LASTEXITCODE -ne 0) { throw "Python 3.14 is not installed. Install it before continuing." }
   py -3.14 -m venv .venv
   if ($LASTEXITCODE -ne 0) { throw "Virtual environment creation failed." }
   .\.venv\Scripts\python.exe -m pip install --upgrade pip
   if ($LASTEXITCODE -ne 0) { throw "Pip upgrade failed." }
   .\.venv\Scripts\python.exe -m pip install -r requirements.txt -r ml_service\requirements.txt
   if ($LASTEXITCODE -ne 0) { throw "Python dependency installation failed." }
   ```
3. **Frontend Dependencies**:
   ```powershell
   cd frontend
   npm install
   cd ..
   ```
4. **Database Migrations**:
   ```powershell
   cd backend
   ..\.venv\Scripts\python.exe -m alembic upgrade head
   cd ..
   ```
5. **Initial administrator (once per database)**: After migrations, run this command from the `backend` directory. It prompts for a username and a hidden password of at least 12 characters. Use `python -c` so the prompts can read from the console; piping a script into `python -` consumes standard input and causes `EOFError`.
   ```powershell
   ..\.venv\Scripts\python.exe -c "import getpass, os; os.environ['INITIAL_ADMIN_USERNAME'] = input('Admin username: ').strip(); os.environ['INITIAL_ADMIN_PASSWORD'] = getpass.getpass('Admin password (12+ characters): '); from app.bootstrap_admin import bootstrap_admin; bootstrap_admin(); print('Initial administrator created.')"
   ```
   The bootstrap command refuses to create an admin if one already exists.

### Normal Startup (Everyday Use)
Simply double-click:
```
start_system.bat
```
`start_system.bat` automatically verifies/installs the pinned InsightFace and ONNX Runtime dependencies, checks both model files, verifies PostgreSQL connectivity, performs safe schema upgrades, boots all 3 subsystems in correct dependency order with a `REAL_MODEL_LOADED` health check, and presents service URLs.

---

## 5. System Services & Ports

| Service | Port | Health / Status Endpoint | Window Title |
| :--- | :--- | :--- | :--- |
| **ML Recognition Service** | `8001` | `http://localhost:8001/api/v1/health` | `AI Attendance - ML Service` |
| **FastAPI Backend** | `8000` | `http://localhost:8000/api/health` | `AI Attendance - Backend` |
| **React / Vite Frontend** | `5173` | `http://localhost:5173` | `AI Attendance - Frontend` |
| **PostgreSQL Database** | `5432` | Native TCP Port 5432 | Windows Service |

---

## 6. One-Click Operations

### Starting the System
Double-click `start_system.bat` from File Explorer or run:
```cmd
start_system.bat
```
* **Order of Execution**:
  1. Prerequisite verification (Python, Pip, Node, npm).
  2. Virtual environment activation (if `.venv` or `venv` exists).
  3. Frontend dependency validation (auto-runs `npm install` if missing).
  4. PostgreSQL connectivity verification.
  5. Safe schema migration execution (`alembic upgrade head`).
  6. ML Service launch on port `8001` + active health check polling.
  7. Backend FastAPI launch on port `8000` + active health check polling.
  8. React/Vite dev server launch on port `5173`.
  9. Displays system dashboard.
* Service command windows are opened in their respective project folders, including when the project path contains spaces. Database migration errors are shown and abort startup rather than being hidden.

### Stopping the System
Double-click `stop_system.bat` or run:
```cmd
stop_system.bat
```
* Terminated safely by window title and targeted listening ports (`8001`, `8000`, `5173`).
* **Does not** kill unrelated Python, Node, or database processes.

### Restarting the System
Double-click `restart_system.bat` or run:
```cmd
restart_system.bat
```
* Safely stops existing services, waits 3 seconds, and triggers `start_system.bat`.

---

## 7. Manual Startup Commands (Alternative)

If you prefer to start each service manually in separate PowerShell terminal windows:

### Terminal 1 — ML Recognition Service:
```powershell
cd ml_service
..\.venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8001 --reload
```

### Terminal 2 — Backend FastAPI:
```powershell
cd backend
..\.venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

### Terminal 3 — Frontend React:
```powershell
cd frontend
npm run dev
```

---

## 8. Verifying End-to-End Functionality

1. Open your browser and navigate to: `http://localhost:5173`
2. **Login**: Authenticate with the initial admin created by `app.bootstrap_admin` or an account provisioned by an existing administrator.
3. **Student Registration**: As an admin, open `/students/register`, start the camera, and allow browser camera access. It automatically captures five samples one second apart. New students and their face templates are saved together only after every sample passes real-model validation. Use **Replace Face Samples** on an existing student's detail page to safely re-enroll five samples; existing templates remain until all five new captures validate.
4. **Session Management**: Navigate to `/sessions` to create and activate a new attendance session.
5. **Live Attendance**: Navigate to `/attendance`, create/start a session on `/sessions` if none is active, then start the camera. Recognition runs automatically and enrolled students are recorded as `PRESENT` in the active session. Camera permission requires HTTPS in production; `localhost` works for local development.
6. **Student Deletion**: Admins can permanently delete a student from the directory. This also removes the student's face templates and attendance records.
7. **Reports**: Access `/reports` to inspect attendance records and export summary statistics.
8. **System Health**: Access `/health` to observe real-time health across Backend and ML services, including `REAL_MODEL_LOADED` and the detector/recognizer load state.

---

## 9. Common Troubleshooting

| Issue | Likely Cause | Solution |
| :--- | :--- | :--- |
| `No suitable Python runtime found` | The requested Python version is not installed or the Python launcher cannot find it | Install a supported Python version (3.11-3.14), open a new PowerShell window, verify with `py -3.14 --version` (adjust for your version), then create the virtual environment |
| `pydantic-core` fails to build | An older Pydantic version is pinned or pip is installing from stale requirements | Ensure all project requirement files use Pydantic 2.13.5, then run `.\.venv\Scripts\python.exe -m pip install -r requirements.txt -r ml_service\requirements.txt` |
| `[ERROR] Python was not found` | Python not installed or not in PATH | Install Python 3.11-3.14 and enable "Add to PATH" |
| `[ERROR] Node.js was not found` | Node.js not installed | Install Node.js LTS from nodejs.org |
| `[WARN] PostgreSQL is not responding` | Service stopped or non-standard port | Run `net start postgresql-x64-16` or start PostgreSQL in Services app |
| `ML Service timeout on port 8001` | Port conflict or missing packages | Check `AI Attendance - ML Service` window for specific tracebacks |
| `Backend timeout on port 8000` | Port conflict or database connection error | Ensure PostgreSQL credentials in `.env` are valid |
| `CORS Error in browser` | Requests from origin other than localhost:5173 | Add your origin to `CORS_ORIGINS` in `.env` |
