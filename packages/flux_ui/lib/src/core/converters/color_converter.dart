import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspireui/extensions.dart';

/// A JSON converter for [Color] that handles multiple color format representations.
///
/// This converter supports five formats:
/// 1. Hex color strings (with or without alpha)
/// 2. RGB map format
/// 3. RGBA map format
/// 4. Material color names
/// 5. Material color with shade
///
/// Example usage with hex format:
/// ```dart
/// // Serialization
/// final json = ColorConverter().toJson(Colors.red);
/// print(json); // '#FF0000'
///
/// // Deserialization
/// final color = ColorConverter().fromJson('#FF0000');
/// print(color); // Color(0xFFFF0000)
/// ```
///
/// Example usage with RGB/RGBA format:
/// ```dart
/// // Serialization (always converts to hex)
/// final json = ColorConverter().toJson(Colors.red.withValueOpacity(0.5));
/// print(json); // '#80FF0000'
///
/// // Deserialization
/// final color = ColorConverter().fromJson({
///   'r': 255,
///   'g': 0,
///   'b': 0,
///   'a': 0.5
/// });
/// print(color); // Color(0x80FF0000)
/// ```
///
/// JSON Format Examples:
/// ```json
/// // 1. Hex format (preferred)
/// "#FF0000"           // Solid red
/// "#80FF0000"        // Semi-transparent red
///
/// // 2. RGB format
/// {
///   "r": 255,        // Red component (0-255)
///   "g": 0,          // Green component (0-255)
///   "b": 0           // Blue component (0-255)
/// }
///
/// // 3. RGBA format
/// {
///   "r": 255,        // Red component (0-255)
///   "g": 0,          // Green component (0-255)
///   "b": 0,          // Blue component (0-255)
///   "a": 0.5         // Alpha component (0.0-1.0)
/// }
///
/// // 4. Material color name
/// "red"              // Uses Colors.red
/// "blue"             // Uses Colors.blue
///
/// // 5. Material color with shade
/// {
///   "color": "blue", // Material color name
///   "shade": 100     // Shade value (50-900)
/// }
///
/// // Null value
/// null               // Results in null color
/// ```
///
/// Supported material color names:
/// * 'red' → Colors.red
/// * 'blue' → Colors.blue
/// * 'green' → Colors.green
/// * 'yellow' → Colors.yellow
/// * 'orange' → Colors.orange
/// * 'purple' → Colors.purple
/// * 'pink' → Colors.pink
/// * 'brown' → Colors.brown
/// * 'grey' → Colors.grey
/// * 'black' → Colors.black
/// * 'white' → Colors.white
/// * 'transparent' → Colors.transparent
///
/// Note:
/// - Hex format is the preferred output format for serialization
/// - When using hex format, 6 digits (#RRGGBB) assumes full opacity
/// - 8-digit hex (#AARRGGBB) explicitly defines alpha channel
/// - RGB values should be integers between 0 and 255
/// - Alpha values should be doubles between 0.0 and 1.0
/// - Invalid color values will result in null
class ColorConverter implements JsonConverter<Color?, dynamic> {
  const ColorConverter();

  @override
  Color? fromJson(dynamic json) {
    if (json == null) return null;

    // Handle hex string
    if (json is String) {
      final hexColor = _tryParseHexColor(json);
      if (hexColor != null) {
        return hexColor;
      }

      // Handle material color names
      switch (json.trim().toLowerCase()) {
        case 'red':
          return Colors.red;
        case 'blue':
          return Colors.blue;
        case 'green':
          return Colors.green;
        case 'yellow':
          return Colors.yellow;
        case 'orange':
          return Colors.orange;
        case 'purple':
          return Colors.purple;
        case 'pink':
          return Colors.pink;
        case 'brown':
          return Colors.brown;
        case 'grey':
          return Colors.grey;
        case 'black':
          return Colors.black;
        case 'white':
          return Colors.white;
        case 'transparent':
          return Colors.transparent;
      }
    }

    // Handle map format
    if (json is Map) {
      // Handle material color with shade
      if (json.containsKey('color') && json.containsKey('shade')) {
        final materialColor = fromJson(json['color']);
        if (materialColor != null) {
          final shade = _tryParseInt(json['shade']);
          if (shade != null && materialColor is MaterialColor) {
            return materialColor[shade];
          }
        }
      }

      // Handle wrapped form {color: <hex|name>} (no shade) — unwrap and parse.
      if (json.containsKey('color')) {
        return fromJson(json['color']);
      }

      // Handle RGB/RGBA format
      if (!json.containsKey('r') &&
          !json.containsKey('g') &&
          !json.containsKey('b')) {
        return null;
      }

      final r = _tryParseInt(json['r'])?.clamp(0, 255).toInt() ?? 0;
      final g = _tryParseInt(json['g'])?.clamp(0, 255).toInt() ?? 0;
      final b = _tryParseInt(json['b'])?.clamp(0, 255).toInt() ?? 0;
      final a = _tryParseAlpha(json['a']) ?? 1.0;

      return Color.fromRGBO(r, g, b, a);
    }

    return null;
  }

  @override
  String? toJson(Color? color) {
    if (color == null) return null;
    return '#${color.toColorText()}';
  }

  static Color? _tryParseHexColor(String value) {
    var hex = value.trim();
    if (hex.isEmpty) return null;

    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    } else if (hex.toLowerCase().startsWith('0x')) {
      hex = hex.substring(2);
    }

    if (hex.length == 3) {
      hex = hex.split('').map((e) => '$e$e').join();
    }

    if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex)) {
      return null;
    }

    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    if (hex.length != 8) {
      return null;
    }

    final colorValue = int.tryParse(hex, radix: 16);
    return colorValue == null ? null : Color(colorValue);
  }

  static int? _tryParseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static double? _tryParseAlpha(dynamic value) {
    if (value == null) return null;

    final alpha = value is num
        ? value.toDouble()
        : value is String
        ? double.tryParse(value.trim())
        : null;

    if (alpha == null) return null;
    if (alpha > 1.0) {
      return (alpha / 255).clamp(0.0, 1.0);
    }
    return alpha.clamp(0.0, 1.0);
  }
}
