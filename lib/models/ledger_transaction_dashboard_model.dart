/// Ledger Transaction Dashboard Model
/// Response from GET /api/ledgerTransaction/{merchantId}/dashboard
///
/// Example response:
/// {
///   "count": 8,
///   "totalCount": 8,
///   "data": [
///     {
///       "ledgerId": 52,
///       "partyName": "Bhotik Pg",
///       "partyType": "CUSTOMER",
///       "mobileNumber": "9328225291",
///       "transactionId": 191,
///       "amount": 99999999,
///       "lastBalance": -254679,
///       "isDelete": false,
///       "currentBalance": 99745320,
///       "description": "bzbzbwbvw s",
///       "transactionDate": "2026-01-26T16:47:31.046Z",
///       "updatedAt": "2026-01-26T16:47:38.979Z",
///       "transactionType": "OUT",
///       "balanceType": "OUT",
///       "row_num": "1"
///     }
///   ]
/// }
class LedgerTransactionDashboardModel {
  final int count;
  final int totalCount;
  final List<LedgerTransactionItem> data;

  LedgerTransactionDashboardModel({
    required this.count,
    required this.totalCount,
    required this.data,
  });

  factory LedgerTransactionDashboardModel.fromJson(Map<String, dynamic> json) {
    return LedgerTransactionDashboardModel(
      count: _parseInt(json['count']),
      totalCount: _parseInt(json['totalCount']),
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => LedgerTransactionItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'totalCount': totalCount,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

/// Individual ledger transaction item
class LedgerTransactionItem {
  final int ledgerId;
  final String partyName;
  final String partyType;
  final String? mobileNumber;
  final int transactionId;
  final double amount;
  final double lastBalance;
  final bool isDelete;
  final double currentBalance;
  final String? description;
  final DateTime transactionDate;
  final DateTime updatedAt;
  final String transactionType; // 'IN' or 'OUT'
  final String balanceType; // 'IN' or 'OUT'
  final int rowNum;

  LedgerTransactionItem({
    required this.ledgerId,
    required this.partyName,
    required this.partyType,
    this.mobileNumber,
    required this.transactionId,
    required this.amount,
    required this.lastBalance,
    required this.isDelete,
    required this.currentBalance,
    this.description,
    required this.transactionDate,
    required this.updatedAt,
    required this.transactionType,
    required this.balanceType,
    required this.rowNum,
  });

  factory LedgerTransactionItem.fromJson(Map<String, dynamic> json) {
    return LedgerTransactionItem(
      ledgerId: _parseInt(json['ledgerId']),
      partyName: (json['partyName'] as String?) ?? '',
      partyType: (json['partyType'] as String?) ?? 'CUSTOMER',
      mobileNumber: json['mobileNumber'] as String?,
      transactionId: _parseInt(json['transactionId']),
      amount: _parseDouble(json['amount']),
      lastBalance: _parseDouble(json['lastBalance']),
      isDelete: (json['isDelete'] as bool?) ?? false,
      currentBalance: _parseDouble(json['currentBalance']),
      description: json['description'] as String?,
      transactionDate: _parseDateTime(json['transactionDate']),
      updatedAt: _parseDateTime(json['updatedAt']),
      transactionType: (json['transactionType'] as String?) ?? 'OUT',
      balanceType: (json['balanceType'] as String?) ?? 'OUT',
      rowNum: _parseInt(json['row_num']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ledgerId': ledgerId,
      'partyName': partyName,
      'partyType': partyType,
      'mobileNumber': mobileNumber,
      'transactionId': transactionId,
      'amount': amount,
      'lastBalance': lastBalance,
      'isDelete': isDelete,
      'currentBalance': currentBalance,
      'description': description,
      'transactionDate': transactionDate.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'transactionType': transactionType,
      'balanceType': balanceType,
      'row_num': rowNum,
    };
  }

  /// Check if transaction is IN type (money received)
  bool get isInTransaction => transactionType == 'IN';

  /// Check if balance is positive (IN type)
  bool get isPositiveBalance => balanceType == 'IN';

  /// Get signed balance (positive for IN, negative for OUT)
  double get signedBalance {
    return balanceType == 'IN' ? currentBalance.abs() : -currentBalance.abs();
  }

  /// Get signed amount (positive for IN, negative for OUT)
  double get signedAmount {
    return transactionType == 'IN' ? amount.abs() : -amount.abs();
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}