import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../core/api/ledger_transaction_api.dart';
import '../models/grouped_transaction_model.dart';

/// Controller for Account Statement Logic
/// Now uses API to fetch grouped transactions instead of local processing
class AccountStatementController extends GetxController {
  // API instance
  final LedgerTransactionApi _api = LedgerTransactionApi();

  // Ledger ID (set from parent)
  int? _ledgerId;

  // Selected month (observable)
  final selectedMonth = Rx<DateTime>(DateTime(DateTime.now().year, DateTime.now().month, 1));

  // Grouped transactions from API
  final groupedTransactions = Rx<GroupedTransactionModel?>(null);

  // Loading state
  final isLoading = false.obs;

  // Error message
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to selectedMonth changes and fetch data
    ever(selectedMonth, (_) => _fetchGroupedTransactions());
  }

  /// Set ledger ID and fetch initial data
  /// Only fetches if ledgerId is different from current
  void setLedgerId(int ledgerId) {
    if (_ledgerId == ledgerId) {
      return; // Already set, no need to fetch again
    }
    debugPrint('📊 AccountStatementController: Setting ledgerId: $ledgerId');
    _ledgerId = ledgerId;
    _fetchGroupedTransactions();
  }

  /// Go to previous month
  void previousMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month - 1,
      1,
    );
    debugPrint('📅 Previous Month: ${getMonthRangeText()}');
  }

  /// Go to next month
  void nextMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
      1,
    );
    debugPrint('📅 Next Month: ${getMonthRangeText()}');
  }

  /// Get month range display text
  String getMonthRangeText() {
    final firstDay = selectedMonth.value;
    final lastDay = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
      0,
    );

    return '${firstDay.day} ${DateFormat('MMM yyyy').format(firstDay)} - ${lastDay.day} ${DateFormat('MMM yyyy').format(lastDay)}';
  }

  /// Fetch grouped transactions from API
  Future<void> _fetchGroupedTransactions() async {
    if (_ledgerId == null) {
      debugPrint('⚠️ AccountStatementController: ledgerId not set');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Calculate date range for selected month
      final firstDay = selectedMonth.value;
      final lastDay = DateTime(
        selectedMonth.value.year,
        selectedMonth.value.month + 1,
        0,
      );

      // Format dates as YYYY-MM-DD
      final startDate = DateFormat('yyyy-MM-dd').format(firstDay);
      final endDate = DateFormat('yyyy-MM-dd').format(lastDay);

      debugPrint('📊 Fetching grouped transactions for ledger: $_ledgerId');
      debugPrint('   Date range: $startDate to $endDate');

      final response = await _api.getGroupedTransactionsByDate(
        ledgerId: _ledgerId!,
        startDate: startDate,
        endDate: endDate,
      );

      groupedTransactions.value = response;
      debugPrint('✅ Fetched ${response.data.length} grouped transactions');

    } catch (e) {
      debugPrint('❌ Error fetching grouped transactions: $e');
      errorMessage.value = e.toString();
      groupedTransactions.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await _fetchGroupedTransactions();
  }

  /// Get daily grouped transactions list (for widget compatibility)
  List<DailyGroupedTransaction> get groupedDailyTransactions {
    return groupedTransactions.value?.data ?? [];
  }
}