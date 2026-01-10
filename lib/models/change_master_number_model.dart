/// Model class for Change Master Number feature
/// Handles all data related to changing merchant's master/admin mobile number
class ChangeMasterNumberModel {
  final String? sessionId;
  final String? currentNumber;
  final String? newNumber;
  final String? pin;
  final String? currentOtp;
  final String? newOtp;
  final ChangeMasterNumberStatus status;

  ChangeMasterNumberModel({
    this.sessionId,
    this.currentNumber,
    this.newNumber,
    this.pin,
    this.currentOtp,
    this.newOtp,
    this.status = ChangeMasterNumberStatus.initial,
  });

  ChangeMasterNumberModel copyWith({
    String? sessionId,
    String? currentNumber,
    String? newNumber,
    String? pin,
    String? currentOtp,
    String? newOtp,
    ChangeMasterNumberStatus? status,
  }) {
    return ChangeMasterNumberModel(
      sessionId: sessionId ?? this.sessionId,
      currentNumber: currentNumber ?? this.currentNumber,
      newNumber: newNumber ?? this.newNumber,
      pin: pin ?? this.pin,
      currentOtp: currentOtp ?? this.currentOtp,
      newOtp: newOtp ?? this.newOtp,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'ChangeMasterNumberModel(sessionId: $sessionId, currentNumber: $currentNumber, newNumber: $newNumber, status: $status)';
  }
}

/// Status enum for change master number process
enum ChangeMasterNumberStatus {
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

class SendOtpToCurrentRequest {
  final String securityKey;

  SendOtpToCurrentRequest({required this.securityKey});

  Map<String, dynamic> toJson() => {'securityKey': securityKey};
}

class VerifyCurrentOtpRequest {
  final String otp;

  VerifyCurrentOtpRequest({required this.otp});

  Map<String, dynamic> toJson() => {'otp': otp};
}

class SendOtpToNewRequest {
  final String mobileNumber;

  SendOtpToNewRequest({required this.mobileNumber});

  Map<String, dynamic> toJson() => {'mobileNumber': mobileNumber};
}

class VerifyNewOtpRequest {
  final String mobileNumber;
  final String otp;

  VerifyNewOtpRequest({
    required this.mobileNumber,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'mobileNumber': mobileNumber,
        'otp': otp,
      };
}

/// API Response Models

class SendOtpResponse {
  final String message;

  SendOtpResponse({required this.message});

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      message: json['message'] ?? 'OTP sent successfully',
    );
  }
}

class VerifyCurrentOtpResponse {
  final int sessionId;

  VerifyCurrentOtpResponse({required this.sessionId});

  factory VerifyCurrentOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyCurrentOtpResponse(
      sessionId: json['sessionId'] ?? 0,
    );
  }
}

class VerifyNewOtpResponse {
  final String message;

  VerifyNewOtpResponse({required this.message});

  factory VerifyNewOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyNewOtpResponse(
      message: json['message'] ?? 'Number changed successfully',
    );
  }
}

/// Error Response Model

class ChangeMasterNumberErrorResponse {
  final int statusCode;
  final String message;
  final List<FieldError>? errors;

  ChangeMasterNumberErrorResponse({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  factory ChangeMasterNumberErrorResponse.fromJson(Map<String, dynamic> json) {
    List<FieldError>? fieldErrors;
    if (json['errors'] != null) {
      fieldErrors = (json['errors'] as List)
          .map((e) => FieldError.fromJson(e))
          .toList();
    }

    return ChangeMasterNumberErrorResponse(
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

class FieldError {
  final String field;
  final String error;

  FieldError({
    required this.field,
    required this.error,
  });

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field'] ?? '',
      error: json['error'] ?? '',
    );
  }
}
