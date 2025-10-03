@echo off
:: ============================================================================
::                 🚦 AI TRAFFIC SIGN RECOGNITION SYSTEM 🚦
::                        Ultimate Launch Script (Batch)
:: ============================================================================

setlocal EnableDelayedExpansion

:: Use batch implementation for better compatibility

:: Fallback batch implementation
title AI Traffic Sign Recognition System

echo(
echo ========================================================================
echo                🚦 AI TRAFFIC SIGN RECOGNITION SYSTEM 🚦
echo                        Ultimate Launch Script
echo ========================================================================
echo(

:: Resolve Python command (prefer python, fallback to py -3)
set "PYCMD="
where python >nul 2>&1 && set "PYCMD=python"
if not defined PYCMD (
    where py >nul 2>&1 && set "PYCMD=py -3"
)

:: Step 1: Check Prerequisites
echo [1/6] Checking Prerequisites...

if not defined PYCMD (
    echo ❌ Error: Python is not installed or not on PATH
    echo Please install Python from https://python.org or ensure 'python' or 'py' is on PATH
    pause
    exit /b 1
) else (
    %PYCMD% --version
)

where node >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Error: Node.js is not installed
    echo Please install Node.js from https://nodejs.org
    pause
    exit /b 1
) else (
    node --version
)

echo Checking for Node package manager...
set "PKG="
where npm >nul 2>&1 && set "PKG=npm"
if not defined PKG (
    where pnpm >nul 2>&1 && set "PKG=pnpm"
)
if defined PKG echo Using !PKG! for frontend
if not defined PKG echo No Node package manager found (npm/pnpm). Frontend will be skipped.

echo Prerequisites check complete
echo Proceeding to environment setup...
echo(

:: Step 2: Setup Environment
echo [2/6] Setting up Environment...

:: Common URLs
set "BACKEND_HEALTH=http://localhost:5000/api/health"
set "FRONTEND_URL=http://localhost:3000/"

if not exist ".venv\Scripts\activate.bat" (
    echo Creating Python virtual environment...
    %PYCMD% -m venv .venv
    if %errorlevel% neq 0 (
        echo ❌ Failed to create virtual environment
        pause
        exit /b 1
    )
)

echo Installing Python packages...
pushd backend >nul
call "..\\.venv\\Scripts\\activate.bat"
python -m pip install --upgrade pip setuptools wheel --quiet
pip install -r requirements.txt --quiet
if %errorlevel% neq 0 (
    echo ❌ Failed to install Python packages
    popd >nul
    pause
    exit /b 1
)
popd >nul

echo Installing Node.js packages...
pushd frontend >nul
if not exist "node_modules" (
    if defined PKG (
        !PKG! install --silent
        if %errorlevel% neq 0 (
            echo ❌ Failed to install Node packages with !PKG!
            popd >nul
            pause
            exit /b 1
        )
    )
    if not defined PKG (
        echo ⚠️  Skipping frontend dependency install (no npm/pnpm)
    )
)
popd >nul

echo ✅ Environment setup complete
echo(

:: Step 3: Start Backend
echo [3/6] Starting Backend Server...
pushd backend >nul
start "AI Traffic Signs Backend" cmd /k "call ..\\.venv\\Scripts\\activate.bat && python app.py"
popd >nul

:: Wait for backend health
echo Waiting for backend to become healthy (%BACKEND_HEALTH%)...
set "HC="
set "HAS_CURL=0"
where curl >nul 2>&1 && set "HAS_CURL=1"
if "!HAS_CURL!"=="1" (
    for /l %%i in (1,1,30) do (
        for /f "usebackq tokens=*" %%H in (`curl -s -o NUL -w "%%{http_code}" %BACKEND_HEALTH%`) do set "HC=%%H"
        if "!HC!"=="200" goto backend_ready
        timeout /t 2 /nobreak >nul
    )
    echo Backend health not confirmed within timeout. Proceeding.
)
if "!HAS_CURL!"=="0" (
    echo ⚠️  curl not found; skipping backend health check
)
:backend_ready
if "!HC!"=="200" echo Backend healthy (200)

:: Step 4: Start Frontend  
if defined PKG (
    echo [4/6] Starting Frontend Server...
    pushd frontend >nul
    if /i "!PKG!"=="npm" (
        start "AI Traffic Signs Frontend" cmd /k "npm start"
    ) else (
        start "AI Traffic Signs Frontend" cmd /k "pnpm start"
    )
    popd >nul
)
if not defined PKG (
    echo [4/6] Skipping Frontend start (no npm/pnpm found)
)

:: Wait for frontend
if defined PKG (
    echo Waiting for frontend to start...
    timeout /t 15 /nobreak >nul
)

:: Step 5: Test Services
echo [5/6] Testing Services...

:: Simple port check using netstat
netstat -an | find ":5000" | find "LISTENING" >nul
if %errorlevel% equ 0 (
    echo Backend: Port 5000 is active
) else (
    echo Backend: Port 5000 not detected
)

netstat -an | find ":3000" | find "LISTENING" >nul
if %errorlevel% equ 0 (
    echo Frontend: Port 3000 is active
) else (
    echo Frontend: Port 3000 not detected
)

:: Step 6: Launch Complete
echo [6/6] Launch Complete!
echo(
echo ========================================================================
echo           AI TRAFFIC SIGN RECOGNITION SYSTEM IS RUNNING!
echo ========================================================================
echo(
echo 🌐 SERVICE STATUS:
echo   Frontend (React):     http://localhost:3000
echo   Backend API (Flask):  http://localhost:5000
echo   API Health Check:     http://localhost:5000/api/health
echo(
echo 📖 HOW TO USE:
echo 1. Open http://localhost:3000 in your browser
echo 2. Upload a dashcam image or video
echo 3. Click 'Analyze for Traffic Signs'
echo 4. View the AI detection results!
echo.

:: Open browser
if defined PKG (
    echo Opening browser...
    start http://localhost:3000
)
if not defined PKG (
    echo Browser not opened because frontend was skipped.
)

echo.
echo ⚠️  Close this window or press Ctrl+C to stop both servers
echo Two new windows opened for Backend and Frontend - you can monitor them there
echo.
pause
