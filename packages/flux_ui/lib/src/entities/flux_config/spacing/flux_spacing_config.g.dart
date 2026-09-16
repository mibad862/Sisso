// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flux_spacing_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FluxSpacingConfig _$FluxSpacingConfigFromJson(Map<String, dynamic> json) =>
    _FluxSpacingConfig(
      marginConfig: _fluxEdgeInsetsConfigFromJson(json['margin']),
      paddingConfig: _fluxEdgeInsetsConfigFromJson(json['padding']),
    );

Map<String, dynamic> _$FluxSpacingConfigToJson(_FluxSpacingConfig instance) =>
    <String, dynamic>{
      'margin': instance.marginConfig?.toJson(),
      'padding': instance.paddingConfig?.toJson(),
    };
