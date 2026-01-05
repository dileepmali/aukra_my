import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/transaction_list_model.dart';

/// Grouped daily transaction data
class DailyTransactionGroup {
  final String date; // Date string (dd/MM/yyyy)
  final double totalIn; // Sum of all IN transactions
  final double totalOut; // Sum of all OUT transactions
  final double finalBalance; // Final balance at end of day

  DailyTransactionGroup({
    required this.date,
    required this.totalIn,
    required this.totalOut,
    required this.finalBalance,
  });
}

/// Controller for Account Statement Logic
class AccountStatementController extends GetxController {
  // Selected month (observable)
  final selectedMonth = Rx<DateTime>(DateTime(DateTime.now().year, DateTime.now().month, 1));

  // All transactions list (passed from parent)
  final allTransactions = <TransactionItemModel>[].obs;

  // Grouped daily transactions for selected month
  final groupedDailyTransactions = <DailyTransactionGroup>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to selectedMonth changes and update filtered list
    ever(selectedMonth, (_) => _filterTransactions());
  }

  /// Set all transactions from parent
  void setTransactions(List<TransactionItemModel> transactions) {
    debugPrint('🔄 Setting ${transactions.length} transactions to AccountStatementController');

    // Debug: Print ALL transaction details
    debugPrint('   📋 All Transactions Details:');
    for (var i = 0; i < transactions.length; i++) {
      final t = transactions[i];
      debugPrint('      ${i + 1}. Date: ${formatDate(t.transactionDate)} | Type: ${t.transactionType} | Amount: ₹${t.amount} | Deleted: ${t.isDelete}');
    }

    // Debug: Print unique dates in transactions
    final uniqueDates = transactions
        .map((t) => formatDate(t.transactionDate))
        .toSet()
        .toList()
      ..sort();
    debugPrint('   Unique dates in all transactions: $uniqueDates');

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

  /// Filter transactions by selected month and group by date
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
    debugPrint('   Total transactions in allTransactions: ${allTransactions.length}');

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

    debugPrint('   Filtered transactions (in selected month): ${filtered.length}');

    // Sort by date (oldest first)
    filtered.sort((a, b) {
      try {
        return DateTime.parse(a.transactionDate)
            .compareTo(DateTime.parse(b.transactionDate));
      } catch (e) {
        return 0;
      }
    });

    // Group transactions by date
    final Map<String, List<TransactionItemModel>> groupedByDate = {};

    for (var transaction in filtered) {
      final dateKey = formatDate(transaction.transactionDate);
      if (!groupedByDate.containsKey(dateKey)) {
        groupedByDate[dateKey] = [];
      }
      groupedByDate[dateKey]!.add(transaction);
    }

    // Create daily transaction groups
    final dailyGroups = <DailyTransactionGroup>[];

    groupedByDate.forEach((date, transactions) {
      double totalIn = 0.0;
      double totalOut = 0.0;
      double finalBalance = 0.0;

      // Sort transactions within the day by time to get the correct final balance
      final sortedTransactions = transactions.toList();
      sortedTransactions.sort((a, b) {
        try {
          return DateTime.parse(a.transactionDate)
              .compareTo(DateTime.parse(b.transactionDate));
        } catch (e) {
          return 0;
        }
      });

      for (var transaction in sortedTransactions) {
        if (transaction.transactionType == 'IN') {
          totalIn += transaction.amount;
        } else if (transaction.transactionType == 'OUT') {
          totalOut += transaction.amount;
        }
        // Update balance with each transaction (last one will be the final balance)
        finalBalance = transaction.lastBalance;
      }

      debugPrint('📅 Date: $date | IN: ₹$totalIn | OUT: ₹$totalOut | Balance: ₹$finalBalance');

      dailyGroups.add(DailyTransactionGroup(
        date: date,
        totalIn: totalIn,
        totalOut: totalOut,
        finalBalance: finalBalance,
      ));
    });

    groupedDailyTransactions.value = dailyGroups;
    debugPrint('   Grouped into ${dailyGroups.length} daily entries');
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
}
