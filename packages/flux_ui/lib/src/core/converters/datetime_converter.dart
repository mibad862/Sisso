import 'package:json_annotation/json_annotation.dart';

import 'json_safe.dart';

class DateTimeConverter implements JsonConverter<DateTime?, dynamic> {
  const DateTimeConverter();

  @override
  DateTime? fromJson(dynamic value) {
    final json = JsonSafe.string(value);
    if (json == null) return null;

    return DateTime.tryParse(json);
  }

  @override
  String? toJson(DateTime? object) {
    return object?.toIso8601String();
  }
}
