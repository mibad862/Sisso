import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_safe.dart';

class StringConverter implements JsonConverter<String, dynamic> {
  const StringConverter();

  @override
  String fromJson(dynamic json) => JsonSafe.string(json) ?? '';

  @override
  String toJson(String object) => object;
}
