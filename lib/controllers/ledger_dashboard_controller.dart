import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ledger_dashboard_model.dart';
import '../models/ledger_dashboard_summary_model.dart';
import '../models/ledger_monthly_dashboard_model.dart';
import '../models/ledger_detail_model.dart';
import '../models/transaction_list_model.dart';
import '../core/api/ledger_detail_api.dart';
import '../core/api/ledger_transaction_api.dart';
import '../core/database/repositories/ledger_repository.dart';
import '../core/database/repositories/transaction_repository.dart';
import '../core/services/connectivity_service.dart';

class LedgerDashboardController extends GetxController {
  // 🗄️ Offline-first repositories
  LedgerRepository? _ledgerRepository;
  LedgerRepository get ledgerRepository {
    if (_ledgerRepository == null) {
      if (Get.isRegistered<LedgerRepository>()) {
        _ledgerRepository = Get.find<LedgerRepository>();
      } else {
        _ledgerRepository = LedgerRepository();
      }
    }
    return _ledgerRepository!;
  }

  TransactionRepository? _transactionRepository;
  TransactionRepository get transactionRepository {
    if (_transactionRepository == null) {
      if (Get.isRegistered<TransactionRepository>()) {
        _transactionRepository = Get.find<TransactionRepository>();
      } else {
        _transactionRepository = TransactionRepository();
      }
    }
    return _transactionRepository!;
  }
  // Reactive variables
  final Rx<LedgerDashboardModel?> dashboardData = Rx<LedgerDashboardModel?>(null);
  final Rx<LedgerDetailModel?> ledgerDetail = Rx<LedgerDetailModel?>(null);
  final Rx<TransactionListModel?> transactions = Rx<TransactionListModel?>(null);
  final Rx<LedgerMonthlyDashboardModel?> monthlyDashboard = Rx<LedgerMonthlyDashboardModel?>(null);
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

  /// Fetch dashboard data using ledger detail, transactions, and dashboard summary APIs
  /// 🗄️ OFFLINE-FIRST: Try cached data first, then API
  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Check if ledger ID exists
      if (ledgerId == null || ledgerId! <= 0) {
        throw Exception('Invalid ledger ID. Cannot fetch dashboard data.');
      }

      debugPrint('📊 Fetching dashboard for ledger: $ledgerId (OFFLINE-FIRST)');

      // Check connectivity
      final isOnline = Get.isRegistered<ConnectivityService>()
          ? ConnectivityService.instance.isConnected.value
          : true;

      debugPrint('🌐 Is Online: $isOnline');

      // 🗄️ OFFLINE-FIRST: Try to load cached transactions first
      try {
        final cachedTransactions = await transactionRepository.getTransactionsByLedger(ledgerId!);
        if (cachedTransactions.isNotEmpty) {
          debugPrint('📦 Loaded ${cachedTransactions.length} cached transactions');
          transactions.value = TransactionListModel(
            count: cachedTransactions.length,
            totalCount: cachedTransactions.length,
            data: cachedTransactions,
          );
          // Calculate dashboard stats from cached data
          _calculateDashboardStats();
        }
      } catch (e) {
        debugPrint('⚠️ Could not load cached transactions: $e');
      }

      // 🗄️ Try to load cached ledger detail
      try {
        final cachedLedger = await ledgerRepository.getLedgerById(ledgerId!);
        if (cachedLedger != null) {
          debugPrint('📦 Loaded cached ledger: ${cachedLedger.name}');
          ledgerDetail.value = LedgerDetailModel(
            id: cachedLedger.id ?? 0,
            merchantId: cachedLedger.merchantId,
            partyName: cachedLedger.name,
            partyType: cachedLedger.partyType,
            mobileNumber: cachedLedger.mobileNumber,
            currentBalance: cachedLedger.currentBalance,
            openingBalance: cachedLedger.openingBalance,
            area: cachedLedger.area,
            address: cachedLedger.address,
            pinCode: cachedLedger.pinCode,
            creditLimit: cachedLedger.creditLimit,
            creditDay: cachedLedger.creditDay,
            interestType: cachedLedger.interestType,
            interestRate: cachedLedger.interestRate,
            transactionType: cachedLedger.transactionType,
            isDelete: false,
            salary: 0.0,
            salaryType: 'MONTHLY',
            createdAt: cachedLedger.createdAt ?? DateTime.now(),
            updatedAt: cachedLedger.updatedAt ?? DateTime.now(),
          );
        }
      } catch (e) {
        debugPrint('⚠️ Could not load cached ledger detail: $e');
      }

      // If online, fetch fresh data from API
      if (isOnline) {
        debugPrint('🔄 Online - Fetching fresh data from API...');
        try {
          // Fetch ledger details, transactions, and dashboard summary in parallel
          final results = await Future.wait([
            _ledgerDetailApi.getLedgerDetails(ledgerId!),
            _transactionApi.getLedgerTransactions(ledgerId: ledgerId!),
            _ledgerDetailApi.getDashboardSummary(ledgerId!),
          ]);

          ledgerDetail.value = results[0] as LedgerDetailModel;
          transactions.value = results[1] as TransactionListModel;
          final summaryData = results[2] as LedgerDashboardSummaryModel;

          // Use API data for dashboard statistics
          _setDashboardStatsFromApi(summaryData);

          // Fetch monthly dashboard separately to ensure it runs
          debugPrint('📅 Starting monthly dashboard fetch...');
          try {
            monthlyDashboard.value = await _ledgerDetailApi.getMonthlyDashboard(ledgerId!);
            debugPrint('📅 Monthly Dashboard loaded: IN=₹${monthlyDashboard.value?.totalIn}, OUT=₹${monthlyDashboard.value?.totalOut}');
          } catch (monthlyError) {
            debugPrint('📅 Monthly Dashboard Error: $monthlyError');
          }

          debugPrint('✅ Dashboard data loaded from API successfully');
        } catch (apiError) {
          debugPrint('⚠️ API fetch failed: $apiError');
          // If API fails but we have cached data, use that
          if (transactions.value != null && transactions.value!.data.isNotEmpty) {
            debugPrint('📦 Using cached data as fallback');
            _calculateDashboardStats();
          } else {
            rethrow;
          }
        }
      } else {
        debugPrint('📴 Offline - Using cached data');
        // If offline and we have cached data, calculate stats from it
        if (transactions.value != null && transactions.value!.data.isNotEmpty) {
          _calculateDashboardStats();
          debugPrint('✅ Dashboard stats calculated from cached data');
        } else {
          errorMessage.value = 'No cached data available. Please connect to internet.';
        }
      }
    } catch (e) {
      debugPrint('❌ Dashboard Fetch Error: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Set dashboard statistics from API response
  /// Note: UI mapping:
  ///   - "You will receive" uses dashboard.overallGiven
  ///   - "You will give" uses dashboard.overallReceived
  void _setDashboardStatsFromApi(LedgerDashboardSummaryModel summary) {
    // Create party breakdown based on current party type
    // Mapping to match UI expectations
    PartyData currentPartyData = PartyData(
      overallGiven: summary.overall.totalIn,     // "You will receive"
      overallReceived: summary.overall.totalOut, // "You will give"
    );

    PartyData emptyData = PartyData(overallGiven: 0, overallReceived: 0);

    dashboardData.value = LedgerDashboardModel(
      todayIn: summary.today.totalIn,
      todayOut: summary.today.totalOut,
      overallGiven: summary.overall.totalIn,     // "You will receive" in UI
      overallReceived: summary.overall.totalOut, // "You will give" in UI
      party: PartyBreakdown(
        customer: partyType?.toUpperCase() == 'CUSTOMER' ? currentPartyData : emptyData,
        supplier: partyType?.toUpperCase() == 'SUPPLIER' ? currentPartyData : emptyData,
        employee: partyType?.toUpperCase() == 'EMPLOYEE' ? currentPartyData : emptyData,
      ),
    );

    debugPrint('📊 Dashboard Stats (from API):');
    debugPrint('   - Today IN: ₹${summary.today.totalIn}');
    debugPrint('   - Today OUT: ₹${summary.today.totalOut}');
    debugPrint('   - You will receive (totalIn): ₹${summary.overall.totalIn}');
    debugPrint('   - You will give (totalOut): ₹${summary.overall.totalOut}');
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
