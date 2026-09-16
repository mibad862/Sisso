import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/converters/json_safe.dart';
import '../flux_config/flux_card_config.dart';
import '../flux_config/flux_image_config.dart';
import '../flux_config/text/flux_text_config.dart';
import '../rating_style_config.dart';
import 'user_tile_config.dart';

part 'product_review_tile_config.freezed.dart';
part 'product_review_tile_config.g.dart';

enum ProductReviewTileElement {
  userTile,
  image,
  reviewText;

  static const List<ProductReviewTileElement> defaultOrder = [
    image,
    reviewText,
    userTile,
  ];
}

@freezed
abstract class TestimonialStyle with _$TestimonialStyle {
  const TestimonialStyle._();

  const factory TestimonialStyle({
    @JsonKey(fromJson: _fluxCardConfigFromJson)
    @Default(FluxCardConfig())
    FluxCardConfig cardConfig,
    @JsonKey(fromJson: _testimonialSpacingFromJson)
    @Default(8.0)
    double spacing,
    @JsonKey(fromJson: _productReviewTileElementsFromJson)
    @Default(ProductReviewTileElement.defaultOrder)
    List<ProductReviewTileElement> elementOrder,
    @JsonKey(fromJson: _fluxTextStyleConfigFromJson)
    FluxTextStyleConfig? userNameStyleConfig,
    @JsonKey(fromJson: _fluxTextStyleConfigFromJson)
    FluxTextStyleConfig? reviewTextStyleConfig,
    @JsonKey(fromJson: _fluxImageStyleConfigFromJson)
    FluxImageStyleConfig? imageStyleConfig,
    @JsonKey(fromJson: _fluxImageStyleConfigFromJson)
    FluxImageStyleConfig? avatarStyleConfig,
    @JsonKey(fromJson: _fluxRatingStyleConfigFromJson)
    @Default(FluxRatingStyleConfig())
    FluxRatingStyleConfig ratingStyleConfig,
  }) = _TestimonialStyle;

  factory TestimonialStyle.fromJson(Map<String, dynamic> json) =>
      _$TestimonialStyleFromJson(json);
}

FluxCardConfig _fluxCardConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, FluxCardConfig.fromJson) ??
      const FluxCardConfig();
}

double _testimonialSpacingFromJson(dynamic value) {
  return JsonSafe.doubleOrNull(value) ?? 8.0;
}

List<ProductReviewTileElement> _productReviewTileElementsFromJson(
  dynamic value,
) {
  final list = JsonSafe.list(value);
  if (list == null) return ProductReviewTileElement.defaultOrder;

  final parsed = list
      .map(_productReviewTileElementFromJson)
      .whereType<ProductReviewTileElement>()
      .toList();

  return parsed.isEmpty ? ProductReviewTileElement.defaultOrder : parsed;
}

ProductReviewTileElement? _productReviewTileElementFromJson(dynamic value) {
  final name = JsonSafe.string(value);
  if (name == null) return null;

  for (final element in ProductReviewTileElement.values) {
    if (element.name == name) return element;
  }

  return null;
}

FluxTextStyleConfig? _fluxTextStyleConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, FluxTextStyleConfig.fromJson);
}

FluxImageStyleConfig? _fluxImageStyleConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, FluxImageStyleConfig.fromJson);
}

FluxRatingStyleConfig _fluxRatingStyleConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, FluxRatingStyleConfig.fromJson) ??
      const FluxRatingStyleConfig();
}

@freezed
abstract class ProductReviewTileConfig with _$ProductReviewTileConfig {
  const ProductReviewTileConfig._();

  const factory ProductReviewTileConfig({
    @JsonKey(fromJson: JsonSafe.string) String? id,
    @JsonKey(fromJson: JsonSafe.string) String? imageUrl,
    @JsonKey(fromJson: JsonSafe.string) String? reviewText,
    @JsonKey(fromJson: _userTileConfigFromJson) UserTileConfig? userTile,
    @JsonKey(fromJson: _testimonialStyleNullableFromJson)
    TestimonialStyle? style,
  }) = _ProductReviewTileConfig;

  TestimonialStyle get resolvedStyle => style ?? const TestimonialStyle();

  UserTileConfig? get resolvedUserTile {
    if (userTile == null) return null;
    final TestimonialStyle(
      :userNameStyleConfig,
      :reviewTextStyleConfig,
      :avatarStyleConfig,
      :ratingStyleConfig,
    ) = resolvedStyle;
    return userTile!.copyWith(
      nameStyleConfig: userNameStyleConfig,
      subtitleStyleConfig: reviewTextStyleConfig,
      avatarStyleConfig: avatarStyleConfig,
      ratingStyleConfig: ratingStyleConfig,
    );
  }

  factory ProductReviewTileConfig.fromJson(Map<String, dynamic> json) =>
      _$ProductReviewTileConfigFromJson(json);
}

UserTileConfig? _userTileConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, UserTileConfig.fromJson);
}

TestimonialStyle? _testimonialStyleNullableFromJson(dynamic value) {
  return JsonSafe.parseObject(value, TestimonialStyle.fromJson);
}
