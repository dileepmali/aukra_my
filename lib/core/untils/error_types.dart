import 'dart:ui';

/// 🎯 Error Types & Enums - Centralized error categorization
/// Purpose: Define all error types, severities, and display options

/// Error severity levels
enum ErrorSeverity {
  low,        // Toast message (2s)
  medium,     // Snackbar with action (4s)
  high,       // Snackbar with longer duration (5s)
  // Legacy values for backward compatibility
  error,      // Red - Errors
  network,    // Grey - Network issues
  auth,       // Purple - Authentication issues
  validation, // Yellow - Validation errors
}

/// Error display types
enum ErrorDisplayType {
  topSnackbar,    // Top snackbar (default)
  bottomSnackbar, // Bottom snackbar
  dialog,         // Modal dialog
  bottomSheet,    // Bottom sheet
  toast,          // Simple toast
}

/// Error categories for analytics
enum ErrorCategory {
  network,        // Internet/connectivity errors
  server,         // API/server errors
  validation,     // Input validation errors
  authentication, // Login/auth errors
  permission,     // Permissions errors
  storage,        // File system errors
  upload,         // Upload errors
  download,       // Download errors
  general,        // General/unknown errors
}

/// Error action types
enum ErrorAction {
  retry,      // Retry the operation
  login,      // Navigate to login
  refresh,    // Refresh data
  contact,    // Contact support
  dismiss,    // Just dismiss
  settings,   // Go to settings
}

/// Error details data class
class ErrorDetails {
  final String title;
  final String message;
  final ErrorCategory category;
  final ErrorSeverity severity;
  final String? screen;
  final String? context;
  final dynamic originalError;
  final DateTime timestamp;

  ErrorDetails({
    required this.title,
    required this.message,
    required this.category,
    this.severity = ErrorSeverity.error,
    this.screen,
    this.context,
    this.originalError,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Convert to JSON for logging
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'category': category.toString(),
      'severity': severity.toString(),
      'screen': screen,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ErrorDetails.fromJson(Map<String, dynamic> json) {
    return ErrorDetails(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      category: ErrorCategory.values.firstWhere(
            (e) => e.toString() == json['category'],
        orElse: () => ErrorCategory.general,
      ),
      severity: ErrorSeverity.values.firstWhere(
            (e) => e.toString() == json['severity'],
        orElse: () => ErrorSeverity.error,
      ),
      screen: json['screen'],
      context: json['context'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Error action data class
class ErrorActionData {
  final ErrorAction action;
  final String label;
  final VoidCallback? onPressed;

  ErrorActionData({
    required this.action,
    required this.label,
    this.onPressed,
  });
}

/// Error configuration for different display types
class ErrorDisplayConfig {
  final ErrorDisplayType type;
  final Duration duration;
  final bool isDismissible;
  final bool showRetry;
  final bool logError;

  const ErrorDisplayConfig({
    this.type = ErrorDisplayType.topSnackbar,
    this.duration = const Duration(seconds: 4),
    this.isDismissible = true,
    this.showRetry = false,
    this.logError = true,
  });
}

/// Success message types
enum SuccessType {
  snackbar, // Medium feedback (3s)
}