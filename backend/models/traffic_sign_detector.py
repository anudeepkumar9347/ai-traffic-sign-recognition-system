import cv2
import numpy as np
import os

class TrafficSignDetector:
    def __init__(self):
        """Initialize the traffic sign detector with OpenCV"""
        self.model = None
        self.detection_enabled = True
        
        # Traffic sign classifications with descriptions
        self.sign_classes = {
            'stop': 'Stop Sign - Come to a complete stop',
            'yield': 'Yield Sign - Give right of way to other traffic',
            'speed_limit_30': 'Speed Limit 30 km/h',
            'speed_limit_50': 'Speed Limit 50 km/h',
            'speed_limit_60': 'Speed Limit 60 km/h',
            'speed_limit_70': 'Speed Limit 70 km/h',
            'speed_limit_80': 'Speed Limit 80 km/h',
            'no_entry': 'No Entry - Do not enter',
            'no_parking': 'No Parking Zone',
            'one_way': 'One Way Street',
            'turn_left': 'Turn Left Only',
            'turn_right': 'Turn Right Only',
            'no_turn_left': 'No Left Turn',
            'no_turn_right': 'No Right Turn',
            'pedestrian_crossing': 'Pedestrian Crossing Ahead',
            'school_zone': 'School Zone - Reduce Speed',
            'construction': 'Construction Zone Ahead',
            'warning': 'General Warning Sign'
        }
    
    def load_model(self):
        """Load detection models - currently using OpenCV only"""
        try:
            # For now, we'll use OpenCV-based detection
            # In the future, you can add YOLO or other ML models here
            print("Traffic sign detector initialized with OpenCV")
            self.detection_enabled = True
        except Exception as e:
            print(f"Error initializing detector: {e}")
            self.detection_enabled = False
    
    def detect_signs_in_image(self, image_or_path):
        """Detect traffic signs in a single image.
        Accepts either a numpy ndarray (BGR image) or a filesystem path.
        """
        try:
            return self._detect_with_opencv(image_or_path)
        except Exception as e:
            print(f"Error detecting signs in image: {e}")
            return []
    
    def detect_signs_in_video(self, video_path):
        """Detect traffic signs in a video file"""
        detections = []
        cap = cv2.VideoCapture(video_path)
        frame_count = 0

        try:
            while True:
                ret, frame = cap.read()
                if not ret:
                    break

                # Process every 30th frame to reduce processing time
                if frame_count % 30 == 0:
                    # Detect signs in current frame (in-memory)
                    frame_detections = self._detect_with_opencv(frame)

                    # Add frame information to detections
                    for detection in frame_detections:
                        detection['frame'] = frame_count
                        detection['timestamp'] = frame_count / 30.0  # Assuming 30 FPS

                    detections.extend(frame_detections)

                frame_count += 1

        finally:
            cap.release()
        
        # Remove duplicate detections (same sign detected in consecutive frames)
        unique_detections = self._remove_duplicate_detections(detections)
        return unique_detections
    
    def _detect_with_yolo(self, image_path):
        """Placeholder for future YOLO implementation"""
        # This method can be implemented when YOLO is added
        return []
    
    def _detect_with_opencv(self, image_or_path):
        """Fallback detection using OpenCV (basic shape and color detection).
        Accepts a numpy ndarray (BGR) or a path string.
        """
        if isinstance(image_or_path, str):
            image = cv2.imread(image_or_path)
        else:
            image = image_or_path
        detections = []
        
        # Convert to HSV for better color detection
        hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
        
        # Detect red circular shapes (potential stop signs)
        red_detections = self._detect_red_circles(image, hsv)
        detections.extend(red_detections)
        
        # Detect triangular shapes (warning signs)
        triangle_detections = self._detect_triangles(image)
        detections.extend(triangle_detections)
        
        # Detect rectangular shapes (speed limit signs)
        rect_detections = self._detect_rectangles(image)
        detections.extend(rect_detections)
        
        return detections
    
    def _detect_red_circles(self, image, hsv):
        """Detect red circular shapes (stop signs)"""
        detections = []
        
        # Define range for red color
        lower_red1 = np.array([0, 120, 70])
        upper_red1 = np.array([10, 255, 255])
        lower_red2 = np.array([170, 120, 70])
        upper_red2 = np.array([180, 255, 255])
        
        # Create masks for red color
        mask1 = cv2.inRange(hsv, lower_red1, upper_red1)
        mask2 = cv2.inRange(hsv, lower_red2, upper_red2)
        mask = mask1 + mask2
        
        # Find contours
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        for contour in contours:
            area = cv2.contourArea(contour)
            if area > 1000:  # Filter small areas
                # Check if contour is roughly circular
                perimeter = cv2.arcLength(contour, True)
                circularity = 4 * np.pi * area / (perimeter * perimeter)
                
                if circularity > 0.6:  # Circular enough
                    x, y, w, h = cv2.boundingRect(contour)
                    detection = {
                        'sign_type': 'stop',
                        'description': self.sign_classes['stop'],
                        'confidence': 0.7,  # Moderate confidence for basic detection
                        'coordinates': {
                            'x': x,
                            'y': y,
                            'width': w,
                            'height': h
                        }
                    }
                    detections.append(detection)
        
        return detections
    
    def _detect_triangles(self, image):
        """Detect triangular shapes (warning signs)"""
        detections = []
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        edges = cv2.Canny(gray, 50, 150)
        
        contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        for contour in contours:
            area = cv2.contourArea(contour)
            if area > 1000:
                # Approximate contour to polygon
                epsilon = 0.02 * cv2.arcLength(contour, True)
                approx = cv2.approxPolyDP(contour, epsilon, True)
                
                # Check if it's a triangle
                if len(approx) == 3:
                    x, y, w, h = cv2.boundingRect(contour)
                    detection = {
                        'sign_type': 'warning',
                        'description': self.sign_classes['warning'],
                        'confidence': 0.6,
                        'coordinates': {
                            'x': x,
                            'y': y,
                            'width': w,
                            'height': h
                        }
                    }
                    detections.append(detection)
        
        return detections
    
    def _detect_rectangles(self, image):
        """Detect rectangular shapes (speed limit signs)"""
        detections = []
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        edges = cv2.Canny(gray, 50, 150)
        
        contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        for contour in contours:
            area = cv2.contourArea(contour)
            if area > 2000:
                # Approximate contour to polygon
                epsilon = 0.02 * cv2.arcLength(contour, True)
                approx = cv2.approxPolyDP(contour, epsilon, True)
                
                # Check if it's a rectangle
                if len(approx) == 4:
                    x, y, w, h = cv2.boundingRect(contour)
                    aspect_ratio = w / h
                    
                    # Speed limit signs are typically square-ish
                    if 0.8 <= aspect_ratio <= 1.2:
                        detection = {
                            'sign_type': 'speed_limit_50',  # Default assumption
                            'description': self.sign_classes['speed_limit_50'],
                            'confidence': 0.5,
                            'coordinates': {
                                'x': x,
                                'y': y,
                                'width': w,
                                'height': h
                            }
                        }
                        detections.append(detection)
        
        return detections
    
    def _map_class_to_sign(self, class_id):
        """Map YOLO class ID to traffic sign type"""
        # This mapping would depend on your trained model's classes
        # For now, using a basic mapping for common objects
        class_mapping = {
            0: 'warning',  # person (pedestrian warning)
            2: 'warning',  # car (traffic ahead)
            9: 'warning',  # traffic light
            11: 'stop',    # stop sign (if trained)
        }
        
        return class_mapping.get(class_id, 'warning')
    
    def _remove_duplicate_detections(self, detections):
        """Remove duplicate detections from video frames"""
        unique_detections = []
        
        for detection in detections:
            is_duplicate = False
            for unique in unique_detections:
                # Check if detections are similar (same type, similar position)
                if (detection['sign_type'] == unique['sign_type'] and
                    abs(detection['coordinates']['x'] - unique['coordinates']['x']) < 50 and
                    abs(detection['coordinates']['y'] - unique['coordinates']['y']) < 50):
                    is_duplicate = True
                    break
            
            if not is_duplicate:
                unique_detections.append(detection)
        
        return unique_detections
    
    def get_supported_signs(self):
        """Get list of supported traffic signs"""
        return list(self.sign_classes.keys())
