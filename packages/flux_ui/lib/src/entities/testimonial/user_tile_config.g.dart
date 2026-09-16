// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_tile_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserTileConfig _$UserTileConfigFromJson(
  Map<String, dynamic> json,
) => _UserTileConfig(
  name: json['name'] == null ? '' : JsonSafe.stringOrEmpty(json['name']),
  nameStyleConfig: _fluxTextStyleConfigFromJson(json['nameStyleConfig']),
  subtitle: JsonSafe.string(json['subtitle']),
  subtitleStyleConfig: _fluxTextStyleConfigFromJson(
    json['subtitleStyleConfig'],
  ),
  avatarUrl: JsonSafe.string(json['avatarUrl']),
  avatarStyleConfig: _fluxImageStyleConfigFromJson(json['avatarStyleConfig']),
  rating: JsonSafe.doubleOrNull(json['rating']),
  ratingStyleConfig: _fluxRatingStyleConfigFromJson(json['ratingStyleConfig']),
  contentPadding: const EdgeInsetsDirectionalConverter().fromJson(
    json['contentPadding'],
  ),
);

Map<String, dynamic> _$UserTileConfigToJson(_UserTileConfig instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameStyleConfig': instance.nameStyleConfig?.toJson(),
      'subtitle': instance.subtitle,
      'subtitleStyleConfig': instance.subtitleStyleConfig?.toJson(),
      'avatarUrl': instance.avatarUrl,
      'avatarStyleConfig': instance.avatarStyleConfig?.toJson(),
      'rating': instance.rating,
      'ratingStyleConfig': instance.ratingStyleConfig?.toJson(),
      'contentPadding': const EdgeInsetsDirectionalConverter().toJson(
        instance.contentPadding,
      ),
    };
