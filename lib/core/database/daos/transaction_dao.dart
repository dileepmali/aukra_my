import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/transactions_table.dart';

part 'transaction_dao.g.dart';

/// Data Access Object for Transactions table
/// Handles all CRUD operations and queries for transactions
@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase> with _$TransactionDaoMixin {
  TransactionDao(AppDatabase db) : super(db);

  // ============ CREATE ============

  /// Insert a single transaction
  Future<int> insertTransaction(TransactionsCompanion transaction) {
    return into(transactions).insert(transaction);
  }

  /// Insert or update transaction (upsert by serverId)
  Future<int> upsertTransaction(TransactionsCompanion transaction) {
    return into(transactions).insertOnConflictUpdate(transaction);
  }

  /// Bulk insert transactions (for initial sync)
  Future<void> insertMultipleTransactions(List<TransactionsCompanion> transactionList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(transactions, transactionList);
    });
  }

  // ============ READ ============

  /// Get all transactions
  Future<List<Transaction>> getAllTransactions() {
    return select(transactions).get();
  }

  /// Watch all transactions (reactive stream)
  Stream<List<Transaction>> watchAllTransactions() {
    return select(transactions).watch();
  }

  /// Get transactions by ledger ID (excludes deleted for balance calculations)
  Future<List<Transaction>> getTransactionsByLedger(int ledgerId) {
    return (select(transactions)
          ..where((t) => t.ledgerId.equals(ledgerId) & t.isDelete.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  /// Get ALL transactions by ledger ID (includes deleted for UI display with strikethrough)
  Future<List<Transaction>> getAllTransactionsByLedgerForDisplay(int ledgerId) {
    return (select(transactions)
          ..where((t) => t.ledgerId.equals(ledgerId))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  /// Watch transactions by ledger ID
  Stream<List<Transaction>> watchTransactionsByLedger(int ledgerId) {
    return (select(transactions)
          ..where((t) => t.ledgerId.equals(ledgerId) & t.isDelete.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .watch();
  }

  /// Get transactions by merchant ID
  Future<List<Transaction>> getTransactionsByMerchant(int merchantId) {
    return (select(transactions)
          ..where((t) => t.merchantId.equals(merchantId) & t.isDelete.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  /// Get transaction by ID
  Future<Transaction?> getTransactionById(int id) {
    return (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Get transaction by server ID
  Future<Transaction?> getTransactionByServerId(int serverId) {
    return (select(transactions)..where((t) => t.serverId.equals(serverId))).getSingleOrNull();
  }

  /// Get transaction by local ID (for offline created)
  Future<Transaction?> getTransactionByLocalId(String localId) {
    return (select(transactions)..where((t) => t.localId.equals(localId))).getSingleOrNull();
  }

  /// Get unsynced transactions
  Future<List<Transaction>> getUnsyncedTransactions() {
    return (select(transactions)..where((t) => t.isSynced.equals(false))).get();
  }

  /// Get transactions by date range (excludes deleted for balance calculations)
  Future<List<Transaction>> getTransactionsByDateRange(
    int ledgerId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return (select(transactions)
          ..where((t) =>
              t.ledgerId.equals(ledgerId) &
              t.isDelete.equals(false) &
              t.transactionDate.isBiggerOrEqualValue(startDate) &
              t.transactionDate.isSmallerOrEqualValue(endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  /// Get ALL transactions by date range (includes deleted for UI display with strikethrough)
  Future<List<Transaction>> getAllTransactionsByDateRangeForDisplay(
    int ledgerId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return (select(transactions)
          ..where((t) =>
              t.ledgerId.equals(ledgerId) &
              t.transactionDate.isBiggerOrEqualValue(startDate) &
              t.transactionDate.isSmallerOrEqualValue(endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  /// Get today's transactions for a ledger
  Future<List<Transaction>> getTodayTransactions(int ledgerId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getTransactionsByDateRange(ledgerId, startOfDay, endOfDay);
  }

  /// Get transaction count for ledger
  Future<int> getTransactionCount(int ledgerId) async {
    final count = countAll();
    final query = selectOnly(transactions)
      ..addColumns([count])
      ..where(transactions.ledgerId.equals(ledgerId) & transactions.isDelete.equals(false));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Get total IN amount for ledger
  Future<double> getTotalInAmount(int ledgerId) async {
    final sum = transactions.transactionAmount.sum();
    final query = selectOnly(transactions)
      ..addColumns([sum])
      ..where(transactions.ledgerId.equals(ledgerId) &
          transactions.transactionType.equals('IN') &
          transactions.isDelete.equals(false));
    final result = await query.getSingle();
    return result.read(sum) ?? 0.0;
  }

  /// Get total OUT amount for ledger
  Future<double> getTotalOutAmount(int ledgerId) async {
    final sum = transactions.transactionAmount.sum();
    final query = selectOnly(transactions)
      ..addColumns([sum])
      ..where(transactions.ledgerId.equals(ledgerId) &
          transactions.transactionType.equals('OUT') &
          transactions.isDelete.equals(false));
    final result = await query.getSingle();
    return result.read(sum) ?? 0.0;
  }

  /// Search transactions by comments
  Future<List<Transaction>> searchTransactions(int merchantId, String query) {
    final lowerQuery = '%${query.toLowerCase()}%';
    return (select(transactions)
          ..where((t) =>
              t.merchantId.equals(merchantId) &
              t.isDelete.equals(false) &
              t.comments.lower().like(lowerQuery))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  // ============ UPDATE ============

  /// Update transaction
  Future<bool> updateTransaction(Transaction transaction) {
    return update(transactions).replace(transaction);
  }

  /// Update transaction by ID
  Future<int> updateTransactionById(int id, TransactionsCompanion transaction) {
    return (update(transactions)..where((t) => t.id.equals(id))).write(transaction);
  }

  /// Mark transaction as synced
  Future<int> markTransactionAsSynced(int id, int serverId) {
    return (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        isSynced: const Value(true),
        serverId: Value(serverId),
      ),
    );
  }

  /// Mark transaction as synced by local ID
  Future<int> markTransactionAsSyncedByLocalId(String localId, int serverId) {
    return (update(transactions)..where((t) => t.localId.equals(localId))).write(
      TransactionsCompanion(
        isSynced: const Value(true),
        serverId: Value(serverId),
      ),
    );
  }

  // ============ DELETE ============

  /// Soft delete transaction by local ID
  Future<int> softDeleteTransaction(int id) {
    return (update(transactions)..where((t) => t.id.equals(id))).write(
      const TransactionsCompanion(
        isDelete: Value(true),
        isSynced: Value(false),
      ),
    );
  }

  /// Soft delete transaction by server ID
  Future<int> softDeleteTransactionByServerId(int serverId) {
    return (update(transactions)..where((t) => t.serverId.equals(serverId))).write(
      const TransactionsCompanion(
        isDelete: Value(true),
        isSynced: Value(false),
      ),
    );
  }

  /// Hard delete transaction by ID
  Future<int> deleteTransactionById(int id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all transactions for a ledger
  Future<int> deleteTransactionsByLedger(int ledgerId) {
    return (delete(transactions)..where((t) => t.ledgerId.equals(ledgerId))).go();
  }

  /// Delete all transactions for a merchant
  Future<int> deleteTransactionsByMerchant(int merchantId) {
    return (delete(transactions)..where((t) => t.merchantId.equals(merchantId))).go();
  }

  /// Delete all transactions
  Future<int> deleteAllTransactions() {
    return delete(transactions).go();
  }

  // ============ BALANCE OPERATIONS ============

  /// Update transaction balance using raw SQL (works before code generation)
  Future<int> updateTransactionBalance(int id, double currentBalance, double lastBalance) async {
    return await customUpdate(
      'UPDATE transactions SET current_balance = ?, last_balance = ? WHERE id = ?',
      variables: [Variable.withReal(currentBalance), Variable.withReal(lastBalance), Variable.withInt(id)],
      updates: {transactions},
    );
  }

  /// Get all transactions for ledger ordered by date (ascending for balance calculation)
  Future<List<Transaction>> getTransactionsForBalanceCalculation(int ledgerId) {
    return (select(transactions)
          ..where((t) => t.ledgerId.equals(ledgerId) & t.isDelete.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.transactionDate), (t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  /// Get unsynced transactions for a specific ledger
  Future<List<Transaction>> getUnsyncedTransactionsByLedger(int ledgerId) {
    return (select(transactions)
          ..where((t) => t.ledgerId.equals(ledgerId) & t.isSynced.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.transactionDate)]))
        .get();
  }
}
