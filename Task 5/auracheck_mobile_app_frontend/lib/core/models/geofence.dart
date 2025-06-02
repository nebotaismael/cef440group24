import 'package:hive/hive.dart';
import 'dart:math' as math;

part 'geofence.g.dart';

@HiveType(typeId: 8)
class Geofence extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final double latitude;
  
  @HiveField(3)
  final double longitude;
  
  @HiveField(4)
  final double radius;
  
  @HiveField(5)
  final bool isActive;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final DateTime updatedAt;

  Geofence({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Geofence copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    double? radius,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Geofence(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool containsLocation(double lat, double lon, {double tolerance = 10.0}) {
    final distance = _calculateDistance(latitude, longitude, lat, lon);
    return distance <= (radius + tolerance);
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) => degrees * (math.pi / 180);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Geofence.fromJson(Map<String, dynamic> json) {
    return Geofence(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      radius: json['radius'].toDouble(),
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}