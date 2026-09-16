import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

export 'theme_helper.dart';

class FluxUiHelper {
  static String? formatString(dynamic value) {
    if (value == null) {
      return null;
    }

    final stringValue = value.toString().trim();
    return stringValue.isEmpty ? null : stringValue;
  }

  static double? formatDouble(dynamic value, [double? defaultValue = 0.0]) {
    if (value == null || value == '') {
      return null;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is double) {
      return value;
    }
    return double.tryParse(value.toString()) ?? defaultValue;
  }

  static int? formatInt([dynamic value = '0', int? defaultValue]) {
    if (value == null || value == '') {
      return defaultValue;
    }

    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  static bool formatBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      if (value == 1) {
        return true;
      }
      if (value == 0) {
        return false;
      }
      return defaultValue;
    }

    final stringValue = formatString(value)?.toLowerCase();
    if (stringValue == null) {
      return defaultValue;
    }

    if (['true', 'yes', '1', '1.0'].contains(stringValue)) {
      return true;
    }
    if (['false', 'no', '0', '0.0'].contains(stringValue)) {
      return false;
    }
    return defaultValue;
  }

  static BoxFit boxFit(String? fit, {BoxFit? defaultValue}) {
    switch (fit) {
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'fitHeight':
        return BoxFit.fitHeight;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'scaleDown':
        return BoxFit.scaleDown;
      case 'cover':
        return BoxFit.cover;
      default:
        return defaultValue ?? BoxFit.fitWidth;
    }
  }

  static String? compactNumberFormat(
    dynamic value, {
    double defaultValue = 0.0,
  }) {
    var number = value.toString();

    var doubleNumber = double.tryParse(number) ?? defaultValue;

    if (doubleNumber < 9999) {
      return doubleNumber.toStringAsFixed(1);
    }

    var numberFormat = NumberFormat.compact();

    return numberFormat.format(doubleNumber);
  }

  static Color getColorFromName(String name) {
    if (name.isEmpty) {
      return Colors.grey;
    }

    final hashCode = name.hashCode.abs();

    final hue = (hashCode % 360).toDouble();
    const saturation = 0.7;
    const lightness = 0.4;

    return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
  }
}
