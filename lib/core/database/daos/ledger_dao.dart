import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/ledgers_table.dart';

part 'ledger_dao.g.dart';

/// Data Access Object for Ledgers table
/// Handles all CRUD operations and queries for ledgers
@DriftAccessor(tables: [Ledgers])
class LedgerDao extends DatabaseAccessor<AppDatabase> with _$LedgerDaoMixin {
  LedgerDao(AppDatabase db) : super(db);

  // ============ CREATE ============

  /// Insert a single ledger
  Future<int> insertLedger(LedgersCompanion ledger) {
    return into(ledgers).insert(ledger);
  }

  /// Insert or update ledger (upsert)
  Future<int> upsertLedger(LedgersCompanion ledger) {
    return into(ledgers).insertOnConflictUpdate(ledger);
  }

  /// Bulk insert ledgers (for initial sync)
  Future<void> insertMultipleLedgers(List<LedgersCompanion> ledgerList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(ledgers, ledgerList);
    });
  }

  // ============ READ ============

  /// Get all ledgers
  Future<List<Ledger>> getAllLedgers() {
    return select(ledgers).get();
  }

  /// Watch all ledgers (reactive stream)
  Stream<List<Ledger>> watchAllLedgers() {
    return select(ledgers).watch();
  }

  /// Get ledgers by merchant ID
  Future<List<Ledger>> getLedgersByMerchant(int merchantId) {
    return (select(ledgers)..where((l) => l.merchantId.equals(merchantId))).get();
  }

  /// Watch ledgers by merchant ID
  Stream<List<Ledger>> watchLedgersByMerchant(int merchantId) {
    return (select(ledgers)..where((l) => l.merchantId.equals(merchantId))).watch();
  }

  /// Get ledgers by party type (CUSTOMER, SUPPLIER, EMPLOYEE)
  Future<List<Ledger>> getLedgersByPartyType(int merchantId, String partyType) {
    return (select(ledgers)
          ..where((l) => l.merchantId.equals(merchantId) & l.partyType.equals(partyType))
          ..where((l) => l.isActive.equals(true)))
        .get();
  }

  /// Watch ledgers by party type
  Stream<List<Ledger>> watchLedgersByPartyType(int merchantId, String partyType) {
    return (select(ledgers)
          ..where((l) => l.merchantId.equals(merchantId) & l.partyType.equals(partyType))
          ..where((l) => l.isActive.equals(true)))
        .watch();
  }

  /// Get ledger by ID
  Future<Ledger?> getLedgerById(int id) {
    return (select(ledgers)..where((l) => l.id.equals(id))).getSingleOrNull();
  }

  /// Watch single ledger by ID
  Stream<Ledger?> watchLedgerById(int id) {
    return (select(ledgers)..where((l) => l.id.equals(id))).watchSingleOrNull();
  }

  /// Get ledger by local ID (for offline created)
  Future<Ledger?> getLedgerByLocalId(String localId) {
    return (select(ledgers)..where((l) => l.localId.equals(localId))).getSingleOrNull();
  }

  /// Search ledgers by name
  Future<List<Ledger>> searchLedgers(int merchantId, String query) {
    final lowerQuery = '%${query.toLowerCase()}%';
    return (select(ledgers)
          ..where((l) =>
              l.merchantId.equals(merchantId) &
              l.isActive.equals(true) &
              (l.name.lower().like(lowerQuery) | l.mobileNumber.like(lowerQuery))))
        .get();
  }

  /// Get unsynced ledgers
  Future<List<Ledger>> getUnsyncedLedgers() {
    return (select(ledgers)..where((l) => l.isSynced.equals(false))).get();
  }

  /// Get deactivated ledgers
  Future<List<Ledger>> getDeactivatedLedgers(int merchantId) {
    return (select(ledgers)
          ..where((l) => l.merchantId.equals(merchantId) & l.isActive.equals(false)))
        .get();
  }

  /// Get ledger count by party type
  Future<int> getLedgerCount(int merchantId, String partyType) async {
    final count = countAll();
    final query = selectOnly(ledgers)
      ..addColumns([count])
      ..where(ledgers.merchantId.equals(merchantId) &
          ledgers.partyType.equals(partyType) &
          ledgers.isActive.equals(true));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Get total balance by party type
  Future<double> getTotalBalance(int merchantId, String partyType, String transactionType) async {
    final sum = ledgers.currentBalance.sum();
    final query = selectOnly(ledgers)
      ..addColumns([sum])
      ..where(ledgers.merchantId.equals(merchantId) &
          ledgers.partyType.equals(partyType) &
          ledgers.transactionType.equals(transactionType) &
          ledgers.isActive.equals(true));
    final result = await query.getSingle();
    return result.read(sum) ?? 0.0;
  }

  // ============ UPDATE ============

  /// Update ledger
  Future<bool> updateLedger(Ledger ledger) {
    return update(ledgers).replace(ledger);
  }

  /// Update ledger by ID
  Future<int> updateLedgerById(int id, LedgersCompanion ledger) {
    return (update(ledgers)..where((l) => l.id.equals(id))).write(ledger);
  }

  /// Mark ledger as synced
  Future<int> markLedgerAsSynced(int id, {int? serverId}) {
    return (update(ledgers)..where((l) => l.id.equals(id))).write(
      LedgersCompanion(
        isSynced: const Value(true),
        id: serverId != null ? Value(serverId) : const Value.absent(),
      ),
    );
  }

  /// Update ledger balance
  Future<int> updateLedgerBalance(int id, double newBalance) {
    return (update(ledgers)..where((l) => l.id.equals(id))).write(
      LedgersCompanion(
        currentBalance: Value(newBalance),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Deactivate ledger
  Future<int> deactivateLedger(int id) {
    return (update(ledgers)..where((l) => l.id.equals(id))).write(
      const LedgersCompanion(
        isActive: Value(false),
        isSynced: Value(false),
      ),
    );
  }

  /// Activate ledger
  Future<int> activateLedger(int id) {
    return (update(ledgers)..where((l) => l.id.equals(id))).write(
      const LedgersCompanion(
        isActive: Value(true),
        isSynced: Value(false),
      ),
    );
  }

  // ============ DELETE ============

  /// Delete ledger by ID
  Future<int> deleteLedgerById(int id) {
    return (delete(ledgers)..where((l) => l.id.equals(id))).go();
  }

  /// Delete all ledgers for a merchant
  Future<int> deleteLedgersByMerchant(int merchantId) {
    return (delete(ledgers)..where((l) => l.merchantId.equals(merchantId))).go();
  }

  /// Delete all ledgers
  Future<int> deleteAllLedgers() {
    return delete(ledgers).go();
  }
}
