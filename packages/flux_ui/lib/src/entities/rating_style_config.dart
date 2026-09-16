import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/converters/json_safe.dart';
import 'app/app_color.dart';

part 'rating_style_config.freezed.dart';
part 'rating_style_config.g.dart';

@freezed
abstract class FluxRatingStyleConfig with _$FluxRatingStyleConfig {
  const factory FluxRatingStyleConfig({
    @JsonKey(fromJson: _ratingSizeFromJson) @Default(16) double size,
    @JsonKey(fromJson: AppColor.fromDynamic)
    @Default(AppColor.primary)
    AppColor color,
  }) = _FluxRatingStyleConfig;

  factory FluxRatingStyleConfig.fromJson(Map<String, dynamic> json) =>
      _$FluxRatingStyleConfigFromJson(json);
}

double _ratingSizeFromJson(dynamic value) {
  return JsonSafe.doubleOrNull(value) ?? 16;
}
