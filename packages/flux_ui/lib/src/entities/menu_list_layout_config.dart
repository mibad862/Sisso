import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/converters/converters.dart';
import 'menu_list_item_config.dart';

part 'menu_list_layout_config.freezed.dart';
part 'menu_list_layout_config.g.dart';

@freezed
abstract class MenuListLayoutConfig with _$MenuListLayoutConfig {
  const factory MenuListLayoutConfig({
    @JsonKey(fromJson: _menuListItemsFromJson)
    required List<MenuListItemConfig> items,
    @JsonKey(fromJson: _menuItemSpacingFromJson) @Default(8) double itemSpacing,
    @JsonKey(fromJson: JsonSafe.doubleOrNull) double? itemHeight,
    @EdgeInsetsDirectionalConverter() EdgeInsetsDirectional? padding,
    @JsonKey(fromJson: _menuListItemStyleFromJson)
    @Default(MenuListItemStyle())
    MenuListItemStyle style,
  }) = _MenuListLayoutConfig;

  const MenuListLayoutConfig._();

  factory MenuListLayoutConfig.fromJson(Map<String, dynamic> json) =>
      _$MenuListLayoutConfigFromJson(json);

  MenuListItemStyle get resolvedStyle {
    if (itemHeight == null) {
      return style.copyWith(
        imageStyleConfig: style.imageStyleConfig?.copyWith(aspectRatio: null),
      );
    }
    return style;
  }

  List<MenuListItemConfig> get resolvedItems => items.map((e) {
    final style = e.style;
    if (style == null) {
      return e.copyWith(style: resolvedStyle);
    }
    if (itemHeight == null) {
      return e.copyWith(
        style: style.copyWith(
          imageStyleConfig: style.imageStyleConfig?.copyWith(aspectRatio: null),
        ),
      );
    }
    return e;
  }).toList();
}

List<MenuListItemConfig> _menuListItemsFromJson(dynamic value) {
  return JsonSafe.parseList(value, MenuListItemConfig.fromJson);
}

double _menuItemSpacingFromJson(dynamic value) {
  return JsonSafe.doubleOrNull(value) ?? 8;
}

MenuListItemStyle _menuListItemStyleFromJson(dynamic value) {
  return JsonSafe.parseObject(value, MenuListItemStyle.fromJson) ??
      const MenuListItemStyle();
}
