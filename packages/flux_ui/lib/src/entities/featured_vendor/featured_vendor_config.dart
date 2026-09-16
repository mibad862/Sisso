import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/converters/json_safe.dart';

part 'featured_vendor_config.freezed.dart';
part 'featured_vendor_config.g.dart';

@freezed
abstract class FeaturedVendorConfig with _$FeaturedVendorConfig {
  const factory FeaturedVendorConfig({
    /// Label header name
    @JsonKey(fromJson: JsonSafe.string) String? name,
    @JsonKey(fromJson: _columnCountFromJson) @Default(3) int columnCount,
    @JsonKey(fromJson: JsonSafe.boolOrTrue) @Default(true) bool showRating,
    @JsonKey(fromJson: JsonSafe.boolOrFalse)
    @Default(false)
    bool enableAutoSliding,
    @JsonKey(fromJson: JsonSafe.intOrNull) int? durationAutoSliding,
    @JsonKey(fromJson: JsonSafe.boolOrFalse)
    @Default(false)
    bool enableBackground,
    @JsonKey(fromJson: JsonSafe.boolOrFalse) @Default(false) bool isSnapping,
    @JsonKey(fromJson: JsonSafe.intOrNull) int? limit,
    @JsonKey(fromJson: _imageBoxfitFromJson)
    @Default('cover')
    String imageBoxfit,
    @JsonKey(fromJson: _alignmentFromJson)
    @Default('centerStart')
    String alignment,
  }) = _FeaturedVendorConfig;

  factory FeaturedVendorConfig.fromJson(Map<String, dynamic> json) =>
      _$FeaturedVendorConfigFromJson(json);
}

int _columnCountFromJson(dynamic value) => JsonSafe.intOrNull(value) ?? 3;

String _imageBoxfitFromJson(dynamic value) => JsonSafe.string(value) ?? 'cover';

String _alignmentFromJson(dynamic value) {
  return JsonSafe.string(value) ?? 'centerStart';
}
