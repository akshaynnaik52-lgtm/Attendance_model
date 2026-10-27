@echo off
setlocal enabledelayedexpansion

title AI Attendance - Stop System

echo ========================================================================
echo    AI-POWERED REAL TIME FACE RECOGNITION ATTENDANCE SYSTEM
echo               Windows Safe System Shutdown
echo ========================================================================
echo.

echo [INFO] Closing AI Attendance service windows...

:: Terminate only service command windows created by the launcher.
taskkill /FI "WINDOWTITLE eq AI Attendance - ML Service*" /T /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq AI Attendance - Backend*" /T /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq AI Attendance - Frontend*" /T /F >nul 2>&1

echo.
echo ========================================================================
echo [OK] Launcher service windows have been closed.
echo If a service was started outside the launcher, stop it from its own terminal.
echo ========================================================================
echo.

if /i not "%~1"=="--no-pause" pause
exit /b 0
