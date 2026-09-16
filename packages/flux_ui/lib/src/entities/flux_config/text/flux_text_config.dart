import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/converters/json_safe.dart';
import '../../app/app_text_style.dart';
import '../flux_container_config.dart';
import 'text_style_source.dart';

part 'flux_text_config.freezed.dart';
part 'flux_text_config.g.dart';

@freezed
abstract class FluxTextConfig with _$FluxTextConfig {
  const factory FluxTextConfig({
    @JsonKey(fromJson: JsonSafe.stringOrEmpty) @Default('') String text,
    @JsonKey(fromJson: _fluxTextStyleConfigFromJson)
    FluxTextStyleConfig? styleConfig,
  }) = _FluxTextConfig;

  factory FluxTextConfig.fromJson(Map<String, dynamic> json) =>
      _$FluxTextConfigFromJson(json);
}

FluxTextStyleConfig? _fluxTextStyleConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, FluxTextStyleConfig.fromJson);
}

@freezed
abstract class FluxTextStyleConfig with _$FluxTextStyleConfig {
  const factory FluxTextStyleConfig({
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    TextStyleSource? styleSource,
    @JsonKey(fromJson: _appTextStyleFromJson) AppTextStyle? customStyle,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    TextOverflow? textOverflow,
    @JsonKey(fromJson: JsonSafe.intOrNull) int? maxLines,
    @JsonKey(fromJson: JsonSafe.intOrNull) int? minLines,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    TextAlign? textAlign,
    @JsonKey(fromJson: _fluxContainerConfigFromJson)
    FluxContainerConfig? containerConfig,
  }) = _FluxTextStyleConfig;

  factory FluxTextStyleConfig.fromJson(Map<String, dynamic> json) =>
      _$FluxTextStyleConfigFromJson(json);
}

AppTextStyle? _appTextStyleFromJson(dynamic value) {
  return JsonSafe.parseObject(value, AppTextStyle.fromJson);
}

FluxContainerConfig? _fluxContainerConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, FluxContainerConfig.fromJson);
}
