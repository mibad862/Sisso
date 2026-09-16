import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/converters/json_safe.dart';
import 'card_grid_item_config.dart';
import 'flux_config/flux_grid_view_config.dart';

part 'card_grid_layout_config.freezed.dart';
part 'card_grid_layout_config.g.dart';

@freezed
abstract class CardGridLayoutConfig with _$CardGridLayoutConfig {
  const factory CardGridLayoutConfig({
    @JsonKey(fromJson: _gridConfigFromJson)
    @Default(FluxGridViewConfig())
    FluxGridViewConfig gridConfig,
    @JsonKey(fromJson: _cardGridItemsFromJson)
    required List<CardGridItemConfig> items,
    @JsonKey(fromJson: JsonSafe.doubleOrZero) @Default(0) double borderRadius,
  }) = _CardGridLayoutConfig;

  factory CardGridLayoutConfig.fromJson(Map<String, dynamic> json) =>
      _$CardGridLayoutConfigFromJson(json);
}

FluxGridViewConfig _gridConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, FluxGridViewConfig.fromJson) ??
      const FluxGridViewConfig();
}

List<CardGridItemConfig> _cardGridItemsFromJson(dynamic value) {
  return JsonSafe.parseList(value, CardGridItemConfig.fromJson);
}
