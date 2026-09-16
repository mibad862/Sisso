import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/converters/converters.dart';

part 'item_list_card_config.freezed.dart';
part 'item_list_card_config.g.dart';

@freezed
abstract class ItemListCardConfig with _$ItemListCardConfig {
  const factory ItemListCardConfig({
    @StringConverter() required String title,
    @JsonKey(fromJson: JsonSafe.string) required String? subtitle,
    @StringConverter() required String imageUrl,
    @JsonKey(fromJson: _actionItemCardConfigFromJson)
    ActionItemCardConfig? action,
    @JsonKey(fromJson: JsonSafe.stringList) List<String>? tags,
  }) = _ItemListCardConfig;

  factory ItemListCardConfig.fromJson(Map<String, dynamic> json) =>
      _$ItemListCardConfigFromJson(json);
}

ActionItemCardConfig? _actionItemCardConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, ActionItemCardConfig.fromJson);
}

@freezed
abstract class ActionItemCardConfig with _$ActionItemCardConfig {
  const factory ActionItemCardConfig({
    @JsonKey(fromJson: JsonSafe.string) String? title,
    @JsonKey(fromJson: JsonSafe.mapOrEmpty)
    required Map<String, dynamic> action,
    @AlignmentDirectionalConverter() AlignmentDirectional? alignment,
  }) = _ActionItemCardConfig;

  factory ActionItemCardConfig.fromJson(Map<String, dynamic> json) =>
      _$ActionItemCardConfigFromJson(json);
}

@freezed
abstract class StyleItemCardConfig with _$StyleItemCardConfig {
  const factory StyleItemCardConfig({
    @DecorationConverter() BoxDecoration? decoration,
    @EdgeInsetsDirectionalConverter() EdgeInsetsDirectional? padding,
    @EdgeInsetsDirectionalConverter() EdgeInsetsDirectional? margin,
  }) = _StyleItemCardConfig;

  factory StyleItemCardConfig.fromJson(Map<String, dynamic> json) =>
      _$StyleItemCardConfigFromJson(json);
}

@freezed
abstract class TextItemConfig with _$TextItemConfig {
  const factory TextItemConfig({
    @JsonKey(fromJson: JsonSafe.intOrNull) int? maxLines,
    @TextStyleConverter() TextStyle? style,
    @EdgeInsetsDirectionalConverter() EdgeInsetsDirectional? padding,
  }) = _TextItemConfig;

  factory TextItemConfig.fromJson(Map<String, dynamic> json) =>
      _$TextItemConfigFromJson(json);
}
