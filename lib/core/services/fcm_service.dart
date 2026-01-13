import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../api/fcm_token_api.dart';
import '../api/auth_storage.dart';
import 'device_info_service.dart';

/// Service for Firebase Cloud Messaging (Push Notifications)
class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FcmTokenApi _fcmTokenApi = FcmTokenApi();

  // Cached values
  static String? _fcmToken;
  static int? _tokenId; // Backend token ID for updates/delete

  /// Initialize FCM Service
  /// Call this after Firebase.initializeApp() and user login
  static Future<void> init() async {
    try {
      debugPrint('');
      debugPrint('🔔 ========== FCM SERVICE INIT ==========');

      // Request notification permission
      final settings = await _requestPermission();
      debugPrint('   Permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        await _getAndRegisterToken();

        // Listen for token refresh
        _setupTokenRefreshListener();

        // Setup foreground notification handler
        _setupForegroundHandler();

        debugPrint('✅ FCM Service initialized successfully');
      } else {
        debugPrint('⚠️ Notification permission denied');
      }

      debugPrint('==========================================');
      debugPrint('');
    } catch (e) {
      debugPrint('❌ FCM Service Init Error: $e');
    }
  }

  /// Request notification permission
  static Future<NotificationSettings> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    return settings;
  }

  /// Get FCM token and register with backend
  static Future<void> _getAndRegisterToken() async {
    try {
      // Get FCM token from Firebase
      _fcmToken = await _messaging.getToken();

      if (_fcmToken != null) {
        debugPrint('   FCM Token: ${_fcmToken!.substring(0, 30)}...');

        // Check if user is logged in
        final isLoggedIn = await AuthStorage.isLoggedIn();
        if (isLoggedIn) {
          await registerTokenWithBackend();
        } else {
          debugPrint('   ⚠️ User not logged in, skipping backend registration');
        }
      } else {
        debugPrint('   ⚠️ Failed to get FCM token');
      }
    } catch (e) {
      debugPrint('❌ Get FCM Token Error: $e');
    }
  }

  /// Register FCM token with backend
  static Future<void> registerTokenWithBackend() async {
    try {
      if (_fcmToken == null) {
        _fcmToken = await _messaging.getToken();
      }

      if (_fcmToken == null) {
        debugPrint('⚠️ No FCM token to register');
        return;
      }

      debugPrint('📤 Registering FCM token with backend...');

      // Check if token already exists for this device
      final existingToken = await _fcmTokenApi.getCurrentDeviceToken();

      if (existingToken != null && existingToken.id != null) {
        // Update existing token
        debugPrint('   Updating existing token (ID: ${existingToken.id})');
        final updated = await _fcmTokenApi.updateToken(
          tokenId: existingToken.id!,
          fcmToken: _fcmToken!,
        );
        _tokenId = updated?.id;
      } else {
        // Register new token
        debugPrint('   Registering new token');
        final registered = await _fcmTokenApi.registerToken(
          fcmToken: _fcmToken!,
        );
        _tokenId = registered?.id;
      }

      // Save token ID locally
      if (_tokenId != null) {
        await AuthStorage.saveFcmTokenId(_tokenId!);
        debugPrint('✅ FCM token registered with backend (ID: $_tokenId)');
      }
    } catch (e) {
      debugPrint('❌ Register FCM Token Error: $e');
    }
  }

  /// Setup listener for token refresh
  static void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('🔄 FCM Token Refreshed');
      _fcmToken = newToken;

      // Update token on backend
      final isLoggedIn = await AuthStorage.isLoggedIn();
      if (isLoggedIn) {
        await registerTokenWithBackend();
      }
    });
  }

  /// Setup foreground notification handler
  static void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Foreground Notification Received');
      debugPrint('   Title: ${message.notification?.title}');
      debugPrint('   Body: ${message.notification?.body}');
      debugPrint('   Data: ${message.data}');

      // Handle notification (show local notification, update UI, etc.)
      _handleNotification(message);
    });
  }

  /// Handle incoming notification
  static void _handleNotification(RemoteMessage message) {
    // TODO: Implement notification handling
    // - Show local notification
    // - Update UI/state
    // - Navigate to specific screen
    debugPrint('🔔 Processing notification: ${message.notification?.title}');
  }

  /// Delete FCM token on logout
  static Future<void> deleteToken() async {
    try {
      debugPrint('📤 Deleting FCM token...');

      // Get saved token ID
      _tokenId ??= await AuthStorage.getFcmTokenId();

      if (_tokenId != null) {
        await _fcmTokenApi.deleteToken(tokenId: _tokenId!);
        debugPrint('✅ FCM token deleted from backend');
      }

      // Clear local storage
      await AuthStorage.clearFcmTokenId();
      _tokenId = null;

      // Delete token from Firebase
      await _messaging.deleteToken();
      _fcmToken = null;

      debugPrint('✅ FCM token deleted successfully');
    } catch (e) {
      debugPrint('❌ Delete FCM Token Error: $e');
    }
  }

  /// Deactivate all tokens (logout from all devices)
  static Future<void> deactivateAllTokens() async {
    try {
      debugPrint('📤 Deactivating all FCM tokens...');
      await _fcmTokenApi.deactivateAllTokens();
      debugPrint('✅ All FCM tokens deactivated');
    } catch (e) {
      debugPrint('❌ Deactivate All Tokens Error: $e');
    }
  }

  /// Get current FCM token
  static String? get fcmToken => _fcmToken;

  /// Get backend token ID
  static int? get tokenId => _tokenId;

  /// Check if FCM is initialized
  static bool get isInitialized => _fcmToken != null;
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 Background Notification Received');
  debugPrint('   Title: ${message.notification?.title}');
  debugPrint('   Body: ${message.notification?.body}');
  // Handle background notification
}
