class OrderDeliverySchedule {
  static const optionFieldKeys = <String>[
    'enable_time_slot',
    'timeslot_mandatory_field',
    'timeslot_asap_option',
    'orddd_asap_charges_label',
    'weekdays',
    'enable_weekdays',
    'orddd_enable_shipping_days',
    'time_slots',
    'holidays',
    'orddd_delivery_date_field_label',
    'orddd_delivery_timeslot_field_label',
  ];
  static bool parseOptionFlag(dynamic value) => _parseMetaValueToBool(value);

  final bool enableTimeSlot;
  final bool isTimeSlotMandatory;
  final bool isAsapOptionEnabled;
  final String asapLabel;
  final Map<String, dynamic> weekdays;
  final bool enableWeekdays;
  final bool ordddEnableShippingDays;
  final List<OrderDeliveryTimeSlot> timeSlots;
  final List<String> holidays;
  final String deliveryDateLabel;
  final String deliveryTimeSlotLabel;

  String get resolvedAsapLabel =>
      asapLabel.isNotEmpty ? asapLabel : _asapDeliveryTimeText;

  bool isAsapSlotTime(String? time) =>
      (time ?? '').trim().toLowerCase() == resolvedAsapLabel.toLowerCase();

  const OrderDeliverySchedule({
    this.enableTimeSlot = false,
    this.isTimeSlotMandatory = false,
    this.isAsapOptionEnabled = false,
    this.asapLabel = '',
    this.weekdays = const {},
    this.enableWeekdays = false,
    this.ordddEnableShippingDays = false,
    this.timeSlots = const [],
    this.holidays = const [],
    this.deliveryDateLabel = '',
    this.deliveryTimeSlotLabel = '',
  });

  factory OrderDeliverySchedule.fromJson(Map<String, dynamic> json) {
    final source = json['_schedule_options'] is Map
        ? Map<String, dynamic>.from(json['_schedule_options'])
        : <String, dynamic>{};
    source.addAll(json);

    final enableTimeSlot = parseOptionFlag(source['enable_time_slot']);
    final isTimeSlotMandatory = parseOptionFlag(
      source['timeslot_mandatory_field'],
    );
    final isAsapOptionEnabled = parseOptionFlag(source['timeslot_asap_option']);
    final asapLabel = json['orddd_asap_charges_label']?.toString() ?? '';
    final deliveryDateLabel =
        source['orddd_delivery_date_field_label']?.toString().trim() ?? '';
    final deliveryTimeSlotLabel =
        source['orddd_delivery_timeslot_field_label']?.toString().trim() ?? '';

    final weekdays = source['weekdays'] is Map
        ? Map<String, dynamic>.from(source['weekdays'])
        : <String, dynamic>{};
    final enableWeekdays = parseOptionFlag(source['enable_weekdays']);
    final ordddEnableShippingDays = parseOptionFlag(
      source['orddd_enable_shipping_days'],
    );

    final slots = source['time_slots'];
    final timeSlots = slots is List
        ? slots
              .whereType<Map>()
              .map((item) => OrderDeliveryTimeSlot.fromJson({...item}))
              .toList()
        : <OrderDeliveryTimeSlot>[];

    final holidays = source['holidays'] is List
        ? (source['holidays'] as List)
              .map((item) => item?.toString() ?? '')
              .where((item) => item.isNotEmpty)
              .toList()
        : <String>[];

    return OrderDeliverySchedule(
      enableTimeSlot: enableTimeSlot,
      isTimeSlotMandatory: isTimeSlotMandatory,
      isAsapOptionEnabled: isAsapOptionEnabled,
      asapLabel: asapLabel,
      weekdays: weekdays,
      enableWeekdays: enableWeekdays,
      ordddEnableShippingDays: ordddEnableShippingDays,
      timeSlots: timeSlots,
      holidays: holidays,
      deliveryDateLabel: deliveryDateLabel,
      deliveryTimeSlotLabel: deliveryTimeSlotLabel,
    );
  }

  static List<OrderDeliveryDate> resolveDatesFromPayload(
    dynamic payload, {
    DateTime? now,
  }) => _OrderDeliveryPayloadResolver(now: now).resolve(payload);
}

class _OrderDeliveryPayloadResolver {
  final DateTime _now;
  final Map<String, Map<String, dynamic>> _mergedByDate = {};

  _OrderDeliveryPayloadResolver({DateTime? now}) : _now = now ?? DateTime.now();

  List<OrderDeliveryDate> resolve(dynamic payload) {
    _collectDeliveryDatesFromPayload(payload);
    return _mergedByDate.values
        .map((item) => OrderDeliveryDate.fromJson(item))
        .toList()
      ..sort(
        (a, b) => (a.dateTime ?? DateTime(1970)).compareTo(
          b.dateTime ?? DateTime(1970),
        ),
      );
  }

  DateTime? _parseDateValue(dynamic value) {
    return _OrderDeliveryDateParser.tryParseDate(value);
  }

  String _toDateKey(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String? _normalizeDateKeyFromRaw(Map<String, dynamic> raw) {
    final fromDate = _parseDateValue(raw['date']);
    if (fromDate != null) {
      return _toDateKey(fromDate);
    }

    final fromTimestamp = _OrderDeliveryDateParser.tryParseTimestamp(
      raw['timestamp'],
    );
    if (fromTimestamp != null) {
      return _toDateKey(fromTimestamp);
    }

    final fromDeliveryDate = _parseDateValue(raw['delivery_date']);
    if (fromDeliveryDate != null) {
      return _toDateKey(fromDeliveryDate);
    }

    return null;
  }

  int? _parsePositiveInt(dynamic value) {
    final parsed = int.tryParse(value?.toString() ?? '');
    return parsed != null && parsed > 0 ? parsed : null;
  }

  bool _isLockoutLimitReached(Map<String, dynamic> lockout, int? limit) {
    if (limit == null) {
      return true;
    }
    final orders = _parsePositiveInt(lockout['o']);
    return orders == null || orders >= limit;
  }

  DateTime? _parseLockoutDate(dynamic value, {required bool preferMonthFirst}) {
    return _OrderDeliveryDateParser.tryParsePluginLockoutDate(
      value,
      preferMonthFirst: preferMonthFirst,
    );
  }

  int? _findSlotLockoutLimit(
    String time,
    DateTime date,
    List<Map<String, dynamic>> slots,
  ) {
    final weekdayKey = 'orddd_weekday_${date.weekday % 7}';
    for (final slot in slots) {
      if (slot['time']?.toString().trim() != time) {
        continue;
      }
      final deliveryDays = slot['delivery_days']?.toString().trim() ?? '';
      if (deliveryDays.isNotEmpty &&
          !deliveryDays
              .split(',')
              .map((item) => item.trim())
              .contains(weekdayKey)) {
        continue;
      }
      final limit = _parsePositiveInt(slot['max_orders']);
      if (limit != null) {
        return limit;
      }
    }
    return null;
  }

  void _mergeDateItem(Map<String, dynamic> raw) {
    final key = _normalizeDateKeyFromRaw(raw);
    if (key == null) {
      return;
    }

    final originalDate = raw['date']?.toString().trim();
    raw['date'] ??= key;
    raw['delivery_date'] ??= '${key}T00:00:00';
    final normalizedDate = _parseDateValue(key);
    if (raw['timestamp'] == null && normalizedDate != null) {
      raw['timestamp'] = _OrderDeliveryDateParser.toDateOnlyTimestamp(
        normalizedDate,
      );
    }

    final existing = _mergedByDate[key];
    if (existing == null) {
      _mergedByDate[key] = raw;
      return;
    }

    for (final optionKey in OrderDeliverySchedule.optionFieldKeys) {
      existing[optionKey] ??= raw[optionKey];
    }

    final existingDate = existing['date']?.toString().trim();
    if ((existingDate == null || existingDate.isEmpty || existingDate == key) &&
        (originalDate?.isNotEmpty ?? false)) {
      existing['date'] = originalDate;
    }

    final mergedSlots = <Map<String, dynamic>>[];
    final slotKeys = <String>{};
    void addSlots(dynamic slots) {
      if (slots is! List) {
        return;
      }
      for (final slot in slots.whereType<Map>()) {
        final mapSlot = Map<String, dynamic>.from(slot);
        final uniq =
            '${mapSlot['delivery_days'] ?? ''}|'
            '${mapSlot['time'] ?? ''}|'
            '${mapSlot['max_orders'] ?? ''}|'
            '${mapSlot['charges'] ?? ''}|'
            '${mapSlot['charges_label'] ?? ''}|'
            '${mapSlot['charges_type'] ?? ''}';
        if (slotKeys.add(uniq)) {
          mergedSlots.add(mapSlot);
        }
      }
    }

    addSlots(existing['time_slots']);
    addSlots(raw['time_slots']);
    existing['time_slots'] = mergedSlots;
  }

  void _addDatesFromSchedule(Map<String, dynamic> schedule) {
    final numberOfDates =
        int.tryParse(schedule['number_of_dates']?.toString() ?? '') ?? 15;
    final minimumDeliveryHours =
        num.tryParse(schedule['minimum_delivery_time']?.toString() ?? '') ?? 0;
    final minimumDeliveryDateTime = _now.add(
      Duration(minutes: (minimumDeliveryHours * 60).ceil()),
    );
    final minimumDeliveryDate = DateTime(
      minimumDeliveryDateTime.year,
      minimumDeliveryDateTime.month,
      minimumDeliveryDateTime.day,
    );
    final targetCount = numberOfDates > 0 ? numberOfDates : 15;
    final isSpecificDatesEnabled = OrderDeliverySchedule.parseOptionFlag(
      schedule['enable_specific_dates'],
    );
    final dateLockoutLimit = _parsePositiveInt(schedule['date_lockout']);

    final weekdays = schedule['weekdays'] is Map
        ? Map<String, dynamic>.from(schedule['weekdays'])
        : <String, dynamic>{};
    final rawTimeSlots = schedule['time_slots'] is List
        ? List<Map<String, dynamic>>.from(
            (schedule['time_slots'] as List).whereType<Map>(),
          )
        : <Map<String, dynamic>>[];
    final hasConfiguredTimeSlots = rawTimeSlots.isNotEmpty;
    final holidayDates = <String>{};
    if (schedule['holidays'] is List) {
      for (final holiday in (schedule['holidays'] as List).whereType()) {
        final parsed = _parseDateValue(holiday);
        if (parsed != null) {
          holidayDates.add(_toDateKey(parsed));
        }
      }
    }
    if (schedule['orddd_lockout_date'] is List) {
      for (final lockout
          in (schedule['orddd_lockout_date'] as List).whereType<Map>()) {
        final lockoutMap = Map<String, dynamic>.from(lockout);
        if (!_isLockoutLimitReached(lockoutMap, dateLockoutLimit)) {
          continue;
        }
        final parsed = _parseLockoutDate(
          lockoutMap['d'],
          preferMonthFirst: true,
        );
        if (parsed != null) {
          holidayDates.add(_toDateKey(parsed));
        }
      }
    }

    final lockedSlotsByDate = <String, Set<String>>{};
    if (schedule['orddd_lockout_time_slot'] is List) {
      for (final lockout
          in (schedule['orddd_lockout_time_slot'] as List).whereType<Map>()) {
        final lockoutMap = Map<String, dynamic>.from(lockout);
        final time = lockoutMap['t']?.toString().trim() ?? '';
        final parsed = _parseLockoutDate(
          lockoutMap['d'],
          preferMonthFirst: false,
        );
        if (parsed == null || time.isEmpty) {
          continue;
        }
        final slotLimit = _findSlotLockoutLimit(time, parsed, rawTimeSlots);
        if (!_isLockoutLimitReached(
          lockoutMap,
          slotLimit ?? dateLockoutLimit,
        )) {
          continue;
        }
        final key = _toDateKey(parsed);
        lockedSlotsByDate.putIfAbsent(key, () => <String>{}).add(time);
      }
    }

    final specificDates = <DateTime>[];
    if (isSpecificDatesEnabled && schedule['specific_dates'] is List) {
      for (final value in (schedule['specific_dates'] as List)) {
        final parsed = value is Map
            ? _parseDateValue(value['date'] ?? value['d'] ?? value['value'])
            : _parseDateValue(value);
        if (parsed != null) {
          specificDates.add(parsed);
        }
      }
      specificDates.sort((a, b) => a.compareTo(b));
    }

    Iterable<DateTime> candidateDates() sync* {
      if (specificDates.isNotEmpty) {
        for (final date in specificDates) {
          if (date.isBefore(minimumDeliveryDate)) {
            continue;
          }
          yield date;
        }
        return;
      }

      var scannedDays = 0;
      var date = minimumDeliveryDate;
      while (scannedDays < 365) {
        final phpWeekday = date.weekday % 7;
        final weekdayKey = 'orddd_weekday_$phpWeekday';
        final weekdayConfig = weekdays[weekdayKey];
        final enabledByWeekday = weekdayConfig is Map
            ? OrderDeliverySchedule.parseOptionFlag(weekdayConfig['enable'])
            : weekdays.isEmpty;
        if (enabledByWeekday) {
          yield date;
        }
        date = date.add(const Duration(days: 1));
        scannedDays++;
      }
    }

    var addedDates = 0;
    for (final date in candidateDates()) {
      if (addedDates >= targetCount) {
        break;
      }

      final dateKey = _toDateKey(date);
      if (holidayDates.contains(dateKey)) {
        continue;
      }

      final phpWeekday = date.weekday % 7;
      final weekdayKey = 'orddd_weekday_$phpWeekday';
      final lockedTimes = lockedSlotsByDate[dateKey] ?? const <String>{};

      final timeSlotsByDate = rawTimeSlots
          .where(
            (slot) =>
                slot['delivery_days'] == null ||
                slot['delivery_days'].toString().isEmpty ||
                slot['delivery_days'] == weekdayKey,
          )
          .where(
            (slot) => !lockedTimes.contains(slot['time']?.toString() ?? ''),
          )
          .map((slot) => Map<String, dynamic>.from(slot))
          .toList();

      if (hasConfiguredTimeSlots && timeSlotsByDate.isEmpty) {
        continue;
      }

      final raw = <String, dynamic>{
        'timestamp': _OrderDeliveryDateParser.toDateOnlyTimestamp(date),
        'date': dateKey,
        'delivery_date': date.toIso8601String(),
        'time_slots': timeSlotsByDate,
        '_schedule_options': schedule,
      };
      for (final key in OrderDeliverySchedule.optionFieldKeys) {
        // Keep the per-date slot list after removing locked time slots.
        if (key == 'time_slots') {
          continue;
        }
        raw[key] = schedule[key];
      }
      _mergeDateItem(raw);
      addedDates++;
    }
  }

  void _collectDeliveryDatesFromPayload(
    dynamic payload, {
    Map<String, dynamic>? inheritedOptions,
  }) {
    if (payload is List) {
      for (final item in payload) {
        _collectDeliveryDatesFromPayload(
          item,
          inheritedOptions: inheritedOptions,
        );
      }
      return;
    }

    if (payload is! Map) {
      return;
    }

    final item = Map<String, dynamic>.from(payload);
    if (inheritedOptions != null) {
      for (final key in OrderDeliverySchedule.optionFieldKeys) {
        item[key] ??= inheritedOptions[key];
      }
    }

    final hasDateFields =
        item['date'] != null ||
        item['timestamp'] != null ||
        item['delivery_date'] != null;
    if (hasDateFields) {
      _mergeDateItem(item);
      return;
    }

    final hasScheduleShape =
        item['time_slots'] is List ||
        item['number_of_dates'] != null ||
        item['minimum_delivery_time'] != null ||
        item['weekdays'] is Map;
    if (hasScheduleShape) {
      _addDatesFromSchedule(item);
      return;
    }

    const nestedKeys = ['delivery_dates', 'dates', 'available_dates'];
    for (final nestedKey in nestedKeys) {
      final nested = item[nestedKey];
      if (nested is List && nested.isNotEmpty) {
        _collectDeliveryDatesFromPayload(nested, inheritedOptions: item);
      }
    }
  }
}

class OrderDeliveryDate {
  String? timeStamp;
  String? dateString;
  DateTime? dateTime;
  String? deliveryDate;
  OrderDeliverySchedule schedule = const OrderDeliverySchedule();
  List<OrderDeliveryTimeSlot> timeSlots = [];
  OrderDeliveryTimeSlot? selectedTimeSlot;

  bool get isTimeSlotEnabled => schedule.enableTimeSlot;
  bool get isTimeSlotRequired => schedule.isTimeSlotMandatory;
  bool get isAsapOptionEnabled => schedule.isAsapOptionEnabled;

  OrderDeliveryDate(this.dateTime);

  OrderDeliveryDate.fromJson(json) {
    timeStamp = json['timestamp'].toString();
    dateString = json['date']?.toString();
    deliveryDate = json['delivery_date'];

    if (json['time_slots'] is List) {
      for (final item in json['time_slots']) {
        if (item is Map) {
          timeSlots.add(OrderDeliveryTimeSlot.fromJson({...item}));
        }
      }
    }

    final raw = json is Map
        ? Map<String, dynamic>.from(json)
        : <String, dynamic>{};
    schedule = OrderDeliverySchedule.fromJson(raw);

    final normalizedDate = _OrderDeliveryDateParser.tryParseDate(dateString);
    if (normalizedDate != null) {
      dateTime = normalizedDate;
    } else if (deliveryDate != null && (deliveryDate?.isNotEmpty ?? false)) {
      final parsedDeliveryDate = DateTime.tryParse(deliveryDate.toString());
      if (parsedDeliveryDate != null) {
        dateTime = DateTime(
          parsedDeliveryDate.year,
          parsedDeliveryDate.month,
          parsedDeliveryDate.day,
        );
      }
    } else if (timeStamp != null) {
      final fromTimestamp = _OrderDeliveryDateParser.tryParseTimestamp(
        timeStamp,
      );
      if (fromTimestamp != null) {
        dateTime = DateTime(
          fromTimestamp.year,
          fromTimestamp.month,
          fromTimestamp.day,
        );
      }
    }

    timeSlots = _filterTimeSlotsByDate(timeSlots: timeSlots, date: dateTime);

    if (schedule.enableTimeSlot && schedule.isAsapOptionEnabled) {
      final asapValue = schedule.resolvedAsapLabel;
      final hasAsap = timeSlots.any(
        (slot) => schedule.isAsapSlotTime(slot.time),
      );
      if (!hasAsap) {
        final asapSlot = OrderDeliveryTimeSlot()..time = asapValue;
        timeSlots.insert(0, asapSlot);
      }
    }

    // Keep time slot unselected by default so non-mandatory flow can submit
    // without forcing a value like "As soon as possible".
    selectedTimeSlot = null;
  }

  List<OrderDeliveryTimeSlot> _filterTimeSlotsByDate({
    required List<OrderDeliveryTimeSlot> timeSlots,
    required DateTime? date,
  }) {
    if (date == null || timeSlots.isEmpty) {
      return timeSlots;
    }

    final weekdayKey = 'orddd_weekday_${date.weekday % 7}';
    return timeSlots.where((slot) {
      final days = slot.deliveryDays?.trim() ?? '';
      if (days.isEmpty) {
        return true;
      }
      return days.split(',').map((item) => item.trim()).contains(weekdayKey);
    }).toList();
  }
}

// Keep canonical ASAP value aligned with Order Delivery Date plugin default.
const _asapDeliveryTimeText = 'As Soon As Possible.';

bool _parseMetaValueToBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.toLowerCase();
    return normalized == 'on' ||
        normalized == 'checked' ||
        normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes';
  }
  return false;
}

class _OrderDeliveryDateParser {
  static int toDateOnlyTimestamp(DateTime value) {
    return DateTime.utc(
          value.year,
          value.month,
          value.day,
          12,
        ).millisecondsSinceEpoch ~/
        1000;
  }

  static DateTime? _buildDate({
    required int year,
    required int month,
    required int day,
  }) {
    final date = DateTime(year, month, day);
    if (date.year == year && date.month == month && date.day == day) {
      return date;
    }
    return null;
  }

  static DateTime? _tryParseDashedDate(String raw, {required bool monthFirst}) {
    final parts = raw.split('-');
    if (parts.length != 3 || parts[2].length != 4) {
      return null;
    }

    final first = int.tryParse(parts[0]);
    final second = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (year == null || first == null || second == null) {
      return null;
    }

    return monthFirst
        ? _buildDate(year: year, month: first, day: second)
        : _buildDate(year: year, month: second, day: first);
  }

  static DateTime? tryParseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) {
      return null;
    }

    final iso = DateTime.tryParse(raw);
    if (iso != null) {
      return DateTime(iso.year, iso.month, iso.day);
    }

    return _tryParseDashedDate(raw, monthFirst: false);
  }

  static DateTime? tryParsePluginLockoutDate(
    dynamic value, {
    required bool preferMonthFirst,
  }) {
    if (value == null) {
      return null;
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) {
      return null;
    }

    final iso = DateTime.tryParse(raw);
    if (iso != null) {
      return DateTime(iso.year, iso.month, iso.day);
    }

    return _tryParseDashedDate(raw, monthFirst: preferMonthFirst) ??
        _tryParseDashedDate(raw, monthFirst: !preferMonthFirst);
  }

  static DateTime? tryParseTimestamp(dynamic value) {
    if (value == null) {
      return null;
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) {
      return null;
    }

    final timestamp = num.tryParse(raw)?.toInt();
    if (timestamp == null) {
      return null;
    }

    final millis = timestamp.abs() > 100000000000
        ? timestamp
        : timestamp * 1000;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }
}

class OrderDeliveryTimeSlot {
  String? deliveryDays;
  String? time;
  String? maxOrders;
  String? charges;
  String? chargesLabel;
  String? chargesType;

  OrderDeliveryTimeSlot();

  OrderDeliveryTimeSlot.fromJson(Map<String, dynamic> json) {
    deliveryDays = json['delivery_days']?.toString();
    time = json['time']?.toString();
    maxOrders = json['max_orders']?.toString();
    charges = json['charges']?.toString();
    chargesLabel = json['charges_label']?.toString();
    chargesType = json['charges_type']?.toString();
  }
}
