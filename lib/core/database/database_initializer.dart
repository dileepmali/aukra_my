import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'app_database.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import 'repositories/ledger_repository.dart';
import 'repositories/transaction_repository.dart';

/// Helper class to initialize database and related services
class DatabaseInitializer {
  static bool _initialized = false;

  /// Initialize database and services
  /// Call this in main.dart before runApp
  static Future<void> initialize() async {
    if (_initialized) {
      debugPrint('⚠️ Database already initialized');
      return;
    }

    debugPrint('🚀 Initializing offline database...');

    try {
      // 1. Initialize database (singleton)
      final db = AppDatabase.instance;
      debugPrint('✅ Database instance created');

      // 2. Register services with GetX
      // Connectivity Service
      Get.put(ConnectivityService(), permanent: true);
      debugPrint('✅ ConnectivityService registered');

      // Sync Service (depends on ConnectivityService)
      Get.put(SyncService(), permanent: true);
      debugPrint('✅ SyncService registered');

      // 3. Register repositories
      Get.lazyPut(() => LedgerRepository(), fenix: true);
      Get.lazyPut(() => TransactionRepository(), fenix: true);
      debugPrint('✅ Repositories registered');

      _initialized = true;
      debugPrint('🎉 Offline database initialization complete!');
    } catch (e) {
      debugPrint('❌ Error initializing database: $e');
      rethrow;
    }
  }

  /// Check if database is initialized
  static bool get isInitialized => _initialized;

  /// Reset database (for logout or testing)
  static Future<void> reset() async {
    debugPrint('🔄 Resetting database...');

    try {
      // Clear all data
      await AppDatabase.instance.clearAllData();
      debugPrint('✅ Database data cleared');

      // Reset sync service
      if (Get.isRegistered<SyncService>()) {
        await SyncService.instance.clearSyncQueue();
      }

      debugPrint('✅ Database reset complete');
    } catch (e) {
      debugPrint('❌ Error resetting database: $e');
    }
  }

  /// Delete database completely (for app reset)
  static Future<void> deleteDatabase() async {
    debugPrint('🗑️ Deleting database...');

    try {
      await AppDatabase.deleteDatabase();
      _initialized = false;
      debugPrint('✅ Database deleted');
    } catch (e) {
      debugPrint('❌ Error deleting database: $e');
    }
  }

  /// Get database statistics
  static Future<Map<String, dynamic>> getStats() async {
    final db = AppDatabase.instance;

    final ledgerCount = await db.ledgerDao.getAllLedgers().then((l) => l.length);
    final transactionCount = await db.transactionDao.getAllTransactions().then((t) => t.length);
    final pendingSyncCount = await db.syncQueueDao.getPendingCount();
    final dbExists = await AppDatabase.databaseExists();
    final dbPath = await AppDatabase.getDatabasePath();

    return {
      'initialized': _initialized,
      'databaseExists': dbExists,
      'databasePath': dbPath,
      'ledgerCount': ledgerCount,
      'transactionCount': transactionCount,
      'pendingSyncCount': pendingSyncCount,
    };
  }
}
