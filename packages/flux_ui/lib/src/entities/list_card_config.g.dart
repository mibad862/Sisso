// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_card_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListCardConfig _$ListCardConfigFromJson(Map<String, dynamic> json) =>
    _ListCardConfig(
      heightContent: JsonSafe.doubleOrNull(json['heightContent']),
      heightImage: JsonSafe.doubleOrNull(json['heightImage']),
      heightAction: JsonSafe.doubleOrNull(json['heightAction']),
      titleTextConfig: _textItemConfigFromJson(json['titleTextConfig']),
      subtitleTextConfig: _textItemConfigFromJson(json['subtitleTextConfig']),
      actionBoxStyle: _styleItemCardConfigFromJson(json['actionBoxStyle']),
      actionTextConfig: _textItemConfigFromJson(json['actionTextConfig']),
      tagBoxStyle: _styleItemCardConfigFromJson(json['tagBoxStyle']),
      tagTextConfig: _textItemConfigFromJson(json['tagTextConfig']),
      cardBoxStyle: _styleItemCardConfigFromJson(json['cardBoxStyle']),
      items: _itemListCardConfigsFromJson(json['items']),
      axis: const AxisConverter().fromJson(json['axis']),
      imageBoxStyle: _styleItemCardConfigFromJson(json['imageBoxStyle']),
      contentPadding: const EdgeInsetsDirectionalConverter().fromJson(
        json['contentPadding'],
      ),
      padding: const EdgeInsetsDirectionalConverter().fromJson(json['padding']),
      style:
          $enumDecodeNullable(
            _$ListCardStyleEnumMap,
            json['style'],
            unknownValue: ListCardStyle.titleHeading,
          ) ??
          ListCardStyle.titleHeading,
      itemInLine: JsonSafe.doubleOrNull(json['itemInLine']),
      itemSpacing: JsonSafe.doubleOrNull(json['itemSpacing']),
      divider: const DividerConverter().fromJson(json['divider']),
    );

Map<String, dynamic> _$ListCardConfigToJson(
  _ListCardConfig instance,
) => <String, dynamic>{
  'heightContent': instance.heightContent,
  'heightImage': instance.heightImage,
  'heightAction': instance.heightAction,
  'titleTextConfig': instance.titleTextConfig?.toJson(),
  'subtitleTextConfig': instance.subtitleTextConfig?.toJson(),
  'actionBoxStyle': instance.actionBoxStyle?.toJson(),
  'actionTextConfig': instance.actionTextConfig?.toJson(),
  'tagBoxStyle': instance.tagBoxStyle?.toJson(),
  'tagTextConfig': instance.tagTextConfig?.toJson(),
  'cardBoxStyle': instance.cardBoxStyle?.toJson(),
  'items': instance.items?.map((e) => e.toJson()).toList(),
  'axis': _$JsonConverterToJson<dynamic, Axis>(
    instance.axis,
    const AxisConverter().toJson,
  ),
  'imageBoxStyle': instance.imageBoxStyle?.toJson(),
  'contentPadding': const EdgeInsetsDirectionalConverter().toJson(
    instance.contentPadding,
  ),
  'padding': const EdgeInsetsDirectionalConverter().toJson(instance.padding),
  'style': _$ListCardStyleEnumMap[instance.style]!,
  'itemInLine': instance.itemInLine,
  'itemSpacing': instance.itemSpacing,
  'divider': const DividerConverter().toJson(instance.divider),
};

const _$ListCardStyleEnumMap = {
  ListCardStyle.subtitleHeading: 'subtitleHeading',
  ListCardStyle.titleHeading: 'titleHeading',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
