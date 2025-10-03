@echo off
:: ============================================================================
::                 🚦 AI TRAFFIC SIGN RECOGNITION SYSTEM 🚦
::                        Ultimate Launch Script (Batch)
:: ============================================================================

setlocal EnableDelayedExpansion

:: Use batch implementation for better compatibility

:: Fallback batch implementation
title AI Traffic Sign Recognition System

echo.
echo ========================================================================
echo                🚦 AI TRAFFIC SIGN RECOGNITION SYSTEM 🚦
echo                        Ultimate Launch Script
echo ========================================================================
echo.

:: Refresh PATH to include newly installed programs
call refreshenv >nul 2>&1
for /f "skip=2 tokens=3*" %%a in ('reg query HKCU\Environment /v PATH 2^>nul') do set "userpath=%%b"
for /f "skip=2 tokens=3*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do set "systempath=%%b"
set "PATH=%systempath%;%userpath%"

:: Step 1: Check Prerequisites
echo [1/6] Checking Prerequisites...

python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Error: Python is not installed
    echo Please install Python from https://python.org
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('python --version 2^>^&1') do echo ✅ Python: %%i
)

node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Error: Node.js is not installed
    echo Please install Node.js from https://nodejs.org
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('node --version 2^>^&1') do echo ✅ Node.js: %%i
)

npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Error: npm is not installed
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('npm --version 2^>^&1') do echo ✅ npm: v%%i
)

echo ✅ Prerequisites check complete
echo.

:: Step 2: Setup Environment
echo [2/6] Setting up Environment...

if not exist ".venv\Scripts\activate.bat" (
    echo Creating Python virtual environment...
    python -m venv .venv
    if %errorlevel% neq 0 (
        echo ❌ Failed to create virtual environment
        pause
        exit /b 1
    )
)

echo Installing Python packages...
cd backend
call "..\\.venv\\Scripts\\activate.bat"
pip install -r requirements.txt --quiet
cd ..

echo Installing Node.js packages...
cd frontend
if not exist "node_modules" (
    npm install --silent
)
cd ..

echo ✅ Environment setup complete
echo.

:: Step 3: Start Backend
echo [3/6] Starting Backend Server...
cd backend
start "AI Traffic Signs Backend" cmd /k "call ..\\.venv\\Scripts\\activate.bat && python app.py"
cd ..

:: Wait for backend
echo Waiting for backend to start...
timeout /t 10 /nobreak >nul

:: Step 4: Start Frontend  
echo [4/6] Starting Frontend Server...
cd frontend
start "AI Traffic Signs Frontend" cmd /k "npm start"
cd ..

:: Wait for frontend
echo Waiting for frontend to start...
timeout /t 15 /nobreak >nul

:: Step 5: Test Services
echo [5/6] Testing Services...

:: Simple port check using netstat
netstat -an | find ":5000" | find "LISTENING" >nul
if %errorlevel% equ 0 (
    echo ✅ Backend: Port 5000 is active
) else (
    echo ⚠️  Backend: Port 5000 not detected
)

netstat -an | find ":3000" | find "LISTENING" >nul
if %errorlevel% equ 0 (
    echo ✅ Frontend: Port 3000 is active
) else (
    echo ⚠️  Frontend: Port 3000 not detected
)

:: Step 6: Launch Complete
echo [6/6] Launch Complete!
echo.
echo ========================================================================
echo           🎉 AI TRAFFIC SIGN RECOGNITION SYSTEM IS RUNNING! 🎉
echo ========================================================================
echo.
echo 🌐 SERVICE STATUS:
echo   Frontend (React):     http://localhost:3000
echo   Backend API (Flask):  http://localhost:5000
echo   API Health Check:     http://localhost:5000/api/health
echo.
echo 📖 HOW TO USE:
echo 1. Open http://localhost:3000 in your browser
echo 2. Upload a dashcam image or video
echo 3. Click 'Analyze for Traffic Signs'
echo 4. View the AI detection results!
echo.

:: Open browser
echo Opening browser...
start http://localhost:3000

echo.
echo ⚠️  Close this window or press Ctrl+C to stop both servers
echo Two new windows opened for Backend and Frontend - you can monitor them there
echo.
pause
