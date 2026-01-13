/// FCM Token Model for Push Notifications
class FcmTokenModel {
  final int? id;
  final String? userId;
  final String fcmToken;
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String platform;
  final bool isActive;
  final bool? isDelete;
  final DateTime? lastUsedAt;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FcmTokenModel({
    this.id,
    this.userId,
    required this.fcmToken,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.platform,
    this.isActive = true,
    this.isDelete,
    this.lastUsedAt,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert to JSON for API request (POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'fcmToken': fcmToken,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'platform': platform,
      'isActive': isActive,
    };
  }

  /// Create from JSON response
  factory FcmTokenModel.fromJson(Map<String, dynamic> json) {
    return FcmTokenModel(
      id: json['id'],
      userId: json['userId'],
      fcmToken: json['fcmToken'] ?? '',
      deviceId: json['deviceId'] ?? '',
      deviceName: json['deviceName'] ?? '',
      deviceType: json['deviceType'] ?? 'MOBILE',
      platform: json['platform'] ?? 'ANDROID',
      isActive: json['isActive'] ?? true,
      isDelete: json['isDelete'],
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'])
          : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Copy with method
  FcmTokenModel copyWith({
    int? id,
    String? userId,
    String? fcmToken,
    String? deviceId,
    String? deviceName,
    String? deviceType,
    String? platform,
    bool? isActive,
    bool? isDelete,
    DateTime? lastUsedAt,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FcmTokenModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fcmToken: fcmToken ?? this.fcmToken,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      platform: platform ?? this.platform,
      isActive: isActive ?? this.isActive,
      isDelete: isDelete ?? this.isDelete,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Response model for FCM Token list
class FcmTokenListResponse {
  final List<FcmTokenModel> tokens;

  FcmTokenListResponse({required this.tokens});

  factory FcmTokenListResponse.fromJson(List<dynamic> json) {
    return FcmTokenListResponse(
      tokens: json.map((item) => FcmTokenModel.fromJson(item)).toList(),
    );
  }
}

/// Response model for FCM Token API success
class FcmTokenResponse {
  final String? message;
  final FcmTokenModel? token;

  FcmTokenResponse({this.message, this.token});

  factory FcmTokenResponse.fromJson(Map<String, dynamic> json) {
    return FcmTokenResponse(
      message: json['message'],
      token: json['id'] != null ? FcmTokenModel.fromJson(json) : null,
    );
  }
}
