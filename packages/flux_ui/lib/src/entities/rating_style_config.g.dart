// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_style_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FluxRatingStyleConfig _$FluxRatingStyleConfigFromJson(
  Map<String, dynamic> json,
) => _FluxRatingStyleConfig(
  size: json['size'] == null ? 16 : _ratingSizeFromJson(json['size']),
  color: json['color'] == null
      ? AppColor.primary
      : AppColor.fromDynamic(json['color']),
);

Map<String, dynamic> _$FluxRatingStyleConfigToJson(
  _FluxRatingStyleConfig instance,
) => <String, dynamic>{'size': instance.size, 'color': instance.color.toJson()};
