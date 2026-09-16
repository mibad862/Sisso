// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_list_layout_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MenuListLayoutConfig _$MenuListLayoutConfigFromJson(
  Map<String, dynamic> json,
) => _MenuListLayoutConfig(
  items: _menuListItemsFromJson(json['items']),
  itemSpacing: json['itemSpacing'] == null
      ? 8
      : _menuItemSpacingFromJson(json['itemSpacing']),
  itemHeight: JsonSafe.doubleOrNull(json['itemHeight']),
  padding: const EdgeInsetsDirectionalConverter().fromJson(json['padding']),
  style: json['style'] == null
      ? const MenuListItemStyle()
      : _menuListItemStyleFromJson(json['style']),
);

Map<String, dynamic> _$MenuListLayoutConfigToJson(
  _MenuListLayoutConfig instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'itemSpacing': instance.itemSpacing,
  'itemHeight': instance.itemHeight,
  'padding': const EdgeInsetsDirectionalConverter().toJson(instance.padding),
  'style': instance.style.toJson(),
};
