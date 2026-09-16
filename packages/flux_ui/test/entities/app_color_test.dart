import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flux_ui/src/core/converters/color_converter.dart';
import 'package:flux_ui/src/entities/app/app_color.dart';
import 'package:flux_ui/src/entities/app/app_text_style.dart';
import 'package:flux_ui/src/entities/rating_style_config.dart';

void main() {
  group('ColorConverter', () {
    test('parses common AI hex string formats', () {
      const converter = ColorConverter();

      expect(converter.fromJson('#FF0000'), const Color(0xFFFF0000));
      expect(converter.fromJson('FF0000'), const Color(0xFFFF0000));
      expect(converter.fromJson('0xFFFF0000'), const Color(0xFFFF0000));
      expect(converter.fromJson('#F00'), const Color(0xFFFF0000));
    });

    test('returns null for invalid colors instead of throwing', () {
      const converter = ColorConverter();

      expect(converter.fromJson('#not-a-color'), isNull);
      expect(converter.fromJson({'materialColorName': 'primary'}), isNull);
      expect(
        converter.fromJson({'color': 'blue', 'shade': 'bad'}),
        Colors.blue,
      );
    });
  });

  group('AppColor', () {
    test('parses direct color string', () {
      final color = AppColor.fromDynamic('#00FF00');

      expect(color, const AppColor.solid(Color(0xFF00FF00)));
    });

    test('parses app color object without runtimeType', () {
      final color = AppColor.fromJson({'color': '#0000FF'});

      expect(color, const AppColor.solid(Color(0xFF0000FF)));
    });

    test('parses material theme color object', () {
      final color = AppColor.fromJson({'materialColorName': 'primary'});

      expect(color, AppColor.primary);
    });

    test('parses theme name from wrapped color object', () {
      final color = AppColor.fromJson({'color': 'primary'});

      expect(color, AppColor.primary);
    });
  });

  group('AppColor model usage', () {
    test('AppTextStyle accepts color strings from json', () {
      final style = AppTextStyle.fromJson({
        'color': '#111111',
        'backgroundColor': '222222',
        'decorationColor': '0xFF333333',
      });

      expect(style.color, const AppColor.solid(Color(0xFF111111)));
      expect(style.backgroundColor, const AppColor.solid(Color(0xFF222222)));
      expect(style.decorationColor, const AppColor.solid(Color(0xFF333333)));
    });

    test('FluxRatingStyleConfig accepts color string from json', () {
      final ratingStyle = FluxRatingStyleConfig.fromJson({
        'size': 20,
        'color': '#444444',
      });

      expect(ratingStyle.size, 20);
      expect(ratingStyle.color, const AppColor.solid(Color(0xFF444444)));
    });
  });
}
