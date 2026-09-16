import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'color_converter.dart';
import 'json_safe.dart';

class ShadowsConverter implements JsonConverter<List<Shadow>?, dynamic> {
  const ShadowsConverter();

  static const _colorConverter = ColorConverter();

  @override
  List<Shadow>? fromJson(dynamic value) {
    final json = JsonSafe.mapList(value);
    if (json == null) return null;

    return json.map((map) {
      final offset = JsonSafe.map(map['offset']);
      return Shadow(
        color: _colorConverter.fromJson(map['color']) ?? Colors.black,
        offset: offset != null
            ? Offset(
                JsonSafe.doubleOrNull(offset['dx']) ?? 0.0,
                JsonSafe.doubleOrNull(offset['dy']) ?? 0.0,
              )
            : Offset.zero,
        blurRadius: JsonSafe.doubleOrNull(map['blurRadius']) ?? 0.0,
      );
    }).toList();
  }

  @override
  List<Map<String, dynamic>>? toJson(List<Shadow>? shadows) {
    if (shadows == null) return null;

    return shadows
        .map(
          (shadow) => {
            'color': const ColorConverter().toJson(shadow.color),
            'offset': {'dx': shadow.offset.dx, 'dy': shadow.offset.dy},
            'blurRadius': shadow.blurRadius,
          },
        )
        .toList();
  }
}
