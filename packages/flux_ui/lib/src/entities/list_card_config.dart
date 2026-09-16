import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/converters/axis_converter.dart';
import '../core/converters/divider_convert.dart';
import '../core/converters/edge_insets_directional_converter.dart';
import '../core/converters/json_safe.dart';
import 'enums/list_card_style.dart';
import 'item_list_card_config.dart';

part 'list_card_config.freezed.dart';
part 'list_card_config.g.dart';

@freezed
abstract class ListCardConfig with _$ListCardConfig {
  const factory ListCardConfig({
    // Height for content, image and action
    @JsonKey(fromJson: JsonSafe.doubleOrNull) double? heightContent,
    @JsonKey(fromJson: JsonSafe.doubleOrNull) double? heightImage,
    @JsonKey(fromJson: JsonSafe.doubleOrNull) double? heightAction,

    // Config for title and subtitle
    @JsonKey(fromJson: _textItemConfigFromJson) TextItemConfig? titleTextConfig,
    @JsonKey(fromJson: _textItemConfigFromJson)
    TextItemConfig? subtitleTextConfig,

    // action config
    @JsonKey(fromJson: _styleItemCardConfigFromJson)
    StyleItemCardConfig? actionBoxStyle,
    @JsonKey(fromJson: _textItemConfigFromJson)
    TextItemConfig? actionTextConfig,

    // tag config
    @JsonKey(fromJson: _styleItemCardConfigFromJson)
    StyleItemCardConfig? tagBoxStyle,
    @JsonKey(fromJson: _textItemConfigFromJson) TextItemConfig? tagTextConfig,

    // widget config
    @JsonKey(fromJson: _styleItemCardConfigFromJson)
    StyleItemCardConfig? cardBoxStyle,
    @JsonKey(fromJson: _itemListCardConfigsFromJson)
    List<ItemListCardConfig>? items,
    @AxisConverter() Axis? axis,

    /// only support border, border radius, margin and padding
    @JsonKey(fromJson: _styleItemCardConfigFromJson)
    StyleItemCardConfig? imageBoxStyle,

    // Padding for content
    @EdgeInsetsDirectionalConverter() EdgeInsetsDirectional? contentPadding,
    // Padding for card
    @EdgeInsetsDirectionalConverter() EdgeInsetsDirectional? padding,

    // Style for list card
    @JsonKey(unknownEnumValue: ListCardStyle.titleHeading)
    @Default(ListCardStyle.titleHeading)
    ListCardStyle style,

    /// Number of item in line. Only support for horizontal
    /// Min 1, Max 3
    @JsonKey(fromJson: JsonSafe.doubleOrNull) double? itemInLine,

    ///  Spacing for item
    @JsonKey(fromJson: JsonSafe.doubleOrNull) double? itemSpacing,
    @DividerConverter() Divider? divider,
  }) = _ListCardConfig;

  factory ListCardConfig.fromJson(Map<String, dynamic> json) =>
      _$ListCardConfigFromJson(json);
}

TextItemConfig? _textItemConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, TextItemConfig.fromJson);
}

StyleItemCardConfig? _styleItemCardConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, StyleItemCardConfig.fromJson);
}

List<ItemListCardConfig>? _itemListCardConfigsFromJson(dynamic value) {
  final list = JsonSafe.parseList(value, ItemListCardConfig.fromJson);
  return list.isEmpty && JsonSafe.list(value) == null ? null : list;
}
