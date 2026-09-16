// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flux_image_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FluxImageConfig _$FluxImageConfigFromJson(Map<String, dynamic> json) =>
    _FluxImageConfig(
      url: json['url'] == null ? '' : JsonSafe.stringOrEmpty(json['url']),
      styleConfig: _fluxImageStyleConfigFromJson(json['styleConfig']),
    );

Map<String, dynamic> _$FluxImageConfigToJson(_FluxImageConfig instance) =>
    <String, dynamic>{
      'url': instance.url,
      'styleConfig': instance.styleConfig?.toJson(),
    };

_FluxImageStyleConfig _$FluxImageStyleConfigFromJson(
  Map<String, dynamic> json,
) => _FluxImageStyleConfig(
  width: JsonSafe.doubleOrNull(json['width']),
  height: JsonSafe.doubleOrNull(json['height']),
  aspectRatio: JsonSafe.doubleOrNull(json['aspectRatio']),
  borderRadius: const BorderRadiusDirectionalConverter().fromJson(
    json['borderRadius'],
  ),
  fit: const BoxFitConverter().fromJson(json['fit']),
  color: const ColorConverter().fromJson(json['color']),
  alignment: const AlignmentDirectionalConverter().fromJson(json['alignment']),
);

Map<String, dynamic> _$FluxImageStyleConfigToJson(
  _FluxImageStyleConfig instance,
) => <String, dynamic>{
  'width': instance.width,
  'height': instance.height,
  'aspectRatio': instance.aspectRatio,
  'borderRadius': _$JsonConverterToJson<dynamic, BorderRadiusDirectional>(
    instance.borderRadius,
    const BorderRadiusDirectionalConverter().toJson,
  ),
  'fit': const BoxFitConverter().toJson(instance.fit),
  'color': const ColorConverter().toJson(instance.color),
  'alignment': const AlignmentDirectionalConverter().toJson(instance.alignment),
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
