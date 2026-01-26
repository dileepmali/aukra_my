import 'package:drift/drift.dart';

/// Transactions table - stores all ledger transactions
/// This is the offline cache for transaction data from API
class Transactions extends Table {
  // Primary key - auto increment for local, server ID when synced
  IntColumn get id => integer().autoIncrement()();

  // Server ID - null for offline created, set after sync
  IntColumn get serverId => integer().nullable()();

  // Relationships
  IntColumn get ledgerId => integer()();
  IntColumn get merchantId => integer()();

  // Transaction details
  RealColumn get transactionAmount => real()();
  TextColumn get transactionType => text()(); // IN, OUT
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get comments => text().nullable()();

  // Party action
  TextColumn get partyMerchantAction => text().withDefault(const Constant('VIEW'))();

  // Attached images (stored as JSON array of keys)
  TextColumn get uploadedKeys => text().nullable()();

  // Security
  TextColumn get securityKey => text().withDefault(const Constant(''))();

  // Sync tracking
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  TextColumn get localId => text().nullable()(); // UUID for offline created records

  // Timestamps
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  // Soft delete
  BoolColumn get isDelete => boolean().withDefault(const Constant(false))();

  // Balance tracking (for offline display)
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
  RealColumn get lastBalance => real().withDefault(const Constant(0.0))();
}
