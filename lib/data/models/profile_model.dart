import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String driverId;
  final String name;
  final String email;
  final String phone;
  final String imagePath;
  final String cnicImagePath;
  final int availabilityStatus;
  final int verificationStatus;
  final double review;
  final GeoLocation currentLocation;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.driverId,
    required this.name,
    required this.email,
    required this.phone,
    required this.imagePath,
    required this.cnicImagePath,
    required this.availabilityStatus,
    required this.verificationStatus,
    required this.review,
    required this.currentLocation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return ProfileModel(
      driverId: json['driver_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      imagePath: json['image_path'] ?? '',
      cnicImagePath: json['cnic_image_path'] ?? '',
      availabilityStatus: (json['availiability_status'] is num)
          ? (json['availiability_status'] as num).toInt()
          : int.tryParse(json['availiability_status'].toString()) ?? 0,
      verificationStatus: (json['verification_status'] is num)
          ? (json['verification_status'] as num).toInt()
          : int.tryParse(json['verification_status'].toString()) ?? 0,
      review: _toDouble(json['review']),
      currentLocation:
      GeoLocation.fromJson(json['current_location'] ?? {}),
      createdAt: (json['created_at'] is Timestamp)
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.tryParse(json['created_at'].toString()) ??
          DateTime.now(),
      updatedAt: (json['updated_at'] is Timestamp)
          ? (json['updated_at'] as Timestamp).toDate()
          : DateTime.tryParse(json['updated_at'].toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'name': name,
      'email': email,
      'phone': phone,
      'image_path': imagePath,
      'cnic_image_path': cnicImagePath,
      'availiability_status': availabilityStatus,
      'verification_status': verificationStatus,
      'review': review,
      'current_location': currentLocation.toJson(),
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }


  ProfileModel copyWith({
    String? driverId,
    String? name,
    String? email,
    String? phone,
    String? imagePath,
    String? cnicImagePath,
    bool? isVerified,
    int? availabilityStatus,
    int? verificationStatus,
    double? review,
    GeoLocation? currentLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      driverId: driverId ?? this.driverId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imagePath: imagePath ?? this.imagePath,
      cnicImagePath: cnicImagePath ?? this.cnicImagePath,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      review: review ?? this.review,
      currentLocation: currentLocation ?? this.currentLocation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ProfileModel(driverId: $driverId, name: $name, email: $email, '
        ' availability: $availabilityStatus, '
        'review: $review, location: $currentLocation)';
  }
}


class GeoLocation {
  final double latitude;
  final double longitude;

  GeoLocation({
    required this.latitude,
    required this.longitude,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return GeoLocation(
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() => 'GeoLocation(lat: $latitude, lng: $longitude)';
}
