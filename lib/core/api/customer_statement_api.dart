import 'package:flutter/material.dart';
import '../../models/customer_statement_model.dart';
import '../../models/ledger_model.dart';
import 'auth_storage.dart';
import 'global_api_function.dart';

/// API class for Customer Statement operations
/// Fetches customer list from ledger API
/// NOTE: netBalance, totalCustomers, todayIn/Out now come from Dashboard API
class CustomerStatementApi {
  final ApiFetcher _apiFetcher = ApiFetcher();

  /// Fetch customer list only
  /// GET /api/ledger/{merchantId}?partyType=CUSTOMER
  Future<CustomerStatementModel> getCustomerStatement({
    required String partyType, // 'CUSTOMER', 'SUPPLIER', 'EMPLOYEE'
  }) async {
    try {
      debugPrint('📊 Fetching $partyType list...');

      // Get merchant ID from storage
      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) {
        throw Exception('Merchant ID not found in storage');
      }

      debugPrint('🏢 Merchant ID: $merchantId');

      // Fetch customer/supplier/employee list
      await _apiFetcher.request(
        url: 'api/ledger/$merchantId?partyType=$partyType',
        method: 'GET',
        requireAuth: true,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout. Please try again.');
        },
      );

      if (_apiFetcher.errorMessage != null) {
        throw Exception(_apiFetcher.errorMessage);
      }

      // Parse customer list
      List<LedgerModel> ledgerList = [];
      if (_apiFetcher.data is Map && _apiFetcher.data['data'] is List) {
        // Nested format: {count: 3, data: [...]}
        final dataList = _apiFetcher.data['data'] as List;
        ledgerList = dataList
            .map((json) => LedgerModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (_apiFetcher.data is List) {
        // Direct array format: [...]
        ledgerList = (_apiFetcher.data as List)
            .map((json) => LedgerModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      debugPrint('✅ Fetched ${ledgerList.length} $partyType records');

      // Convert ledger list to customer statement items
      final customers = ledgerList.map((ledger) {
        return CustomerStatementItem(
          id: ledger.id ?? 0,
          name: ledger.name,
          location: ledger.area.isNotEmpty
              ? ledger.area
              : (ledger.address.isNotEmpty ? ledger.address : 'N/A'),
          balance: ledger.currentBalance.abs(),
          balanceType: ledger.currentBalance >= 0 ? 'IN' : 'OUT',
          lastTransactionDate: ledger.updatedAt ?? DateTime.now(),
          mobileNumber: ledger.mobileNumber,
        );
      }).toList();

      // Sort by last transaction date (most recent first)
      customers.sort((a, b) =>
          b.lastTransactionDate.compareTo(a.lastTransactionDate));

      // Create statement model (only customers list)
      final statementModel = CustomerStatementModel(
        customers: customers,
      );

      debugPrint('✅ Customer list prepared successfully');
      return statementModel;
    } catch (e) {
      debugPrint('❌ Error fetching customer list: $e');
      rethrow;
    }
  }

  /// Export transactions API
  /// GET /api/export/{merchantId}/transaction
  /// Returns jobId and status for export
  Future<Map<String, dynamic>> exportTransactions({
    String? partyType,
  }) async {
    try {
      // Get merchant ID from storage
      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) {
        throw Exception('Merchant ID not found');
      }

      debugPrint('📥 Exporting transactions for merchant: $merchantId');
      debugPrint('   - Party Type: $partyType');

      // Build URL with query params
      String url = 'api/export/$merchantId/transaction';
      if (partyType != null) {
        url += '?partyType=$partyType';
      }

      await _apiFetcher.request(
        url: url,
        method: 'GET',
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage != null) {
        throw Exception(_apiFetcher.errorMessage);
      }

      final response = _apiFetcher.data as Map<String, dynamic>;

      debugPrint('📥 Export Response: $response');
      debugPrint('   - Message: ${response['message']}');
      debugPrint('   - Job ID: ${response['jobId']}');
      debugPrint('   - Status: ${response['status']}');
      debugPrint('   - Download URL: ${response['downloadUrl'] ?? response['fileUrl'] ?? 'N/A'}');

      return response;
    } catch (e) {
      debugPrint('❌ Error exporting transactions: $e');
      rethrow;
    }
  }
}
