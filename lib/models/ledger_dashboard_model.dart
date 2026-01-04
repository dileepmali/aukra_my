/// Ledger Dashboard Response Model
class LedgerDashboardModel {
  final double todayIn;
  final double todayOut;
  final double overallGiven;
  final double overallReceived;
  final PartyBreakdown party;

  LedgerDashboardModel({
    required this.todayIn,
    required this.todayOut,
    required this.overallGiven,
    required this.overallReceived,
    required this.party,
  });

  factory LedgerDashboardModel.fromJson(Map<String, dynamic> json) {
    return LedgerDashboardModel(
      todayIn: (json['todayIn'] ?? 0).toDouble(),
      todayOut: (json['todayOut'] ?? 0).toDouble(),
      overallGiven: (json['overallGiven'] ?? 0).toDouble(),
      overallReceived: (json['overallReceived'] ?? 0).toDouble(),
      party: PartyBreakdown.fromJson(json['party'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayIn': todayIn,
      'todayOut': todayOut,
      'overallGiven': overallGiven,
      'overallReceived': overallReceived,
      'party': party.toJson(),
    };
  }

  /// Get net balance (received - given)
  double get netBalance => overallReceived - overallGiven;

  /// Check if in credit (given more than received)
  bool get isInCredit => overallGiven > overallReceived;

  /// Get formatted net balance
  String getFormattedNetBalance() {
    return '₹${netBalance.abs().toStringAsFixed(2)}';
  }
}

/// Party-wise breakdown
class PartyBreakdown {
  final PartyData customer;
  final PartyData supplier;
  final PartyData employee;

  PartyBreakdown({
    required this.customer,
    required this.supplier,
    required this.employee,
  });

  factory PartyBreakdown.fromJson(Map<String, dynamic> json) {
    return PartyBreakdown(
      customer: PartyData.fromJson(json['customer'] ?? {}),
      supplier: PartyData.fromJson(json['supplier'] ?? {}),
      employee: PartyData.fromJson(json['employee'] ?? {}),
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

/// Individual party data
class PartyData {
  final double overallGiven;
  final double overallReceived;

  PartyData({
    required this.overallGiven,
    required this.overallReceived,
  });

  factory PartyData.fromJson(Map<String, dynamic> json) {
    return PartyData(
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

  /// Get net balance for this party type
  double get netBalance => overallReceived - overallGiven;

  /// Check if in credit
  bool get isInCredit => overallGiven > overallReceived;
}
