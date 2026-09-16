import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../flux_ui.dart';

part 'flux_list_view_config.freezed.dart';
part 'flux_list_view_config.g.dart';

const _defaultItemSize = ItemSizeAdvanceConfig(
  value: 2.5,
  type: ItemSizeAdvanceType.gridColumns,
);

const _defaultSpacing = 16.0;

@freezed
abstract class FluxListViewConfig with _$FluxListViewConfig {
  const factory FluxListViewConfig({
    @JsonKey(fromJson: _itemSizeFromJson)
    @Default(_defaultItemSize)
    ItemSizeAdvanceConfig itemSize,
    @JsonKey(fromJson: _itemSpacingFromJson)
    @Default(_defaultSpacing)
    double itemSpacing,
    @EdgeInsetsDirectionalConverter() EdgeInsetsDirectional? padding,
  }) = _FluxListViewConfig;

  factory FluxListViewConfig.fromJson(Map<String, dynamic> json) =>
      _$FluxListViewConfigFromJson(json);
}

ItemSizeAdvanceConfig _itemSizeFromJson(dynamic value) {
  return JsonSafe.parseObject(value, ItemSizeAdvanceConfig.fromJson) ??
      _defaultItemSize;
}

double _itemSpacingFromJson(dynamic value) {
  return JsonSafe.doubleOrNull(value) ?? _defaultSpacing;
}
