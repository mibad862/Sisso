// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_grid_item_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CardGridItemConfig _$CardGridItemConfigFromJson(Map<String, dynamic> json) =>
    _CardGridItemConfig(
      id: JsonSafe.string(json['id']),
      name: JsonSafe.stringOrEmpty(json['name']),
      imageUrl: JsonSafe.stringOrEmpty(json['imageUrl']),
    );

Map<String, dynamic> _$CardGridItemConfigToJson(_CardGridItemConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
    };
