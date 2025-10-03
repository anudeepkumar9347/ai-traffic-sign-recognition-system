# 🔧 Troubleshooting Guide

## Setup Issues

### ❌ "Python is not installed or not in PATH"

**Solution:**
1. Download Python from [python.org](https://www.python.org/)
2. **Important:** Check "Add Python to PATH" during installation
3. Restart your terminal/command prompt
4. Test: `python --version` should show Python 3.8+

### ❌ "Node.js/npm is not installed"

**Solution:**
1. Download Node.js from [nodejs.org](https://nodejs.org/)
2. Install the LTS version (includes npm)
3. Restart your terminal/command prompt
4. Test: `node --version` and `npm --version`

### ❌ "Failed to create virtual environment"

**Solution:**
```bash
# Install venv module
pip install virtualenv

# Or on Ubuntu/Debian
sudo apt install python3-venv
```

### ❌ "pip install failed" or package installation errors

**Solution:**
```bash
# Update pip first
python -m pip install --upgrade pip

# Try installing packages one by one to identify the problematic one
pip install flask
pip install opencv-python
# etc.
```

## Runtime Issues

### ❌ "Module not found" errors when starting backend

**Solution:**
1. Make sure virtual environment is activated:
   - Windows: `venv\Scripts\activate`
   - Mac/Linux: `source venv/bin/activate`
2. Install requirements again: `pip install -r requirements.txt`

### ❌ "Port already in use" errors

**Solution:**
```bash
# Find and kill process using port 5000 (backend)
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID_NUMBER> /F

# Mac/Linux
lsof -ti:5000 | xargs kill -9

# Or change port in backend/app.py:
app.run(debug=True, host='0.0.0.0', port=5001)
```

### ❌ CORS errors in browser

**Solution:**
1. Make sure both backend (port 5000) and frontend (port 3000) are running
2. Check that `flask-cors` is installed: `pip install flask-cors`
3. Clear browser cache and reload

### ❌ File upload fails

**Causes & Solutions:**
- **File too large**: Max size is 100MB, reduce file size
- **Unsupported format**: Use JPEG, PNG, MP4, AVI, etc.
- **Backend not running**: Start backend first
- **Permissions**: Ensure `uploads/` directory exists and is writable

### ❌ Poor detection accuracy

**Solutions:**
1. Use high-quality images with good lighting
2. Ensure traffic signs are clearly visible and not too small
3. For better accuracy, consider training a custom YOLO model
4. The current system uses basic OpenCV detection as fallback

## Platform-Specific Issues

### Windows Issues

#### ❌ "'python' is not recognized"
Try `python3` instead of `python`, or `py -3`

#### ❌ PowerShell execution policy errors
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### ❌ Path too long errors
Move project to a shorter path like `C:\traffic-signs\`

### Mac Issues

#### ❌ Permission denied when running scripts
```bash
chmod +x setup-improved.sh start-backend.sh start-frontend.sh
```

#### ❌ OpenCV installation fails
```bash
# Install dependencies
brew install cmake
pip install opencv-python
```

### Linux Issues

#### ❌ Missing system dependencies
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3-dev python3-pip nodejs npm build-essential

# CentOS/RHEL
sudo yum install python3-devel python3-pip nodejs npm gcc
```

## Performance Issues

### 🐌 Slow video processing

**Solutions:**
- Reduce video resolution before upload
- Use shorter video clips (< 30 seconds recommended)
- The system processes every 30th frame by default
- Consider using images instead of videos for faster results

### 🐌 High memory usage

**Solutions:**
- Close other applications
- Use smaller image/video files
- Restart the application periodically

## Common Questions

### ❓ Can I use custom AI models?

Yes! Place your trained YOLO model in `/models/traffic_signs.pt` and it will be loaded automatically.

### ❓ How to add new traffic sign types?

1. Edit `backend/models/traffic_sign_detector.py`
2. Add new sign types to the `sign_classes` dictionary
3. Update detection logic if needed

### ❓ Can I deploy this to production?

The current setup is for development. For production:
- Use a production WSGI server (gunicorn, uWSGI)
- Build the React app: `npm run build`
- Use a reverse proxy (nginx)
- Add authentication and security measures

### ❓ How to improve detection accuracy?

1. **Train a custom model**: Collect traffic sign images and train YOLOv8
2. **Better preprocessing**: Add image enhancement before detection
3. **Multiple detection methods**: Combine YOLO + OpenCV + template matching
4. **Post-processing**: Add confidence thresholding and non-maximum suppression

## Getting Help

If you're still having issues:

1. **Check the console logs** in both backend and frontend terminals
2. **Try the manual setup** instead of the automated scripts
3. **Test with a simple image first** before trying videos
4. **Check file permissions** in the project directory
5. **Restart your computer** (sometimes helps with PATH issues)

## Error Codes Reference

| Error Code | Meaning | Solution |
|------------|---------|----------|
| 400 | Bad request (file issue) | Check file format and size |
| 404 | Endpoint not found | Make sure backend is running on port 5000 |
| 500 | Server error | Check backend console for detailed error |
| CORS | Cross-origin blocked | Ensure both servers are running |
