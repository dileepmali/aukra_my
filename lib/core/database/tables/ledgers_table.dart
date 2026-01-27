import 'package:drift/drift.dart';

/// Ledgers table - stores customers, suppliers, employees
/// This is the offline cache for ledger data from API
class Ledgers extends Table {
  // Primary key - same as server ID
  IntColumn get id => integer()();

  // Merchant relationship
  IntColumn get merchantId => integer()();

  // Ledger details
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get partyType => text().withDefault(const Constant('CUSTOMER'))(); // CUSTOMER, SUPPLIER, EMPLOYEE

  // Balance information
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
  RealColumn get openingBalance => real().withDefault(const Constant(0.0))();
  TextColumn get transactionType => text().withDefault(const Constant('IN'))(); // IN, OUT

  // Credit settings
  RealColumn get creditLimit => real().withDefault(const Constant(0.0))();
  IntColumn get creditDay => integer().withDefault(const Constant(0))();
  TextColumn get interestType => text().withDefault(const Constant('YEARLY'))(); // YEARLY, MONTHLY
  RealColumn get interestRate => real().withDefault(const Constant(0.0))();

  // Contact info
  TextColumn get mobileNumber => text().withDefault(const Constant(''))();
  TextColumn get area => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get pinCode => text().withDefault(const Constant(''))();

  // Sync tracking
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  TextColumn get localId => text().nullable()(); // For offline created records

  // Timestamps
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get transactionDate => dateTime().nullable()(); // Last transaction date from API
  DateTimeColumn get localUpdatedAt => dateTime().nullable()(); // Local modification time

  // Status
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
