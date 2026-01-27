// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LedgersTable extends Ledgers with TableInfo<$LedgersTable, Ledger> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _merchantIdMeta = const VerificationMeta(
    'merchantId',
  );
  @override
  late final GeneratedColumn<int> merchantId = GeneratedColumn<int>(
    'merchant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partyTypeMeta = const VerificationMeta(
    'partyType',
  );
  @override
  late final GeneratedColumn<String> partyType = GeneratedColumn<String>(
    'party_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('CUSTOMER'),
  );
  static const VerificationMeta _currentBalanceMeta = const VerificationMeta(
    'currentBalance',
  );
  @override
  late final GeneratedColumn<double> currentBalance = GeneratedColumn<double>(
    'current_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _openingBalanceMeta = const VerificationMeta(
    'openingBalance',
  );
  @override
  late final GeneratedColumn<double> openingBalance = GeneratedColumn<double>(
    'opening_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('IN'),
  );
  static const VerificationMeta _creditLimitMeta = const VerificationMeta(
    'creditLimit',
  );
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
    'credit_limit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _creditDayMeta = const VerificationMeta(
    'creditDay',
  );
  @override
  late final GeneratedColumn<int> creditDay = GeneratedColumn<int>(
    'credit_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _interestTypeMeta = const VerificationMeta(
    'interestType',
  );
  @override
  late final GeneratedColumn<String> interestType = GeneratedColumn<String>(
    'interest_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('YEARLY'),
  );
  static const VerificationMeta _interestRateMeta = const VerificationMeta(
    'interestRate',
  );
  @override
  late final GeneratedColumn<double> interestRate = GeneratedColumn<double>(
    'interest_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _mobileNumberMeta = const VerificationMeta(
    'mobileNumber',
  );
  @override
  late final GeneratedColumn<String> mobileNumber = GeneratedColumn<String>(
    'mobile_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  @override
  late final GeneratedColumn<String> area = GeneratedColumn<String>(
    'area',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pinCodeMeta = const VerificationMeta(
    'pinCode',
  );
  @override
  late final GeneratedColumn<String> pinCode = GeneratedColumn<String>(
    'pin_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>(
        'transaction_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    merchantId,
    name,
    partyType,
    currentBalance,
    openingBalance,
    transactionType,
    creditLimit,
    creditDay,
    interestType,
    interestRate,
    mobileNumber,
    area,
    address,
    pinCode,
    isSynced,
    localId,
    createdAt,
    updatedAt,
    transactionDate,
    localUpdatedAt,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledgers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ledger> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('merchant_id')) {
      context.handle(
        _merchantIdMeta,
        merchantId.isAcceptableOrUnknown(data['merchant_id']!, _merchantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_merchantIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('party_type')) {
      context.handle(
        _partyTypeMeta,
        partyType.isAcceptableOrUnknown(data['party_type']!, _partyTypeMeta),
      );
    }
    if (data.containsKey('current_balance')) {
      context.handle(
        _currentBalanceMeta,
        currentBalance.isAcceptableOrUnknown(
          data['current_balance']!,
          _currentBalanceMeta,
        ),
      );
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
        _openingBalanceMeta,
        openingBalance.isAcceptableOrUnknown(
          data['opening_balance']!,
          _openingBalanceMeta,
        ),
      );
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
        _creditLimitMeta,
        creditLimit.isAcceptableOrUnknown(
          data['credit_limit']!,
          _creditLimitMeta,
        ),
      );
    }
    if (data.containsKey('credit_day')) {
      context.handle(
        _creditDayMeta,
        creditDay.isAcceptableOrUnknown(data['credit_day']!, _creditDayMeta),
      );
    }
    if (data.containsKey('interest_type')) {
      context.handle(
        _interestTypeMeta,
        interestType.isAcceptableOrUnknown(
          data['interest_type']!,
          _interestTypeMeta,
        ),
      );
    }
    if (data.containsKey('interest_rate')) {
      context.handle(
        _interestRateMeta,
        interestRate.isAcceptableOrUnknown(
          data['interest_rate']!,
          _interestRateMeta,
        ),
      );
    }
    if (data.containsKey('mobile_number')) {
      context.handle(
        _mobileNumberMeta,
        mobileNumber.isAcceptableOrUnknown(
          data['mobile_number']!,
          _mobileNumberMeta,
        ),
      );
    }
    if (data.containsKey('area')) {
      context.handle(
        _areaMeta,
        area.isAcceptableOrUnknown(data['area']!, _areaMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('pin_code')) {
      context.handle(
        _pinCodeMeta,
        pinCode.isAcceptableOrUnknown(data['pin_code']!, _pinCodeMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ledger map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ledger(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      merchantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}merchant_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      partyType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_type'],
      )!,
      currentBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_balance'],
      )!,
      openingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}opening_balance'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      creditLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit_limit'],
      )!,
      creditDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_day'],
      )!,
      interestType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interest_type'],
      )!,
      interestRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interest_rate'],
      )!,
      mobileNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_number'],
      )!,
      area: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      pinCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_code'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_date'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $LedgersTable createAlias(String alias) {
    return $LedgersTable(attachedDatabase, alias);
  }
}

class Ledger extends DataClass implements Insertable<Ledger> {
  final int id;
  final int merchantId;
  final String name;
  final String partyType;
  final double currentBalance;
  final double openingBalance;
  final String transactionType;
  final double creditLimit;
  final int creditDay;
  final String interestType;
  final double interestRate;
  final String mobileNumber;
  final String area;
  final String address;
  final String pinCode;
  final bool isSynced;
  final String? localId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? transactionDate;
  final DateTime? localUpdatedAt;
  final bool isActive;
  const Ledger({
    required this.id,
    required this.merchantId,
    required this.name,
    required this.partyType,
    required this.currentBalance,
    required this.openingBalance,
    required this.transactionType,
    required this.creditLimit,
    required this.creditDay,
    required this.interestType,
    required this.interestRate,
    required this.mobileNumber,
    required this.area,
    required this.address,
    required this.pinCode,
    required this.isSynced,
    this.localId,
    this.createdAt,
    this.updatedAt,
    this.transactionDate,
    this.localUpdatedAt,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['merchant_id'] = Variable<int>(merchantId);
    map['name'] = Variable<String>(name);
    map['party_type'] = Variable<String>(partyType);
    map['current_balance'] = Variable<double>(currentBalance);
    map['opening_balance'] = Variable<double>(openingBalance);
    map['transaction_type'] = Variable<String>(transactionType);
    map['credit_limit'] = Variable<double>(creditLimit);
    map['credit_day'] = Variable<int>(creditDay);
    map['interest_type'] = Variable<String>(interestType);
    map['interest_rate'] = Variable<double>(interestRate);
    map['mobile_number'] = Variable<String>(mobileNumber);
    map['area'] = Variable<String>(area);
    map['address'] = Variable<String>(address);
    map['pin_code'] = Variable<String>(pinCode);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || localId != null) {
      map['local_id'] = Variable<String>(localId);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || transactionDate != null) {
      map['transaction_date'] = Variable<DateTime>(transactionDate);
    }
    if (!nullToAbsent || localUpdatedAt != null) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  LedgersCompanion toCompanion(bool nullToAbsent) {
    return LedgersCompanion(
      id: Value(id),
      merchantId: Value(merchantId),
      name: Value(name),
      partyType: Value(partyType),
      currentBalance: Value(currentBalance),
      openingBalance: Value(openingBalance),
      transactionType: Value(transactionType),
      creditLimit: Value(creditLimit),
      creditDay: Value(creditDay),
      interestType: Value(interestType),
      interestRate: Value(interestRate),
      mobileNumber: Value(mobileNumber),
      area: Value(area),
      address: Value(address),
      pinCode: Value(pinCode),
      isSynced: Value(isSynced),
      localId: localId == null && nullToAbsent
          ? const Value.absent()
          : Value(localId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      transactionDate: transactionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionDate),
      localUpdatedAt: localUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(localUpdatedAt),
      isActive: Value(isActive),
    );
  }

  factory Ledger.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ledger(
      id: serializer.fromJson<int>(json['id']),
      merchantId: serializer.fromJson<int>(json['merchantId']),
      name: serializer.fromJson<String>(json['name']),
      partyType: serializer.fromJson<String>(json['partyType']),
      currentBalance: serializer.fromJson<double>(json['currentBalance']),
      openingBalance: serializer.fromJson<double>(json['openingBalance']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      creditLimit: serializer.fromJson<double>(json['creditLimit']),
      creditDay: serializer.fromJson<int>(json['creditDay']),
      interestType: serializer.fromJson<String>(json['interestType']),
      interestRate: serializer.fromJson<double>(json['interestRate']),
      mobileNumber: serializer.fromJson<String>(json['mobileNumber']),
      area: serializer.fromJson<String>(json['area']),
      address: serializer.fromJson<String>(json['address']),
      pinCode: serializer.fromJson<String>(json['pinCode']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      localId: serializer.fromJson<String?>(json['localId']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      transactionDate: serializer.fromJson<DateTime?>(json['transactionDate']),
      localUpdatedAt: serializer.fromJson<DateTime?>(json['localUpdatedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'merchantId': serializer.toJson<int>(merchantId),
      'name': serializer.toJson<String>(name),
      'partyType': serializer.toJson<String>(partyType),
      'currentBalance': serializer.toJson<double>(currentBalance),
      'openingBalance': serializer.toJson<double>(openingBalance),
      'transactionType': serializer.toJson<String>(transactionType),
      'creditLimit': serializer.toJson<double>(creditLimit),
      'creditDay': serializer.toJson<int>(creditDay),
      'interestType': serializer.toJson<String>(interestType),
      'interestRate': serializer.toJson<double>(interestRate),
      'mobileNumber': serializer.toJson<String>(mobileNumber),
      'area': serializer.toJson<String>(area),
      'address': serializer.toJson<String>(address),
      'pinCode': serializer.toJson<String>(pinCode),
      'isSynced': serializer.toJson<bool>(isSynced),
      'localId': serializer.toJson<String?>(localId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'transactionDate': serializer.toJson<DateTime?>(transactionDate),
      'localUpdatedAt': serializer.toJson<DateTime?>(localUpdatedAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Ledger copyWith({
    int? id,
    int? merchantId,
    String? name,
    String? partyType,
    double? currentBalance,
    double? openingBalance,
    String? transactionType,
    double? creditLimit,
    int? creditDay,
    String? interestType,
    double? interestRate,
    String? mobileNumber,
    String? area,
    String? address,
    String? pinCode,
    bool? isSynced,
    Value<String?> localId = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> transactionDate = const Value.absent(),
    Value<DateTime?> localUpdatedAt = const Value.absent(),
    bool? isActive,
  }) => Ledger(
    id: id ?? this.id,
    merchantId: merchantId ?? this.merchantId,
    name: name ?? this.name,
    partyType: partyType ?? this.partyType,
    currentBalance: currentBalance ?? this.currentBalance,
    openingBalance: openingBalance ?? this.openingBalance,
    transactionType: transactionType ?? this.transactionType,
    creditLimit: creditLimit ?? this.creditLimit,
    creditDay: creditDay ?? this.creditDay,
    interestType: interestType ?? this.interestType,
    interestRate: interestRate ?? this.interestRate,
    mobileNumber: mobileNumber ?? this.mobileNumber,
    area: area ?? this.area,
    address: address ?? this.address,
    pinCode: pinCode ?? this.pinCode,
    isSynced: isSynced ?? this.isSynced,
    localId: localId.present ? localId.value : this.localId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    transactionDate: transactionDate.present
        ? transactionDate.value
        : this.transactionDate,
    localUpdatedAt: localUpdatedAt.present
        ? localUpdatedAt.value
        : this.localUpdatedAt,
    isActive: isActive ?? this.isActive,
  );
  Ledger copyWithCompanion(LedgersCompanion data) {
    return Ledger(
      id: data.id.present ? data.id.value : this.id,
      merchantId: data.merchantId.present
          ? data.merchantId.value
          : this.merchantId,
      name: data.name.present ? data.name.value : this.name,
      partyType: data.partyType.present ? data.partyType.value : this.partyType,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      creditLimit: data.creditLimit.present
          ? data.creditLimit.value
          : this.creditLimit,
      creditDay: data.creditDay.present ? data.creditDay.value : this.creditDay,
      interestType: data.interestType.present
          ? data.interestType.value
          : this.interestType,
      interestRate: data.interestRate.present
          ? data.interestRate.value
          : this.interestRate,
      mobileNumber: data.mobileNumber.present
          ? data.mobileNumber.value
          : this.mobileNumber,
      area: data.area.present ? data.area.value : this.area,
      address: data.address.present ? data.address.value : this.address,
      pinCode: data.pinCode.present ? data.pinCode.value : this.pinCode,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      localId: data.localId.present ? data.localId.value : this.localId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ledger(')
          ..write('id: $id, ')
          ..write('merchantId: $merchantId, ')
          ..write('name: $name, ')
          ..write('partyType: $partyType, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('transactionType: $transactionType, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('creditDay: $creditDay, ')
          ..write('interestType: $interestType, ')
          ..write('interestRate: $interestRate, ')
          ..write('mobileNumber: $mobileNumber, ')
          ..write('area: $area, ')
          ..write('address: $address, ')
          ..write('pinCode: $pinCode, ')
          ..write('isSynced: $isSynced, ')
          ..write('localId: $localId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    merchantId,
    name,
    partyType,
    currentBalance,
    openingBalance,
    transactionType,
    creditLimit,
    creditDay,
    interestType,
    interestRate,
    mobileNumber,
    area,
    address,
    pinCode,
    isSynced,
    localId,
    createdAt,
    updatedAt,
    transactionDate,
    localUpdatedAt,
    isActive,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ledger &&
          other.id == this.id &&
          other.merchantId == this.merchantId &&
          other.name == this.name &&
          other.partyType == this.partyType &&
          other.currentBalance == this.currentBalance &&
          other.openingBalance == this.openingBalance &&
          other.transactionType == this.transactionType &&
          other.creditLimit == this.creditLimit &&
          other.creditDay == this.creditDay &&
          other.interestType == this.interestType &&
          other.interestRate == this.interestRate &&
          other.mobileNumber == this.mobileNumber &&
          other.area == this.area &&
          other.address == this.address &&
          other.pinCode == this.pinCode &&
          other.isSynced == this.isSynced &&
          other.localId == this.localId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.transactionDate == this.transactionDate &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.isActive == this.isActive);
}

class LedgersCompanion extends UpdateCompanion<Ledger> {
  final Value<int> id;
  final Value<int> merchantId;
  final Value<String> name;
  final Value<String> partyType;
  final Value<double> currentBalance;
  final Value<double> openingBalance;
  final Value<String> transactionType;
  final Value<double> creditLimit;
  final Value<int> creditDay;
  final Value<String> interestType;
  final Value<double> interestRate;
  final Value<String> mobileNumber;
  final Value<String> area;
  final Value<String> address;
  final Value<String> pinCode;
  final Value<bool> isSynced;
  final Value<String?> localId;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> transactionDate;
  final Value<DateTime?> localUpdatedAt;
  final Value<bool> isActive;
  const LedgersCompanion({
    this.id = const Value.absent(),
    this.merchantId = const Value.absent(),
    this.name = const Value.absent(),
    this.partyType = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.creditDay = const Value.absent(),
    this.interestType = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.mobileNumber = const Value.absent(),
    this.area = const Value.absent(),
    this.address = const Value.absent(),
    this.pinCode = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.localId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  LedgersCompanion.insert({
    this.id = const Value.absent(),
    required int merchantId,
    required String name,
    this.partyType = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.creditDay = const Value.absent(),
    this.interestType = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.mobileNumber = const Value.absent(),
    this.area = const Value.absent(),
    this.address = const Value.absent(),
    this.pinCode = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.localId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : merchantId = Value(merchantId),
       name = Value(name);
  static Insertable<Ledger> custom({
    Expression<int>? id,
    Expression<int>? merchantId,
    Expression<String>? name,
    Expression<String>? partyType,
    Expression<double>? currentBalance,
    Expression<double>? openingBalance,
    Expression<String>? transactionType,
    Expression<double>? creditLimit,
    Expression<int>? creditDay,
    Expression<String>? interestType,
    Expression<double>? interestRate,
    Expression<String>? mobileNumber,
    Expression<String>? area,
    Expression<String>? address,
    Expression<String>? pinCode,
    Expression<bool>? isSynced,
    Expression<String>? localId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? transactionDate,
    Expression<DateTime>? localUpdatedAt,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (merchantId != null) 'merchant_id': merchantId,
      if (name != null) 'name': name,
      if (partyType != null) 'party_type': partyType,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (transactionType != null) 'transaction_type': transactionType,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (creditDay != null) 'credit_day': creditDay,
      if (interestType != null) 'interest_type': interestType,
      if (interestRate != null) 'interest_rate': interestRate,
      if (mobileNumber != null) 'mobile_number': mobileNumber,
      if (area != null) 'area': area,
      if (address != null) 'address': address,
      if (pinCode != null) 'pin_code': pinCode,
      if (isSynced != null) 'is_synced': isSynced,
      if (localId != null) 'local_id': localId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (isActive != null) 'is_active': isActive,
    });
  }

  LedgersCompanion copyWith({
    Value<int>? id,
    Value<int>? merchantId,
    Value<String>? name,
    Value<String>? partyType,
    Value<double>? currentBalance,
    Value<double>? openingBalance,
    Value<String>? transactionType,
    Value<double>? creditLimit,
    Value<int>? creditDay,
    Value<String>? interestType,
    Value<double>? interestRate,
    Value<String>? mobileNumber,
    Value<String>? area,
    Value<String>? address,
    Value<String>? pinCode,
    Value<bool>? isSynced,
    Value<String?>? localId,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? transactionDate,
    Value<DateTime?>? localUpdatedAt,
    Value<bool>? isActive,
  }) {
    return LedgersCompanion(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      name: name ?? this.name,
      partyType: partyType ?? this.partyType,
      currentBalance: currentBalance ?? this.currentBalance,
      openingBalance: openingBalance ?? this.openingBalance,
      transactionType: transactionType ?? this.transactionType,
      creditLimit: creditLimit ?? this.creditLimit,
      creditDay: creditDay ?? this.creditDay,
      interestType: interestType ?? this.interestType,
      interestRate: interestRate ?? this.interestRate,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      area: area ?? this.area,
      address: address ?? this.address,
      pinCode: pinCode ?? this.pinCode,
      isSynced: isSynced ?? this.isSynced,
      localId: localId ?? this.localId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactionDate: transactionDate ?? this.transactionDate,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (merchantId.present) {
      map['merchant_id'] = Variable<int>(merchantId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (partyType.present) {
      map['party_type'] = Variable<String>(partyType.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<double>(currentBalance.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<double>(openingBalance.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (creditDay.present) {
      map['credit_day'] = Variable<int>(creditDay.value);
    }
    if (interestType.present) {
      map['interest_type'] = Variable<String>(interestType.value);
    }
    if (interestRate.present) {
      map['interest_rate'] = Variable<double>(interestRate.value);
    }
    if (mobileNumber.present) {
      map['mobile_number'] = Variable<String>(mobileNumber.value);
    }
    if (area.present) {
      map['area'] = Variable<String>(area.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (pinCode.present) {
      map['pin_code'] = Variable<String>(pinCode.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgersCompanion(')
          ..write('id: $id, ')
          ..write('merchantId: $merchantId, ')
          ..write('name: $name, ')
          ..write('partyType: $partyType, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('transactionType: $transactionType, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('creditDay: $creditDay, ')
          ..write('interestType: $interestType, ')
          ..write('interestRate: $interestRate, ')
          ..write('mobileNumber: $mobileNumber, ')
          ..write('area: $area, ')
          ..write('address: $address, ')
          ..write('pinCode: $pinCode, ')
          ..write('isSynced: $isSynced, ')
          ..write('localId: $localId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ledgerIdMeta = const VerificationMeta(
    'ledgerId',
  );
  @override
  late final GeneratedColumn<int> ledgerId = GeneratedColumn<int>(
    'ledger_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantIdMeta = const VerificationMeta(
    'merchantId',
  );
  @override
  late final GeneratedColumn<int> merchantId = GeneratedColumn<int>(
    'merchant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionAmountMeta = const VerificationMeta(
    'transactionAmount',
  );
  @override
  late final GeneratedColumn<double> transactionAmount =
      GeneratedColumn<double>(
        'transaction_amount',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>(
        'transaction_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _commentsMeta = const VerificationMeta(
    'comments',
  );
  @override
  late final GeneratedColumn<String> comments = GeneratedColumn<String>(
    'comments',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partyMerchantActionMeta =
      const VerificationMeta('partyMerchantAction');
  @override
  late final GeneratedColumn<String> partyMerchantAction =
      GeneratedColumn<String>(
        'party_merchant_action',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('VIEW'),
      );
  static const VerificationMeta _uploadedKeysMeta = const VerificationMeta(
    'uploadedKeys',
  );
  @override
  late final GeneratedColumn<String> uploadedKeys = GeneratedColumn<String>(
    'uploaded_keys',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _securityKeyMeta = const VerificationMeta(
    'securityKey',
  );
  @override
  late final GeneratedColumn<String> securityKey = GeneratedColumn<String>(
    'security_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeleteMeta = const VerificationMeta(
    'isDelete',
  );
  @override
  late final GeneratedColumn<bool> isDelete = GeneratedColumn<bool>(
    'is_delete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_delete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _currentBalanceMeta = const VerificationMeta(
    'currentBalance',
  );
  @override
  late final GeneratedColumn<double> currentBalance = GeneratedColumn<double>(
    'current_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lastBalanceMeta = const VerificationMeta(
    'lastBalance',
  );
  @override
  late final GeneratedColumn<double> lastBalance = GeneratedColumn<double>(
    'last_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    ledgerId,
    merchantId,
    transactionAmount,
    transactionType,
    transactionDate,
    comments,
    partyMerchantAction,
    uploadedKeys,
    securityKey,
    isSynced,
    localId,
    createdAt,
    updatedAt,
    isDelete,
    currentBalance,
    lastBalance,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('ledger_id')) {
      context.handle(
        _ledgerIdMeta,
        ledgerId.isAcceptableOrUnknown(data['ledger_id']!, _ledgerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ledgerIdMeta);
    }
    if (data.containsKey('merchant_id')) {
      context.handle(
        _merchantIdMeta,
        merchantId.isAcceptableOrUnknown(data['merchant_id']!, _merchantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_merchantIdMeta);
    }
    if (data.containsKey('transaction_amount')) {
      context.handle(
        _transactionAmountMeta,
        transactionAmount.isAcceptableOrUnknown(
          data['transaction_amount']!,
          _transactionAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionAmountMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('comments')) {
      context.handle(
        _commentsMeta,
        comments.isAcceptableOrUnknown(data['comments']!, _commentsMeta),
      );
    }
    if (data.containsKey('party_merchant_action')) {
      context.handle(
        _partyMerchantActionMeta,
        partyMerchantAction.isAcceptableOrUnknown(
          data['party_merchant_action']!,
          _partyMerchantActionMeta,
        ),
      );
    }
    if (data.containsKey('uploaded_keys')) {
      context.handle(
        _uploadedKeysMeta,
        uploadedKeys.isAcceptableOrUnknown(
          data['uploaded_keys']!,
          _uploadedKeysMeta,
        ),
      );
    }
    if (data.containsKey('security_key')) {
      context.handle(
        _securityKeyMeta,
        securityKey.isAcceptableOrUnknown(
          data['security_key']!,
          _securityKeyMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_delete')) {
      context.handle(
        _isDeleteMeta,
        isDelete.isAcceptableOrUnknown(data['is_delete']!, _isDeleteMeta),
      );
    }
    if (data.containsKey('current_balance')) {
      context.handle(
        _currentBalanceMeta,
        currentBalance.isAcceptableOrUnknown(
          data['current_balance']!,
          _currentBalanceMeta,
        ),
      );
    }
    if (data.containsKey('last_balance')) {
      context.handle(
        _lastBalanceMeta,
        lastBalance.isAcceptableOrUnknown(
          data['last_balance']!,
          _lastBalanceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      ledgerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ledger_id'],
      )!,
      merchantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}merchant_id'],
      )!,
      transactionAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}transaction_amount'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_date'],
      )!,
      comments: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comments'],
      ),
      partyMerchantAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_merchant_action'],
      )!,
      uploadedKeys: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uploaded_keys'],
      ),
      securityKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}security_key'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      isDelete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_delete'],
      )!,
      currentBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_balance'],
      )!,
      lastBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_balance'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final int? serverId;
  final int ledgerId;
  final int merchantId;
  final double transactionAmount;
  final String transactionType;
  final DateTime transactionDate;
  final String? comments;
  final String partyMerchantAction;
  final String? uploadedKeys;
  final String securityKey;
  final bool isSynced;
  final String? localId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDelete;
  final double currentBalance;
  final double lastBalance;
  const Transaction({
    required this.id,
    this.serverId,
    required this.ledgerId,
    required this.merchantId,
    required this.transactionAmount,
    required this.transactionType,
    required this.transactionDate,
    this.comments,
    required this.partyMerchantAction,
    this.uploadedKeys,
    required this.securityKey,
    required this.isSynced,
    this.localId,
    this.createdAt,
    this.updatedAt,
    required this.isDelete,
    required this.currentBalance,
    required this.lastBalance,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['ledger_id'] = Variable<int>(ledgerId);
    map['merchant_id'] = Variable<int>(merchantId);
    map['transaction_amount'] = Variable<double>(transactionAmount);
    map['transaction_type'] = Variable<String>(transactionType);
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    if (!nullToAbsent || comments != null) {
      map['comments'] = Variable<String>(comments);
    }
    map['party_merchant_action'] = Variable<String>(partyMerchantAction);
    if (!nullToAbsent || uploadedKeys != null) {
      map['uploaded_keys'] = Variable<String>(uploadedKeys);
    }
    map['security_key'] = Variable<String>(securityKey);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || localId != null) {
      map['local_id'] = Variable<String>(localId);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_delete'] = Variable<bool>(isDelete);
    map['current_balance'] = Variable<double>(currentBalance);
    map['last_balance'] = Variable<double>(lastBalance);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      ledgerId: Value(ledgerId),
      merchantId: Value(merchantId),
      transactionAmount: Value(transactionAmount),
      transactionType: Value(transactionType),
      transactionDate: Value(transactionDate),
      comments: comments == null && nullToAbsent
          ? const Value.absent()
          : Value(comments),
      partyMerchantAction: Value(partyMerchantAction),
      uploadedKeys: uploadedKeys == null && nullToAbsent
          ? const Value.absent()
          : Value(uploadedKeys),
      securityKey: Value(securityKey),
      isSynced: Value(isSynced),
      localId: localId == null && nullToAbsent
          ? const Value.absent()
          : Value(localId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isDelete: Value(isDelete),
      currentBalance: Value(currentBalance),
      lastBalance: Value(lastBalance),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      ledgerId: serializer.fromJson<int>(json['ledgerId']),
      merchantId: serializer.fromJson<int>(json['merchantId']),
      transactionAmount: serializer.fromJson<double>(json['transactionAmount']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      comments: serializer.fromJson<String?>(json['comments']),
      partyMerchantAction: serializer.fromJson<String>(
        json['partyMerchantAction'],
      ),
      uploadedKeys: serializer.fromJson<String?>(json['uploadedKeys']),
      securityKey: serializer.fromJson<String>(json['securityKey']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      localId: serializer.fromJson<String?>(json['localId']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isDelete: serializer.fromJson<bool>(json['isDelete']),
      currentBalance: serializer.fromJson<double>(json['currentBalance']),
      lastBalance: serializer.fromJson<double>(json['lastBalance']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'ledgerId': serializer.toJson<int>(ledgerId),
      'merchantId': serializer.toJson<int>(merchantId),
      'transactionAmount': serializer.toJson<double>(transactionAmount),
      'transactionType': serializer.toJson<String>(transactionType),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'comments': serializer.toJson<String?>(comments),
      'partyMerchantAction': serializer.toJson<String>(partyMerchantAction),
      'uploadedKeys': serializer.toJson<String?>(uploadedKeys),
      'securityKey': serializer.toJson<String>(securityKey),
      'isSynced': serializer.toJson<bool>(isSynced),
      'localId': serializer.toJson<String?>(localId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isDelete': serializer.toJson<bool>(isDelete),
      'currentBalance': serializer.toJson<double>(currentBalance),
      'lastBalance': serializer.toJson<double>(lastBalance),
    };
  }

  Transaction copyWith({
    int? id,
    Value<int?> serverId = const Value.absent(),
    int? ledgerId,
    int? merchantId,
    double? transactionAmount,
    String? transactionType,
    DateTime? transactionDate,
    Value<String?> comments = const Value.absent(),
    String? partyMerchantAction,
    Value<String?> uploadedKeys = const Value.absent(),
    String? securityKey,
    bool? isSynced,
    Value<String?> localId = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    bool? isDelete,
    double? currentBalance,
    double? lastBalance,
  }) => Transaction(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    ledgerId: ledgerId ?? this.ledgerId,
    merchantId: merchantId ?? this.merchantId,
    transactionAmount: transactionAmount ?? this.transactionAmount,
    transactionType: transactionType ?? this.transactionType,
    transactionDate: transactionDate ?? this.transactionDate,
    comments: comments.present ? comments.value : this.comments,
    partyMerchantAction: partyMerchantAction ?? this.partyMerchantAction,
    uploadedKeys: uploadedKeys.present ? uploadedKeys.value : this.uploadedKeys,
    securityKey: securityKey ?? this.securityKey,
    isSynced: isSynced ?? this.isSynced,
    localId: localId.present ? localId.value : this.localId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    isDelete: isDelete ?? this.isDelete,
    currentBalance: currentBalance ?? this.currentBalance,
    lastBalance: lastBalance ?? this.lastBalance,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      ledgerId: data.ledgerId.present ? data.ledgerId.value : this.ledgerId,
      merchantId: data.merchantId.present
          ? data.merchantId.value
          : this.merchantId,
      transactionAmount: data.transactionAmount.present
          ? data.transactionAmount.value
          : this.transactionAmount,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      comments: data.comments.present ? data.comments.value : this.comments,
      partyMerchantAction: data.partyMerchantAction.present
          ? data.partyMerchantAction.value
          : this.partyMerchantAction,
      uploadedKeys: data.uploadedKeys.present
          ? data.uploadedKeys.value
          : this.uploadedKeys,
      securityKey: data.securityKey.present
          ? data.securityKey.value
          : this.securityKey,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      localId: data.localId.present ? data.localId.value : this.localId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDelete: data.isDelete.present ? data.isDelete.value : this.isDelete,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      lastBalance: data.lastBalance.present
          ? data.lastBalance.value
          : this.lastBalance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('merchantId: $merchantId, ')
          ..write('transactionAmount: $transactionAmount, ')
          ..write('transactionType: $transactionType, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('comments: $comments, ')
          ..write('partyMerchantAction: $partyMerchantAction, ')
          ..write('uploadedKeys: $uploadedKeys, ')
          ..write('securityKey: $securityKey, ')
          ..write('isSynced: $isSynced, ')
          ..write('localId: $localId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDelete: $isDelete, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('lastBalance: $lastBalance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    ledgerId,
    merchantId,
    transactionAmount,
    transactionType,
    transactionDate,
    comments,
    partyMerchantAction,
    uploadedKeys,
    securityKey,
    isSynced,
    localId,
    createdAt,
    updatedAt,
    isDelete,
    currentBalance,
    lastBalance,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.ledgerId == this.ledgerId &&
          other.merchantId == this.merchantId &&
          other.transactionAmount == this.transactionAmount &&
          other.transactionType == this.transactionType &&
          other.transactionDate == this.transactionDate &&
          other.comments == this.comments &&
          other.partyMerchantAction == this.partyMerchantAction &&
          other.uploadedKeys == this.uploadedKeys &&
          other.securityKey == this.securityKey &&
          other.isSynced == this.isSynced &&
          other.localId == this.localId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDelete == this.isDelete &&
          other.currentBalance == this.currentBalance &&
          other.lastBalance == this.lastBalance);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<int?> serverId;
  final Value<int> ledgerId;
  final Value<int> merchantId;
  final Value<double> transactionAmount;
  final Value<String> transactionType;
  final Value<DateTime> transactionDate;
  final Value<String?> comments;
  final Value<String> partyMerchantAction;
  final Value<String?> uploadedKeys;
  final Value<String> securityKey;
  final Value<bool> isSynced;
  final Value<String?> localId;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isDelete;
  final Value<double> currentBalance;
  final Value<double> lastBalance;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.ledgerId = const Value.absent(),
    this.merchantId = const Value.absent(),
    this.transactionAmount = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.comments = const Value.absent(),
    this.partyMerchantAction = const Value.absent(),
    this.uploadedKeys = const Value.absent(),
    this.securityKey = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.localId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDelete = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.lastBalance = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required int ledgerId,
    required int merchantId,
    required double transactionAmount,
    required String transactionType,
    required DateTime transactionDate,
    this.comments = const Value.absent(),
    this.partyMerchantAction = const Value.absent(),
    this.uploadedKeys = const Value.absent(),
    this.securityKey = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.localId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDelete = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.lastBalance = const Value.absent(),
  }) : ledgerId = Value(ledgerId),
       merchantId = Value(merchantId),
       transactionAmount = Value(transactionAmount),
       transactionType = Value(transactionType),
       transactionDate = Value(transactionDate);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<int>? serverId,
    Expression<int>? ledgerId,
    Expression<int>? merchantId,
    Expression<double>? transactionAmount,
    Expression<String>? transactionType,
    Expression<DateTime>? transactionDate,
    Expression<String>? comments,
    Expression<String>? partyMerchantAction,
    Expression<String>? uploadedKeys,
    Expression<String>? securityKey,
    Expression<bool>? isSynced,
    Expression<String>? localId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDelete,
    Expression<double>? currentBalance,
    Expression<double>? lastBalance,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (ledgerId != null) 'ledger_id': ledgerId,
      if (merchantId != null) 'merchant_id': merchantId,
      if (transactionAmount != null) 'transaction_amount': transactionAmount,
      if (transactionType != null) 'transaction_type': transactionType,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (comments != null) 'comments': comments,
      if (partyMerchantAction != null)
        'party_merchant_action': partyMerchantAction,
      if (uploadedKeys != null) 'uploaded_keys': uploadedKeys,
      if (securityKey != null) 'security_key': securityKey,
      if (isSynced != null) 'is_synced': isSynced,
      if (localId != null) 'local_id': localId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDelete != null) 'is_delete': isDelete,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (lastBalance != null) 'last_balance': lastBalance,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? serverId,
    Value<int>? ledgerId,
    Value<int>? merchantId,
    Value<double>? transactionAmount,
    Value<String>? transactionType,
    Value<DateTime>? transactionDate,
    Value<String?>? comments,
    Value<String>? partyMerchantAction,
    Value<String?>? uploadedKeys,
    Value<String>? securityKey,
    Value<bool>? isSynced,
    Value<String?>? localId,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<bool>? isDelete,
    Value<double>? currentBalance,
    Value<double>? lastBalance,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      ledgerId: ledgerId ?? this.ledgerId,
      merchantId: merchantId ?? this.merchantId,
      transactionAmount: transactionAmount ?? this.transactionAmount,
      transactionType: transactionType ?? this.transactionType,
      transactionDate: transactionDate ?? this.transactionDate,
      comments: comments ?? this.comments,
      partyMerchantAction: partyMerchantAction ?? this.partyMerchantAction,
      uploadedKeys: uploadedKeys ?? this.uploadedKeys,
      securityKey: securityKey ?? this.securityKey,
      isSynced: isSynced ?? this.isSynced,
      localId: localId ?? this.localId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDelete: isDelete ?? this.isDelete,
      currentBalance: currentBalance ?? this.currentBalance,
      lastBalance: lastBalance ?? this.lastBalance,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (ledgerId.present) {
      map['ledger_id'] = Variable<int>(ledgerId.value);
    }
    if (merchantId.present) {
      map['merchant_id'] = Variable<int>(merchantId.value);
    }
    if (transactionAmount.present) {
      map['transaction_amount'] = Variable<double>(transactionAmount.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (comments.present) {
      map['comments'] = Variable<String>(comments.value);
    }
    if (partyMerchantAction.present) {
      map['party_merchant_action'] = Variable<String>(
        partyMerchantAction.value,
      );
    }
    if (uploadedKeys.present) {
      map['uploaded_keys'] = Variable<String>(uploadedKeys.value);
    }
    if (securityKey.present) {
      map['security_key'] = Variable<String>(securityKey.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDelete.present) {
      map['is_delete'] = Variable<bool>(isDelete.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<double>(currentBalance.value);
    }
    if (lastBalance.present) {
      map['last_balance'] = Variable<double>(lastBalance.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('merchantId: $merchantId, ')
          ..write('transactionAmount: $transactionAmount, ')
          ..write('transactionType: $transactionType, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('comments: $comments, ')
          ..write('partyMerchantAction: $partyMerchantAction, ')
          ..write('uploadedKeys: $uploadedKeys, ')
          ..write('securityKey: $securityKey, ')
          ..write('isSynced: $isSynced, ')
          ..write('localId: $localId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDelete: $isDelete, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('lastBalance: $lastBalance')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<int> recordId = GeneratedColumn<int>(
    'record_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endpointMeta = const VerificationMeta(
    'endpoint',
  );
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
    'endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('POST'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAttemptMeta = const VerificationMeta(
    'lastAttempt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttempt = GeneratedColumn<DateTime>(
    'last_attempt',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetTable,
    recordId,
    localId,
    action,
    payload,
    endpoint,
    method,
    status,
    retryCount,
    lastError,
    lastAttempt,
    createdAt,
    priority,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    }
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('endpoint')) {
      context.handle(
        _endpointMeta,
        endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta),
      );
    } else if (isInserting) {
      context.missing(_endpointMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('last_attempt')) {
      context.handle(
        _lastAttemptMeta,
        lastAttempt.isAcceptableOrUnknown(
          data['last_attempt']!,
          _lastAttemptMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}record_id'],
      ),
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      endpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      lastAttempt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String targetTable;
  final int? recordId;
  final String? localId;
  final String action;
  final String payload;
  final String endpoint;
  final String method;
  final String status;
  final int retryCount;
  final String? lastError;
  final DateTime? lastAttempt;
  final DateTime createdAt;
  final int priority;
  const SyncQueueData({
    required this.id,
    required this.targetTable,
    this.recordId,
    this.localId,
    required this.action,
    required this.payload,
    required this.endpoint,
    required this.method,
    required this.status,
    required this.retryCount,
    this.lastError,
    this.lastAttempt,
    required this.createdAt,
    required this.priority,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['target_table'] = Variable<String>(targetTable);
    if (!nullToAbsent || recordId != null) {
      map['record_id'] = Variable<int>(recordId);
    }
    if (!nullToAbsent || localId != null) {
      map['local_id'] = Variable<String>(localId);
    }
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['endpoint'] = Variable<String>(endpoint);
    map['method'] = Variable<String>(method);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || lastAttempt != null) {
      map['last_attempt'] = Variable<DateTime>(lastAttempt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['priority'] = Variable<int>(priority);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      targetTable: Value(targetTable),
      recordId: recordId == null && nullToAbsent
          ? const Value.absent()
          : Value(recordId),
      localId: localId == null && nullToAbsent
          ? const Value.absent()
          : Value(localId),
      action: Value(action),
      payload: Value(payload),
      endpoint: Value(endpoint),
      method: Value(method),
      status: Value(status),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      lastAttempt: lastAttempt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttempt),
      createdAt: Value(createdAt),
      priority: Value(priority),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      recordId: serializer.fromJson<int?>(json['recordId']),
      localId: serializer.fromJson<String?>(json['localId']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      endpoint: serializer.fromJson<String>(json['endpoint']),
      method: serializer.fromJson<String>(json['method']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      lastAttempt: serializer.fromJson<DateTime?>(json['lastAttempt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      priority: serializer.fromJson<int>(json['priority']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'targetTable': serializer.toJson<String>(targetTable),
      'recordId': serializer.toJson<int?>(recordId),
      'localId': serializer.toJson<String?>(localId),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'endpoint': serializer.toJson<String>(endpoint),
      'method': serializer.toJson<String>(method),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'lastAttempt': serializer.toJson<DateTime?>(lastAttempt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'priority': serializer.toJson<int>(priority),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? targetTable,
    Value<int?> recordId = const Value.absent(),
    Value<String?> localId = const Value.absent(),
    String? action,
    String? payload,
    String? endpoint,
    String? method,
    String? status,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    Value<DateTime?> lastAttempt = const Value.absent(),
    DateTime? createdAt,
    int? priority,
  }) => SyncQueueData(
    id: id ?? this.id,
    targetTable: targetTable ?? this.targetTable,
    recordId: recordId.present ? recordId.value : this.recordId,
    localId: localId.present ? localId.value : this.localId,
    action: action ?? this.action,
    payload: payload ?? this.payload,
    endpoint: endpoint ?? this.endpoint,
    method: method ?? this.method,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    lastAttempt: lastAttempt.present ? lastAttempt.value : this.lastAttempt,
    createdAt: createdAt ?? this.createdAt,
    priority: priority ?? this.priority,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      localId: data.localId.present ? data.localId.value : this.localId,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      method: data.method.present ? data.method.value : this.method,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      lastAttempt: data.lastAttempt.present
          ? data.lastAttempt.value
          : this.lastAttempt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      priority: data.priority.present ? data.priority.value : this.priority,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('recordId: $recordId, ')
          ..write('localId: $localId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('endpoint: $endpoint, ')
          ..write('method: $method, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('lastAttempt: $lastAttempt, ')
          ..write('createdAt: $createdAt, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetTable,
    recordId,
    localId,
    action,
    payload,
    endpoint,
    method,
    status,
    retryCount,
    lastError,
    lastAttempt,
    createdAt,
    priority,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.targetTable == this.targetTable &&
          other.recordId == this.recordId &&
          other.localId == this.localId &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.endpoint == this.endpoint &&
          other.method == this.method &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.lastAttempt == this.lastAttempt &&
          other.createdAt == this.createdAt &&
          other.priority == this.priority);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> targetTable;
  final Value<int?> recordId;
  final Value<String?> localId;
  final Value<String> action;
  final Value<String> payload;
  final Value<String> endpoint;
  final Value<String> method;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime?> lastAttempt;
  final Value<DateTime> createdAt;
  final Value<int> priority;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.localId = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.method = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.lastAttempt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.priority = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String targetTable,
    this.recordId = const Value.absent(),
    this.localId = const Value.absent(),
    required String action,
    required String payload,
    required String endpoint,
    this.method = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.lastAttempt = const Value.absent(),
    required DateTime createdAt,
    this.priority = const Value.absent(),
  }) : targetTable = Value(targetTable),
       action = Value(action),
       payload = Value(payload),
       endpoint = Value(endpoint),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? targetTable,
    Expression<int>? recordId,
    Expression<String>? localId,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<String>? endpoint,
    Expression<String>? method,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? lastAttempt,
    Expression<DateTime>? createdAt,
    Expression<int>? priority,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetTable != null) 'target_table': targetTable,
      if (recordId != null) 'record_id': recordId,
      if (localId != null) 'local_id': localId,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (endpoint != null) 'endpoint': endpoint,
      if (method != null) 'method': method,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (lastAttempt != null) 'last_attempt': lastAttempt,
      if (createdAt != null) 'created_at': createdAt,
      if (priority != null) 'priority': priority,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? targetTable,
    Value<int?>? recordId,
    Value<String?>? localId,
    Value<String>? action,
    Value<String>? payload,
    Value<String>? endpoint,
    Value<String>? method,
    Value<String>? status,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<DateTime?>? lastAttempt,
    Value<DateTime>? createdAt,
    Value<int>? priority,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      targetTable: targetTable ?? this.targetTable,
      recordId: recordId ?? this.recordId,
      localId: localId ?? this.localId,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<int>(recordId.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (lastAttempt.present) {
      map['last_attempt'] = Variable<DateTime>(lastAttempt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('recordId: $recordId, ')
          ..write('localId: $localId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('endpoint: $endpoint, ')
          ..write('method: $method, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('lastAttempt: $lastAttempt, ')
          ..write('createdAt: $createdAt, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LedgersTable ledgers = $LedgersTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final LedgerDao ledgerDao = LedgerDao(this as AppDatabase);
  late final TransactionDao transactionDao = TransactionDao(
    this as AppDatabase,
  );
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ledgers,
    transactions,
    syncQueue,
  ];
}

typedef $$LedgersTableCreateCompanionBuilder =
    LedgersCompanion Function({
      Value<int> id,
      required int merchantId,
      required String name,
      Value<String> partyType,
      Value<double> currentBalance,
      Value<double> openingBalance,
      Value<String> transactionType,
      Value<double> creditLimit,
      Value<int> creditDay,
      Value<String> interestType,
      Value<double> interestRate,
      Value<String> mobileNumber,
      Value<String> area,
      Value<String> address,
      Value<String> pinCode,
      Value<bool> isSynced,
      Value<String?> localId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> transactionDate,
      Value<DateTime?> localUpdatedAt,
      Value<bool> isActive,
    });
typedef $$LedgersTableUpdateCompanionBuilder =
    LedgersCompanion Function({
      Value<int> id,
      Value<int> merchantId,
      Value<String> name,
      Value<String> partyType,
      Value<double> currentBalance,
      Value<double> openingBalance,
      Value<String> transactionType,
      Value<double> creditLimit,
      Value<int> creditDay,
      Value<String> interestType,
      Value<double> interestRate,
      Value<String> mobileNumber,
      Value<String> area,
      Value<String> address,
      Value<String> pinCode,
      Value<bool> isSynced,
      Value<String?> localId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> transactionDate,
      Value<DateTime?> localUpdatedAt,
      Value<bool> isActive,
    });

class $$LedgersTableFilterComposer
    extends Composer<_$AppDatabase, $LedgersTable> {
  $$LedgersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get merchantId => $composableBuilder(
    column: $table.merchantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyType => $composableBuilder(
    column: $table.partyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditDay => $composableBuilder(
    column: $table.creditDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interestType => $composableBuilder(
    column: $table.interestType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinCode => $composableBuilder(
    column: $table.pinCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LedgersTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgersTable> {
  $$LedgersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get merchantId => $composableBuilder(
    column: $table.merchantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyType => $composableBuilder(
    column: $table.partyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditDay => $composableBuilder(
    column: $table.creditDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interestType => $composableBuilder(
    column: $table.interestType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinCode => $composableBuilder(
    column: $table.pinCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LedgersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgersTable> {
  $$LedgersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get merchantId => $composableBuilder(
    column: $table.merchantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get partyType =>
      $composableBuilder(column: $table.partyType, builder: (column) => column);

  GeneratedColumn<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get creditDay =>
      $composableBuilder(column: $table.creditDay, builder: (column) => column);

  GeneratedColumn<String> get interestType => $composableBuilder(
    column: $table.interestType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get pinCode =>
      $composableBuilder(column: $table.pinCode, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$LedgersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LedgersTable,
          Ledger,
          $$LedgersTableFilterComposer,
          $$LedgersTableOrderingComposer,
          $$LedgersTableAnnotationComposer,
          $$LedgersTableCreateCompanionBuilder,
          $$LedgersTableUpdateCompanionBuilder,
          (Ledger, BaseReferences<_$AppDatabase, $LedgersTable, Ledger>),
          Ledger,
          PrefetchHooks Function()
        > {
  $$LedgersTableTableManager(_$AppDatabase db, $LedgersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> merchantId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> partyType = const Value.absent(),
                Value<double> currentBalance = const Value.absent(),
                Value<double> openingBalance = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<double> creditLimit = const Value.absent(),
                Value<int> creditDay = const Value.absent(),
                Value<String> interestType = const Value.absent(),
                Value<double> interestRate = const Value.absent(),
                Value<String> mobileNumber = const Value.absent(),
                Value<String> area = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> pinCode = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> localId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> transactionDate = const Value.absent(),
                Value<DateTime?> localUpdatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => LedgersCompanion(
                id: id,
                merchantId: merchantId,
                name: name,
                partyType: partyType,
                currentBalance: currentBalance,
                openingBalance: openingBalance,
                transactionType: transactionType,
                creditLimit: creditLimit,
                creditDay: creditDay,
                interestType: interestType,
                interestRate: interestRate,
                mobileNumber: mobileNumber,
                area: area,
                address: address,
                pinCode: pinCode,
                isSynced: isSynced,
                localId: localId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                transactionDate: transactionDate,
                localUpdatedAt: localUpdatedAt,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int merchantId,
                required String name,
                Value<String> partyType = const Value.absent(),
                Value<double> currentBalance = const Value.absent(),
                Value<double> openingBalance = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<double> creditLimit = const Value.absent(),
                Value<int> creditDay = const Value.absent(),
                Value<String> interestType = const Value.absent(),
                Value<double> interestRate = const Value.absent(),
                Value<String> mobileNumber = const Value.absent(),
                Value<String> area = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> pinCode = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> localId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> transactionDate = const Value.absent(),
                Value<DateTime?> localUpdatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => LedgersCompanion.insert(
                id: id,
                merchantId: merchantId,
                name: name,
                partyType: partyType,
                currentBalance: currentBalance,
                openingBalance: openingBalance,
                transactionType: transactionType,
                creditLimit: creditLimit,
                creditDay: creditDay,
                interestType: interestType,
                interestRate: interestRate,
                mobileNumber: mobileNumber,
                area: area,
                address: address,
                pinCode: pinCode,
                isSynced: isSynced,
                localId: localId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                transactionDate: transactionDate,
                localUpdatedAt: localUpdatedAt,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LedgersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LedgersTable,
      Ledger,
      $$LedgersTableFilterComposer,
      $$LedgersTableOrderingComposer,
      $$LedgersTableAnnotationComposer,
      $$LedgersTableCreateCompanionBuilder,
      $$LedgersTableUpdateCompanionBuilder,
      (Ledger, BaseReferences<_$AppDatabase, $LedgersTable, Ledger>),
      Ledger,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      required int ledgerId,
      required int merchantId,
      required double transactionAmount,
      required String transactionType,
      required DateTime transactionDate,
      Value<String?> comments,
      Value<String> partyMerchantAction,
      Value<String?> uploadedKeys,
      Value<String> securityKey,
      Value<bool> isSynced,
      Value<String?> localId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<bool> isDelete,
      Value<double> currentBalance,
      Value<double> lastBalance,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      Value<int> ledgerId,
      Value<int> merchantId,
      Value<double> transactionAmount,
      Value<String> transactionType,
      Value<DateTime> transactionDate,
      Value<String?> comments,
      Value<String> partyMerchantAction,
      Value<String?> uploadedKeys,
      Value<String> securityKey,
      Value<bool> isSynced,
      Value<String?> localId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<bool> isDelete,
      Value<double> currentBalance,
      Value<double> lastBalance,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ledgerId => $composableBuilder(
    column: $table.ledgerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get merchantId => $composableBuilder(
    column: $table.merchantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get transactionAmount => $composableBuilder(
    column: $table.transactionAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comments => $composableBuilder(
    column: $table.comments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyMerchantAction => $composableBuilder(
    column: $table.partyMerchantAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uploadedKeys => $composableBuilder(
    column: $table.uploadedKeys,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get securityKey => $composableBuilder(
    column: $table.securityKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDelete => $composableBuilder(
    column: $table.isDelete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastBalance => $composableBuilder(
    column: $table.lastBalance,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ledgerId => $composableBuilder(
    column: $table.ledgerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get merchantId => $composableBuilder(
    column: $table.merchantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get transactionAmount => $composableBuilder(
    column: $table.transactionAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comments => $composableBuilder(
    column: $table.comments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyMerchantAction => $composableBuilder(
    column: $table.partyMerchantAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploadedKeys => $composableBuilder(
    column: $table.uploadedKeys,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get securityKey => $composableBuilder(
    column: $table.securityKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDelete => $composableBuilder(
    column: $table.isDelete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastBalance => $composableBuilder(
    column: $table.lastBalance,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get ledgerId =>
      $composableBuilder(column: $table.ledgerId, builder: (column) => column);

  GeneratedColumn<int> get merchantId => $composableBuilder(
    column: $table.merchantId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get transactionAmount => $composableBuilder(
    column: $table.transactionAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comments =>
      $composableBuilder(column: $table.comments, builder: (column) => column);

  GeneratedColumn<String> get partyMerchantAction => $composableBuilder(
    column: $table.partyMerchantAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uploadedKeys => $composableBuilder(
    column: $table.uploadedKeys,
    builder: (column) => column,
  );

  GeneratedColumn<String> get securityKey => $composableBuilder(
    column: $table.securityKey,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDelete =>
      $composableBuilder(column: $table.isDelete, builder: (column) => column);

  GeneratedColumn<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastBalance => $composableBuilder(
    column: $table.lastBalance,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<int> ledgerId = const Value.absent(),
                Value<int> merchantId = const Value.absent(),
                Value<double> transactionAmount = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<DateTime> transactionDate = const Value.absent(),
                Value<String?> comments = const Value.absent(),
                Value<String> partyMerchantAction = const Value.absent(),
                Value<String?> uploadedKeys = const Value.absent(),
                Value<String> securityKey = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> localId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool> isDelete = const Value.absent(),
                Value<double> currentBalance = const Value.absent(),
                Value<double> lastBalance = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                serverId: serverId,
                ledgerId: ledgerId,
                merchantId: merchantId,
                transactionAmount: transactionAmount,
                transactionType: transactionType,
                transactionDate: transactionDate,
                comments: comments,
                partyMerchantAction: partyMerchantAction,
                uploadedKeys: uploadedKeys,
                securityKey: securityKey,
                isSynced: isSynced,
                localId: localId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDelete: isDelete,
                currentBalance: currentBalance,
                lastBalance: lastBalance,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required int ledgerId,
                required int merchantId,
                required double transactionAmount,
                required String transactionType,
                required DateTime transactionDate,
                Value<String?> comments = const Value.absent(),
                Value<String> partyMerchantAction = const Value.absent(),
                Value<String?> uploadedKeys = const Value.absent(),
                Value<String> securityKey = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> localId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool> isDelete = const Value.absent(),
                Value<double> currentBalance = const Value.absent(),
                Value<double> lastBalance = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                serverId: serverId,
                ledgerId: ledgerId,
                merchantId: merchantId,
                transactionAmount: transactionAmount,
                transactionType: transactionType,
                transactionDate: transactionDate,
                comments: comments,
                partyMerchantAction: partyMerchantAction,
                uploadedKeys: uploadedKeys,
                securityKey: securityKey,
                isSynced: isSynced,
                localId: localId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDelete: isDelete,
                currentBalance: currentBalance,
                lastBalance: lastBalance,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        Transaction,
        BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
      ),
      Transaction,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String targetTable,
      Value<int?> recordId,
      Value<String?> localId,
      required String action,
      required String payload,
      required String endpoint,
      Value<String> method,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<DateTime?> lastAttempt,
      required DateTime createdAt,
      Value<int> priority,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> targetTable,
      Value<int?> recordId,
      Value<String?> localId,
      Value<String> action,
      Value<String> payload,
      Value<String> endpoint,
      Value<String> method,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<DateTime?> lastAttempt,
      Value<DateTime> createdAt,
      Value<int> priority,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<int?> recordId = const Value.absent(),
                Value<String?> localId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> endpoint = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> lastAttempt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> priority = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                targetTable: targetTable,
                recordId: recordId,
                localId: localId,
                action: action,
                payload: payload,
                endpoint: endpoint,
                method: method,
                status: status,
                retryCount: retryCount,
                lastError: lastError,
                lastAttempt: lastAttempt,
                createdAt: createdAt,
                priority: priority,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String targetTable,
                Value<int?> recordId = const Value.absent(),
                Value<String?> localId = const Value.absent(),
                required String action,
                required String payload,
                required String endpoint,
                Value<String> method = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> lastAttempt = const Value.absent(),
                required DateTime createdAt,
                Value<int> priority = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                targetTable: targetTable,
                recordId: recordId,
                localId: localId,
                action: action,
                payload: payload,
                endpoint: endpoint,
                method: method,
                status: status,
                retryCount: retryCount,
                lastError: lastError,
                lastAttempt: lastAttempt,
                createdAt: createdAt,
                priority: priority,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LedgersTableTableManager get ledgers =>
      $$LedgersTableTableManager(_db, _db.ledgers);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
