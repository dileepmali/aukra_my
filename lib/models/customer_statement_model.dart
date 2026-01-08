/// Model for Customer Statement Screen
/// This model represents the aggregated data for customer statements
class CustomerStatementModel {
  final double netBalance;
  final int totalCustomers;
  final double yesterdayTotalIn;
  final double yesterdayTotalOut;
  final List<CustomerStatementItem> customers;

  CustomerStatementModel({
    required this.netBalance,
    required this.totalCustomers,
    required this.yesterdayTotalIn,
    required this.yesterdayTotalOut,
    required this.customers,
  });

  factory CustomerStatementModel.fromJson(Map<String, dynamic> json) {
    return CustomerStatementModel(
      netBalance: (json['netBalance'] ?? 0).toDouble(),
      totalCustomers: json['totalCustomers'] ?? 0,
      yesterdayTotalIn: (json['yesterdayTotalIn'] ?? 0).toDouble(),
      yesterdayTotalOut: (json['yesterdayTotalOut'] ?? 0).toDouble(),
      customers: (json['customers'] as List<dynamic>?)
              ?.map((item) => CustomerStatementItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'netBalance': netBalance,
      'totalCustomers': totalCustomers,
      'yesterdayTotalIn': yesterdayTotalIn,
      'yesterdayTotalOut': yesterdayTotalOut,
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
}
