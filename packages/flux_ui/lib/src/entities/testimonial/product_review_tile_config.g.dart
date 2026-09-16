// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_review_tile_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TestimonialStyle _$TestimonialStyleFromJson(Map<String, dynamic> json) =>
    _TestimonialStyle(
      cardConfig: json['cardConfig'] == null
          ? const FluxCardConfig()
          : _fluxCardConfigFromJson(json['cardConfig']),
      spacing: json['spacing'] == null
          ? 8.0
          : _testimonialSpacingFromJson(json['spacing']),
      elementOrder: json['elementOrder'] == null
          ? ProductReviewTileElement.defaultOrder
          : _productReviewTileElementsFromJson(json['elementOrder']),
      userNameStyleConfig: _fluxTextStyleConfigFromJson(
        json['userNameStyleConfig'],
      ),
      reviewTextStyleConfig: _fluxTextStyleConfigFromJson(
        json['reviewTextStyleConfig'],
      ),
      imageStyleConfig: _fluxImageStyleConfigFromJson(json['imageStyleConfig']),
      avatarStyleConfig: _fluxImageStyleConfigFromJson(
        json['avatarStyleConfig'],
      ),
      ratingStyleConfig: json['ratingStyleConfig'] == null
          ? const FluxRatingStyleConfig()
          : _fluxRatingStyleConfigFromJson(json['ratingStyleConfig']),
    );

Map<String, dynamic> _$TestimonialStyleToJson(_TestimonialStyle instance) =>
    <String, dynamic>{
      'cardConfig': instance.cardConfig.toJson(),
      'spacing': instance.spacing,
      'elementOrder': instance.elementOrder
          .map((e) => _$ProductReviewTileElementEnumMap[e]!)
          .toList(),
      'userNameStyleConfig': instance.userNameStyleConfig?.toJson(),
      'reviewTextStyleConfig': instance.reviewTextStyleConfig?.toJson(),
      'imageStyleConfig': instance.imageStyleConfig?.toJson(),
      'avatarStyleConfig': instance.avatarStyleConfig?.toJson(),
      'ratingStyleConfig': instance.ratingStyleConfig.toJson(),
    };

const _$ProductReviewTileElementEnumMap = {
  ProductReviewTileElement.userTile: 'userTile',
  ProductReviewTileElement.image: 'image',
  ProductReviewTileElement.reviewText: 'reviewText',
};

_ProductReviewTileConfig _$ProductReviewTileConfigFromJson(
  Map<String, dynamic> json,
) => _ProductReviewTileConfig(
  id: JsonSafe.string(json['id']),
  imageUrl: JsonSafe.string(json['imageUrl']),
  reviewText: JsonSafe.string(json['reviewText']),
  userTile: _userTileConfigFromJson(json['userTile']),
  style: _testimonialStyleNullableFromJson(json['style']),
);

Map<String, dynamic> _$ProductReviewTileConfigToJson(
  _ProductReviewTileConfig instance,
) => <String, dynamic>{
  'id': instance.id,
  'imageUrl': instance.imageUrl,
  'reviewText': instance.reviewText,
  'userTile': instance.userTile?.toJson(),
  'style': instance.style?.toJson(),
};
