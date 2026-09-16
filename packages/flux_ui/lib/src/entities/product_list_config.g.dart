// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_list_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductListConfig _$ProductListConfigFromJson(Map<String, dynamic> json) =>
    _ProductListConfig(
      itemSpacing: json['itemSpacing'] == null
          ? _defaultItemSpacing
          : _productItemSpacingFromJson(json['itemSpacing']),
      itemSizeConfig: json['itemSizeConfig'] == null
          ? _defaultItemSizeConfig
          : _productItemSizeConfigFromJson(json['itemSizeConfig']),
      padding: json['padding'] == null
          ? _defaultPadding
          : const EdgeInsetsDirectionalConverter().fromJson(json['padding']),
      imageConfig: json['imageConfig'] == null
          ? const ImageConfig()
          : _productImageConfigFromJson(json['imageConfig']),
    );

Map<String, dynamic> _$ProductListConfigToJson(
  _ProductListConfig instance,
) => <String, dynamic>{
  'itemSpacing': instance.itemSpacing,
  'itemSizeConfig': instance.itemSizeConfig.toJson(),
  'padding': const EdgeInsetsDirectionalConverter().toJson(instance.padding),
  'imageConfig': instance.imageConfig.toJson(),
};
