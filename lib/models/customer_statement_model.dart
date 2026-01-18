/// Model for Customer Statement Screen
/// This model represents the customer list only
/// NOTE: netBalance, totalCustomers, yesterdayIn/Out are now from Dashboard API
class CustomerStatementModel {
  final List<CustomerStatementItem> customers;

  CustomerStatementModel({
    required this.customers,
  });

  factory CustomerStatementModel.fromJson(Map<String, dynamic> json) {
    return CustomerStatementModel(
      customers: (json['customers'] as List<dynamic>?)
              ?.map((item) => CustomerStatementItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customers': customers.map((item) => item.toJson()).toList(),
    };
  }
}

/// Individual customer item in statement
class CustomerStatementItem {
  final int id;
  final String name;
  final String location;
  final double balance;
  final String balanceType; // "IN" or "OUT"
  final DateTime lastTransactionDate;
  final String? mobileNumber;

  CustomerStatementItem({
    required this.id,
    required this.name,
    required this.location,
    required this.balance,
    required this.balanceType,
    required this.lastTransactionDate,
    this.mobileNumber,
  });

  factory CustomerStatementItem.fromJson(Map<String, dynamic> json) {
    return CustomerStatementItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['partyName'] ?? '',
      location: json['location'] ?? json['area'] ?? '',
      balance: (json['balance'] ?? json['currentBalance'] ?? 0).toDouble(),
      balanceType: json['balanceType'] ?? json['transactionType'] ?? 'IN',
      lastTransactionDate: json['lastTransactionDate'] != null
          ? DateTime.parse(json['lastTransactionDate'])
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
      mobileNumber: json['mobileNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'balance': balance,
      'balanceType': balanceType,
      'lastTransactionDate': lastTransactionDate.toIso8601String(),
      'mobileNumber': mobileNumber,
    };
  }

  /// ✅ Get signed balance (balance with correct sign)
  /// API returns balance as absolute value, balanceType indicates direction
  /// IN = positive (customer owes you - Receivable)
  /// OUT = negative (you owe customer - Payable)
  double get signedBalance => balanceType == 'IN' ? balance : -balance;
}
