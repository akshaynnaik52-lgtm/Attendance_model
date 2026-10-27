@echo off
setlocal

title AI Attendance - Start System

echo ========================================================================
echo    AI-POWERED REAL TIME FACE RECOGNITION ATTENDANCE SYSTEM
echo                    System Startup Utility
echo ========================================================================
echo.

set "ROOT_DIR=%~dp0"
set "PYTHON_EXE=%ROOT_DIR%.venv\Scripts\python.exe"
set "ML_DIR=%ROOT_DIR%ml_service"
set "BACKEND_DIR=%ROOT_DIR%backend"
set "FRONTEND_DIR=%ROOT_DIR%frontend"

if not exist "%PYTHON_EXE%" (
    echo [ERROR] Project Python environment not found:
    echo         "%PYTHON_EXE%"
    echo Create the root .venv and install the backend and ML service requirements.
    exit /b 1
)

if not exist "%ML_DIR%\app\main.py" (
    echo [ERROR] ML service entry point not found: "%ML_DIR%\app\main.py"
    exit /b 1
)

if not exist "%BACKEND_DIR%\app\main.py" (
    echo [ERROR] Backend entry point not found: "%BACKEND_DIR%\app\main.py"
    exit /b 1
)

if not exist "%FRONTEND_DIR%\package.json" (
    echo [ERROR] Frontend package file not found: "%FRONTEND_DIR%\package.json"
    exit /b 1
)

if not exist "%FRONTEND_DIR%\node_modules" (
    echo [ERROR] Frontend dependencies are missing.
    echo Run "npm install" from "%FRONTEND_DIR%" first.
    exit /b 1
)

where.exe npm.cmd >nul 2>&1
if errorlevel 1 (
    echo [ERROR] npm.cmd was not found. Install Node.js and reopen this terminal.
    exit /b 1
)

echo [1/3] Starting ML service on http://127.0.0.1:8001 ...
start "AI Attendance - ML Service" /D "%ML_DIR%" cmd.exe /k ""%PYTHON_EXE%" -m uvicorn app.main:app --host 127.0.0.1 --port 8001 --reload"
if errorlevel 1 goto :start_failed

echo [2/3] Starting backend on http://127.0.0.1:8000 ...
start "AI Attendance - Backend" /D "%BACKEND_DIR%" cmd.exe /k ""%PYTHON_EXE%" -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload"
if errorlevel 1 goto :start_failed

echo [3/3] Starting frontend on http://127.0.0.1:5173 ...
start "AI Attendance - Frontend" /D "%FRONTEND_DIR%" cmd.exe /k "npm.cmd run dev -- --host 127.0.0.1"
if errorlevel 1 goto :start_failed

echo.
echo [OK] Startup commands were launched in separate service windows.
echo Check each window for startup errors, including ML model loading errors.
exit /b 0

:start_failed
echo.
echo [ERROR] A service window could not be started.
exit /b 1