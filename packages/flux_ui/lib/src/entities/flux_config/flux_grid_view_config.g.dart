// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flux_grid_view_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FluxGridViewConfig _$FluxGridViewConfigFromJson(Map<String, dynamic> json) =>
    _FluxGridViewConfig(
      crossAxisCount: json['crossAxisCount'] == null
          ? _defaultCrossAxisCount
          : _crossAxisCountFromJson(json['crossAxisCount']),
      crossAxisSpacing: json['crossAxisSpacing'] == null
          ? _defaultCrossAxisSpacing
          : _crossAxisSpacingFromJson(json['crossAxisSpacing']),
      mainAxisSpacing: json['mainAxisSpacing'] == null
          ? _defaultMainAxisSpacing
          : _mainAxisSpacingFromJson(json['mainAxisSpacing']),
      childAspectRatio: json['childAspectRatio'] == null
          ? _defaultChildAspectRatio
          : _childAspectRatioFromJson(json['childAspectRatio']),
      padding: const EdgeInsetsDirectionalConverter().fromJson(json['padding']),
    );

Map<String, dynamic> _$FluxGridViewConfigToJson(
  _FluxGridViewConfig instance,
) => <String, dynamic>{
  'crossAxisCount': instance.crossAxisCount,
  'crossAxisSpacing': instance.crossAxisSpacing,
  'mainAxisSpacing': instance.mainAxisSpacing,
  'childAspectRatio': instance.childAspectRatio,
  'padding': const EdgeInsetsDirectionalConverter().toJson(instance.padding),
};
