import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/converters/edge_insets_directional_converter.dart';
import '../core/converters/json_safe.dart';
import 'image_config.dart';
import 'item_size_advance_config.dart';

part 'product_list_config.freezed.dart';
part 'product_list_config.g.dart';

const _defaultItemSpacing = 16.0;
const _defaultItemSizeConfig = ItemSizeAdvanceConfig(
  value: 2,
  type: ItemSizeAdvanceType.gridColumns,
);
const _defaultPadding = EdgeInsetsDirectional.all(16);

@freezed
abstract class ProductListConfig with _$ProductListConfig {
  const factory ProductListConfig({
    @JsonKey(fromJson: _productItemSpacingFromJson)
    @Default(_defaultItemSpacing)
    double itemSpacing,
    @JsonKey(fromJson: _productItemSizeConfigFromJson)
    @Default(_defaultItemSizeConfig)
    ItemSizeAdvanceConfig itemSizeConfig,
    @EdgeInsetsDirectionalConverter()
    @Default(_defaultPadding)
    EdgeInsetsDirectional? padding,
    @JsonKey(fromJson: _productImageConfigFromJson)
    @Default(ImageConfig())
    ImageConfig imageConfig,
  }) = _ProductListConfig;

  factory ProductListConfig.fromJson(Map<String, dynamic> json) =>
      _$ProductListConfigFromJson(json);
}

ItemSizeAdvanceConfig _productItemSizeConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, ItemSizeAdvanceConfig.fromJson) ??
      _defaultItemSizeConfig;
}

double _productItemSpacingFromJson(dynamic value) {
  return JsonSafe.doubleOrNull(value) ?? _defaultItemSpacing;
}

ImageConfig _productImageConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, ImageConfig.fromJson) ??
      const ImageConfig();
}
