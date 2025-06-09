import os
import uuid
from datetime import datetime, timedelta
import flask_cors
# Image processing & ML
from deepface import DeepFace
# Web framework
from flask import Flask, request, jsonify
from config import allowed_file, token_required, secure_save_file, cleanup_files, read_image, detect_faces, \
    extract_face_features, verify_location, generate_attendance_id

# Global variable for detector
detector_backend = "retinaface"  # Changed from dlib to retinaface

# Storage
import firebase_admin
from firebase_admin import credentials, firestore, storage
# Authentication & security
import jwt
from cryptography.fernet import Fernet
import bcrypt
from livenesschech import Config, check_liveness, logger

# Initialize application
app = Flask(__name__)
# Add CORS support for production
flask_cors.CORS(app)
logger.info("Checking start")
os.makedirs(Config.TEMP_FOLDER, exist_ok=True)

# Initialize security
encryption_key = os.getenv('ENCRYPTION_KEY', Fernet.generate_key())
cipher_suite = Fernet(encryption_key)

# Initialize Firebase
try:
    # Check if credentials are provided as JSON string in environment variable
    cred_json = os.getenv('FIREBASE_CREDENTIALS_JSON')
    if cred_json:
        import json

        try:
            # Try to parse as JSON string
            cred_dict = json.loads(cred_json)
            cred = credentials.Certificate(cred_dict)
            logger.info("Using Firebase credentials from environment variable")
        except json.JSONDecodeError:
            # If it's not valid JSON, try as a file path
            logger.warning("Failed to parse FIREBASE_CREDENTIALS_JSON as JSON, trying as file")
            cred = credentials.Certificate(cred_json)
    else:
        # Fall back to file-based credentials
        logger.info("Using Firebase credentials from file")
        cred = credentials.Certificate(Config.FIREBASE_CRED_PATH)

    firebase_admin.initialize_app(cred, {
        'storageBucket': "powerub-795a1.appspot.com"
    })

    # Initialize Firestore and Storage
    db = firestore.client()
    bucket = storage.bucket()
    logger.info("Firebase services initialized successfully")
except Exception as e:
    logger.error(f"Failed to initialize Firebase: {e}")
    raise


@app.route('/login', methods=['POST'])
def login():
    """User login to get authentication token. Creates user if not exists (for testing)."""
    auth = request.authorization
    logger.info(f"Logging with credentials: {auth.username} {auth.password} {auth}")
    if not auth or not auth.username or not auth.password:
        return jsonify({'error': 'Missing credentials'}), 401

    try:
        # Get user from Firestore
        user_ref = db.collection('users').document(auth.username)
        user = user_ref.get()
        user_data = {}  # Initialize user_data

        if not user.exists:
            # User not found in database - fail the login
            logger.warning(f"Login attempt for non-existent user: {auth.username}")
            return jsonify({'error': 'User not found. Please register first.'}), 404
        else:
            user_data = user.to_dict()
            # Check password (assuming passwords are stored as bcrypt hashes)
            if 'password' not in user_data or  auth.password !=user_data['password']:
                logger.warning(f"Failed login attempt for user: {auth.username}")
                return jsonify({'error': 'Invalid credentials'}), 401

        # Generate token
        token_expiry = datetime.utcnow() + timedelta(seconds=Config.JWT_EXPIRATION)  # Corrected datetime usage
        token = jwt.encode(
            {
                'id': auth.username,
                'name': user_data.get('fullName', ''),
                'exp': token_expiry
            },
            Config.JWT_SECRET,
            algorithm="HS256"
        )
        return jsonify({
            'token': token,
            'expires_at': token_expiry.isoformat(),
            'user': {
                'id': auth.username,
                'name': user_data.get('fullName', '')
            }
        })
    except Exception as e:
        logger.error(f"Login error: {e}")
        return jsonify({'error': 'Authentication failed'}), 500

@app.route('/attendance/register', methods=['POST'])
@token_required
def register_face():
    """Register a user's face for future attendance verification"""
    if 'image' not in request.files:
        return jsonify({'error': 'No image file provided'}), 400

    user_id = request.user['id']
    file = request.files['image']
    if not allowed_file(file.filename):
        return jsonify({'error': 'Invalid file type'}), 400

    try:
        # Save and process the image
        file_path = secure_save_file(file)
        if not file_path:
            return jsonify({'error': 'Failed to save image'}), 500

        image = read_image(file_path)
        if image is None:
            return jsonify({'error': 'Failed to read image'}), 400

        # Detect face
        faces, _ = detect_faces(image)
        if len(faces) == 0:
            return jsonify({'error': 'No face detected in image'}), 400
        if len(faces) > 1:
            return jsonify({'error': 'Multiple faces detected, please provide an image with only your face'}), 400

        # Check liveness
        face_img = extract_face_features(image, faces[0])
        is_live, liveness_score = check_liveness(face_img)

        if not is_live:
            logger.warning(f"Liveness check failed for user {user_id}: score {liveness_score:.4f}")
            return jsonify({'error': 'Liveness check failed. Please ensure you are using a real face.'}), 400

        # Store the reference image in Firebase Storage
        timestamp = datetime.utcnow()
        image_path = f"reference_faces/{user_id}/{timestamp.strftime('%Y%m%d_%H%M%S')}.jpg"
        blob = bucket.blob(image_path)

        # Upload the image
        with open(file_path, 'rb') as img_file:
            blob.upload_from_file(img_file)

        # Create/update user face profile in Firestore
        db.collection('users').document(user_id).set({
            'reference_face': image_path,
            'reference_face_updated': timestamp,
            'liveness_score': liveness_score,
            'hasFacialTemplate': True,
            'updatedAt': timestamp
        }, merge=True)

        # Cleanup
        cleanup_files([file_path])

        return jsonify({
            'status': 'success',
            'message': 'Face registered successfully',
            'timestamp': timestamp.isoformat()
        }), 200

    except Exception as e:
        logger.error(f"Error in face registration: {e}")
        return jsonify({'error': f'Registration failed: {str(e)}'}), 500

@app.route('/attendance/verify', methods=['POST'])
@token_required
def verify_attendance():
    """Complete attendance verification with multi-factor authentication"""
    user_id = request.user['id']

    # Required fields
    if 'image' not in request.files:
        return jsonify({'error': 'No image file provided'}), 400

    # Get location information
    latitude = request.form.get('latitude', type=float)
    longitude = request.form.get('longitude', type=float)
    location_id = request.form.get('location_id')
    # Get authorized locations from request
    authorized_locations = []
    # Get additional validation factors
    pin_code = request.form.get('pin_code')
    device_id = request.form.get('device_id')

    # Option 1: Parse from JSON field
    if 'authorized_locations' in request.form:
        try:
            import json
            authorized_locations = json.loads(request.form.get('authorized_locations'))
        except Exception as e:
            logger.warning(f"Failed to parse authorized_locations JSON: {e}")

    # Option 2: Support single location for backward compatibility
    elif 'auth_latitude' in request.form and 'auth_longitude' in request.form:
        authorized_locations.append({
            'latitude': request.form.get('auth_latitude', type=float),
            'longitude': request.form.get('auth_longitude', type=float),
            'radius': request.form.get('auth_radius', type=float, default=Config.ALLOWED_LOCATION_RADIUS),
            'name': request.form.get('auth_name', 'Verification point')
        })
    # Processing starts
    temp_files = []
    try:
        # 1. Process and validate the verification image
        file = request.files['image']
        file_path = secure_save_file(file)
        temp_files.append(file_path)

        if not file_path:
            return jsonify({'error': 'Failed to save image'}), 500

        verification_image = read_image(file_path)
        if verification_image is None:
            return jsonify({'error': 'Failed to read image'}), 400

        # 2. Face detection
        faces, _ = detect_faces(verification_image)
        if len(faces) == 0:
            return jsonify({'error': 'No face detected in verification image'}), 400
        if len(faces) > 1:
            return jsonify({'error': 'Multiple faces detected, please provide a clear image with only your face'}), 400

        # 3. Liveness detection (anti-spoofing)
        face_img = extract_face_features(verification_image, faces[0])
        is_live, liveness_score = check_liveness(face_img)
        # Convert to native Python types
        is_live = bool(is_live)
        liveness_score = float(liveness_score)

        if not is_live:
            logger.warning(f"Liveness check failed during verification for user {user_id}: score {liveness_score:.4f}")
            # Log the attempt as potentially fraudulent
            db.collection('security_events').add({
                'user_id': user_id,
                'event_type': 'liveness_check_failed',
                'timestamp': datetime.utcnow(),
                'liveness_score': liveness_score,
                'device_id': device_id,
                'latitude': float(latitude) if latitude else None,
                'longitude': float(longitude) if longitude else None
            })
            return jsonify({
                'error': 'Liveness check failed. Please ensure you are using a real face.',
                'verified': False,
            }), 400

        # 4. Get the user's reference face from Firestore
        user_ref = db.collection('users').document(user_id)
        user_doc = user_ref.get()

        if not user_doc.exists:
            return jsonify({'error': 'User profile not found'}), 404

        user_data = user_doc.to_dict()
        if 'reference_face' not in user_data:
            return jsonify({'error': 'No reference face registered for this user'}), 400

        # 5. Download reference image from Firebase Storage
        reference_blob = bucket.blob(user_data['reference_face'])
        reference_path = os.path.join(Config.TEMP_FOLDER, f"ref_{user_id}_{uuid.uuid4().hex}.jpg")
        reference_blob.download_to_filename(reference_path)
        temp_files.append(reference_path)

        reference_image = read_image(reference_path)
        if reference_image is None:
            return jsonify({'error': 'Failed to read reference image'}), 500

        # 6. Face comparison using DeepFace - UPDATED TO USE RETINAFACE INSTEAD OF DLIB
        try:
            result = DeepFace.verify(
                face_img,
                reference_image,
                model_name="VGG-Face",
                enforce_detection=False,
                threshold=Config.FACE_MATCH_THRESHOLD,
                detector_backend=detector_backend  # Using retinaface or mediapipe instead of dlib
            )
            # Convert NumPy types to Python native types
            face_match = bool(result.get("verified", False))
            face_distance = float(result.get("distance", 1.0))
            face_match_confidence = float(max(0, min(100, 100 * (1 - face_distance / 2))))

        except Exception as e:
            logger.error(f"Face verification error: {e}")
            return jsonify({'error': f'Face verification failed: {str(e)}'}), 500


        # 7. Location verification
        location_verified, location_message = verify_location(latitude, longitude, authorized_locations)
        location_verified = bool(location_verified)  # Ensure Python native boolean

        # 8. Optional PIN verification
        pin_verified = False
        if pin_code:
            stored_pin_hash = user_data.get('pin_hash')
            if stored_pin_hash:
                pin_verified = bool(bcrypt.checkpw(pin_code.encode(), stored_pin_hash.encode()))

        # 9. Compile verification results
        timestamp = datetime.utcnow()
        attendance_id = generate_attendance_id(user_id, timestamp)

        # Get sessionId from request (required for new structure)
        session_id = request.form.get('session_id')
        if not session_id:
            return jsonify({'error': 'session_id is required for attendance verification'}), 400

        # Determine overall verification status with native Python types
        verification_factors = [
            {
                "factor": "face_recognition",
                "verified": bool(face_match),
                "confidence": float(face_match_confidence)
            },
            {
                "factor": "liveness",
                "verified": bool(is_live),
                "confidence": float(liveness_score * 100)
            },
            {
                "factor": "location",
                "verified": bool(location_verified),
                "message": location_message
            }
        ]

        if pin_code:
            verification_factors.append({
                "factor": "pin_code",
                "verified": bool(pin_verified)
            })

        # Calculate overall verification status
        verified = bool(face_match and is_live and location_verified)
        if pin_code:
            verified = bool(verified and pin_verified)

        # 10. Store attendance record with new structure
        attendance_record = {
            'id': attendance_id,
            'studentId': user_id,
            'sessionId': session_id,
            'status': 'present' if verified else 'absent',
            'checkInTimestamp': timestamp if verified else None,
            'overrideJustification': None,
            'overrideBy': None,
            'isOverridden': False,
            'createdAt': timestamp,
            'updatedAt': timestamp,
            # Keep legacy fields for backward compatibility
            'verification_factors': verification_factors,
            'face_distance': float(face_distance),
            'device_id': device_id,
            'location': {
                'latitude': float(latitude) if latitude else None,
                'longitude': float(longitude) if longitude else None,
                'location_id': location_id,
                'verified': bool(location_verified),
                'message': location_message
            }
        }

        # Store record in Firestore
        db.collection('attendance_record').document(attendance_id).set(attendance_record)

        # 11. Update user's attendance history
        user_ref.collection('attendance_history').add({
            'attendance_id': attendance_id,
            'timestamp': timestamp,
            'verified': bool(verified),
            'location_verified': bool(location_verified)
        })

        # 12. Create appropriate response
        response = {
            'attendance_id': attendance_id,
            'timestamp': timestamp.isoformat(),
            'verified': bool(verified),
            'verification_details': verification_factors
        }

        # 13. Cleanup temporary files
        cleanup_files(temp_files)

        return jsonify(response), 200

    except Exception as e:
        logger.error(f"Attendance verification error: {e}")
        # Ensure cleanup happens even on error
        cleanup_files(temp_files)
        return jsonify({'error': f'Attendance verification failed: {str(e)}'}), 500

if __name__ == '__main__':
    # Use PORT environment variable provided by Heroku
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)