/// Model for Ledger Dashboard Summary API response
/// Endpoint: GET /api/ledger/{ledgerId}/dashboard/summary
///
/// Response format:
/// {
///   "today": {
///     "totalIn": 5000,
///     "totalOut": 3000
///   },
///   "overall": {
///     "totalIn": 150000,
///     "totalOut": 120000
///   }
/// }

class LedgerDashboardSummaryModel {
  final TodaySummary today;
  final OverallSummary overall;

  LedgerDashboardSummaryModel({
    required this.today,
    required this.overall,
  });

  factory LedgerDashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return LedgerDashboardSummaryModel(
      today: TodaySummary.fromJson(json['today'] ?? {}),
      overall: OverallSummary.fromJson(json['overall'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today': today.toJson(),
      'overall': overall.toJson(),
    };
  }
}

class TodaySummary {
  final double totalIn;
  final double totalOut;

  TodaySummary({
    required this.totalIn,
    required this.totalOut,
  });

  factory TodaySummary.fromJson(Map<String, dynamic> json) {
    return TodaySummary(
      totalIn: (json['totalIn'] ?? 0).toDouble(),
      totalOut: (json['totalOut'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalIn': totalIn,
      'totalOut': totalOut,
    };
  }
}

class OverallSummary {
  final double totalIn;
  final double totalOut;

  OverallSummary({
    required this.totalIn,
    required this.totalOut,
  });

  factory OverallSummary.fromJson(Map<String, dynamic> json) {
    return OverallSummary(
      totalIn: (json['totalIn'] ?? 0).toDouble(),
      totalOut: (json['totalOut'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalIn': totalIn,
      'totalOut': totalOut,
    };
  }
}