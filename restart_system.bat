@echo off
setlocal

title AI Attendance - Restart System

echo ========================================================================
echo    AI-POWERED REAL TIME FACE RECOGNITION ATTENDANCE SYSTEM
echo                    System Restart Utility
echo ========================================================================
echo.

set "ROOT_DIR=%~dp0"

echo [1/2] Stopping existing services...
call "%ROOT_DIR%stop_system.bat" --no-pause
if errorlevel 1 (
    echo [ERROR] Existing service windows could not be stopped.
    exit /b 1
)

echo.
echo [2/2] Waiting 3 seconds before starting up...
timeout /t 3 /nobreak >nul

echo Starting system services...
call "%ROOT_DIR%start_system.bat"
exit /b %ERRORLEVEL%
