import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../api/ledger_api.dart';
import '../../api/search_api.dart';
import '../../services/connectivity_service.dart';
import '../../../models/ledger_model.dart';
import '../../../models/ledger_detail_model.dart';
import '../app_database.dart';

/// Repository for Ledger data
/// Handles offline-first logic: read from local DB, sync with server
class LedgerRepository {
  final AppDatabase _db = AppDatabase.instance;
  final LedgerApi _ledgerApi = LedgerApi();
  final SearchApi _searchApi = SearchApi();
  final Uuid _uuid = const Uuid();

  // ============ READ OPERATIONS ============

  /// Get ledgers by party type - OFFLINE FIRST
  /// 1. Return cached data immediately
  /// 2. Fetch from API in background
  /// 3. Update cache with new data
  Future<List<LedgerModel>> getLedgersByPartyType(
    int merchantId,
    String partyType, {
    bool forceRefresh = false,
  }) async {
    try {
      debugPrint('');
      debugPrint('🔵🔵🔵 LEDGER_REPOSITORY: getLedgersByPartyType() 🔵🔵🔵');
      debugPrint('   merchantId: $merchantId');
      debugPrint('   partyType: $partyType');
      debugPrint('   forceRefresh: $forceRefresh');

      // 1. Get cached data first
      final cachedLedgers = await _db.ledgerDao.getLedgersByPartyType(merchantId, partyType);
      debugPrint('   📦 Cached ledgers count: ${cachedLedgers.length}');

      // If we have cached data and not forcing refresh, return it
      if (cachedLedgers.isNotEmpty && !forceRefresh) {
        debugPrint('   ✅ Returning ${cachedLedgers.length} cached $partyType ledgers');

        // Refresh in background if online
        _refreshLedgersInBackground(merchantId, partyType);

        return cachedLedgers.map(_dbLedgerToModel).toList();
      }

      // 2. If no cache or force refresh, try API
      final isOnline = ConnectivityService.instance.isConnected.value;
      debugPrint('   🌐 Is Online: $isOnline');

      if (isOnline) {
        debugPrint('   🔄 No cache, fetching from API...');
        return await _fetchAndCacheLedgers(merchantId, partyType);
      }

      // 3. Return cached data even if empty when offline
      debugPrint('   📴 Offline - returning ${cachedLedgers.length} cached');
      return cachedLedgers.map(_dbLedgerToModel).toList();
    } catch (e) {
      debugPrint('   ❌ ERROR in getLedgersByPartyType: $e');
      // Return cached data on error
      final cachedLedgers = await _db.ledgerDao.getLedgersByPartyType(merchantId, partyType);
      return cachedLedgers.map(_dbLedgerToModel).toList();
    }
  }

  /// Watch ledgers stream (reactive)
  Stream<List<LedgerModel>> watchLedgersByPartyType(int merchantId, String partyType) {
    return _db.ledgerDao
        .watchLedgersByPartyType(merchantId, partyType)
        .map((ledgers) => ledgers.map(_dbLedgerToModel).toList());
  }

  /// Get single ledger by ID
  Future<LedgerModel?> getLedgerById(int id) async {
    final cached = await _db.ledgerDao.getLedgerById(id);
    if (cached != null) {
      return _dbLedgerToModel(cached);
    }
    return null;
  }

  /// Search ledgers locally
  Future<List<LedgerModel>> searchLedgers(int merchantId, String query) async {
    final results = await _db.ledgerDao.searchLedgers(merchantId, query);
    return results.map(_dbLedgerToModel).toList();
  }

  /// Get all ledgers for search
  Future<List<LedgerModel>> getAllLedgersForSearch(int merchantId) async {
    final cached = await _db.ledgerDao.getLedgersByMerchant(merchantId);
    if (cached.isNotEmpty) {
      return cached.map(_dbLedgerToModel).toList();
    }

    // If no cache, try API
    if (ConnectivityService.instance.isConnected.value) {
      try {
        final apiLedgers = await _searchApi.getAllLedgers();
        await _cacheLedgers(apiLedgers);
        return apiLedgers;
      } catch (e) {
        debugPrint('❌ Error fetching all ledgers: $e');
      }
    }

    return [];
  }

  // ============ CREATE OPERATIONS ============

  /// Create new ledger - OFFLINE FIRST
  /// 1. Save to local DB immediately
  /// 2. Add to sync queue
  /// 3. Return immediately (UI updates)
  /// 4. Sync with server when online
  Future<LedgerModel> createLedger(LedgerModel ledger) async {
    final localId = _uuid.v4();
    final now = DateTime.now();

    // Generate temporary local ID (negative to avoid conflicts)
    final tempId = -DateTime.now().millisecondsSinceEpoch;

    // 1. Save to local DB
    final companion = LedgersCompanion(
      id: Value(tempId),
      merchantId: Value(ledger.merchantId),
      name: Value(ledger.name),
      partyType: Value(ledger.partyType),
      currentBalance: Value(ledger.openingBalance),
      openingBalance: Value(ledger.openingBalance),
      transactionType: Value(ledger.transactionType),
      creditLimit: Value(ledger.creditLimit),
      creditDay: Value(ledger.creditDay),
      interestType: Value(ledger.interestType),
      interestRate: Value(ledger.interestRate),
      mobileNumber: Value(ledger.mobileNumber),
      area: Value(ledger.area),
      address: Value(ledger.address),
      pinCode: Value(ledger.pinCode),
      isSynced: const Value(false),
      localId: Value(localId),
      createdAt: Value(now),
      updatedAt: Value(now),
      localUpdatedAt: Value(now),
      isActive: const Value(true),
    );

    await _db.ledgerDao.insertLedger(companion);
    debugPrint('💾 Ledger saved locally with temp ID: $tempId');

    // 2. Add to sync queue
    await _db.syncQueueDao.queueLedgerCreate(
      localId,
      jsonEncode(ledger.toJson()),
      ledger.merchantId,
    );
    debugPrint('📤 Ledger added to sync queue');

    // 3. Return model with temp ID
    return ledger.copyWith(id: tempId);
  }

  // ============ UPDATE OPERATIONS ============

  /// Update ledger - OFFLINE FIRST
  Future<bool> updateLedger(LedgerModel ledger) async {
    if (ledger.id == null) return false;

    final now = DateTime.now();

    // 1. Update local DB
    final companion = LedgersCompanion(
      name: Value(ledger.name),
      creditLimit: Value(ledger.creditLimit),
      creditDay: Value(ledger.creditDay),
      interestType: Value(ledger.interestType),
      interestRate: Value(ledger.interestRate),
      area: Value(ledger.area),
      address: Value(ledger.address),
      pinCode: Value(ledger.pinCode),
      isSynced: const Value(false),
      localUpdatedAt: Value(now),
    );

    await _db.ledgerDao.updateLedgerById(ledger.id!, companion);
    debugPrint('💾 Ledger updated locally: ${ledger.id}');

    // 2. Add to sync queue (only if server ID, not temp ID)
    if (ledger.id! > 0) {
      await _db.syncQueueDao.queueLedgerUpdate(
        ledger.id!,
        jsonEncode(ledger.toUpdateJson()),
      );
      debugPrint('📤 Ledger update added to sync queue');
    }

    return true;
  }

  /// Update ledger status (activate/deactivate)
  Future<bool> updateLedgerStatus(int ledgerId, bool isActive, String securityKey) async {
    // 1. Update local DB
    if (isActive) {
      await _db.ledgerDao.activateLedger(ledgerId);
    } else {
      await _db.ledgerDao.deactivateLedger(ledgerId);
    }
    debugPrint('💾 Ledger status updated locally: $ledgerId -> $isActive');

    // 2. Add to sync queue
    await _db.syncQueueDao.queueLedgerStatusChange(
      ledgerId,
      jsonEncode({'isActive': isActive, 'securityKey': securityKey}),
    );

    return true;
  }

  // ============ SYNC OPERATIONS ============

  /// Fetch from API and cache
  Future<List<LedgerModel>> _fetchAndCacheLedgers(int merchantId, String partyType) async {
    try {
      debugPrint('');
      debugPrint('🟡🟡🟡 LEDGER_REPOSITORY: _fetchAndCacheLedgers() 🟡🟡🟡');
      debugPrint('   merchantId: $merchantId, partyType: $partyType');

      // Call API - NOTE: limit is NOT passed, so default 10 is used
      // TODO: Need to fetch ALL pages, not just first 10
      final result = await _searchApi.getLedgersByPartyType(partyType, limit: 1000);
      debugPrint('   📥 API result keys: ${result.keys.toList()}');

      final ledgers = result['data'] as List<LedgerModel>;
      final totalCount = result['totalCount'] ?? 0;
      debugPrint('   📊 Ledgers fetched: ${ledgers.length}');
      debugPrint('   📊 Total count from API: $totalCount');

      if (ledgers.isNotEmpty) {
        debugPrint('   💾 Caching ${ledgers.length} ledgers...');
        await _cacheLedgers(ledgers);
        debugPrint('   ✅ Cached ${ledgers.length} $partyType ledgers from API');
      } else {
        debugPrint('   ⚠️ API returned EMPTY ledgers list for $partyType');
      }

      return ledgers;
    } catch (e) {
      debugPrint('   ❌ ERROR in _fetchAndCacheLedgers: $e');
      rethrow;
    }
  }

  /// Refresh ledgers in background
  void _refreshLedgersInBackground(int merchantId, String partyType) async {
    if (!ConnectivityService.instance.isConnected.value) return;

    try {
      await _fetchAndCacheLedgers(merchantId, partyType);
    } catch (e) {
      debugPrint('⚠️ Background refresh failed: $e');
    }
  }

  /// Cache ledgers to local DB
  /// Also removes duplicate unsynced local ledgers that match API data
  /// NOTE: Server API is the source of truth. If API returns a ledger as active,
  /// it means the ledger is active on the server, so we should trust it.
  Future<void> _cacheLedgers(List<LedgerModel> ledgers) async {
    debugPrint('🗄️ _cacheLedgers: Processing ${ledgers.length} ledgers from API');

    // 1. First, get all unsynced local ledgers (created offline)
    final unsyncedLocal = await _db.ledgerDao.getUnsyncedLedgers();
    debugPrint('   📦 Found ${unsyncedLocal.length} unsynced local ledgers');

    // 2. For each API ledger, check if there's a matching unsynced local ledger
    //    Match by: name + mobileNumber + partyType (since offline ledger has no serverId)
    for (final apiLedger in ledgers) {
      for (final localLedger in unsyncedLocal) {
        final nameMatch = localLedger.name.toLowerCase() == apiLedger.name.toLowerCase();
        final mobileMatch = localLedger.mobileNumber == apiLedger.mobileNumber;
        final typeMatch = localLedger.partyType.toUpperCase() == apiLedger.partyType.toUpperCase();

        if (nameMatch && mobileMatch && typeMatch) {
          // Found a duplicate! Delete the local unsynced entry
          debugPrint('   🔄 Found duplicate: "${localLedger.name}" (local ID: ${localLedger.id}, API ID: ${apiLedger.id})');
          debugPrint('      Deleting local duplicate with ID: ${localLedger.id}');
          await _db.ledgerDao.deleteLedgerById(localLedger.id);
        }
      }
    }

    // 3. Now insert/upsert the API ledgers
    // API returns ACTIVE ledgers from server, so trust the server as source of truth
    // The API only returns active ledgers - if a ledger is in this list, it's active on server
    final companions = ledgers.map((l) {
      return LedgersCompanion(
        id: Value(l.id ?? 0),
        merchantId: Value(l.merchantId),
        name: Value(l.name),
        partyType: Value(l.partyType),
        currentBalance: Value(l.currentBalance),
        openingBalance: Value(l.openingBalance),
        transactionType: Value(l.transactionType),
        creditLimit: Value(l.creditLimit),
        creditDay: Value(l.creditDay),
        interestType: Value(l.interestType),
        interestRate: Value(l.interestRate),
        mobileNumber: Value(l.mobileNumber),
        area: Value(l.area),
        address: Value(l.address),
        pinCode: Value(l.pinCode),
        isSynced: const Value(true),
        createdAt: Value(l.createdAt),
        updatedAt: Value(l.updatedAt),
        transactionDate: Value(l.transactionDate),
        // Server says active, so set active - server is source of truth
        isActive: const Value(true),
      );
    }).toList();

    await _db.ledgerDao.insertMultipleLedgers(companions);
    debugPrint('   ✅ Cached ${ledgers.length} ledgers from API (all set to active)');
  }

  /// Full sync - fetch all ledgers from server
  Future<void> fullSync(int merchantId) async {
    if (!ConnectivityService.instance.isConnected.value) {
      debugPrint('📴 Cannot sync - device offline');
      return;
    }

    debugPrint('🔄 Starting full ledger sync...');

    for (final partyType in ['CUSTOMER', 'SUPPLIER', 'EMPLOYEE']) {
      try {
        await _fetchAndCacheLedgers(merchantId, partyType);
      } catch (e) {
        debugPrint('❌ Error syncing $partyType: $e');
      }
    }

    debugPrint('✅ Full ledger sync completed');
  }

  // ============ HELPERS ============

  /// Convert DB Ledger to LedgerModel
  LedgerModel _dbLedgerToModel(Ledger l) {
    return LedgerModel(
      id: l.id,
      name: l.name,
      creditLimit: l.creditLimit,
      creditDay: l.creditDay,
      interestType: l.interestType,
      openingBalance: l.openingBalance,
      currentBalance: l.currentBalance,
      transactionType: l.transactionType,
      interestRate: l.interestRate,
      mobileNumber: l.mobileNumber,
      area: l.area,
      address: l.address,
      merchantId: l.merchantId,
      pinCode: l.pinCode,
      partyType: l.partyType,
      createdAt: l.createdAt,
      updatedAt: l.updatedAt,
      transactionDate: l.transactionDate,
    );
  }

  /// Cache a single ledger detail from API to local DB
  /// Call this from controller after fetching ledger detail from API
  /// IMPORTANT: Preserves local isActive status for deactivated ledgers
  Future<void> cacheLedgerDetailFromApi(LedgerDetailModel detail) async {
    try {
      // Check if this ledger is locally deactivated
      final existingLedger = await _db.ledgerDao.getLedgerById(detail.id);
      final isLocallyDeactivated = existingLedger != null && !existingLedger.isActive;

      if (isLocallyDeactivated) {
        debugPrint('⚠️ Preserving deactivated status for ledger ${detail.id}: ${detail.partyName}');
      }

      final companion = LedgersCompanion(
        id: Value(detail.id),
        merchantId: Value(detail.merchantId),
        name: Value(detail.partyName),
        partyType: Value(detail.partyType),
        currentBalance: Value(detail.currentBalance),
        openingBalance: Value(detail.openingBalance),
        transactionType: Value(detail.transactionType),
        creditLimit: Value(detail.creditLimit),
        creditDay: Value(detail.creditDay),
        interestType: Value(detail.interestType),
        interestRate: Value(detail.interestRate),
        mobileNumber: Value(detail.mobileNumber ?? ''),
        area: Value(detail.area ?? ''),
        address: Value(detail.address ?? ''),
        pinCode: Value(detail.pinCode ?? ''),
        isSynced: const Value(true),
        createdAt: Value(detail.createdAt),
        updatedAt: Value(detail.updatedAt),
        // Preserve local deactivation status
        isActive: Value(!isLocallyDeactivated),
      );

      await _db.ledgerDao.upsertLedger(companion);
      debugPrint('💾 Ledger cached to local DB: ${detail.partyName}');
    } catch (e) {
      debugPrint('⚠️ Failed to cache ledger: $e');
    }
  }

  /// Clear all cached ledgers
  Future<void> clearCache() async {
    await _db.ledgerDao.deleteAllLedgers();
  }

  /// Get unsynced count
  Future<int> getUnsyncedCount() async {
    final unsynced = await _db.ledgerDao.getUnsyncedLedgers();
    return unsynced.length;
  }
}
