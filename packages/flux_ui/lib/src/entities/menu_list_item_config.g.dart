// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_list_item_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MenuListItemStyle _$MenuListItemStyleFromJson(Map<String, dynamic> json) =>
    _MenuListItemStyle(
      cardConfig: json['cardConfig'] == null
          ? const FluxCardConfig()
          : _fluxCardConfigFromJson(json['cardConfig']),
      imageStyleConfig: _fluxImageStyleConfigFromJson(json['imageStyleConfig']),
      titleStyleConfig: _fluxTextStyleConfigFromJson(json['titleStyleConfig']),
    );

Map<String, dynamic> _$MenuListItemStyleToJson(_MenuListItemStyle instance) =>
    <String, dynamic>{
      'cardConfig': instance.cardConfig.toJson(),
      'imageStyleConfig': instance.imageStyleConfig?.toJson(),
      'titleStyleConfig': instance.titleStyleConfig?.toJson(),
    };

_MenuListItemConfig _$MenuListItemConfigFromJson(Map<String, dynamic> json) =>
    _MenuListItemConfig(
      title: json['title'] == null ? '' : JsonSafe.stringOrEmpty(json['title']),
      imageUrl: JsonSafe.string(json['imageUrl']),
      style: _menuListItemStyleNullableFromJson(json['style']),
      action: JsonSafe.action(json['action']),
    );

Map<String, dynamic> _$MenuListItemConfigToJson(_MenuListItemConfig instance) =>
    <String, dynamic>{
      'title': instance.title,
      'imageUrl': instance.imageUrl,
      'style': instance.style?.toJson(),
      'action': instance.action,
    };
