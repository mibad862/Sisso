import '../helpers/helpers.dart';

class JsonSafe {
  const JsonSafe._();

  static String? string(dynamic value) {
    if (value is Map || value is List) return null;
    return FluxUiHelper.formatString(value);
  }

  static String stringOrEmpty(dynamic value) => string(value) ?? '';

  static int? intOrNull(dynamic value) {
    return FluxUiHelper.formatInt(value, null);
  }

  static int intOrZero(dynamic value) => intOrNull(value) ?? 0;

  static double? doubleOrNull(dynamic value) {
    return FluxUiHelper.formatDouble(value, null);
  }

  static double doubleOrZero(dynamic value) => doubleOrNull(value) ?? 0;

  static bool? boolOrNull(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num && (value == 0 || value == 1)) {
      return FluxUiHelper.formatBool(value);
    }

    final normalized = FluxUiHelper.formatString(value)?.toLowerCase();
    if (normalized == null) return null;
    if (['true', 'yes', '1', '1.0'].contains(normalized)) return true;
    if (['false', 'no', '0', '0.0'].contains(normalized)) return false;
    return null;
  }

  static bool boolOrFalse(dynamic value) => boolOrNull(value) ?? false;

  static bool boolOrTrue(dynamic value) => boolOrNull(value) ?? true;

  static Map<String, dynamic>? map(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  static List<dynamic>? list(dynamic value) {
    if (value is List) return value;
    return null;
  }

  static List<String>? stringList(dynamic value) {
    return list(value)?.map(string).whereType<String>().toList();
  }

  static List<Map<String, dynamic>>? mapList(dynamic value) {
    final listValue = list(value);
    if (listValue == null) return null;

    return listValue.map(map).whereType<Map<String, dynamic>>().toList();
  }

  static List<T> parseList<T>(
    dynamic value,
    T? Function(Map<String, dynamic> json) parser,
  ) {
    final maps = mapList(value);
    if (maps == null) return <T>[];

    return maps.map(parser).whereType<T>().toList();
  }

  static T? parseObject<T>(
    dynamic value,
    T Function(Map<String, dynamic> json) parser,
  ) {
    final mapValue = map(value);
    if (mapValue == null) return null;
    return parser(mapValue);
  }

  static Map<String, dynamic>? action(dynamic value) => map(value);

  static Map<String, dynamic> mapOrEmpty(dynamic value) =>
      map(value) ?? const {};

  static T? enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
    if (source == null) return null;
    if (enumValues.containsKey(source)) return source as T;

    for (final entry in enumValues.entries) {
      if (entry.value == source) return entry.key;
      if (entry.value?.toString() == source.toString()) return entry.key;
    }

    return null;
  }
}
