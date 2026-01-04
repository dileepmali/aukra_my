import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ledger_dashboard_model.dart';
import '../models/ledger_detail_model.dart';
import '../models/transaction_list_model.dart';
import '../core/api/ledger_detail_api.dart';
import '../core/api/ledger_transaction_api.dart';

class LedgerDashboardController extends GetxController {
  // Reactive variables
  final Rx<LedgerDashboardModel?> dashboardData = Rx<LedgerDashboardModel?>(null);
  final Rx<LedgerDetailModel?> ledgerDetail = Rx<LedgerDetailModel?>(null);
  final Rx<TransactionListModel?> transactions = Rx<TransactionListModel?>(null);
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // API instances
  final LedgerDetailApi _ledgerDetailApi = LedgerDetailApi();
  final LedgerTransactionApi _transactionApi = LedgerTransactionApi();

  // Arguments from navigation
  int? ledgerId;
  String? partyName;
  String? partyType;
  double? creditAmount;
  String? mobileNumber;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    fetchDashboard();
  }

  void _initializeData() {
    // Get arguments passed from previous screen
    final args = Get.arguments as Map<String, dynamic>?;
    ledgerId = args?['ledgerId'] as int?;
    partyName = args?['partyName'] as String? ?? 'Party';
    partyType = args?['partyType'] as String? ?? 'CUSTOMER';
    creditAmount = args?['creditAmount'] as double? ?? 0.0;
    mobileNumber = args?['mobileNumber'] as String?;

    debugPrint('📊 Ledger Dashboard Initialized');
    debugPrint('   - Ledger ID: $ledgerId');
    debugPrint('   - Party Name: $partyName');
    debugPrint('   - Party Type: $partyType');
  }

  /// Fetch dashboard data using ledger detail and transaction APIs
  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Check if ledger ID exists
      if (ledgerId == null || ledgerId! <= 0) {
        throw Exception('Invalid ledger ID. Cannot fetch dashboard data.');
      }

      debugPrint('📊 Fetching dashboard for ledger: $ledgerId');

      // Fetch ledger details and transactions in parallel
      final results = await Future.wait([
        _ledgerDetailApi.getLedgerDetails(ledgerId!),
        _transactionApi.getLedgerTransactions(ledgerId: ledgerId!),
      ]);

      ledgerDetail.value = results[0] as LedgerDetailModel;
      transactions.value = results[1] as TransactionListModel;

      // Calculate dashboard statistics from transactions
      _calculateDashboardStats();

      debugPrint('✅ Dashboard data loaded successfully');
    } catch (e) {
      debugPrint('❌ Dashboard Fetch Error: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate dashboard statistics from transaction data
  void _calculateDashboardStats() {
    if (transactions.value == null) {
      dashboardData.value = LedgerDashboardModel(
        todayIn: 0,
        todayOut: 0,
        overallGiven: 0,
        overallReceived: 0,
        party: PartyBreakdown(
          customer: PartyData(overallGiven: 0, overallReceived: 0),
          supplier: PartyData(overallGiven: 0, overallReceived: 0),
          employee: PartyData(overallGiven: 0, overallReceived: 0),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    double todayIn = 0;
    double todayOut = 0;
    double overallGiven = 0;
    double overallReceived = 0;

    // Calculate from transactions
    for (var transaction in transactions.value!.data) {
      // Skip deleted transactions
      if (transaction.isDelete) continue;

      final transactionDate = DateTime.parse(transaction.transactionDate);
      final isToday = DateTime(transactionDate.year, transactionDate.month, transactionDate.day) == today;

      if (transaction.transactionType == 'IN') {
        overallReceived += transaction.amount;
        if (isToday) todayIn += transaction.amount;
      } else {
        overallGiven += transaction.amount;
        if (isToday) todayOut += transaction.amount;
      }
    }

    // Create party breakdown based on current party type
    PartyData currentPartyData = PartyData(
      overallGiven: overallGiven,
      overallReceived: overallReceived,
    );

    PartyData emptyData = PartyData(overallGiven: 0, overallReceived: 0);

    dashboardData.value = LedgerDashboardModel(
      todayIn: todayIn,
      todayOut: todayOut,
      overallGiven: overallGiven,
      overallReceived: overallReceived,
      party: PartyBreakdown(
        customer: partyType?.toUpperCase() == 'CUSTOMER' ? currentPartyData : emptyData,
        supplier: partyType?.toUpperCase() == 'SUPPLIER' ? currentPartyData : emptyData,
        employee: partyType?.toUpperCase() == 'EMPLOYEE' ? currentPartyData : emptyData,
      ),
    );

    debugPrint('📊 Dashboard Stats:');
    debugPrint('   - Today IN: ₹$todayIn');
    debugPrint('   - Today OUT: ₹$todayOut');
    debugPrint('   - Overall Given: ₹$overallGiven');
    debugPrint('   - Overall Received: ₹$overallReceived');
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    await fetchDashboard();
  }

  /// Get formatted credit amount
  String getFormattedCredit() {
    return '₹${creditAmount?.toStringAsFixed(2) ?? '0.00'}';
  }

  /// Get party type display text
  String getPartyTypeDisplay() {
    switch (partyType?.toUpperCase()) {
      case 'CUSTOMER':
        return 'Customer';
      case 'SUPPLIER':
        return 'Supplier';
      case 'EMPLOYEE':
        return 'Employee';
      default:
        return 'Party';
    }
  }
}
