import 'package:flutter/material.dart';
import 'global_api_function.dart';
import '../../models/transaction_list_model.dart';
import '../../models/transaction_detail_model.dart';
import '../../models/grouped_transaction_model.dart';

class LedgerTransactionApi {
  final ApiFetcher _apiFetcher = ApiFetcher();

  /// Create a new ledger transaction
  ///
  /// Request body:
  /// {
  ///   "ledgerId": 7,
  ///   "merchantId": 1,
  ///   "transactionAmount": 600,
  ///   "transactionType": "IN" or "OUT",
  ///   "transactionDate": "2025-10-17T10:30:00.000Z",
  ///   "comments": "Payment received",
  ///   "partyMerchantAction": "VIEW",
  ///   "uploadedKeys": [1, 4],
  ///   "securityKey": "1234"
  /// }
  Future<LedgerTransactionResponse> createTransaction({
    required int ledgerId,
    required int merchantId,
    required double transactionAmount,
    required String transactionType, // "IN" or "OUT"
    required String transactionDate, // ISO format
    String? comments,
    String partyMerchantAction = "VIEW",
    List<int>? uploadedKeys,
    required String securityKey,
  }) async {
    try {
      final body = {
        "ledgerId": ledgerId,
        "merchantId": merchantId,
        "transactionAmount": transactionAmount,
        "transactionType": transactionType,
        "transactionDate": transactionDate,
        "comments": comments ?? "", // Always send as string (empty or with value)
        "partyMerchantAction": partyMerchantAction,
        if (uploadedKeys != null && uploadedKeys.isNotEmpty)
          "uploadedKeys": uploadedKeys,
        "securityKey": securityKey,
      };

      debugPrint('📤 Creating ledger transaction: $body');

      await _apiFetcher.request(
        url: 'api/ledgerTransaction',
        method: 'POST',
        body: body,
        requireAuth: true,
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        // Parse error response
        if (_apiFetcher.data is Map) {
          final errorResponse = LedgerTransactionErrorResponse.fromJson(
            _apiFetcher.data as Map<String, dynamic>,
          );
          throw Exception(errorResponse.getErrorMessages());
        }
        throw Exception(_apiFetcher.errorMessage);
      }

      // Parse success response
      if (_apiFetcher.data is Map) {
        return LedgerTransactionResponse.fromJson(
          _apiFetcher.data as Map<String, dynamic>,
        );
      }

      // Default success message
      return LedgerTransactionResponse(message: 'Created successfully');
    } catch (e) {
      debugPrint('❌ Ledger Transaction API Error: $e');
      rethrow;
    }
  }

  /// Get all transactions for a specific ledger with pagination
  ///
  /// Endpoint: GET api/ledger/{ledgerId}/transaction?skip=0&limit=10
  /// Returns individual transactions for a specific ledger
  Future<TransactionListModel> getLedgerTransactions({
    required int ledgerId,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      debugPrint('📥 Fetching transactions for ledger: $ledgerId (skip: $skip, limit: $limit)');

      await _apiFetcher.request(
        url: 'api/ledger/$ledgerId/transaction?skip=$skip&limit=$limit',
        method: 'GET',
        requireAuth: true,
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        throw Exception(_apiFetcher.errorMessage);
      }

      // Parse success response
      if (_apiFetcher.data is Map) {
        final transactionList = TransactionListModel.fromJson(
          _apiFetcher.data as Map<String, dynamic>,
        );
        debugPrint('✅ Fetched ${transactionList.data.length} transactions (total: ${transactionList.totalCount}) for ledger $ledgerId');
        return transactionList;
      }

      // Return empty list if no data
      return TransactionListModel(count: 0, totalCount: 0, data: []);
    } catch (e) {
      debugPrint('❌ Fetch Ledger Transactions API Error: $e');
      rethrow;
    }
  }

  /// Get all transactions for a merchant (ALL ledgers)
  ///
  /// Endpoint: GET api/ledgerTransaction/{merchantId}
  /// NOTE: This returns transactions from ALL ledgers of the merchant
  /// Use getLedgerTransactions() for specific ledger transactions
  Future<TransactionListModel> getMerchantTransactions({
    required int merchantId,
  }) async {
    try {
      debugPrint('📥 Fetching ALL transactions for merchant: $merchantId');

      await _apiFetcher.request(
        url: 'api/ledgerTransaction/$merchantId',
        method: 'GET',
        requireAuth: true,
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        throw Exception(_apiFetcher.errorMessage);
      }

      // Parse success response
      if (_apiFetcher.data is Map) {
        final transactionList = TransactionListModel.fromJson(
          _apiFetcher.data as Map<String, dynamic>,
        );
        debugPrint('✅ Fetched ${transactionList.count} transactions for merchant $merchantId');
        return transactionList;
      }

      // Return empty list if no data
      return TransactionListModel(count: 0, totalCount: 0, data: []);
    } catch (e) {
      debugPrint('❌ Fetch Merchant Transactions API Error: $e');
      rethrow;
    }
  }

  /// Get transaction details by ID
  ///
  /// Endpoint: GET api/ledgerTransaction/details/{transactionId}
  /// Returns detailed transaction info including history and attachments
  Future<TransactionDetailModel> getTransactionDetails({
    required int transactionId,
  }) async {
    try {
      debugPrint('📥 Fetching transaction details for ID: $transactionId');

      await _apiFetcher.request(
        url: 'api/ledgerTransaction/details/$transactionId',
        method: 'GET',
        requireAuth: true,
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        throw Exception(_apiFetcher.errorMessage);
      }

      // Parse success response
      if (_apiFetcher.data is Map) {
        final transactionDetail = TransactionDetailModel.fromJson(
          _apiFetcher.data as Map<String, dynamic>,
        );
        debugPrint('✅ Fetched transaction details for ID: $transactionId');
        debugPrint('   - Amount: ${transactionDetail.amount}');
        debugPrint('   - Type: ${transactionDetail.transactionType}');
        debugPrint('   - History count: ${transactionDetail.historyCount}');
        debugPrint('   - Attachments: ${transactionDetail.attachmentCount}');
        return transactionDetail;
      }

      throw Exception('Invalid response format');
    } catch (e) {
      debugPrint('❌ Fetch Transaction Details API Error: $e');
      rethrow;
    }
  }

  /// Get transactions grouped by date for a specific ledger
  ///
  /// Endpoint: GET api/ledger/{ledgerId}/transaction/groupByDate
  /// Query params: startDate, endDate (format: YYYY-MM-DD)
  ///
  /// Returns daily grouped transactions with IN, OUT, and balance
  Future<GroupedTransactionModel> getGroupedTransactionsByDate({
    required int ledgerId,
    required String startDate, // Format: YYYY-MM-DD
    required String endDate, // Format: YYYY-MM-DD
  }) async {
    try {
      debugPrint('📥 Fetching grouped transactions for ledger: $ledgerId');
      debugPrint('   Date range: $startDate to $endDate');

      await _apiFetcher.request(
        url: 'api/ledger/$ledgerId/transaction/groupByDate?startDate=$startDate&endDate=$endDate',
        method: 'GET',
        requireAuth: true,
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        throw Exception(_apiFetcher.errorMessage);
      }

      // Parse success response
      if (_apiFetcher.data is Map) {
        final groupedData = GroupedTransactionModel.fromJson(
          _apiFetcher.data as Map<String, dynamic>,
        );
        debugPrint('✅ Fetched ${groupedData.data.length} grouped transactions for ledger $ledgerId');
        return groupedData;
      }

      // Return empty model if no data
      return GroupedTransactionModel(startDate: startDate, endDate: endDate, data: []);
    } catch (e) {
      debugPrint('❌ Fetch Grouped Transactions API Error: $e');
      rethrow;
    }
  }

  /// Get loading state
  bool get isLoading => _apiFetcher.isLoading;

  /// Get error message
  String? get errorMessage => _apiFetcher.errorMessage;

  /// Get raw data
  dynamic get data => _apiFetcher.data;

  /// Update an existing ledger transaction
  ///
  /// Endpoint: PUT api/ledgerTransaction/{transactionId}
  ///
  /// NOTE: Backend does NOT allow changing transactionType during update.
  /// To change IN/OUT, user must delete and recreate the transaction.
  ///
  /// Request body:
  /// {
  ///   "transactionAmount": 600,
  ///   "transactionDate": "2025-10-17T10:30:00.000Z",
  ///   "comments": "Payment received for invoice #1234",
  ///   "uploadedKeys": [1, 4],
  ///   "securityKey": "1234"
  /// }
  Future<LedgerTransactionResponse> updateTransaction({
    required int transactionId,
    required double transactionAmount,
    required String transactionDate, // ISO format
    String? comments,
    List<int>? uploadedKeys,
    required String securityKey,
  }) async {
    try {
      final body = {
        "transactionAmount": transactionAmount,
        "transactionDate": transactionDate,
        "comments": comments ?? "", // Always send as string (empty or with value)
        if (uploadedKeys != null && uploadedKeys.isNotEmpty)
          "uploadedKeys": uploadedKeys,
        "securityKey": securityKey,
      };

      debugPrint('📤 Updating transaction $transactionId: $body');

      await _apiFetcher.request(
        url: 'api/ledgerTransaction/$transactionId',
        method: 'PUT',
        body: body,
        requireAuth: true,
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        // Parse error response
        if (_apiFetcher.data is Map) {
          final errorResponse = LedgerTransactionErrorResponse.fromJson(
            _apiFetcher.data as Map<String, dynamic>,
          );
          throw Exception(errorResponse.getErrorMessages());
        }
        throw Exception(_apiFetcher.errorMessage);
      }

      // Parse success response
      if (_apiFetcher.data is Map) {
        return LedgerTransactionResponse.fromJson(
          _apiFetcher.data as Map<String, dynamic>,
        );
      }

      // Default success message
      return LedgerTransactionResponse(message: 'Transaction updated successfully');
    } catch (e) {
      debugPrint('❌ Update Transaction API Error: $e');
      rethrow;
    }
  }

  /// Delete an existing ledger transaction
  ///
  /// Endpoint: DELETE api/ledgerTransaction/{transactionId}
  ///
  /// Request body:
  /// {
  ///   "securityKey": "1234"
  /// }
  Future<LedgerTransactionResponse> deleteTransaction({
    required int transactionId,
    required String securityKey,
  }) async {
    try {
      final body = {
        "securityKey": securityKey,
      };

      debugPrint('📤 Deleting transaction $transactionId');

      await _apiFetcher.request(
        url: 'api/ledgerTransaction/$transactionId',
        method: 'DELETE',
        body: body,
        requireAuth: true,
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        // Parse error response
        if (_apiFetcher.data is Map) {
          final errorResponse = LedgerTransactionErrorResponse.fromJson(
            _apiFetcher.data as Map<String, dynamic>,
          );
          throw Exception(errorResponse.getErrorMessages());
        }
        throw Exception(_apiFetcher.errorMessage);
      }

      // Parse success response
      if (_apiFetcher.data is Map) {
        return LedgerTransactionResponse.fromJson(
          _apiFetcher.data as Map<String, dynamic>,
        );
      }

      // Default success message
      return LedgerTransactionResponse(message: 'Transaction deleted successfully');
    } catch (e) {
      debugPrint('❌ Delete Transaction API Error: $e');
      rethrow;
    }
  }
}

// Success Response Model
class LedgerTransactionResponse {
  final String message;

  LedgerTransactionResponse({required this.message});

  factory LedgerTransactionResponse.fromJson(Map<String, dynamic> json) {
    return LedgerTransactionResponse(
      message: json['message'] ?? 'Created successfully',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

// Error Response Model
class LedgerTransactionErrorResponse {
  final int? statusCode;
  final String? message;
  final List<FieldError>? errors;

  LedgerTransactionErrorResponse({
    this.statusCode,
    this.message,
    this.errors,
  });

  factory LedgerTransactionErrorResponse.fromJson(Map<String, dynamic> json) {
    return LedgerTransactionErrorResponse(
      statusCode: json['statusCode'],
      message: json['message'],
      errors: json['errors'] != null
          ? (json['errors'] as List)
              .map((e) => FieldError.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  String getErrorMessages() {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.map((e) => '${e.field}: ${e.error}').join('\n');
    }
    return message ?? 'Unknown error occurred';
  }
}

class FieldError {
  final String field;
  final String error;

  FieldError({required this.field, required this.error});

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field'] ?? '',
      error: json['error'] ?? '',
    );
  }
}
