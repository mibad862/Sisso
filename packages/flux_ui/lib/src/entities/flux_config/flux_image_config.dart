import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/core.dart';

part 'flux_image_config.freezed.dart';
part 'flux_image_config.g.dart';

@freezed
abstract class FluxImageConfig with _$FluxImageConfig {
  const factory FluxImageConfig({
    @JsonKey(fromJson: JsonSafe.stringOrEmpty) @Default('') String url,
    @JsonKey(fromJson: _fluxImageStyleConfigFromJson)
    FluxImageStyleConfig? styleConfig,
  }) = _FluxImageConfig;

  factory FluxImageConfig.fromJson(Map<String, dynamic> json) =>
      _$FluxImageConfigFromJson(json);
}

FluxImageStyleConfig? _fluxImageStyleConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, FluxImageStyleConfig.fromJson);
}

@freezed
abstract class FluxImageStyleConfig with _$FluxImageStyleConfig {
  const factory FluxImageStyleConfig({
    @JsonKey(fromJson: JsonSafe.doubleOrNull) double? width,
    @JsonKey(fromJson: JsonSafe.doubleOrNull) double? height,
    @JsonKey(fromJson: JsonSafe.doubleOrNull) double? aspectRatio,
    @BorderRadiusDirectionalConverter() BorderRadiusDirectional? borderRadius,
    @BoxFitConverter() BoxFit? fit,
    @ColorConverter() Color? color,
    @AlignmentDirectionalConverter() AlignmentDirectional? alignment,
  }) = _FluxImageStyleConfig;

  const FluxImageStyleConfig._();

  factory FluxImageStyleConfig.fromJson(Map<String, dynamic> json) =>
      _$FluxImageStyleConfigFromJson(json);

  double? get resolvedWidth => aspectRatio != null ? null : width;

  double? get resolvedHeight => aspectRatio != null ? null : height;
}
