import 'error_types.dart';

// Temporary ApiResponse class until real implementation is added
class ApiResponse {
  final bool isNetworkError;
  final bool isAuthError;
  final int? statusCode;
  final String errorMessage;

  ApiResponse({
    this.isNetworkError = false,
    this.isAuthError = false,
    this.statusCode,
    this.errorMessage = '',
  });
}

/// 🔍 Error Parser - Parse different error types into standardized format
/// Purpose: Convert various error formats into ErrorDetails
class ErrorParser {

  /// Parse any type of error into standardized ErrorDetails
  static ErrorDetails parse(
      dynamic error, {
        String? context,
        String? screen,
        ErrorSeverity? forceSeverity,
      }) {
    if (error is ErrorDetails) {
      return error;
    }

    if (error is ApiResponse) {
      return _parseApiResponse(error, context: context, screen: screen, forceSeverity: forceSeverity);
    }

    if (error is String) {
      return _parseStringError(error, context: context, screen: screen, forceSeverity: forceSeverity);
    }

    if (error is Exception) {
      return _parseException(error, context: context, screen: screen, forceSeverity: forceSeverity);
    }

    return _parseUnknownError(error, context: context, screen: screen, forceSeverity: forceSeverity);
  }

  /// Parse API response errors
  static ErrorDetails _parseApiResponse(
      ApiResponse response, {
        String? context,
        String? screen,
        ErrorSeverity? forceSeverity,
      }) {
    String title;
    ErrorCategory category;
    ErrorSeverity severity;

    // Determine category and title based on response type
    if (response.isNetworkError) {
      title = 'Connection Error';
      category = ErrorCategory.network;
      severity = ErrorSeverity.auth;
    } else if (response.isAuthError) {
      title = 'Authentication Error';
      category = ErrorCategory.authentication;
      severity = ErrorSeverity.auth;
    } else {
      // Check status code for specific errors
      switch (response.statusCode) {
        case 400:
          title = 'Bad Request';
          category = ErrorCategory.validation;
          severity = ErrorSeverity.validation;
          break;
        case 401:
          title = 'Unauthorized';
          category = ErrorCategory.authentication;
          severity = ErrorSeverity.auth;
          break;
        case 403:
          title = 'Access Denied';
          category = ErrorCategory.permission;
          severity = ErrorSeverity.error;
          break;
        case 404:
          title = 'Not Found';
          category = ErrorCategory.server;
          severity = ErrorSeverity.warning;
          break;
        case 500:
          title = 'Server Error';
          category = ErrorCategory.server;
          severity = ErrorSeverity.critical;
          break;
        default:
          title = 'Request Failed';
          category = ErrorCategory.server;
          severity = ErrorSeverity.error;
      }
    }

    return ErrorDetails(
      title: title,
      message: response.errorMessage,
      category: category,
      severity: forceSeverity ?? severity,
      screen: screen,
      context: context,
      originalError: response,
    );
  }

  /// Parse string errors
  static ErrorDetails _parseStringError(
      String error, {
        String? context,
        String? screen,
        ErrorSeverity? forceSeverity,
      }) {
    // Check for common error patterns
    final lowerError = error.toLowerCase();

    ErrorCategory category = ErrorCategory.general;
    ErrorSeverity severity = ErrorSeverity.error;
    String title = 'Error';

    if (lowerError.contains('network') || lowerError.contains('connection') || lowerError.contains('internet')) {
      category = ErrorCategory.network;
      severity = ErrorSeverity.network;
      title = 'Connection Error';
    } else if (lowerError.contains('auth') || lowerError.contains('login') || lowerError.contains('token')) {
      category = ErrorCategory.authentication;
      severity = ErrorSeverity.auth;
      title = 'Authentication Error';
    } else if (lowerError.contains('validation') || lowerError.contains('invalid') || lowerError.contains('required')) {
      category = ErrorCategory.validation;
      severity = ErrorSeverity.validation;
      title = 'Validation Error';
    } else if (lowerError.contains('file') || lowerError.contains('upload') || lowerError.contains('download')) {
      category = ErrorCategory.storage;
      severity = ErrorSeverity.error;
      title = 'File Error';
    } else if (lowerError.contains('folder') || lowerError.contains('directory')) {
      category = ErrorCategory.storage;
      severity = ErrorSeverity.error;
      title = 'Folder Error';
    } else if (lowerError.contains('permission') || lowerError.contains('access')) {
      category = ErrorCategory.permission;
      severity = ErrorSeverity.error;
      title = 'Permission Error';
    }

    return ErrorDetails(
      title: title,
      message: error,
      category: category,
      severity: forceSeverity ?? severity,
      screen: screen,
      context: context,
      originalError: error,
    );
  }

  /// Parse exceptions
  static ErrorDetails _parseException(
      Exception exception, {
        String? context,
        String? screen,
        ErrorSeverity? forceSeverity,
      }) {
    String message = exception.toString();

    // Clean up exception message
    if (message.startsWith('Exception: ')) {
      message = message.substring(11);
    }

    // Determine category based on exception type
    ErrorCategory category = ErrorCategory.general;
    ErrorSeverity severity = ErrorSeverity.error;
    String title = 'System Error';

    if (exception.runtimeType.toString().contains('Socket') ||
        exception.runtimeType.toString().contains('Network')) {
      category = ErrorCategory.network;
      severity = ErrorSeverity.network;
      title = 'Network Error';
    } else if (exception.runtimeType.toString().contains('Format') ||
        exception.runtimeType.toString().contains('Argument')) {
      category = ErrorCategory.validation;
      severity = ErrorSeverity.validation;
      title = 'Validation Error';
    } else if (exception.runtimeType.toString().contains('File') ||
        exception.runtimeType.toString().contains('Path')) {
      category = ErrorCategory.storage;
      severity = ErrorSeverity.error;
      title = 'File Error';
    }

    return ErrorDetails(
      title: title,
      message: message,
      category: category,
      severity: forceSeverity ?? severity,
      screen: screen,
      context: context,
      originalError: exception,
    );
  }

  /// Parse unknown errors
  static ErrorDetails _parseUnknownError(
      dynamic error, {
        String? context,
        String? screen,
        ErrorSeverity? forceSeverity,
      }) {
    return ErrorDetails(
      title: 'Unknown Error',
      message: 'An unexpected error occurred: ${error?.toString() ?? 'No details available'}',
      category: ErrorCategory.general,
      severity: forceSeverity ?? ErrorSeverity.error,
      screen: screen,
      context: context,
      originalError: error,
    );
  }

  /// Get user-friendly message based on error category
  static String getUserFriendlyMessage(ErrorCategory category, String originalMessage) {
    switch (category) {
      case ErrorCategory.network:
        return 'Please check your internet connection and try again';
      case ErrorCategory.authentication:
        return 'Please login again to continue';
      case ErrorCategory.validation:
        return originalMessage; // Keep original validation messages
      case ErrorCategory.permission:
        return 'You don\'t have permission to perform this action';
      case ErrorCategory.storage:
        return 'There was a problem with the file operation';
      case ErrorCategory.storage:
        return 'There was a problem with the folder operation';
      case ErrorCategory.server:
        if (originalMessage.isNotEmpty) return originalMessage;
        return 'There was a problem connecting to our servers';
      case ErrorCategory.general:
        return 'A system error occurred. Please try again';
      case ErrorCategory.general:
        return 'Something went wrong. Please try again';
      case ErrorCategory.upload:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ErrorCategory.download:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  /// Get suggested actions based on error category
  static List<ErrorAction> getSuggestedActions(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.network:
        return [ErrorAction.retry, ErrorAction.refresh];
      case ErrorCategory.authentication:
        return [ErrorAction.login, ErrorAction.retry];
      case ErrorCategory.validation:
        return [ErrorAction.dismiss];
      case ErrorCategory.permission:
        return [ErrorAction.settings, ErrorAction.contact];
      case ErrorCategory.storage:
        return [ErrorAction.retry, ErrorAction.refresh];
      case ErrorCategory.server:
        return [ErrorAction.retry, ErrorAction.refresh];
      case ErrorCategory.general:
        return [ErrorAction.retry, ErrorAction.contact];
      case ErrorCategory.upload:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ErrorCategory.download:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}