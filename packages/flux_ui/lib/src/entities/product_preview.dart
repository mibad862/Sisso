import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/converters/json_safe.dart';
import '../core/converters/list_color_converter.dart';

part 'product_preview.freezed.dart';
part 'product_preview.g.dart';

@freezed
abstract class ProductPreview with _$ProductPreview {
  const factory ProductPreview({
    @JsonKey(fromJson: JsonSafe.stringOrEmpty) required String title,
    @JsonKey(fromJson: JsonSafe.stringOrEmpty) required String textPrice,
    @JsonKey(fromJson: JsonSafe.stringOrEmpty) required String imageUrl,
    @JsonKey(fromJson: JsonSafe.string) String? textDiscountedPrice,
    @JsonKey(fromJson: JsonSafe.doubleOrNull) double? discountPercentage,
    @JsonKey(fromJson: JsonSafe.boolOrFalse) @Default(false) bool isFavorite,
    @ListColorConverter() List<Color>? colorVariants,
  }) = _ProductPreview;

  factory ProductPreview.fromJson(Map<String, dynamic> json) =>
      _$ProductPreviewFromJson(json);

  const ProductPreview._();

  bool get hasDiscount => textDiscountedPrice != null;
}
