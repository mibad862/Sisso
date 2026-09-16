import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/converters/json_safe.dart';
import 'entities.dart';

part 'menu_list_item_config.freezed.dart';
part 'menu_list_item_config.g.dart';

@freezed
abstract class MenuListItemStyle with _$MenuListItemStyle {
  const factory MenuListItemStyle({
    @JsonKey(fromJson: _fluxCardConfigFromJson)
    @Default(FluxCardConfig())
    FluxCardConfig cardConfig,
    @JsonKey(fromJson: _fluxImageStyleConfigFromJson)
    FluxImageStyleConfig? imageStyleConfig,
    @JsonKey(fromJson: _fluxTextStyleConfigFromJson)
    FluxTextStyleConfig? titleStyleConfig,
  }) = _MenuListItemStyle;

  factory MenuListItemStyle.fromJson(Map<String, dynamic> json) =>
      _$MenuListItemStyleFromJson(json);
}

FluxCardConfig _fluxCardConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, FluxCardConfig.fromJson) ??
      const FluxCardConfig();
}

FluxImageStyleConfig? _fluxImageStyleConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, FluxImageStyleConfig.fromJson);
}

FluxTextStyleConfig? _fluxTextStyleConfigFromJson(dynamic value) {
  return JsonSafe.parseObject(value, FluxTextStyleConfig.fromJson);
}

@freezed
abstract class MenuListItemConfig with _$MenuListItemConfig {
  const factory MenuListItemConfig({
    @JsonKey(fromJson: JsonSafe.stringOrEmpty) @Default('') String title,
    @JsonKey(fromJson: JsonSafe.string) String? imageUrl,
    @JsonKey(fromJson: _menuListItemStyleNullableFromJson)
    MenuListItemStyle? style,
    @JsonKey(fromJson: JsonSafe.action) Map<String, dynamic>? action,
  }) = _MenuListItemConfig;

  const MenuListItemConfig._();

  factory MenuListItemConfig.fromJson(Map<String, dynamic> json) =>
      _$MenuListItemConfigFromJson(json);

  MenuListItemStyle get resolvedStyle => style ?? const MenuListItemStyle();
}

MenuListItemStyle? _menuListItemStyleNullableFromJson(dynamic value) {
  return JsonSafe.parseObject(value, MenuListItemStyle.fromJson);
}
