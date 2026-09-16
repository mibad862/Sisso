import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/converters/json_safe.dart';

part 'card_grid_item_config.freezed.dart';
part 'card_grid_item_config.g.dart';

@freezed
abstract class CardGridItemConfig with _$CardGridItemConfig {
  const factory CardGridItemConfig({
    @JsonKey(fromJson: JsonSafe.string) String? id,
    @JsonKey(fromJson: JsonSafe.stringOrEmpty) required String name,
    @JsonKey(fromJson: JsonSafe.stringOrEmpty) required String imageUrl,
  }) = _CardGridItemConfig;

  factory CardGridItemConfig.fromJson(Map<String, dynamic> json) =>
      _$CardGridItemConfigFromJson(json);
}
