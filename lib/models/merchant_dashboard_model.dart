/// Merchant Dashboard Model for Account Screen
/// This model represents the overall merchant account summary
class MerchantDashboardModel {
  final double todayIn;
  final double todayOut;
  final double overallGiven;
  final double overallReceived;
  final double netBalance;
  final String netBalanceType;
  final MerchantPartyBreakdown party;

  MerchantDashboardModel({
    required this.todayIn,
    required this.todayOut,
    required this.overallGiven,
    required this.overallReceived,
    required this.netBalance,
    required this.netBalanceType,
    required this.party,
  });

  /// Factory constructor to create model from JSON
  factory MerchantDashboardModel.fromJson(Map<String, dynamic> json) {
    return MerchantDashboardModel(
      todayIn: _parseDouble(json['todayIn']),
      todayOut: _parseDouble(json['todayOut']),
      overallGiven: _parseDouble(json['overallGiven']),
      overallReceived: _parseDouble(json['overallReceived']),
      netBalance: _parseDouble(json['netBalance']),
      netBalanceType: (json['netBalanceType'] as String?) ?? 'OUT',
      party: MerchantPartyBreakdown.fromJson(json['party'] ?? {}),
    );
  }

  /// Helper to safely parse double from dynamic value
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'todayIn': todayIn,
      'todayOut': todayOut,
      'overallGiven': overallGiven,
      'overallReceived': overallReceived,
      'netBalance': netBalance,
      'netBalanceType': netBalanceType,
      'party': party.toJson(),
    };
  }

  /// Check if merchant is in credit (owes money)
  bool get isInCredit => overallReceived > overallGiven;

  /// Get formatted total net balance
  String getFormattedTotalBalance() {
    return '₹${netBalance.abs().toStringAsFixed(2)}';
  }

  /// Get today's net flow (in - out)
  double get todayNetFlow => todayIn - todayOut;
}

/// Party-wise breakdown for merchant dashboard
class MerchantPartyBreakdown {
  final MerchantPartyData customer;
  final MerchantPartyData supplier;
  final MerchantPartyData employee;

  MerchantPartyBreakdown({
    required this.customer,
    required this.supplier,
    required this.employee,
  });

  factory MerchantPartyBreakdown.fromJson(Map<String, dynamic> json) {
    return MerchantPartyBreakdown(
      customer: MerchantPartyData.fromJson(json['customer'] ?? {}),
      supplier: MerchantPartyData.fromJson(json['supplier'] ?? {}),
      employee: MerchantPartyData.fromJson(json['employee'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer': customer.toJson(),
      'supplier': supplier.toJson(),
      'employee': employee.toJson(),
    };
  }
}

/// Individual party type data
class MerchantPartyData {
  final double overallGiven;
  final double overallReceived;
  final double netBalance;
  final String netBalanceType;
  final int total;

  MerchantPartyData({
    required this.overallGiven,
    required this.overallReceived,
    required this.netBalance,
    required this.netBalanceType,
    required this.total,
  });

  factory MerchantPartyData.fromJson(Map<String, dynamic> json) {
    return MerchantPartyData(
      overallGiven: _parseDouble(json['overallGiven']),
      overallReceived: _parseDouble(json['overallReceived']),
      netBalance: _parseDouble(json['netBalance']),
      netBalanceType: (json['netBalanceType'] as String?) ?? 'OUT',
      total: _parseInt(json['total']),
    );
  }

  /// Helper to safely parse double from dynamic value
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Helper to safely parse int from dynamic value
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'overallGiven': overallGiven,
      'overallReceived': overallReceived,
      'netBalance': netBalance,
      'netBalanceType': netBalanceType,
      'total': total,
    };
  }

  /// Check if in credit for this party type (you owe them)
  bool get isInCredit => overallReceived > overallGiven;

  /// Get formatted net balance
  String getFormattedBalance() {
    return '₹${netBalance.abs().toStringAsFixed(2)}';
  }
}
