/// Model class for Recovery Mobile feature
/// Handles all data related to changing user's recovery/backup mobile number
class RecoveryMobileModel {
  final String? sessionId;
  final String? currentNumber;
  final String? newRecoveryNumber;
  final String? pin;
  final String? currentOtp;
  final String? newOtp;
  final RecoveryMobileStatus status;

  RecoveryMobileModel({
    this.sessionId,
    this.currentNumber,
    this.newRecoveryNumber,
    this.pin,
    this.currentOtp,
    this.newOtp,
    this.status = RecoveryMobileStatus.initial,
  });

  RecoveryMobileModel copyWith({
    String? sessionId,
    String? currentNumber,
    String? newRecoveryNumber,
    String? pin,
    String? currentOtp,
    String? newOtp,
    RecoveryMobileStatus? status,
  }) {
    return RecoveryMobileModel(
      sessionId: sessionId ?? this.sessionId,
      currentNumber: currentNumber ?? this.currentNumber,
      newRecoveryNumber: newRecoveryNumber ?? this.newRecoveryNumber,
      pin: pin ?? this.pin,
      currentOtp: currentOtp ?? this.currentOtp,
      newOtp: newOtp ?? this.newOtp,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'RecoveryMobileModel(sessionId: $sessionId, currentNumber: $currentNumber, newRecoveryNumber: $newRecoveryNumber, status: $status)';
  }
}

/// Status enum for recovery mobile process
enum RecoveryMobileStatus {
  initial,
  sendingOtpToCurrent,
  otpSentToCurrent,
  verifyingCurrentOtp,
  currentOtpVerified,
  sendingOtpToNew,
  otpSentToNew,
  verifyingNewOtp,
  completed,
  error,
}

/// API Request Models

/// API 1: Send OTP to current number request
class RecoverySendOtpToCurrentRequest {
  final String securityKey;

  RecoverySendOtpToCurrentRequest({required this.securityKey});

  Map<String, dynamic> toJson() => {'securityKey': securityKey};
}

/// API 2: Verify current OTP request
class RecoveryVerifyCurrentOtpRequest {
  final String otp;

  RecoveryVerifyCurrentOtpRequest({required this.otp});

  Map<String, dynamic> toJson() => {'otp': otp};
}

/// API 3: Send OTP to new recovery number request
class RecoverySendOtpToNewRequest {
  final String mobileNumber;

  RecoverySendOtpToNewRequest({required this.mobileNumber});

  Map<String, dynamic> toJson() => {'mobileNumber': mobileNumber};
}

/// API 4: Verify new recovery OTP request
class RecoveryVerifyNewOtpRequest {
  final String mobileNumber;
  final String otp;

  RecoveryVerifyNewOtpRequest({
    required this.mobileNumber,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'mobileNumber': mobileNumber,
        'otp': otp,
      };
}

/// API Response Models

class RecoverySendOtpResponse {
  final String message;

  RecoverySendOtpResponse({required this.message});

  factory RecoverySendOtpResponse.fromJson(Map<String, dynamic> json) {
    return RecoverySendOtpResponse(
      message: json['message'] ?? 'OTP sent successfully',
    );
  }
}

class RecoveryVerifyCurrentOtpResponse {
  final int sessionId;

  RecoveryVerifyCurrentOtpResponse({required this.sessionId});

  factory RecoveryVerifyCurrentOtpResponse.fromJson(Map<String, dynamic> json) {
    return RecoveryVerifyCurrentOtpResponse(
      sessionId: json['sessionId'] ?? 0,
    );
  }
}

class RecoveryVerifyNewOtpResponse {
  final String message;

  RecoveryVerifyNewOtpResponse({required this.message});

  factory RecoveryVerifyNewOtpResponse.fromJson(Map<String, dynamic> json) {
    return RecoveryVerifyNewOtpResponse(
      message: json['message'] ?? 'Recovery mobile changed successfully',
    );
  }
}

/// Error Response Model
class RecoveryMobileErrorResponse {
  final int statusCode;
  final String message;
  final List<RecoveryFieldError>? errors;

  RecoveryMobileErrorResponse({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  factory RecoveryMobileErrorResponse.fromJson(Map<String, dynamic> json) {
    List<RecoveryFieldError>? fieldErrors;
    if (json['errors'] != null) {
      fieldErrors = (json['errors'] as List)
          .map((e) => RecoveryFieldError.fromJson(e))
          .toList();
    }

    return RecoveryMobileErrorResponse(
      statusCode: json['statusCode'] ?? 400,
      message: json['message'] ?? 'An error occurred',
      errors: fieldErrors,
    );
  }

  String get fullErrorMessage {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.map((e) => e.error).join(', ');
    }
    return message;
  }
}

class RecoveryFieldError {
  final String field;
  final String error;

  RecoveryFieldError({
    required this.field,
    required this.error,
  });

  factory RecoveryFieldError.fromJson(Map<String, dynamic> json) {
    return RecoveryFieldError(
      field: json['field'] ?? '',
      error: json['error'] ?? '',
    );
  }
}