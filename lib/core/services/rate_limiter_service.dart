import '../utils/secure_logger.dart';

/// Rate limiter service to prevent brute force attacks and spam
///
/// Usage:
/// ```dart
/// if (!RateLimiter.isAllowed('otp_verify', maxAttempts: 5, duration: Duration(minutes: 5))) {
///   // Show error - too many attempts
///   return;
/// }
/// ```
class RateLimiter {
  static final Map<String, List<DateTime>> _attempts = {};

  /// Check if action is allowed based on rate limiting rules
  ///
  /// [key] - Unique identifier for the action (e.g., 'otp_verify', 'create_transaction')
  /// [maxAttempts] - Maximum number of attempts allowed
  /// [duration] - Time window for rate limiting (default: 1 minute)
  ///
  /// Returns true if action is allowed, false if rate limit exceeded
  static bool isAllowed(
    String key, {
    int maxAttempts = 5,
    Duration duration = const Duration(minutes: 1),
  }) {
    final now = DateTime.now();

    // Get previous attempts for this key
    final attempts = _attempts[key] ?? [];

    // Remove old attempts outside the time window
    attempts.removeWhere((time) => now.difference(time) > duration);

    // Check if limit exceeded
    if (attempts.length >= maxAttempts) {
      SecureLogger.warning(
        'Rate limit exceeded for "$key": ${attempts.length}/$maxAttempts attempts in ${duration.inMinutes}m',
      );
      return false; // Rate limit exceeded
    }

    // Add current attempt
    attempts.add(now);
    _attempts[key] = attempts;

    SecureLogger.info(
      'Rate limit check for "$key": ${attempts.length}/$maxAttempts attempts',
    );

    return true; // Allowed
  }

  /// Get remaining cooldown time until next attempt is allowed
  ///
  /// Returns null if no cooldown is active
  /// Returns Duration if user must wait before next attempt
  static Duration? getRemainingCooldown(
    String key, {
    int maxAttempts = 5,
    Duration duration = const Duration(minutes: 1),
  }) {
    final attempts = _attempts[key] ?? [];

    // Clean up old attempts
    final now = DateTime.now();
    attempts.removeWhere((time) => now.difference(time) > duration);

    // If under limit, no cooldown
    if (attempts.isEmpty || attempts.length < maxAttempts) {
      return null;
    }

    // Calculate when the oldest attempt will expire
    final oldestAttempt = attempts.first;
    final cooldownEnd = oldestAttempt.add(duration);

    if (now.isBefore(cooldownEnd)) {
      return cooldownEnd.difference(now);
    }

    return null;
  }

  /// Get remaining attempts before rate limit is hit
  ///
  /// Returns number of attempts remaining
  static int getRemainingAttempts(
    String key, {
    int maxAttempts = 5,
    Duration duration = const Duration(minutes: 1),
  }) {
    final attempts = _attempts[key] ?? [];

    // Clean up old attempts
    final now = DateTime.now();
    attempts.removeWhere((time) => now.difference(time) > duration);

    final remaining = maxAttempts - attempts.length;
    return remaining > 0 ? remaining : 0;
  }

  /// Clear attempts for a specific key
  ///
  /// Useful after successful authentication or when resetting a user's attempts
  static void clearAttempts(String key) {
    _attempts.remove(key);
    SecureLogger.info('Cleared rate limit attempts for "$key"');
  }

  /// Clear all rate limit attempts
  ///
  /// Use with caution - typically only needed for logout or app reset
  static void clearAll() {
    _attempts.clear();
    SecureLogger.info('Cleared all rate limit attempts');
  }

  /// Get attempt count for a specific key
  ///
  /// Useful for debugging or showing user how many attempts they have
  static int getAttemptCount(String key) {
    final attempts = _attempts[key] ?? [];
    final now = DateTime.now();

    // Return only valid (non-expired) attempts
    return attempts.where((time) => now.difference(time) <= const Duration(minutes: 1)).length;
  }

  /// Format cooldown duration for user-friendly display
  ///
  /// Example: "2 minutes 30 seconds" or "45 seconds"
  static String formatCooldown(Duration? cooldown) {
    if (cooldown == null) {
      return 'No cooldown';
    }

    if (cooldown.inMinutes > 0) {
      final minutes = cooldown.inMinutes;
      final seconds = cooldown.inSeconds % 60;

      if (seconds > 0) {
        return '$minutes minute${minutes > 1 ? 's' : ''} $seconds second${seconds > 1 ? 's' : ''}';
      } else {
        return '$minutes minute${minutes > 1 ? 's' : ''}';
      }
    } else {
      final seconds = cooldown.inSeconds;
      return '$seconds second${seconds > 1 ? 's' : ''}';
    }
  }
}

/// Predefined rate limit configurations for common use cases
class RateLimitConfig {
  /// OTP verification: 5 attempts per 5 minutes
  static const otpVerify = RateLimitRule(
    maxAttempts: 5,
    duration: Duration(minutes: 5),
  );

  /// Security PIN: 3 attempts per 5 minutes (stricter)
  static const securityPin = RateLimitRule(
    maxAttempts: 3,
    duration: Duration(minutes: 5),
  );

  /// Transaction creation: 10 transactions per minute
  static const createTransaction = RateLimitRule(
    maxAttempts: 10,
    duration: Duration(minutes: 1),
  );

  /// Image upload: 5 uploads per minute
  static const imageUpload = RateLimitRule(
    maxAttempts: 5,
    duration: Duration(minutes: 1),
  );

  /// API calls (general): 30 requests per minute
  static const apiCall = RateLimitRule(
    maxAttempts: 30,
    duration: Duration(minutes: 1),
  );

  /// Login attempts: 5 attempts per 10 minutes
  static const login = RateLimitRule(
    maxAttempts: 5,
    duration: Duration(minutes: 10),
  );
}

/// Rate limit rule configuration
class RateLimitRule {
  final int maxAttempts;
  final Duration duration;

  const RateLimitRule({
    required this.maxAttempts,
    required this.duration,
  });
}
