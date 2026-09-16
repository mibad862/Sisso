// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flux_edge_insets_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FluxEdgeInsetsConfig _$FluxEdgeInsetsConfigFromJson(
  Map<String, dynamic> json,
) => _FluxEdgeInsetsConfig(
  start: _EdgeConfigHelper.parseOldConfig(json, 'start') == null
      ? 0
      : JsonSafe.doubleOrZero(_EdgeConfigHelper.parseOldConfig(json, 'start')),
  end: _EdgeConfigHelper.parseOldConfig(json, 'end') == null
      ? 0
      : JsonSafe.doubleOrZero(_EdgeConfigHelper.parseOldConfig(json, 'end')),
  top: json['top'] == null ? 0 : JsonSafe.doubleOrZero(json['top']),
  bottom: json['bottom'] == null ? 0 : JsonSafe.doubleOrZero(json['bottom']),
);

Map<String, dynamic> _$FluxEdgeInsetsConfigToJson(
  _FluxEdgeInsetsConfig instance,
) => <String, dynamic>{
  'start': instance.start,
  'end': instance.end,
  'top': instance.top,
  'bottom': instance.bottom,
};
