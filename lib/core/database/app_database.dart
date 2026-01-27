import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Import tables
import 'tables/ledgers_table.dart';
import 'tables/transactions_table.dart';
import 'tables/sync_queue_table.dart';

// Import DAOs
import 'daos/ledger_dao.dart';
import 'daos/transaction_dao.dart';
import 'daos/sync_queue_dao.dart';

part 'app_database.g.dart';

/// Main application database
/// Uses Drift (SQLite) for offline-first data storage
@DriftDatabase(
  tables: [Ledgers, Transactions, SyncQueue],
  daos: [LedgerDao, TransactionDao, SyncQueueDao],
)
class AppDatabase extends _$AppDatabase {
  // Singleton instance
  static AppDatabase? _instance;

  // Private constructor
  AppDatabase._() : super(_openConnection());

  // Factory constructor for singleton
  factory AppDatabase() {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  // Get singleton instance
  static AppDatabase get instance => AppDatabase();

  // Schema version - increment when tables change
  @override
  int get schemaVersion => 3;

  // Migration strategy
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migration from version 1 to 2: Add balance columns to transactions
        if (from < 2) {
          // Using raw SQL to avoid dependency on generated code
          await customStatement('ALTER TABLE transactions ADD COLUMN current_balance REAL NOT NULL DEFAULT 0.0');
          await customStatement('ALTER TABLE transactions ADD COLUMN last_balance REAL NOT NULL DEFAULT 0.0');
        }
        if (from < 3) {
          await customStatement('ALTER TABLE ledgers ADD COLUMN transaction_date INTEGER');
        }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Clear all data (useful for logout)
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(syncQueue).go();
      await delete(transactions).go();
      await delete(ledgers).go();
    });
  }

  // Clear only sync queue
  Future<void> clearSyncQueue() async {
    await delete(syncQueue).go();
  }

  // Get database file path (for debugging)
  static Future<String> getDatabasePath() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return '${dbFolder.path}/aukra_offline.db';
  }

  // Check if database exists
  static Future<bool> databaseExists() async {
    final path = await getDatabasePath();
    return File(path).exists();
  }

  // Delete database file (for reset)
  static Future<void> deleteDatabase() async {
    final path = await getDatabasePath();
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    _instance = null;
  }
}

// Database connection
QueryExecutor _openConnection() {
  return driftDatabase(name: 'aukra_offline');
}
