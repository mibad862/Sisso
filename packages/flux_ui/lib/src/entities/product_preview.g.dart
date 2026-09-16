// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductPreview _$ProductPreviewFromJson(Map<String, dynamic> json) =>
    _ProductPreview(
      title: JsonSafe.stringOrEmpty(json['title']),
      textPrice: JsonSafe.stringOrEmpty(json['textPrice']),
      imageUrl: JsonSafe.stringOrEmpty(json['imageUrl']),
      textDiscountedPrice: JsonSafe.string(json['textDiscountedPrice']),
      discountPercentage: JsonSafe.doubleOrNull(json['discountPercentage']),
      isFavorite: json['isFavorite'] == null
          ? false
          : JsonSafe.boolOrFalse(json['isFavorite']),
      colorVariants: const ListColorConverter().fromJson(json['colorVariants']),
    );

Map<String, dynamic> _$ProductPreviewToJson(
  _ProductPreview instance,
) => <String, dynamic>{
  'title': instance.title,
  'textPrice': instance.textPrice,
  'imageUrl': instance.imageUrl,
  'textDiscountedPrice': instance.textDiscountedPrice,
  'discountPercentage': instance.discountPercentage,
  'isFavorite': instance.isFavorite,
  'colorVariants': const ListColorConverter().toJson(instance.colorVariants),
};
