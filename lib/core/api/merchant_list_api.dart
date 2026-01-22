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

      debugPrint('📥 Merchants Response Type: ${_apiFetcher.data.runtimeType}');
      debugPrint('📥 Merchants Response: ${_apiFetcher.data}');

      // Parse response - handle both direct list and wrapped in 'data' key
      List<dynamic> merchantsJson;

      if (_apiFetcher.data is List) {
        // Direct list response
        merchantsJson = _apiFetcher.data as List<dynamic>;
      } else if (_apiFetcher.data is Map && _apiFetcher.data['data'] != null) {
        // Response wrapped in 'data' key
        debugPrint('📦 Response wrapped in data key');
        merchantsJson = _apiFetcher.data['data'] as List<dynamic>;
      } else if (_apiFetcher.data is Map && _apiFetcher.data['merchants'] != null) {
        // Response wrapped in 'merchants' key
        debugPrint('📦 Response wrapped in merchants key');
        merchantsJson = _apiFetcher.data['merchants'] as List<dynamic>;
      } else {
        debugPrint('❌ Unexpected response format: ${_apiFetcher.data.runtimeType}');
        throw Exception('Unexpected API response format');
      }

      // Convert to list of MerchantListModel
      final List<MerchantListModel> merchants = merchantsJson
          .map((json) => MerchantListModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ Fetched ${merchants.length} merchants successfully');

      // Log merchant details with all relevant fields
      for (var merchant in merchants) {
        debugPrint('   - ${merchant.businessName} (ID: ${merchant.merchantId})');
        debugPrint('     Phone: ${merchant.formattedPhone}');
        debugPrint('     Admin Mobile: ${merchant.adminMobileNumber}');
        debugPrint('     Mobile Number: ${merchant.mobileNumber}');
        debugPrint('     📱 Backup/Recovery Phone: ${merchant.backupPhoneNumber}');
        debugPrint('     Address: ${merchant.formattedAddress}');
        debugPrint('     Business Type: ${merchant.businessType}');
        debugPrint('     Category: ${merchant.category}');
        debugPrint('     Main Account: ${merchant.isMainAccount}');
        debugPrint('     Access: ${merchant.action}');
      }

      // Log raw JSON for debugging
      debugPrint('📋 Raw JSON response:');
      for (var json in merchantsJson) {
        debugPrint('   Raw: $json');
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
