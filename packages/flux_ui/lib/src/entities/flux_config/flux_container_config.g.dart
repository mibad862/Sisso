// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flux_container_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FluxContainerConfig _$FluxContainerConfigFromJson(Map<String, dynamic> json) =>
    _FluxContainerConfig(
      width: JsonSafe.doubleOrNull(json['width']),
      height: JsonSafe.doubleOrNull(json['height']),
      padding: const EdgeInsetsDirectionalConverter().fromJson(json['padding']),
      margin: const EdgeInsetsDirectionalConverter().fromJson(json['margin']),
      decoration: const DecorationConverter().fromJson(json['decoration']),
      alignment: const AlignmentDirectionalConverter().fromJson(
        json['alignment'],
      ),
      constraints: const ConstraintsConverter().fromJson(json['constraints']),
      clipBehavior:
          $enumDecodeNullable(
            _$ClipEnumMap,
            json['clipBehavior'],
            unknownValue: Clip.none,
          ) ??
          Clip.none,
    );

Map<String, dynamic> _$FluxContainerConfigToJson(
  _FluxContainerConfig instance,
) => <String, dynamic>{
  'width': instance.width,
  'height': instance.height,
  'padding': const EdgeInsetsDirectionalConverter().toJson(instance.padding),
  'margin': const EdgeInsetsDirectionalConverter().toJson(instance.margin),
  'decoration': const DecorationConverter().toJson(instance.decoration),
  'alignment': const AlignmentDirectionalConverter().toJson(instance.alignment),
  'constraints': const ConstraintsConverter().toJson(instance.constraints),
  'clipBehavior': _$ClipEnumMap[instance.clipBehavior]!,
};

const _$ClipEnumMap = {
  Clip.none: 'none',
  Clip.hardEdge: 'hardEdge',
  Clip.antiAlias: 'antiAlias',
  Clip.antiAliasWithSaveLayer: 'antiAliasWithSaveLayer',
};
