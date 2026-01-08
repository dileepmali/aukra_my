import 'package:flutter/material.dart';
import '../../models/merchant_list_model.dart';
import 'global_api_function.dart';

/// API class for merchant list operations
class MerchantListApi {
  final ApiFetcher _apiFetcher = ApiFetcher();

  /// Fetch all merchants for the current user
  /// GET /api/merchant/all
  Future<List<MerchantListModel>> getAllMerchants() async {
    try {
      debugPrint('📋 Fetching all merchants...');

      // Call API
      await _apiFetcher.request(
        url: 'api/merchant/all',
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

      debugPrint('📥 Merchants Response: ${_apiFetcher.data}');

      // Parse response as list
      final List<dynamic> merchantsJson = _apiFetcher.data as List<dynamic>;

      // Convert to list of MerchantListModel
      final List<MerchantListModel> merchants = merchantsJson
          .map((json) => MerchantListModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ Fetched ${merchants.length} merchants successfully');

      // Log merchant details
      for (var merchant in merchants) {
        debugPrint('   - ${merchant.businessName} (ID: ${merchant.merchantId})');
        debugPrint('     Phone: ${merchant.formattedPhone}');
        debugPrint('     Main Account: ${merchant.isMainAccount}');
        debugPrint('     Access: ${merchant.action}');
      }

      return merchants;
    } catch (e) {
      debugPrint('❌ Error fetching all merchants: $e');
      rethrow;
    }
  }

  /// Get error message from last API call
  String? get errorMessage => _apiFetcher.errorMessage;
}
