/// Transaction Detail Model
/// Response from GET /api/ledgerTranscation/details/{transactionId}
class TransactionDetailModel {
  final int id;
  final String? transactionId;
  final int? senderLedgerId;
  final int? senderMerchantId;
  final int? ownerId;
  final int? receiverMerchantId;
  final int? receiverLedgerId;
  final double amount;
  final double lastBalance;
  final double currentBalance;
  final String? description;
  final String? transactionDate;
  final int creditDay;
  final double interestRate;
  final bool isDelete;
  final String? createdBy;
  final String? sessionId;
  final String? updatedBy;
  final String? createdAt;
  final String? updatedAt;
  final List<AttachmentModel> attachments;
  final int version;
  final List<dynamic> transactionHistory;
  final MerchantInfo? senderMerchant;
  final MerchantInfo? receiverMerchant;
  final String? transactionType;
  final String? customerName;

  TransactionDetailModel({
    required this.id,
    this.transactionId,
    this.senderLedgerId,
    this.senderMerchantId,
    this.ownerId,
    this.receiverMerchantId,
    this.receiverLedgerId,
    required this.amount,
    required this.lastBalance,
    required this.currentBalance,
    this.description,
    this.transactionDate,
    this.creditDay = 0,
    this.interestRate = 0,
    this.isDelete = false,
    this.createdBy,
    this.sessionId,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    required this.attachments,
    this.version = 0,
    this.transactionHistory = const [],
    this.senderMerchant,
    this.receiverMerchant,
    this.transactionType,
    this.customerName,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailModel(
      id: json['id'] ?? 0,
      transactionId: json['transactionId'],
      senderLedgerId: json['senderLedgerId'],
      senderMerchantId: json['senderMerchantId'],
      ownerId: json['ownerId'],
      receiverMerchantId: json['receiverMerchantId'],
      receiverLedgerId: json['receiverLedgerId'],
      amount: (json['amount'] ?? 0).toDouble(),
      lastBalance: (json['lastBalance'] ?? 0).toDouble(),
      currentBalance: (json['currentBalance'] ?? 0).toDouble(),
      description: json['description'],
      transactionDate: json['transactionDate'],
      creditDay: json['creditDay'] ?? 0,
      interestRate: (json['interestRate'] ?? 0).toDouble(),
      isDelete: json['isDelete'] ?? false,
      createdBy: json['createdBy'],
      sessionId: json['sessionId'],
      updatedBy: json['updatedBy'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      attachments: json['attachment'] != null
          ? (json['attachment'] as List)
              .map((item) => AttachmentModel.fromJson(item))
              .toList()
          : [],
      version: json['version'] ?? 0,
      transactionHistory: json['transactionHistory'] ?? [],
      senderMerchant: json['senderMerchant'] != null
          ? MerchantInfo.fromJson(json['senderMerchant'])
          : null,
      receiverMerchant: json['receiverMerchant'] != null
          ? MerchantInfo.fromJson(json['receiverMerchant'])
          : null,
      transactionType: json['transactionType'],
      customerName: json['customerName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'senderLedgerId': senderLedgerId,
      'senderMerchantId': senderMerchantId,
      'ownerId': ownerId,
      'receiverMerchantId': receiverMerchantId,
      'receiverLedgerId': receiverLedgerId,
      'amount': amount,
      'lastBalance': lastBalance,
      'currentBalance': currentBalance,
      'description': description,
      'transactionDate': transactionDate,
      'creditDay': creditDay,
      'interestRate': interestRate,
      'isDelete': isDelete,
      'createdBy': createdBy,
      'sessionId': sessionId,
      'updatedBy': updatedBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'attachment': attachments.map((a) => a.toJson()).toList(),
      'version': version,
      'transactionHistory': transactionHistory,
      'senderMerchant': senderMerchant?.toJson(),
      'receiverMerchant': receiverMerchant?.toJson(),
      'transactionType': transactionType,
      'customerName': customerName,
    };
  }

  /// Check if transaction has attachments
  bool get hasAttachments => attachments.isNotEmpty;

  /// Get attachment count
  int get attachmentCount => attachments.length;

  /// Get all attachment URLs
  List<String> get attachmentUrls =>
      attachments.map((a) => a.url).where((url) => url.isNotEmpty).toList();
}

/// Attachment Model for transaction images
class AttachmentModel {
  final int id;
  final String url;
  final String? fileName;
  final String? mimeType;
  final int? fileSize;
  final String? createdAt;

  AttachmentModel({
    required this.id,
    required this.url,
    this.fileName,
    this.mimeType,
    this.fileSize,
    this.createdAt,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] ?? 0,
      url: json['url'] ?? json['imageUrl'] ?? json['fileUrl'] ?? '',
      fileName: json['fileName'] ?? json['name'],
      mimeType: json['mimeType'] ?? json['type'],
      fileSize: json['fileSize'] ?? json['size'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'fileName': fileName,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'createdAt': createdAt,
    };
  }
}

/// Merchant Info Model
class MerchantInfo {
  final int id;
  final String? mobileNumber;
  final String? businessName;

  MerchantInfo({
    required this.id,
    this.mobileNumber,
    this.businessName,
  });

  factory MerchantInfo.fromJson(Map<String, dynamic> json) {
    return MerchantInfo(
      id: json['id'] ?? 0,
      mobileNumber: json['mobileNumber'],
      businessName: json['businessName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobileNumber': mobileNumber,
      'businessName': businessName,
    };
  }
}
