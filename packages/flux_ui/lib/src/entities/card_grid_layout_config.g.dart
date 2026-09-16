// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_grid_layout_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CardGridLayoutConfig _$CardGridLayoutConfigFromJson(
  Map<String, dynamic> json,
) => _CardGridLayoutConfig(
  gridConfig: json['gridConfig'] == null
      ? const FluxGridViewConfig()
      : _gridConfigFromJson(json['gridConfig']),
  items: _cardGridItemsFromJson(json['items']),
  borderRadius: json['borderRadius'] == null
      ? 0
      : JsonSafe.doubleOrZero(json['borderRadius']),
);

Map<String, dynamic> _$CardGridLayoutConfigToJson(
  _CardGridLayoutConfig instance,
) => <String, dynamic>{
  'gridConfig': instance.gridConfig.toJson(),
  'items': instance.items.map((e) => e.toJson()).toList(),
  'borderRadius': instance.borderRadius,
};
