import 'package:flutter/material.dart';
import '../../models/ledger_model.dart';
import 'global_api_function.dart';

class LedgerApi {
  final ApiFetcher _apiFetcher = ApiFetcher();

  /// Create a new ledger entry (customer/supplier)
  ///
  /// Returns a success message or throws an error
  Future<LedgerCreateResponse> createLedger(LedgerModel ledger) async {
    try {
      await _apiFetcher.request(
        url: 'api/ledger',
        method: 'POST',
        body: ledger.toJson(),
        requireAuth: true,
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        // Parse error response
        if (_apiFetcher.data is Map) {
          final errorResponse = LedgerErrorResponse.fromJson(
            _apiFetcher.data as Map<String, dynamic>,
          );
          throw Exception(errorResponse.getErrorMessages());
        }
        throw Exception(_apiFetcher.errorMessage);
      }

      // Parse success response
      if (_apiFetcher.data is Map) {
        return LedgerCreateResponse.fromJson(
          _apiFetcher.data as Map<String, dynamic>,
        );
      }

      // Default success message
      return LedgerCreateResponse(message: 'Created successfully');
    } catch (e) {
      debugPrint('❌ Ledger API Error: $e');
      rethrow;
    }
  }

  /// Get loading state
  bool get isLoading => _apiFetcher.isLoading;

  /// Get error message
  String? get errorMessage => _apiFetcher.errorMessage;

  /// Get raw data
  dynamic get data => _apiFetcher.data;
}
