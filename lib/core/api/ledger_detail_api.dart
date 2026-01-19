import 'package:flutter/material.dart';
import '../../models/ledger_detail_model.dart';
import '../../models/ledger_dashboard_summary_model.dart';
import '../../models/ledger_monthly_dashboard_model.dart';
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

  /// Get dashboard summary for a ledger
  /// GET /api/ledger/{ledgerId}/dashboard/summary
  ///
  /// Returns today's and overall IN/OUT totals
  /// Note: Uses separate ApiFetcher to avoid race condition when called in parallel
  Future<LedgerDashboardSummaryModel> getDashboardSummary(int ledgerId) async {
    // Use separate ApiFetcher instance to avoid race condition with parallel API calls
    final summaryApiFetcher = ApiFetcher();

    try {
      debugPrint('📊 Fetching dashboard summary for ledger ID: $ledgerId');

      await summaryApiFetcher.request(
        url: 'api/ledger/$ledgerId/dashboard/summary',
        method: 'GET',
        requireAuth: true,
      );

      // Check for errors
      if (summaryApiFetcher.errorMessage != null) {
        throw Exception(summaryApiFetcher.errorMessage);
      }

      // Parse success response
      if (summaryApiFetcher.data is Map) {
        debugPrint('✅ Dashboard summary fetched successfully');
        return LedgerDashboardSummaryModel.fromJson(
          summaryApiFetcher.data as Map<String, dynamic>,
        );
      }

      throw Exception('Invalid response format');
    } catch (e) {
      debugPrint('❌ Error fetching dashboard summary: $e');
      rethrow;
    }
  }

  /// Get monthly dashboard data for a ledger
  /// GET /api/ledger/{ledgerId}/dashboard
  ///
  /// Returns current month's IN/OUT totals with date range
  /// Note: Uses separate ApiFetcher to avoid race condition when called in parallel
  Future<LedgerMonthlyDashboardModel> getMonthlyDashboard(int ledgerId) async {
    // Use separate ApiFetcher instance to avoid race condition with parallel API calls
    final monthlyApiFetcher = ApiFetcher();

    try {
      // Calculate current month's start and end dates
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0); // Last day of current month

      final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

      debugPrint('📅📅📅 START: Fetching monthly dashboard for ledger ID: $ledgerId');
      debugPrint('📅📅📅 Date range: $startDateStr to $endDateStr');

      await monthlyApiFetcher.request(
        url: 'api/ledger/$ledgerId/dashboard?startDate=$startDateStr&endDate=$endDateStr',
        method: 'GET',
        requireAuth: true,
      );

      debugPrint('📅📅📅 API call completed');
      debugPrint('📅📅📅 Error message: ${monthlyApiFetcher.errorMessage}');
      debugPrint('📅📅📅 Data type: ${monthlyApiFetcher.data?.runtimeType}');
      debugPrint('📅📅📅 Data: ${monthlyApiFetcher.data}');

      // Check for errors
      if (monthlyApiFetcher.errorMessage != null) {
        throw Exception(monthlyApiFetcher.errorMessage);
      }

      // Parse success response
      if (monthlyApiFetcher.data is Map) {
        final data = monthlyApiFetcher.data as Map<String, dynamic>;
        debugPrint('📅📅📅 Monthly Dashboard Raw Response: $data');
        debugPrint('📅📅📅 totalIn: ${data['totalIn']}, totalOut: ${data['totalOut']}');
        return LedgerMonthlyDashboardModel.fromJson(data);
      }

      debugPrint('📅📅📅 Data is not a Map, returning default values');
      throw Exception('Invalid response format');
    } catch (e) {
      debugPrint('📅📅📅 ERROR fetching monthly dashboard: $e');
      rethrow;
    }
  }

  /// Get loading state
  bool get isLoading => _apiFetcher.isLoading;

  /// Get error message
  String? get errorMessage => _apiFetcher.errorMessage;
}
