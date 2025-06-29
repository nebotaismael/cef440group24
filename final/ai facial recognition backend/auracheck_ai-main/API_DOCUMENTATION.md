# AuraCheck Attendance API Documentation

## Base URL
```
https://auracheck-backend-ed233cba7e31.herokuapp.com
```

## Overview
The AuraCheck Attendance API provides secure face recognition-based attendance tracking with multi-factor authentication including liveness detection, location verification, and session management.

---

## Authentication
All endpoints (except login and health check) require Bearer token authentication.

### Headers
```
Authorization: Bearer <your_jwt_token>
Content-Type: multipart/form-data (for image uploads)
Content-Type: application/json (for JSON requests)
```

---

## Endpoints

### 1. Health Check
**GET** `/`

Check if the API is running.

**Response:**
```json
{
  "status": "ok",
  "message": "AuraCheck Attendance API is running",
  "timestamp": "2025-06-29T19:30:00.000000",
  "version": "1.0"
}
```

### 2. User Login
**POST** `/login`

Authenticate user and get JWT token.

**Authentication:** Basic Auth (username/password)

**Request Headers:**
```
Authorization: Basic <base64(email:matriculeOrStaffId)>
```

**Parameters:**
- `username`: User's email address
- `password`: User's matricule or staff ID

**Response (Success - 200):**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "expires_at": "2025-06-29T20:30:00.000000",
  "user": {
    "id": "BgW5oywH3obX1a75g4f3TUqrchm1",
    "email": "john.doe@ub.edu.cm",
    "name": "Prof. John Doe",
    "role": "UserRole.instructor",
    "matriculeOrStaffId": "INS002"
  }
}
```

**Response (Error - 401/404):**
```json
{
  "error": "User not found. Please register first."
}
```

### 3. Face Registration
**POST** `/attendance/register`

Register user's face for attendance verification.

**Authentication:** Bearer Token Required
**Content-Type:** multipart/form-data

**Parameters:**
- `image` (file): Face image (JPG, PNG, JPEG - max 10MB)

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Face registered successfully",
  "timestamp": "2025-06-29T19:30:00.000000"
}
```

**Response (Error - 400):**
```json
{
  "error": "No face detected in image"
}
```

### 4. Attendance Verification
**POST** `/attendance/verify`

Verify attendance with multi-factor authentication.

**Authentication:** Bearer Token Required
**Content-Type:** multipart/form-data
**User Role:** Must be 'student' or 'UserRole.student'

**Required Parameters:**
- `image` (file): Face image for verification
- `session_id` (string): Active session ID
- `latitude` (float): Current latitude
- `longitude` (float): Current longitude

**Optional Parameters:**
- `location_id` (string): Specific location identifier
- `pin_code` (string): Additional PIN verification
- `device_id` (string): Device identifier
- `authorized_locations` (JSON string): Array of authorized locations

**Authorized Locations Format:**
```json
[
  {
    "latitude": 3.848,
    "longitude": 11.502,
    "radius": 100,
    "name": "Main Campus"
  }
]
```

**Response (Success - 200):**
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
    },
    {
      "factor": "liveness",
      "verified": true,
      "confidence": 78.2
    },
    {
      "factor": "location",
      "verified": true,
      "message": "Within authorized radius of Main Campus (45.2m)"
    },
    {
      "factor": "pin_code",
      "verified": true
    }
  ]
}
```

**Response (Error - 400/403/500):**
```json
{
  "error": "Liveness check failed. Please ensure you are using a real face.",
  "verified": false
}
```

---

## Flutter Integration

### 1. Dependencies
Add these to your `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  image_picker: ^1.0.4
  geolocator: ^10.1.0
  permission_handler: ^11.0.1
  shared_preferences: ^2.2.2
```

### 2. API Service Class

```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class AuraCheckAPI {
  static const String baseUrl = 'https://auracheck-backend-ed233cba7e31.herokuapp.com';
  
  // Health Check
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // User Login
  static Future<Map<String, dynamic>> login(String email, String matricule) async {
    try {
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$email:$matricule'))}';
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }
  
  // Face Registration
  static Future<Map<String, dynamic>> registerFace(String token, File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/attendance/register'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Face registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }
  
  // Attendance Verification
  static Future<Map<String, dynamic>> verifyAttendance({
    required String token,
    required File imageFile,
    required String sessionId,
    required double latitude,
    required double longitude,
    String? locationId,
    String? pinCode,
    String? deviceId,
    List<Map<String, dynamic>>? authorizedLocations,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/attendance/verify'));
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add image
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      
      // Add required fields
      request.fields['session_id'] = sessionId;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      
      // Add optional fields
      if (locationId != null) request.fields['location_id'] = locationId;
      if (pinCode != null) request.fields['pin_code'] = pinCode;
      if (deviceId != null) request.fields['device_id'] = deviceId;
      if (authorizedLocations != null) {
        request.fields['authorized_locations'] = json.encode(authorizedLocations);
      }
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Attendance verification failed');
      }
    } catch (e) {
      throw Exception('Verification error: $e');
    }
  }
}
```

### 3. Example Usage

#### Login Example
```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController matriculeController = TextEditingController();
  bool isLoading = false;
  
  Future<void> handleLogin() async {
    setState(() => isLoading = true);
    
    try {
      final result = await AuraCheckAPI.login(
        emailController.text.trim(),
        matriculeController.text.trim(),
      );
      
      // Save token and user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', result['token']);
      await prefs.setString('user_data', json.encode(result['user']));
      
      // Navigate to main screen
      Navigator.pushReplacementNamed(context, '/dashboard');
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
    
    setState(() => isLoading = false);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AuraCheck Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: matriculeController,
              decoration: InputDecoration(labelText: 'Matricule/Staff ID'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : handleLogin,
              child: isLoading 
                ? CircularProgressIndicator() 
                : Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Face Registration Example
```dart
class FaceRegistrationScreen extends StatefulWidget {
  @override
  _FaceRegistrationScreenState createState() => _FaceRegistrationScreenState();
}

class _FaceRegistrationScreenState extends State<FaceRegistrationScreen> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool isUploading = false;
  
  Future<void> captureImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }
  
  Future<void> registerFace() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please capture an image first')),
      );
      return;
    }
    
    setState(() => isUploading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) throw Exception('Not authenticated');
      
      final result = await AuraCheckAPI.registerFace(token, selectedImage!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      
      Navigator.pop(context);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
    
    setState(() => isUploading = false);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Face')),
      body: Column(
        children: [
          if (selectedImage != null)
            Container(
              height: 300,
              width: double.infinity,
              child: Image.file(selectedImage!, fit: BoxFit.cover),
            ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: captureImage,
                  child: Text('Capture Face Image'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isUploading ? null : registerFace,
                  child: isUploading 
                    ? CircularProgressIndicator() 
                    : Text('Register Face'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Attendance Verification Example
```dart
class AttendanceScreen extends StatefulWidget {
  final String sessionId;
  
  AttendanceScreen({required this.sessionId});
  
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final ImagePicker _picker = ImagePicker();
  File? capturedImage;
  Position? currentPosition;
  bool isVerifying = false;
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {});
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }
  
  Future<void> captureAndVerify() async {
    // Capture image
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
    );
    
    if (image == null) return;
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not available')),
      );
      return;
    }
    
    setState(() {
      capturedImage = File(image.path);
      isVerifying = true;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) throw Exception('Not authenticated');
      
      // Define authorized locations
      final authorizedLocations = [
        {
          'latitude': 3.848,
          'longitude': 11.502,
          'radius': 100,
          'name': 'Main Campus'
        }
      ];
      
      final result = await AuraCheckAPI.verifyAttendance(
        token: token,
        imageFile: capturedImage!,
        sessionId: widget.sessionId,
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
        authorizedLocations: authorizedLocations,
        deviceId: await _getDeviceId(),
      );
      
      _showVerificationResult(result);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e')),
      );
    }
    
    setState(() => isVerifying = false);
  }
  
  void _showVerificationResult(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result['verified'] ? 'Attendance Verified' : 'Verification Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attendance ID: ${result['attendance_id']}'),
            Text('Time: ${result['timestamp']}'),
            SizedBox(height: 10),
            Text('Verification Details:'),
            ...((result['verification_details'] as List).map((detail) => 
              Text('${detail['factor']}: ${detail['verified'] ? '✓' : '✗'}')
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  Future<String> _getDeviceId() async {
    // Implement device ID generation
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('device_id', deviceId);
    }
    return deviceId;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mark Attendance')),
      body: Column(
        children: [
          if (currentPosition != null)
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Location: ${currentPosition!.latitude.toStringAsFixed(6)}, '
                  '${currentPosition!.longitude.toStringAsFixed(6)}',
                ),
              ),
            ),
          if (capturedImage != null)
            Container(
              height: 300,
              margin: EdgeInsets.all(16),
              child: Image.file(capturedImage!, fit: BoxFit.cover),
            ),
          Spacer(),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: isVerifying ? null : captureAndVerify,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: isVerifying 
                ? CircularProgressIndicator() 
                : Text('Capture & Verify Attendance'),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Error Codes

| Status Code | Description |
|-------------|-------------|
| 200 | Success |
| 400 | Bad Request - Invalid parameters or failed validation |
| 401 | Unauthorized - Invalid or missing authentication |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - User or resource not found |
| 500 | Internal Server Error - Server-side error |

---

## Security Considerations

### 1. Token Management
- Store JWT tokens securely using Flutter's `flutter_secure_storage`
- Implement automatic token refresh
- Clear tokens on logout

### 2. Image Handling
- Compress images before upload to reduce bandwidth
- Validate image size and format on client side
- Clear temporary image files after upload

### 3. Location Privacy
- Request location permissions appropriately
- Only collect location when needed for attendance
- Inform users about location usage

### 4. Network Security
- Always use HTTPS for API calls
- Implement certificate pinning for production
- Handle network timeouts gracefully

---

## Best Practices

1. **Image Quality**: Ensure good lighting and clear face visibility for best results
2. **Location Accuracy**: Use high accuracy location settings for precise verification
3. **Error Handling**: Implement comprehensive error handling with user-friendly messages
4. **Offline Support**: Consider caching attendance data for offline scenarios
5. **Performance**: Optimize image sizes and implement proper loading states

---

## Testing

Use the provided test images (`abia.jpg`, `belowe.jpg`) in your project directory for testing face registration and verification workflows.

---

## Support

For issues or questions, refer to the application logs or contact the development team.
