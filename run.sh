#!/bin/bash
# ============================================================================
#                 🚦 AI TRAFFIC SIGN RECOGNITION SYSTEM 🚦
#                          Ultimate Launch Script
# ============================================================================

# Colors for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Global variables
BACKEND_PID=""
FRONTEND_PID=""

# Function to print colored text
print_color() {
    local color=$1
    local text=$2
    echo -e "${color}${text}${NC}"
}

# Function to print banner
print_banner() {
    clear
    echo ""
    print_color $MAGENTA "╔════════════════════════════════════════════════════════════════════════════╗"
    print_color $MAGENTA "║                                                                            ║"
    print_color $MAGENTA "║              🚦 AI TRAFFIC SIGN RECOGNITION SYSTEM 🚦                      ║"
    print_color $MAGENTA "║                        Ultimate Launch Script                             ║"
    print_color $MAGENTA "║                                                                            ║"
    print_color $MAGENTA "╚════════════════════════════════════════════════════════════════════════════╝"
    echo ""
}

# Function to print step
print_step() {
    local step=$1
    local description=$2
    local status=$3
    
    local prefix="[$step/6]"
    
    case $status in
        "SUCCESS")
            print_color $GREEN "$prefix ✅ $description"
            ;;
        "ERROR")
            print_color $RED "$prefix ❌ $description"
            ;;
        "WARNING")
            print_color $YELLOW "$prefix ⚠️  $description"
            ;;
        *)
            print_color $CYAN "$prefix 🔄 $description..."
            ;;
    esac
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait for port to be available
wait_for_port() {
    local port=$1
    local timeout=${2:-30}
    local count=0
    
    while [ $count -lt $timeout ]; do
        if nc -z localhost $port 2>/dev/null || (echo >/dev/tcp/localhost/$port) 2>/dev/null; then
            return 0
        fi
        sleep 1
        ((count++))
    done
    return 1
}

# Function to test prerequisites
test_prerequisites() {
    print_step 1 "Checking Prerequisites"
    
    local issues=()
    
    # Check Python3
    if command_exists python3; then
        local python_version=$(python3 --version 2>&1)
        print_color $GREEN "  ✅ Python: $python_version"
    else
        issues+=("Python3 is not installed. Install with: brew install python3 (macOS) or apt install python3 (Ubuntu)")
        print_color $RED "  ❌ Python3: Not found"
    fi
    
    # Check Node.js
    if command_exists node; then
        local node_version=$(node --version 2>&1)
        print_color $GREEN "  ✅ Node.js: $node_version"
    else
        issues+=("Node.js is not installed. Download from https://nodejs.org")
        print_color $RED "  ❌ Node.js: Not found"
    fi
    
    # Check npm
    if command_exists npm; then
        local npm_version=$(npm --version 2>&1)
        print_color $GREEN "  ✅ npm: v$npm_version"
    else
        issues+=("npm is not installed. Usually comes with Node.js")
        print_color $RED "  ❌ npm: Not found"
    fi
    
    if [ ${#issues[@]} -gt 0 ]; then
        print_step 1 "Prerequisites Check" "ERROR"
        echo ""
        print_color $YELLOW "💡 Please install the missing requirements:"
        for issue in "${issues[@]}"; do
            print_color $YELLOW "   • $issue"
        done
        echo ""
        print_color $GRAY "Press any key to exit..."
        read -n 1
        exit 1
    fi
    
    print_step 1 "Prerequisites Check" "SUCCESS"
}

# Function to setup environment
setup_environment() {
    print_step 2 "Setting up Environment"
    
    # Setup Python virtual environment
    if [ ! -f ".venv/bin/activate" ]; then
        print_color $CYAN "  🔧 Creating Python virtual environment..."
        python3 -m venv .venv
        if [ $? -ne 0 ]; then
            print_step 2 "Environment Setup" "ERROR"
            print_color $RED "Failed to create virtual environment"
            exit 1
        fi
    else
        print_color $GREEN "  ✅ Virtual environment exists"
    fi
    
    # Install Python packages
    print_color $CYAN "  📦 Installing Python packages..."
    source .venv/bin/activate
    cd backend
    pip install -r requirements.txt --quiet
    if [ $? -ne 0 ]; then
        print_step 2 "Environment Setup" "ERROR"
        print_color $RED "Failed to install Python packages"
        exit 1
    fi
    cd ..
    
    # Install Node.js packages
    print_color $CYAN "  📦 Installing Node.js packages..."
    cd frontend
    if [ ! -d "node_modules" ]; then
        npm install --silent
        if [ $? -ne 0 ]; then
            print_step 2 "Environment Setup" "ERROR"
            print_color $RED "Failed to install Node.js packages"
            exit 1
        fi
    else
        print_color $GREEN "  ✅ Node modules exist"
    fi
    cd ..
    
    print_step 2 "Environment Setup" "SUCCESS"
}

# Function to start backend
start_backend() {
    print_step 3 "Starting Backend Server"
    
    cd backend
    source ../.venv/bin/activate
    
    # Start backend in background
    python app.py > ../backend.log 2>&1 &
    BACKEND_PID=$!
    cd ..
    
    # Wait for backend to start
    print_color $CYAN "  🔄 Waiting for backend to start..."
    if wait_for_port 5000 30; then
        # Test health endpoint
        if curl -s http://localhost:5000/api/health | grep -q "healthy"; then
            print_step 3 "Backend Server (Port 5000)" "SUCCESS"
            return 0
        fi
    fi
    
    print_step 3 "Backend Server" "ERROR"
    print_color $RED "  Backend failed to start properly"
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
    fi
    return 1
}

# Function to start frontend
start_frontend() {
    print_step 4 "Starting Frontend Server"
    
    cd frontend
    
    # Start frontend in background
    npm start > ../frontend.log 2>&1 &
    FRONTEND_PID=$!
    cd ..
    
    # Wait for frontend to start
    print_color $CYAN "  🔄 Waiting for frontend to start..."
    if wait_for_port 3000 60; then
        print_step 4 "Frontend Server (Port 3000)" "SUCCESS"
        return 0
    else
        print_step 4 "Frontend Server" "ERROR"
        print_color $RED "  Frontend failed to start on port 3000"
        if [ ! -z "$FRONTEND_PID" ]; then
            kill $FRONTEND_PID 2>/dev/null
        fi
        return 1
    fi
}

# Function to test services
test_services() {
    print_step 5 "Testing Services"
    
    local all_good=true
    
    # Test backend health
    if curl -s http://localhost:5000/api/health | grep -q "healthy"; then
        print_color $GREEN "  ✅ Backend API: Healthy"
    else
        print_color $RED "  ❌ Backend API: Not responding"
        all_good=false
    fi
    
    # Test frontend
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200"; then
        print_color $GREEN "  ✅ Frontend: Accessible"
    else
        print_color $RED "  ❌ Frontend: Not responding"
        all_good=false
    fi
    
    if [ "$all_good" = true ]; then
        print_step 5 "Service Testing" "SUCCESS"
    else
        print_step 5 "Service Testing" "ERROR"
    fi
    
    return $([ "$all_good" = true ])
}

# Function to show success
show_success() {
    print_step 6 "Launch Complete" "SUCCESS"
    echo ""
    
    print_color $GREEN "🎉 AI TRAFFIC SIGN RECOGNITION SYSTEM IS RUNNING! 🎉"
    echo ""
    
    # Create beautiful status box
    print_color $MAGENTA "┌─────────────────────────────────────────────────────────────────┐"
    print_color $MAGENTA "│                        🌐 SERVICE STATUS                        │"
    print_color $MAGENTA "├─────────────────────────────────────────────────────────────────┤"
    print_color $CYAN "│  🎨 Frontend (React):     http://localhost:3000                │"
    print_color $CYAN "│  🚀 Backend API (Flask):  http://localhost:5000                │"
    print_color $CYAN "│  📊 API Health Check:     http://localhost:5000/api/health     │"
    print_color $CYAN "│  📋 Supported Signs:      http://localhost:5000/api/supported-signs │"
    print_color $MAGENTA "└─────────────────────────────────────────────────────────────────┘"
    echo ""
    
    # Usage instructions
    print_color $YELLOW "📖 HOW TO USE:"
    print_color $CYAN "1. Open http://localhost:3000 in your browser"
    print_color $CYAN "2. Upload a dashcam image or video"
    print_color $CYAN "3. Click 'Analyze for Traffic Signs'"
    print_color $CYAN "4. View the AI detection results!"
    echo ""
    
    # Open browser if available
    if command_exists open; then  # macOS
        print_color $CYAN "🌐 Opening browser..."
        open http://localhost:3000
    elif command_exists xdg-open; then  # Linux
        print_color $CYAN "🌐 Opening browser..."
        xdg-open http://localhost:3000
    fi
    
    print_color $YELLOW "⚠️  Press Ctrl+C to stop both servers"
    echo ""
}

# Function to cleanup
cleanup() {
    echo ""
    print_color $YELLOW "🧹 Cleaning up..."
    
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
    fi
    
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null
    fi
    
    # Kill any remaining processes on our ports
    pkill -f "python app.py" 2>/dev/null
    pkill -f "npm start" 2>/dev/null
    
    print_color $GREEN "✅ Cleanup complete. Goodbye!"
    exit 0
}

# Set up cleanup on exit
trap cleanup EXIT INT TERM

# ============================================================================
#                              MAIN EXECUTION
# ============================================================================

print_banner

# Step 1: Check Prerequisites
test_prerequisites

# Step 2: Setup Environment
setup_environment

# Step 3: Start Backend
if ! start_backend; then
    print_color $RED "❌ Failed to start backend. Exiting."
    exit 1
fi

# Step 4: Start Frontend
if ! start_frontend; then
    print_color $RED "❌ Failed to start frontend. Cleaning up..."
    cleanup
fi

# Step 5: Test Services
if ! test_services; then
    print_color $YELLOW "⚠️  Some services may not be fully functional"
fi

# Step 6: Show Success
show_success

# Keep script running and monitor services
print_color $GRAY "🔍 Monitoring services... (Press Ctrl+C to stop)"

while true; do
    sleep 5
    
    # Check if processes are still running
    if ! kill -0 $BACKEND_PID 2>/dev/null; then
        print_color $RED "❌ Backend service stopped unexpectedly"
        break
    fi
    
    if ! kill -0 $FRONTEND_PID 2>/dev/null; then
        print_color $RED "❌ Frontend service stopped unexpectedly"
        break
    fi
done
