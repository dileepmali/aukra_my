class LedgerDetailModel {
  final int id;
  final int merchantId;
  final int? partyMerchantId;
  final int? partyLedgerId;
  final String partyType;
  final String partyName;
  final bool isDelete;
  final DateTime createdAt;
  final double salary;
  final String salaryType;
  final int creditDay;
  final double creditLimit;
  final double interestRate;
  final String interestType;
  final double openingBalance;
  final double currentBalance;
  final DateTime updatedAt;
  final String? address;
  final String? area;
  final String? city;
  final String? country;
  final String? pinCode;
  final String transactionType;
  final String? mobileNumber;

  LedgerDetailModel({
    required this.id,
    required this.merchantId,
    this.partyMerchantId,
    this.partyLedgerId,
    required this.partyType,
    required this.partyName,
    required this.isDelete,
    required this.createdAt,
    required this.salary,
    required this.salaryType,
    required this.creditDay,
    required this.creditLimit,
    required this.interestRate,
    required this.interestType,
    required this.openingBalance,
    required this.currentBalance,
    required this.updatedAt,
    this.address,
    this.area,
    this.city,
    this.country,
    this.pinCode,
    required this.transactionType,
    this.mobileNumber,
  });

  factory LedgerDetailModel.fromJson(Map<String, dynamic> json) {
    return LedgerDetailModel(
      id: json['id'] ?? 0,
      merchantId: json['merchantId'] ?? 0,
      partyMerchantId: json['partyMerchantId'],
      partyLedgerId: json['partyLedgerId'],
      partyType: json['partyType'] ?? '',
      partyName: json['partyName'] ?? '',
      isDelete: json['isDelete'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      salary: (json['salary'] ?? 0).toDouble(),
      salaryType: json['salaryType'] ?? 'YEARLY',
      creditDay: json['creditDay'] ?? 0,
      creditLimit: (json['creditLimit'] ?? 0).toDouble(),
      interestRate: (json['interestRate'] ?? 0).toDouble(),
      interestType: json['interestType'] ?? 'YEARLY',
      openingBalance: (json['openingBalance'] ?? 0).toDouble(),
      currentBalance: (json['currentBalance'] ?? 0).toDouble(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      address: json['address'],
      area: json['area'],
      city: json['city'],
      country: json['country'],
      pinCode: json['pinCode'],
      transactionType: json['transactionType'] ?? 'IN',
      mobileNumber: json['mobileNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchantId': merchantId,
      'partyMerchantId': partyMerchantId,
      'partyLedgerId': partyLedgerId,
      'partyType': partyType,
      'partyName': partyName,
      'isDelete': isDelete,
      'createdAt': createdAt.toIso8601String(),
      'salary': salary,
      'salaryType': salaryType,
      'creditDay': creditDay,
      'creditLimit': creditLimit,
      'interestRate': interestRate,
      'interestType': interestType,
      'openingBalance': openingBalance,
      'currentBalance': currentBalance,
      'updatedAt': updatedAt.toIso8601String(),
      'address': address,
      'area': area,
      'city': city,
      'country': country,
      'pinCode': pinCode,
      'transactionType': transactionType,
      'mobileNumber': mobileNumber,
    };
  }
}

// Transaction item model
class LedgerTransactionItem {
  final String date;
  final double inAmount;
  final double outAmount;
  final double balance;
  final String balanceType;

  LedgerTransactionItem({
    required this.date,
    required this.inAmount,
    required this.outAmount,
    required this.balance,
    required this.balanceType,
  });

  factory LedgerTransactionItem.fromJson(Map<String, dynamic> json) {
    return LedgerTransactionItem(
      date: json['date'] ?? '',
      inAmount: (json['in'] ?? 0).toDouble(),
      outAmount: (json['out'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      balanceType: json['balanceType'] ?? 'IN',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'in': inAmount,
      'out': outAmount,
      'balance': balance,
      'balanceType': balanceType,
    };
  }
}

// Transaction history model
class LedgerTransactionHistory {
  final String startDate;
  final String endDate;
  final List<LedgerTransactionItem> data;

  LedgerTransactionHistory({
    required this.startDate,
    required this.endDate,
    required this.data,
  });

  factory LedgerTransactionHistory.fromJson(Map<String, dynamic> json) {
    return LedgerTransactionHistory(
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => LedgerTransactionItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}
