// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'header_view_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HeaderViewConfig _$HeaderViewConfigFromJson(Map<String, dynamic> json) =>
    _HeaderViewConfig(
      margin: const EdgeInsetsDirectionalConverter().fromJson(json['margin']),
      padding: const EdgeInsetsDirectionalConverter().fromJson(json['padding']),
      title: JsonSafe.stringOrEmpty(json['title']),
      actionTitle: JsonSafe.string(json['actionTitle']),
      action: JsonSafe.action(json['action']),
      datetimeCountdown: const DateTimeConverter().fromJson(
        json['datetimeCountdown'],
      ),
    );

Map<String, dynamic> _$HeaderViewConfigToJson(
  _HeaderViewConfig instance,
) => <String, dynamic>{
  'margin': const EdgeInsetsDirectionalConverter().toJson(instance.margin),
  'padding': const EdgeInsetsDirectionalConverter().toJson(instance.padding),
  'title': instance.title,
  'actionTitle': instance.actionTitle,
  'action': instance.action,
  'datetimeCountdown': const DateTimeConverter().toJson(
    instance.datetimeCountdown,
  ),
};
