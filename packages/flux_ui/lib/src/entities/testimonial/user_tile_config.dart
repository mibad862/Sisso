import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/converters/converters.dart';
import '../flux_config/flux_image_config.dart';
import '../flux_config/text/flux_text_config.dart';
import '../rating_style_config.dart';

part 'user_tile_config.freezed.dart';
part 'user_tile_config.g.dart';

@freezed
abstract class UserTileConfig with _$UserTileConfig {
  const factory UserTileConfig({
    /// The name.
    @JsonKey(fromJson: JsonSafe.stringOrEmpty) @Default('') String name,

    /// The name style configuration.
    @JsonKey(fromJson: _fluxTextStyleConfigFromJson)
    FluxTextStyleConfig? nameStyleConfig,

    /// The subtitle.
    @JsonKey(fromJson: JsonSafe.string) String? subtitle,

    /// The subtitle style configuration.
    @JsonKey(fromJson: _fluxTextStyleConfigFromJson)
    FluxTextStyleConfig? subtitleStyleConfig,

    /// The avatar image URL.
    @JsonKey(fromJson: JsonSafe.string) String? avatarUrl,

    /// The avatar image style configuration.
    @JsonKey(fromJson: _fluxImageStyleConfigFromJson)
    FluxImageStyleConfig? avatarStyleConfig,

    /// The rating value.
    @JsonKey(fromJson: JsonSafe.doubleOrNull) double? rating,

    /// The rating style configuration.
    @JsonKey(fromJson: _fluxRatingStyleConfigFromJson)
    FluxRatingStyleConfig? ratingStyleConfig,

    /// The content padding.
    @EdgeInsetsDirectionalConverter() EdgeInsetsDirectional? contentPadding,
  }) = _UserTileConfig;

  const UserTileConfig._();

  FluxRatingStyleConfig get resolvedRatingStyleConfig =>
      ratingStyleConfig ?? const FluxRatingStyleConfig();

  factory UserTileConfig.fromJson(Map<String, dynamic> json) =>
      _$UserTileConfigFromJson(json);
}

FluxTextStyleConfig? _fluxTextStyleConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, FluxTextStyleConfig.fromJson);
}

FluxImageStyleConfig? _fluxImageStyleConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, FluxImageStyleConfig.fromJson);
}

FluxRatingStyleConfig? _fluxRatingStyleConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, FluxRatingStyleConfig.fromJson);
}
