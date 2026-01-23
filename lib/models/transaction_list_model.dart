/// Transaction List Response Model
class TransactionListModel {
  final int count;
  final int totalCount; // Total transactions available (for pagination)
  final List<TransactionItemModel> data;

  TransactionListModel({
    required this.count,
    required this.totalCount,
    required this.data,
  });

  factory TransactionListModel.fromJson(Map<String, dynamic> json) {
    return TransactionListModel(
      count: json['count'] ?? 0,
      totalCount: json['totalCount'] ?? json['count'] ?? 0, // Fallback to count if totalCount not present
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
      'totalCount': totalCount,
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
  final List<int>? uploadedKeys; // Image keys uploaded with this transaction

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
    this.uploadedKeys,
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
      uploadedKeys: json['uploadedKeys'] != null
          ? List<int>.from(json['uploadedKeys'])
          : null,
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
      if (uploadedKeys != null) 'uploadedKeys': uploadedKeys,
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

  /// Check if transaction has images
  bool get hasImages => uploadedKeys != null && uploadedKeys!.isNotEmpty;

  /// Get number of images
  int get imageCount => uploadedKeys?.length ?? 0;

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

  /// Create a copy with updated balance values
  /// Used for frontend balance recalculation when backend doesn't update
  TransactionItemModel copyWith({
    double? lastBalance,
    double? currentBalance,
  }) {
    return TransactionItemModel(
      id: id,
      amount: amount,
      lastBalance: lastBalance ?? this.lastBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      description: description,
      isDelete: isDelete,
      transactionDate: transactionDate,
      updatedAt: updatedAt,
      transactionType: transactionType,
      ledgerId: ledgerId,
      partyName: partyName,
      partyType: partyType,
      balanceType: balanceType,
      uploadedKeys: uploadedKeys,
    );
  }
}
