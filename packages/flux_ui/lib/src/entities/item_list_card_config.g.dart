// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_list_card_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemListCardConfig _$ItemListCardConfigFromJson(Map<String, dynamic> json) =>
    _ItemListCardConfig(
      title: const StringConverter().fromJson(json['title']),
      subtitle: JsonSafe.string(json['subtitle']),
      imageUrl: const StringConverter().fromJson(json['imageUrl']),
      action: _actionItemCardConfigFromJson(json['action']),
      tags: JsonSafe.stringList(json['tags']),
    );

Map<String, dynamic> _$ItemListCardConfigToJson(_ItemListCardConfig instance) =>
    <String, dynamic>{
      'title': const StringConverter().toJson(instance.title),
      'subtitle': instance.subtitle,
      'imageUrl': const StringConverter().toJson(instance.imageUrl),
      'action': instance.action?.toJson(),
      'tags': instance.tags,
    };

_ActionItemCardConfig _$ActionItemCardConfigFromJson(
  Map<String, dynamic> json,
) => _ActionItemCardConfig(
  title: JsonSafe.string(json['title']),
  action: JsonSafe.mapOrEmpty(json['action']),
  alignment: const AlignmentDirectionalConverter().fromJson(json['alignment']),
);

Map<String, dynamic> _$ActionItemCardConfigToJson(
  _ActionItemCardConfig instance,
) => <String, dynamic>{
  'title': instance.title,
  'action': instance.action,
  'alignment': const AlignmentDirectionalConverter().toJson(instance.alignment),
};

_StyleItemCardConfig _$StyleItemCardConfigFromJson(Map<String, dynamic> json) =>
    _StyleItemCardConfig(
      decoration: const DecorationConverter().fromJson(json['decoration']),
      padding: const EdgeInsetsDirectionalConverter().fromJson(json['padding']),
      margin: const EdgeInsetsDirectionalConverter().fromJson(json['margin']),
    );

Map<String, dynamic> _$StyleItemCardConfigToJson(
  _StyleItemCardConfig instance,
) => <String, dynamic>{
  'decoration': const DecorationConverter().toJson(instance.decoration),
  'padding': const EdgeInsetsDirectionalConverter().toJson(instance.padding),
  'margin': const EdgeInsetsDirectionalConverter().toJson(instance.margin),
};

_TextItemConfig _$TextItemConfigFromJson(Map<String, dynamic> json) =>
    _TextItemConfig(
      maxLines: JsonSafe.intOrNull(json['maxLines']),
      style: const TextStyleConverter().fromJson(json['style']),
      padding: const EdgeInsetsDirectionalConverter().fromJson(json['padding']),
    );

Map<String, dynamic> _$TextItemConfigToJson(
  _TextItemConfig instance,
) => <String, dynamic>{
  'maxLines': instance.maxLines,
  'style': const TextStyleConverter().toJson(instance.style),
  'padding': const EdgeInsetsDirectionalConverter().toJson(instance.padding),
};
