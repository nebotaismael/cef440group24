# Flutter Integration Guide for AuraCheck API

## Quick Start

### 1. Add Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  image_picker: ^1.0.4
  geolocator: ^10.1.0
  permission_handler: ^11.0.1
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  device_info_plus: ^10.1.0
```

### 2. Configure Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture attendance photos</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to verify attendance location</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select images</string>
```

### 3. Complete API Service Implementation

```dart
// lib/services/auracheck_api.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AuraCheckAPI {
  static const String baseUrl = 'https://auracheck-backend-ed233cba7e31.herokuapp.com';
  static const _storage = FlutterSecureStorage();
  
  // Error Classes
  static const int ERROR_NETWORK = 1000;
  static const int ERROR_AUTH = 1001;
  static const int ERROR_VALIDATION = 1002;
  static const int ERROR_SERVER = 1003;
  
  // Health Check
  static Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return ApiResponse.success(json.decode(response.body));
      } else {
        return ApiResponse.error('Health check failed', ERROR_SERVER);
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e', ERROR_NETWORK);
    }
  }
  
  // User Login
  static Future<ApiResponse<LoginResponse>> login(String email, String matricule) async {
    try {
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$email:$matricule'))}';
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final loginResponse = LoginResponse.fromJson(data);
        
        // Save token securely
        await _storage.write(key: 'auth_token', value: loginResponse.token);
        await _storage.write(key: 'user_data', value: json.encode(loginResponse.user.toJson()));
        
        return ApiResponse.success(loginResponse);
      } else {
        final error = json.decode(response.body);
        return ApiResponse.error(error['error'] ?? 'Login failed', ERROR_AUTH);
      }
    } catch (e) {
      return ApiResponse.error('Login error: $e', ERROR_NETWORK);
    }
  }
  
  // Get stored token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  // Logout
  static Future<void> logout() async {
    await _storage.deleteAll();
  }
  
  // Face Registration
  static Future<ApiResponse<Map<String, dynamic>>> registerFace(File imageFile) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('Not authenticated', ERROR_AUTH);
      }
      
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/attendance/register'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      
      var streamedResponse = await request.send().timeout(Duration(seconds: 60));
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return ApiResponse.success(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        return ApiResponse.error(error['error'] ?? 'Face registration failed', ERROR_VALIDATION);
      }
    } catch (e) {
      return ApiResponse.error('Registration error: $e', ERROR_NETWORK);
    }
  }
  
  // Attendance Verification
  static Future<ApiResponse<AttendanceResponse>> verifyAttendance({
    required File imageFile,
    required String sessionId,
    required double latitude,
    required double longitude,
    String? locationId,
    String? pinCode,
    List<AuthorizedLocation>? authorizedLocations,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('Not authenticated', ERROR_AUTH);
      }
      
      final deviceId = await _getDeviceId();
      
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/attendance/verify'));
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add image
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      
      // Add required fields
      request.fields['session_id'] = sessionId;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['device_id'] = deviceId;
      
      // Add optional fields
      if (locationId != null) request.fields['location_id'] = locationId;
      if (pinCode != null) request.fields['pin_code'] = pinCode;
      if (authorizedLocations != null && authorizedLocations.isNotEmpty) {
        request.fields['authorized_locations'] = json.encode(
          authorizedLocations.map((loc) => loc.toJson()).toList()
        );
      }
      
      var streamedResponse = await request.send().timeout(Duration(seconds: 60));
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(AttendanceResponse.fromJson(data));
      } else {
        final error = json.decode(response.body);
        return ApiResponse.error(error['error'] ?? 'Attendance verification failed', ERROR_VALIDATION);
      }
    } catch (e) {
      return ApiResponse.error('Verification error: $e', ERROR_NETWORK);
    }
  }
  
  // Get Device ID
  static Future<String> _getDeviceId() async {
    String? deviceId = await _storage.read(key: 'device_id');
    
    if (deviceId == null) {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
      } else {
        deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      }
      
      await _storage.write(key: 'device_id', value: deviceId);
    }
    
    return deviceId;
  }
}

// Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? errorCode;
  
  ApiResponse.success(this.data) : success = true, error = null, errorCode = null;
  ApiResponse.error(this.error, this.errorCode) : success = false, data = null;
}

// Data Models
class LoginResponse {
  final String token;
  final String expiresAt;
  final User user;
  
  LoginResponse({required this.token, required this.expiresAt, required this.user});
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      expiresAt: json['expires_at'],
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String matriculeOrStaffId;
  
  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.matriculeOrStaffId,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      matriculeOrStaffId: json['matriculeOrStaffId'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'matriculeOrStaffId': matriculeOrStaffId,
    };
  }
}

class AttendanceResponse {
  final String attendanceId;
  final String timestamp;
  final bool verified;
  final List<VerificationDetail> verificationDetails;
  
  AttendanceResponse({
    required this.attendanceId,
    required this.timestamp,
    required this.verified,
    required this.verificationDetails,
  });
  
  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      attendanceId: json['attendance_id'],
      timestamp: json['timestamp'],
      verified: json['verified'],
      verificationDetails: (json['verification_details'] as List)
          .map((detail) => VerificationDetail.fromJson(detail))
          .toList(),
    );
  }
}

class VerificationDetail {
  final String factor;
  final bool verified;
  final double? confidence;
  final String? message;
  
  VerificationDetail({
    required this.factor,
    required this.verified,
    this.confidence,
    this.message,
  });
  
  factory VerificationDetail.fromJson(Map<String, dynamic> json) {
    return VerificationDetail(
      factor: json['factor'],
      verified: json['verified'],
      confidence: json['confidence']?.toDouble(),
      message: json['message'],
    );
  }
}

class AuthorizedLocation {
  final double latitude;
  final double longitude;
  final double radius;
  final String name;
  
  AuthorizedLocation({
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.name,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'name': name,
    };
  }
}
```

### 4. Location Service

```dart
// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Request location permissions
  static Future<bool> requestLocationPermission() async {
    PermissionStatus permission = await Permission.location.request();
    return permission == PermissionStatus.granted;
  }
  
  // Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }
  
  // Calculate distance between two points
  static double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}
```

### 5. Camera Service

```dart
// lib/services/camera_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();
  
  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    PermissionStatus permission = await Permission.camera.request();
    return permission == PermissionStatus.granted;
  }
  
  // Capture image from camera
  static Future<File?> captureImage({
    CameraDevice camera = CameraDevice.front,
    int imageQuality = 85,
  }) async {
    try {
      bool hasPermission = await requestCameraPermission();
      if (!hasPermission) {
        throw Exception('Camera permission denied');
      }
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: camera,
        imageQuality: imageQuality,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }
  
  // Pick image from gallery
  static Future<File?> pickImage({int imageQuality = 85}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
}
```

### 6. Example Screens

#### Login Screen
```dart
// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:your_app/services/auracheck_api.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _matriculeController = TextEditingController();
  bool _isLoading = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    _matriculeController.dispose();
    super.dispose();
  }
  
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final response = await AuraCheckAPI.login(
        _emailController.text.trim(),
        _matriculeController.text.trim(),
      );
      
      if (response.success) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        _showErrorDialog(response.error!);
      }
    } catch (e) {
      _showErrorDialog('Login failed: $e');
    }
    
    setState(() => _isLoading = false);
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AuraCheck Login'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.face,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _matriculeController,
                decoration: InputDecoration(
                  labelText: 'Matricule/Staff ID',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your matricule or staff ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### Attendance Screen
```dart
// lib/screens/attendance_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:your_app/services/auracheck_api.dart';
import 'package:your_app/services/camera_service.dart';
import 'package:your_app/services/location_service.dart';

class AttendanceScreen extends StatefulWidget {
  final String sessionId;
  
  AttendanceScreen({required this.sessionId});
  
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  File? _capturedImage;
  Position? _currentPosition;
  bool _isVerifying = false;
  bool _isLocationLoading = false;
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  
  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true);
    
    try {
      final position = await LocationService.getCurrentPosition();
      setState(() => _currentPosition = position);
    } catch (e) {
      _showErrorDialog('Failed to get location: $e');
    }
    
    setState(() => _isLocationLoading = false);
  }
  
  Future<void> _captureAndVerify() async {
    if (_currentPosition == null) {
      _showErrorDialog('Location not available. Please try again.');
      return;
    }
    
    // Capture image
    final image = await CameraService.captureImage();
    if (image == null) return;
    
    setState(() {
      _capturedImage = image;
      _isVerifying = true;
    });
    
    try {
      // Define authorized locations (this could come from your app's config)
      final authorizedLocations = [
        AuthorizedLocation(
          latitude: 3.848,
          longitude: 11.502,
          radius: 100,
          name: 'Main Campus',
        ),
      ];
      
      final response = await AuraCheckAPI.verifyAttendance(
        imageFile: image,
        sessionId: widget.sessionId,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        authorizedLocations: authorizedLocations,
      );
      
      if (response.success) {
        _showVerificationResult(response.data!);
      } else {
        _showErrorDialog(response.error!);
      }
    } catch (e) {
      _showErrorDialog('Verification failed: $e');
    }
    
    setState(() => _isVerifying = false);
  }
  
  void _showVerificationResult(AttendanceResponse result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.verified ? Icons.check_circle : Icons.error,
              color: result.verified ? Colors.green : Colors.red,
            ),
            SizedBox(width: 8),
            Text(result.verified ? 'Attendance Verified' : 'Verification Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attendance ID: ${result.attendanceId}'),
            Text('Time: ${result.timestamp}'),
            SizedBox(height: 16),
            Text('Verification Details:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...result.verificationDetails.map((detail) => Padding(
              padding: EdgeInsets.only(left: 16, top: 4),
              child: Row(
                children: [
                  Icon(
                    detail.verified ? Icons.check : Icons.close,
                    size: 16,
                    color: detail.verified ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${detail.factor}: ${detail.confidence != null ? '${detail.confidence!.toStringAsFixed(1)}%' : detail.message ?? ''}',
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (result.verified) {
                Navigator.pop(context); // Go back to previous screen
              }
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mark Attendance'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Location Info Card
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Location Status', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (_isLocationLoading)
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Getting location...'),
                      ],
                    )
                  else if (_currentPosition != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}'),
                        Text('Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}'),
                        Text('Accuracy: ±${_currentPosition!.accuracy.toStringAsFixed(1)}m'),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text('Location unavailable'),
                        Spacer(),
                        TextButton(
                          onPressed: _getCurrentLocation,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          
          // Captured Image Preview
          if (_capturedImage != null)
            Card(
              margin: EdgeInsets.all(16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _capturedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Captured Image', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          
          Spacer(),
          
          // Action Button
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _captureAndVerify,
                child: _isVerifying
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Verifying...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt),
                          SizedBox(width: 8),
                          Text('Capture & Verify Attendance'),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Testing Your Integration

1. **Import the Postman collection** (`AuraCheck_API.postman_collection.json`) for API testing
2. **Test endpoints individually** before Flutter integration
3. **Use provided test images** (`abia.jpg`, `belowe.jpg`) for development
4. **Test with real users** from your Firebase database

## Common Issues & Solutions

1. **CORS Issues**: Already handled in the backend with `flask_cors`
2. **Image Size**: Compress images before upload to avoid timeouts
3. **Location Accuracy**: Use high accuracy settings for best results
4. **Token Expiry**: Implement token refresh mechanism
5. **Network Timeouts**: Add appropriate timeout values for image uploads

Your API is now fully documented and ready for Flutter integration!
