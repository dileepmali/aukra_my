import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/customer_statement_model.dart';
import '../../models/ledger_model.dart';
import '../../models/transaction_list_model.dart';
import 'auth_storage.dart';
import 'global_api_function.dart';

/// API class for Customer Statement operations
/// This aggregates data from multiple APIs to create customer statement
class CustomerStatementApi {
  final ApiFetcher _apiFetcher = ApiFetcher();

  /// Fetch customer statement data
  /// This method combines:
  /// 1. Customer list from GET /api/ledger/{merchantId}?partyType=CUSTOMER
  /// 2. Transactions from GET /api/ledgerTransaction/{merchantId}
  /// 3. Calculates yesterday's IN/OUT totals
  Future<CustomerStatementModel> getCustomerStatement({
    required String partyType, // 'CUSTOMER', 'SUPPLIER', 'EMPLOYEE'
  }) async {
    try {
      debugPrint('📊 Fetching $partyType statement data...');

      // Get merchant ID from storage
      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) {
        throw Exception('Merchant ID not found in storage');
      }

      debugPrint('🏢 Merchant ID: $merchantId');

      // Step 1: Fetch customer/supplier/employee list
      debugPrint('📡 Step 1: Fetching $partyType list...');
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

      // Step 2: Fetch all transactions for the merchant
      debugPrint('📡 Step 2: Fetching all transactions...');
      final transactionFetcher = ApiFetcher();
      await transactionFetcher.request(
        url: 'api/ledgerTransaction/$merchantId',
        method: 'GET',
        requireAuth: true,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Transaction fetch timeout. Please try again.');
        },
      );

      if (transactionFetcher.errorMessage != null) {
        debugPrint('⚠️ Transaction fetch error: ${transactionFetcher.errorMessage}');
        // Continue without transactions if error occurs
      }

      // Parse transactions
      List<TransactionItemModel> allTransactions = [];
      if (transactionFetcher.data is Map &&
          transactionFetcher.data['data'] is List) {
        final dataList = transactionFetcher.data['data'] as List;
        allTransactions = dataList
            .map((json) =>
                TransactionItemModel.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('✅ Fetched ${allTransactions.length} transactions');
      }

      // Step 3: Calculate yesterday's IN/OUT totals
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStart = DateTime(yesterday.year, yesterday.month, yesterday.day);
      final yesterdayEnd = yesterdayStart.add(const Duration(days: 1));

      double yesterdayTotalIn = 0.0;
      double yesterdayTotalOut = 0.0;

      for (var transaction in allTransactions) {
        // Skip deleted transactions
        if (transaction.isDelete) continue;

        // Filter by party type
        if (transaction.partyType != partyType) continue;

        try {
          final transactionDate = DateTime.parse(transaction.transactionDate);
          if (transactionDate.isAfter(yesterdayStart) &&
              transactionDate.isBefore(yesterdayEnd)) {
            if (transaction.transactionType == 'IN') {
              yesterdayTotalIn += transaction.amount;
            } else if (transaction.transactionType == 'OUT') {
              yesterdayTotalOut += transaction.amount;
            }
          }
        } catch (e) {
          debugPrint('❌ Error parsing transaction date: $e');
        }
      }

      debugPrint('📅 Yesterday IN: ₹$yesterdayTotalIn | OUT: ₹$yesterdayTotalOut');

      // Step 4: Calculate net balance (sum of all customer balances)
      double netBalance = 0.0;
      for (var ledger in ledgerList) {
        netBalance += ledger.currentBalance;
      }

      debugPrint('💰 Total Net Balance: ₹$netBalance');

      // Step 5: Convert ledger list to customer statement items
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

      // Create statement model
      final statementModel = CustomerStatementModel(
        netBalance: netBalance,
        totalCustomers: ledgerList.length,
        yesterdayTotalIn: yesterdayTotalIn,
        yesterdayTotalOut: yesterdayTotalOut,
        customers: customers,
      );

      debugPrint('✅ Customer statement data prepared successfully');
      return statementModel;
    } catch (e) {
      debugPrint('❌ Error fetching customer statement: $e');
      rethrow;
    }
  }
}
