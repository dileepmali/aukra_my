import 'package:flutter/material.dart';
import '../../models/ledger_detail_model.dart';
import 'global_api_function.dart';

class LedgerDetailApi {
  final ApiFetcher _apiFetcher = ApiFetcher();

  /// Get ledger details by ledger ID
  /// GET /api/ledger/{ledgerId}/details
  Future<LedgerDetailModel> getLedgerDetails(int ledgerId) async {
    try {
      debugPrint('🔍 Fetching ledger details for ID: $ledgerId');

      await _apiFetcher.request(
        url: 'api/ledger/$ledgerId/details',
        method: 'GET',
        requireAuth: true,
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        throw Exception(_apiFetcher.errorMessage);
      }

      // Parse success response
      if (_apiFetcher.data is Map) {
        debugPrint('✅ Ledger details fetched successfully');
        return LedgerDetailModel.fromJson(
          _apiFetcher.data as Map<String, dynamic>,
        );
      }

      throw Exception('Invalid response format');
    } catch (e) {
      debugPrint('❌ Error fetching ledger details: $e');
      rethrow;
    }
  }

  /// Get ledger transaction history by ledger ID
  /// GET /api/ledgerTransaction/{ledgerId}
  Future<LedgerTransactionHistory> getLedgerTransactions(int ledgerId) async {
    try {
      debugPrint('🔍 Fetching transactions for ledger ID: $ledgerId');

      await _apiFetcher.request(
        url: 'api/ledgerTransaction/$ledgerId',
        method: 'GET',
        requireAuth: true,
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        throw Exception(_apiFetcher.errorMessage);
      }

      // Parse success response
      if (_apiFetcher.data is Map) {
        final data = _apiFetcher.data as Map<String, dynamic>;
        debugPrint('✅ Transactions fetched successfully');
        debugPrint('   Transaction count: ${data['data']?.length ?? 0}');

        return LedgerTransactionHistory.fromJson(data);
      }

      throw Exception('Invalid response format');
    } catch (e) {
      debugPrint('❌ Error fetching transactions: $e');
      rethrow;
    }
  }

  /// Get loading state
  bool get isLoading => _apiFetcher.isLoading;

  /// Get error message
  String? get errorMessage => _apiFetcher.errorMessage;
}
