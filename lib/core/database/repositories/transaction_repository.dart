import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../api/ledger_transaction_api.dart';
import '../../services/connectivity_service.dart';
import '../../../models/transaction_model.dart';
import '../../../models/transaction_list_model.dart';
import '../app_database.dart';

/// Repository for Transaction data
/// Handles offline-first logic: read from local DB, sync with server
class TransactionRepository {
  final AppDatabase _db = AppDatabase.instance;
  final LedgerTransactionApi _transactionApi = LedgerTransactionApi();
  final Uuid _uuid = const Uuid();

  // ============ READ OPERATIONS ============

  /// Get transactions by ledger ID - OFFLINE FIRST
  Future<List<TransactionItemModel>> getTransactionsByLedger(
    int ledgerId, {
    bool forceRefresh = false,
  }) async {
    try {
      // 1. Get cached data first
      final cached = await _db.transactionDao.getTransactionsByLedger(ledgerId);

      if (cached.isNotEmpty && !forceRefresh) {
        debugPrint('📦 Returning ${cached.length} cached transactions for ledger $ledgerId');

        // Refresh in background if online
        _refreshTransactionsInBackground(ledgerId);

        return cached.map(_dbTransactionToModel).toList();
      }

      // 2. If no cache or force refresh, try API
      if (ConnectivityService.instance.isConnected.value) {
        return await _fetchAndCacheTransactions(ledgerId);
      }

      // 3. Return cached data when offline
      return cached.map(_dbTransactionToModel).toList();
    } catch (e) {
      debugPrint('❌ Error getting transactions: $e');
      final cached = await _db.transactionDao.getTransactionsByLedger(ledgerId);
      return cached.map(_dbTransactionToModel).toList();
    }
  }

  /// Watch transactions stream (reactive)
  Stream<List<TransactionItemModel>> watchTransactionsByLedger(int ledgerId) {
    return _db.transactionDao
        .watchTransactionsByLedger(ledgerId)
        .map((transactions) => transactions.map(_dbTransactionToModel).toList());
  }

  /// Get transactions by date range (excludes deleted)
  Future<List<TransactionItemModel>> getTransactionsByDateRange(
    int ledgerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final cached = await _db.transactionDao.getTransactionsByDateRange(
      ledgerId,
      startDate,
      endDate,
    );
    return cached.map(_dbTransactionToModel).toList();
  }

  /// Get ALL transactions by date range (includes deleted for UI display)
  Future<List<TransactionItemModel>> getAllTransactionsByDateRangeForDisplay(
    int ledgerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final cached = await _db.transactionDao.getAllTransactionsByDateRangeForDisplay(
      ledgerId,
      startDate,
      endDate,
    );
    return cached.map(_dbTransactionToModel).toList();
  }

  /// Get today's transactions
  Future<List<TransactionItemModel>> getTodayTransactions(int ledgerId) async {
    final cached = await _db.transactionDao.getTodayTransactions(ledgerId);
    return cached.map(_dbTransactionToModel).toList();
  }

  /// Get total IN amount
  Future<double> getTotalInAmount(int ledgerId) {
    return _db.transactionDao.getTotalInAmount(ledgerId);
  }

  /// Get total OUT amount
  Future<double> getTotalOutAmount(int ledgerId) {
    return _db.transactionDao.getTotalOutAmount(ledgerId);
  }

  // ============ CREATE OPERATIONS ============

  /// Create new transaction - OFFLINE FIRST
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    final localId = _uuid.v4();
    final now = DateTime.now();

    // Parse transaction date
    DateTime transactionDate;
    try {
      transactionDate = DateTime.parse(transaction.transactionDate);
    } catch (e) {
      transactionDate = now;
    }

    // Get current ledger balance for calculating new balance
    final ledger = await _db.ledgerDao.getLedgerById(transaction.ledgerId);
    final currentLedgerBalance = ledger?.currentBalance ?? 0.0;

    // Calculate new balance after this transaction
    // Khatabook logic (matches server):
    // IN (You Got/Received money from customer) = Balance DECREASES
    // OUT (You Gave money to customer) = Balance INCREASES
    double newBalance = currentLedgerBalance;
    if (transaction.transactionType == 'IN') {
      newBalance -= transaction.transactionAmount;
    } else {
      newBalance += transaction.transactionAmount;
    }

    // 1. Save to local DB (without balance fields - will update separately)
    final companion = TransactionsCompanion(
      ledgerId: Value(transaction.ledgerId),
      merchantId: Value(transaction.merchantId),
      transactionAmount: Value(transaction.transactionAmount),
      transactionType: Value(transaction.transactionType),
      transactionDate: Value(transactionDate),
      comments: Value(transaction.comments),
      partyMerchantAction: Value(transaction.partyMerchantAction),
      uploadedKeys: Value(transaction.uploadedKeys?.join(',') ?? ''),
      securityKey: Value(transaction.securityKey),
      isSynced: const Value(false),
      localId: Value(localId),
      createdAt: Value(now),
      updatedAt: Value(now),
      isDelete: const Value(false),
    );

    final localDbId = await _db.transactionDao.insertTransaction(companion);

    // Update balance fields separately (works before code regeneration)
    await _db.transactionDao.updateTransactionBalance(localDbId, newBalance, currentLedgerBalance);

    debugPrint('💾 Transaction saved locally with ID: $localDbId');
    debugPrint('💰 Balance: $currentLedgerBalance → $newBalance');

    // 2. Update ledger balance locally
    await _updateLedgerBalanceLocally(
      transaction.ledgerId,
      transaction.transactionAmount,
      transaction.transactionType,
    );

    // 3. Add to sync queue
    await _db.syncQueueDao.queueTransactionCreate(
      localId,
      jsonEncode(transaction.toJson()),
    );
    debugPrint('📤 Transaction added to sync queue');

    return transaction;
  }

  /// Update ledger balance locally after transaction
  Future<void> _updateLedgerBalanceLocally(
    int ledgerId,
    double amount,
    String transactionType,
  ) async {
    debugPrint('🔄 _updateLedgerBalanceLocally: ledgerId=$ledgerId, amount=$amount, type=$transactionType');

    final ledger = await _db.ledgerDao.getLedgerById(ledgerId);
    if (ledger == null) {
      debugPrint('❌ Ledger $ledgerId NOT FOUND in local DB - balance update skipped!');
      return;
    }

    final oldBalance = ledger.currentBalance;
    double newBalance = oldBalance;

    // Khatabook logic (matches server):
    // IN (You Got/Received money from customer) = Balance DECREASES
    // OUT (You Gave money to customer) = Balance INCREASES
    if (transactionType == 'IN') {
      newBalance -= amount;
    } else {
      newBalance += amount;
    }

    await _db.ledgerDao.updateLedgerBalance(ledgerId, newBalance);
    debugPrint('💰 Ledger $ledgerId balance updated: $oldBalance → $newBalance');
  }

  // ============ UPDATE OPERATIONS ============

  /// Update transaction - OFFLINE FIRST
  /// Update transaction - OFFLINE FIRST
  /// transactionId can be either local id or serverId (from UI)
  Future<bool> updateTransaction({
    required int transactionId,
    required double transactionAmount,
    required String transactionDate,
    String? comments,
    List<int>? uploadedKeys,
    required String securityKey,
  }) async {
    debugPrint('');
    debugPrint('✏️✏️✏️ ========== UPDATE TRANSACTION START ========== ✏️✏️✏️');
    debugPrint('✏️ Online Status: ${ConnectivityService.instance.isConnected.value}');
    debugPrint('✏️ Input transactionId: $transactionId');
    debugPrint('✏️ New amount: $transactionAmount');
    debugPrint('✏️ New date: $transactionDate');
    debugPrint('✏️ New comments: $comments');

    // Parse transaction date
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(transactionDate);
    } catch (e) {
      parsedDate = DateTime.now();
    }

    // 1. Find the transaction - could be by serverId or local id
    var transaction = await _db.transactionDao.getTransactionByServerId(transactionId);
    if (transaction == null) {
      transaction = await _db.transactionDao.getTransactionById(transactionId);
    }

    if (transaction == null) {
      debugPrint('❌ Transaction not found: $transactionId');
      debugPrint('✏️✏️✏️ ========== UPDATE TRANSACTION END (NOT FOUND) ========== ✏️✏️✏️');
      return false;
    }

    final localId = transaction.id;
    final localUuid = transaction.localId;
    final hasServerId = transaction.serverId != null && transaction.serverId! > 0;

    debugPrint('✏️ Found transaction details:');
    debugPrint('   - localId (DB id): $localId');
    debugPrint('   - localUuid: $localUuid');
    debugPrint('   - serverId: ${transaction.serverId}');
    debugPrint('   - hasServerId: $hasServerId');
    debugPrint('   - Old amount: ${transaction.transactionAmount}');
    debugPrint('   - isDelete: ${transaction.isDelete}');
    debugPrint('   - isSynced: ${transaction.isSynced}');

    // 2. Update local DB first using LOCAL id
    final companion = TransactionsCompanion(
      transactionAmount: Value(transactionAmount),
      transactionDate: Value(parsedDate),
      comments: Value(comments),
      uploadedKeys: Value(uploadedKeys?.join(',') ?? ''),
      updatedAt: Value(DateTime.now()),
      isSynced: const Value(false),
    );

    await _db.transactionDao.updateTransactionById(localId, companion);
    debugPrint('💾 Transaction updated locally: $localId');

    // 3. SPECIAL CASE: Transaction created offline but never synced (no serverId)
    // Update the pending CREATE in sync queue instead of adding UPDATE
    if (!hasServerId && localUuid != null) {
      debugPrint('✏️ ⚡ OFFLINE-CREATED TRANSACTION - Updating CREATE payload instead of queueing UPDATE');

      // Get the pending CREATE from sync queue
      final pendingCreate = await _db.syncQueueDao.getItemByLocalId(localUuid);
      if (pendingCreate != null && pendingCreate.action == 'CREATE') {
        // Update the CREATE payload with new values (matching TransactionModel.toJson structure)
        final payloadMap = <String, dynamic>{
          'ledgerId': transaction.ledgerId,
          'merchantId': transaction.merchantId,
          'transactionAmount': transactionAmount,
          'transactionType': transaction.transactionType,
          'transactionDate': transactionDate,
          'partyMerchantAction': transaction.partyMerchantAction.isNotEmpty ? transaction.partyMerchantAction : 'VIEW',
          'securityKey': securityKey,
        };
        if (comments != null && comments.isNotEmpty) {
          payloadMap['comments'] = comments;
        }
        if (uploadedKeys != null && uploadedKeys.isNotEmpty) {
          payloadMap['uploadedKeys'] = uploadedKeys;
        }
        final updatedPayload = jsonEncode(payloadMap);

        await _db.syncQueueDao.updatePayload(pendingCreate.id, updatedPayload);
        debugPrint('✏️ ✅ CREATE payload updated with new values');
        debugPrint('✏️✏️✏️ ========== UPDATE TRANSACTION END (CREATE PAYLOAD UPDATED) ========== ✏️✏️✏️');
        return true;
      } else {
        debugPrint('⚠️ No pending CREATE found for localUuid: $localUuid');
      }
    }

    final effectiveServerId = transaction.serverId ?? transactionId;
    debugPrint('✏️ effectiveServerId: $effectiveServerId');

    // 4. If online, call API immediately
    if (ConnectivityService.instance.isConnected.value) {
      try {
        await _transactionApi.updateTransaction(
          transactionId: effectiveServerId,
          transactionAmount: transactionAmount,
          transactionDate: transactionDate,
          comments: comments ?? '',
          uploadedKeys: uploadedKeys,
          securityKey: securityKey,
        );

        // Mark as synced
        await _db.transactionDao.updateTransactionById(
          localId,
          const TransactionsCompanion(isSynced: Value(true)),
        );
        debugPrint('✅ Transaction synced to server');
        return true;
      } catch (e) {
        debugPrint('⚠️ API update failed, queued for sync: $e');
        // Queue for later sync
        await _db.syncQueueDao.queueTransactionUpdate(
          effectiveServerId,
          jsonEncode({
            'transactionId': effectiveServerId,
            'transactionAmount': transactionAmount,
            'transactionDate': transactionDate,
            'comments': comments,
            'uploadedKeys': uploadedKeys,
            'securityKey': securityKey,
          }),
        );
        return true; // Local update succeeded
      }
    } else {
      // 5. Offline - Queue for sync (only if transaction has serverId)
      debugPrint('📴 Offline - Queuing transaction update for sync');
      debugPrint('📴 Queue params: effectiveServerId=$effectiveServerId');
      await _db.syncQueueDao.queueTransactionUpdate(
        effectiveServerId,
        jsonEncode({
          'transactionId': effectiveServerId,
          'transactionAmount': transactionAmount,
          'transactionDate': transactionDate,
          'comments': comments,
          'uploadedKeys': uploadedKeys,
          'securityKey': securityKey,
        }),
      );

      // Verify update worked
      final afterUpdate = await _db.transactionDao.getTransactionById(localId);
      debugPrint('✏️ ✅ UPDATE RESULT:');
      debugPrint('   - New amount in DB: ${afterUpdate?.transactionAmount}');
      debugPrint('   - isSynced (should be false): ${afterUpdate?.isSynced}');
      debugPrint('✏️✏️✏️ ========== UPDATE TRANSACTION END (OFFLINE) ========== ✏️✏️✏️');
      debugPrint('');
      return true;
    }
  }

  // ============ DELETE OPERATIONS ============

  /// Delete transaction - OFFLINE FIRST
  /// transactionId can be either local id or serverId (from UI)
  Future<bool> deleteTransaction({
    required int transactionId,
    int? serverId,
    required String securityKey,
  }) async {
    debugPrint('');
    debugPrint('🗑️🗑️🗑️ ========== DELETE TRANSACTION START ========== 🗑️🗑️🗑️');
    debugPrint('🗑️ Online Status: ${ConnectivityService.instance.isConnected.value}');
    debugPrint('🗑️ Input transactionId: $transactionId');
    debugPrint('🗑️ Input serverId: $serverId');

    // 1. Find the transaction - could be by serverId or local id
    // First try to find by serverId
    var transaction = await _db.transactionDao.getTransactionByServerId(transactionId);

    // If not found by serverId, try by local id
    if (transaction == null) {
      transaction = await _db.transactionDao.getTransactionById(transactionId);
    }

    if (transaction == null) {
      debugPrint('❌ Transaction not found: $transactionId');
      return false;
    }

    final localId = transaction.id;
    final localUuid = transaction.localId;
    final hasServerId = transaction.serverId != null && transaction.serverId! > 0;

    debugPrint('🗑️ Found transaction details:');
    debugPrint('   - localId (DB id): $localId');
    debugPrint('   - serverId: ${transaction.serverId}');
    debugPrint('   - localUuid: $localUuid');
    debugPrint('   - hasServerId: $hasServerId');
    debugPrint('   - isDelete (before): ${transaction.isDelete}');
    debugPrint('   - isSynced (before): ${transaction.isSynced}');

    // 2. SPECIAL CASE: Transaction created offline but never synced
    // SOFT DELETE - show with strikethrough until sync cleans it up
    if (!hasServerId && localUuid != null) {
      debugPrint('🗑️ ⚡ SOFT DELETE PATH - Transaction created offline, never synced');
      debugPrint('🗑️ Will show with strikethrough in UI');

      // Remove pending CREATE from sync queue (no need to sync a deleted offline transaction)
      await _db.syncQueueDao.deleteByLocalId(localUuid);
      debugPrint('🗑️ Removed CREATE from sync queue');

      // SOFT DELETE (not hard delete) - so it shows with strikethrough
      await _db.transactionDao.softDeleteTransaction(localId);

      // Verify soft delete worked
      final afterDelete = await _db.transactionDao.getTransactionById(localId);
      debugPrint('🗑️ ✅ Offline transaction SOFT DELETED:');
      debugPrint('   - isDelete (after): ${afterDelete?.isDelete}');
      debugPrint('   - Transaction still exists: ${afterDelete != null}');

      // Update ledger balance (reverse the transaction effect)
      await _reverseLedgerBalanceLocally(
        transaction.ledgerId,
        transaction.transactionAmount,
        transaction.transactionType,
      );

      return true;
    }

    final effectiveServerId = transaction.serverId ?? serverId ?? transactionId;
    debugPrint('🗑️ ⚡ SOFT DELETE PATH - Transaction has serverId, will sync later');
    debugPrint('🗑️ effectiveServerId for API: $effectiveServerId');

    // 3. Soft delete locally using the LOCAL id
    debugPrint('🗑️ Setting isDelete=true, isSynced=false for localId: $localId');
    await _db.transactionDao.softDeleteTransaction(localId);

    // Verify soft delete worked
    final afterDelete = await _db.transactionDao.getTransactionById(localId);
    debugPrint('🗑️ ✅ SOFT DELETE RESULT:');
    debugPrint('   - isDelete (after): ${afterDelete?.isDelete}');
    debugPrint('   - isSynced (after): ${afterDelete?.isSynced}');
    debugPrint('   - Transaction still exists: ${afterDelete != null}');

    // 4. Update ledger balance (reverse the transaction effect)
    await _reverseLedgerBalanceLocally(
      transaction.ledgerId,
      transaction.transactionAmount,
      transaction.transactionType,
    );

    // 5. If online, call API immediately
    if (ConnectivityService.instance.isConnected.value) {
      try {
        await _transactionApi.deleteTransaction(
          transactionId: effectiveServerId,
          securityKey: securityKey,
        );
        debugPrint('✅ Transaction deleted on server');
        return true;
      } catch (e) {
        debugPrint('⚠️ API delete failed, queued for sync: $e');
        // Queue for later sync
        await _db.syncQueueDao.queueTransactionDelete(
          localId,
          effectiveServerId,
        );
        return true; // Local delete succeeded
      }
    } else {
      // 6. Offline - Queue for sync
      debugPrint('📴 Offline - Queuing transaction delete for sync');
      debugPrint('📴 Queue params: localId=$localId, effectiveServerId=$effectiveServerId');
      await _db.syncQueueDao.queueTransactionDelete(
        localId,
        effectiveServerId,
      );
      debugPrint('🗑️🗑️🗑️ ========== DELETE TRANSACTION END (OFFLINE) ========== 🗑️🗑️🗑️');
      debugPrint('');
      return true;
    }
  }

  /// Reverse ledger balance after deleting a transaction
  Future<void> _reverseLedgerBalanceLocally(
    int ledgerId,
    double amount,
    String transactionType,
  ) async {
    debugPrint('🔄 _reverseLedgerBalanceLocally: ledgerId=$ledgerId, amount=$amount, type=$transactionType');

    final ledger = await _db.ledgerDao.getLedgerById(ledgerId);
    if (ledger == null) {
      debugPrint('❌ Ledger $ledgerId NOT FOUND in local DB - balance reversal skipped!');
      return;
    }

    final oldBalance = ledger.currentBalance;
    double newBalance = oldBalance;

    // REVERSE the Khatabook logic:
    // Original: IN decreases, OUT increases
    // Reverse: IN increases (undo decrease), OUT decreases (undo increase)
    if (transactionType == 'IN') {
      newBalance += amount; // Undo the decrease
    } else {
      newBalance -= amount; // Undo the increase
    }

    await _db.ledgerDao.updateLedgerBalance(ledgerId, newBalance);
    debugPrint('💰 Ledger $ledgerId balance reversed: $oldBalance → $newBalance');
  }

  /// Get transaction by ID (from cache)
  Future<TransactionItemModel?> getTransactionById(int transactionId) async {
    final transaction = await _db.transactionDao.getTransactionById(transactionId);
    if (transaction != null) {
      return _dbTransactionToModel(transaction);
    }

    // Try by server ID
    final byServerId = await _db.transactionDao.getTransactionByServerId(transactionId);
    if (byServerId != null) {
      return _dbTransactionToModel(byServerId);
    }

    return null;
  }

  // ============ SYNC OPERATIONS ============

  /// Fetch from API and cache
  Future<List<TransactionItemModel>> _fetchAndCacheTransactions(int ledgerId) async {
    try {
      final result = await _transactionApi.getLedgerTransactions(ledgerId: ledgerId);
      final transactions = result.data;

      if (transactions.isNotEmpty) {
        await _cacheTransactions(transactions, ledgerId);
        debugPrint('✅ Cached ${transactions.length} transactions from API');
      }

      return transactions;
    } catch (e) {
      debugPrint('❌ Error fetching transactions from API: $e');
      rethrow;
    }
  }

  /// Refresh transactions in background
  void _refreshTransactionsInBackground(int ledgerId) async {
    if (!ConnectivityService.instance.isConnected.value) return;

    try {
      await _fetchAndCacheTransactions(ledgerId);
    } catch (e) {
      debugPrint('⚠️ Background transaction refresh failed: $e');
    }
  }

  /// Cache transactions to local DB
  Future<void> _cacheTransactions(List<TransactionItemModel> transactions, int ledgerId) async {
    debugPrint('');
    debugPrint('💾💾💾 ========== CACHE TRANSACTIONS FROM API START ========== 💾💾💾');
    debugPrint('💾 Caching ${transactions.length} transactions for ledger $ledgerId');

    // Get unsynced local transactions for this ledger (to match with API data)
    final unsyncedLocal = await _db.transactionDao.getUnsyncedTransactionsByLedger(ledgerId);
    debugPrint('💾 Found ${unsyncedLocal.length} unsynced local transactions');
    for (final local in unsyncedLocal) {
      debugPrint('   - localId: ${local.id}, serverId: ${local.serverId}, isDelete: ${local.isDelete}, isSynced: ${local.isSynced}');
    }

    for (final t in transactions) {
      // Parse date string to DateTime
      DateTime? transactionDate;
      DateTime? updatedAt;
      try {
        transactionDate = DateTime.parse(t.transactionDate);
        updatedAt = DateTime.parse(t.updatedAt);
      } catch (e) {
        transactionDate = DateTime.now();
        updatedAt = DateTime.now();
      }

      // 1. Check if transaction with this serverId already exists
      final existingByServerId = await _db.transactionDao.getTransactionByServerId(t.id);

      if (existingByServerId != null) {
        // CHECK: If local transaction has pending changes (isSynced=false), PRESERVE local values
        // This prevents API data from overwriting pending offline edits or deletes
        final hasLocalPendingChanges = !existingByServerId.isSynced;

        // ALSO check if there's a pending UPDATE in sync queue for this transaction
        // This handles edge case where isSynced=true but there's still a pending update
        final hasPendingUpdate = await _db.syncQueueDao.hasPendingSync(
          'transactions',
          existingByServerId.serverId ?? existingByServerId.id,
        );

        final shouldPreserveLocal = hasLocalPendingChanges || hasPendingUpdate;

        debugPrint('💾 Processing API transaction serverId: ${t.id}');
        debugPrint('   - Found existing local record: localId=${existingByServerId.id}');
        debugPrint('   - Local isDelete: ${existingByServerId.isDelete}');
        debugPrint('   - Local isSynced: ${existingByServerId.isSynced}');
        debugPrint('   - Local amount: ${existingByServerId.transactionAmount}');
        debugPrint('   - API isDelete: ${t.isDelete}');
        debugPrint('   - API amount: ${t.amount}');
        debugPrint('   - hasLocalPendingChanges: $hasLocalPendingChanges');
        debugPrint('   - hasPendingUpdate: $hasPendingUpdate');
        debugPrint('   - shouldPreserveLocal: $shouldPreserveLocal');

        if (shouldPreserveLocal) {
          // PRESERVE local changes - don't overwrite edits or deletes
          if (existingByServerId.isDelete) {
            debugPrint('🛡️🛡️🛡️ PRESERVING LOCAL DELETE - keeping isDelete=true');
          } else {
            debugPrint('🛡️🛡️🛡️ PRESERVING LOCAL EDIT - keeping local amount: ${existingByServerId.transactionAmount}');
          }
          // Only update updatedAt, keep all local values
          final updateCompanion = TransactionsCompanion(
            updatedAt: Value(updatedAt),
            // Keep ALL local values: amount, date, comments, isDelete, isSynced
          );
          await _db.transactionDao.updateTransactionById(existingByServerId.id, updateCompanion);
        } else {
          // Normal update - use API values (local is already synced)
          debugPrint('📝 Normal update - using API values (isDelete: ${t.isDelete}, amount: ${t.amount})');
          final updateCompanion = TransactionsCompanion(
            transactionAmount: Value(t.amount),
            transactionType: Value(t.transactionType),
            transactionDate: Value(transactionDate),
            comments: Value(t.description),
            uploadedKeys: Value(t.uploadedKeys?.join(',') ?? ''),
            isSynced: const Value(true),
            updatedAt: Value(updatedAt),
            isDelete: Value(t.isDelete),
          );
          await _db.transactionDao.updateTransactionById(existingByServerId.id, updateCompanion);
          await _db.transactionDao.updateTransactionBalance(existingByServerId.id, t.currentBalance, t.lastBalance);
        }
        continue;
      }

      debugPrint('💾 No existing record by serverId ${t.id}, checking for matching unsynced...');

      // 2. Check if there's a matching UNSYNCED local transaction
      // Match by: amount, type, and approximate date (same day)
      // Use fuzzy matching to handle floating point precision issues
      Transaction? matchingLocal;
      for (final local in unsyncedLocal) {
        // Fuzzy amount comparison (within 0.01 tolerance for floating point)
        final amountDiff = (local.transactionAmount - t.amount).abs();
        final sameAmount = amountDiff < 0.01;

        final sameType = local.transactionType == t.transactionType;

        // Flexible description matching (both null or both empty or exact match)
        final localDesc = (local.comments ?? '').trim();
        final apiDesc = (t.description ?? '').trim();
        final sameDescription = localDesc == apiDesc ||
                                (localDesc.isEmpty && apiDesc.isEmpty);

        // Check if same day (API might have slightly different timestamp)
        final localDate = local.transactionDate;
        final apiDate = transactionDate;
        final sameDay = localDate.year == apiDate.year &&
                        localDate.month == apiDate.month &&
                        localDate.day == apiDate.day;

        debugPrint('💾 Matching check for local ${local.id} vs API ${t.id}:');
        debugPrint('   - sameAmount: $sameAmount (local: ${local.transactionAmount}, api: ${t.amount}, diff: $amountDiff)');
        debugPrint('   - sameType: $sameType (local: ${local.transactionType}, api: ${t.transactionType})');
        debugPrint('   - sameDay: $sameDay (local: $localDate, api: $apiDate)');
        debugPrint('   - sameDescription: $sameDescription (local: "$localDesc", api: "$apiDesc")');

        if (sameAmount && sameType && sameDay && sameDescription) {
          debugPrint('✅ MATCH FOUND: local ${local.id} matches API ${t.id}');
          matchingLocal = local;
          break;
        }
      }

      // If no exact match found, try fuzzy matching (looser criteria)
      if (matchingLocal == null) {
        debugPrint('💾 No exact match, trying fuzzy match...');
        for (final local in unsyncedLocal) {
          // Looser amount comparison (within 1.0 tolerance)
          final amountDiff = (local.transactionAmount - t.amount).abs();
          final similarAmount = amountDiff < 1.0;

          final sameType = local.transactionType == t.transactionType;

          // Same day check
          final localDate = local.transactionDate;
          final apiDate = transactionDate;
          final sameDay = localDate.year == apiDate.year &&
                          localDate.month == apiDate.month &&
                          localDate.day == apiDate.day;

          // For fuzzy match, just need type + day + similar amount
          if (similarAmount && sameType && sameDay) {
            debugPrint('✅ FUZZY MATCH FOUND: local ${local.id} ≈ API ${t.id}');
            debugPrint('   - Amount diff: $amountDiff');
            matchingLocal = local;
            break;
          }
        }
      }

      if (matchingLocal != null) {
        // Found matching offline transaction - link serverId but PRESERVE local changes
        debugPrint('🔗 Linking offline transaction (local: ${matchingLocal.id}) to server (serverId: ${t.id})');
        debugPrint('   - Local isDelete: ${matchingLocal.isDelete}');
        debugPrint('   - Local amount: ${matchingLocal.transactionAmount}');

        // Always preserve local values when linking (local is unsynced)
        if (matchingLocal.isDelete) {
          debugPrint('🛡️ Preserving local delete for matched transaction');
        } else {
          debugPrint('🛡️ Preserving local values, just linking serverId');
        }

        // Link to server but keep ALL local values (it's unsynced, so local values are newer)
        final updateCompanion = TransactionsCompanion(
          serverId: Value(t.id),
          updatedAt: Value(updatedAt),
          // Keep all local values: amount, date, comments, isDelete, isSynced
        );
        await _db.transactionDao.updateTransactionById(matchingLocal.id, updateCompanion);

        // Remove from unsyncedLocal list so it's not matched again
        unsyncedLocal.remove(matchingLocal);
        continue;
      }

      // 3. No match found - INSERT as new transaction
      debugPrint('💾 Inserting NEW transaction from API: serverId=${t.id}, isDelete=${t.isDelete}');
      final companion = TransactionsCompanion(
        serverId: Value(t.id),
        ledgerId: Value(ledgerId),
        merchantId: const Value(0),
        transactionAmount: Value(t.amount),
        transactionType: Value(t.transactionType),
        transactionDate: Value(transactionDate),
        comments: Value(t.description),
        partyMerchantAction: const Value('VIEW'),
        uploadedKeys: Value(t.uploadedKeys?.join(',') ?? ''),
        isSynced: const Value(true),
        createdAt: Value(transactionDate),
        updatedAt: Value(updatedAt),
        isDelete: Value(t.isDelete),
      );
      final newId = await _db.transactionDao.insertTransaction(companion);
      await _db.transactionDao.updateTransactionBalance(newId, t.currentBalance, t.lastBalance);
    }

    debugPrint('💾💾💾 ========== CACHE TRANSACTIONS FROM API END ========== 💾💾💾');
    debugPrint('');
  }

  /// Public method to cache transactions from API response
  /// Call this from controller after fetching API data
  Future<void> cacheTransactionsFromApi(List<TransactionItemModel> transactions, int ledgerId) async {
    if (transactions.isEmpty) return;

    debugPrint('💾 Caching ${transactions.length} transactions from API for ledger $ledgerId');
    await _cacheTransactions(transactions, ledgerId);
    debugPrint('✅ Transactions cached successfully');
  }

  /// Full sync - fetch all transactions for a ledger
  Future<void> fullSync(int ledgerId) async {
    if (!ConnectivityService.instance.isConnected.value) {
      debugPrint('📴 Cannot sync - device offline');
      return;
    }

    try {
      await _fetchAndCacheTransactions(ledgerId);
      debugPrint('✅ Full transaction sync completed for ledger $ledgerId');
    } catch (e) {
      debugPrint('❌ Error in full sync: $e');
    }
  }

  // ============ HELPERS ============

  /// Convert DB Transaction to TransactionItemModel
  TransactionItemModel _dbTransactionToModel(Transaction t) {
    // Parse uploaded keys from comma-separated string
    List<int>? uploadedKeys;
    if (t.uploadedKeys != null && t.uploadedKeys!.isNotEmpty) {
      try {
        uploadedKeys = t.uploadedKeys!.split(',').map((s) => int.parse(s.trim())).toList();
      } catch (e) {
        uploadedKeys = null;
      }
    }

    // Get balance fields safely (may not exist in generated code until rebuild)
    double lastBal = 0.0;
    double currentBal = 0.0;
    try {
      // Using dynamic access to handle missing fields before code regeneration
      final dynamic dynT = t;
      lastBal = (dynT.lastBalance as num?)?.toDouble() ?? 0.0;
      currentBal = (dynT.currentBalance as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      // Fields don't exist yet - will work after build_runner
      debugPrint('⚠️ Balance fields not available yet - run build_runner');
    }

    return TransactionItemModel(
      id: t.serverId ?? t.id,
      amount: t.transactionAmount,
      lastBalance: lastBal,
      currentBalance: currentBal,
      description: t.comments,
      isDelete: t.isDelete,
      transactionDate: t.transactionDate.toIso8601String(),
      updatedAt: t.updatedAt?.toIso8601String() ?? '',
      transactionType: t.transactionType,
      ledgerId: t.ledgerId,
      partyName: '', // Will be filled from ledger
      partyType: '', // Will be filled from ledger
      balanceType: t.transactionType,
      uploadedKeys: uploadedKeys,
    );
  }

  /// Clear all cached transactions
  Future<void> clearCache() async {
    await _db.transactionDao.deleteAllTransactions();
  }

  /// Clear transactions for a specific ledger
  Future<void> clearCacheForLedger(int ledgerId) async {
    await _db.transactionDao.deleteTransactionsByLedger(ledgerId);
  }

  /// Repair/cleanup transactions for a ledger
  /// - Removes duplicate transactions (keeps only one per serverId)
  /// - Recalculates balances with correct logic
  /// Call this to fix corrupted data without clearing entire app
  Future<void> repairLedgerData(int ledgerId) async {
    debugPrint('🔧 Repairing data for ledger $ledgerId...');

    // 1. Remove duplicate transactions (same serverId)
    await _removeDuplicateTransactions(ledgerId);

    // 2. Recalculate all balances with correct IN/OUT logic
    await recalculateBalances(ledgerId);

    debugPrint('✅ Ledger $ledgerId data repaired');
  }

  /// Remove duplicate transactions for a ledger
  /// 1. Removes duplicates with same serverId (keeps synced version)
  /// 2. Removes unsynced transactions that match synced ones (already synced to server)
  /// 3. Removes orphaned transactions (no serverId but isSynced=true) that match synced ones
  /// 4. Removes offline-sync duplicates (local transaction + server duplicate from sync mismatch)
  Future<void> _removeDuplicateTransactions(int ledgerId) async {
    debugPrint('🗑️ Removing duplicate transactions for ledger $ledgerId...');

    // Use getAllTransactionsByLedgerForDisplay to include deleted transactions in duplicate check
    final allTransactions = await _db.transactionDao.getAllTransactionsByLedgerForDisplay(ledgerId);
    debugPrint('🗑️ Total transactions (including deleted): ${allTransactions.length}');
    debugPrint('🗑️ Deleted transactions: ${allTransactions.where((t) => t.isDelete).length}');
    int deletedCount = 0;

    // 1. Group transactions by category
    final Map<int, List<Transaction>> byServerId = {};
    final List<Transaction> unsyncedTransactions = [];
    final List<Transaction> orphanedTransactions = []; // NEW: no serverId but isSynced=true

    for (final t in allTransactions) {
      if (t.serverId != null && t.serverId! > 0) {
        byServerId.putIfAbsent(t.serverId!, () => []).add(t);
      } else if (!t.isSynced) {
        unsyncedTransactions.add(t);
      } else {
        // NEW: orphaned record - no serverId but isSynced=true
        orphanedTransactions.add(t);
        debugPrint('🔍 Found orphaned transaction: localId=${t.id}, serverId=${t.serverId}, isSynced=${t.isSynced}, isDelete=${t.isDelete}');
      }
    }

    debugPrint('🗑️ Synced (with serverId): ${byServerId.length} groups');
    debugPrint('🗑️ Unsynced (no serverId, isSynced=false): ${unsyncedTransactions.length}');
    debugPrint('🗑️ Orphaned (no serverId, isSynced=true): ${orphanedTransactions.length}');

    // 2. Remove duplicates with same serverId - keep first, delete rest
    for (final entry in byServerId.entries) {
      final transactions = entry.value;
      if (transactions.length > 1) {
        transactions.sort((a, b) => a.id.compareTo(b.id));
        for (int i = 1; i < transactions.length; i++) {
          debugPrint('🗑️ Removing serverId duplicate (local: ${transactions[i].id}, serverId: ${entry.key})');
          await _db.transactionDao.deleteTransactionById(transactions[i].id);
          deletedCount++;
        }
      }
    }

    // 3. Check if any unsynced transaction matches a synced one (duplicate from sync)
    for (final unsynced in unsyncedTransactions) {
      for (final syncedList in byServerId.values) {
        if (syncedList.isEmpty) continue;
        final synced = syncedList.first;

        if (_isTransactionMatch(unsynced, synced)) {
          debugPrint('🗑️ Removing unsynced duplicate (local: ${unsynced.id}, matches serverId: ${synced.serverId})');
          await _db.transactionDao.deleteTransactionById(unsynced.id);
          deletedCount++;
          break;
        }
      }
    }

    // 4. Check if any orphaned transaction matches a synced one
    // These are records that somehow got isSynced=true but no serverId
    for (final orphan in orphanedTransactions) {
      for (final syncedList in byServerId.values) {
        if (syncedList.isEmpty) continue;
        final synced = syncedList.first;

        if (_isTransactionMatch(orphan, synced)) {
          debugPrint('🗑️ Removing orphaned duplicate (local: ${orphan.id}, matches serverId: ${synced.serverId})');
          await _db.transactionDao.deleteTransactionById(orphan.id);
          deletedCount++;
          break;
        }
      }
    }

    // 5. Remove orphaned transactions that don't match any synced one
    // If it's orphaned (no serverId) and deleted, it's garbage - remove it
    for (final orphan in orphanedTransactions) {
      // Check if already deleted in step 4
      final stillExists = await _db.transactionDao.getTransactionById(orphan.id);
      if (stillExists == null) continue;

      // If orphaned and deleted, remove it (it's garbage data)
      if (orphan.isDelete) {
        debugPrint('🗑️ Removing orphaned deleted transaction (local: ${orphan.id})');
        await _db.transactionDao.deleteTransactionById(orphan.id);
        deletedCount++;
      }
    }

    // 6. NEW: Detect offline-sync duplicates by date+type+description (even if amounts differ)
    // This handles the case where user edited offline-created transaction before sync
    // resulting in local having different amount than server
    for (final unsynced in unsyncedTransactions) {
      // Check if already deleted in previous steps
      final stillExists = await _db.transactionDao.getTransactionById(unsynced.id);
      if (stillExists == null) continue;

      for (final syncedList in byServerId.values) {
        if (syncedList.isEmpty) continue;
        final synced = syncedList.first;

        // Match by type, day, and description (ignore amount - might have been edited)
        if (_isTransactionMatchLoose(unsynced, synced)) {
          debugPrint('🗑️ Found potential offline-sync duplicate:');
          debugPrint('   - Unsynced: ID ${unsynced.id}, amount ${unsynced.transactionAmount}');
          debugPrint('   - Synced: serverId ${synced.serverId}, amount ${synced.transactionAmount}');

          // If amounts differ, keep the local one (user's edit) and update it with serverId
          if (unsynced.transactionAmount != synced.transactionAmount) {
            debugPrint('🔗 Linking unsynced to server (preserving local amount)');
            // Update unsynced with serverId, delete the synced duplicate
            await _db.transactionDao.updateTransactionById(
              unsynced.id,
              TransactionsCompanion(
                serverId: Value(synced.serverId!),
                isSynced: const Value(false), // Still needs to sync the amount change
              ),
            );
            await _db.transactionDao.deleteTransactionById(synced.id);
            debugPrint('🗑️ Removed synced duplicate (ID: ${synced.id})');
            deletedCount++;
          }
          break;
        }
      }
    }

    debugPrint('🗑️ Removed $deletedCount duplicate/orphaned transactions');
  }

  /// Loose matching - ignores amount (for detecting offline-edited duplicates)
  bool _isTransactionMatchLoose(Transaction a, Transaction b) {
    final sameType = a.transactionType == b.transactionType;
    final sameDescription = (a.comments ?? '') == (b.comments ?? '');
    final sameDay = a.transactionDate.year == b.transactionDate.year &&
                    a.transactionDate.month == b.transactionDate.month &&
                    a.transactionDate.day == b.transactionDate.day;

    return sameType && sameDay && sameDescription;
  }

  /// Helper to check if two transactions match (for duplicate detection)
  bool _isTransactionMatch(Transaction a, Transaction b) {
    final sameAmount = a.transactionAmount == b.transactionAmount;
    final sameType = a.transactionType == b.transactionType;
    final sameDescription = (a.comments ?? '') == (b.comments ?? '');
    final sameDay = a.transactionDate.year == b.transactionDate.year &&
                    a.transactionDate.month == b.transactionDate.month &&
                    a.transactionDate.day == b.transactionDate.day;

    return sameAmount && sameType && sameDay && sameDescription;
  }

  /// Get unsynced count
  Future<int> getUnsyncedCount() async {
    final unsynced = await _db.transactionDao.getUnsyncedTransactions();
    return unsynced.length;
  }

  // ============ BALANCE OPERATIONS ============

  /// Recalculate all running balances for a ledger
  /// Call this after sync or when balances seem incorrect
  Future<void> recalculateBalances(int ledgerId) async {
    debugPrint('🔄 Recalculating balances for ledger $ledgerId...');

    // Get ledger's opening balance
    final ledger = await _db.ledgerDao.getLedgerById(ledgerId);
    if (ledger == null) {
      debugPrint('❌ Ledger not found: $ledgerId');
      return;
    }

    final openingBalance = ledger.openingBalance;

    // Get all transactions ordered by date (ascending)
    final transactions = await _db.transactionDao.getTransactionsForBalanceCalculation(ledgerId);

    if (transactions.isEmpty) {
      debugPrint('📭 No transactions to recalculate');
      return;
    }

    double runningBalance = openingBalance;

    for (final t in transactions) {
      final lastBalance = runningBalance;

      // Calculate new balance
      // Khatabook logic (matches server):
      // IN (You Got/Received money from customer) = Balance DECREASES
      // OUT (You Gave money to customer) = Balance INCREASES
      if (t.transactionType == 'IN') {
        runningBalance -= t.transactionAmount;
      } else {
        runningBalance += t.transactionAmount;
      }

      // Update transaction with correct balances
      await _db.transactionDao.updateTransactionBalance(
        t.id,
        runningBalance,
        lastBalance,
      );
    }

    // Update ledger's current balance
    await _db.ledgerDao.updateLedgerBalance(ledgerId, runningBalance);

    debugPrint('✅ Recalculated ${transactions.length} transactions');
    debugPrint('💰 Final balance: $runningBalance');
  }

  /// Get transactions with balances merged (online + offline)
  /// This ensures offline transactions show correct running balance
  /// Includes deleted transactions for UI display (with strikethrough)
  Future<List<TransactionItemModel>> getTransactionsWithBalances(int ledgerId) async {
    // Get ALL transactions including deleted (for display with strikethrough)
    final allTransactions = await _db.transactionDao.getAllTransactionsByLedgerForDisplay(ledgerId);

    // Check if any non-deleted transaction has zero balance (needs recalculation)
    bool needsRecalculation = false;
    try {
      needsRecalculation = allTransactions.any((t) {
        if (t.isDelete) return false; // Skip deleted for recalc check
        final dynamic dynT = t;
        final currentBal = (dynT.currentBalance as num?)?.toDouble() ?? 0.0;
        final lastBal = (dynT.lastBalance as num?)?.toDouble() ?? 0.0;
        return currentBal == 0 && lastBal == 0;
      });
    } catch (e) {
      // Fields don't exist yet - recalculate all
      needsRecalculation = allTransactions.where((t) => !t.isDelete).isNotEmpty;
    }

    if (needsRecalculation && allTransactions.where((t) => !t.isDelete).isNotEmpty) {
      await recalculateBalances(ledgerId);
      // Re-fetch after recalculation (including deleted)
      final updated = await _db.transactionDao.getAllTransactionsByLedgerForDisplay(ledgerId);
      return updated.map(_dbTransactionToModel).toList();
    }

    return allTransactions.map(_dbTransactionToModel).toList();
  }

  /// Get updated ledger balance from DB (call after recalculation)
  Future<double> getLedgerBalanceFromDb(int ledgerId) async {
    final ledger = await _db.ledgerDao.getLedgerById(ledgerId);
    return ledger?.currentBalance ?? 0.0;
  }

  /// Get unsynced transactions for a ledger
  Future<List<TransactionItemModel>> getUnsyncedTransactionsByLedger(int ledgerId) async {
    final unsynced = await _db.transactionDao.getUnsyncedTransactionsByLedger(ledgerId);
    return unsynced.map(_dbTransactionToModel).toList();
  }
}
