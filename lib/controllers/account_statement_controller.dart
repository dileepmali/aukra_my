import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/transaction_list_model.dart';

/// Controller for Account Statement Logic
class AccountStatementController extends GetxController {
  // Selected month (observable)
  final selectedMonth = Rx<DateTime>(DateTime(DateTime.now().year, DateTime.now().month, 1));

  // All transactions list (passed from parent)
  final allTransactions = <TransactionItemModel>[].obs;

  // Filtered transactions for selected month
  final monthTransactions = <TransactionItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to selectedMonth changes and update filtered list
    ever(selectedMonth, (_) => _filterTransactions());
  }

  /// Set all transactions from parent
  void setTransactions(List<TransactionItemModel> transactions) {
    allTransactions.value = transactions;
    _filterTransactions();
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

  /// Filter transactions by selected month
  void _filterTransactions() {
    final firstDay = selectedMonth.value;
    final lastDay = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
      0,
      23,
      59,
      59,
    );

    debugPrint('📊 Filtering transactions for month: ${getMonthRangeText()}');
    debugPrint('   Total transactions: ${allTransactions.length}');

    // Filter by month and exclude deleted
    final filtered = allTransactions.where((transaction) {
      if (transaction.isDelete) return false;

      try {
        final transactionDate = DateTime.parse(transaction.transactionDate);
        final isInRange = transactionDate.isAfter(firstDay.subtract(Duration(seconds: 1))) &&
                         transactionDate.isBefore(lastDay.add(Duration(seconds: 1)));
        return isInRange;
      } catch (e) {
        debugPrint('❌ Error parsing date: ${transaction.transactionDate}');
        return false;
      }
    }).toList();

    // Sort by date (oldest first)
    filtered.sort((a, b) {
      try {
        return DateTime.parse(a.transactionDate)
            .compareTo(DateTime.parse(b.transactionDate));
      } catch (e) {
        return 0;
      }
    });

    monthTransactions.value = filtered;
    debugPrint('   Filtered transactions: ${monthTransactions.length}');
  }

  /// Format date for display (dd/MM/yyyy)
  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString.substring(0, 10);
    }
  }

  /// Get IN amount for transaction (returns 0 if OUT)
  double getInAmount(TransactionItemModel transaction) {
    return transaction.transactionType == 'IN' ? transaction.amount : 0.0;
  }

  /// Get OUT amount for transaction (returns 0 if IN)
  double getOutAmount(TransactionItemModel transaction) {
    return transaction.transactionType == 'OUT' ? transaction.amount : 0.0;
  }

  /// Check if transaction is IN type
  bool isInTransaction(TransactionItemModel transaction) {
    return transaction.transactionType == 'IN';
  }

  /// Get balance for transaction
  double getBalance(TransactionItemModel transaction) {
    return transaction.lastBalance;
  }
}
