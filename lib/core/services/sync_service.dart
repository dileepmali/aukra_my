import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../database/app_database.dart';
import '../api/global_api_function.dart';
import 'connectivity_service.dart';

/// Service to sync offline changes with the server
/// Processes the sync queue when device is online
class SyncService extends GetxService {
  static SyncService get instance => Get.find<SyncService>();

  final AppDatabase _db = AppDatabase.instance;
  late final ConnectivityService _connectivity;

  // Sync state
  final RxBool isSyncing = false.obs;
  final RxInt pendingCount = 0.obs;
  final RxString lastSyncTime = ''.obs;
  final RxString lastError = ''.obs;

  // Sync lock to prevent concurrent syncs
  bool _syncLock = false;

  // Timer for periodic sync
  Timer? _syncTimer;

  // Sync complete callbacks - controllers can register to refresh after sync
  final List<Function(bool hadTransactions)> _syncCompleteCallbacks = [];

  /// Register a callback to be called when sync completes
  void onSyncComplete(Function(bool hadTransactions) callback) {
    _syncCompleteCallbacks.add(callback);
  }

  /// Remove a sync complete callback
  void removeSyncCompleteCallback(Function(bool hadTransactions) callback) {
    _syncCompleteCallbacks.remove(callback);
  }

  /// Notify all sync complete callbacks
  void _notifySyncComplete(bool hadTransactions) {
    debugPrint('📢 Notifying ${_syncCompleteCallbacks.length} callbacks of sync completion');
    for (final callback in _syncCompleteCallbacks) {
      try {
        callback(hadTransactions);
      } catch (e) {
        debugPrint('⚠️ Sync callback error: $e');
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    _connectivity = ConnectivityService.instance;

    // Listen for connectivity changes
    _connectivity.onConnected(_onDeviceOnline);

    // Start watching pending count
    _watchPendingCount();

    // Initial sync check
    _checkAndSync();

    // Periodic sync every 5 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) => _checkAndSync());
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    _connectivity.removeOnConnected(_onDeviceOnline);
    super.onClose();
  }

  /// Watch pending sync count
  void _watchPendingCount() {
    _db.syncQueueDao.watchPendingCount().listen((count) {
      pendingCount.value = count;
      debugPrint('📊 Pending sync items: $count');
    });
  }

  /// Called when device comes online
  void _onDeviceOnline() {
    debugPrint('🌐 Device online - starting sync');
    syncNow();
  }

  /// Check connectivity and sync if online
  Future<void> _checkAndSync() async {
    if (await _connectivity.checkConnectivity()) {
      await syncNow();
    }
  }

  /// Manually trigger sync
  Future<bool> syncNow() async {
    // Prevent concurrent syncs
    if (_syncLock) {
      debugPrint('⏳ Sync already in progress, skipping...');
      return false;
    }

    // Check connectivity
    if (!_connectivity.isConnected.value) {
      debugPrint('📴 Device offline, cannot sync');
      return false;
    }

    _syncLock = true;
    isSyncing.value = true;
    lastError.value = '';

    try {
      debugPrint('🔄 Starting sync process...');

      // Get pending items ordered by priority
      final pendingItems = await _db.syncQueueDao.getPendingItems();

      if (pendingItems.isEmpty) {
        debugPrint('✅ No pending items to sync');
        lastSyncTime.value = DateTime.now().toIso8601String();
        return true;
      }

      debugPrint('📤 Syncing ${pendingItems.length} items...');

      int successCount = 0;
      int failCount = 0;

      for (final item in pendingItems) {
        // Check connectivity before each item
        if (!_connectivity.isConnected.value) {
          debugPrint('📴 Lost connection during sync, stopping...');
          break;
        }

        final success = await _processQueueItem(item);
        if (success) {
          successCount++;
        } else {
          failCount++;
        }

        // Small delay between requests
        await Future.delayed(const Duration(milliseconds: 100));
      }

      debugPrint('✅ Sync completed: $successCount success, $failCount failed');
      lastSyncTime.value = DateTime.now().toIso8601String();

      // Clean up completed items
      await _db.syncQueueDao.deleteCompletedItems();

      // Notify callbacks that sync completed
      final hadTransactions = pendingItems.any((item) => item.targetTable == 'transactions');
      _notifySyncComplete(hadTransactions);

      return failCount == 0;
    } catch (e) {
      debugPrint('❌ Sync error: $e');
      lastError.value = e.toString();
      return false;
    } finally {
      _syncLock = false;
      isSyncing.value = false;
    }
  }

  /// Process a single queue item
  Future<bool> _processQueueItem(SyncQueueData item) async {
    try {
      debugPrint('📤 Processing: ${item.targetTable} - ${item.action} (ID: ${item.id})');

      // Mark as in progress
      await _db.syncQueueDao.markInProgress(item.id);

      // Create API fetcher
      final apiFetcher = ApiFetcher();

      // Parse payload
      final payload = item.payload.isNotEmpty ? jsonDecode(item.payload) : null;

      // Make API request
      await apiFetcher.request(
        url: item.endpoint,
        method: item.method,
        body: payload is Map<String, dynamic> ? payload : null,
        requireAuth: true,
      );

      // Check for errors
      if (apiFetcher.errorMessage != null) {
        debugPrint('❌ API error: ${apiFetcher.errorMessage}');
        await _db.syncQueueDao.markFailed(item.id, apiFetcher.errorMessage!);
        return false;
      }

      // Handle response based on action
      await _handleSyncResponse(item, apiFetcher.data);

      // Mark as completed
      await _db.syncQueueDao.markCompleted(item.id);
      debugPrint('✅ Synced: ${item.targetTable} - ${item.action}');

      return true;
    } catch (e) {
      debugPrint('❌ Error processing queue item: $e');
      await _db.syncQueueDao.markFailed(item.id, e.toString());
      return false;
    }
  }

  /// Handle successful sync response
  Future<void> _handleSyncResponse(SyncQueueData item, dynamic responseData) async {
    try {
      debugPrint('📥 Handling sync response for ${item.targetTable} - ${item.action}');
      debugPrint('📥 Response data type: ${responseData.runtimeType}');
      debugPrint('📥 Response data: $responseData');

      if (item.action == 'CREATE' && item.localId != null) {
        // Extract server ID from response and update local record
        int? serverId;

        if (responseData is Map) {
          // Try multiple paths to find the ID
          serverId = responseData['id'] as int? ??
                     responseData['transactionId'] as int? ??
                     (responseData['data'] is Map ? responseData['data']['id'] as int? : null) ??
                     (responseData['data'] is Map ? responseData['data']['transactionId'] as int? : null);

          debugPrint('📥 Extracted serverId: $serverId');
        }

        if (serverId != null) {
          if (item.targetTable == 'ledgers') {
            await _db.ledgerDao.markLedgerAsSynced(
              int.parse(item.localId!.split('_').last),
              serverId: serverId,
            );
            debugPrint('✅ Ledger linked with serverId: $serverId');
          } else if (item.targetTable == 'transactions') {
            await _db.transactionDao.markTransactionAsSyncedByLocalId(
              item.localId!,
              serverId,
            );
            debugPrint('✅ Transaction linked with serverId: $serverId');
          }
        } else {
          // Server didn't return ID - mark for refresh
          // The transaction will be linked when API data is fetched next
          debugPrint('⚠️ No serverId in response - transaction will be linked on next refresh');
          debugPrint('⚠️ localId: ${item.localId}');

          // Store the localId for tracking - the caching logic will link it later
          if (item.targetTable == 'transactions') {
            _pendingTransactionLinks.add(item.localId!);
          }
        }
      } else if (item.recordId != null) {
        // Update existing record as synced
        if (item.targetTable == 'ledgers') {
          await _db.ledgerDao.markLedgerAsSynced(item.recordId!);
        } else if (item.targetTable == 'transactions') {
          await _db.transactionDao.markTransactionAsSynced(item.recordId!, item.recordId!);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error handling sync response: $e');
      // Don't fail the sync for response handling errors
    }
  }

  // Track transactions that were synced but didn't get serverId
  final Set<String> _pendingTransactionLinks = {};

  /// Get pending transaction links (for refresh triggering)
  Set<String> get pendingTransactionLinks => _pendingTransactionLinks;

  /// Clear pending transaction links after refresh
  void clearPendingTransactionLinks() {
    _pendingTransactionLinks.clear();
  }

  /// Retry failed items
  Future<void> retryFailedItems() async {
    await _db.syncQueueDao.resetFailedItems();
    await syncNow();
  }

  /// Clear all pending sync items (use with caution)
  Future<void> clearSyncQueue() async {
    await _db.syncQueueDao.deleteAll();
    pendingCount.value = 0;
  }

  /// Get pending items for UI display
  Future<List<SyncQueueData>> getPendingItems() {
    return _db.syncQueueDao.getPendingItems();
  }
}
