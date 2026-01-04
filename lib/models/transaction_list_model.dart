/// Transaction List Response Model
class TransactionListModel {
  final int count;
  final List<TransactionItemModel> data;

  TransactionListModel({
    required this.count,
    required this.data,
  });

  factory TransactionListModel.fromJson(Map<String, dynamic> json) {
    return TransactionListModel(
      count: json['count'] ?? 0,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => TransactionItemModel.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

/// Individual Transaction Item Model
class TransactionItemModel {
  final int id;
  final double amount;
  final double lastBalance;
  final double currentBalance;
  final String? description;
  final bool isDelete;
  final String transactionDate;
  final String updatedAt;
  final String transactionType; // "IN" or "OUT"
  final int ledgerId;
  final String partyName;
  final String partyType; // "CUSTOMER", "SUPPLIER", "EMPLOYEE"
  final String balanceType; // "IN" or "OUT"

  TransactionItemModel({
    required this.id,
    required this.amount,
    required this.lastBalance,
    required this.currentBalance,
    this.description,
    required this.isDelete,
    required this.transactionDate,
    required this.updatedAt,
    required this.transactionType,
    required this.ledgerId,
    required this.partyName,
    required this.partyType,
    required this.balanceType,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: json['id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      lastBalance: (json['lastBalance'] ?? 0).toDouble(),
      currentBalance: (json['currentBalance'] ?? 0).toDouble(),
      description: json['description'],
      isDelete: json['isDelete'] ?? false,
      transactionDate: json['transactionDate'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      transactionType: json['transactionType'] ?? 'OUT',
      ledgerId: json['ledgerId'] ?? 0,
      partyName: json['partyName'] ?? '',
      partyType: json['partyType'] ?? 'CUSTOMER',
      balanceType: json['balanceType'] ?? 'OUT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'lastBalance': lastBalance,
      'currentBalance': currentBalance,
      'description': description,
      'isDelete': isDelete,
      'transactionDate': transactionDate,
      'updatedAt': updatedAt,
      'transactionType': transactionType,
      'ledgerId': ledgerId,
      'partyName': partyName,
      'partyType': partyType,
      'balanceType': balanceType,
    };
  }

  /// Get formatted transaction date
  String getFormattedDate() {
    try {
      final date = DateTime.parse(transactionDate);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return transactionDate;
    }
  }

  /// Get formatted amount with currency symbol
  String getFormattedAmount() {
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Check if transaction is positive (IN)
  bool get isPositive => transactionType == 'IN';

  /// Get month name
  static String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  /// Get initials from party name
  String getInitials() {
    final parts = partyName.trim().split(' ');
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'A';
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}
