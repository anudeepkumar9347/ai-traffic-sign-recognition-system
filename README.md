# 🚦 AI Traffic Sign Recognition System

A complete full-stack application that uses artificial intelligence to detect and recognize traffic signs from dashcam images and videos. The system provides a user-friendly web interface for uploading media files and displays detailed analysis results.

## 🚀 **ULTIMATE QUICK START** ⚡

**One command to rule them all!**

```bash
# Windows
.\run.bat

# macOS/Linux
chmod +x run.sh && ./run.sh
```

These launchers will:
- ✅ Check all prerequisites (Python, Node.js)
- 🔧 Set up virtual environment & install packages
- 🚀 Start both backend (5000) and frontend (3000)
- 🌐 Open your browser automatically
- 📊 Show beautiful status dashboard
- ❌ Display helpful errors if something goes wrong

## 🌟 Features

- **Multi-format Support**: Upload images (JPEG, PNG, GIF, BMP) or videos (MP4, AVI, MOV, WMV, FLV, WebM)
- **Real-time Analysis**: AI-powered traffic sign detection and recognition
- **Interactive Web Interface**: Drag-and-drop file upload with live preview
- **Comprehensive Results**: Detailed information about detected signs including confidence levels and positions
- **Video Processing**: Frame-by-frame analysis of dashcam videos
- **REST API**: Backend API for integration with other applications

## 🏗️ Architecture

```
AI Traffic Sign Recognition System/
│
├── frontend/                 # React.js web application
│   ├── src/
│   │   ├── App.js           # Main application component
│   │   ├── index.js         # Application entry point
│   │   └── index.css        # Styling
│   ├── public/
│   └── package.json
│
├── backend/                  # Python Flask API server
│   ├── app.py               # Main Flask application
│   ├── models/
│   │   └── traffic_sign_detector.py  # AI detection logic
│   ├── utils/
│   │   └── file_handler.py  # File processing utilities
│   └── requirements.txt
│
├── uploads/                  # Temporary file storage
├── models/                   # AI model storage
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- **Python 3.8+** with pip
- **Node.js 16+** with npm (Download from [nodejs.org](https://nodejs.org/))
- **Git** (for cloning)

**Note**: If you're using Python 3.13, some packages might have compatibility issues. Python 3.11 or 3.12 is recommended.

### Installation

1. **Prerequisites**:
   - **Python 3.8+** - Download from [python.org](https://www.python.org/)
   - **Node.js 16+** - Download from [nodejs.org](https://nodejs.org/)

2. Open a terminal in the project folder and run one of the launchers above.

### Manual Setup

If you prefer manual setup:

1. **Setup Backend**:
   ```bash
   cd backend
   python -m venv venv
   
   # Windows
   venv\Scripts\activate
   
   # macOS/Linux  
   source venv/bin/activate
   
   pip install -r requirements.txt
   ```

2. **Setup Frontend**:
   ```bash
   cd frontend
   npm install
   ```

## 🏃‍♂️ Running the Application

### Option 1: Use the start scripts (easiest)

Use the top-level `run.bat` (Windows) or `run.sh` (macOS/Linux) to start both services automatically.

### Option 2: Manual startup

1. **Start the Backend Server**:
   
   **Windows:**
   ```cmd
   cd backend
   venv\Scripts\activate
   python app.py
   ```
   
   **macOS/Linux:**
   ```bash
   cd backend
   source venv/bin/activate
   python app.py
   ```
   The API will be available at `http://localhost:5000`

2. **Start the Frontend** (in a new terminal):
   ```bash
   cd frontend
   npm start
   ```
   The web application will open at `http://localhost:3000`

## 💻 Usage

1. **Open your browser** and go to `http://localhost:3000`

2. **Upload a file**:
   - Drag and drop an image or video file onto the upload area
   - Or click the upload area to select a file
   - Supported formats: JPEG, PNG, GIF, BMP, MP4, AVI, MOV, WMV, FLV, WebM

3. **Analyze the file**:
   - Click the "Analyze for Traffic Signs" button
   - Wait for the AI processing to complete

4. **View results**:
   - See detected traffic signs with confidence levels
   - View bounding box coordinates for each detection
   - For videos, see frame-by-frame analysis results

## 🤖 Supported Traffic Signs

The system can detect and classify the following traffic signs:

- **Regulatory Signs**: Stop, Yield, No Entry, No Parking, One Way
- **Speed Limits**: 30, 50, 60, 70, 80 km/h
- **Directional**: Turn Left/Right, No Turn Left/Right
- **Warning Signs**: Pedestrian Crossing, School Zone, Construction
- **General**: Warning signs and other traffic indicators

## 🔧 API Endpoints

### Health Check
```
GET /api/health
```
Returns the API status and version information.

### Analyze File
```
POST /api/analyze
```
Upload and analyze an image or video file.

**Request**: Multipart form data with `file` field
**Response**: JSON with detection results

### Supported Signs
```
GET /api/supported-signs
```
Returns list of all supported traffic sign types.

## 🧠 AI Model Details

The system uses multiple detection approaches:

1. **Primary**: YOLOv8 (You Only Look Once) neural network
   - Pre-trained model for general object detection
   - Custom model support for traffic sign-specific training

2. **Fallback**: OpenCV computer vision
   - Color-based detection (red stop signs)
   - Shape-based detection (triangular warnings, rectangular speed limits)
   - Contour analysis for sign classification

## 📁 File Processing

- **Maximum file size**: 100MB
- **Image processing**: Direct analysis of uploaded images
- **Video processing**: Frame extraction (every 30th frame) for efficient analysis
- **Automatic cleanup**: Temporary files are removed after processing

## 🔧 Configuration

### Backend Configuration (in `app.py`)
- Upload folder location
- Maximum file size
- Allowed file extensions
- CORS settings

### Frontend Configuration (in `package.json`)
- Proxy settings for API communication
- Build configuration
- Dependencies

## 🛠️ Development

### Adding New Traffic Signs

1. Update the `sign_classes` dictionary in `traffic_sign_detector.py`
2. Add detection logic for the new sign type
3. Train a custom YOLO model if needed
4. Update the supported signs list

### Improving Detection Accuracy

1. **Train a custom YOLO model**:
   - Collect traffic sign dataset
   - Annotate images with bounding boxes
   - Train YOLOv8 on your dataset
   - Place the trained model in `/models/traffic_signs.pt`

2. **Enhance OpenCV detection**:
   - Add more color ranges for different sign colors
   - Improve shape detection algorithms
   - Add template matching for specific signs

### Frontend Customization

- Modify `src/App.js` for UI changes
- Update `src/index.css` for styling
- Add new components in `src/components/` (create this directory)

## 🐛 Troubleshooting

### Common Issues

1. **"Module not found" errors**:
   - Ensure virtual environment is activated
   - Run `pip install -r requirements.txt` again

2. **CORS errors**:
   - Make sure both frontend and backend are running
   - Check that proxy is configured in `package.json`

3. **File upload fails**:
   - Check file size (max 100MB)
   - Verify file format is supported
   - Ensure uploads directory exists and is writable

4. **Poor detection accuracy**:
   - The system uses a general YOLO model by default
   - For better accuracy, train a custom model on traffic sign data
   - Ensure good image quality and lighting

### Performance Optimization

- For large videos, consider increasing frame skip rate
- Implement GPU acceleration for YOLO inference
- Add caching for repeated file analysis
- Implement background job processing for large files

## 📝 License

This project is open source and available under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📞 Support

For issues and questions:
1. Check the troubleshooting section above
2. Review the code comments for implementation details
3. Create an issue in the project repository

---

**Note**: This system is designed for educational and development purposes. For production use in safety-critical applications, additional validation and testing would be required.
