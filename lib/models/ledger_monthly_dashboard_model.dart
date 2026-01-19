/// Model for Ledger Monthly Dashboard API response
/// Endpoint: GET /api/ledger/{ledgerId}/dashboard
///
/// Response format:
/// {
///   "totalIn": 6721,
///   "totalOut": 55,
///   "startDate": "2026-01-01T00:00:00.000Z",
///   "endDate": "2026-01-31T23:59:59.999Z"
/// }

class LedgerMonthlyDashboardModel {
  final double totalIn;
  final double totalOut;
  final String startDate;
  final String endDate;

  LedgerMonthlyDashboardModel({
    required this.totalIn,
    required this.totalOut,
    required this.startDate,
    required this.endDate,
  });

  factory LedgerMonthlyDashboardModel.fromJson(Map<String, dynamic> json) {
    return LedgerMonthlyDashboardModel(
      totalIn: (json['totalIn'] ?? 0).toDouble(),
      totalOut: (json['totalOut'] ?? 0).toDouble(),
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalIn': totalIn,
      'totalOut': totalOut,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}