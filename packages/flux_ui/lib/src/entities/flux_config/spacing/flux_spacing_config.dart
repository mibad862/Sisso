import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/converters/json_safe.dart';
import 'flux_edge_insets_config.dart';

export 'flux_edge_insets_config.dart';

part 'flux_spacing_config.freezed.dart';
part 'flux_spacing_config.g.dart';

@freezed
abstract class FluxSpacingConfig with _$FluxSpacingConfig {
  const factory FluxSpacingConfig({
    @JsonKey(name: 'margin', fromJson: _fluxEdgeInsetsConfigFromJson)
    FluxEdgeInsetsConfig? marginConfig,
    @JsonKey(name: 'padding', fromJson: _fluxEdgeInsetsConfigFromJson)
    FluxEdgeInsetsConfig? paddingConfig,
  }) = _FluxSpacingConfig;

  factory FluxSpacingConfig.fromJson(Map<String, dynamic> json) =>
      _$FluxSpacingConfigFromJson(json);

  static FluxSpacingConfig get zero => FluxSpacingConfig(
    marginConfig: FluxEdgeInsetsConfig.zero,
    paddingConfig: FluxEdgeInsetsConfig.zero,
  );
}

FluxEdgeInsetsConfig? _fluxEdgeInsetsConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, FluxEdgeInsetsConfig.fromJson);
}
