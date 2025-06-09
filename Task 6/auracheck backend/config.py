import hashlib
import os
import uuid
from functools import wraps

import cv2
import jwt
import mediapipe as mp
from flask import request, jsonify
from geopy.distance import geodesic
from werkzeug.utils import secure_filename

from livenesschech import Config, logger


def verify_location(lat, lng, authorized_locations=None):
    """Verify if the user is at any of the authorized locations"""
    if not lat or not lng:
        return False, "Missing location data"

    if not authorized_locations or len(authorized_locations) == 0:
        return False, "No authorized locations provided"

    # Check against all provided authorized locations
    for loc in authorized_locations:
        auth_lat = loc.get('latitude')
        auth_lng = loc.get('longitude')
        allowed_radius = loc.get('radius', Config.ALLOWED_LOCATION_RADIUS)
        loc_name = loc.get('name', 'Unnamed location')

        if not auth_lat or not auth_lng:
            continue  # Skip invalid locations

        # Calculate distance
        authorized_coords = (auth_lat, auth_lng)
        current_coords = (lat, lng)
        distance = geodesic(authorized_coords, current_coords).meters

        if distance <= allowed_radius:
            return True, f"Within authorized radius of {loc_name} ({distance:.1f}m)"

    return False, "Not near any authorized location"



# Security middleware
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            logger.warning("Missing authentication token")
            return jsonify({'error': 'Authentication token is required'}), 401

        try:
            token = token.split("Bearer ")[1]
            data = jwt.decode(token, Config.JWT_SECRET, algorithms=["HS256"])
            request.user = data  # Add user data to request
        except Exception as e:
            logger.warning(f"Invalid token: {e}")
            return jsonify({'error': 'Invalid or expired token'}), 401

        return f(*args, **kwargs)

    return decorated


# Helper functions
def allowed_file(filename):
    """Check if the file has an allowed extension"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in Config.ALLOWED_IMAGE_EXTENSIONS


def secure_save_file(file):
    """Securely save uploaded file with sanitized filename"""
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        # Add random component to prevent filename collisions
        unique_filename = f"{uuid.uuid4().hex}_{filename}"
        file_path = os.path.join(Config.TEMP_FOLDER, unique_filename)
        file.save(file_path)
        return file_path
    return None

def generate_attendance_id(user_id, timestamp):
    """Generate a unique attendance ID based on user and time"""
    str_to_hash = f"{user_id}-{timestamp.isoformat()}"
    return hashlib.sha256(str_to_hash.encode()).hexdigest()[:20]


def cleanup_files(file_paths):
    """Remove temporary files after processing"""
    for path in file_paths:
        if path and os.path.exists(path):
            try:
                os.remove(path)
                logger.debug(f"Removed temporary file: {path}")
            except Exception as e:
                logger.warning(f"Failed to remove temporary file {path}: {e}")


# Face detection with MediaPipe
mp_face_detection = mp.solutions.face_detection
face_detection = mp_face_detection.FaceDetection(
    model_selection=1,  # 0 for close range, 1 for mid/long range
    min_detection_confidence=0.5
)

# For face mesh (used in liveness check)
mp_face_mesh = mp.solutions.face_mesh
face_mesh = mp_face_mesh.FaceMesh(
    static_image_mode=True,
    max_num_faces=1,
    min_detection_confidence=0.5
)



def read_image(file_path):
    """Read image from file path using OpenCV"""
    image = cv2.imread(file_path)
    return image


# REPLACED DLIB-BASED FACE DETECTION WITH MEDIAPIPE
def detect_faces(image):
    """Detect faces in an image using MediaPipe"""
    # Convert to RGB (MediaPipe requires RGB)
    rgb_image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    results = face_detection.process(rgb_image)
    faces = []

    if results.detections:
        h, w, _ = image.shape
        for detection in results.detections:
            # Extract bounding box
            bbox = detection.location_data.relative_bounding_box
            x, y = int(bbox.xmin * w), int(bbox.ymin * h)
            width, height = int(bbox.width * w), int(bbox.height * h)

            # Store face as x1, y1, x2, y2 format (like dlib rect)
            faces.append((x, y, x + width, y + height))

    return faces, image


# UPDATED TO WORK WITH NEW FACE DETECTION OUTPUT
def extract_face_features(image, face_rect):
    """Extract face area and compute features"""
    x1, y1, x2, y2 = face_rect
    # Add padding to the face region
    h, w, _ = image.shape
    padding_x = int((x2 - x1) * 0.3)
    padding_y = int((y2 - y1) * 0.3)
    face_img = image[max(0, y1 - padding_y):min(h, y2 + padding_y),
               max(0, x1 - padding_x):min(w, x2 + padding_x)]
    return face_img