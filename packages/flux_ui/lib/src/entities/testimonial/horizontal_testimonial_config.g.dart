// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horizontal_testimonial_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HorizontalTestimonialConfig _$HorizontalTestimonialConfigFromJson(
  Map<String, dynamic> json,
) => _HorizontalTestimonialConfig(
  style: json['style'] == null
      ? const TestimonialStyle()
      : _testimonialStyleFromJson(json['style']),
  listConfig: json['listConfig'] == null
      ? const FluxListViewConfig()
      : _testimonialListConfigFromJson(json['listConfig']),
  items: json['items'] == null
      ? const []
      : _productReviewTileConfigsFromJson(json['items']),
  design:
      $enumDecodeNullable(
        _$HorizontalTestimonialDesignEnumMap,
        json['design'],
        unknownValue: HorizontalTestimonialDesign.tile,
      ) ??
      HorizontalTestimonialDesign.tile,
);

Map<String, dynamic> _$HorizontalTestimonialConfigToJson(
  _HorizontalTestimonialConfig instance,
) => <String, dynamic>{
  'style': instance.style.toJson(),
  'listConfig': instance.listConfig.toJson(),
  'items': instance.items.map((e) => e.toJson()).toList(),
  'design': _$HorizontalTestimonialDesignEnumMap[instance.design]!,
};

const _$HorizontalTestimonialDesignEnumMap = {
  HorizontalTestimonialDesign.card: 'card',
  HorizontalTestimonialDesign.chat: 'chat',
  HorizontalTestimonialDesign.tile: 'tile',
};
