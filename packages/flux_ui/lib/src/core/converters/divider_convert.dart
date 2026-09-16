import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'color_converter.dart';
import 'json_safe.dart';

class DividerConverter implements JsonConverter<Divider?, dynamic> {
  const DividerConverter();

  static const _colorConverter = ColorConverter();

  @override
  Divider? fromJson(dynamic value) {
    final json = JsonSafe.map(value);
    if (json == null) return null;

    return Divider(
      color: _colorConverter.fromJson(json['color']),
      thickness: JsonSafe.doubleOrNull(json['thickness']) ?? 1,
      indent: JsonSafe.doubleOrNull(json['indent']) ?? 0,
      endIndent: JsonSafe.doubleOrNull(json['endIndent']) ?? 0,
      height: JsonSafe.doubleOrNull(json['height']) ?? 0,
    );
  }

  @override
  Map<String, dynamic>? toJson(Divider? divider) {
    if (divider == null) return null;

    return {
      'color': _colorConverter.toJson(divider.color),
      'thickness': divider.thickness,
      'indent': divider.indent,
      'endIndent': divider.endIndent,
      'height': divider.height,
    };
  }
}
