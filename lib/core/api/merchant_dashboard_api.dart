import 'package:flutter/material.dart';
import '../../models/merchant_dashboard_model.dart';
import 'auth_storage.dart';
import 'global_api_function.dart';

/// API class for merchant dashboard operations
class MerchantDashboardApi {
  final ApiFetcher _apiFetcher = ApiFetcher();

  /// Fetch merchant dashboard data
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
      debugPrint('   - Today In: ₹${dashboardModel.todayIn}');
      debugPrint('   - Today Out: ₹${dashboardModel.todayOut}');
      debugPrint('   - Overall Given: ₹${dashboardModel.overallGiven}');
      debugPrint('   - Overall Received: ₹${dashboardModel.overallReceived}');
      debugPrint('   - Total Net Balance: ₹${dashboardModel.totalNetBalance}');
      debugPrint('   - Customer Balance: ₹${dashboardModel.party.customer.netBalance}');
      debugPrint('   - Supplier Balance: ₹${dashboardModel.party.supplier.netBalance}');
      debugPrint('   - Employee Balance: ₹${dashboardModel.party.employee.netBalance}');

      return dashboardModel;
    } catch (e) {
      debugPrint('❌ Error fetching merchant dashboard: $e');
      rethrow;
    }
  }
}
