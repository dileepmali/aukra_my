/// Party-specific Dashboard Model
/// Response from GET /api/merchant/{merchantId}/{partyType}/dashboard
/// Example response:
/// {
///   "todayIn": 0,
///   "todayOut": 0,
///   "overallGiven": 214368752.95999998,
///   "overallReceived": 17743.309999999998,
///   "netBalance": 214351009.64999998,
///   "netBalanceType": "OUT",
///   "total": 8
/// }
class PartyDashboardModel {
  final double todayIn;
  final double todayOut;
  final double overallGiven;
  final double overallReceived;
  final double netBalance;
  final String netBalanceType;
  final int total;

  PartyDashboardModel({
    required this.todayIn,
    required this.todayOut,
    required this.overallGiven,
    required this.overallReceived,
    required this.netBalance,
    required this.netBalanceType,
    required this.total,
  });

  /// Factory constructor to create model from JSON
  factory PartyDashboardModel.fromJson(Map<String, dynamic> json) {
    return PartyDashboardModel(
      todayIn: _parseDouble(json['todayIn']),
      todayOut: _parseDouble(json['todayOut']),
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

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'todayIn': todayIn,
      'todayOut': todayOut,
      'overallGiven': overallGiven,
      'overallReceived': overallReceived,
      'netBalance': netBalance,
      'netBalanceType': netBalanceType,
      'total': total,
    };
  }

  /// Check if balance is positive (IN type)
  bool get isPositive => netBalanceType == 'IN';

  /// Get formatted net balance
  String getFormattedBalance() {
    return '₹${netBalance.abs().toStringAsFixed(2)}';
  }
}