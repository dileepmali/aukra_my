import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Service to monitor internet connectivity
/// Used to trigger sync when coming back online
class ConnectivityService extends GetxService {
  static ConnectivityService get instance => Get.find<ConnectivityService>();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  // Observable connectivity state
  final RxBool isConnected = true.obs;
  final Rx<ConnectivityResult> connectionType = ConnectivityResult.none.obs;

  // Callbacks for connectivity changes
  final List<VoidCallback> _onConnectedCallbacks = [];
  final List<VoidCallback> _onDisconnectedCallbacks = [];

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _startListening();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _onConnectedCallbacks.clear();
    _onDisconnectedCallbacks.clear();
    super.onClose();
  }

  /// Initialize connectivity check
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('❌ Error checking connectivity: $e');
      isConnected.value = true; // Assume connected on error
    }
  }

  /// Start listening to connectivity changes
  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (e) {
        debugPrint('❌ Connectivity stream error: $e');
      },
    );
  }

  /// Update connection status based on results
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = isConnected.value;

    // Check if any connection is available
    final hasConnection = results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);

    isConnected.value = hasConnection;

    // Update connection type (use first available)
    if (results.isNotEmpty) {
      connectionType.value = results.first;
    } else {
      connectionType.value = ConnectivityResult.none;
    }

    debugPrint('📶 Connectivity changed: ${connectionType.value} (connected: $hasConnection)');

    // Trigger callbacks on state change
    if (!wasConnected && hasConnection) {
      // Just came online
      debugPrint('✅ Device is now ONLINE - triggering sync callbacks');
      _triggerOnConnectedCallbacks();
    } else if (wasConnected && !hasConnection) {
      // Just went offline
      debugPrint('📴 Device is now OFFLINE');
      _triggerOnDisconnectedCallbacks();
    }
  }

  /// Check current connectivity (one-time check)
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasConnection = results.any((result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet);
      isConnected.value = hasConnection;
      return hasConnection;
    } catch (e) {
      debugPrint('❌ Error checking connectivity: $e');
      return true; // Assume connected on error
    }
  }

  /// Register callback for when device comes online
  void onConnected(VoidCallback callback) {
    _onConnectedCallbacks.add(callback);
  }

  /// Remove connected callback
  void removeOnConnected(VoidCallback callback) {
    _onConnectedCallbacks.remove(callback);
  }

  /// Register callback for when device goes offline
  void onDisconnected(VoidCallback callback) {
    _onDisconnectedCallbacks.add(callback);
  }

  /// Remove disconnected callback
  void removeOnDisconnected(VoidCallback callback) {
    _onDisconnectedCallbacks.remove(callback);
  }

  /// Trigger all connected callbacks
  void _triggerOnConnectedCallbacks() {
    for (final callback in _onConnectedCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('❌ Error in onConnected callback: $e');
      }
    }
  }

  /// Trigger all disconnected callbacks
  void _triggerOnDisconnectedCallbacks() {
    for (final callback in _onDisconnectedCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('❌ Error in onDisconnected callback: $e');
      }
    }
  }

  /// Get human-readable connection type
  String get connectionTypeString {
    switch (connectionType.value) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
      default:
        return 'No Connection';
    }
  }
}
