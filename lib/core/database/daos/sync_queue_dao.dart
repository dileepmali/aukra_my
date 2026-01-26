import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

/// Data Access Object for SyncQueue table
/// Manages pending offline changes that need to be synced with server
@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase> with _$SyncQueueDaoMixin {
  SyncQueueDao(AppDatabase db) : super(db);

  // ============ CREATE ============

  /// Add item to sync queue
  Future<int> addToQueue(SyncQueueCompanion item) {
    return into(syncQueue).insert(item);
  }

  /// Add ledger create to queue
  Future<int> queueLedgerCreate(String localId, String payload, int merchantId) {
    return addToQueue(SyncQueueCompanion(
      targetTable: const Value('ledgers'),
      localId: Value(localId),
      action: const Value('CREATE'),
      payload: Value(payload),
      endpoint: Value('api/ledger'),
      method: const Value('POST'),
      createdAt: Value(DateTime.now()),
      priority: const Value(1), // Ledgers have higher priority
    ));
  }

  /// Add ledger update to queue
  Future<int> queueLedgerUpdate(int recordId, String payload) {
    return addToQueue(SyncQueueCompanion(
      targetTable: const Value('ledgers'),
      recordId: Value(recordId),
      action: const Value('UPDATE'),
      payload: Value(payload),
      endpoint: Value('api/ledger/$recordId'),
      method: const Value('PUT'),
      createdAt: Value(DateTime.now()),
      priority: const Value(2),
    ));
  }

  /// Add ledger status change to queue
  Future<int> queueLedgerStatusChange(int recordId, String payload) {
    return addToQueue(SyncQueueCompanion(
      targetTable: const Value('ledgers'),
      recordId: Value(recordId),
      action: const Value('UPDATE'),
      payload: Value(payload),
      endpoint: Value('api/ledger/$recordId/status'),
      method: const Value('PATCH'),
      createdAt: Value(DateTime.now()),
      priority: const Value(2),
    ));
  }

  /// Add transaction create to queue
  Future<int> queueTransactionCreate(String localId, String payload) {
    return addToQueue(SyncQueueCompanion(
      targetTable: const Value('transactions'),
      localId: Value(localId),
      action: const Value('CREATE'),
      payload: Value(payload),
      endpoint: const Value('api/ledgerTransaction'),
      method: const Value('POST'),
      createdAt: Value(DateTime.now()),
      priority: const Value(3), // Transactions after ledgers
    ));
  }

  /// Add transaction update to queue
  Future<int> queueTransactionUpdate(int recordId, String payload) {
    return addToQueue(SyncQueueCompanion(
      targetTable: const Value('transactions'),
      recordId: Value(recordId),
      action: const Value('UPDATE'),
      payload: Value(payload),
      endpoint: Value('api/ledgerTransaction/$recordId'),
      method: const Value('PUT'),
      createdAt: Value(DateTime.now()),
      priority: const Value(3),
    ));
  }

  /// Add transaction delete to queue
  Future<int> queueTransactionDelete(int recordId, int serverId) {
    return addToQueue(SyncQueueCompanion(
      targetTable: const Value('transactions'),
      recordId: Value(recordId),
      action: const Value('DELETE'),
      payload: const Value('{}'),
      endpoint: Value('api/ledgerTransaction/$serverId'),
      method: const Value('DELETE'),
      createdAt: Value(DateTime.now()),
      priority: const Value(4),
    ));
  }

  // ============ READ ============

  /// Get all pending items
  Future<List<SyncQueueData>> getPendingItems() {
    return (select(syncQueue)
          ..where((q) => q.status.equals('PENDING') | q.status.equals('FAILED'))
          ..orderBy([
            (q) => OrderingTerm.asc(q.priority),
            (q) => OrderingTerm.asc(q.createdAt),
          ]))
        .get();
  }

  /// Watch pending items count
  Stream<int> watchPendingCount() {
    final count = countAll();
    return (selectOnly(syncQueue)
          ..addColumns([count])
          ..where(syncQueue.status.equals('PENDING') | syncQueue.status.equals('FAILED')))
        .watchSingle()
        .map((row) => row.read(count) ?? 0);
  }

  /// Get pending count
  Future<int> getPendingCount() async {
    final count = countAll();
    final query = selectOnly(syncQueue)
      ..addColumns([count])
      ..where(syncQueue.status.equals('PENDING') | syncQueue.status.equals('FAILED'));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Get item by ID
  Future<SyncQueueData?> getItemById(int id) {
    return (select(syncQueue)..where((q) => q.id.equals(id))).getSingleOrNull();
  }

  /// Get items by table name
  Future<List<SyncQueueData>> getItemsByTable(String tableName) {
    return (select(syncQueue)
          ..where((q) => q.targetTable.equals(tableName) & q.status.equals('PENDING')))
        .get();
  }

  /// Get item by local ID
  Future<SyncQueueData?> getItemByLocalId(String localId) {
    return (select(syncQueue)..where((q) => q.localId.equals(localId))).getSingleOrNull();
  }

  /// Check if record has pending sync
  Future<bool> hasPendingSync(String tableName, int recordId) async {
    final item = await (select(syncQueue)
          ..where((q) =>
              q.targetTable.equals(tableName) &
              q.recordId.equals(recordId) &
              (q.status.equals('PENDING') | q.status.equals('IN_PROGRESS'))))
        .getSingleOrNull();
    return item != null;
  }

  // ============ UPDATE ============

  /// Update item payload (for offline-created transactions that get edited before sync)
  Future<int> updatePayload(int id, String payload) {
    return (update(syncQueue)..where((q) => q.id.equals(id))).write(
      SyncQueueCompanion(
        payload: Value(payload),
      ),
    );
  }

  /// Update item status
  Future<int> updateStatus(int id, String status, {String? error}) {
    return (update(syncQueue)..where((q) => q.id.equals(id))).write(
      SyncQueueCompanion(
        status: Value(status),
        lastError: Value(error),
        lastAttempt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark item as in progress
  Future<int> markInProgress(int id) {
    return updateStatus(id, 'IN_PROGRESS');
  }

  /// Mark item as completed
  Future<int> markCompleted(int id) {
    return updateStatus(id, 'COMPLETED');
  }

  /// Mark item as failed with error
  Future<int> markFailed(int id, String error) async {
    // Get current retry count
    final item = await getItemById(id);
    if (item == null) return 0;

    return (update(syncQueue)..where((q) => q.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value('FAILED'),
        lastError: Value(error),
        lastAttempt: Value(DateTime.now()),
        retryCount: Value(item.retryCount + 1),
      ),
    );
  }

  /// Reset failed items to pending (for retry)
  Future<int> resetFailedItems() {
    return (update(syncQueue)..where((q) => q.status.equals('FAILED') & q.retryCount.isSmallerThanValue(5)))
        .write(const SyncQueueCompanion(
      status: Value('PENDING'),
    ));
  }

  // ============ DELETE ============

  /// Delete item by ID
  Future<int> deleteItem(int id) {
    return (delete(syncQueue)..where((q) => q.id.equals(id))).go();
  }

  /// Delete completed items
  Future<int> deleteCompletedItems() {
    return (delete(syncQueue)..where((q) => q.status.equals('COMPLETED'))).go();
  }

  /// Delete items older than X days
  Future<int> deleteOldItems(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (delete(syncQueue)
          ..where((q) => q.status.equals('COMPLETED') & q.createdAt.isSmallerThanValue(cutoff)))
        .go();
  }

  /// Delete all items
  Future<int> deleteAll() {
    return delete(syncQueue).go();
  }

  /// Delete items by local ID
  Future<int> deleteByLocalId(String localId) {
    return (delete(syncQueue)..where((q) => q.localId.equals(localId))).go();
  }
}
