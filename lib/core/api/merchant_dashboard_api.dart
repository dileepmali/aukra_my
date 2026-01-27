import 'package:flutter/material.dart';
import '../../models/merchant_dashboard_model.dart';
import '../../models/party_dashboard_model.dart';
import 'auth_storage.dart';
import 'global_api_function.dart';

/// API class for merchant dashboard operations
class MerchantDashboardApi {
  final ApiFetcher _apiFetcher = ApiFetcher();

  /// Fetch merchant dashboard data (global)
  /// GET /api/merchant/{merchantId}/dashboard
  Future<MerchantDashboardModel> getMerchantDashboard() async {
    try {
      debugPrint('📊 Fetching merchant dashboard data...');

      // Get merchant ID from storage
      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) {
        throw Exception('Merchant ID not found in storage');
      }

      debugPrint('🏢 Merchant ID: $merchantId');

      // Call API
      await _apiFetcher.request(
        url: 'api/merchant/$merchantId/dashboard',
        method: 'GET',
        requireAuth: true,
      ).timeout(
        const Duration(seconds: 10),
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

      debugPrint('📥 Dashboard Response: ${_apiFetcher.data}');

      // Parse response
      final dashboardModel = MerchantDashboardModel.fromJson(
        _apiFetcher.data as Map<String, dynamic>,
      );

      debugPrint('✅ Dashboard data parsed successfully');
      debugPrint('   - Global Today In: ₹${dashboardModel.todayIn}');
      debugPrint('   - Global Today Out: ₹${dashboardModel.todayOut}');
      debugPrint('   - Overall Given: ₹${dashboardModel.overallGiven}');
      debugPrint('   - Overall Received: ₹${dashboardModel.overallReceived}');
      debugPrint('   - Customer: Balance ₹${dashboardModel.party.customer.netBalance}, Received ₹${dashboardModel.party.customer.overallReceived}, Given ₹${dashboardModel.party.customer.overallGiven}');
      debugPrint('   - Supplier: Balance ₹${dashboardModel.party.supplier.netBalance}, Received ₹${dashboardModel.party.supplier.overallReceived}, Given ₹${dashboardModel.party.supplier.overallGiven}');
      debugPrint('   - Employee: Balance ₹${dashboardModel.party.employee.netBalance}, Received ₹${dashboardModel.party.employee.overallReceived}, Given ₹${dashboardModel.party.employee.overallGiven}');

      return dashboardModel;
    } catch (e) {
      debugPrint('❌ Error fetching merchant dashboard: $e');
      rethrow;
    }
  }

  /// Fetch party-specific dashboard data
  /// GET /api/merchant/{merchantId}/{partyType}/dashboard
  /// partyType: 'CUSTOMER', 'SUPPLIER', 'EMPLOYEE'
  ///
  /// Response:
  /// {
  ///   "todayIn": 0,
  ///   "todayOut": 0,
  ///   "overallGiven": 214368752.95,
  ///   "overallReceived": 17743.31,
  ///   "netBalance": 214351009.65,
  ///   "netBalanceType": "OUT",
  ///   "total": 8
  /// }
  Future<PartyDashboardModel> getPartyDashboard({
    required String partyType,
  }) async {
    try {
      debugPrint('📊 Fetching $partyType dashboard data...');

      // Get merchant ID from storage
      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) {
        throw Exception('Merchant ID not found in storage');
      }

      debugPrint('🏢 Merchant ID: $merchantId');
      debugPrint('👥 Party Type: $partyType');

      // Call API: /api/merchant/{merchantId}/{partyType}/dashboard
      await _apiFetcher.request(
        url: 'api/merchant/$merchantId/$partyType/dashboard',
        method: 'GET',
        requireAuth: true,
      ).timeout(
        const Duration(seconds: 10),
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

      debugPrint('📥 Party Dashboard Response: ${_apiFetcher.data}');

      // Parse response
      final partyDashboard = PartyDashboardModel.fromJson(
        _apiFetcher.data as Map<String, dynamic>,
      );

      debugPrint('✅ $partyType Dashboard data parsed successfully');
      debugPrint('   - Today In: ₹${partyDashboard.todayIn}');
      debugPrint('   - Today Out: ₹${partyDashboard.todayOut}');
      debugPrint('   - Overall Given: ₹${partyDashboard.overallGiven}');
      debugPrint('   - Overall Received: ₹${partyDashboard.overallReceived}');
      debugPrint('   - Net Balance: ₹${partyDashboard.netBalance} (${partyDashboard.netBalanceType})');
      debugPrint('   - Total: ${partyDashboard.total}');

      return partyDashboard;
    } catch (e) {
      debugPrint('❌ Error fetching $partyType dashboard: $e');
      rethrow;
    }
  }
}
