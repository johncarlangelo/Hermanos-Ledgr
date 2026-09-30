// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTableTable extends AccountsTable
    with TableInfo<$AccountsTableTable, AccountsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<int> iconCode = GeneratedColumn<int>(
    'icon_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionMeta = const VerificationMeta(
    'institution',
  );
  @override
  late final GeneratedColumn<String> institution = GeneratedColumn<String>(
    'institution',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyChangeMeta = const VerificationMeta(
    'monthlyChange',
  );
  @override
  late final GeneratedColumn<double> monthlyChange = GeneratedColumn<double>(
    'monthly_change',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    balance,
    iconCode,
    colorValue,
    institution,
    monthlyChange,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_iconCodeMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('institution')) {
      context.handle(
        _institutionMeta,
        institution.isAcceptableOrUnknown(
          data['institution']!,
          _institutionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionMeta);
    }
    if (data.containsKey('monthly_change')) {
      context.handle(
        _monthlyChangeMeta,
        monthlyChange.isAcceptableOrUnknown(
          data['monthly_change']!,
          _monthlyChangeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      )!,
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      institution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution'],
      )!,
      monthlyChange: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_change'],
      )!,
    );
  }

  @override
  $AccountsTableTable createAlias(String alias) {
    return $AccountsTableTable(attachedDatabase, alias);
  }
}

class AccountsTableData extends DataClass
    implements Insertable<AccountsTableData> {
  final String id;
  final String name;
  final String type;
  final double balance;
  final int iconCode;
  final int colorValue;
  final String institution;
  final double monthlyChange;
  const AccountsTableData({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.iconCode,
    required this.colorValue,
    required this.institution,
    required this.monthlyChange,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['balance'] = Variable<double>(balance);
    map['icon_code'] = Variable<int>(iconCode);
    map['color_value'] = Variable<int>(colorValue);
    map['institution'] = Variable<String>(institution);
    map['monthly_change'] = Variable<double>(monthlyChange);
    return map;
  }

  AccountsTableCompanion toCompanion(bool nullToAbsent) {
    return AccountsTableCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      balance: Value(balance),
      iconCode: Value(iconCode),
      colorValue: Value(colorValue),
      institution: Value(institution),
      monthlyChange: Value(monthlyChange),
    );
  }

  factory AccountsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      balance: serializer.fromJson<double>(json['balance']),
      iconCode: serializer.fromJson<int>(json['iconCode']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      institution: serializer.fromJson<String>(json['institution']),
      monthlyChange: serializer.fromJson<double>(json['monthlyChange']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'balance': serializer.toJson<double>(balance),
      'iconCode': serializer.toJson<int>(iconCode),
      'colorValue': serializer.toJson<int>(colorValue),
      'institution': serializer.toJson<String>(institution),
      'monthlyChange': serializer.toJson<double>(monthlyChange),
    };
  }

  AccountsTableData copyWith({
    String? id,
    String? name,
    String? type,
    double? balance,
    int? iconCode,
    int? colorValue,
    String? institution,
    double? monthlyChange,
  }) => AccountsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    balance: balance ?? this.balance,
    iconCode: iconCode ?? this.iconCode,
    colorValue: colorValue ?? this.colorValue,
    institution: institution ?? this.institution,
    monthlyChange: monthlyChange ?? this.monthlyChange,
  );
  AccountsTableData copyWithCompanion(AccountsTableCompanion data) {
    return AccountsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      balance: data.balance.present ? data.balance.value : this.balance,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      institution: data.institution.present
          ? data.institution.value
          : this.institution,
      monthlyChange: data.monthlyChange.present
          ? data.monthlyChange.value
          : this.monthlyChange,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('balance: $balance, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorValue: $colorValue, ')
          ..write('institution: $institution, ')
          ..write('monthlyChange: $monthlyChange')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    balance,
    iconCode,
    colorValue,
    institution,
    monthlyChange,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.balance == this.balance &&
          other.iconCode == this.iconCode &&
          other.colorValue == this.colorValue &&
          other.institution == this.institution &&
          other.monthlyChange == this.monthlyChange);
}

class AccountsTableCompanion extends UpdateCompanion<AccountsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<double> balance;
  final Value<int> iconCode;
  final Value<int> colorValue;
  final Value<String> institution;
  final Value<double> monthlyChange;
  final Value<int> rowid;
  const AccountsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.balance = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.institution = const Value.absent(),
    this.monthlyChange = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsTableCompanion.insert({
    required String id,
    required String name,
    required String type,
    required double balance,
    required int iconCode,
    required int colorValue,
    required String institution,
    this.monthlyChange = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       balance = Value(balance),
       iconCode = Value(iconCode),
       colorValue = Value(colorValue),
       institution = Value(institution);
  static Insertable<AccountsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? balance,
    Expression<int>? iconCode,
    Expression<int>? colorValue,
    Expression<String>? institution,
    Expression<double>? monthlyChange,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (balance != null) 'balance': balance,
      if (iconCode != null) 'icon_code': iconCode,
      if (colorValue != null) 'color_value': colorValue,
      if (institution != null) 'institution': institution,
      if (monthlyChange != null) 'monthly_change': monthlyChange,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<double>? balance,
    Value<int>? iconCode,
    Value<int>? colorValue,
    Value<String>? institution,
    Value<double>? monthlyChange,
    Value<int>? rowid,
  }) {
    return AccountsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      institution: institution ?? this.institution,
      monthlyChange: monthlyChange ?? this.monthlyChange,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<int>(iconCode.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (institution.present) {
      map['institution'] = Variable<String>(institution.value);
    }
    if (monthlyChange.present) {
      map['monthly_change'] = Variable<double>(monthlyChange.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('balance: $balance, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorValue: $colorValue, ')
          ..write('institution: $institution, ')
          ..write('monthlyChange: $monthlyChange, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTableTable extends TransactionsTable
    with TableInfo<$TransactionsTableTable, TransactionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIconCodeMeta = const VerificationMeta(
    'categoryIconCode',
  );
  @override
  late final GeneratedColumn<int> categoryIconCode = GeneratedColumn<int>(
    'category_icon_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryColorValueMeta =
      const VerificationMeta('categoryColorValue');
  @override
  late final GeneratedColumn<int> categoryColorValue = GeneratedColumn<int>(
    'category_color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountNameMeta = const VerificationMeta(
    'accountName',
  );
  @override
  late final GeneratedColumn<String> accountName = GeneratedColumn<String>(
    'account_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationAccountIdMeta =
      const VerificationMeta('destinationAccountId');
  @override
  late final GeneratedColumn<String> destinationAccountId =
      GeneratedColumn<String>(
        'destination_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _destinationAccountNameMeta =
      const VerificationMeta('destinationAccountName');
  @override
  late final GeneratedColumn<String> destinationAccountName =
      GeneratedColumn<String>(
        'destination_account_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptImagePathMeta = const VerificationMeta(
    'receiptImagePath',
  );
  @override
  late final GeneratedColumn<String> receiptImagePath = GeneratedColumn<String>(
    'receipt_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    amount,
    type,
    categoryId,
    categoryName,
    categoryIconCode,
    categoryColorValue,
    accountId,
    accountName,
    destinationAccountId,
    destinationAccountName,
    date,
    note,
    receiptImagePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryNameMeta);
    }
    if (data.containsKey('category_icon_code')) {
      context.handle(
        _categoryIconCodeMeta,
        categoryIconCode.isAcceptableOrUnknown(
          data['category_icon_code']!,
          _categoryIconCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryIconCodeMeta);
    }
    if (data.containsKey('category_color_value')) {
      context.handle(
        _categoryColorValueMeta,
        categoryColorValue.isAcceptableOrUnknown(
          data['category_color_value']!,
          _categoryColorValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryColorValueMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('account_name')) {
      context.handle(
        _accountNameMeta,
        accountName.isAcceptableOrUnknown(
          data['account_name']!,
          _accountNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountNameMeta);
    }
    if (data.containsKey('destination_account_id')) {
      context.handle(
        _destinationAccountIdMeta,
        destinationAccountId.isAcceptableOrUnknown(
          data['destination_account_id']!,
          _destinationAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('destination_account_name')) {
      context.handle(
        _destinationAccountNameMeta,
        destinationAccountName.isAcceptableOrUnknown(
          data['destination_account_name']!,
          _destinationAccountNameMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('receipt_image_path')) {
      context.handle(
        _receiptImagePathMeta,
        receiptImagePath.isAcceptableOrUnknown(
          data['receipt_image_path']!,
          _receiptImagePathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      )!,
      categoryIconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_icon_code'],
      )!,
      categoryColorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_color_value'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      accountName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_name'],
      )!,
      destinationAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_account_id'],
      ),
      destinationAccountName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_account_name'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      receiptImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_image_path'],
      ),
    );
  }

  @override
  $TransactionsTableTable createAlias(String alias) {
    return $TransactionsTableTable(attachedDatabase, alias);
  }
}

class TransactionsTableData extends DataClass
    implements Insertable<TransactionsTableData> {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String categoryId;
  final String categoryName;
  final int categoryIconCode;
  final int categoryColorValue;
  final String accountId;
  final String accountName;
  final String? destinationAccountId;
  final String? destinationAccountName;
  final DateTime date;
  final String? note;
  final String? receiptImagePath;
  const TransactionsTableData({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIconCode,
    required this.categoryColorValue,
    required this.accountId,
    required this.accountName,
    this.destinationAccountId,
    this.destinationAccountName,
    required this.date,
    this.note,
    this.receiptImagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<double>(amount);
    map['type'] = Variable<String>(type);
    map['category_id'] = Variable<String>(categoryId);
    map['category_name'] = Variable<String>(categoryName);
    map['category_icon_code'] = Variable<int>(categoryIconCode);
    map['category_color_value'] = Variable<int>(categoryColorValue);
    map['account_id'] = Variable<String>(accountId);
    map['account_name'] = Variable<String>(accountName);
    if (!nullToAbsent || destinationAccountId != null) {
      map['destination_account_id'] = Variable<String>(destinationAccountId);
    }
    if (!nullToAbsent || destinationAccountName != null) {
      map['destination_account_name'] = Variable<String>(
        destinationAccountName,
      );
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || receiptImagePath != null) {
      map['receipt_image_path'] = Variable<String>(receiptImagePath);
    }
    return map;
  }

  TransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionsTableCompanion(
      id: Value(id),
      title: Value(title),
      amount: Value(amount),
      type: Value(type),
      categoryId: Value(categoryId),
      categoryName: Value(categoryName),
      categoryIconCode: Value(categoryIconCode),
      categoryColorValue: Value(categoryColorValue),
      accountId: Value(accountId),
      accountName: Value(accountName),
      destinationAccountId: destinationAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAccountId),
      destinationAccountName: destinationAccountName == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAccountName),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      receiptImagePath: receiptImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptImagePath),
    );
  }

  factory TransactionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<double>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      categoryName: serializer.fromJson<String>(json['categoryName']),
      categoryIconCode: serializer.fromJson<int>(json['categoryIconCode']),
      categoryColorValue: serializer.fromJson<int>(json['categoryColorValue']),
      accountId: serializer.fromJson<String>(json['accountId']),
      accountName: serializer.fromJson<String>(json['accountName']),
      destinationAccountId: serializer.fromJson<String?>(
        json['destinationAccountId'],
      ),
      destinationAccountName: serializer.fromJson<String?>(
        json['destinationAccountName'],
      ),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      receiptImagePath: serializer.fromJson<String?>(json['receiptImagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<double>(amount),
      'type': serializer.toJson<String>(type),
      'categoryId': serializer.toJson<String>(categoryId),
      'categoryName': serializer.toJson<String>(categoryName),
      'categoryIconCode': serializer.toJson<int>(categoryIconCode),
      'categoryColorValue': serializer.toJson<int>(categoryColorValue),
      'accountId': serializer.toJson<String>(accountId),
      'accountName': serializer.toJson<String>(accountName),
      'destinationAccountId': serializer.toJson<String?>(destinationAccountId),
      'destinationAccountName': serializer.toJson<String?>(
        destinationAccountName,
      ),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String?>(note),
      'receiptImagePath': serializer.toJson<String?>(receiptImagePath),
    };
  }

  TransactionsTableData copyWith({
    String? id,
    String? title,
    double? amount,
    String? type,
    String? categoryId,
    String? categoryName,
    int? categoryIconCode,
    int? categoryColorValue,
    String? accountId,
    String? accountName,
    Value<String?> destinationAccountId = const Value.absent(),
    Value<String?> destinationAccountName = const Value.absent(),
    DateTime? date,
    Value<String?> note = const Value.absent(),
    Value<String?> receiptImagePath = const Value.absent(),
  }) => TransactionsTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    categoryId: categoryId ?? this.categoryId,
    categoryName: categoryName ?? this.categoryName,
    categoryIconCode: categoryIconCode ?? this.categoryIconCode,
    categoryColorValue: categoryColorValue ?? this.categoryColorValue,
    accountId: accountId ?? this.accountId,
    accountName: accountName ?? this.accountName,
    destinationAccountId: destinationAccountId.present
        ? destinationAccountId.value
        : this.destinationAccountId,
    destinationAccountName: destinationAccountName.present
        ? destinationAccountName.value
        : this.destinationAccountName,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    receiptImagePath: receiptImagePath.present
        ? receiptImagePath.value
        : this.receiptImagePath,
  );
  TransactionsTableData copyWithCompanion(TransactionsTableCompanion data) {
    return TransactionsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      categoryIconCode: data.categoryIconCode.present
          ? data.categoryIconCode.value
          : this.categoryIconCode,
      categoryColorValue: data.categoryColorValue.present
          ? data.categoryColorValue.value
          : this.categoryColorValue,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      accountName: data.accountName.present
          ? data.accountName.value
          : this.accountName,
      destinationAccountId: data.destinationAccountId.present
          ? data.destinationAccountId.value
          : this.destinationAccountId,
      destinationAccountName: data.destinationAccountName.present
          ? data.destinationAccountName.value
          : this.destinationAccountName,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      receiptImagePath: data.receiptImagePath.present
          ? data.receiptImagePath.value
          : this.receiptImagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('categoryIconCode: $categoryIconCode, ')
          ..write('categoryColorValue: $categoryColorValue, ')
          ..write('accountId: $accountId, ')
          ..write('accountName: $accountName, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('destinationAccountName: $destinationAccountName, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('receiptImagePath: $receiptImagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    amount,
    type,
    categoryId,
    categoryName,
    categoryIconCode,
    categoryColorValue,
    accountId,
    accountName,
    destinationAccountId,
    destinationAccountName,
    date,
    note,
    receiptImagePath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.categoryId == this.categoryId &&
          other.categoryName == this.categoryName &&
          other.categoryIconCode == this.categoryIconCode &&
          other.categoryColorValue == this.categoryColorValue &&
          other.accountId == this.accountId &&
          other.accountName == this.accountName &&
          other.destinationAccountId == this.destinationAccountId &&
          other.destinationAccountName == this.destinationAccountName &&
          other.date == this.date &&
          other.note == this.note &&
          other.receiptImagePath == this.receiptImagePath);
}

class TransactionsTableCompanion
    extends UpdateCompanion<TransactionsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<double> amount;
  final Value<String> type;
  final Value<String> categoryId;
  final Value<String> categoryName;
  final Value<int> categoryIconCode;
  final Value<int> categoryColorValue;
  final Value<String> accountId;
  final Value<String> accountName;
  final Value<String?> destinationAccountId;
  final Value<String?> destinationAccountName;
  final Value<DateTime> date;
  final Value<String?> note;
  final Value<String?> receiptImagePath;
  final Value<int> rowid;
  const TransactionsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.categoryIconCode = const Value.absent(),
    this.categoryColorValue = const Value.absent(),
    this.accountId = const Value.absent(),
    this.accountName = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    this.destinationAccountName = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.receiptImagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsTableCompanion.insert({
    required String id,
    required String title,
    required double amount,
    required String type,
    required String categoryId,
    required String categoryName,
    required int categoryIconCode,
    required int categoryColorValue,
    required String accountId,
    required String accountName,
    this.destinationAccountId = const Value.absent(),
    this.destinationAccountName = const Value.absent(),
    required DateTime date,
    this.note = const Value.absent(),
    this.receiptImagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       amount = Value(amount),
       type = Value(type),
       categoryId = Value(categoryId),
       categoryName = Value(categoryName),
       categoryIconCode = Value(categoryIconCode),
       categoryColorValue = Value(categoryColorValue),
       accountId = Value(accountId),
       accountName = Value(accountName),
       date = Value(date);
  static Insertable<TransactionsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<double>? amount,
    Expression<String>? type,
    Expression<String>? categoryId,
    Expression<String>? categoryName,
    Expression<int>? categoryIconCode,
    Expression<int>? categoryColorValue,
    Expression<String>? accountId,
    Expression<String>? accountName,
    Expression<String>? destinationAccountId,
    Expression<String>? destinationAccountName,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<String>? receiptImagePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryName != null) 'category_name': categoryName,
      if (categoryIconCode != null) 'category_icon_code': categoryIconCode,
      if (categoryColorValue != null)
        'category_color_value': categoryColorValue,
      if (accountId != null) 'account_id': accountId,
      if (accountName != null) 'account_name': accountName,
      if (destinationAccountId != null)
        'destination_account_id': destinationAccountId,
      if (destinationAccountName != null)
        'destination_account_name': destinationAccountName,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (receiptImagePath != null) 'receipt_image_path': receiptImagePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<double>? amount,
    Value<String>? type,
    Value<String>? categoryId,
    Value<String>? categoryName,
    Value<int>? categoryIconCode,
    Value<int>? categoryColorValue,
    Value<String>? accountId,
    Value<String>? accountName,
    Value<String?>? destinationAccountId,
    Value<String?>? destinationAccountName,
    Value<DateTime>? date,
    Value<String?>? note,
    Value<String?>? receiptImagePath,
    Value<int>? rowid,
  }) {
    return TransactionsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIconCode: categoryIconCode ?? this.categoryIconCode,
      categoryColorValue: categoryColorValue ?? this.categoryColorValue,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      destinationAccountName:
          destinationAccountName ?? this.destinationAccountName,
      date: date ?? this.date,
      note: note ?? this.note,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (categoryIconCode.present) {
      map['category_icon_code'] = Variable<int>(categoryIconCode.value);
    }
    if (categoryColorValue.present) {
      map['category_color_value'] = Variable<int>(categoryColorValue.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (accountName.present) {
      map['account_name'] = Variable<String>(accountName.value);
    }
    if (destinationAccountId.present) {
      map['destination_account_id'] = Variable<String>(
        destinationAccountId.value,
      );
    }
    if (destinationAccountName.present) {
      map['destination_account_name'] = Variable<String>(
        destinationAccountName.value,
      );
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (receiptImagePath.present) {
      map['receipt_image_path'] = Variable<String>(receiptImagePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('categoryIconCode: $categoryIconCode, ')
          ..write('categoryColorValue: $categoryColorValue, ')
          ..write('accountId: $accountId, ')
          ..write('accountName: $accountName, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('destinationAccountName: $destinationAccountName, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('receiptImagePath: $receiptImagePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTableTable extends BudgetsTable
    with TableInfo<$BudgetsTableTable, BudgetsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyLimitMeta = const VerificationMeta(
    'monthlyLimit',
  );
  @override
  late final GeneratedColumn<double> monthlyLimit = GeneratedColumn<double>(
    'monthly_limit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    categoryName,
    monthlyLimit,
    month,
    year,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryNameMeta);
    }
    if (data.containsKey('monthly_limit')) {
      context.handle(
        _monthlyLimitMeta,
        monthlyLimit.isAcceptableOrUnknown(
          data['monthly_limit']!,
          _monthlyLimitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyLimitMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      )!,
      monthlyLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_limit'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
    );
  }

  @override
  $BudgetsTableTable createAlias(String alias) {
    return $BudgetsTableTable(attachedDatabase, alias);
  }
}

class BudgetsTableData extends DataClass
    implements Insertable<BudgetsTableData> {
  final String id;
  final String categoryId;
  final String categoryName;
  final double monthlyLimit;
  final int month;
  final int year;
  const BudgetsTableData({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.monthlyLimit,
    required this.month,
    required this.year,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['category_name'] = Variable<String>(categoryName);
    map['monthly_limit'] = Variable<double>(monthlyLimit);
    map['month'] = Variable<int>(month);
    map['year'] = Variable<int>(year);
    return map;
  }

  BudgetsTableCompanion toCompanion(bool nullToAbsent) {
    return BudgetsTableCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      categoryName: Value(categoryName),
      monthlyLimit: Value(monthlyLimit),
      month: Value(month),
      year: Value(year),
    );
  }

  factory BudgetsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetsTableData(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      categoryName: serializer.fromJson<String>(json['categoryName']),
      monthlyLimit: serializer.fromJson<double>(json['monthlyLimit']),
      month: serializer.fromJson<int>(json['month']),
      year: serializer.fromJson<int>(json['year']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'categoryName': serializer.toJson<String>(categoryName),
      'monthlyLimit': serializer.toJson<double>(monthlyLimit),
      'month': serializer.toJson<int>(month),
      'year': serializer.toJson<int>(year),
    };
  }

  BudgetsTableData copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    double? monthlyLimit,
    int? month,
    int? year,
  }) => BudgetsTableData(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    categoryName: categoryName ?? this.categoryName,
    monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    month: month ?? this.month,
    year: year ?? this.year,
  );
  BudgetsTableData copyWithCompanion(BudgetsTableCompanion data) {
    return BudgetsTableData(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      monthlyLimit: data.monthlyLimit.present
          ? data.monthlyLimit.value
          : this.monthlyLimit,
      month: data.month.present ? data.month.value : this.month,
      year: data.year.present ? data.year.value : this.year,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsTableData(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('monthlyLimit: $monthlyLimit, ')
          ..write('month: $month, ')
          ..write('year: $year')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, categoryId, categoryName, monthlyLimit, month, year);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetsTableData &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.categoryName == this.categoryName &&
          other.monthlyLimit == this.monthlyLimit &&
          other.month == this.month &&
          other.year == this.year);
}

class BudgetsTableCompanion extends UpdateCompanion<BudgetsTableData> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<String> categoryName;
  final Value<double> monthlyLimit;
  final Value<int> month;
  final Value<int> year;
  final Value<int> rowid;
  const BudgetsTableCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.monthlyLimit = const Value.absent(),
    this.month = const Value.absent(),
    this.year = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsTableCompanion.insert({
    required String id,
    required String categoryId,
    required String categoryName,
    required double monthlyLimit,
    required int month,
    required int year,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       categoryName = Value(categoryName),
       monthlyLimit = Value(monthlyLimit),
       month = Value(month),
       year = Value(year);
  static Insertable<BudgetsTableData> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? categoryName,
    Expression<double>? monthlyLimit,
    Expression<int>? month,
    Expression<int>? year,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryName != null) 'category_name': categoryName,
      if (monthlyLimit != null) 'monthly_limit': monthlyLimit,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryId,
    Value<String>? categoryName,
    Value<double>? monthlyLimit,
    Value<int>? month,
    Value<int>? year,
    Value<int>? rowid,
  }) {
    return BudgetsTableCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      month: month ?? this.month,
      year: year ?? this.year,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (monthlyLimit.present) {
      map['monthly_limit'] = Variable<double>(monthlyLimit.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsTableCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('monthlyLimit: $monthlyLimit, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTableTable extends CategoriesTable
    with TableInfo<$CategoriesTableTable, CategoriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<int> iconCode = GeneratedColumn<int>(
    'icon_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isExpenseMeta = const VerificationMeta(
    'isExpense',
  );
  @override
  late final GeneratedColumn<bool> isExpense = GeneratedColumn<bool>(
    'is_expense',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_expense" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconCode,
    colorValue,
    isExpense,
    isCustom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_iconCodeMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('is_expense')) {
      context.handle(
        _isExpenseMeta,
        isExpense.isAcceptableOrUnknown(data['is_expense']!, _isExpenseMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoriesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      isExpense: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_expense'],
      )!,
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
    );
  }

  @override
  $CategoriesTableTable createAlias(String alias) {
    return $CategoriesTableTable(attachedDatabase, alias);
  }
}

class CategoriesTableData extends DataClass
    implements Insertable<CategoriesTableData> {
  final String id;
  final String name;
  final int iconCode;
  final int colorValue;
  final bool isExpense;
  final bool isCustom;
  const CategoriesTableData({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.isExpense,
    required this.isCustom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_code'] = Variable<int>(iconCode);
    map['color_value'] = Variable<int>(colorValue);
    map['is_expense'] = Variable<bool>(isExpense);
    map['is_custom'] = Variable<bool>(isCustom);
    return map;
  }

  CategoriesTableCompanion toCompanion(bool nullToAbsent) {
    return CategoriesTableCompanion(
      id: Value(id),
      name: Value(name),
      iconCode: Value(iconCode),
      colorValue: Value(colorValue),
      isExpense: Value(isExpense),
      isCustom: Value(isCustom),
    );
  }

  factory CategoriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoriesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconCode: serializer.fromJson<int>(json['iconCode']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      isExpense: serializer.fromJson<bool>(json['isExpense']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconCode': serializer.toJson<int>(iconCode),
      'colorValue': serializer.toJson<int>(colorValue),
      'isExpense': serializer.toJson<bool>(isExpense),
      'isCustom': serializer.toJson<bool>(isCustom),
    };
  }

  CategoriesTableData copyWith({
    String? id,
    String? name,
    int? iconCode,
    int? colorValue,
    bool? isExpense,
    bool? isCustom,
  }) => CategoriesTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    iconCode: iconCode ?? this.iconCode,
    colorValue: colorValue ?? this.colorValue,
    isExpense: isExpense ?? this.isExpense,
    isCustom: isCustom ?? this.isCustom,
  );
  CategoriesTableData copyWithCompanion(CategoriesTableCompanion data) {
    return CategoriesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      isExpense: data.isExpense.present ? data.isExpense.value : this.isExpense,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorValue: $colorValue, ')
          ..write('isExpense: $isExpense, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, iconCode, colorValue, isExpense, isCustom);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoriesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconCode == this.iconCode &&
          other.colorValue == this.colorValue &&
          other.isExpense == this.isExpense &&
          other.isCustom == this.isCustom);
}

class CategoriesTableCompanion extends UpdateCompanion<CategoriesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> iconCode;
  final Value<int> colorValue;
  final Value<bool> isExpense;
  final Value<bool> isCustom;
  final Value<int> rowid;
  const CategoriesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isExpense = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesTableCompanion.insert({
    required String id,
    required String name,
    required int iconCode,
    required int colorValue,
    this.isExpense = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       iconCode = Value(iconCode),
       colorValue = Value(colorValue);
  static Insertable<CategoriesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? iconCode,
    Expression<int>? colorValue,
    Expression<bool>? isExpense,
    Expression<bool>? isCustom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconCode != null) 'icon_code': iconCode,
      if (colorValue != null) 'color_value': colorValue,
      if (isExpense != null) 'is_expense': isExpense,
      if (isCustom != null) 'is_custom': isCustom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? iconCode,
    Value<int>? colorValue,
    Value<bool>? isExpense,
    Value<bool>? isCustom,
    Value<int>? rowid,
  }) {
    return CategoriesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      isExpense: isExpense ?? this.isExpense,
      isCustom: isCustom ?? this.isCustom,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<int>(iconCode.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (isExpense.present) {
      map['is_expense'] = Variable<bool>(isExpense.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorValue: $colorValue, ')
          ..write('isExpense: $isExpense, ')
          ..write('isCustom: $isCustom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTableTable accountsTable = $AccountsTableTable(this);
  late final $TransactionsTableTable transactionsTable =
      $TransactionsTableTable(this);
  late final $BudgetsTableTable budgetsTable = $BudgetsTableTable(this);
  late final $CategoriesTableTable categoriesTable = $CategoriesTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accountsTable,
    transactionsTable,
    budgetsTable,
    categoriesTable,
  ];
}

typedef $$AccountsTableTableCreateCompanionBuilder =
    AccountsTableCompanion Function({
      required String id,
      required String name,
      required String type,
      required double balance,
      required int iconCode,
      required int colorValue,
      required String institution,
      Value<double> monthlyChange,
      Value<int> rowid,
    });
typedef $$AccountsTableTableUpdateCompanionBuilder =
    AccountsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<double> balance,
      Value<int> iconCode,
      Value<int> colorValue,
      Value<String> institution,
      Value<double> monthlyChange,
      Value<int> rowid,
    });

class $$AccountsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTableTable> {
  $$AccountsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyChange => $composableBuilder(
    column: $table.monthlyChange,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTableTable> {
  $$AccountsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyChange => $composableBuilder(
    column: $table.monthlyChange,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTableTable> {
  $$AccountsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<int> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyChange => $composableBuilder(
    column: $table.monthlyChange,
    builder: (column) => column,
  );
}

class $$AccountsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTableTable,
          AccountsTableData,
          $$AccountsTableTableFilterComposer,
          $$AccountsTableTableOrderingComposer,
          $$AccountsTableTableAnnotationComposer,
          $$AccountsTableTableCreateCompanionBuilder,
          $$AccountsTableTableUpdateCompanionBuilder,
          (
            AccountsTableData,
            BaseReferences<
              _$AppDatabase,
              $AccountsTableTable,
              AccountsTableData
            >,
          ),
          AccountsTableData,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableTableManager(_$AppDatabase db, $AccountsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<int> iconCode = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<String> institution = const Value.absent(),
                Value<double> monthlyChange = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsTableCompanion(
                id: id,
                name: name,
                type: type,
                balance: balance,
                iconCode: iconCode,
                colorValue: colorValue,
                institution: institution,
                monthlyChange: monthlyChange,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                required double balance,
                required int iconCode,
                required int colorValue,
                required String institution,
                Value<double> monthlyChange = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsTableCompanion.insert(
                id: id,
                name: name,
                type: type,
                balance: balance,
                iconCode: iconCode,
                colorValue: colorValue,
                institution: institution,
                monthlyChange: monthlyChange,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTableTable, AccountsTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AccountsTableTable,
                    AccountsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTableTable,
      AccountsTableData,
      $$AccountsTableTableFilterComposer,
      $$AccountsTableTableOrderingComposer,
      $$AccountsTableTableAnnotationComposer,
      $$AccountsTableTableCreateCompanionBuilder,
      $$AccountsTableTableUpdateCompanionBuilder,
      (
        AccountsTableData,
        BaseReferences<_$AppDatabase, $AccountsTableTable, AccountsTableData>,
      ),
      AccountsTableData,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableTableCreateCompanionBuilder =
    TransactionsTableCompanion Function({
      required String id,
      required String title,
      required double amount,
      required String type,
      required String categoryId,
      required String categoryName,
      required int categoryIconCode,
      required int categoryColorValue,
      required String accountId,
      required String accountName,
      Value<String?> destinationAccountId,
      Value<String?> destinationAccountName,
      required DateTime date,
      Value<String?> note,
      Value<String?> receiptImagePath,
      Value<int> rowid,
    });
typedef $$TransactionsTableTableUpdateCompanionBuilder =
    TransactionsTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<double> amount,
      Value<String> type,
      Value<String> categoryId,
      Value<String> categoryName,
      Value<int> categoryIconCode,
      Value<int> categoryColorValue,
      Value<String> accountId,
      Value<String> accountName,
      Value<String?> destinationAccountId,
      Value<String?> destinationAccountName,
      Value<DateTime> date,
      Value<String?> note,
      Value<String?> receiptImagePath,
      Value<int> rowid,
    });

class $$TransactionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryIconCode => $composableBuilder(
    column: $table.categoryIconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryColorValue => $composableBuilder(
    column: $table.categoryColorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationAccountName => $composableBuilder(
    column: $table.destinationAccountName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptImagePath => $composableBuilder(
    column: $table.receiptImagePath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryIconCode => $composableBuilder(
    column: $table.categoryIconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryColorValue => $composableBuilder(
    column: $table.categoryColorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationAccountName => $composableBuilder(
    column: $table.destinationAccountName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptImagePath => $composableBuilder(
    column: $table.receiptImagePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoryIconCode => $composableBuilder(
    column: $table.categoryIconCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoryColorValue => $composableBuilder(
    column: $table.categoryColorValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationAccountName => $composableBuilder(
    column: $table.destinationAccountName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get receiptImagePath => $composableBuilder(
    column: $table.receiptImagePath,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTableTable,
          TransactionsTableData,
          $$TransactionsTableTableFilterComposer,
          $$TransactionsTableTableOrderingComposer,
          $$TransactionsTableTableAnnotationComposer,
          $$TransactionsTableTableCreateCompanionBuilder,
          $$TransactionsTableTableUpdateCompanionBuilder,
          (
            TransactionsTableData,
            BaseReferences<
              _$AppDatabase,
              $TransactionsTableTable,
              TransactionsTableData
            >,
          ),
          TransactionsTableData,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableTableManager(
    _$AppDatabase db,
    $TransactionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> categoryName = const Value.absent(),
                Value<int> categoryIconCode = const Value.absent(),
                Value<int> categoryColorValue = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> accountName = const Value.absent(),
                Value<String?> destinationAccountId = const Value.absent(),
                Value<String?> destinationAccountName = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> receiptImagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsTableCompanion(
                id: id,
                title: title,
                amount: amount,
                type: type,
                categoryId: categoryId,
                categoryName: categoryName,
                categoryIconCode: categoryIconCode,
                categoryColorValue: categoryColorValue,
                accountId: accountId,
                accountName: accountName,
                destinationAccountId: destinationAccountId,
                destinationAccountName: destinationAccountName,
                date: date,
                note: note,
                receiptImagePath: receiptImagePath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required double amount,
                required String type,
                required String categoryId,
                required String categoryName,
                required int categoryIconCode,
                required int categoryColorValue,
                required String accountId,
                required String accountName,
                Value<String?> destinationAccountId = const Value.absent(),
                Value<String?> destinationAccountName = const Value.absent(),
                required DateTime date,
                Value<String?> note = const Value.absent(),
                Value<String?> receiptImagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsTableCompanion.insert(
                id: id,
                title: title,
                amount: amount,
                type: type,
                categoryId: categoryId,
                categoryName: categoryName,
                categoryIconCode: categoryIconCode,
                categoryColorValue: categoryColorValue,
                accountId: accountId,
                accountName: accountName,
                destinationAccountId: destinationAccountId,
                destinationAccountName: destinationAccountName,
                date: date,
                note: note,
                receiptImagePath: receiptImagePath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionsTableTable, TransactionsTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $TransactionsTableTable,
                    TransactionsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTableTable,
      TransactionsTableData,
      $$TransactionsTableTableFilterComposer,
      $$TransactionsTableTableOrderingComposer,
      $$TransactionsTableTableAnnotationComposer,
      $$TransactionsTableTableCreateCompanionBuilder,
      $$TransactionsTableTableUpdateCompanionBuilder,
      (
        TransactionsTableData,
        BaseReferences<
          _$AppDatabase,
          $TransactionsTableTable,
          TransactionsTableData
        >,
      ),
      TransactionsTableData,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableTableCreateCompanionBuilder =
    BudgetsTableCompanion Function({
      required String id,
      required String categoryId,
      required String categoryName,
      required double monthlyLimit,
      required int month,
      required int year,
      Value<int> rowid,
    });
typedef $$BudgetsTableTableUpdateCompanionBuilder =
    BudgetsTableCompanion Function({
      Value<String> id,
      Value<String> categoryId,
      Value<String> categoryName,
      Value<double> monthlyLimit,
      Value<int> month,
      Value<int> year,
      Value<int> rowid,
    });

class $$BudgetsTableTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTableTable> {
  $$BudgetsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTableTable> {
  $$BudgetsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTableTable> {
  $$BudgetsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);
}

class $$BudgetsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTableTable,
          BudgetsTableData,
          $$BudgetsTableTableFilterComposer,
          $$BudgetsTableTableOrderingComposer,
          $$BudgetsTableTableAnnotationComposer,
          $$BudgetsTableTableCreateCompanionBuilder,
          $$BudgetsTableTableUpdateCompanionBuilder,
          (
            BudgetsTableData,
            BaseReferences<_$AppDatabase, $BudgetsTableTable, BudgetsTableData>,
          ),
          BudgetsTableData,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableTableManager(_$AppDatabase db, $BudgetsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> categoryName = const Value.absent(),
                Value<double> monthlyLimit = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsTableCompanion(
                id: id,
                categoryId: categoryId,
                categoryName: categoryName,
                monthlyLimit: monthlyLimit,
                month: month,
                year: year,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryId,
                required String categoryName,
                required double monthlyLimit,
                required int month,
                required int year,
                Value<int> rowid = const Value.absent(),
              }) => BudgetsTableCompanion.insert(
                id: id,
                categoryId: categoryId,
                categoryName: categoryName,
                monthlyLimit: monthlyLimit,
                month: month,
                year: year,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetsTableTable, BudgetsTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BudgetsTableTable,
                    BudgetsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTableTable,
      BudgetsTableData,
      $$BudgetsTableTableFilterComposer,
      $$BudgetsTableTableOrderingComposer,
      $$BudgetsTableTableAnnotationComposer,
      $$BudgetsTableTableCreateCompanionBuilder,
      $$BudgetsTableTableUpdateCompanionBuilder,
      (
        BudgetsTableData,
        BaseReferences<_$AppDatabase, $BudgetsTableTable, BudgetsTableData>,
      ),
      BudgetsTableData,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableTableCreateCompanionBuilder =
    CategoriesTableCompanion Function({
      required String id,
      required String name,
      required int iconCode,
      required int colorValue,
      Value<bool> isExpense,
      Value<bool> isCustom,
      Value<int> rowid,
    });
typedef $$CategoriesTableTableUpdateCompanionBuilder =
    CategoriesTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> iconCode,
      Value<int> colorValue,
      Value<bool> isExpense,
      Value<bool> isCustom,
      Value<int> rowid,
    });

class $$CategoriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExpense => $composableBuilder(
    column: $table.isExpense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExpense => $composableBuilder(
    column: $table.isExpense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isExpense =>
      $composableBuilder(column: $table.isExpense, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);
}

class $$CategoriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTableTable,
          CategoriesTableData,
          $$CategoriesTableTableFilterComposer,
          $$CategoriesTableTableOrderingComposer,
          $$CategoriesTableTableAnnotationComposer,
          $$CategoriesTableTableCreateCompanionBuilder,
          $$CategoriesTableTableUpdateCompanionBuilder,
          (
            CategoriesTableData,
            BaseReferences<
              _$AppDatabase,
              $CategoriesTableTable,
              CategoriesTableData
            >,
          ),
          CategoriesTableData,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableTableManager(
    _$AppDatabase db,
    $CategoriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> iconCode = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<bool> isExpense = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesTableCompanion(
                id: id,
                name: name,
                iconCode: iconCode,
                colorValue: colorValue,
                isExpense: isExpense,
                isCustom: isCustom,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int iconCode,
                required int colorValue,
                Value<bool> isExpense = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesTableCompanion.insert(
                id: id,
                name: name,
                iconCode: iconCode,
                colorValue: colorValue,
                isExpense: isExpense,
                isCustom: isCustom,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTableTable, CategoriesTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $CategoriesTableTable,
                    CategoriesTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTableTable,
      CategoriesTableData,
      $$CategoriesTableTableFilterComposer,
      $$CategoriesTableTableOrderingComposer,
      $$CategoriesTableTableAnnotationComposer,
      $$CategoriesTableTableCreateCompanionBuilder,
      $$CategoriesTableTableUpdateCompanionBuilder,
      (
        CategoriesTableData,
        BaseReferences<
          _$AppDatabase,
          $CategoriesTableTable,
          CategoriesTableData
        >,
      ),
      CategoriesTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableTableManager get accountsTable =>
      $$AccountsTableTableTableManager(_db, _db.accountsTable);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(_db, _db.transactionsTable);
  $$BudgetsTableTableTableManager get budgetsTable =>
      $$BudgetsTableTableTableManager(_db, _db.budgetsTable);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(_db, _db.categoriesTable);
}
