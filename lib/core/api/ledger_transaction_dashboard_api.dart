import 'package:flutter/material.dart';
import '../../models/ledger_transaction_dashboard_model.dart';
import 'auth_storage.dart';
import 'global_api_function.dart';

/// API class for Ledger Transaction Dashboard
/// Fetches transaction list with filters, sorting, and pagination
class LedgerTransactionDashboardApi {
  final ApiFetcher _apiFetcher = ApiFetcher();

  /// Fetch ledger transactions with filters and pagination
  /// GET /api/ledgerTransaction/{merchantId}/dashboard
  ///
  /// Query Parameters:
  /// - partyType: CUSTOMER, SUPPLIER, EMPLOYEE (optional)
  /// - skip: number of records to skip (pagination)
  /// - limit: number of records to fetch
  /// - search: search by partyName
  /// - sortBy: sort field name (e.g. partyName, amount, transactionDate)
  /// - sortOrder: sort direction (asc, desc)
  /// - dateFilter: today, yesterday, older_week, older_month, custom, all_time
  /// - startDate: start date for custom range (ISO format)
  /// - endDate: end date for custom range (ISO format)
  /// - transactionType: IN, OUT (optional)


  Future<LedgerTransactionDashboardModel> getLedgerTransactionDashboard({
    String? partyType,
    int skip = 0,
    int limit = 20,
    String? search,
    String? sortBy,
    String? sortOrder,
    String? dateFilter,
    DateTime? startDate,
    DateTime? endDate,
    String? transactionType,
  }) async {
    try {
      debugPrint('📊 Fetching Ledger Transaction Dashboard...');

      // Get merchant ID from storage
      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) {
        throw Exception('Merchant ID not found in storage');
      }

      debugPrint('🏢 Merchant ID: $merchantId');

      // Build query parameters
      final queryParams = <String, String>{};

      // Pagination
      queryParams['skip'] = skip.toString();
      queryParams['limit'] = limit.toString();

      // Party Type filter
      if (partyType != null && partyType.isNotEmpty) {
        queryParams['partyType'] = partyType;
      }

      // Search filter
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Sorting - separate sortBy and sortOrder params
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }
      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sortOrder'] = sortOrder;
      }

      // Date filter
      if (dateFilter != null && dateFilter.isNotEmpty && dateFilter != 'all_time') {
        queryParams['dateFilter'] = dateFilter;
      }

      // Custom date range
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      // Transaction type filter (IN/OUT)
      if (transactionType != null && transactionType.isNotEmpty) {
        queryParams['transactionType'] = transactionType;
      }

      // Build URL with query string
      String url = 'api/ledgerTransaction/$merchantId/dashboard';
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url = '$url?$queryString';
      }

      debugPrint('🔗 API URL: $url');
      debugPrint('📋 Query Params: $queryParams');

      // Make API request
      await _apiFetcher.request(
        url: url,
        method: 'GET',
        requireAuth: true,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout. Please try again.');
        },
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        debugPrint('❌ API Error: ${_apiFetcher.errorMessage}');
        throw Exception(_apiFetcher.errorMessage);
      }

      // Check if data is null
      if (_apiFetcher.data == null) {
        throw Exception('No data received from server');
      }

      debugPrint('📥 Response received');

      // Parse response
      final model = LedgerTransactionDashboardModel.fromJson(
        _apiFetcher.data as Map<String, dynamic>,
      );

      debugPrint('✅ Ledger Transaction Dashboard loaded successfully');
      debugPrint('   - Count: ${model.count}');
      debugPrint('   - Total Count: ${model.totalCount}');
      debugPrint('   - Data Items: ${model.data.length}');

      return model;
    } catch (e) {
      debugPrint('❌ Error fetching ledger transaction dashboard: $e');
      rethrow;
    }
  }
}