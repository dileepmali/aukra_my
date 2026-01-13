/// Privacy Setting Model
/// Handles security PIN feature state and API responses
///
/// API Endpoints:
/// - POST /api/privacy-setting/user/sendOtp - Send OTP
/// - POST /api/privacy-setting/user - Update settings
/// - GET /api/privacy-setting/user - Get settings
/// - GET /api/privacy-setting/user/validate/{key} - Validate PIN

/// Status enum for privacy setting operations
enum PrivacySettingStatus {
  initial,
  loading,
  sendingOtp,
  otpSent,
  updatingSettings,
  settingsUpdated,
  validatingPin,
  pinValidated,
  success,
  error,
}

/// Main Privacy Setting Model
class PrivacySettingModel {
  final bool isEnabled;
  final bool isValid;
  final String? securityKey;
  final String? otp;
  final PrivacySettingStatus status;
  final String? errorMessage;

  const PrivacySettingModel({
    this.isEnabled = false,
    this.isValid = false,
    this.securityKey,
    this.otp,
    this.status = PrivacySettingStatus.initial,
    this.errorMessage,
  });

  /// Create from API response (GET /api/privacy-setting/user)
  factory PrivacySettingModel.fromJson(Map<String, dynamic> json) {
    return PrivacySettingModel(
      isEnabled: json['isEnabled'] ?? false,
      isValid: json['isValid'] ?? false,
    );
  }

  /// Copy with method for immutability
  PrivacySettingModel copyWith({
    bool? isEnabled,
    bool? isValid,
    String? securityKey,
    String? otp,
    PrivacySettingStatus? status,
    String? errorMessage,
  }) {
    return PrivacySettingModel(
      isEnabled: isEnabled ?? this.isEnabled,
      isValid: isValid ?? this.isValid,
      securityKey: securityKey ?? this.securityKey,
      otp: otp ?? this.otp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Reset to initial state
  factory PrivacySettingModel.initial() {
    return const PrivacySettingModel(
      isEnabled: false,
      isValid: false,
      status: PrivacySettingStatus.initial,
    );
  }

  @override
  String toString() {
    return 'PrivacySettingModel(isEnabled: $isEnabled, isValid: $isValid, status: $status)';
  }
}

// ============================================================
// REQUEST MODELS
// ============================================================

/// Request for POST /api/privacy-setting/user
/// Used to enable/disable security PIN
class UpdatePrivacySettingRequest {
  final String securityKey;
  final bool isEnabled;
  final String otp;

  const UpdatePrivacySettingRequest({
    required this.securityKey,
    required this.isEnabled,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'securityKey': securityKey,
      'isEnabled': isEnabled,
      'otp': otp,
    };
  }

  @override
  String toString() {
    return 'UpdatePrivacySettingRequest(securityKey: ****, isEnabled: $isEnabled, otp: ****)';
  }
}

// ============================================================
// RESPONSE MODELS
// ============================================================

/// Response for POST /api/privacy-setting/user/sendOtp
class SendOtpResponse {
  final String message;

  const SendOtpResponse({required this.message});

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      message: json['message'] ?? 'OTP sent successfully',
    );
  }

  @override
  String toString() => 'SendOtpResponse(message: $message)';
}

/// Response for POST /api/privacy-setting/user
class UpdatePrivacySettingResponse {
  final String message;

  const UpdatePrivacySettingResponse({required this.message});

  factory UpdatePrivacySettingResponse.fromJson(Map<String, dynamic> json) {
    return UpdatePrivacySettingResponse(
      message: json['message'] ?? 'Updated successfully',
    );
  }

  @override
  String toString() => 'UpdatePrivacySettingResponse(message: $message)';
}

/// Response for GET /api/privacy-setting/user
/// and GET /api/privacy-setting/user/validate/{key}
class PrivacySettingResponse {
  final bool isEnabled;
  final bool isValid;

  const PrivacySettingResponse({
    required this.isEnabled,
    required this.isValid,
  });

  factory PrivacySettingResponse.fromJson(Map<String, dynamic> json) {
    return PrivacySettingResponse(
      isEnabled: json['isEnabled'] ?? false,
      isValid: json['isValid'] ?? false,
    );
  }

  @override
  String toString() => 'PrivacySettingResponse(isEnabled: $isEnabled, isValid: $isValid)';
}

/// Error response for all privacy setting APIs
class PrivacySettingErrorResponse {
  final int statusCode;
  final String message;
  final List<PrivacySettingFieldError>? errors;

  const PrivacySettingErrorResponse({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  factory PrivacySettingErrorResponse.fromJson(Map<String, dynamic> json) {
    List<PrivacySettingFieldError>? fieldErrors;
    if (json['errors'] != null) {
      fieldErrors = (json['errors'] as List)
          .map((e) => PrivacySettingFieldError.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return PrivacySettingErrorResponse(
      statusCode: json['statusCode'] ?? 400,
      message: json['message'] ?? 'An error occurred',
      errors: fieldErrors,
    );
  }

  /// Get full error message including field errors
  String get fullErrorMessage {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.map((e) => e.error).join(', ');
    }
    return message;
  }

  @override
  String toString() => 'PrivacySettingErrorResponse(statusCode: $statusCode, message: $message)';
}

/// Field error in API response
class PrivacySettingFieldError {
  final String field;
  final String error;

  const PrivacySettingFieldError({
    required this.field,
    required this.error,
  });

  factory PrivacySettingFieldError.fromJson(Map<String, dynamic> json) {
    return PrivacySettingFieldError(
      field: json['field'] ?? '',
      error: json['error'] ?? '',
    );
  }

  @override
  String toString() => 'PrivacySettingFieldError(field: $field, error: $error)';
}