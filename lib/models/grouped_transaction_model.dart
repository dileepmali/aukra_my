/// Model for grouped transaction API response
/// Endpoint: GET /api/ledger/{ledgerId}/transction/groupByDate
///
/// Response format:
/// {
///   "startDate": "1 Nov 2025",
///   "endDate": "12 Nov 2025",
///   "data": [
///     {
///       "date": "2025-11-10",
///       "in": 1000,
///       "out": 0,
///       "balance": -3300,
///       "balanceType": "IN"
///     }
///   ]
/// }

class GroupedTransactionModel {
  final String startDate;
  final String endDate;
  final List<DailyGroupedTransaction> data;

  GroupedTransactionModel({
    required this.startDate,
    required this.endDate,
    required this.data,
  });

  factory GroupedTransactionModel.fromJson(Map<String, dynamic> json) {
    return GroupedTransactionModel(
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => DailyGroupedTransaction.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class DailyGroupedTransaction {
  final String date; // "2025-11-10"
  final double inAmount; // "in" from API
  final double outAmount; // "out" from API
  final double balance;
  final String balanceType; // "IN" or "OUT"

  DailyGroupedTransaction({
    required this.date,
    required this.inAmount,
    required this.outAmount,
    required this.balance,
    required this.balanceType,
  });

  factory DailyGroupedTransaction.fromJson(Map<String, dynamic> json) {
    return DailyGroupedTransaction(
      date: json['date'] ?? '',
      inAmount: (json['in'] ?? 0).toDouble(),
      outAmount: (json['out'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      balanceType: json['balanceType'] ?? 'IN',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'in': inAmount,
      'out': outAmount,
      'balance': balance,
      'balanceType': balanceType,
    };
  }

  /// Get formatted date (dd/MM/yyyy)
  String get formattedDate {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return date;
    } catch (e) {
      return date;
    }
  }
}