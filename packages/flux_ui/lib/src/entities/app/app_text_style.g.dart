// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_text_style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppTextStyle _$AppTextStyleFromJson(Map<String, dynamic> json) =>
    _AppTextStyle(
      color: AppColor.nullableFromDynamic(json['color']),
      backgroundColor: AppColor.nullableFromDynamic(json['backgroundColor']),
      fontSize: JsonSafe.doubleOrNull(json['fontSize']),
      fontWeight: const FontWeightConverter().fromJson(json['fontWeight']),
      fontStyle: $enumDecodeNullable(
        _$FontStyleEnumMap,
        json['fontStyle'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      letterSpacing: JsonSafe.doubleOrNull(json['letterSpacing']),
      wordSpacing: JsonSafe.doubleOrNull(json['wordSpacing']),
      height: JsonSafe.doubleOrNull(json['height']),
      shadows: const ShadowsConverter().fromJson(json['shadows']),
      decoration: const TextDecorationConverter().fromJson(json['decoration']),
      decorationColor: AppColor.nullableFromDynamic(json['decorationColor']),
      decorationStyle: $enumDecodeNullable(
        _$TextDecorationStyleEnumMap,
        json['decorationStyle'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      decorationThickness: JsonSafe.doubleOrNull(json['decorationThickness']),
      fontFamily: JsonSafe.string(json['fontFamily']),
      overflow: $enumDecodeNullable(
        _$TextOverflowEnumMap,
        json['overflow'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
    );

Map<String, dynamic> _$AppTextStyleToJson(_AppTextStyle instance) =>
    <String, dynamic>{
      'color': instance.color?.toJson(),
      'backgroundColor': instance.backgroundColor?.toJson(),
      'fontSize': instance.fontSize,
      'fontWeight': const FontWeightConverter().toJson(instance.fontWeight),
      'fontStyle': _$FontStyleEnumMap[instance.fontStyle],
      'letterSpacing': instance.letterSpacing,
      'wordSpacing': instance.wordSpacing,
      'height': instance.height,
      'shadows': const ShadowsConverter().toJson(instance.shadows),
      'decoration': const TextDecorationConverter().toJson(instance.decoration),
      'decorationColor': instance.decorationColor?.toJson(),
      'decorationStyle': _$TextDecorationStyleEnumMap[instance.decorationStyle],
      'decorationThickness': instance.decorationThickness,
      'fontFamily': instance.fontFamily,
      'overflow': _$TextOverflowEnumMap[instance.overflow],
    };

const _$FontStyleEnumMap = {
  FontStyle.normal: 'normal',
  FontStyle.italic: 'italic',
};

const _$TextDecorationStyleEnumMap = {
  TextDecorationStyle.solid: 'solid',
  TextDecorationStyle.double: 'double',
  TextDecorationStyle.dotted: 'dotted',
  TextDecorationStyle.dashed: 'dashed',
  TextDecorationStyle.wavy: 'wavy',
};

const _$TextOverflowEnumMap = {
  TextOverflow.clip: 'clip',
  TextOverflow.fade: 'fade',
  TextOverflow.ellipsis: 'ellipsis',
  TextOverflow.visible: 'visible',
};
