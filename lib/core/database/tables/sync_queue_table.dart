import 'package:drift/drift.dart';

/// Sync Queue table - tracks pending offline changes to sync with server
/// When user creates/updates/deletes data offline, it goes here first
class SyncQueue extends Table {
  // Auto increment primary key
  IntColumn get id => integer().autoIncrement()();

  // Which table this change belongs to
  TextColumn get targetTable => text()(); // 'ledgers', 'transactions'

  // Record identifier
  IntColumn get recordId => integer().nullable()(); // Local table ID
  TextColumn get localId => text().nullable()(); // UUID for new records

  // What action to perform
  TextColumn get action => text()(); // CREATE, UPDATE, DELETE

  // JSON payload of the data to send
  TextColumn get payload => text()();

  // API endpoint to call
  TextColumn get endpoint => text()();

  // HTTP method
  TextColumn get method => text().withDefault(const Constant('POST'))(); // POST, PUT, PATCH, DELETE

  // Sync status
  TextColumn get status => text().withDefault(const Constant('PENDING'))(); // PENDING, IN_PROGRESS, FAILED, COMPLETED

  // Error tracking
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get lastAttempt => dateTime().nullable()();

  // Timestamps
  DateTimeColumn get createdAt => dateTime()();

  // Priority (lower = higher priority)
  IntColumn get priority => integer().withDefault(const Constant(0))();
}
