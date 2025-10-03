from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import time
from werkzeug.utils import secure_filename
from models.traffic_sign_detector import TrafficSignDetector

app = Flask(__name__)
CORS(app)

# Configuration
UPLOAD_FOLDER = '../uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'bmp', 'mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'}
MAX_CONTENT_LENGTH = 100 * 1024 * 1024  # 100MB max file size

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = MAX_CONTENT_LENGTH

# Ensure upload directory exists
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Initialize the traffic sign detector
detector = TrafficSignDetector()

def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'message': 'Traffic Sign Recognition API is running',
        'version': '1.0.0'
    })

@app.route('/api/analyze', methods=['POST'])
def analyze_file():
    """Main endpoint for analyzing uploaded files"""
    try:
        start_time = time.time()
        
        # Check if file is present
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        
        # Check if file is selected
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        # Check file extension
        if not allowed_file(file.filename):
            return jsonify({'error': 'File type not supported'}), 400
        
        # Peek file type by filename first
        filename = secure_filename(file.filename)
        ext = filename.rsplit('.', 1)[1].lower()

        try:
            # For images, process in-memory to avoid disk I/O
            if ext in {'png', 'jpg', 'jpeg', 'gif', 'bmp'}:
                import numpy as np
                import cv2

                file_bytes = np.frombuffer(file.read(), dtype=np.uint8)
                image = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)
                if image is None:
                    return jsonify({'error': 'Invalid image data'}), 400

                # Downscale very large images to max 1280px longest side
                h, w = image.shape[:2]
                max_side = max(h, w)
                if max_side > 1280:
                    scale = 1280.0 / max_side
                    new_size = (int(w * scale), int(h * scale))
                    image = cv2.resize(image, new_size, interpolation=cv2.INTER_AREA)

                detections = detector.detect_signs_in_image(image)
                file_type = 'image'

            # For videos, save to disk temporarily (OpenCV VideoCapture needs a path)
            elif ext in {'mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'}:
                timestamp = str(int(time.time()))
                safe_name = f"{timestamp}_{filename}"
                filepath = os.path.join(app.config['UPLOAD_FOLDER'], safe_name)
                file.save(filepath)
                detections = detector.detect_signs_in_video(filepath)
                file_type = 'video'
                # Clean up uploaded video file
                if os.path.exists(filepath):
                    os.remove(filepath)
            else:
                return jsonify({'error': 'Unsupported file format'}), 400
            
            processing_time = time.time() - start_time
            
            return jsonify({
                'detections': detections,
                'processing_time': processing_time,
                'file_type': file_type,
                'message': f'Analyzed {len(detections)} traffic signs'
            })
            
        except Exception as e:
            raise e
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/supported-signs', methods=['GET'])
def get_supported_signs():
    """Get list of supported traffic signs"""
    supported_signs = detector.get_supported_signs()
    return jsonify({
        'supported_signs': supported_signs,
        'total_count': len(supported_signs)
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
