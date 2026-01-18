/// Merchant Dashboard Model for Account Screen
/// This model represents the overall merchant account summary
class MerchantDashboardModel {
  final double todayIn;
  final double todayOut;
  final double overallGiven;
  final double overallReceived;
  final MerchantPartyBreakdown party;

  MerchantDashboardModel({
    required this.todayIn,
    required this.todayOut,
    required this.overallGiven,
    required this.overallReceived,
    required this.party,
  });

  /// Factory constructor to create model from JSON
  factory MerchantDashboardModel.fromJson(Map<String, dynamic> json) {
    return MerchantDashboardModel(
      todayIn: (json['todayIn'] ?? 0).toDouble(),
      todayOut: (json['todayOut'] ?? 0).toDouble(),
      overallGiven: (json['overallGiven'] ?? 0).toDouble(),
      overallReceived: (json['overallReceived'] ?? 0).toDouble(),
      party: MerchantPartyBreakdown.fromJson(json['party'] ?? {}),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'todayIn': todayIn,
      'todayOut': todayOut,
      'overallGiven': overallGiven,
      'overallReceived': overallReceived,
      'party': party.toJson(),
    };
  }

  /// Calculate total net balance across all parties
  /// Positive = You will receive (Receivable)
  /// Negative = You need to pay (Payable)
  double get totalNetBalance => overallGiven - overallReceived;

  /// Check if merchant is in credit (owes money)
  bool get isInCredit => overallReceived > overallGiven;

  /// Get balance type: 'IN' = Receivable, 'OUT' = Payable
  /// This follows the same pattern as transactionType for consistency
  String get balanceType => totalNetBalance >= 0 ? 'IN' : 'OUT';

  /// Get formatted total net balance
  String getFormattedTotalBalance() {
    return '₹${totalNetBalance.abs().toStringAsFixed(2)}';
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

  MerchantPartyData({
    required this.overallGiven,
    required this.overallReceived,
  });

  factory MerchantPartyData.fromJson(Map<String, dynamic> json) {
    return MerchantPartyData(
      overallGiven: (json['overallGiven'] ?? 0).toDouble(),
      overallReceived: (json['overallReceived'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallGiven': overallGiven,
      'overallReceived': overallReceived,
    };
  }

  /// Calculate net balance for this party type
  /// Positive = They owe you (Receivable)
  /// Negative = You owe them (Payable)
  double get netBalance => overallGiven - overallReceived;

  /// Check if in credit for this party type (you owe them)
  bool get isInCredit => overallReceived > overallGiven;

  /// Get balance type: 'IN' = Receivable, 'OUT' = Payable
  /// This follows the same pattern as transactionType for consistency
  String get balanceType => netBalance >= 0 ? 'IN' : 'OUT';

  /// Get formatted net balance
  String getFormattedBalance() {
    return '₹${netBalance.abs().toStringAsFixed(2)}';
  }
}
