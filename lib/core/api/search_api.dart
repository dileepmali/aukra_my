import 'package:flutter/material.dart';
import '../../models/ledger_model.dart';
import '../../models/transaction_list_model.dart';
import 'auth_storage.dart';
import 'global_api_function.dart';

/// API class for Search functionality
/// Fetches all ledgers (customers, suppliers, employees) and transactions for search
class SearchApi {
  final ApiFetcher _apiFetcher = ApiFetcher();

  bool get isLoading => _apiFetcher.isLoading;
  String? get errorMessage => _apiFetcher.errorMessage;

  /// Fetch all ledgers (customers, suppliers, employees) for search
  /// Returns combined list of all party types
  Future<List<LedgerModel>> getAllLedgers() async {
    try {
      debugPrint('🔍 Fetching all ledgers for search...');

      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) {
        throw Exception('Merchant ID not found');
      }

      List<LedgerModel> allLedgers = [];

      // Fetch all party types in parallel
      final partyTypes = ['CUSTOMER', 'SUPPLIER', 'EMPLOYEE'];

      for (String partyType in partyTypes) {
        try {
          await _apiFetcher.request(
            url: 'api/ledger/$merchantId?partyType=$partyType',
            method: 'GET',
            requireAuth: true,
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout for $partyType');
            },
          );

          if (_apiFetcher.errorMessage == null) {
            List<LedgerModel> ledgerList = [];

            if (_apiFetcher.data is Map && _apiFetcher.data['data'] is List) {
              final dataList = _apiFetcher.data['data'] as List;
              ledgerList = dataList
                  .map((json) => LedgerModel.fromJson(json as Map<String, dynamic>))
                  .toList();
            } else if (_apiFetcher.data is List) {
              ledgerList = (_apiFetcher.data as List)
                  .map((json) => LedgerModel.fromJson(json as Map<String, dynamic>))
                  .toList();
            }

            allLedgers.addAll(ledgerList);
            debugPrint('   ✅ Fetched ${ledgerList.length} $partyType records');
          }
        } catch (e) {
          debugPrint('   ⚠️ Error fetching $partyType: $e');
        }
      }

      debugPrint('✅ Total ledgers fetched: ${allLedgers.length}');
      return allLedgers;
    } catch (e) {
      debugPrint('❌ Error fetching ledgers: $e');
      rethrow;
    }
  }

  /// Fetch all transactions for search
  Future<List<TransactionItemModel>> getAllTransactions() async {
    try {
      debugPrint('🔍 Fetching all transactions for search...');

      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) {
        throw Exception('Merchant ID not found');
      }

      await _apiFetcher.request(
        url: 'api/ledgerTransaction/$merchantId',
        method: 'GET',
        requireAuth: true,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (_apiFetcher.errorMessage != null) {
        throw Exception(_apiFetcher.errorMessage);
      }

      List<TransactionItemModel> transactions = [];

      if (_apiFetcher.data is Map && _apiFetcher.data['data'] is List) {
        final dataList = _apiFetcher.data['data'] as List;
        transactions = dataList
            .map((json) => TransactionItemModel.fromJson(json as Map<String, dynamic>))
            .where((t) => !t.isDelete) // Filter out deleted transactions
            .toList();
      }

      debugPrint('✅ Fetched ${transactions.length} transactions');
      return transactions;
    } catch (e) {
      debugPrint('❌ Error fetching transactions: $e');
      rethrow;
    }
  }

  /// Fetch ledgers by specific party type with pagination
  /// Returns a map with 'data' (list of ledgers) and 'totalCount' (total items)
  Future<Map<String, dynamic>> getLedgersByPartyType(
    String partyType, {
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      debugPrint('🔍 Fetching $partyType ledgers (skip: $skip, limit: $limit)...');

      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) {
        throw Exception('Merchant ID not found');
      }

      await _apiFetcher.request(
        url: 'api/ledger/$merchantId?partyType=$partyType&skip=$skip&limit=$limit',
        method: 'GET',
        requireAuth: true,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (_apiFetcher.errorMessage != null) {
        throw Exception(_apiFetcher.errorMessage);
      }

      List<LedgerModel> ledgerList = [];
      int totalCount = 0;

      if (_apiFetcher.data is Map && _apiFetcher.data['data'] is List) {
        final dataList = _apiFetcher.data['data'] as List;
        ledgerList = dataList
            .map((json) => LedgerModel.fromJson(json as Map<String, dynamic>))
            .toList();
        // Use totalCount if available, otherwise use count
        totalCount = _apiFetcher.data['totalCount'] ?? _apiFetcher.data['count'] ?? ledgerList.length;
      } else if (_apiFetcher.data is List) {
        ledgerList = (_apiFetcher.data as List)
            .map((json) => LedgerModel.fromJson(json as Map<String, dynamic>))
            .toList();
        totalCount = ledgerList.length;
      }

      debugPrint('✅ Fetched ${ledgerList.length} $partyType records (total: $totalCount)');
      return {
        'data': ledgerList,
        'totalCount': totalCount,
      };
    } catch (e) {
      debugPrint('❌ Error fetching $partyType ledgers: $e');
      rethrow;
    }
  }
}
