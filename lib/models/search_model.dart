/// Search Model for Search Screen
/// Defines all searchable fields and search result structure

/// Enum for searchable field types
enum SearchableField {
  name,
  mobileNumber,
  address,
  area,
  pinCode,
  balanceAmount,
  balanceType, // IN or OUT
}

/// Extension for SearchableField
extension SearchableFieldExtension on SearchableField {
  /// Get display label for field
  String get label {
    switch (this) {
      case SearchableField.name:
        return 'Name';
      case SearchableField.mobileNumber:
        return 'Mobile Number';
      case SearchableField.address:
        return 'Address';
      case SearchableField.area:
        return 'Area';
      case SearchableField.pinCode:
        return 'Pincode';
      case SearchableField.balanceAmount:
        return 'Balance Amount';
      case SearchableField.balanceType:
        return 'Balance Type (IN/OUT)';
    }
  }

  /// Get hint text for field
  String get hint {
    switch (this) {
      case SearchableField.name:
        return 'Search by name...';
      case SearchableField.mobileNumber:
        return 'Search by mobile number...';
      case SearchableField.address:
        return 'Search by address...';
      case SearchableField.area:
        return 'Search by area...';
      case SearchableField.pinCode:
        return 'Search by pincode...';
      case SearchableField.balanceAmount:
        return 'Search by amount (e.g., 5000)...';
      case SearchableField.balanceType:
        return 'Type "IN" or "OUT"...';
    }
  }
}

/// Search configuration model
class SearchConfig {
  /// Party type to search in (CUSTOMER, SUPPLIER, EMPLOYEE)
  final String partyType;

  /// Party type label for display
  final String partyTypeLabel;

  /// List of enabled searchable fields
  final List<SearchableField> enabledFields;

  /// Placeholder text for search bar
  final String searchHint;

  SearchConfig({
    required this.partyType,
    required this.partyTypeLabel,
    List<SearchableField>? enabledFields,
    String? searchHint,
  })  : enabledFields = enabledFields ?? SearchableField.values,
        searchHint = searchHint ?? 'Search by name, mobile, address...';

  /// Factory for Customer search
  factory SearchConfig.customer() => SearchConfig(
        partyType: 'CUSTOMER',
        partyTypeLabel: 'Customer',
        searchHint: 'Search customers...',
      );

  /// Factory for Supplier search
  factory SearchConfig.supplier() => SearchConfig(
        partyType: 'SUPPLIER',
        partyTypeLabel: 'Supplier',
        searchHint: 'Search suppliers...',
      );

  /// Factory for Employee search
  factory SearchConfig.employee() => SearchConfig(
        partyType: 'EMPLOYEE',
        partyTypeLabel: 'Employee',
        searchHint: 'Search employees...',
      );

  /// Factory from party type string
  factory SearchConfig.fromPartyType(String partyType) {
    switch (partyType.toUpperCase()) {
      case 'CUSTOMER':
        return SearchConfig.customer();
      case 'SUPPLIER':
        return SearchConfig.supplier();
      case 'EMPLOYEE':
        return SearchConfig.employee();
      default:
        return SearchConfig(
          partyType: partyType,
          partyTypeLabel: partyType,
        );
    }
  }
}

/// Search result item model
class SearchResultItem {
  /// Unique ID
  final int id;

  /// Primary display name
  final String name;

  /// Mobile number
  final String? mobileNumber;

  /// Full address
  final String? address;

  /// Area/Locality
  final String? area;

  /// Pin code
  final String? pinCode;

  /// Current balance amount (absolute value)
  final double balance;

  /// Balance type: 'IN' (positive) or 'OUT' (negative)
  final String balanceType;

  /// Party type: CUSTOMER, SUPPLIER, EMPLOYEE
  final String partyType;

  /// Created date/time
  final DateTime? createdAt;

  /// Updated date/time
  final DateTime? updatedAt;

  /// Original ledger data for navigation
  final dynamic originalData;

  /// Which field matched the search query
  final SearchableField? matchedField;

  SearchResultItem({
    required this.id,
    required this.name,
    this.mobileNumber,
    this.address,
    this.area,
    this.pinCode,
    required this.balance,
    required this.balanceType,
    required this.partyType,
    this.createdAt,
    this.updatedAt,
    this.originalData,
    this.matchedField,
  });

  /// Get initials for avatar
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'A';
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  /// Check if balance is positive (IN)
  bool get isPositiveBalance => balanceType == 'IN';

  /// Get subtitle for display (date, time and address)
  String get subtitle {
    String result = '';

    // Format date and time (same as LedgerScreen)
    final displayDate = updatedAt ?? createdAt;
    if (displayDate != null) {
      final localTime = displayDate.toLocal();
      final day = localTime.day;
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = months[localTime.month - 1];
      final year = localTime.year;
      final hour = localTime.hour.toString().padLeft(2, '0');
      final minute = localTime.minute.toString().padLeft(2, '0');
      result = '$day $month $year, $hour:$minute';
    }

    // Add address/area if available
    if (address != null && address!.isNotEmpty) {
      result += result.isNotEmpty ? ' • $address' : address!;
    } else if (area != null && area!.isNotEmpty) {
      result += result.isNotEmpty ? ' • $area' : area!;
    }

    return result.isEmpty ? 'No details' : result;
  }

  /// Get location string
  String get location {
    if (area != null && area!.isNotEmpty) return area!;
    if (address != null && address!.isNotEmpty) return address!;
    return 'N/A';
  }

  /// Create from LedgerModel
  factory SearchResultItem.fromLedger(
    dynamic ledger, {
    SearchableField? matchedField,
  }) {
    final currentBalance = (ledger.currentBalance as num).toDouble();

    return SearchResultItem(
      id: ledger.id ?? 0,
      name: ledger.name ?? '',
      mobileNumber: ledger.mobileNumber,
      address: ledger.address,
      area: ledger.area,
      pinCode: ledger.pinCode,
      balance: currentBalance.abs(),
      balanceType: currentBalance >= 0 ? 'IN' : 'OUT',
      partyType: ledger.partyType ?? 'CUSTOMER',
      createdAt: ledger.createdAt,
      updatedAt: ledger.updatedAt,
      originalData: ledger,
      matchedField: matchedField,
    );
  }

  /// Copy with method
  SearchResultItem copyWith({
    int? id,
    String? name,
    String? mobileNumber,
    String? address,
    String? area,
    String? pinCode,
    double? balance,
    String? balanceType,
    String? partyType,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic originalData,
    SearchableField? matchedField,
  }) {
    return SearchResultItem(
      id: id ?? this.id,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      area: area ?? this.area,
      pinCode: pinCode ?? this.pinCode,
      balance: balance ?? this.balance,
      balanceType: balanceType ?? this.balanceType,
      partyType: partyType ?? this.partyType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      originalData: originalData ?? this.originalData,
      matchedField: matchedField ?? this.matchedField,
    );
  }
}

/// Search summary model for displaying stats
class SearchSummary {
  /// Total count of items
  final int totalCount;

  /// Count of items with IN balance
  final int inCount;

  /// Count of items with OUT balance
  final int outCount;

  /// Total IN amount
  final double totalInAmount;

  /// Total OUT amount
  final double totalOutAmount;

  /// Net balance
  double get netBalance => totalInAmount - totalOutAmount;

  SearchSummary({
    required this.totalCount,
    required this.inCount,
    required this.outCount,
    required this.totalInAmount,
    required this.totalOutAmount,
  });

  /// Empty summary
  factory SearchSummary.empty() => SearchSummary(
        totalCount: 0,
        inCount: 0,
        outCount: 0,
        totalInAmount: 0,
        totalOutAmount: 0,
      );
}

/// Sort options for search results
enum SearchSortBy {
  name,
  balance,
  recent,
}

/// Extension for SearchSortBy
extension SearchSortByExtension on SearchSortBy {
  String get label {
    switch (this) {
      case SearchSortBy.name:
        return 'Name';
      case SearchSortBy.balance:
        return 'Balance';
      case SearchSortBy.recent:
        return 'Recent';
    }
  }
}

/// Sort order
enum SearchSortOrder {
  ascending,
  descending,
}

/// Extension for SearchSortOrder
extension SearchSortOrderExtension on SearchSortOrder {
  String get label {
    switch (this) {
      case SearchSortOrder.ascending:
        return 'A-Z / Low-High';
      case SearchSortOrder.descending:
        return 'Z-A / High-Low';
    }
  }

  String get shortLabel {
    switch (this) {
      case SearchSortOrder.ascending:
        return 'Asc';
      case SearchSortOrder.descending:
        return 'Desc';
    }
  }
}
