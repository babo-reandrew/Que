// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_database.dart';

// ignore_for_file: type=lint
class $ScheduleTable extends Schedule
    with TableInfo<$ScheduleTable, ScheduleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<DateTime> start = GeneratedColumn<DateTime>(
    'start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMeta = const VerificationMeta('end');
  @override
  late final GeneratedColumn<DateTime> end = GeneratedColumn<DateTime>(
    'end',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
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
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _colorIdMeta = const VerificationMeta(
    'colorId',
  );
  @override
  late final GeneratedColumn<String> colorId = GeneratedColumn<String>(
    'color_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatRuleMeta = const VerificationMeta(
    'repeatRule',
  );
  @override
  late final GeneratedColumn<String> repeatRule = GeneratedColumn<String>(
    'repeat_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alertSettingMeta = const VerificationMeta(
    'alertSetting',
  );
  @override
  late final GeneratedColumn<String> alertSetting = GeneratedColumn<String>(
    'alert_setting',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAllDayMeta = const VerificationMeta(
    'isAllDay',
  );
  @override
  late final GeneratedColumn<bool> isAllDay = GeneratedColumn<bool>(
    'is_all_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_all_day" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visibilityMeta = const VerificationMeta(
    'visibility',
  );
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    start,
    end,
    id,
    summary,
    description,
    location,
    colorId,
    repeatRule,
    alertSetting,
    isAllDay,
    createdAt,
    status,
    visibility,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('start')) {
      context.handle(
        _startMeta,
        start.isAcceptableOrUnknown(data['start']!, _startMeta),
      );
    } else if (isInserting) {
      context.missing(_startMeta);
    }
    if (data.containsKey('end')) {
      context.handle(
        _endMeta,
        end.isAcceptableOrUnknown(data['end']!, _endMeta),
      );
    } else if (isInserting) {
      context.missing(_endMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('color_id')) {
      context.handle(
        _colorIdMeta,
        colorId.isAcceptableOrUnknown(data['color_id']!, _colorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_colorIdMeta);
    }
    if (data.containsKey('repeat_rule')) {
      context.handle(
        _repeatRuleMeta,
        repeatRule.isAcceptableOrUnknown(data['repeat_rule']!, _repeatRuleMeta),
      );
    } else if (isInserting) {
      context.missing(_repeatRuleMeta);
    }
    if (data.containsKey('alert_setting')) {
      context.handle(
        _alertSettingMeta,
        alertSetting.isAcceptableOrUnknown(
          data['alert_setting']!,
          _alertSettingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_alertSettingMeta);
    }
    if (data.containsKey('is_all_day')) {
      context.handle(
        _isAllDayMeta,
        isAllDay.isAcceptableOrUnknown(data['is_all_day']!, _isAllDayMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
      );
    } else if (isInserting) {
      context.missing(_visibilityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleData(
      start: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start'],
      )!,
      end: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      colorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_id'],
      )!,
      repeatRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_rule'],
      )!,
      alertSetting: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_setting'],
      )!,
      isAllDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_all_day'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      visibility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visibility'],
      )!,
    );
  }

  @override
  $ScheduleTable createAlias(String alias) {
    return $ScheduleTable(attachedDatabase, alias);
  }
}

class ScheduleData extends DataClass implements Insertable<ScheduleData> {
  final DateTime start;
  final DateTime end;
  final int id;
  final String summary;
  final String description;
  final String location;
  final String colorId;
  final String repeatRule;
  final String alertSetting;
  final bool isAllDay;
  final DateTime createdAt;
  final String status;
  final String visibility;
  const ScheduleData({
    required this.start,
    required this.end,
    required this.id,
    required this.summary,
    required this.description,
    required this.location,
    required this.colorId,
    required this.repeatRule,
    required this.alertSetting,
    required this.isAllDay,
    required this.createdAt,
    required this.status,
    required this.visibility,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['start'] = Variable<DateTime>(start);
    map['end'] = Variable<DateTime>(end);
    map['id'] = Variable<int>(id);
    map['summary'] = Variable<String>(summary);
    map['description'] = Variable<String>(description);
    map['location'] = Variable<String>(location);
    map['color_id'] = Variable<String>(colorId);
    map['repeat_rule'] = Variable<String>(repeatRule);
    map['alert_setting'] = Variable<String>(alertSetting);
    map['is_all_day'] = Variable<bool>(isAllDay);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['status'] = Variable<String>(status);
    map['visibility'] = Variable<String>(visibility);
    return map;
  }

  ScheduleCompanion toCompanion(bool nullToAbsent) {
    return ScheduleCompanion(
      start: Value(start),
      end: Value(end),
      id: Value(id),
      summary: Value(summary),
      description: Value(description),
      location: Value(location),
      colorId: Value(colorId),
      repeatRule: Value(repeatRule),
      alertSetting: Value(alertSetting),
      isAllDay: Value(isAllDay),
      createdAt: Value(createdAt),
      status: Value(status),
      visibility: Value(visibility),
    );
  }

  factory ScheduleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleData(
      start: serializer.fromJson<DateTime>(json['start']),
      end: serializer.fromJson<DateTime>(json['end']),
      id: serializer.fromJson<int>(json['id']),
      summary: serializer.fromJson<String>(json['summary']),
      description: serializer.fromJson<String>(json['description']),
      location: serializer.fromJson<String>(json['location']),
      colorId: serializer.fromJson<String>(json['colorId']),
      repeatRule: serializer.fromJson<String>(json['repeatRule']),
      alertSetting: serializer.fromJson<String>(json['alertSetting']),
      isAllDay: serializer.fromJson<bool>(json['isAllDay']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      status: serializer.fromJson<String>(json['status']),
      visibility: serializer.fromJson<String>(json['visibility']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'start': serializer.toJson<DateTime>(start),
      'end': serializer.toJson<DateTime>(end),
      'id': serializer.toJson<int>(id),
      'summary': serializer.toJson<String>(summary),
      'description': serializer.toJson<String>(description),
      'location': serializer.toJson<String>(location),
      'colorId': serializer.toJson<String>(colorId),
      'repeatRule': serializer.toJson<String>(repeatRule),
      'alertSetting': serializer.toJson<String>(alertSetting),
      'isAllDay': serializer.toJson<bool>(isAllDay),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'status': serializer.toJson<String>(status),
      'visibility': serializer.toJson<String>(visibility),
    };
  }

  ScheduleData copyWith({
    DateTime? start,
    DateTime? end,
    int? id,
    String? summary,
    String? description,
    String? location,
    String? colorId,
    String? repeatRule,
    String? alertSetting,
    bool? isAllDay,
    DateTime? createdAt,
    String? status,
    String? visibility,
  }) => ScheduleData(
    start: start ?? this.start,
    end: end ?? this.end,
    id: id ?? this.id,
    summary: summary ?? this.summary,
    description: description ?? this.description,
    location: location ?? this.location,
    colorId: colorId ?? this.colorId,
    repeatRule: repeatRule ?? this.repeatRule,
    alertSetting: alertSetting ?? this.alertSetting,
    isAllDay: isAllDay ?? this.isAllDay,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
    visibility: visibility ?? this.visibility,
  );
  ScheduleData copyWithCompanion(ScheduleCompanion data) {
    return ScheduleData(
      start: data.start.present ? data.start.value : this.start,
      end: data.end.present ? data.end.value : this.end,
      id: data.id.present ? data.id.value : this.id,
      summary: data.summary.present ? data.summary.value : this.summary,
      description: data.description.present
          ? data.description.value
          : this.description,
      location: data.location.present ? data.location.value : this.location,
      colorId: data.colorId.present ? data.colorId.value : this.colorId,
      repeatRule: data.repeatRule.present
          ? data.repeatRule.value
          : this.repeatRule,
      alertSetting: data.alertSetting.present
          ? data.alertSetting.value
          : this.alertSetting,
      isAllDay: data.isAllDay.present ? data.isAllDay.value : this.isAllDay,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
      visibility: data.visibility.present
          ? data.visibility.value
          : this.visibility,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleData(')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('id: $id, ')
          ..write('summary: $summary, ')
          ..write('description: $description, ')
          ..write('location: $location, ')
          ..write('colorId: $colorId, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('alertSetting: $alertSetting, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('visibility: $visibility')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    start,
    end,
    id,
    summary,
    description,
    location,
    colorId,
    repeatRule,
    alertSetting,
    isAllDay,
    createdAt,
    status,
    visibility,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleData &&
          other.start == this.start &&
          other.end == this.end &&
          other.id == this.id &&
          other.summary == this.summary &&
          other.description == this.description &&
          other.location == this.location &&
          other.colorId == this.colorId &&
          other.repeatRule == this.repeatRule &&
          other.alertSetting == this.alertSetting &&
          other.isAllDay == this.isAllDay &&
          other.createdAt == this.createdAt &&
          other.status == this.status &&
          other.visibility == this.visibility);
}

class ScheduleCompanion extends UpdateCompanion<ScheduleData> {
  final Value<DateTime> start;
  final Value<DateTime> end;
  final Value<int> id;
  final Value<String> summary;
  final Value<String> description;
  final Value<String> location;
  final Value<String> colorId;
  final Value<String> repeatRule;
  final Value<String> alertSetting;
  final Value<bool> isAllDay;
  final Value<DateTime> createdAt;
  final Value<String> status;
  final Value<String> visibility;
  const ScheduleCompanion({
    this.start = const Value.absent(),
    this.end = const Value.absent(),
    this.id = const Value.absent(),
    this.summary = const Value.absent(),
    this.description = const Value.absent(),
    this.location = const Value.absent(),
    this.colorId = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.alertSetting = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.visibility = const Value.absent(),
  });
  ScheduleCompanion.insert({
    required DateTime start,
    required DateTime end,
    this.id = const Value.absent(),
    required String summary,
    this.description = const Value.absent(),
    this.location = const Value.absent(),
    required String colorId,
    required String repeatRule,
    required String alertSetting,
    this.isAllDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String status,
    required String visibility,
  }) : start = Value(start),
       end = Value(end),
       summary = Value(summary),
       colorId = Value(colorId),
       repeatRule = Value(repeatRule),
       alertSetting = Value(alertSetting),
       status = Value(status),
       visibility = Value(visibility);
  static Insertable<ScheduleData> custom({
    Expression<DateTime>? start,
    Expression<DateTime>? end,
    Expression<int>? id,
    Expression<String>? summary,
    Expression<String>? description,
    Expression<String>? location,
    Expression<String>? colorId,
    Expression<String>? repeatRule,
    Expression<String>? alertSetting,
    Expression<bool>? isAllDay,
    Expression<DateTime>? createdAt,
    Expression<String>? status,
    Expression<String>? visibility,
  }) {
    return RawValuesInsertable({
      if (start != null) 'start': start,
      if (end != null) 'end': end,
      if (id != null) 'id': id,
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (colorId != null) 'color_id': colorId,
      if (repeatRule != null) 'repeat_rule': repeatRule,
      if (alertSetting != null) 'alert_setting': alertSetting,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
      if (visibility != null) 'visibility': visibility,
    });
  }

  ScheduleCompanion copyWith({
    Value<DateTime>? start,
    Value<DateTime>? end,
    Value<int>? id,
    Value<String>? summary,
    Value<String>? description,
    Value<String>? location,
    Value<String>? colorId,
    Value<String>? repeatRule,
    Value<String>? alertSetting,
    Value<bool>? isAllDay,
    Value<DateTime>? createdAt,
    Value<String>? status,
    Value<String>? visibility,
  }) {
    return ScheduleCompanion(
      start: start ?? this.start,
      end: end ?? this.end,
      id: id ?? this.id,
      summary: summary ?? this.summary,
      description: description ?? this.description,
      location: location ?? this.location,
      colorId: colorId ?? this.colorId,
      repeatRule: repeatRule ?? this.repeatRule,
      alertSetting: alertSetting ?? this.alertSetting,
      isAllDay: isAllDay ?? this.isAllDay,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (start.present) {
      map['start'] = Variable<DateTime>(start.value);
    }
    if (end.present) {
      map['end'] = Variable<DateTime>(end.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (colorId.present) {
      map['color_id'] = Variable<String>(colorId.value);
    }
    if (repeatRule.present) {
      map['repeat_rule'] = Variable<String>(repeatRule.value);
    }
    if (alertSetting.present) {
      map['alert_setting'] = Variable<String>(alertSetting.value);
    }
    if (isAllDay.present) {
      map['is_all_day'] = Variable<bool>(isAllDay.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleCompanion(')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('id: $id, ')
          ..write('summary: $summary, ')
          ..write('description: $description, ')
          ..write('location: $location, ')
          ..write('colorId: $colorId, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('alertSetting: $alertSetting, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('visibility: $visibility')
          ..write(')'))
        .toString();
  }
}

class $TaskTable extends Task with TableInfo<$TaskTable, TaskData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _executionDateMeta = const VerificationMeta(
    'executionDate',
  );
  @override
  late final GeneratedColumn<DateTime> executionDate =
      GeneratedColumn<DateTime>(
        'execution_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('inbox'),
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
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorIdMeta = const VerificationMeta(
    'colorId',
  );
  @override
  late final GeneratedColumn<String> colorId = GeneratedColumn<String>(
    'color_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('gray'),
  );
  static const VerificationMeta _repeatRuleMeta = const VerificationMeta(
    'repeatRule',
  );
  @override
  late final GeneratedColumn<String> repeatRule = GeneratedColumn<String>(
    'repeat_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _reminderMeta = const VerificationMeta(
    'reminder',
  );
  @override
  late final GeneratedColumn<String> reminder = GeneratedColumn<String>(
    'reminder',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    completed,
    dueDate,
    executionDate,
    listId,
    createdAt,
    completedAt,
    colorId,
    repeatRule,
    reminder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('execution_date')) {
      context.handle(
        _executionDateMeta,
        executionDate.isAcceptableOrUnknown(
          data['execution_date']!,
          _executionDateMeta,
        ),
      );
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
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
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('color_id')) {
      context.handle(
        _colorIdMeta,
        colorId.isAcceptableOrUnknown(data['color_id']!, _colorIdMeta),
      );
    }
    if (data.containsKey('repeat_rule')) {
      context.handle(
        _repeatRuleMeta,
        repeatRule.isAcceptableOrUnknown(data['repeat_rule']!, _repeatRuleMeta),
      );
    }
    if (data.containsKey('reminder')) {
      context.handle(
        _reminderMeta,
        reminder.isAcceptableOrUnknown(data['reminder']!, _reminderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      executionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}execution_date'],
      ),
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      colorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_id'],
      )!,
      repeatRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_rule'],
      )!,
      reminder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder'],
      )!,
    );
  }

  @override
  $TaskTable createAlias(String alias) {
    return $TaskTable(attachedDatabase, alias);
  }
}

class TaskData extends DataClass implements Insertable<TaskData> {
  final int id;
  final String title;
  final bool completed;
  final DateTime? dueDate;
  final DateTime? executionDate;
  final String listId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String colorId;
  final String repeatRule;
  final String reminder;
  const TaskData({
    required this.id,
    required this.title,
    required this.completed,
    this.dueDate,
    this.executionDate,
    required this.listId,
    required this.createdAt,
    this.completedAt,
    required this.colorId,
    required this.repeatRule,
    required this.reminder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || executionDate != null) {
      map['execution_date'] = Variable<DateTime>(executionDate);
    }
    map['list_id'] = Variable<String>(listId);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['color_id'] = Variable<String>(colorId);
    map['repeat_rule'] = Variable<String>(repeatRule);
    map['reminder'] = Variable<String>(reminder);
    return map;
  }

  TaskCompanion toCompanion(bool nullToAbsent) {
    return TaskCompanion(
      id: Value(id),
      title: Value(title),
      completed: Value(completed),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      executionDate: executionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(executionDate),
      listId: Value(listId),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      colorId: Value(colorId),
      repeatRule: Value(repeatRule),
      reminder: Value(reminder),
    );
  }

  factory TaskData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      completed: serializer.fromJson<bool>(json['completed']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      executionDate: serializer.fromJson<DateTime?>(json['executionDate']),
      listId: serializer.fromJson<String>(json['listId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      colorId: serializer.fromJson<String>(json['colorId']),
      repeatRule: serializer.fromJson<String>(json['repeatRule']),
      reminder: serializer.fromJson<String>(json['reminder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'completed': serializer.toJson<bool>(completed),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'executionDate': serializer.toJson<DateTime?>(executionDate),
      'listId': serializer.toJson<String>(listId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'colorId': serializer.toJson<String>(colorId),
      'repeatRule': serializer.toJson<String>(repeatRule),
      'reminder': serializer.toJson<String>(reminder),
    };
  }

  TaskData copyWith({
    int? id,
    String? title,
    bool? completed,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<DateTime?> executionDate = const Value.absent(),
    String? listId,
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
    String? colorId,
    String? repeatRule,
    String? reminder,
  }) => TaskData(
    id: id ?? this.id,
    title: title ?? this.title,
    completed: completed ?? this.completed,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    executionDate: executionDate.present
        ? executionDate.value
        : this.executionDate,
    listId: listId ?? this.listId,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    colorId: colorId ?? this.colorId,
    repeatRule: repeatRule ?? this.repeatRule,
    reminder: reminder ?? this.reminder,
  );
  TaskData copyWithCompanion(TaskCompanion data) {
    return TaskData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      completed: data.completed.present ? data.completed.value : this.completed,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      executionDate: data.executionDate.present
          ? data.executionDate.value
          : this.executionDate,
      listId: data.listId.present ? data.listId.value : this.listId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      colorId: data.colorId.present ? data.colorId.value : this.colorId,
      repeatRule: data.repeatRule.present
          ? data.repeatRule.value
          : this.repeatRule,
      reminder: data.reminder.present ? data.reminder.value : this.reminder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('completed: $completed, ')
          ..write('dueDate: $dueDate, ')
          ..write('executionDate: $executionDate, ')
          ..write('listId: $listId, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('colorId: $colorId, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('reminder: $reminder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    completed,
    dueDate,
    executionDate,
    listId,
    createdAt,
    completedAt,
    colorId,
    repeatRule,
    reminder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskData &&
          other.id == this.id &&
          other.title == this.title &&
          other.completed == this.completed &&
          other.dueDate == this.dueDate &&
          other.executionDate == this.executionDate &&
          other.listId == this.listId &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.colorId == this.colorId &&
          other.repeatRule == this.repeatRule &&
          other.reminder == this.reminder);
}

class TaskCompanion extends UpdateCompanion<TaskData> {
  final Value<int> id;
  final Value<String> title;
  final Value<bool> completed;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> executionDate;
  final Value<String> listId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<String> colorId;
  final Value<String> repeatRule;
  final Value<String> reminder;
  const TaskCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.completed = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.executionDate = const Value.absent(),
    this.listId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.colorId = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.reminder = const Value.absent(),
  });
  TaskCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.completed = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.executionDate = const Value.absent(),
    this.listId = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.colorId = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.reminder = const Value.absent(),
  }) : title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<TaskData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<bool>? completed,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? executionDate,
    Expression<String>? listId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<String>? colorId,
    Expression<String>? repeatRule,
    Expression<String>? reminder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (completed != null) 'completed': completed,
      if (dueDate != null) 'due_date': dueDate,
      if (executionDate != null) 'execution_date': executionDate,
      if (listId != null) 'list_id': listId,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (colorId != null) 'color_id': colorId,
      if (repeatRule != null) 'repeat_rule': repeatRule,
      if (reminder != null) 'reminder': reminder,
    });
  }

  TaskCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<bool>? completed,
    Value<DateTime?>? dueDate,
    Value<DateTime?>? executionDate,
    Value<String>? listId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<String>? colorId,
    Value<String>? repeatRule,
    Value<String>? reminder,
  }) {
    return TaskCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      dueDate: dueDate ?? this.dueDate,
      executionDate: executionDate ?? this.executionDate,
      listId: listId ?? this.listId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      colorId: colorId ?? this.colorId,
      repeatRule: repeatRule ?? this.repeatRule,
      reminder: reminder ?? this.reminder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (executionDate.present) {
      map['execution_date'] = Variable<DateTime>(executionDate.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (colorId.present) {
      map['color_id'] = Variable<String>(colorId.value);
    }
    if (repeatRule.present) {
      map['repeat_rule'] = Variable<String>(repeatRule.value);
    }
    if (reminder.present) {
      map['reminder'] = Variable<String>(reminder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('completed: $completed, ')
          ..write('dueDate: $dueDate, ')
          ..write('executionDate: $executionDate, ')
          ..write('listId: $listId, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('colorId: $colorId, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('reminder: $reminder')
          ..write(')'))
        .toString();
  }
}

class $HabitTable extends Habit with TableInfo<$HabitTable, HabitData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _colorIdMeta = const VerificationMeta(
    'colorId',
  );
  @override
  late final GeneratedColumn<String> colorId = GeneratedColumn<String>(
    'color_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('gray'),
  );
  static const VerificationMeta _repeatRuleMeta = const VerificationMeta(
    'repeatRule',
  );
  @override
  late final GeneratedColumn<String> repeatRule = GeneratedColumn<String>(
    'repeat_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderMeta = const VerificationMeta(
    'reminder',
  );
  @override
  late final GeneratedColumn<String> reminder = GeneratedColumn<String>(
    'reminder',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    createdAt,
    colorId,
    repeatRule,
    reminder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('color_id')) {
      context.handle(
        _colorIdMeta,
        colorId.isAcceptableOrUnknown(data['color_id']!, _colorIdMeta),
      );
    }
    if (data.containsKey('repeat_rule')) {
      context.handle(
        _repeatRuleMeta,
        repeatRule.isAcceptableOrUnknown(data['repeat_rule']!, _repeatRuleMeta),
      );
    } else if (isInserting) {
      context.missing(_repeatRuleMeta);
    }
    if (data.containsKey('reminder')) {
      context.handle(
        _reminderMeta,
        reminder.isAcceptableOrUnknown(data['reminder']!, _reminderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      colorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_id'],
      )!,
      repeatRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_rule'],
      )!,
      reminder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder'],
      )!,
    );
  }

  @override
  $HabitTable createAlias(String alias) {
    return $HabitTable(attachedDatabase, alias);
  }
}

class HabitData extends DataClass implements Insertable<HabitData> {
  final int id;
  final String title;
  final DateTime createdAt;
  final String colorId;
  final String repeatRule;
  final String reminder;
  const HabitData({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.colorId,
    required this.repeatRule,
    required this.reminder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['color_id'] = Variable<String>(colorId);
    map['repeat_rule'] = Variable<String>(repeatRule);
    map['reminder'] = Variable<String>(reminder);
    return map;
  }

  HabitCompanion toCompanion(bool nullToAbsent) {
    return HabitCompanion(
      id: Value(id),
      title: Value(title),
      createdAt: Value(createdAt),
      colorId: Value(colorId),
      repeatRule: Value(repeatRule),
      reminder: Value(reminder),
    );
  }

  factory HabitData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      colorId: serializer.fromJson<String>(json['colorId']),
      repeatRule: serializer.fromJson<String>(json['repeatRule']),
      reminder: serializer.fromJson<String>(json['reminder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'colorId': serializer.toJson<String>(colorId),
      'repeatRule': serializer.toJson<String>(repeatRule),
      'reminder': serializer.toJson<String>(reminder),
    };
  }

  HabitData copyWith({
    int? id,
    String? title,
    DateTime? createdAt,
    String? colorId,
    String? repeatRule,
    String? reminder,
  }) => HabitData(
    id: id ?? this.id,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    colorId: colorId ?? this.colorId,
    repeatRule: repeatRule ?? this.repeatRule,
    reminder: reminder ?? this.reminder,
  );
  HabitData copyWithCompanion(HabitCompanion data) {
    return HabitData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      colorId: data.colorId.present ? data.colorId.value : this.colorId,
      repeatRule: data.repeatRule.present
          ? data.repeatRule.value
          : this.repeatRule,
      reminder: data.reminder.present ? data.reminder.value : this.reminder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('colorId: $colorId, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('reminder: $reminder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, createdAt, colorId, repeatRule, reminder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitData &&
          other.id == this.id &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.colorId == this.colorId &&
          other.repeatRule == this.repeatRule &&
          other.reminder == this.reminder);
}

class HabitCompanion extends UpdateCompanion<HabitData> {
  final Value<int> id;
  final Value<String> title;
  final Value<DateTime> createdAt;
  final Value<String> colorId;
  final Value<String> repeatRule;
  final Value<String> reminder;
  const HabitCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.colorId = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.reminder = const Value.absent(),
  });
  HabitCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required DateTime createdAt,
    this.colorId = const Value.absent(),
    required String repeatRule,
    this.reminder = const Value.absent(),
  }) : title = Value(title),
       createdAt = Value(createdAt),
       repeatRule = Value(repeatRule);
  static Insertable<HabitData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<String>? colorId,
    Expression<String>? repeatRule,
    Expression<String>? reminder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (colorId != null) 'color_id': colorId,
      if (repeatRule != null) 'repeat_rule': repeatRule,
      if (reminder != null) 'reminder': reminder,
    });
  }

  HabitCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<DateTime>? createdAt,
    Value<String>? colorId,
    Value<String>? repeatRule,
    Value<String>? reminder,
  }) {
    return HabitCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      colorId: colorId ?? this.colorId,
      repeatRule: repeatRule ?? this.repeatRule,
      reminder: reminder ?? this.reminder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (colorId.present) {
      map['color_id'] = Variable<String>(colorId.value);
    }
    if (repeatRule.present) {
      map['repeat_rule'] = Variable<String>(repeatRule.value);
    }
    if (reminder.present) {
      map['reminder'] = Variable<String>(reminder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('colorId: $colorId, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('reminder: $reminder')
          ..write(')'))
        .toString();
  }
}

class $HabitCompletionTable extends HabitCompletion
    with TableInfo<$HabitCompletionTable, HabitCompletionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitCompletionTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedDateMeta = const VerificationMeta(
    'completedDate',
  );
  @override
  late final GeneratedColumn<DateTime> completedDate =
      GeneratedColumn<DateTime>(
        'completed_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [id, habitId, completedDate, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_completion';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitCompletionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('completed_date')) {
      context.handle(
        _completedDateMeta,
        completedDate.isAcceptableOrUnknown(
          data['completed_date']!,
          _completedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitCompletionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitCompletionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      completedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HabitCompletionTable createAlias(String alias) {
    return $HabitCompletionTable(attachedDatabase, alias);
  }
}

class HabitCompletionData extends DataClass
    implements Insertable<HabitCompletionData> {
  final int id;
  final int habitId;
  final DateTime completedDate;
  final DateTime createdAt;
  const HabitCompletionData({
    required this.id,
    required this.habitId,
    required this.completedDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<int>(habitId);
    map['completed_date'] = Variable<DateTime>(completedDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HabitCompletionCompanion toCompanion(bool nullToAbsent) {
    return HabitCompletionCompanion(
      id: Value(id),
      habitId: Value(habitId),
      completedDate: Value(completedDate),
      createdAt: Value(createdAt),
    );
  }

  factory HabitCompletionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitCompletionData(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<int>(json['habitId']),
      completedDate: serializer.fromJson<DateTime>(json['completedDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<int>(habitId),
      'completedDate': serializer.toJson<DateTime>(completedDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HabitCompletionData copyWith({
    int? id,
    int? habitId,
    DateTime? completedDate,
    DateTime? createdAt,
  }) => HabitCompletionData(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    completedDate: completedDate ?? this.completedDate,
    createdAt: createdAt ?? this.createdAt,
  );
  HabitCompletionData copyWithCompanion(HabitCompletionCompanion data) {
    return HabitCompletionData(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      completedDate: data.completedDate.present
          ? data.completedDate.value
          : this.completedDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitCompletionData(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('completedDate: $completedDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, completedDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitCompletionData &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.completedDate == this.completedDate &&
          other.createdAt == this.createdAt);
}

class HabitCompletionCompanion extends UpdateCompanion<HabitCompletionData> {
  final Value<int> id;
  final Value<int> habitId;
  final Value<DateTime> completedDate;
  final Value<DateTime> createdAt;
  const HabitCompletionCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HabitCompletionCompanion.insert({
    this.id = const Value.absent(),
    required int habitId,
    required DateTime completedDate,
    required DateTime createdAt,
  }) : habitId = Value(habitId),
       completedDate = Value(completedDate),
       createdAt = Value(createdAt);
  static Insertable<HabitCompletionData> custom({
    Expression<int>? id,
    Expression<int>? habitId,
    Expression<DateTime>? completedDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (completedDate != null) 'completed_date': completedDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HabitCompletionCompanion copyWith({
    Value<int>? id,
    Value<int>? habitId,
    Value<DateTime>? completedDate,
    Value<DateTime>? createdAt,
  }) {
    return HabitCompletionCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      completedDate: completedDate ?? this.completedDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (completedDate.present) {
      map['completed_date'] = Variable<DateTime>(completedDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitCompletionCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('completedDate: $completedDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailyCardOrderTable extends DailyCardOrder
    with TableInfo<$DailyCardOrderTable, DailyCardOrderData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyCardOrderTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardTypeMeta = const VerificationMeta(
    'cardType',
  );
  @override
  late final GeneratedColumn<String> cardType = GeneratedColumn<String>(
    'card_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    cardType,
    cardId,
    sortOrder,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_card_order';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyCardOrderData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('card_type')) {
      context.handle(
        _cardTypeMeta,
        cardType.isAcceptableOrUnknown(data['card_type']!, _cardTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_cardTypeMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyCardOrderData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyCardOrderData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      cardType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_type'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailyCardOrderTable createAlias(String alias) {
    return $DailyCardOrderTable(attachedDatabase, alias);
  }
}

class DailyCardOrderData extends DataClass
    implements Insertable<DailyCardOrderData> {
  final int id;
  final DateTime date;
  final String cardType;
  final int cardId;
  final int sortOrder;
  final DateTime updatedAt;
  const DailyCardOrderData({
    required this.id,
    required this.date,
    required this.cardType,
    required this.cardId,
    required this.sortOrder,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['card_type'] = Variable<String>(cardType);
    map['card_id'] = Variable<int>(cardId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyCardOrderCompanion toCompanion(bool nullToAbsent) {
    return DailyCardOrderCompanion(
      id: Value(id),
      date: Value(date),
      cardType: Value(cardType),
      cardId: Value(cardId),
      sortOrder: Value(sortOrder),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyCardOrderData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyCardOrderData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      cardType: serializer.fromJson<String>(json['cardType']),
      cardId: serializer.fromJson<int>(json['cardId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'cardType': serializer.toJson<String>(cardType),
      'cardId': serializer.toJson<int>(cardId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyCardOrderData copyWith({
    int? id,
    DateTime? date,
    String? cardType,
    int? cardId,
    int? sortOrder,
    DateTime? updatedAt,
  }) => DailyCardOrderData(
    id: id ?? this.id,
    date: date ?? this.date,
    cardType: cardType ?? this.cardType,
    cardId: cardId ?? this.cardId,
    sortOrder: sortOrder ?? this.sortOrder,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailyCardOrderData copyWithCompanion(DailyCardOrderCompanion data) {
    return DailyCardOrderData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      cardType: data.cardType.present ? data.cardType.value : this.cardType,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyCardOrderData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('cardType: $cardType, ')
          ..write('cardId: $cardId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, cardType, cardId, sortOrder, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyCardOrderData &&
          other.id == this.id &&
          other.date == this.date &&
          other.cardType == this.cardType &&
          other.cardId == this.cardId &&
          other.sortOrder == this.sortOrder &&
          other.updatedAt == this.updatedAt);
}

class DailyCardOrderCompanion extends UpdateCompanion<DailyCardOrderData> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> cardType;
  final Value<int> cardId;
  final Value<int> sortOrder;
  final Value<DateTime> updatedAt;
  const DailyCardOrderCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.cardType = const Value.absent(),
    this.cardId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DailyCardOrderCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String cardType,
    required int cardId,
    required int sortOrder,
    this.updatedAt = const Value.absent(),
  }) : date = Value(date),
       cardType = Value(cardType),
       cardId = Value(cardId),
       sortOrder = Value(sortOrder);
  static Insertable<DailyCardOrderData> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? cardType,
    Expression<int>? cardId,
    Expression<int>? sortOrder,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (cardType != null) 'card_type': cardType,
      if (cardId != null) 'card_id': cardId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DailyCardOrderCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? cardType,
    Value<int>? cardId,
    Value<int>? sortOrder,
    Value<DateTime>? updatedAt,
  }) {
    return DailyCardOrderCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      cardType: cardType ?? this.cardType,
      cardId: cardId ?? this.cardId,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (cardType.present) {
      map['card_type'] = Variable<String>(cardType.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyCardOrderCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('cardType: $cardType, ')
          ..write('cardId: $cardId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AudioContentsTable extends AudioContents
    with TableInfo<$AudioContentsTable, AudioContentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioContentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastPositionMsMeta = const VerificationMeta(
    'lastPositionMs',
  );
  @override
  late final GeneratedColumn<int> lastPositionMs = GeneratedColumn<int>(
    'last_position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    subtitle,
    audioPath,
    durationSeconds,
    targetDate,
    createdAt,
    lastPositionMs,
    isCompleted,
    lastPlayedAt,
    completedAt,
    playCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_contents';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioContentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    } else if (isInserting) {
      context.missing(_subtitleMeta);
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    } else if (isInserting) {
      context.missing(_audioPathMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    } else if (isInserting) {
      context.missing(_targetDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_position_ms')) {
      context.handle(
        _lastPositionMsMeta,
        lastPositionMs.isAcceptableOrUnknown(
          data['last_position_ms']!,
          _lastPositionMsMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {targetDate},
  ];
  @override
  AudioContentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioContentData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      )!,
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastPositionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_position_ms'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
    );
  }

  @override
  $AudioContentsTable createAlias(String alias) {
    return $AudioContentsTable(attachedDatabase, alias);
  }
}

class AudioContentData extends DataClass
    implements Insertable<AudioContentData> {
  final int id;
  final String title;
  final String subtitle;
  final String audioPath;
  final int durationSeconds;
  final DateTime targetDate;
  final DateTime createdAt;
  final int lastPositionMs;
  final bool isCompleted;
  final DateTime? lastPlayedAt;
  final DateTime? completedAt;
  final int playCount;
  const AudioContentData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.audioPath,
    required this.durationSeconds,
    required this.targetDate,
    required this.createdAt,
    required this.lastPositionMs,
    required this.isCompleted,
    this.lastPlayedAt,
    this.completedAt,
    required this.playCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['subtitle'] = Variable<String>(subtitle);
    map['audio_path'] = Variable<String>(audioPath);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['target_date'] = Variable<DateTime>(targetDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_position_ms'] = Variable<int>(lastPositionMs);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['play_count'] = Variable<int>(playCount);
    return map;
  }

  AudioContentsCompanion toCompanion(bool nullToAbsent) {
    return AudioContentsCompanion(
      id: Value(id),
      title: Value(title),
      subtitle: Value(subtitle),
      audioPath: Value(audioPath),
      durationSeconds: Value(durationSeconds),
      targetDate: Value(targetDate),
      createdAt: Value(createdAt),
      lastPositionMs: Value(lastPositionMs),
      isCompleted: Value(isCompleted),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      playCount: Value(playCount),
    );
  }

  factory AudioContentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioContentData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      audioPath: serializer.fromJson<String>(json['audioPath']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      targetDate: serializer.fromJson<DateTime>(json['targetDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastPositionMs: serializer.fromJson<int>(json['lastPositionMs']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      playCount: serializer.fromJson<int>(json['playCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String>(subtitle),
      'audioPath': serializer.toJson<String>(audioPath),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'targetDate': serializer.toJson<DateTime>(targetDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastPositionMs': serializer.toJson<int>(lastPositionMs),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'playCount': serializer.toJson<int>(playCount),
    };
  }

  AudioContentData copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? audioPath,
    int? durationSeconds,
    DateTime? targetDate,
    DateTime? createdAt,
    int? lastPositionMs,
    bool? isCompleted,
    Value<DateTime?> lastPlayedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    int? playCount,
  }) => AudioContentData(
    id: id ?? this.id,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    audioPath: audioPath ?? this.audioPath,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    targetDate: targetDate ?? this.targetDate,
    createdAt: createdAt ?? this.createdAt,
    lastPositionMs: lastPositionMs ?? this.lastPositionMs,
    isCompleted: isCompleted ?? this.isCompleted,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    playCount: playCount ?? this.playCount,
  );
  AudioContentData copyWithCompanion(AudioContentsCompanion data) {
    return AudioContentData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastPositionMs: data.lastPositionMs.present
          ? data.lastPositionMs.value
          : this.lastPositionMs,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioContentData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('audioPath: $audioPath, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('targetDate: $targetDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastPositionMs: $lastPositionMs, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('playCount: $playCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    subtitle,
    audioPath,
    durationSeconds,
    targetDate,
    createdAt,
    lastPositionMs,
    isCompleted,
    lastPlayedAt,
    completedAt,
    playCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioContentData &&
          other.id == this.id &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.audioPath == this.audioPath &&
          other.durationSeconds == this.durationSeconds &&
          other.targetDate == this.targetDate &&
          other.createdAt == this.createdAt &&
          other.lastPositionMs == this.lastPositionMs &&
          other.isCompleted == this.isCompleted &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.completedAt == this.completedAt &&
          other.playCount == this.playCount);
}

class AudioContentsCompanion extends UpdateCompanion<AudioContentData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> subtitle;
  final Value<String> audioPath;
  final Value<int> durationSeconds;
  final Value<DateTime> targetDate;
  final Value<DateTime> createdAt;
  final Value<int> lastPositionMs;
  final Value<bool> isCompleted;
  final Value<DateTime?> lastPlayedAt;
  final Value<DateTime?> completedAt;
  final Value<int> playCount;
  const AudioContentsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastPositionMs = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.playCount = const Value.absent(),
  });
  AudioContentsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String subtitle,
    required String audioPath,
    required int durationSeconds,
    required DateTime targetDate,
    this.createdAt = const Value.absent(),
    this.lastPositionMs = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.playCount = const Value.absent(),
  }) : title = Value(title),
       subtitle = Value(subtitle),
       audioPath = Value(audioPath),
       durationSeconds = Value(durationSeconds),
       targetDate = Value(targetDate);
  static Insertable<AudioContentData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? audioPath,
    Expression<int>? durationSeconds,
    Expression<DateTime>? targetDate,
    Expression<DateTime>? createdAt,
    Expression<int>? lastPositionMs,
    Expression<bool>? isCompleted,
    Expression<DateTime>? lastPlayedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? playCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (audioPath != null) 'audio_path': audioPath,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (targetDate != null) 'target_date': targetDate,
      if (createdAt != null) 'created_at': createdAt,
      if (lastPositionMs != null) 'last_position_ms': lastPositionMs,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (playCount != null) 'play_count': playCount,
    });
  }

  AudioContentsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? subtitle,
    Value<String>? audioPath,
    Value<int>? durationSeconds,
    Value<DateTime>? targetDate,
    Value<DateTime>? createdAt,
    Value<int>? lastPositionMs,
    Value<bool>? isCompleted,
    Value<DateTime?>? lastPlayedAt,
    Value<DateTime?>? completedAt,
    Value<int>? playCount,
  }) {
    return AudioContentsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      audioPath: audioPath ?? this.audioPath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      lastPositionMs: lastPositionMs ?? this.lastPositionMs,
      isCompleted: isCompleted ?? this.isCompleted,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      completedAt: completedAt ?? this.completedAt,
      playCount: playCount ?? this.playCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastPositionMs.present) {
      map['last_position_ms'] = Variable<int>(lastPositionMs.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioContentsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('audioPath: $audioPath, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('targetDate: $targetDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastPositionMs: $lastPositionMs, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('playCount: $playCount')
          ..write(')'))
        .toString();
  }
}

class $TranscriptLinesTable extends TranscriptLines
    with TableInfo<$TranscriptLinesTable, TranscriptLineData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranscriptLinesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _audioContentIdMeta = const VerificationMeta(
    'audioContentId',
  );
  @override
  late final GeneratedColumn<int> audioContentId = GeneratedColumn<int>(
    'audio_content_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audio_contents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMsMeta = const VerificationMeta(
    'startTimeMs',
  );
  @override
  late final GeneratedColumn<int> startTimeMs = GeneratedColumn<int>(
    'start_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMsMeta = const VerificationMeta(
    'endTimeMs',
  );
  @override
  late final GeneratedColumn<int> endTimeMs = GeneratedColumn<int>(
    'end_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    audioContentId,
    sequence,
    startTimeMs,
    endTimeMs,
    content,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transcript_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<TranscriptLineData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('audio_content_id')) {
      context.handle(
        _audioContentIdMeta,
        audioContentId.isAcceptableOrUnknown(
          data['audio_content_id']!,
          _audioContentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_audioContentIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('start_time_ms')) {
      context.handle(
        _startTimeMsMeta,
        startTimeMs.isAcceptableOrUnknown(
          data['start_time_ms']!,
          _startTimeMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startTimeMsMeta);
    }
    if (data.containsKey('end_time_ms')) {
      context.handle(
        _endTimeMsMeta,
        endTimeMs.isAcceptableOrUnknown(data['end_time_ms']!, _endTimeMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMsMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {audioContentId, sequence},
  ];
  @override
  TranscriptLineData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranscriptLineData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      audioContentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_content_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      startTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time_ms'],
      )!,
      endTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_time_ms'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $TranscriptLinesTable createAlias(String alias) {
    return $TranscriptLinesTable(attachedDatabase, alias);
  }
}

class TranscriptLineData extends DataClass
    implements Insertable<TranscriptLineData> {
  final int id;
  final int audioContentId;
  final int sequence;
  final int startTimeMs;
  final int endTimeMs;
  final String content;
  const TranscriptLineData({
    required this.id,
    required this.audioContentId,
    required this.sequence,
    required this.startTimeMs,
    required this.endTimeMs,
    required this.content,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['audio_content_id'] = Variable<int>(audioContentId);
    map['sequence'] = Variable<int>(sequence);
    map['start_time_ms'] = Variable<int>(startTimeMs);
    map['end_time_ms'] = Variable<int>(endTimeMs);
    map['content'] = Variable<String>(content);
    return map;
  }

  TranscriptLinesCompanion toCompanion(bool nullToAbsent) {
    return TranscriptLinesCompanion(
      id: Value(id),
      audioContentId: Value(audioContentId),
      sequence: Value(sequence),
      startTimeMs: Value(startTimeMs),
      endTimeMs: Value(endTimeMs),
      content: Value(content),
    );
  }

  factory TranscriptLineData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranscriptLineData(
      id: serializer.fromJson<int>(json['id']),
      audioContentId: serializer.fromJson<int>(json['audioContentId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      startTimeMs: serializer.fromJson<int>(json['startTimeMs']),
      endTimeMs: serializer.fromJson<int>(json['endTimeMs']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'audioContentId': serializer.toJson<int>(audioContentId),
      'sequence': serializer.toJson<int>(sequence),
      'startTimeMs': serializer.toJson<int>(startTimeMs),
      'endTimeMs': serializer.toJson<int>(endTimeMs),
      'content': serializer.toJson<String>(content),
    };
  }

  TranscriptLineData copyWith({
    int? id,
    int? audioContentId,
    int? sequence,
    int? startTimeMs,
    int? endTimeMs,
    String? content,
  }) => TranscriptLineData(
    id: id ?? this.id,
    audioContentId: audioContentId ?? this.audioContentId,
    sequence: sequence ?? this.sequence,
    startTimeMs: startTimeMs ?? this.startTimeMs,
    endTimeMs: endTimeMs ?? this.endTimeMs,
    content: content ?? this.content,
  );
  TranscriptLineData copyWithCompanion(TranscriptLinesCompanion data) {
    return TranscriptLineData(
      id: data.id.present ? data.id.value : this.id,
      audioContentId: data.audioContentId.present
          ? data.audioContentId.value
          : this.audioContentId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      startTimeMs: data.startTimeMs.present
          ? data.startTimeMs.value
          : this.startTimeMs,
      endTimeMs: data.endTimeMs.present ? data.endTimeMs.value : this.endTimeMs,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptLineData(')
          ..write('id: $id, ')
          ..write('audioContentId: $audioContentId, ')
          ..write('sequence: $sequence, ')
          ..write('startTimeMs: $startTimeMs, ')
          ..write('endTimeMs: $endTimeMs, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    audioContentId,
    sequence,
    startTimeMs,
    endTimeMs,
    content,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranscriptLineData &&
          other.id == this.id &&
          other.audioContentId == this.audioContentId &&
          other.sequence == this.sequence &&
          other.startTimeMs == this.startTimeMs &&
          other.endTimeMs == this.endTimeMs &&
          other.content == this.content);
}

class TranscriptLinesCompanion extends UpdateCompanion<TranscriptLineData> {
  final Value<int> id;
  final Value<int> audioContentId;
  final Value<int> sequence;
  final Value<int> startTimeMs;
  final Value<int> endTimeMs;
  final Value<String> content;
  const TranscriptLinesCompanion({
    this.id = const Value.absent(),
    this.audioContentId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.startTimeMs = const Value.absent(),
    this.endTimeMs = const Value.absent(),
    this.content = const Value.absent(),
  });
  TranscriptLinesCompanion.insert({
    this.id = const Value.absent(),
    required int audioContentId,
    required int sequence,
    required int startTimeMs,
    required int endTimeMs,
    required String content,
  }) : audioContentId = Value(audioContentId),
       sequence = Value(sequence),
       startTimeMs = Value(startTimeMs),
       endTimeMs = Value(endTimeMs),
       content = Value(content);
  static Insertable<TranscriptLineData> custom({
    Expression<int>? id,
    Expression<int>? audioContentId,
    Expression<int>? sequence,
    Expression<int>? startTimeMs,
    Expression<int>? endTimeMs,
    Expression<String>? content,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (audioContentId != null) 'audio_content_id': audioContentId,
      if (sequence != null) 'sequence': sequence,
      if (startTimeMs != null) 'start_time_ms': startTimeMs,
      if (endTimeMs != null) 'end_time_ms': endTimeMs,
      if (content != null) 'content': content,
    });
  }

  TranscriptLinesCompanion copyWith({
    Value<int>? id,
    Value<int>? audioContentId,
    Value<int>? sequence,
    Value<int>? startTimeMs,
    Value<int>? endTimeMs,
    Value<String>? content,
  }) {
    return TranscriptLinesCompanion(
      id: id ?? this.id,
      audioContentId: audioContentId ?? this.audioContentId,
      sequence: sequence ?? this.sequence,
      startTimeMs: startTimeMs ?? this.startTimeMs,
      endTimeMs: endTimeMs ?? this.endTimeMs,
      content: content ?? this.content,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (audioContentId.present) {
      map['audio_content_id'] = Variable<int>(audioContentId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (startTimeMs.present) {
      map['start_time_ms'] = Variable<int>(startTimeMs.value);
    }
    if (endTimeMs.present) {
      map['end_time_ms'] = Variable<int>(endTimeMs.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptLinesCompanion(')
          ..write('id: $id, ')
          ..write('audioContentId: $audioContentId, ')
          ..write('sequence: $sequence, ')
          ..write('startTimeMs: $startTimeMs, ')
          ..write('endTimeMs: $endTimeMs, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ScheduleTable schedule = $ScheduleTable(this);
  late final $TaskTable task = $TaskTable(this);
  late final $HabitTable habit = $HabitTable(this);
  late final $HabitCompletionTable habitCompletion = $HabitCompletionTable(
    this,
  );
  late final $DailyCardOrderTable dailyCardOrder = $DailyCardOrderTable(this);
  late final $AudioContentsTable audioContents = $AudioContentsTable(this);
  late final $TranscriptLinesTable transcriptLines = $TranscriptLinesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    schedule,
    task,
    habit,
    habitCompletion,
    dailyCardOrder,
    audioContents,
    transcriptLines,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'audio_contents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transcript_lines', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ScheduleTableCreateCompanionBuilder =
    ScheduleCompanion Function({
      required DateTime start,
      required DateTime end,
      Value<int> id,
      required String summary,
      Value<String> description,
      Value<String> location,
      required String colorId,
      required String repeatRule,
      required String alertSetting,
      Value<bool> isAllDay,
      Value<DateTime> createdAt,
      required String status,
      required String visibility,
    });
typedef $$ScheduleTableUpdateCompanionBuilder =
    ScheduleCompanion Function({
      Value<DateTime> start,
      Value<DateTime> end,
      Value<int> id,
      Value<String> summary,
      Value<String> description,
      Value<String> location,
      Value<String> colorId,
      Value<String> repeatRule,
      Value<String> alertSetting,
      Value<bool> isAllDay,
      Value<DateTime> createdAt,
      Value<String> status,
      Value<String> visibility,
    });

class $$ScheduleTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleTable> {
  $$ScheduleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alertSetting => $composableBuilder(
    column: $table.alertSetting,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScheduleTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleTable> {
  $$ScheduleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alertSetting => $composableBuilder(
    column: $table.alertSetting,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduleTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleTable> {
  $$ScheduleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get start =>
      $composableBuilder(column: $table.start, builder: (column) => column);

  GeneratedColumn<DateTime> get end =>
      $composableBuilder(column: $table.end, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get colorId =>
      $composableBuilder(column: $table.colorId, builder: (column) => column);

  GeneratedColumn<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alertSetting => $composableBuilder(
    column: $table.alertSetting,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAllDay =>
      $composableBuilder(column: $table.isAllDay, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );
}

class $$ScheduleTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduleTable,
          ScheduleData,
          $$ScheduleTableFilterComposer,
          $$ScheduleTableOrderingComposer,
          $$ScheduleTableAnnotationComposer,
          $$ScheduleTableCreateCompanionBuilder,
          $$ScheduleTableUpdateCompanionBuilder,
          (
            ScheduleData,
            BaseReferences<_$AppDatabase, $ScheduleTable, ScheduleData>,
          ),
          ScheduleData,
          PrefetchHooks Function()
        > {
  $$ScheduleTableTableManager(_$AppDatabase db, $ScheduleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> start = const Value.absent(),
                Value<DateTime> end = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> colorId = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<String> alertSetting = const Value.absent(),
                Value<bool> isAllDay = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> visibility = const Value.absent(),
              }) => ScheduleCompanion(
                start: start,
                end: end,
                id: id,
                summary: summary,
                description: description,
                location: location,
                colorId: colorId,
                repeatRule: repeatRule,
                alertSetting: alertSetting,
                isAllDay: isAllDay,
                createdAt: createdAt,
                status: status,
                visibility: visibility,
              ),
          createCompanionCallback:
              ({
                required DateTime start,
                required DateTime end,
                Value<int> id = const Value.absent(),
                required String summary,
                Value<String> description = const Value.absent(),
                Value<String> location = const Value.absent(),
                required String colorId,
                required String repeatRule,
                required String alertSetting,
                Value<bool> isAllDay = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String status,
                required String visibility,
              }) => ScheduleCompanion.insert(
                start: start,
                end: end,
                id: id,
                summary: summary,
                description: description,
                location: location,
                colorId: colorId,
                repeatRule: repeatRule,
                alertSetting: alertSetting,
                isAllDay: isAllDay,
                createdAt: createdAt,
                status: status,
                visibility: visibility,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScheduleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduleTable,
      ScheduleData,
      $$ScheduleTableFilterComposer,
      $$ScheduleTableOrderingComposer,
      $$ScheduleTableAnnotationComposer,
      $$ScheduleTableCreateCompanionBuilder,
      $$ScheduleTableUpdateCompanionBuilder,
      (
        ScheduleData,
        BaseReferences<_$AppDatabase, $ScheduleTable, ScheduleData>,
      ),
      ScheduleData,
      PrefetchHooks Function()
    >;
typedef $$TaskTableCreateCompanionBuilder =
    TaskCompanion Function({
      Value<int> id,
      required String title,
      Value<bool> completed,
      Value<DateTime?> dueDate,
      Value<DateTime?> executionDate,
      Value<String> listId,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
      Value<String> colorId,
      Value<String> repeatRule,
      Value<String> reminder,
    });
typedef $$TaskTableUpdateCompanionBuilder =
    TaskCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<bool> completed,
      Value<DateTime?> dueDate,
      Value<DateTime?> executionDate,
      Value<String> listId,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
      Value<String> colorId,
      Value<String> repeatRule,
      Value<String> reminder,
    });

class $$TaskTableFilterComposer extends Composer<_$AppDatabase, $TaskTable> {
  $$TaskTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get executionDate => $composableBuilder(
    column: $table.executionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminder => $composableBuilder(
    column: $table.reminder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskTableOrderingComposer extends Composer<_$AppDatabase, $TaskTable> {
  $$TaskTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get executionDate => $composableBuilder(
    column: $table.executionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminder => $composableBuilder(
    column: $table.reminder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskTable> {
  $$TaskTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get executionDate => $composableBuilder(
    column: $table.executionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorId =>
      $composableBuilder(column: $table.colorId, builder: (column) => column);

  GeneratedColumn<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminder =>
      $composableBuilder(column: $table.reminder, builder: (column) => column);
}

class $$TaskTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskTable,
          TaskData,
          $$TaskTableFilterComposer,
          $$TaskTableOrderingComposer,
          $$TaskTableAnnotationComposer,
          $$TaskTableCreateCompanionBuilder,
          $$TaskTableUpdateCompanionBuilder,
          (TaskData, BaseReferences<_$AppDatabase, $TaskTable, TaskData>),
          TaskData,
          PrefetchHooks Function()
        > {
  $$TaskTableTableManager(_$AppDatabase db, $TaskTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> executionDate = const Value.absent(),
                Value<String> listId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String> colorId = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<String> reminder = const Value.absent(),
              }) => TaskCompanion(
                id: id,
                title: title,
                completed: completed,
                dueDate: dueDate,
                executionDate: executionDate,
                listId: listId,
                createdAt: createdAt,
                completedAt: completedAt,
                colorId: colorId,
                repeatRule: repeatRule,
                reminder: reminder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> executionDate = const Value.absent(),
                Value<String> listId = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String> colorId = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<String> reminder = const Value.absent(),
              }) => TaskCompanion.insert(
                id: id,
                title: title,
                completed: completed,
                dueDate: dueDate,
                executionDate: executionDate,
                listId: listId,
                createdAt: createdAt,
                completedAt: completedAt,
                colorId: colorId,
                repeatRule: repeatRule,
                reminder: reminder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskTable,
      TaskData,
      $$TaskTableFilterComposer,
      $$TaskTableOrderingComposer,
      $$TaskTableAnnotationComposer,
      $$TaskTableCreateCompanionBuilder,
      $$TaskTableUpdateCompanionBuilder,
      (TaskData, BaseReferences<_$AppDatabase, $TaskTable, TaskData>),
      TaskData,
      PrefetchHooks Function()
    >;
typedef $$HabitTableCreateCompanionBuilder =
    HabitCompanion Function({
      Value<int> id,
      required String title,
      required DateTime createdAt,
      Value<String> colorId,
      required String repeatRule,
      Value<String> reminder,
    });
typedef $$HabitTableUpdateCompanionBuilder =
    HabitCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<DateTime> createdAt,
      Value<String> colorId,
      Value<String> repeatRule,
      Value<String> reminder,
    });

class $$HabitTableFilterComposer extends Composer<_$AppDatabase, $HabitTable> {
  $$HabitTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminder => $composableBuilder(
    column: $table.reminder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitTable> {
  $$HabitTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminder => $composableBuilder(
    column: $table.reminder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitTable> {
  $$HabitTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get colorId =>
      $composableBuilder(column: $table.colorId, builder: (column) => column);

  GeneratedColumn<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminder =>
      $composableBuilder(column: $table.reminder, builder: (column) => column);
}

class $$HabitTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitTable,
          HabitData,
          $$HabitTableFilterComposer,
          $$HabitTableOrderingComposer,
          $$HabitTableAnnotationComposer,
          $$HabitTableCreateCompanionBuilder,
          $$HabitTableUpdateCompanionBuilder,
          (HabitData, BaseReferences<_$AppDatabase, $HabitTable, HabitData>),
          HabitData,
          PrefetchHooks Function()
        > {
  $$HabitTableTableManager(_$AppDatabase db, $HabitTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> colorId = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<String> reminder = const Value.absent(),
              }) => HabitCompanion(
                id: id,
                title: title,
                createdAt: createdAt,
                colorId: colorId,
                repeatRule: repeatRule,
                reminder: reminder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required DateTime createdAt,
                Value<String> colorId = const Value.absent(),
                required String repeatRule,
                Value<String> reminder = const Value.absent(),
              }) => HabitCompanion.insert(
                id: id,
                title: title,
                createdAt: createdAt,
                colorId: colorId,
                repeatRule: repeatRule,
                reminder: reminder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitTable,
      HabitData,
      $$HabitTableFilterComposer,
      $$HabitTableOrderingComposer,
      $$HabitTableAnnotationComposer,
      $$HabitTableCreateCompanionBuilder,
      $$HabitTableUpdateCompanionBuilder,
      (HabitData, BaseReferences<_$AppDatabase, $HabitTable, HabitData>),
      HabitData,
      PrefetchHooks Function()
    >;
typedef $$HabitCompletionTableCreateCompanionBuilder =
    HabitCompletionCompanion Function({
      Value<int> id,
      required int habitId,
      required DateTime completedDate,
      required DateTime createdAt,
    });
typedef $$HabitCompletionTableUpdateCompanionBuilder =
    HabitCompletionCompanion Function({
      Value<int> id,
      Value<int> habitId,
      Value<DateTime> completedDate,
      Value<DateTime> createdAt,
    });

class $$HabitCompletionTableFilterComposer
    extends Composer<_$AppDatabase, $HabitCompletionTable> {
  $$HabitCompletionTableFilterComposer({
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

  ColumnFilters<int> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitCompletionTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitCompletionTable> {
  $$HabitCompletionTableOrderingComposer({
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

  ColumnOrderings<int> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitCompletionTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitCompletionTable> {
  $$HabitCompletionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HabitCompletionTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitCompletionTable,
          HabitCompletionData,
          $$HabitCompletionTableFilterComposer,
          $$HabitCompletionTableOrderingComposer,
          $$HabitCompletionTableAnnotationComposer,
          $$HabitCompletionTableCreateCompanionBuilder,
          $$HabitCompletionTableUpdateCompanionBuilder,
          (
            HabitCompletionData,
            BaseReferences<
              _$AppDatabase,
              $HabitCompletionTable,
              HabitCompletionData
            >,
          ),
          HabitCompletionData,
          PrefetchHooks Function()
        > {
  $$HabitCompletionTableTableManager(
    _$AppDatabase db,
    $HabitCompletionTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitCompletionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitCompletionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitCompletionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> habitId = const Value.absent(),
                Value<DateTime> completedDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HabitCompletionCompanion(
                id: id,
                habitId: habitId,
                completedDate: completedDate,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int habitId,
                required DateTime completedDate,
                required DateTime createdAt,
              }) => HabitCompletionCompanion.insert(
                id: id,
                habitId: habitId,
                completedDate: completedDate,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitCompletionTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitCompletionTable,
      HabitCompletionData,
      $$HabitCompletionTableFilterComposer,
      $$HabitCompletionTableOrderingComposer,
      $$HabitCompletionTableAnnotationComposer,
      $$HabitCompletionTableCreateCompanionBuilder,
      $$HabitCompletionTableUpdateCompanionBuilder,
      (
        HabitCompletionData,
        BaseReferences<
          _$AppDatabase,
          $HabitCompletionTable,
          HabitCompletionData
        >,
      ),
      HabitCompletionData,
      PrefetchHooks Function()
    >;
typedef $$DailyCardOrderTableCreateCompanionBuilder =
    DailyCardOrderCompanion Function({
      Value<int> id,
      required DateTime date,
      required String cardType,
      required int cardId,
      required int sortOrder,
      Value<DateTime> updatedAt,
    });
typedef $$DailyCardOrderTableUpdateCompanionBuilder =
    DailyCardOrderCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<String> cardType,
      Value<int> cardId,
      Value<int> sortOrder,
      Value<DateTime> updatedAt,
    });

class $$DailyCardOrderTableFilterComposer
    extends Composer<_$AppDatabase, $DailyCardOrderTable> {
  $$DailyCardOrderTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardType => $composableBuilder(
    column: $table.cardType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyCardOrderTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyCardOrderTable> {
  $$DailyCardOrderTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardType => $composableBuilder(
    column: $table.cardType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyCardOrderTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyCardOrderTable> {
  $$DailyCardOrderTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get cardType =>
      $composableBuilder(column: $table.cardType, builder: (column) => column);

  GeneratedColumn<int> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailyCardOrderTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyCardOrderTable,
          DailyCardOrderData,
          $$DailyCardOrderTableFilterComposer,
          $$DailyCardOrderTableOrderingComposer,
          $$DailyCardOrderTableAnnotationComposer,
          $$DailyCardOrderTableCreateCompanionBuilder,
          $$DailyCardOrderTableUpdateCompanionBuilder,
          (
            DailyCardOrderData,
            BaseReferences<
              _$AppDatabase,
              $DailyCardOrderTable,
              DailyCardOrderData
            >,
          ),
          DailyCardOrderData,
          PrefetchHooks Function()
        > {
  $$DailyCardOrderTableTableManager(
    _$AppDatabase db,
    $DailyCardOrderTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyCardOrderTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyCardOrderTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyCardOrderTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> cardType = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DailyCardOrderCompanion(
                id: id,
                date: date,
                cardType: cardType,
                cardId: cardId,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String cardType,
                required int cardId,
                required int sortOrder,
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DailyCardOrderCompanion.insert(
                id: id,
                date: date,
                cardType: cardType,
                cardId: cardId,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyCardOrderTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyCardOrderTable,
      DailyCardOrderData,
      $$DailyCardOrderTableFilterComposer,
      $$DailyCardOrderTableOrderingComposer,
      $$DailyCardOrderTableAnnotationComposer,
      $$DailyCardOrderTableCreateCompanionBuilder,
      $$DailyCardOrderTableUpdateCompanionBuilder,
      (
        DailyCardOrderData,
        BaseReferences<_$AppDatabase, $DailyCardOrderTable, DailyCardOrderData>,
      ),
      DailyCardOrderData,
      PrefetchHooks Function()
    >;
typedef $$AudioContentsTableCreateCompanionBuilder =
    AudioContentsCompanion Function({
      Value<int> id,
      required String title,
      required String subtitle,
      required String audioPath,
      required int durationSeconds,
      required DateTime targetDate,
      Value<DateTime> createdAt,
      Value<int> lastPositionMs,
      Value<bool> isCompleted,
      Value<DateTime?> lastPlayedAt,
      Value<DateTime?> completedAt,
      Value<int> playCount,
    });
typedef $$AudioContentsTableUpdateCompanionBuilder =
    AudioContentsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> subtitle,
      Value<String> audioPath,
      Value<int> durationSeconds,
      Value<DateTime> targetDate,
      Value<DateTime> createdAt,
      Value<int> lastPositionMs,
      Value<bool> isCompleted,
      Value<DateTime?> lastPlayedAt,
      Value<DateTime?> completedAt,
      Value<int> playCount,
    });

final class $$AudioContentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $AudioContentsTable, AudioContentData> {
  $$AudioContentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TranscriptLinesTable, List<TranscriptLineData>>
  _transcriptLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transcriptLines,
    aliasName: $_aliasNameGenerator(
      db.audioContents.id,
      db.transcriptLines.audioContentId,
    ),
  );

  $$TranscriptLinesTableProcessedTableManager get transcriptLinesRefs {
    final manager = $$TranscriptLinesTableTableManager(
      $_db,
      $_db.transcriptLines,
    ).filter((f) => f.audioContentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transcriptLinesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AudioContentsTableFilterComposer
    extends Composer<_$AppDatabase, $AudioContentsTable> {
  $$AudioContentsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transcriptLinesRefs(
    Expression<bool> Function($$TranscriptLinesTableFilterComposer f) f,
  ) {
    final $$TranscriptLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transcriptLines,
      getReferencedColumn: (t) => t.audioContentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TranscriptLinesTableFilterComposer(
            $db: $db,
            $table: $db.transcriptLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AudioContentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioContentsTable> {
  $$AudioContentsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioContentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioContentsTable> {
  $$AudioContentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  Expression<T> transcriptLinesRefs<T extends Object>(
    Expression<T> Function($$TranscriptLinesTableAnnotationComposer a) f,
  ) {
    final $$TranscriptLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transcriptLines,
      getReferencedColumn: (t) => t.audioContentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TranscriptLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.transcriptLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AudioContentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioContentsTable,
          AudioContentData,
          $$AudioContentsTableFilterComposer,
          $$AudioContentsTableOrderingComposer,
          $$AudioContentsTableAnnotationComposer,
          $$AudioContentsTableCreateCompanionBuilder,
          $$AudioContentsTableUpdateCompanionBuilder,
          (AudioContentData, $$AudioContentsTableReferences),
          AudioContentData,
          PrefetchHooks Function({bool transcriptLinesRefs})
        > {
  $$AudioContentsTableTableManager(_$AppDatabase db, $AudioContentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioContentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioContentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioContentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> subtitle = const Value.absent(),
                Value<String> audioPath = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<DateTime> targetDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> lastPositionMs = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> playCount = const Value.absent(),
              }) => AudioContentsCompanion(
                id: id,
                title: title,
                subtitle: subtitle,
                audioPath: audioPath,
                durationSeconds: durationSeconds,
                targetDate: targetDate,
                createdAt: createdAt,
                lastPositionMs: lastPositionMs,
                isCompleted: isCompleted,
                lastPlayedAt: lastPlayedAt,
                completedAt: completedAt,
                playCount: playCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String subtitle,
                required String audioPath,
                required int durationSeconds,
                required DateTime targetDate,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> lastPositionMs = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> playCount = const Value.absent(),
              }) => AudioContentsCompanion.insert(
                id: id,
                title: title,
                subtitle: subtitle,
                audioPath: audioPath,
                durationSeconds: durationSeconds,
                targetDate: targetDate,
                createdAt: createdAt,
                lastPositionMs: lastPositionMs,
                isCompleted: isCompleted,
                lastPlayedAt: lastPlayedAt,
                completedAt: completedAt,
                playCount: playCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AudioContentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transcriptLinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transcriptLinesRefs) db.transcriptLines,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transcriptLinesRefs)
                    await $_getPrefetchedData<
                      AudioContentData,
                      $AudioContentsTable,
                      TranscriptLineData
                    >(
                      currentTable: table,
                      referencedTable: $$AudioContentsTableReferences
                          ._transcriptLinesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AudioContentsTableReferences(
                            db,
                            table,
                            p0,
                          ).transcriptLinesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.audioContentId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AudioContentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioContentsTable,
      AudioContentData,
      $$AudioContentsTableFilterComposer,
      $$AudioContentsTableOrderingComposer,
      $$AudioContentsTableAnnotationComposer,
      $$AudioContentsTableCreateCompanionBuilder,
      $$AudioContentsTableUpdateCompanionBuilder,
      (AudioContentData, $$AudioContentsTableReferences),
      AudioContentData,
      PrefetchHooks Function({bool transcriptLinesRefs})
    >;
typedef $$TranscriptLinesTableCreateCompanionBuilder =
    TranscriptLinesCompanion Function({
      Value<int> id,
      required int audioContentId,
      required int sequence,
      required int startTimeMs,
      required int endTimeMs,
      required String content,
    });
typedef $$TranscriptLinesTableUpdateCompanionBuilder =
    TranscriptLinesCompanion Function({
      Value<int> id,
      Value<int> audioContentId,
      Value<int> sequence,
      Value<int> startTimeMs,
      Value<int> endTimeMs,
      Value<String> content,
    });

final class $$TranscriptLinesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TranscriptLinesTable,
          TranscriptLineData
        > {
  $$TranscriptLinesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AudioContentsTable _audioContentIdTable(_$AppDatabase db) =>
      db.audioContents.createAlias(
        $_aliasNameGenerator(
          db.transcriptLines.audioContentId,
          db.audioContents.id,
        ),
      );

  $$AudioContentsTableProcessedTableManager get audioContentId {
    final $_column = $_itemColumn<int>('audio_content_id')!;

    final manager = $$AudioContentsTableTableManager(
      $_db,
      $_db.audioContents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_audioContentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TranscriptLinesTableFilterComposer
    extends Composer<_$AppDatabase, $TranscriptLinesTable> {
  $$TranscriptLinesTableFilterComposer({
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

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTimeMs => $composableBuilder(
    column: $table.startTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endTimeMs => $composableBuilder(
    column: $table.endTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  $$AudioContentsTableFilterComposer get audioContentId {
    final $$AudioContentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audioContentId,
      referencedTable: $db.audioContents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioContentsTableFilterComposer(
            $db: $db,
            $table: $db.audioContents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TranscriptLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $TranscriptLinesTable> {
  $$TranscriptLinesTableOrderingComposer({
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

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTimeMs => $composableBuilder(
    column: $table.startTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endTimeMs => $composableBuilder(
    column: $table.endTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  $$AudioContentsTableOrderingComposer get audioContentId {
    final $$AudioContentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audioContentId,
      referencedTable: $db.audioContents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioContentsTableOrderingComposer(
            $db: $db,
            $table: $db.audioContents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TranscriptLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TranscriptLinesTable> {
  $$TranscriptLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<int> get startTimeMs => $composableBuilder(
    column: $table.startTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endTimeMs =>
      $composableBuilder(column: $table.endTimeMs, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  $$AudioContentsTableAnnotationComposer get audioContentId {
    final $$AudioContentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audioContentId,
      referencedTable: $db.audioContents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioContentsTableAnnotationComposer(
            $db: $db,
            $table: $db.audioContents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TranscriptLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TranscriptLinesTable,
          TranscriptLineData,
          $$TranscriptLinesTableFilterComposer,
          $$TranscriptLinesTableOrderingComposer,
          $$TranscriptLinesTableAnnotationComposer,
          $$TranscriptLinesTableCreateCompanionBuilder,
          $$TranscriptLinesTableUpdateCompanionBuilder,
          (TranscriptLineData, $$TranscriptLinesTableReferences),
          TranscriptLineData,
          PrefetchHooks Function({bool audioContentId})
        > {
  $$TranscriptLinesTableTableManager(
    _$AppDatabase db,
    $TranscriptLinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranscriptLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranscriptLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranscriptLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> audioContentId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<int> startTimeMs = const Value.absent(),
                Value<int> endTimeMs = const Value.absent(),
                Value<String> content = const Value.absent(),
              }) => TranscriptLinesCompanion(
                id: id,
                audioContentId: audioContentId,
                sequence: sequence,
                startTimeMs: startTimeMs,
                endTimeMs: endTimeMs,
                content: content,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int audioContentId,
                required int sequence,
                required int startTimeMs,
                required int endTimeMs,
                required String content,
              }) => TranscriptLinesCompanion.insert(
                id: id,
                audioContentId: audioContentId,
                sequence: sequence,
                startTimeMs: startTimeMs,
                endTimeMs: endTimeMs,
                content: content,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TranscriptLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({audioContentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (audioContentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.audioContentId,
                                referencedTable:
                                    $$TranscriptLinesTableReferences
                                        ._audioContentIdTable(db),
                                referencedColumn:
                                    $$TranscriptLinesTableReferences
                                        ._audioContentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TranscriptLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TranscriptLinesTable,
      TranscriptLineData,
      $$TranscriptLinesTableFilterComposer,
      $$TranscriptLinesTableOrderingComposer,
      $$TranscriptLinesTableAnnotationComposer,
      $$TranscriptLinesTableCreateCompanionBuilder,
      $$TranscriptLinesTableUpdateCompanionBuilder,
      (TranscriptLineData, $$TranscriptLinesTableReferences),
      TranscriptLineData,
      PrefetchHooks Function({bool audioContentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScheduleTableTableManager get schedule =>
      $$ScheduleTableTableManager(_db, _db.schedule);
  $$TaskTableTableManager get task => $$TaskTableTableManager(_db, _db.task);
  $$HabitTableTableManager get habit =>
      $$HabitTableTableManager(_db, _db.habit);
  $$HabitCompletionTableTableManager get habitCompletion =>
      $$HabitCompletionTableTableManager(_db, _db.habitCompletion);
  $$DailyCardOrderTableTableManager get dailyCardOrder =>
      $$DailyCardOrderTableTableManager(_db, _db.dailyCardOrder);
  $$AudioContentsTableTableManager get audioContents =>
      $$AudioContentsTableTableManager(_db, _db.audioContents);
  $$TranscriptLinesTableTableManager get transcriptLines =>
      $$TranscriptLinesTableTableManager(_db, _db.transcriptLines);
}
