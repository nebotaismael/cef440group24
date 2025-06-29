# Attendance AI - Face Recognition Verification System

This project is an advanced attendance verification system that utilizes face recognition, liveness detection, and multi-factor authentication to ensure secure and accurate attendance tracking. The system is built using Flask with DeepFace integration and Firebase for backend services.

## Project Structure

```
attendanceapi/
├── application.py                   # Main Flask application with API endpoints
├── config.py                        # Configuration settings and utility functions
├── livenesschech.py                 # Liveness detection and anti-spoofing module
├── camera_interface.py              # Camera handling interface
├── test_api.py                      # API testing scripts
├── requirements.txt                 # Python dependencies
├── Dockerfile                       # Docker containerization
├── firebase.json                    # Firebase service account credentials
├── models/                          # Directory for ML model files
│   └── download_models.py           # Script to download required models
├── app_temp/                        # Temporary files directory
├── abia.jpg                         # Sample test images
├── belowe.jpg                       # Sample test images
└── README.md                        # Project documentation
```

## Features

- **Face Recognition**: Advanced facial recognition using DeepFace with VGG-Face model
- **Liveness Detection**: Anti-spoofing measures to prevent fraudulent attempts
- **Multi-Factor Authentication**: Combines face recognition, location verification, and optional PIN
- **Location Verification**: GPS-based attendance validation
- **Firebase Integration**: User management and data storage with Firestore
- **RESTful API**: Clean API endpoints for mobile app integration
- **Security**: JWT tokens, encryption, and comprehensive logging

## Setup Instructions

1. **Clone the Repository**:
   ```cmd
   git clone https://github.com/yourusername/attendanceapi.git
   cd attendanceapi
   ```

2. **Create a Virtual Environment** (recommended):
   ```cmd
   python -m venv venv
   venv\Scripts\activate
   ```

3. **Install Dependencies**:
   ```
   pip install -r requirements.txt
   ```

4. **Configure Environment Variables**:
   - Create a `.env` file in the root directory and add the following variables:
     ```
     JWT_SECRET=your_jwt_secret_key
     FIREBASE_CREDENTIALS_JSON=path/to/firebase.json_or_json_content
     ENCRYPTION_KEY=your_encryption_key
     PORT=5000
     ```

5. **Download or Train the Anti-Spoofing Model**:
   - If you do not have the `antispoofing_model.h5`, you can download a pre-trained model from a repository or website that provides anti-spoofing models. Alternatively, you can train your own model using a suitable dataset and save it as `antispoofing_model.h5` in the `models` directory.

6. **Run the Application**:
   ```
   python application.py
   ```

## Usage

- The application provides API endpoints for user authentication and attendance verification. You can interact with these endpoints using tools like Postman or cURL.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.