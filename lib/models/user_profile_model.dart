/// User Profile Model for /api/user/profile API
/// Handles both user profile data and device session data
class UserProfileModel {
  final String? userId;
  final String? sessionId;
  final String? deviceName;
  final String? deviceType;
  final String? deviceId;
  final DateTime? loginTime;
  final DateTime? expiresAt;
  final bool isMainDevice;
  final bool isActive;
  final bool isDelete;
  final bool isBlocked;
  final String? latitude;
  final String? address;
  final String? longitude;
  final String? ipAddress;
  final bool isVerified;
  final DateTime? lastActivityAt;
  final String? createdBy;
  final String? updatedBy;
  final String? appVersion;
  final String? deviceVersion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ✅ NEW: User profile fields from /api/user/profile
  final String? username;           // User's display name (e.g., "Dileep Mali")
  final String? mobileNumber;       // User's mobile number
  final String? recoveryMobileNumber; // Recovery mobile number
  final String? countryCode;        // Country code (e.g., "+91")
  final DateTime? lastLoginDate;    // Last login timestamp
  final String? updateBySessionId;  // Session that last updated
  final int? merchantId;            // Associated merchant ID

  UserProfileModel({
    this.userId,
    this.sessionId,
    this.deviceName,
    this.deviceType,
    this.deviceId,
    this.loginTime,
    this.expiresAt,
    this.isMainDevice = false,
    this.isActive = true,
    this.isDelete = false,
    this.isBlocked = false,
    this.latitude,
    this.address,
    this.longitude,
    this.ipAddress,
    this.isVerified = false,
    this.lastActivityAt,
    this.createdBy,
    this.updatedBy,
    this.appVersion,
    this.deviceVersion,
    this.createdAt,
    this.updatedAt,
    // ✅ NEW fields
    this.username,
    this.mobileNumber,
    this.recoveryMobileNumber,
    this.countryCode,
    this.lastLoginDate,
    this.updateBySessionId,
    this.merchantId,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'] as String?,
      sessionId: json['sessionId'] as String?,
      deviceName: json['deviceName'] as String?,
      deviceType: json['deviceType'] as String?,
      deviceId: json['deviceId'] as String?,
      loginTime: json['loginTime'] != null
          ? DateTime.tryParse(json['loginTime'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      isMainDevice: json['isMainDevice'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      isDelete: json['isDelete'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
      latitude: json['latitude'] as String?,
      address: json['address'] as String?,
      longitude: json['longitude'] as String?,
      ipAddress: json['ipAddress'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      lastActivityAt: json['lastActivityAt'] != null
          ? DateTime.tryParse(json['lastActivityAt'] as String)
          : null,
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      appVersion: json['appVersion'] as String?,
      deviceVersion: json['deviceVersion'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      // ✅ NEW: Parse user profile fields
      username: json['username'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      recoveryMobileNumber: json['recoveryMobileNumber'] as String?,
      countryCode: json['countryCode'] as String?,
      lastLoginDate: json['lastLoginDate'] != null
          ? DateTime.tryParse(json['lastLoginDate'] as String)
          : null,
      updateBySessionId: json['updateBySessionId'] as String?,
      merchantId: json['merchantId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sessionId': sessionId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'deviceId': deviceId,
      'loginTime': loginTime?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isMainDevice': isMainDevice,
      'isActive': isActive,
      'isDelete': isDelete,
      'isBlocked': isBlocked,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'ipAddress': ipAddress,
      'isVerified': isVerified,
      'lastActivityAt': lastActivityAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'appVersion': appVersion,
      'deviceVersion': deviceVersion,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      // ✅ NEW fields
      'username': username,
      'mobileNumber': mobileNumber,
      'recoveryMobileNumber': recoveryMobileNumber,
      'countryCode': countryCode,
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'updateBySessionId': updateBySessionId,
      'merchantId': merchantId,
    };
  }

  UserProfileModel copyWith({
    String? userId,
    String? sessionId,
    String? deviceName,
    String? deviceType,
    String? deviceId,
    DateTime? loginTime,
    DateTime? expiresAt,
    bool? isMainDevice,
    bool? isActive,
    bool? isDelete,
    bool? isBlocked,
    String? latitude,
    String? address,
    String? longitude,
    String? ipAddress,
    bool? isVerified,
    DateTime? lastActivityAt,
    String? createdBy,
    String? updatedBy,
    String? appVersion,
    String? deviceVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    // ✅ NEW fields
    String? username,
    String? mobileNumber,
    String? recoveryMobileNumber,
    String? countryCode,
    DateTime? lastLoginDate,
    String? updateBySessionId,
    int? merchantId,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      deviceId: deviceId ?? this.deviceId,
      loginTime: loginTime ?? this.loginTime,
      expiresAt: expiresAt ?? this.expiresAt,
      isMainDevice: isMainDevice ?? this.isMainDevice,
      isActive: isActive ?? this.isActive,
      isDelete: isDelete ?? this.isDelete,
      isBlocked: isBlocked ?? this.isBlocked,
      latitude: latitude ?? this.latitude,
      address: address ?? this.address,
      longitude: longitude ?? this.longitude,
      ipAddress: ipAddress ?? this.ipAddress,
      isVerified: isVerified ?? this.isVerified,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      appVersion: appVersion ?? this.appVersion,
      deviceVersion: deviceVersion ?? this.deviceVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // ✅ NEW fields
      username: username ?? this.username,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      recoveryMobileNumber: recoveryMobileNumber ?? this.recoveryMobileNumber,
      countryCode: countryCode ?? this.countryCode,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      updateBySessionId: updateBySessionId ?? this.updateBySessionId,
      merchantId: merchantId ?? this.merchantId,
    );
  }
}

/// Request model for updating profile name
class UpdateProfileNameRequest {
  final String name;

  UpdateProfileNameRequest({required this.name});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

/// Response model for profile update
class UpdateProfileResponse {
  final bool success;
  final String? message;
  final UserProfileModel? data;

  UpdateProfileResponse({
    this.success = false,
    this.message,
    this.data,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: json['data'] != null
          ? UserProfileModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}