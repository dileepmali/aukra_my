/// User Preference Model
/// Handles user preferences for language, currency, timezone, theme, notifications etc.
///
/// API Endpoints:
/// - POST /api/user-preference - Create preference
/// - GET /api/user-preference - Get preference
/// - PUT /api/user-preference - Update preference
/// - DELETE /api/user-preference - Delete preference

/// Status enum for user preference operations
enum UserPreferenceStatus {
  initial,
  loading,
  creating,
  fetching,
  updating,
  deleting,
  success,
  error,
}

/// Main User Preference Model
class UserPreferenceModel {
  final String? language;
  final String? currency;
  final String? timezone;
  final String? dateFormat;
  final String? timeFormat;
  final String? theme;
  final bool notifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool pushNotifications;
  final UserPreferenceStatus status;
  final String? errorMessage;

  const UserPreferenceModel({
    this.language,
    this.currency,
    this.timezone,
    this.dateFormat,
    this.timeFormat,
    this.theme,
    this.notifications = true,
    this.emailNotifications = true,
    this.smsNotifications = true,
    this.pushNotifications = true,
    this.status = UserPreferenceStatus.initial,
    this.errorMessage,
  });

  /// Create from API response (GET /api/user-preference)
  factory UserPreferenceModel.fromJson(Map<String, dynamic> json) {
    return UserPreferenceModel(
      language: json['language'] as String? ?? 'en',
      currency: json['currency'] as String? ?? 'INR',
      timezone: json['timezone'] as String? ?? 'Asia/Kolkata',
      dateFormat: json['dateFormat'] as String? ?? 'DD/MM/YYYY',
      timeFormat: json['timeFormat'] as String? ?? '24h',
      theme: json['theme'] as String? ?? 'light',
      notifications: json['notifications'] as bool? ?? true,
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      smsNotifications: json['smsNotifications'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      status: UserPreferenceStatus.success,
    );
  }

  /// Convert to JSON for API requests (POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'language': language ?? 'en',
      'currency': currency ?? 'INR',
      'timezone': timezone ?? 'Asia/Kolkata',
      'dateFormat': dateFormat ?? 'DD/MM/YYYY',
      'timeFormat': timeFormat ?? '24h',
      'theme': theme ?? 'light',
      'notifications': notifications,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'pushNotifications': pushNotifications,
    };
  }

  /// Copy with method for immutability
  UserPreferenceModel copyWith({
    String? language,
    String? currency,
    String? timezone,
    String? dateFormat,
    String? timeFormat,
    String? theme,
    bool? notifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? pushNotifications,
    UserPreferenceStatus? status,
    String? errorMessage,
  }) {
    return UserPreferenceModel(
      language: language ?? this.language,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Default/Initial state
  factory UserPreferenceModel.initial() {
    return const UserPreferenceModel(
      language: 'en',
      currency: 'INR',
      timezone: 'Asia/Kolkata',
      dateFormat: 'DD/MM/YYYY',
      timeFormat: '24h',
      theme: 'light',
      notifications: true,
      emailNotifications: true,
      smsNotifications: true,
      pushNotifications: true,
      status: UserPreferenceStatus.initial,
    );
  }

  /// Check if preference exists (has been fetched from server)
  bool get hasData => language != null && currency != null;

  /// Check if dark theme
  bool get isDarkTheme => theme == 'dark';

  /// Check if 24h time format
  bool get is24HourFormat => timeFormat == '24h';

  @override
  String toString() {
    return 'UserPreferenceModel('
        'language: $language, '
        'currency: $currency, '
        'timezone: $timezone, '
        'theme: $theme, '
        'notifications: $notifications, '
        'status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferenceModel &&
        other.language == language &&
        other.currency == currency &&
        other.timezone == timezone &&
        other.dateFormat == dateFormat &&
        other.timeFormat == timeFormat &&
        other.theme == theme &&
        other.notifications == notifications &&
        other.emailNotifications == emailNotifications &&
        other.smsNotifications == smsNotifications &&
        other.pushNotifications == pushNotifications;
  }

  @override
  int get hashCode {
    return Object.hash(
      language,
      currency,
      timezone,
      dateFormat,
      timeFormat,
      theme,
      notifications,
      emailNotifications,
      smsNotifications,
      pushNotifications,
    );
  }
}

// ============================================================
// RESPONSE MODELS
// ============================================================

/// Generic API Response for user preference operations
class UserPreferenceResponse {
  final bool success;
  final String? message;
  final UserPreferenceModel? data;

  const UserPreferenceResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory UserPreferenceResponse.fromJson(Map<String, dynamic> json) {
    UserPreferenceModel? preferenceData;

    // Handle nested data object
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      preferenceData = UserPreferenceModel.fromJson(json['data'] as Map<String, dynamic>);
    } else if (json.containsKey('language')) {
      // Direct preference data in response
      preferenceData = UserPreferenceModel.fromJson(json);
    }

    return UserPreferenceResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: preferenceData,
    );
  }

  @override
  String toString() => 'UserPreferenceResponse(success: $success, message: $message)';
}

/// Error response for user preference APIs
class UserPreferenceErrorResponse {
  final int statusCode;
  final String message;
  final List<UserPreferenceFieldError>? errors;

  const UserPreferenceErrorResponse({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  factory UserPreferenceErrorResponse.fromJson(Map<String, dynamic> json) {
    List<UserPreferenceFieldError>? fieldErrors;
    if (json['errors'] != null && json['errors'] is List) {
      fieldErrors = (json['errors'] as List)
          .map((e) => UserPreferenceFieldError.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return UserPreferenceErrorResponse(
      statusCode: json['statusCode'] as int? ?? 400,
      message: json['message'] as String? ?? 'An error occurred',
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
  String toString() => 'UserPreferenceErrorResponse(statusCode: $statusCode, message: $message)';
}

/// Field error in API response
class UserPreferenceFieldError {
  final String field;
  final String error;

  const UserPreferenceFieldError({
    required this.field,
    required this.error,
  });

  factory UserPreferenceFieldError.fromJson(Map<String, dynamic> json) {
    return UserPreferenceFieldError(
      field: json['field'] as String? ?? '',
      error: json['error'] as String? ?? '',
    );
  }

  @override
  String toString() => 'UserPreferenceFieldError(field: $field, error: $error)';
}
