import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/core.dart';
import 'app_color.dart';

part 'app_text_style.freezed.dart';
part 'app_text_style.g.dart';

@freezed
abstract class AppTextStyle with _$AppTextStyle {
  const factory AppTextStyle({
    @JsonKey(fromJson: AppColor.nullableFromDynamic) AppColor? color,
    @JsonKey(fromJson: AppColor.nullableFromDynamic) AppColor? backgroundColor,
    @JsonKey(fromJson: JsonSafe.doubleOrNull) double? fontSize,
    @FontWeightConverter() FontWeight? fontWeight,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    FontStyle? fontStyle,
    @JsonKey(fromJson: JsonSafe.doubleOrNull) double? letterSpacing,
    @JsonKey(fromJson: JsonSafe.doubleOrNull) double? wordSpacing,
    @JsonKey(fromJson: JsonSafe.doubleOrNull) double? height,
    @ShadowsConverter() List<Shadow>? shadows,
    @TextDecorationConverter() TextDecoration? decoration,
    @JsonKey(fromJson: AppColor.nullableFromDynamic) AppColor? decorationColor,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    TextDecorationStyle? decorationStyle,
    @JsonKey(fromJson: JsonSafe.doubleOrNull) double? decorationThickness,
    @JsonKey(fromJson: JsonSafe.string) String? fontFamily,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    TextOverflow? overflow,
  }) = _AppTextStyle;

  const AppTextStyle._();

  factory AppTextStyle.fromJson(Map<String, dynamic> json) =>
      _$AppTextStyleFromJson(json);

  factory AppTextStyle.fromTextStyle(TextStyle textStyle) {
    return AppTextStyle(
      color: textStyle.color != null ? AppColor.solid(textStyle.color) : null,
      backgroundColor: textStyle.backgroundColor != null
          ? AppColor.solid(textStyle.backgroundColor)
          : null,
      fontSize: textStyle.fontSize,
      fontWeight: textStyle.fontWeight,
      fontStyle: textStyle.fontStyle,
      letterSpacing: textStyle.letterSpacing,
      wordSpacing: textStyle.wordSpacing,
      height: textStyle.height,
      shadows: textStyle.shadows,
      decoration: textStyle.decoration,
      decorationColor: textStyle.decorationColor != null
          ? AppColor.solid(textStyle.decorationColor)
          : null,
      decorationStyle: textStyle.decorationStyle,
      decorationThickness: textStyle.decorationThickness,
      fontFamily: textStyle.fontFamily,
      overflow: textStyle.overflow,
    );
  }

  TextStyle resolve(BuildContext context) {
    return ThemeHelper.getFont(
      fontFamily,
      textStyle: TextStyle(
        color: color?.resolve(context),
        backgroundColor: backgroundColor?.resolve(context),
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        shadows: shadows,
        decoration: decoration,
        decorationColor: decorationColor?.resolve(context),
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
        overflow: overflow,
      ),
    );
  }
}
