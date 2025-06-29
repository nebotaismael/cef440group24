import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/user.dart';

class AuraCheckApiService {
  static const String baseUrl = 'https://auracheck-backend-ed233cba7e31.herokuapp.com';
  static const _storage = FlutterSecureStorage();

  // Error codes
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
  static Future<ApiResponse<AuraCheckLoginResponse>> login(String email, String matricule) async {
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
        final loginResponse = AuraCheckLoginResponse.fromJson(data);

        // Save token securely
        await _storage.write(key: 'auracheck_token', value: loginResponse.token);
        await _storage.write(key: 'auracheck_user', value: json.encode(loginResponse.user));

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
    return await _storage.read(key: 'auracheck_token');
  }

  // Get stored user
  static Future<Map<String, dynamic>?> getStoredUser() async {
    final userData = await _storage.read(key: 'auracheck_user');
    if (userData != null) {
      return json.decode(userData);
    }
    return null;
  }

  // Clear stored credentials
  static Future<void> clearCredentials() async {
    await _storage.delete(key: 'auracheck_token');
    await _storage.delete(key: 'auracheck_user');
  }

  // Face Registration
  static Future<ApiResponse<Map<String, dynamic>>> registerFace(File imageFile) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('Not authenticated with AuraCheck', ERROR_AUTH);
      }

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/attendance/register'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var streamedResponse = await request.send().timeout(Duration(seconds: 250));
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
  static Future<ApiResponse<AuraCheckAttendanceResponse>> verifyAttendance({
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
        return ApiResponse.error('Not authenticated with AuraCheck', ERROR_AUTH);
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
        return ApiResponse.success(AuraCheckAttendanceResponse.fromJson(data));
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
    String? deviceId = await _storage.read(key: 'auracheck_device_id');

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

      await _storage.write(key: 'auracheck_device_id', value: deviceId);
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

// AuraCheck specific models (only what's needed for API responses)
class AuraCheckLoginResponse {
  final String token;
  final String expiresAt;
  final Map<String, dynamic> user;

  AuraCheckLoginResponse({required this.token, required this.expiresAt, required this.user});

  factory AuraCheckLoginResponse.fromJson(Map<String, dynamic> json) {
    return AuraCheckLoginResponse(
      token: json['token'],
      expiresAt: json['expires_at'],
      user: json['user'],
    );
  }
}

class AuraCheckAttendanceResponse {
  final String attendanceId;
  final String timestamp;
  final bool verified;
  final List<VerificationDetail> verificationDetails;

  AuraCheckAttendanceResponse({
    required this.attendanceId,
    required this.timestamp,
    required this.verified,
    required this.verificationDetails,
  });

  factory AuraCheckAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AuraCheckAttendanceResponse(
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
