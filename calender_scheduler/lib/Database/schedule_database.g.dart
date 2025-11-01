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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: false,
    defaultValue: const Constant('confirmed'),
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
    requiredDuringInsert: false,
    defaultValue: const Constant('default'),
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
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _originalHourMeta = const VerificationMeta(
    'originalHour',
  );
  @override
  late final GeneratedColumn<int> originalHour = GeneratedColumn<int>(
    'original_hour',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalMinuteMeta = const VerificationMeta(
    'originalMinute',
  );
  @override
  late final GeneratedColumn<int> originalMinute = GeneratedColumn<int>(
    'original_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    createdAt,
    status,
    visibility,
    completed,
    completedAt,
    timezone,
    originalHour,
    originalMinute,
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
    }
    if (data.containsKey('alert_setting')) {
      context.handle(
        _alertSettingMeta,
        alertSetting.isAcceptableOrUnknown(
          data['alert_setting']!,
          _alertSettingMeta,
        ),
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
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
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
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('original_hour')) {
      context.handle(
        _originalHourMeta,
        originalHour.isAcceptableOrUnknown(
          data['original_hour']!,
          _originalHourMeta,
        ),
      );
    }
    if (data.containsKey('original_minute')) {
      context.handle(
        _originalMinuteMeta,
        originalMinute.isAcceptableOrUnknown(
          data['original_minute']!,
          _originalMinuteMeta,
        ),
      );
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
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      originalHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_hour'],
      ),
      originalMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_minute'],
      ),
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
  final DateTime createdAt;
  final String status;
  final String visibility;
  final bool completed;
  final DateTime? completedAt;
  final String timezone;
  final int? originalHour;
  final int? originalMinute;
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
    required this.createdAt,
    required this.status,
    required this.visibility,
    required this.completed,
    this.completedAt,
    required this.timezone,
    this.originalHour,
    this.originalMinute,
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
    map['created_at'] = Variable<DateTime>(createdAt);
    map['status'] = Variable<String>(status);
    map['visibility'] = Variable<String>(visibility);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['timezone'] = Variable<String>(timezone);
    if (!nullToAbsent || originalHour != null) {
      map['original_hour'] = Variable<int>(originalHour);
    }
    if (!nullToAbsent || originalMinute != null) {
      map['original_minute'] = Variable<int>(originalMinute);
    }
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
      createdAt: Value(createdAt),
      status: Value(status),
      visibility: Value(visibility),
      completed: Value(completed),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      timezone: Value(timezone),
      originalHour: originalHour == null && nullToAbsent
          ? const Value.absent()
          : Value(originalHour),
      originalMinute: originalMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(originalMinute),
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
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      status: serializer.fromJson<String>(json['status']),
      visibility: serializer.fromJson<String>(json['visibility']),
      completed: serializer.fromJson<bool>(json['completed']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      timezone: serializer.fromJson<String>(json['timezone']),
      originalHour: serializer.fromJson<int?>(json['originalHour']),
      originalMinute: serializer.fromJson<int?>(json['originalMinute']),
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'status': serializer.toJson<String>(status),
      'visibility': serializer.toJson<String>(visibility),
      'completed': serializer.toJson<bool>(completed),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'timezone': serializer.toJson<String>(timezone),
      'originalHour': serializer.toJson<int?>(originalHour),
      'originalMinute': serializer.toJson<int?>(originalMinute),
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
    DateTime? createdAt,
    String? status,
    String? visibility,
    bool? completed,
    Value<DateTime?> completedAt = const Value.absent(),
    String? timezone,
    Value<int?> originalHour = const Value.absent(),
    Value<int?> originalMinute = const Value.absent(),
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
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
    visibility: visibility ?? this.visibility,
    completed: completed ?? this.completed,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    timezone: timezone ?? this.timezone,
    originalHour: originalHour.present ? originalHour.value : this.originalHour,
    originalMinute: originalMinute.present
        ? originalMinute.value
        : this.originalMinute,
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
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
      visibility: data.visibility.present
          ? data.visibility.value
          : this.visibility,
      completed: data.completed.present ? data.completed.value : this.completed,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      originalHour: data.originalHour.present
          ? data.originalHour.value
          : this.originalHour,
      originalMinute: data.originalMinute.present
          ? data.originalMinute.value
          : this.originalMinute,
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
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('visibility: $visibility, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('timezone: $timezone, ')
          ..write('originalHour: $originalHour, ')
          ..write('originalMinute: $originalMinute')
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
    createdAt,
    status,
    visibility,
    completed,
    completedAt,
    timezone,
    originalHour,
    originalMinute,
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
          other.createdAt == this.createdAt &&
          other.status == this.status &&
          other.visibility == this.visibility &&
          other.completed == this.completed &&
          other.completedAt == this.completedAt &&
          other.timezone == this.timezone &&
          other.originalHour == this.originalHour &&
          other.originalMinute == this.originalMinute);
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
  final Value<DateTime> createdAt;
  final Value<String> status;
  final Value<String> visibility;
  final Value<bool> completed;
  final Value<DateTime?> completedAt;
  final Value<String> timezone;
  final Value<int?> originalHour;
  final Value<int?> originalMinute;
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
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.visibility = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.timezone = const Value.absent(),
    this.originalHour = const Value.absent(),
    this.originalMinute = const Value.absent(),
  });
  ScheduleCompanion.insert({
    required DateTime start,
    required DateTime end,
    this.id = const Value.absent(),
    required String summary,
    this.description = const Value.absent(),
    this.location = const Value.absent(),
    required String colorId,
    this.repeatRule = const Value.absent(),
    this.alertSetting = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.visibility = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.timezone = const Value.absent(),
    this.originalHour = const Value.absent(),
    this.originalMinute = const Value.absent(),
  }) : start = Value(start),
       end = Value(end),
       summary = Value(summary),
       colorId = Value(colorId);
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
    Expression<DateTime>? createdAt,
    Expression<String>? status,
    Expression<String>? visibility,
    Expression<bool>? completed,
    Expression<DateTime>? completedAt,
    Expression<String>? timezone,
    Expression<int>? originalHour,
    Expression<int>? originalMinute,
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
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
      if (visibility != null) 'visibility': visibility,
      if (completed != null) 'completed': completed,
      if (completedAt != null) 'completed_at': completedAt,
      if (timezone != null) 'timezone': timezone,
      if (originalHour != null) 'original_hour': originalHour,
      if (originalMinute != null) 'original_minute': originalMinute,
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
    Value<DateTime>? createdAt,
    Value<String>? status,
    Value<String>? visibility,
    Value<bool>? completed,
    Value<DateTime?>? completedAt,
    Value<String>? timezone,
    Value<int?>? originalHour,
    Value<int?>? originalMinute,
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
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      timezone: timezone ?? this.timezone,
      originalHour: originalHour ?? this.originalHour,
      originalMinute: originalMinute ?? this.originalMinute,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (originalHour.present) {
      map['original_hour'] = Variable<int>(originalHour.value);
    }
    if (originalMinute.present) {
      map['original_minute'] = Variable<int>(originalMinute.value);
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
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('visibility: $visibility, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('timezone: $timezone, ')
          ..write('originalHour: $originalHour, ')
          ..write('originalMinute: $originalMinute')
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
  static const VerificationMeta _inboxOrderMeta = const VerificationMeta(
    'inboxOrder',
  );
  @override
  late final GeneratedColumn<int> inboxOrder = GeneratedColumn<int>(
    'inbox_order',
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
    completed,
    dueDate,
    executionDate,
    listId,
    createdAt,
    completedAt,
    colorId,
    repeatRule,
    reminder,
    inboxOrder,
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
    if (data.containsKey('inbox_order')) {
      context.handle(
        _inboxOrderMeta,
        inboxOrder.isAcceptableOrUnknown(data['inbox_order']!, _inboxOrderMeta),
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
      inboxOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inbox_order'],
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
  final int inboxOrder;
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
    required this.inboxOrder,
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
    map['inbox_order'] = Variable<int>(inboxOrder);
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
      inboxOrder: Value(inboxOrder),
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
      inboxOrder: serializer.fromJson<int>(json['inboxOrder']),
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
      'inboxOrder': serializer.toJson<int>(inboxOrder),
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
    int? inboxOrder,
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
    inboxOrder: inboxOrder ?? this.inboxOrder,
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
      inboxOrder: data.inboxOrder.present
          ? data.inboxOrder.value
          : this.inboxOrder,
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
          ..write('reminder: $reminder, ')
          ..write('inboxOrder: $inboxOrder')
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
    inboxOrder,
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
          other.reminder == this.reminder &&
          other.inboxOrder == this.inboxOrder);
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
  final Value<int> inboxOrder;
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
    this.inboxOrder = const Value.absent(),
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
    this.inboxOrder = const Value.absent(),
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
    Expression<int>? inboxOrder,
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
      if (inboxOrder != null) 'inbox_order': inboxOrder,
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
    Value<int>? inboxOrder,
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
      inboxOrder: inboxOrder ?? this.inboxOrder,
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
    if (inboxOrder.present) {
      map['inbox_order'] = Variable<int>(inboxOrder.value);
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
          ..write('reminder: $reminder, ')
          ..write('inboxOrder: $inboxOrder')
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

class $ScheduleCompletionTable extends ScheduleCompletion
    with TableInfo<$ScheduleCompletionTable, ScheduleCompletionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleCompletionTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta(
    'scheduleId',
  );
  @override
  late final GeneratedColumn<int> scheduleId = GeneratedColumn<int>(
    'schedule_id',
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
  List<GeneratedColumn> get $columns => [
    id,
    scheduleId,
    completedDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_completion';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleCompletionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scheduleIdMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {scheduleId, completedDate},
  ];
  @override
  ScheduleCompletionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleCompletionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_id'],
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
  $ScheduleCompletionTable createAlias(String alias) {
    return $ScheduleCompletionTable(attachedDatabase, alias);
  }
}

class ScheduleCompletionData extends DataClass
    implements Insertable<ScheduleCompletionData> {
  final int id;
  final int scheduleId;
  final DateTime completedDate;
  final DateTime createdAt;
  const ScheduleCompletionData({
    required this.id,
    required this.scheduleId,
    required this.completedDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['schedule_id'] = Variable<int>(scheduleId);
    map['completed_date'] = Variable<DateTime>(completedDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ScheduleCompletionCompanion toCompanion(bool nullToAbsent) {
    return ScheduleCompletionCompanion(
      id: Value(id),
      scheduleId: Value(scheduleId),
      completedDate: Value(completedDate),
      createdAt: Value(createdAt),
    );
  }

  factory ScheduleCompletionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleCompletionData(
      id: serializer.fromJson<int>(json['id']),
      scheduleId: serializer.fromJson<int>(json['scheduleId']),
      completedDate: serializer.fromJson<DateTime>(json['completedDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scheduleId': serializer.toJson<int>(scheduleId),
      'completedDate': serializer.toJson<DateTime>(completedDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ScheduleCompletionData copyWith({
    int? id,
    int? scheduleId,
    DateTime? completedDate,
    DateTime? createdAt,
  }) => ScheduleCompletionData(
    id: id ?? this.id,
    scheduleId: scheduleId ?? this.scheduleId,
    completedDate: completedDate ?? this.completedDate,
    createdAt: createdAt ?? this.createdAt,
  );
  ScheduleCompletionData copyWithCompanion(ScheduleCompletionCompanion data) {
    return ScheduleCompletionData(
      id: data.id.present ? data.id.value : this.id,
      scheduleId: data.scheduleId.present
          ? data.scheduleId.value
          : this.scheduleId,
      completedDate: data.completedDate.present
          ? data.completedDate.value
          : this.completedDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleCompletionData(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('completedDate: $completedDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, scheduleId, completedDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleCompletionData &&
          other.id == this.id &&
          other.scheduleId == this.scheduleId &&
          other.completedDate == this.completedDate &&
          other.createdAt == this.createdAt);
}

class ScheduleCompletionCompanion
    extends UpdateCompanion<ScheduleCompletionData> {
  final Value<int> id;
  final Value<int> scheduleId;
  final Value<DateTime> completedDate;
  final Value<DateTime> createdAt;
  const ScheduleCompletionCompanion({
    this.id = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ScheduleCompletionCompanion.insert({
    this.id = const Value.absent(),
    required int scheduleId,
    required DateTime completedDate,
    required DateTime createdAt,
  }) : scheduleId = Value(scheduleId),
       completedDate = Value(completedDate),
       createdAt = Value(createdAt);
  static Insertable<ScheduleCompletionData> custom({
    Expression<int>? id,
    Expression<int>? scheduleId,
    Expression<DateTime>? completedDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (completedDate != null) 'completed_date': completedDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ScheduleCompletionCompanion copyWith({
    Value<int>? id,
    Value<int>? scheduleId,
    Value<DateTime>? completedDate,
    Value<DateTime>? createdAt,
  }) {
    return ScheduleCompletionCompanion(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
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
    if (scheduleId.present) {
      map['schedule_id'] = Variable<int>(scheduleId.value);
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
    return (StringBuffer('ScheduleCompletionCompanion(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('completedDate: $completedDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TaskCompletionTable extends TaskCompletion
    with TableInfo<$TaskCompletionTable, TaskCompletionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskCompletionTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
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
  List<GeneratedColumn> get $columns => [id, taskId, completedDate, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_completion';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskCompletionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {taskId, completedDate},
  ];
  @override
  TaskCompletionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskCompletionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
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
  $TaskCompletionTable createAlias(String alias) {
    return $TaskCompletionTable(attachedDatabase, alias);
  }
}

class TaskCompletionData extends DataClass
    implements Insertable<TaskCompletionData> {
  final int id;
  final int taskId;
  final DateTime completedDate;
  final DateTime createdAt;
  const TaskCompletionData({
    required this.id,
    required this.taskId,
    required this.completedDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<int>(taskId);
    map['completed_date'] = Variable<DateTime>(completedDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TaskCompletionCompanion toCompanion(bool nullToAbsent) {
    return TaskCompletionCompanion(
      id: Value(id),
      taskId: Value(taskId),
      completedDate: Value(completedDate),
      createdAt: Value(createdAt),
    );
  }

  factory TaskCompletionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskCompletionData(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      completedDate: serializer.fromJson<DateTime>(json['completedDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int>(taskId),
      'completedDate': serializer.toJson<DateTime>(completedDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TaskCompletionData copyWith({
    int? id,
    int? taskId,
    DateTime? completedDate,
    DateTime? createdAt,
  }) => TaskCompletionData(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    completedDate: completedDate ?? this.completedDate,
    createdAt: createdAt ?? this.createdAt,
  );
  TaskCompletionData copyWithCompanion(TaskCompletionCompanion data) {
    return TaskCompletionData(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      completedDate: data.completedDate.present
          ? data.completedDate.value
          : this.completedDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskCompletionData(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('completedDate: $completedDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, completedDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskCompletionData &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.completedDate == this.completedDate &&
          other.createdAt == this.createdAt);
}

class TaskCompletionCompanion extends UpdateCompanion<TaskCompletionData> {
  final Value<int> id;
  final Value<int> taskId;
  final Value<DateTime> completedDate;
  final Value<DateTime> createdAt;
  const TaskCompletionCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TaskCompletionCompanion.insert({
    this.id = const Value.absent(),
    required int taskId,
    required DateTime completedDate,
    required DateTime createdAt,
  }) : taskId = Value(taskId),
       completedDate = Value(completedDate),
       createdAt = Value(createdAt);
  static Insertable<TaskCompletionData> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<DateTime>? completedDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (completedDate != null) 'completed_date': completedDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TaskCompletionCompanion copyWith({
    Value<int>? id,
    Value<int>? taskId,
    Value<DateTime>? completedDate,
    Value<DateTime>? createdAt,
  }) {
    return TaskCompletionCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
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
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
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
    return (StringBuffer('TaskCompletionCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
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

class $RecurringPatternTable extends RecurringPattern
    with TableInfo<$RecurringPatternTable, RecurringPatternData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringPatternTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rruleMeta = const VerificationMeta('rrule');
  @override
  late final GeneratedColumn<String> rrule = GeneratedColumn<String>(
    'rrule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dtstartMeta = const VerificationMeta(
    'dtstart',
  );
  @override
  late final GeneratedColumn<DateTime> dtstart = GeneratedColumn<DateTime>(
    'dtstart',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _untilMeta = const VerificationMeta('until');
  @override
  late final GeneratedColumn<DateTime> until = GeneratedColumn<DateTime>(
    'until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UTC'),
  );
  static const VerificationMeta _exdateMeta = const VerificationMeta('exdate');
  @override
  late final GeneratedColumn<String> exdate = GeneratedColumn<String>(
    'exdate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _recurrenceModeMeta = const VerificationMeta(
    'recurrenceMode',
  );
  @override
  late final GeneratedColumn<String> recurrenceMode = GeneratedColumn<String>(
    'recurrence_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ABSOLUTE'),
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
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    rrule,
    dtstart,
    until,
    count,
    timezone,
    exdate,
    recurrenceMode,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_pattern';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringPatternData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('rrule')) {
      context.handle(
        _rruleMeta,
        rrule.isAcceptableOrUnknown(data['rrule']!, _rruleMeta),
      );
    } else if (isInserting) {
      context.missing(_rruleMeta);
    }
    if (data.containsKey('dtstart')) {
      context.handle(
        _dtstartMeta,
        dtstart.isAcceptableOrUnknown(data['dtstart']!, _dtstartMeta),
      );
    } else if (isInserting) {
      context.missing(_dtstartMeta);
    }
    if (data.containsKey('until')) {
      context.handle(
        _untilMeta,
        until.isAcceptableOrUnknown(data['until']!, _untilMeta),
      );
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('exdate')) {
      context.handle(
        _exdateMeta,
        exdate.isAcceptableOrUnknown(data['exdate']!, _exdateMeta),
      );
    }
    if (data.containsKey('recurrence_mode')) {
      context.handle(
        _recurrenceModeMeta,
        recurrenceMode.isAcceptableOrUnknown(
          data['recurrence_mode']!,
          _recurrenceModeMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {entityType, entityId},
  ];
  @override
  RecurringPatternData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringPatternData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_id'],
      )!,
      rrule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rrule'],
      )!,
      dtstart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dtstart'],
      )!,
      until: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}until'],
      ),
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      ),
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      exdate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exdate'],
      )!,
      recurrenceMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_mode'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RecurringPatternTable createAlias(String alias) {
    return $RecurringPatternTable(attachedDatabase, alias);
  }
}

class RecurringPatternData extends DataClass
    implements Insertable<RecurringPatternData> {
  final int id;
  final String entityType;
  final int entityId;
  final String rrule;
  final DateTime dtstart;
  final DateTime? until;
  final int? count;
  final String timezone;
  final String exdate;
  final String recurrenceMode;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RecurringPatternData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.rrule,
    required this.dtstart,
    this.until,
    this.count,
    required this.timezone,
    required this.exdate,
    required this.recurrenceMode,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<int>(entityId);
    map['rrule'] = Variable<String>(rrule);
    map['dtstart'] = Variable<DateTime>(dtstart);
    if (!nullToAbsent || until != null) {
      map['until'] = Variable<DateTime>(until);
    }
    if (!nullToAbsent || count != null) {
      map['count'] = Variable<int>(count);
    }
    map['timezone'] = Variable<String>(timezone);
    map['exdate'] = Variable<String>(exdate);
    map['recurrence_mode'] = Variable<String>(recurrenceMode);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RecurringPatternCompanion toCompanion(bool nullToAbsent) {
    return RecurringPatternCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      rrule: Value(rrule),
      dtstart: Value(dtstart),
      until: until == null && nullToAbsent
          ? const Value.absent()
          : Value(until),
      count: count == null && nullToAbsent
          ? const Value.absent()
          : Value(count),
      timezone: Value(timezone),
      exdate: Value(exdate),
      recurrenceMode: Value(recurrenceMode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RecurringPatternData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringPatternData(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<int>(json['entityId']),
      rrule: serializer.fromJson<String>(json['rrule']),
      dtstart: serializer.fromJson<DateTime>(json['dtstart']),
      until: serializer.fromJson<DateTime?>(json['until']),
      count: serializer.fromJson<int?>(json['count']),
      timezone: serializer.fromJson<String>(json['timezone']),
      exdate: serializer.fromJson<String>(json['exdate']),
      recurrenceMode: serializer.fromJson<String>(json['recurrenceMode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<int>(entityId),
      'rrule': serializer.toJson<String>(rrule),
      'dtstart': serializer.toJson<DateTime>(dtstart),
      'until': serializer.toJson<DateTime?>(until),
      'count': serializer.toJson<int?>(count),
      'timezone': serializer.toJson<String>(timezone),
      'exdate': serializer.toJson<String>(exdate),
      'recurrenceMode': serializer.toJson<String>(recurrenceMode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RecurringPatternData copyWith({
    int? id,
    String? entityType,
    int? entityId,
    String? rrule,
    DateTime? dtstart,
    Value<DateTime?> until = const Value.absent(),
    Value<int?> count = const Value.absent(),
    String? timezone,
    String? exdate,
    String? recurrenceMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => RecurringPatternData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    rrule: rrule ?? this.rrule,
    dtstart: dtstart ?? this.dtstart,
    until: until.present ? until.value : this.until,
    count: count.present ? count.value : this.count,
    timezone: timezone ?? this.timezone,
    exdate: exdate ?? this.exdate,
    recurrenceMode: recurrenceMode ?? this.recurrenceMode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RecurringPatternData copyWithCompanion(RecurringPatternCompanion data) {
    return RecurringPatternData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      rrule: data.rrule.present ? data.rrule.value : this.rrule,
      dtstart: data.dtstart.present ? data.dtstart.value : this.dtstart,
      until: data.until.present ? data.until.value : this.until,
      count: data.count.present ? data.count.value : this.count,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      exdate: data.exdate.present ? data.exdate.value : this.exdate,
      recurrenceMode: data.recurrenceMode.present
          ? data.recurrenceMode.value
          : this.recurrenceMode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringPatternData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('rrule: $rrule, ')
          ..write('dtstart: $dtstart, ')
          ..write('until: $until, ')
          ..write('count: $count, ')
          ..write('timezone: $timezone, ')
          ..write('exdate: $exdate, ')
          ..write('recurrenceMode: $recurrenceMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    rrule,
    dtstart,
    until,
    count,
    timezone,
    exdate,
    recurrenceMode,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringPatternData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.rrule == this.rrule &&
          other.dtstart == this.dtstart &&
          other.until == this.until &&
          other.count == this.count &&
          other.timezone == this.timezone &&
          other.exdate == this.exdate &&
          other.recurrenceMode == this.recurrenceMode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RecurringPatternCompanion extends UpdateCompanion<RecurringPatternData> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<int> entityId;
  final Value<String> rrule;
  final Value<DateTime> dtstart;
  final Value<DateTime?> until;
  final Value<int?> count;
  final Value<String> timezone;
  final Value<String> exdate;
  final Value<String> recurrenceMode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const RecurringPatternCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.rrule = const Value.absent(),
    this.dtstart = const Value.absent(),
    this.until = const Value.absent(),
    this.count = const Value.absent(),
    this.timezone = const Value.absent(),
    this.exdate = const Value.absent(),
    this.recurrenceMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RecurringPatternCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required int entityId,
    required String rrule,
    required DateTime dtstart,
    this.until = const Value.absent(),
    this.count = const Value.absent(),
    this.timezone = const Value.absent(),
    this.exdate = const Value.absent(),
    this.recurrenceMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       rrule = Value(rrule),
       dtstart = Value(dtstart);
  static Insertable<RecurringPatternData> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<int>? entityId,
    Expression<String>? rrule,
    Expression<DateTime>? dtstart,
    Expression<DateTime>? until,
    Expression<int>? count,
    Expression<String>? timezone,
    Expression<String>? exdate,
    Expression<String>? recurrenceMode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (rrule != null) 'rrule': rrule,
      if (dtstart != null) 'dtstart': dtstart,
      if (until != null) 'until': until,
      if (count != null) 'count': count,
      if (timezone != null) 'timezone': timezone,
      if (exdate != null) 'exdate': exdate,
      if (recurrenceMode != null) 'recurrence_mode': recurrenceMode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RecurringPatternCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<int>? entityId,
    Value<String>? rrule,
    Value<DateTime>? dtstart,
    Value<DateTime?>? until,
    Value<int?>? count,
    Value<String>? timezone,
    Value<String>? exdate,
    Value<String>? recurrenceMode,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return RecurringPatternCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      rrule: rrule ?? this.rrule,
      dtstart: dtstart ?? this.dtstart,
      until: until ?? this.until,
      count: count ?? this.count,
      timezone: timezone ?? this.timezone,
      exdate: exdate ?? this.exdate,
      recurrenceMode: recurrenceMode ?? this.recurrenceMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (rrule.present) {
      map['rrule'] = Variable<String>(rrule.value);
    }
    if (dtstart.present) {
      map['dtstart'] = Variable<DateTime>(dtstart.value);
    }
    if (until.present) {
      map['until'] = Variable<DateTime>(until.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (exdate.present) {
      map['exdate'] = Variable<String>(exdate.value);
    }
    if (recurrenceMode.present) {
      map['recurrence_mode'] = Variable<String>(recurrenceMode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringPatternCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('rrule: $rrule, ')
          ..write('dtstart: $dtstart, ')
          ..write('until: $until, ')
          ..write('count: $count, ')
          ..write('timezone: $timezone, ')
          ..write('exdate: $exdate, ')
          ..write('recurrenceMode: $recurrenceMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $RecurringExceptionTable extends RecurringException
    with TableInfo<$RecurringExceptionTable, RecurringExceptionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringExceptionTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _recurringPatternIdMeta =
      const VerificationMeta('recurringPatternId');
  @override
  late final GeneratedColumn<int> recurringPatternId = GeneratedColumn<int>(
    'recurring_pattern_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recurring_pattern (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _originalDateMeta = const VerificationMeta(
    'originalDate',
  );
  @override
  late final GeneratedColumn<DateTime> originalDate = GeneratedColumn<DateTime>(
    'original_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCancelledMeta = const VerificationMeta(
    'isCancelled',
  );
  @override
  late final GeneratedColumn<bool> isCancelled = GeneratedColumn<bool>(
    'is_cancelled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_cancelled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isRescheduledMeta = const VerificationMeta(
    'isRescheduled',
  );
  @override
  late final GeneratedColumn<bool> isRescheduled = GeneratedColumn<bool>(
    'is_rescheduled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_rescheduled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _newStartDateMeta = const VerificationMeta(
    'newStartDate',
  );
  @override
  late final GeneratedColumn<DateTime> newStartDate = GeneratedColumn<DateTime>(
    'new_start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newEndDateMeta = const VerificationMeta(
    'newEndDate',
  );
  @override
  late final GeneratedColumn<DateTime> newEndDate = GeneratedColumn<DateTime>(
    'new_end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedTitleMeta = const VerificationMeta(
    'modifiedTitle',
  );
  @override
  late final GeneratedColumn<String> modifiedTitle = GeneratedColumn<String>(
    'modified_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedDescriptionMeta =
      const VerificationMeta('modifiedDescription');
  @override
  late final GeneratedColumn<String> modifiedDescription =
      GeneratedColumn<String>(
        'modified_description',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _modifiedLocationMeta = const VerificationMeta(
    'modifiedLocation',
  );
  @override
  late final GeneratedColumn<String> modifiedLocation = GeneratedColumn<String>(
    'modified_location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedColorIdMeta = const VerificationMeta(
    'modifiedColorId',
  );
  @override
  late final GeneratedColumn<String> modifiedColorId = GeneratedColumn<String>(
    'modified_color_id',
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
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recurringPatternId,
    originalDate,
    isCancelled,
    isRescheduled,
    newStartDate,
    newEndDate,
    modifiedTitle,
    modifiedDescription,
    modifiedLocation,
    modifiedColorId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_exception';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringExceptionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recurring_pattern_id')) {
      context.handle(
        _recurringPatternIdMeta,
        recurringPatternId.isAcceptableOrUnknown(
          data['recurring_pattern_id']!,
          _recurringPatternIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recurringPatternIdMeta);
    }
    if (data.containsKey('original_date')) {
      context.handle(
        _originalDateMeta,
        originalDate.isAcceptableOrUnknown(
          data['original_date']!,
          _originalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalDateMeta);
    }
    if (data.containsKey('is_cancelled')) {
      context.handle(
        _isCancelledMeta,
        isCancelled.isAcceptableOrUnknown(
          data['is_cancelled']!,
          _isCancelledMeta,
        ),
      );
    }
    if (data.containsKey('is_rescheduled')) {
      context.handle(
        _isRescheduledMeta,
        isRescheduled.isAcceptableOrUnknown(
          data['is_rescheduled']!,
          _isRescheduledMeta,
        ),
      );
    }
    if (data.containsKey('new_start_date')) {
      context.handle(
        _newStartDateMeta,
        newStartDate.isAcceptableOrUnknown(
          data['new_start_date']!,
          _newStartDateMeta,
        ),
      );
    }
    if (data.containsKey('new_end_date')) {
      context.handle(
        _newEndDateMeta,
        newEndDate.isAcceptableOrUnknown(
          data['new_end_date']!,
          _newEndDateMeta,
        ),
      );
    }
    if (data.containsKey('modified_title')) {
      context.handle(
        _modifiedTitleMeta,
        modifiedTitle.isAcceptableOrUnknown(
          data['modified_title']!,
          _modifiedTitleMeta,
        ),
      );
    }
    if (data.containsKey('modified_description')) {
      context.handle(
        _modifiedDescriptionMeta,
        modifiedDescription.isAcceptableOrUnknown(
          data['modified_description']!,
          _modifiedDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('modified_location')) {
      context.handle(
        _modifiedLocationMeta,
        modifiedLocation.isAcceptableOrUnknown(
          data['modified_location']!,
          _modifiedLocationMeta,
        ),
      );
    }
    if (data.containsKey('modified_color_id')) {
      context.handle(
        _modifiedColorIdMeta,
        modifiedColorId.isAcceptableOrUnknown(
          data['modified_color_id']!,
          _modifiedColorIdMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {recurringPatternId, originalDate},
  ];
  @override
  RecurringExceptionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringExceptionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recurringPatternId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurring_pattern_id'],
      )!,
      originalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}original_date'],
      )!,
      isCancelled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_cancelled'],
      )!,
      isRescheduled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_rescheduled'],
      )!,
      newStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}new_start_date'],
      ),
      newEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}new_end_date'],
      ),
      modifiedTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modified_title'],
      ),
      modifiedDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modified_description'],
      ),
      modifiedLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modified_location'],
      ),
      modifiedColorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modified_color_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RecurringExceptionTable createAlias(String alias) {
    return $RecurringExceptionTable(attachedDatabase, alias);
  }
}

class RecurringExceptionData extends DataClass
    implements Insertable<RecurringExceptionData> {
  final int id;
  final int recurringPatternId;
  final DateTime originalDate;
  final bool isCancelled;
  final bool isRescheduled;
  final DateTime? newStartDate;
  final DateTime? newEndDate;
  final String? modifiedTitle;
  final String? modifiedDescription;
  final String? modifiedLocation;
  final String? modifiedColorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RecurringExceptionData({
    required this.id,
    required this.recurringPatternId,
    required this.originalDate,
    required this.isCancelled,
    required this.isRescheduled,
    this.newStartDate,
    this.newEndDate,
    this.modifiedTitle,
    this.modifiedDescription,
    this.modifiedLocation,
    this.modifiedColorId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recurring_pattern_id'] = Variable<int>(recurringPatternId);
    map['original_date'] = Variable<DateTime>(originalDate);
    map['is_cancelled'] = Variable<bool>(isCancelled);
    map['is_rescheduled'] = Variable<bool>(isRescheduled);
    if (!nullToAbsent || newStartDate != null) {
      map['new_start_date'] = Variable<DateTime>(newStartDate);
    }
    if (!nullToAbsent || newEndDate != null) {
      map['new_end_date'] = Variable<DateTime>(newEndDate);
    }
    if (!nullToAbsent || modifiedTitle != null) {
      map['modified_title'] = Variable<String>(modifiedTitle);
    }
    if (!nullToAbsent || modifiedDescription != null) {
      map['modified_description'] = Variable<String>(modifiedDescription);
    }
    if (!nullToAbsent || modifiedLocation != null) {
      map['modified_location'] = Variable<String>(modifiedLocation);
    }
    if (!nullToAbsent || modifiedColorId != null) {
      map['modified_color_id'] = Variable<String>(modifiedColorId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RecurringExceptionCompanion toCompanion(bool nullToAbsent) {
    return RecurringExceptionCompanion(
      id: Value(id),
      recurringPatternId: Value(recurringPatternId),
      originalDate: Value(originalDate),
      isCancelled: Value(isCancelled),
      isRescheduled: Value(isRescheduled),
      newStartDate: newStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(newStartDate),
      newEndDate: newEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(newEndDate),
      modifiedTitle: modifiedTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedTitle),
      modifiedDescription: modifiedDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedDescription),
      modifiedLocation: modifiedLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedLocation),
      modifiedColorId: modifiedColorId == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedColorId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RecurringExceptionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringExceptionData(
      id: serializer.fromJson<int>(json['id']),
      recurringPatternId: serializer.fromJson<int>(json['recurringPatternId']),
      originalDate: serializer.fromJson<DateTime>(json['originalDate']),
      isCancelled: serializer.fromJson<bool>(json['isCancelled']),
      isRescheduled: serializer.fromJson<bool>(json['isRescheduled']),
      newStartDate: serializer.fromJson<DateTime?>(json['newStartDate']),
      newEndDate: serializer.fromJson<DateTime?>(json['newEndDate']),
      modifiedTitle: serializer.fromJson<String?>(json['modifiedTitle']),
      modifiedDescription: serializer.fromJson<String?>(
        json['modifiedDescription'],
      ),
      modifiedLocation: serializer.fromJson<String?>(json['modifiedLocation']),
      modifiedColorId: serializer.fromJson<String?>(json['modifiedColorId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recurringPatternId': serializer.toJson<int>(recurringPatternId),
      'originalDate': serializer.toJson<DateTime>(originalDate),
      'isCancelled': serializer.toJson<bool>(isCancelled),
      'isRescheduled': serializer.toJson<bool>(isRescheduled),
      'newStartDate': serializer.toJson<DateTime?>(newStartDate),
      'newEndDate': serializer.toJson<DateTime?>(newEndDate),
      'modifiedTitle': serializer.toJson<String?>(modifiedTitle),
      'modifiedDescription': serializer.toJson<String?>(modifiedDescription),
      'modifiedLocation': serializer.toJson<String?>(modifiedLocation),
      'modifiedColorId': serializer.toJson<String?>(modifiedColorId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RecurringExceptionData copyWith({
    int? id,
    int? recurringPatternId,
    DateTime? originalDate,
    bool? isCancelled,
    bool? isRescheduled,
    Value<DateTime?> newStartDate = const Value.absent(),
    Value<DateTime?> newEndDate = const Value.absent(),
    Value<String?> modifiedTitle = const Value.absent(),
    Value<String?> modifiedDescription = const Value.absent(),
    Value<String?> modifiedLocation = const Value.absent(),
    Value<String?> modifiedColorId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => RecurringExceptionData(
    id: id ?? this.id,
    recurringPatternId: recurringPatternId ?? this.recurringPatternId,
    originalDate: originalDate ?? this.originalDate,
    isCancelled: isCancelled ?? this.isCancelled,
    isRescheduled: isRescheduled ?? this.isRescheduled,
    newStartDate: newStartDate.present ? newStartDate.value : this.newStartDate,
    newEndDate: newEndDate.present ? newEndDate.value : this.newEndDate,
    modifiedTitle: modifiedTitle.present
        ? modifiedTitle.value
        : this.modifiedTitle,
    modifiedDescription: modifiedDescription.present
        ? modifiedDescription.value
        : this.modifiedDescription,
    modifiedLocation: modifiedLocation.present
        ? modifiedLocation.value
        : this.modifiedLocation,
    modifiedColorId: modifiedColorId.present
        ? modifiedColorId.value
        : this.modifiedColorId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RecurringExceptionData copyWithCompanion(RecurringExceptionCompanion data) {
    return RecurringExceptionData(
      id: data.id.present ? data.id.value : this.id,
      recurringPatternId: data.recurringPatternId.present
          ? data.recurringPatternId.value
          : this.recurringPatternId,
      originalDate: data.originalDate.present
          ? data.originalDate.value
          : this.originalDate,
      isCancelled: data.isCancelled.present
          ? data.isCancelled.value
          : this.isCancelled,
      isRescheduled: data.isRescheduled.present
          ? data.isRescheduled.value
          : this.isRescheduled,
      newStartDate: data.newStartDate.present
          ? data.newStartDate.value
          : this.newStartDate,
      newEndDate: data.newEndDate.present
          ? data.newEndDate.value
          : this.newEndDate,
      modifiedTitle: data.modifiedTitle.present
          ? data.modifiedTitle.value
          : this.modifiedTitle,
      modifiedDescription: data.modifiedDescription.present
          ? data.modifiedDescription.value
          : this.modifiedDescription,
      modifiedLocation: data.modifiedLocation.present
          ? data.modifiedLocation.value
          : this.modifiedLocation,
      modifiedColorId: data.modifiedColorId.present
          ? data.modifiedColorId.value
          : this.modifiedColorId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringExceptionData(')
          ..write('id: $id, ')
          ..write('recurringPatternId: $recurringPatternId, ')
          ..write('originalDate: $originalDate, ')
          ..write('isCancelled: $isCancelled, ')
          ..write('isRescheduled: $isRescheduled, ')
          ..write('newStartDate: $newStartDate, ')
          ..write('newEndDate: $newEndDate, ')
          ..write('modifiedTitle: $modifiedTitle, ')
          ..write('modifiedDescription: $modifiedDescription, ')
          ..write('modifiedLocation: $modifiedLocation, ')
          ..write('modifiedColorId: $modifiedColorId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recurringPatternId,
    originalDate,
    isCancelled,
    isRescheduled,
    newStartDate,
    newEndDate,
    modifiedTitle,
    modifiedDescription,
    modifiedLocation,
    modifiedColorId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringExceptionData &&
          other.id == this.id &&
          other.recurringPatternId == this.recurringPatternId &&
          other.originalDate == this.originalDate &&
          other.isCancelled == this.isCancelled &&
          other.isRescheduled == this.isRescheduled &&
          other.newStartDate == this.newStartDate &&
          other.newEndDate == this.newEndDate &&
          other.modifiedTitle == this.modifiedTitle &&
          other.modifiedDescription == this.modifiedDescription &&
          other.modifiedLocation == this.modifiedLocation &&
          other.modifiedColorId == this.modifiedColorId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RecurringExceptionCompanion
    extends UpdateCompanion<RecurringExceptionData> {
  final Value<int> id;
  final Value<int> recurringPatternId;
  final Value<DateTime> originalDate;
  final Value<bool> isCancelled;
  final Value<bool> isRescheduled;
  final Value<DateTime?> newStartDate;
  final Value<DateTime?> newEndDate;
  final Value<String?> modifiedTitle;
  final Value<String?> modifiedDescription;
  final Value<String?> modifiedLocation;
  final Value<String?> modifiedColorId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const RecurringExceptionCompanion({
    this.id = const Value.absent(),
    this.recurringPatternId = const Value.absent(),
    this.originalDate = const Value.absent(),
    this.isCancelled = const Value.absent(),
    this.isRescheduled = const Value.absent(),
    this.newStartDate = const Value.absent(),
    this.newEndDate = const Value.absent(),
    this.modifiedTitle = const Value.absent(),
    this.modifiedDescription = const Value.absent(),
    this.modifiedLocation = const Value.absent(),
    this.modifiedColorId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RecurringExceptionCompanion.insert({
    this.id = const Value.absent(),
    required int recurringPatternId,
    required DateTime originalDate,
    this.isCancelled = const Value.absent(),
    this.isRescheduled = const Value.absent(),
    this.newStartDate = const Value.absent(),
    this.newEndDate = const Value.absent(),
    this.modifiedTitle = const Value.absent(),
    this.modifiedDescription = const Value.absent(),
    this.modifiedLocation = const Value.absent(),
    this.modifiedColorId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : recurringPatternId = Value(recurringPatternId),
       originalDate = Value(originalDate);
  static Insertable<RecurringExceptionData> custom({
    Expression<int>? id,
    Expression<int>? recurringPatternId,
    Expression<DateTime>? originalDate,
    Expression<bool>? isCancelled,
    Expression<bool>? isRescheduled,
    Expression<DateTime>? newStartDate,
    Expression<DateTime>? newEndDate,
    Expression<String>? modifiedTitle,
    Expression<String>? modifiedDescription,
    Expression<String>? modifiedLocation,
    Expression<String>? modifiedColorId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recurringPatternId != null)
        'recurring_pattern_id': recurringPatternId,
      if (originalDate != null) 'original_date': originalDate,
      if (isCancelled != null) 'is_cancelled': isCancelled,
      if (isRescheduled != null) 'is_rescheduled': isRescheduled,
      if (newStartDate != null) 'new_start_date': newStartDate,
      if (newEndDate != null) 'new_end_date': newEndDate,
      if (modifiedTitle != null) 'modified_title': modifiedTitle,
      if (modifiedDescription != null)
        'modified_description': modifiedDescription,
      if (modifiedLocation != null) 'modified_location': modifiedLocation,
      if (modifiedColorId != null) 'modified_color_id': modifiedColorId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RecurringExceptionCompanion copyWith({
    Value<int>? id,
    Value<int>? recurringPatternId,
    Value<DateTime>? originalDate,
    Value<bool>? isCancelled,
    Value<bool>? isRescheduled,
    Value<DateTime?>? newStartDate,
    Value<DateTime?>? newEndDate,
    Value<String?>? modifiedTitle,
    Value<String?>? modifiedDescription,
    Value<String?>? modifiedLocation,
    Value<String?>? modifiedColorId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return RecurringExceptionCompanion(
      id: id ?? this.id,
      recurringPatternId: recurringPatternId ?? this.recurringPatternId,
      originalDate: originalDate ?? this.originalDate,
      isCancelled: isCancelled ?? this.isCancelled,
      isRescheduled: isRescheduled ?? this.isRescheduled,
      newStartDate: newStartDate ?? this.newStartDate,
      newEndDate: newEndDate ?? this.newEndDate,
      modifiedTitle: modifiedTitle ?? this.modifiedTitle,
      modifiedDescription: modifiedDescription ?? this.modifiedDescription,
      modifiedLocation: modifiedLocation ?? this.modifiedLocation,
      modifiedColorId: modifiedColorId ?? this.modifiedColorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recurringPatternId.present) {
      map['recurring_pattern_id'] = Variable<int>(recurringPatternId.value);
    }
    if (originalDate.present) {
      map['original_date'] = Variable<DateTime>(originalDate.value);
    }
    if (isCancelled.present) {
      map['is_cancelled'] = Variable<bool>(isCancelled.value);
    }
    if (isRescheduled.present) {
      map['is_rescheduled'] = Variable<bool>(isRescheduled.value);
    }
    if (newStartDate.present) {
      map['new_start_date'] = Variable<DateTime>(newStartDate.value);
    }
    if (newEndDate.present) {
      map['new_end_date'] = Variable<DateTime>(newEndDate.value);
    }
    if (modifiedTitle.present) {
      map['modified_title'] = Variable<String>(modifiedTitle.value);
    }
    if (modifiedDescription.present) {
      map['modified_description'] = Variable<String>(modifiedDescription.value);
    }
    if (modifiedLocation.present) {
      map['modified_location'] = Variable<String>(modifiedLocation.value);
    }
    if (modifiedColorId.present) {
      map['modified_color_id'] = Variable<String>(modifiedColorId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringExceptionCompanion(')
          ..write('id: $id, ')
          ..write('recurringPatternId: $recurringPatternId, ')
          ..write('originalDate: $originalDate, ')
          ..write('isCancelled: $isCancelled, ')
          ..write('isRescheduled: $isRescheduled, ')
          ..write('newStartDate: $newStartDate, ')
          ..write('newEndDate: $newEndDate, ')
          ..write('modifiedTitle: $modifiedTitle, ')
          ..write('modifiedDescription: $modifiedDescription, ')
          ..write('modifiedLocation: $modifiedLocation, ')
          ..write('modifiedColorId: $modifiedColorId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TempExtractedItemsTable extends TempExtractedItems
    with TableInfo<$TempExtractedItemsTable, TempExtractedItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TempExtractedItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
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
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isConfirmedMeta = const VerificationMeta(
    'isConfirmed',
  );
  @override
  late final GeneratedColumn<bool> isConfirmed = GeneratedColumn<bool>(
    'is_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemType,
    title,
    startDate,
    endDate,
    dueDate,
    executionDate,
    description,
    location,
    colorId,
    repeatRule,
    listId,
    createdAt,
    isConfirmed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'temp_extracted_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TempExtractedItemData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
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
    }
    if (data.containsKey('repeat_rule')) {
      context.handle(
        _repeatRuleMeta,
        repeatRule.isAcceptableOrUnknown(data['repeat_rule']!, _repeatRuleMeta),
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
    }
    if (data.containsKey('is_confirmed')) {
      context.handle(
        _isConfirmedMeta,
        isConfirmed.isAcceptableOrUnknown(
          data['is_confirmed']!,
          _isConfirmedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TempExtractedItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TempExtractedItemData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      executionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}execution_date'],
      ),
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
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_confirmed'],
      )!,
    );
  }

  @override
  $TempExtractedItemsTable createAlias(String alias) {
    return $TempExtractedItemsTable(attachedDatabase, alias);
  }
}

class TempExtractedItemData extends DataClass
    implements Insertable<TempExtractedItemData> {
  /// ID (자동 증가)
  final int id;

  /// 항목 타입 (schedule, task, habit)
  final String itemType;

  /// 제목 또는 요약
  final String title;

  /// 시작 날짜/시간 (일정용, nullable)
  final DateTime? startDate;

  /// 종료 날짜/시간 (일정용, nullable)
  final DateTime? endDate;

  /// 마감일 (할일용, nullable)
  final DateTime? dueDate;

  /// 실행일 (할일용, nullable)
  final DateTime? executionDate;

  /// 설명
  final String description;

  /// 장소
  final String location;

  /// 색상 ID
  final String colorId;

  /// 반복 규칙 (RRULE 형식)
  final String repeatRule;

  /// 리스트 ID (할일용, 기본: inbox)
  final String listId;

  /// 생성 시간
  final DateTime createdAt;

  /// 사용자 확인 여부 (체크박스)
  final bool isConfirmed;
  const TempExtractedItemData({
    required this.id,
    required this.itemType,
    required this.title,
    this.startDate,
    this.endDate,
    this.dueDate,
    this.executionDate,
    required this.description,
    required this.location,
    required this.colorId,
    required this.repeatRule,
    required this.listId,
    required this.createdAt,
    required this.isConfirmed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_type'] = Variable<String>(itemType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || executionDate != null) {
      map['execution_date'] = Variable<DateTime>(executionDate);
    }
    map['description'] = Variable<String>(description);
    map['location'] = Variable<String>(location);
    map['color_id'] = Variable<String>(colorId);
    map['repeat_rule'] = Variable<String>(repeatRule);
    map['list_id'] = Variable<String>(listId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_confirmed'] = Variable<bool>(isConfirmed);
    return map;
  }

  TempExtractedItemsCompanion toCompanion(bool nullToAbsent) {
    return TempExtractedItemsCompanion(
      id: Value(id),
      itemType: Value(itemType),
      title: Value(title),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      executionDate: executionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(executionDate),
      description: Value(description),
      location: Value(location),
      colorId: Value(colorId),
      repeatRule: Value(repeatRule),
      listId: Value(listId),
      createdAt: Value(createdAt),
      isConfirmed: Value(isConfirmed),
    );
  }

  factory TempExtractedItemData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TempExtractedItemData(
      id: serializer.fromJson<int>(json['id']),
      itemType: serializer.fromJson<String>(json['itemType']),
      title: serializer.fromJson<String>(json['title']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      executionDate: serializer.fromJson<DateTime?>(json['executionDate']),
      description: serializer.fromJson<String>(json['description']),
      location: serializer.fromJson<String>(json['location']),
      colorId: serializer.fromJson<String>(json['colorId']),
      repeatRule: serializer.fromJson<String>(json['repeatRule']),
      listId: serializer.fromJson<String>(json['listId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isConfirmed: serializer.fromJson<bool>(json['isConfirmed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemType': serializer.toJson<String>(itemType),
      'title': serializer.toJson<String>(title),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'executionDate': serializer.toJson<DateTime?>(executionDate),
      'description': serializer.toJson<String>(description),
      'location': serializer.toJson<String>(location),
      'colorId': serializer.toJson<String>(colorId),
      'repeatRule': serializer.toJson<String>(repeatRule),
      'listId': serializer.toJson<String>(listId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isConfirmed': serializer.toJson<bool>(isConfirmed),
    };
  }

  TempExtractedItemData copyWith({
    int? id,
    String? itemType,
    String? title,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    Value<DateTime?> executionDate = const Value.absent(),
    String? description,
    String? location,
    String? colorId,
    String? repeatRule,
    String? listId,
    DateTime? createdAt,
    bool? isConfirmed,
  }) => TempExtractedItemData(
    id: id ?? this.id,
    itemType: itemType ?? this.itemType,
    title: title ?? this.title,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    executionDate: executionDate.present
        ? executionDate.value
        : this.executionDate,
    description: description ?? this.description,
    location: location ?? this.location,
    colorId: colorId ?? this.colorId,
    repeatRule: repeatRule ?? this.repeatRule,
    listId: listId ?? this.listId,
    createdAt: createdAt ?? this.createdAt,
    isConfirmed: isConfirmed ?? this.isConfirmed,
  );
  TempExtractedItemData copyWithCompanion(TempExtractedItemsCompanion data) {
    return TempExtractedItemData(
      id: data.id.present ? data.id.value : this.id,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      title: data.title.present ? data.title.value : this.title,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      executionDate: data.executionDate.present
          ? data.executionDate.value
          : this.executionDate,
      description: data.description.present
          ? data.description.value
          : this.description,
      location: data.location.present ? data.location.value : this.location,
      colorId: data.colorId.present ? data.colorId.value : this.colorId,
      repeatRule: data.repeatRule.present
          ? data.repeatRule.value
          : this.repeatRule,
      listId: data.listId.present ? data.listId.value : this.listId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isConfirmed: data.isConfirmed.present
          ? data.isConfirmed.value
          : this.isConfirmed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TempExtractedItemData(')
          ..write('id: $id, ')
          ..write('itemType: $itemType, ')
          ..write('title: $title, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('executionDate: $executionDate, ')
          ..write('description: $description, ')
          ..write('location: $location, ')
          ..write('colorId: $colorId, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('listId: $listId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isConfirmed: $isConfirmed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemType,
    title,
    startDate,
    endDate,
    dueDate,
    executionDate,
    description,
    location,
    colorId,
    repeatRule,
    listId,
    createdAt,
    isConfirmed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TempExtractedItemData &&
          other.id == this.id &&
          other.itemType == this.itemType &&
          other.title == this.title &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.dueDate == this.dueDate &&
          other.executionDate == this.executionDate &&
          other.description == this.description &&
          other.location == this.location &&
          other.colorId == this.colorId &&
          other.repeatRule == this.repeatRule &&
          other.listId == this.listId &&
          other.createdAt == this.createdAt &&
          other.isConfirmed == this.isConfirmed);
}

class TempExtractedItemsCompanion
    extends UpdateCompanion<TempExtractedItemData> {
  final Value<int> id;
  final Value<String> itemType;
  final Value<String> title;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> executionDate;
  final Value<String> description;
  final Value<String> location;
  final Value<String> colorId;
  final Value<String> repeatRule;
  final Value<String> listId;
  final Value<DateTime> createdAt;
  final Value<bool> isConfirmed;
  const TempExtractedItemsCompanion({
    this.id = const Value.absent(),
    this.itemType = const Value.absent(),
    this.title = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.executionDate = const Value.absent(),
    this.description = const Value.absent(),
    this.location = const Value.absent(),
    this.colorId = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.listId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isConfirmed = const Value.absent(),
  });
  TempExtractedItemsCompanion.insert({
    this.id = const Value.absent(),
    required String itemType,
    required String title,
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.executionDate = const Value.absent(),
    this.description = const Value.absent(),
    this.location = const Value.absent(),
    this.colorId = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.listId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isConfirmed = const Value.absent(),
  }) : itemType = Value(itemType),
       title = Value(title);
  static Insertable<TempExtractedItemData> custom({
    Expression<int>? id,
    Expression<String>? itemType,
    Expression<String>? title,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? executionDate,
    Expression<String>? description,
    Expression<String>? location,
    Expression<String>? colorId,
    Expression<String>? repeatRule,
    Expression<String>? listId,
    Expression<DateTime>? createdAt,
    Expression<bool>? isConfirmed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemType != null) 'item_type': itemType,
      if (title != null) 'title': title,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (dueDate != null) 'due_date': dueDate,
      if (executionDate != null) 'execution_date': executionDate,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (colorId != null) 'color_id': colorId,
      if (repeatRule != null) 'repeat_rule': repeatRule,
      if (listId != null) 'list_id': listId,
      if (createdAt != null) 'created_at': createdAt,
      if (isConfirmed != null) 'is_confirmed': isConfirmed,
    });
  }

  TempExtractedItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? itemType,
    Value<String>? title,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<DateTime?>? dueDate,
    Value<DateTime?>? executionDate,
    Value<String>? description,
    Value<String>? location,
    Value<String>? colorId,
    Value<String>? repeatRule,
    Value<String>? listId,
    Value<DateTime>? createdAt,
    Value<bool>? isConfirmed,
  }) {
    return TempExtractedItemsCompanion(
      id: id ?? this.id,
      itemType: itemType ?? this.itemType,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dueDate: dueDate ?? this.dueDate,
      executionDate: executionDate ?? this.executionDate,
      description: description ?? this.description,
      location: location ?? this.location,
      colorId: colorId ?? this.colorId,
      repeatRule: repeatRule ?? this.repeatRule,
      listId: listId ?? this.listId,
      createdAt: createdAt ?? this.createdAt,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (executionDate.present) {
      map['execution_date'] = Variable<DateTime>(executionDate.value);
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
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isConfirmed.present) {
      map['is_confirmed'] = Variable<bool>(isConfirmed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TempExtractedItemsCompanion(')
          ..write('id: $id, ')
          ..write('itemType: $itemType, ')
          ..write('title: $title, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('executionDate: $executionDate, ')
          ..write('description: $description, ')
          ..write('location: $location, ')
          ..write('colorId: $colorId, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('listId: $listId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isConfirmed: $isConfirmed')
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
  late final $ScheduleCompletionTable scheduleCompletion =
      $ScheduleCompletionTable(this);
  late final $TaskCompletionTable taskCompletion = $TaskCompletionTable(this);
  late final $DailyCardOrderTable dailyCardOrder = $DailyCardOrderTable(this);
  late final $AudioContentsTable audioContents = $AudioContentsTable(this);
  late final $TranscriptLinesTable transcriptLines = $TranscriptLinesTable(
    this,
  );
  late final $RecurringPatternTable recurringPattern = $RecurringPatternTable(
    this,
  );
  late final $RecurringExceptionTable recurringException =
      $RecurringExceptionTable(this);
  late final $TempExtractedItemsTable tempExtractedItems =
      $TempExtractedItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    schedule,
    task,
    habit,
    habitCompletion,
    scheduleCompletion,
    taskCompletion,
    dailyCardOrder,
    audioContents,
    transcriptLines,
    recurringPattern,
    recurringException,
    tempExtractedItems,
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recurring_pattern',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recurring_exception', kind: UpdateKind.delete)],
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
      Value<String> repeatRule,
      Value<String> alertSetting,
      Value<DateTime> createdAt,
      Value<String> status,
      Value<String> visibility,
      Value<bool> completed,
      Value<DateTime?> completedAt,
      Value<String> timezone,
      Value<int?> originalHour,
      Value<int?> originalMinute,
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
      Value<DateTime> createdAt,
      Value<String> status,
      Value<String> visibility,
      Value<bool> completed,
      Value<DateTime?> completedAt,
      Value<String> timezone,
      Value<int?> originalHour,
      Value<int?> originalMinute,
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

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalHour => $composableBuilder(
    column: $table.originalHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalMinute => $composableBuilder(
    column: $table.originalMinute,
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

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalHour => $composableBuilder(
    column: $table.originalHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalMinute => $composableBuilder(
    column: $table.originalMinute,
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<int> get originalHour => $composableBuilder(
    column: $table.originalHour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originalMinute => $composableBuilder(
    column: $table.originalMinute,
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
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int?> originalHour = const Value.absent(),
                Value<int?> originalMinute = const Value.absent(),
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
                createdAt: createdAt,
                status: status,
                visibility: visibility,
                completed: completed,
                completedAt: completedAt,
                timezone: timezone,
                originalHour: originalHour,
                originalMinute: originalMinute,
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
                Value<String> repeatRule = const Value.absent(),
                Value<String> alertSetting = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int?> originalHour = const Value.absent(),
                Value<int?> originalMinute = const Value.absent(),
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
                createdAt: createdAt,
                status: status,
                visibility: visibility,
                completed: completed,
                completedAt: completedAt,
                timezone: timezone,
                originalHour: originalHour,
                originalMinute: originalMinute,
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
      Value<int> inboxOrder,
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
      Value<int> inboxOrder,
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

  ColumnFilters<int> get inboxOrder => $composableBuilder(
    column: $table.inboxOrder,
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

  ColumnOrderings<int> get inboxOrder => $composableBuilder(
    column: $table.inboxOrder,
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

  GeneratedColumn<int> get inboxOrder => $composableBuilder(
    column: $table.inboxOrder,
    builder: (column) => column,
  );
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
                Value<int> inboxOrder = const Value.absent(),
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
                inboxOrder: inboxOrder,
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
                Value<int> inboxOrder = const Value.absent(),
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
                inboxOrder: inboxOrder,
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
typedef $$ScheduleCompletionTableCreateCompanionBuilder =
    ScheduleCompletionCompanion Function({
      Value<int> id,
      required int scheduleId,
      required DateTime completedDate,
      required DateTime createdAt,
    });
typedef $$ScheduleCompletionTableUpdateCompanionBuilder =
    ScheduleCompletionCompanion Function({
      Value<int> id,
      Value<int> scheduleId,
      Value<DateTime> completedDate,
      Value<DateTime> createdAt,
    });

class $$ScheduleCompletionTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleCompletionTable> {
  $$ScheduleCompletionTableFilterComposer({
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

  ColumnFilters<int> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
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

class $$ScheduleCompletionTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleCompletionTable> {
  $$ScheduleCompletionTableOrderingComposer({
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

  ColumnOrderings<int> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
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

class $$ScheduleCompletionTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleCompletionTable> {
  $$ScheduleCompletionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ScheduleCompletionTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduleCompletionTable,
          ScheduleCompletionData,
          $$ScheduleCompletionTableFilterComposer,
          $$ScheduleCompletionTableOrderingComposer,
          $$ScheduleCompletionTableAnnotationComposer,
          $$ScheduleCompletionTableCreateCompanionBuilder,
          $$ScheduleCompletionTableUpdateCompanionBuilder,
          (
            ScheduleCompletionData,
            BaseReferences<
              _$AppDatabase,
              $ScheduleCompletionTable,
              ScheduleCompletionData
            >,
          ),
          ScheduleCompletionData,
          PrefetchHooks Function()
        > {
  $$ScheduleCompletionTableTableManager(
    _$AppDatabase db,
    $ScheduleCompletionTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleCompletionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleCompletionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleCompletionTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> scheduleId = const Value.absent(),
                Value<DateTime> completedDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ScheduleCompletionCompanion(
                id: id,
                scheduleId: scheduleId,
                completedDate: completedDate,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int scheduleId,
                required DateTime completedDate,
                required DateTime createdAt,
              }) => ScheduleCompletionCompanion.insert(
                id: id,
                scheduleId: scheduleId,
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

typedef $$ScheduleCompletionTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduleCompletionTable,
      ScheduleCompletionData,
      $$ScheduleCompletionTableFilterComposer,
      $$ScheduleCompletionTableOrderingComposer,
      $$ScheduleCompletionTableAnnotationComposer,
      $$ScheduleCompletionTableCreateCompanionBuilder,
      $$ScheduleCompletionTableUpdateCompanionBuilder,
      (
        ScheduleCompletionData,
        BaseReferences<
          _$AppDatabase,
          $ScheduleCompletionTable,
          ScheduleCompletionData
        >,
      ),
      ScheduleCompletionData,
      PrefetchHooks Function()
    >;
typedef $$TaskCompletionTableCreateCompanionBuilder =
    TaskCompletionCompanion Function({
      Value<int> id,
      required int taskId,
      required DateTime completedDate,
      required DateTime createdAt,
    });
typedef $$TaskCompletionTableUpdateCompanionBuilder =
    TaskCompletionCompanion Function({
      Value<int> id,
      Value<int> taskId,
      Value<DateTime> completedDate,
      Value<DateTime> createdAt,
    });

class $$TaskCompletionTableFilterComposer
    extends Composer<_$AppDatabase, $TaskCompletionTable> {
  $$TaskCompletionTableFilterComposer({
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

  ColumnFilters<int> get taskId => $composableBuilder(
    column: $table.taskId,
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

class $$TaskCompletionTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskCompletionTable> {
  $$TaskCompletionTableOrderingComposer({
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

  ColumnOrderings<int> get taskId => $composableBuilder(
    column: $table.taskId,
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

class $$TaskCompletionTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskCompletionTable> {
  $$TaskCompletionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TaskCompletionTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskCompletionTable,
          TaskCompletionData,
          $$TaskCompletionTableFilterComposer,
          $$TaskCompletionTableOrderingComposer,
          $$TaskCompletionTableAnnotationComposer,
          $$TaskCompletionTableCreateCompanionBuilder,
          $$TaskCompletionTableUpdateCompanionBuilder,
          (
            TaskCompletionData,
            BaseReferences<
              _$AppDatabase,
              $TaskCompletionTable,
              TaskCompletionData
            >,
          ),
          TaskCompletionData,
          PrefetchHooks Function()
        > {
  $$TaskCompletionTableTableManager(
    _$AppDatabase db,
    $TaskCompletionTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskCompletionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskCompletionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskCompletionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> taskId = const Value.absent(),
                Value<DateTime> completedDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TaskCompletionCompanion(
                id: id,
                taskId: taskId,
                completedDate: completedDate,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int taskId,
                required DateTime completedDate,
                required DateTime createdAt,
              }) => TaskCompletionCompanion.insert(
                id: id,
                taskId: taskId,
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

typedef $$TaskCompletionTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskCompletionTable,
      TaskCompletionData,
      $$TaskCompletionTableFilterComposer,
      $$TaskCompletionTableOrderingComposer,
      $$TaskCompletionTableAnnotationComposer,
      $$TaskCompletionTableCreateCompanionBuilder,
      $$TaskCompletionTableUpdateCompanionBuilder,
      (
        TaskCompletionData,
        BaseReferences<_$AppDatabase, $TaskCompletionTable, TaskCompletionData>,
      ),
      TaskCompletionData,
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
typedef $$RecurringPatternTableCreateCompanionBuilder =
    RecurringPatternCompanion Function({
      Value<int> id,
      required String entityType,
      required int entityId,
      required String rrule,
      required DateTime dtstart,
      Value<DateTime?> until,
      Value<int?> count,
      Value<String> timezone,
      Value<String> exdate,
      Value<String> recurrenceMode,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$RecurringPatternTableUpdateCompanionBuilder =
    RecurringPatternCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<int> entityId,
      Value<String> rrule,
      Value<DateTime> dtstart,
      Value<DateTime?> until,
      Value<int?> count,
      Value<String> timezone,
      Value<String> exdate,
      Value<String> recurrenceMode,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$RecurringPatternTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecurringPatternTable,
          RecurringPatternData
        > {
  $$RecurringPatternTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $RecurringExceptionTable,
    List<RecurringExceptionData>
  >
  _recurringExceptionRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringException,
        aliasName: $_aliasNameGenerator(
          db.recurringPattern.id,
          db.recurringException.recurringPatternId,
        ),
      );

  $$RecurringExceptionTableProcessedTableManager get recurringExceptionRefs {
    final manager =
        $$RecurringExceptionTableTableManager(
          $_db,
          $_db.recurringException,
        ).filter(
          (f) => f.recurringPatternId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _recurringExceptionRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecurringPatternTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringPatternTable> {
  $$RecurringPatternTableFilterComposer({
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rrule => $composableBuilder(
    column: $table.rrule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dtstart => $composableBuilder(
    column: $table.dtstart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get until => $composableBuilder(
    column: $table.until,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exdate => $composableBuilder(
    column: $table.exdate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceMode => $composableBuilder(
    column: $table.recurrenceMode,
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

  Expression<bool> recurringExceptionRefs(
    Expression<bool> Function($$RecurringExceptionTableFilterComposer f) f,
  ) {
    final $$RecurringExceptionTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurringException,
      getReferencedColumn: (t) => t.recurringPatternId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringExceptionTableFilterComposer(
            $db: $db,
            $table: $db.recurringException,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringPatternTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringPatternTable> {
  $$RecurringPatternTableOrderingComposer({
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rrule => $composableBuilder(
    column: $table.rrule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dtstart => $composableBuilder(
    column: $table.dtstart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get until => $composableBuilder(
    column: $table.until,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exdate => $composableBuilder(
    column: $table.exdate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceMode => $composableBuilder(
    column: $table.recurrenceMode,
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
}

class $$RecurringPatternTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringPatternTable> {
  $$RecurringPatternTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get rrule =>
      $composableBuilder(column: $table.rrule, builder: (column) => column);

  GeneratedColumn<DateTime> get dtstart =>
      $composableBuilder(column: $table.dtstart, builder: (column) => column);

  GeneratedColumn<DateTime> get until =>
      $composableBuilder(column: $table.until, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get exdate =>
      $composableBuilder(column: $table.exdate, builder: (column) => column);

  GeneratedColumn<String> get recurrenceMode => $composableBuilder(
    column: $table.recurrenceMode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> recurringExceptionRefs<T extends Object>(
    Expression<T> Function($$RecurringExceptionTableAnnotationComposer a) f,
  ) {
    final $$RecurringExceptionTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringException,
          getReferencedColumn: (t) => t.recurringPatternId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringExceptionTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringException,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RecurringPatternTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringPatternTable,
          RecurringPatternData,
          $$RecurringPatternTableFilterComposer,
          $$RecurringPatternTableOrderingComposer,
          $$RecurringPatternTableAnnotationComposer,
          $$RecurringPatternTableCreateCompanionBuilder,
          $$RecurringPatternTableUpdateCompanionBuilder,
          (RecurringPatternData, $$RecurringPatternTableReferences),
          RecurringPatternData,
          PrefetchHooks Function({bool recurringExceptionRefs})
        > {
  $$RecurringPatternTableTableManager(
    _$AppDatabase db,
    $RecurringPatternTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringPatternTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringPatternTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringPatternTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<int> entityId = const Value.absent(),
                Value<String> rrule = const Value.absent(),
                Value<DateTime> dtstart = const Value.absent(),
                Value<DateTime?> until = const Value.absent(),
                Value<int?> count = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> exdate = const Value.absent(),
                Value<String> recurrenceMode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RecurringPatternCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                rrule: rrule,
                dtstart: dtstart,
                until: until,
                count: count,
                timezone: timezone,
                exdate: exdate,
                recurrenceMode: recurrenceMode,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required int entityId,
                required String rrule,
                required DateTime dtstart,
                Value<DateTime?> until = const Value.absent(),
                Value<int?> count = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> exdate = const Value.absent(),
                Value<String> recurrenceMode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RecurringPatternCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                rrule: rrule,
                dtstart: dtstart,
                until: until,
                count: count,
                timezone: timezone,
                exdate: exdate,
                recurrenceMode: recurrenceMode,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecurringPatternTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recurringExceptionRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (recurringExceptionRefs) db.recurringException,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recurringExceptionRefs)
                    await $_getPrefetchedData<
                      RecurringPatternData,
                      $RecurringPatternTable,
                      RecurringExceptionData
                    >(
                      currentTable: table,
                      referencedTable: $$RecurringPatternTableReferences
                          ._recurringExceptionRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RecurringPatternTableReferences(
                            db,
                            table,
                            p0,
                          ).recurringExceptionRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.recurringPatternId == item.id,
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

typedef $$RecurringPatternTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringPatternTable,
      RecurringPatternData,
      $$RecurringPatternTableFilterComposer,
      $$RecurringPatternTableOrderingComposer,
      $$RecurringPatternTableAnnotationComposer,
      $$RecurringPatternTableCreateCompanionBuilder,
      $$RecurringPatternTableUpdateCompanionBuilder,
      (RecurringPatternData, $$RecurringPatternTableReferences),
      RecurringPatternData,
      PrefetchHooks Function({bool recurringExceptionRefs})
    >;
typedef $$RecurringExceptionTableCreateCompanionBuilder =
    RecurringExceptionCompanion Function({
      Value<int> id,
      required int recurringPatternId,
      required DateTime originalDate,
      Value<bool> isCancelled,
      Value<bool> isRescheduled,
      Value<DateTime?> newStartDate,
      Value<DateTime?> newEndDate,
      Value<String?> modifiedTitle,
      Value<String?> modifiedDescription,
      Value<String?> modifiedLocation,
      Value<String?> modifiedColorId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$RecurringExceptionTableUpdateCompanionBuilder =
    RecurringExceptionCompanion Function({
      Value<int> id,
      Value<int> recurringPatternId,
      Value<DateTime> originalDate,
      Value<bool> isCancelled,
      Value<bool> isRescheduled,
      Value<DateTime?> newStartDate,
      Value<DateTime?> newEndDate,
      Value<String?> modifiedTitle,
      Value<String?> modifiedDescription,
      Value<String?> modifiedLocation,
      Value<String?> modifiedColorId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$RecurringExceptionTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecurringExceptionTable,
          RecurringExceptionData
        > {
  $$RecurringExceptionTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecurringPatternTable _recurringPatternIdTable(_$AppDatabase db) =>
      db.recurringPattern.createAlias(
        $_aliasNameGenerator(
          db.recurringException.recurringPatternId,
          db.recurringPattern.id,
        ),
      );

  $$RecurringPatternTableProcessedTableManager get recurringPatternId {
    final $_column = $_itemColumn<int>('recurring_pattern_id')!;

    final manager = $$RecurringPatternTableTableManager(
      $_db,
      $_db.recurringPattern,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recurringPatternIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecurringExceptionTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringExceptionTable> {
  $$RecurringExceptionTableFilterComposer({
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

  ColumnFilters<DateTime> get originalDate => $composableBuilder(
    column: $table.originalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCancelled => $composableBuilder(
    column: $table.isCancelled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRescheduled => $composableBuilder(
    column: $table.isRescheduled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get newStartDate => $composableBuilder(
    column: $table.newStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get newEndDate => $composableBuilder(
    column: $table.newEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modifiedTitle => $composableBuilder(
    column: $table.modifiedTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modifiedDescription => $composableBuilder(
    column: $table.modifiedDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modifiedLocation => $composableBuilder(
    column: $table.modifiedLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modifiedColorId => $composableBuilder(
    column: $table.modifiedColorId,
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

  $$RecurringPatternTableFilterComposer get recurringPatternId {
    final $$RecurringPatternTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringPatternId,
      referencedTable: $db.recurringPattern,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringPatternTableFilterComposer(
            $db: $db,
            $table: $db.recurringPattern,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringExceptionTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringExceptionTable> {
  $$RecurringExceptionTableOrderingComposer({
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

  ColumnOrderings<DateTime> get originalDate => $composableBuilder(
    column: $table.originalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCancelled => $composableBuilder(
    column: $table.isCancelled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRescheduled => $composableBuilder(
    column: $table.isRescheduled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get newStartDate => $composableBuilder(
    column: $table.newStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get newEndDate => $composableBuilder(
    column: $table.newEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modifiedTitle => $composableBuilder(
    column: $table.modifiedTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modifiedDescription => $composableBuilder(
    column: $table.modifiedDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modifiedLocation => $composableBuilder(
    column: $table.modifiedLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modifiedColorId => $composableBuilder(
    column: $table.modifiedColorId,
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

  $$RecurringPatternTableOrderingComposer get recurringPatternId {
    final $$RecurringPatternTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringPatternId,
      referencedTable: $db.recurringPattern,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringPatternTableOrderingComposer(
            $db: $db,
            $table: $db.recurringPattern,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringExceptionTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringExceptionTable> {
  $$RecurringExceptionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get originalDate => $composableBuilder(
    column: $table.originalDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCancelled => $composableBuilder(
    column: $table.isCancelled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRescheduled => $composableBuilder(
    column: $table.isRescheduled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get newStartDate => $composableBuilder(
    column: $table.newStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get newEndDate => $composableBuilder(
    column: $table.newEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modifiedTitle => $composableBuilder(
    column: $table.modifiedTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modifiedDescription => $composableBuilder(
    column: $table.modifiedDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modifiedLocation => $composableBuilder(
    column: $table.modifiedLocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modifiedColorId => $composableBuilder(
    column: $table.modifiedColorId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$RecurringPatternTableAnnotationComposer get recurringPatternId {
    final $$RecurringPatternTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringPatternId,
      referencedTable: $db.recurringPattern,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringPatternTableAnnotationComposer(
            $db: $db,
            $table: $db.recurringPattern,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringExceptionTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringExceptionTable,
          RecurringExceptionData,
          $$RecurringExceptionTableFilterComposer,
          $$RecurringExceptionTableOrderingComposer,
          $$RecurringExceptionTableAnnotationComposer,
          $$RecurringExceptionTableCreateCompanionBuilder,
          $$RecurringExceptionTableUpdateCompanionBuilder,
          (RecurringExceptionData, $$RecurringExceptionTableReferences),
          RecurringExceptionData,
          PrefetchHooks Function({bool recurringPatternId})
        > {
  $$RecurringExceptionTableTableManager(
    _$AppDatabase db,
    $RecurringExceptionTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringExceptionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringExceptionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringExceptionTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> recurringPatternId = const Value.absent(),
                Value<DateTime> originalDate = const Value.absent(),
                Value<bool> isCancelled = const Value.absent(),
                Value<bool> isRescheduled = const Value.absent(),
                Value<DateTime?> newStartDate = const Value.absent(),
                Value<DateTime?> newEndDate = const Value.absent(),
                Value<String?> modifiedTitle = const Value.absent(),
                Value<String?> modifiedDescription = const Value.absent(),
                Value<String?> modifiedLocation = const Value.absent(),
                Value<String?> modifiedColorId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RecurringExceptionCompanion(
                id: id,
                recurringPatternId: recurringPatternId,
                originalDate: originalDate,
                isCancelled: isCancelled,
                isRescheduled: isRescheduled,
                newStartDate: newStartDate,
                newEndDate: newEndDate,
                modifiedTitle: modifiedTitle,
                modifiedDescription: modifiedDescription,
                modifiedLocation: modifiedLocation,
                modifiedColorId: modifiedColorId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int recurringPatternId,
                required DateTime originalDate,
                Value<bool> isCancelled = const Value.absent(),
                Value<bool> isRescheduled = const Value.absent(),
                Value<DateTime?> newStartDate = const Value.absent(),
                Value<DateTime?> newEndDate = const Value.absent(),
                Value<String?> modifiedTitle = const Value.absent(),
                Value<String?> modifiedDescription = const Value.absent(),
                Value<String?> modifiedLocation = const Value.absent(),
                Value<String?> modifiedColorId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RecurringExceptionCompanion.insert(
                id: id,
                recurringPatternId: recurringPatternId,
                originalDate: originalDate,
                isCancelled: isCancelled,
                isRescheduled: isRescheduled,
                newStartDate: newStartDate,
                newEndDate: newEndDate,
                modifiedTitle: modifiedTitle,
                modifiedDescription: modifiedDescription,
                modifiedLocation: modifiedLocation,
                modifiedColorId: modifiedColorId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecurringExceptionTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recurringPatternId = false}) {
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
                    if (recurringPatternId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recurringPatternId,
                                referencedTable:
                                    $$RecurringExceptionTableReferences
                                        ._recurringPatternIdTable(db),
                                referencedColumn:
                                    $$RecurringExceptionTableReferences
                                        ._recurringPatternIdTable(db)
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

typedef $$RecurringExceptionTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringExceptionTable,
      RecurringExceptionData,
      $$RecurringExceptionTableFilterComposer,
      $$RecurringExceptionTableOrderingComposer,
      $$RecurringExceptionTableAnnotationComposer,
      $$RecurringExceptionTableCreateCompanionBuilder,
      $$RecurringExceptionTableUpdateCompanionBuilder,
      (RecurringExceptionData, $$RecurringExceptionTableReferences),
      RecurringExceptionData,
      PrefetchHooks Function({bool recurringPatternId})
    >;
typedef $$TempExtractedItemsTableCreateCompanionBuilder =
    TempExtractedItemsCompanion Function({
      Value<int> id,
      required String itemType,
      required String title,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<DateTime?> dueDate,
      Value<DateTime?> executionDate,
      Value<String> description,
      Value<String> location,
      Value<String> colorId,
      Value<String> repeatRule,
      Value<String> listId,
      Value<DateTime> createdAt,
      Value<bool> isConfirmed,
    });
typedef $$TempExtractedItemsTableUpdateCompanionBuilder =
    TempExtractedItemsCompanion Function({
      Value<int> id,
      Value<String> itemType,
      Value<String> title,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<DateTime?> dueDate,
      Value<DateTime?> executionDate,
      Value<String> description,
      Value<String> location,
      Value<String> colorId,
      Value<String> repeatRule,
      Value<String> listId,
      Value<DateTime> createdAt,
      Value<bool> isConfirmed,
    });

class $$TempExtractedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TempExtractedItemsTable> {
  $$TempExtractedItemsTableFilterComposer({
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

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
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

  ColumnFilters<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isConfirmed => $composableBuilder(
    column: $table.isConfirmed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TempExtractedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TempExtractedItemsTable> {
  $$TempExtractedItemsTableOrderingComposer({
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

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
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

  ColumnOrderings<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isConfirmed => $composableBuilder(
    column: $table.isConfirmed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TempExtractedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TempExtractedItemsTable> {
  $$TempExtractedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get executionDate => $composableBuilder(
    column: $table.executionDate,
    builder: (column) => column,
  );

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

  GeneratedColumn<String> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isConfirmed => $composableBuilder(
    column: $table.isConfirmed,
    builder: (column) => column,
  );
}

class $$TempExtractedItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TempExtractedItemsTable,
          TempExtractedItemData,
          $$TempExtractedItemsTableFilterComposer,
          $$TempExtractedItemsTableOrderingComposer,
          $$TempExtractedItemsTableAnnotationComposer,
          $$TempExtractedItemsTableCreateCompanionBuilder,
          $$TempExtractedItemsTableUpdateCompanionBuilder,
          (
            TempExtractedItemData,
            BaseReferences<
              _$AppDatabase,
              $TempExtractedItemsTable,
              TempExtractedItemData
            >,
          ),
          TempExtractedItemData,
          PrefetchHooks Function()
        > {
  $$TempExtractedItemsTableTableManager(
    _$AppDatabase db,
    $TempExtractedItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TempExtractedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TempExtractedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TempExtractedItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> executionDate = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> colorId = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<String> listId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isConfirmed = const Value.absent(),
              }) => TempExtractedItemsCompanion(
                id: id,
                itemType: itemType,
                title: title,
                startDate: startDate,
                endDate: endDate,
                dueDate: dueDate,
                executionDate: executionDate,
                description: description,
                location: location,
                colorId: colorId,
                repeatRule: repeatRule,
                listId: listId,
                createdAt: createdAt,
                isConfirmed: isConfirmed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String itemType,
                required String title,
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> executionDate = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> colorId = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<String> listId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isConfirmed = const Value.absent(),
              }) => TempExtractedItemsCompanion.insert(
                id: id,
                itemType: itemType,
                title: title,
                startDate: startDate,
                endDate: endDate,
                dueDate: dueDate,
                executionDate: executionDate,
                description: description,
                location: location,
                colorId: colorId,
                repeatRule: repeatRule,
                listId: listId,
                createdAt: createdAt,
                isConfirmed: isConfirmed,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TempExtractedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TempExtractedItemsTable,
      TempExtractedItemData,
      $$TempExtractedItemsTableFilterComposer,
      $$TempExtractedItemsTableOrderingComposer,
      $$TempExtractedItemsTableAnnotationComposer,
      $$TempExtractedItemsTableCreateCompanionBuilder,
      $$TempExtractedItemsTableUpdateCompanionBuilder,
      (
        TempExtractedItemData,
        BaseReferences<
          _$AppDatabase,
          $TempExtractedItemsTable,
          TempExtractedItemData
        >,
      ),
      TempExtractedItemData,
      PrefetchHooks Function()
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
  $$ScheduleCompletionTableTableManager get scheduleCompletion =>
      $$ScheduleCompletionTableTableManager(_db, _db.scheduleCompletion);
  $$TaskCompletionTableTableManager get taskCompletion =>
      $$TaskCompletionTableTableManager(_db, _db.taskCompletion);
  $$DailyCardOrderTableTableManager get dailyCardOrder =>
      $$DailyCardOrderTableTableManager(_db, _db.dailyCardOrder);
  $$AudioContentsTableTableManager get audioContents =>
      $$AudioContentsTableTableManager(_db, _db.audioContents);
  $$TranscriptLinesTableTableManager get transcriptLines =>
      $$TranscriptLinesTableTableManager(_db, _db.transcriptLines);
  $$RecurringPatternTableTableManager get recurringPattern =>
      $$RecurringPatternTableTableManager(_db, _db.recurringPattern);
  $$RecurringExceptionTableTableManager get recurringException =>
      $$RecurringExceptionTableTableManager(_db, _db.recurringException);
  $$TempExtractedItemsTableTableManager get tempExtractedItems =>
      $$TempExtractedItemsTableTableManager(_db, _db.tempExtractedItems);
}
