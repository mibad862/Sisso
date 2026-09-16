import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_safe.dart';

class TextDecorationConverter
    implements JsonConverter<TextDecoration?, dynamic> {
  const TextDecorationConverter();

  @override
  TextDecoration? fromJson(dynamic source) {
    final value = JsonSafe.string(source);
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'none':
        return TextDecoration.none;
      case 'underline':
        return TextDecoration.underline;
      case 'overline':
        return TextDecoration.overline;
      case 'linethrough':
        return TextDecoration.lineThrough;
      default:
        return null;
    }
  }

  @override
  String? toJson(TextDecoration? decoration) {
    if (decoration == null) return null;
    if (decoration == TextDecoration.none) return 'none';
    if (decoration == TextDecoration.underline) return 'underline';
    if (decoration == TextDecoration.overline) return 'overline';
    if (decoration == TextDecoration.lineThrough) return 'linethrough';
    return null;
  }
}
