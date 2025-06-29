# AuraCheck Attendance API 🎯

A robust face recognition-based attendance system with liveness detection, location verification, and multi-factor authentication.

## 🚀 Features

- **Face Recognition**: Advanced face detection and verification using DeepFace
- **Liveness Detection**: Anti-spoofing protection with multi-factor analysis
- **Location Verification**: GPS-based attendance location validation
- **Session Management**: Integration with course sessions and enrollments
- **Role-based Access**: Student/instructor role management
- **Firebase Integration**: Secure cloud storage and user management

## 📋 Quick Start

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Health check |
| `/login` | POST | User authentication |
| `/attendance/register` | POST | Register face template |
| `/attendance/verify` | POST | Verify attendance |

### Base URL
```
https://auracheck-backend-ed233cba7e31.herokuapp.com
```

## 📚 Documentation

- **[API Documentation](./API_DOCUMENTATION.md)** - Complete API reference
- **[Flutter Integration Guide](./FLUTTER_INTEGRATION.md)** - Flutter SDK and examples
- **[Postman Collection](./AuraCheck_API.postman_collection.json)** - Ready-to-use API tests

## 🛠️ Technology Stack

- **Backend**: Python Flask
- **Face Recognition**: DeepFace + RetinaFace
- **Liveness Detection**: MediaPipe + Custom algorithms
- **Database**: Firebase Firestore
- **Storage**: Firebase Storage
- **Deployment**: Heroku

## 🔧 Configuration

### Environment Variables
```bash
JWT_SECRET=your_secret_key
FIREBASE_CREDENTIALS_JSON=path_to_firebase_json
DEEPFACE_HOME=models
```

### Firebase Collections
- `users` - User profiles and authentication
- `sessions` - Course sessions
- `attendance` - Attendance records
- `enrollments` - Student course enrollments

## 📱 Flutter Integration

### Add Dependencies
```yaml
dependencies:
  http: ^1.1.0
  image_picker: ^1.0.4
  geolocator: ^10.1.0
  permission_handler: ^11.0.1
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
```

### Basic Usage
```dart
// Login
final response = await AuraCheckAPI.login(email, matricule);

// Register Face
final result = await AuraCheckAPI.registerFace(imageFile);

// Verify Attendance
final verification = await AuraCheckAPI.verifyAttendance(
  imageFile: image,
  sessionId: sessionId,
  latitude: lat,
  longitude: lng,
);
```

## 🧪 Testing

### Using Test Images
- `abia.jpg` - Sample face image 1
- `belowe.jpg` - Sample face image 2

### Test User Credentials
- Email: `john.doe@ub.edu.cm`
- Matricule: `INS002`

### Postman Testing
1. Import `AuraCheck_API.postman_collection.json`
2. Test login endpoint first to get auth token
3. Use token for protected endpoints

## 🔒 Security Features

- JWT token authentication
- Face liveness detection
- Location-based verification
- Role-based access control
- Secure image processing
- Anti-spoofing protection

## 📊 Response Format

### Success Response
```json
{
  "attendance_id": "a1b2c3d4e5f6g7h8i9j0",
  "timestamp": "2025-06-29T19:30:00.000000",
  "verified": true,
  "verification_details": [
    {
      "factor": "face_recognition",
      "verified": true,
      "confidence": 95.5
    }
  ]
}
```

### Error Response
```json
{
  "error": "Liveness check failed. Please ensure you are using a real face."
}
```

## 🚀 Deployment

The API is deployed on Heroku with:
- Docker containerization
- Gunicorn WSGI server
- Automatic scaling
- Health monitoring

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Test with provided examples
4. Submit pull request

## 📞 Support

For integration support or issues:
- Check the documentation files
- Test with Postman collection
- Review Flutter integration examples

---

**Built with ❤️ for secure attendance management**
