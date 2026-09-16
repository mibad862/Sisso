import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/converters/datetime_converter.dart';
import '../../core/converters/edge_insets_directional_converter.dart';
import '../../core/converters/json_safe.dart';

part 'header_view_config.freezed.dart';
part 'header_view_config.g.dart';

@freezed
abstract class HeaderViewConfig with _$HeaderViewConfig {
  const factory HeaderViewConfig({
    @EdgeInsetsDirectionalConverter() EdgeInsetsDirectional? margin,
    @EdgeInsetsDirectionalConverter() EdgeInsetsDirectional? padding,
    @JsonKey(fromJson: JsonSafe.stringOrEmpty) required String title,
    @JsonKey(fromJson: JsonSafe.string) String? actionTitle,
    @JsonKey(fromJson: JsonSafe.action) Map<String, dynamic>? action,
    @DateTimeConverter() DateTime? datetimeCountdown,
  }) = _HeaderViewConfig;

  factory HeaderViewConfig.fromJson(Map<String, dynamic> json) =>
      _$HeaderViewConfigFromJson(json);
}
