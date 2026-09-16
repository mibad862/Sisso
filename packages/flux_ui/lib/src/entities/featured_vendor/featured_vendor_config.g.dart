// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'featured_vendor_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeaturedVendorConfig _$FeaturedVendorConfigFromJson(
  Map<String, dynamic> json,
) => _FeaturedVendorConfig(
  name: JsonSafe.string(json['name']),
  columnCount: json['columnCount'] == null
      ? 3
      : _columnCountFromJson(json['columnCount']),
  showRating: json['showRating'] == null
      ? true
      : JsonSafe.boolOrTrue(json['showRating']),
  enableAutoSliding: json['enableAutoSliding'] == null
      ? false
      : JsonSafe.boolOrFalse(json['enableAutoSliding']),
  durationAutoSliding: JsonSafe.intOrNull(json['durationAutoSliding']),
  enableBackground: json['enableBackground'] == null
      ? false
      : JsonSafe.boolOrFalse(json['enableBackground']),
  isSnapping: json['isSnapping'] == null
      ? false
      : JsonSafe.boolOrFalse(json['isSnapping']),
  limit: JsonSafe.intOrNull(json['limit']),
  imageBoxfit: json['imageBoxfit'] == null
      ? 'cover'
      : _imageBoxfitFromJson(json['imageBoxfit']),
  alignment: json['alignment'] == null
      ? 'centerStart'
      : _alignmentFromJson(json['alignment']),
);

Map<String, dynamic> _$FeaturedVendorConfigToJson(
  _FeaturedVendorConfig instance,
) => <String, dynamic>{
  'name': instance.name,
  'columnCount': instance.columnCount,
  'showRating': instance.showRating,
  'enableAutoSliding': instance.enableAutoSliding,
  'durationAutoSliding': instance.durationAutoSliding,
  'enableBackground': instance.enableBackground,
  'isSnapping': instance.isSnapping,
  'limit': instance.limit,
  'imageBoxfit': instance.imageBoxfit,
  'alignment': instance.alignment,
};
