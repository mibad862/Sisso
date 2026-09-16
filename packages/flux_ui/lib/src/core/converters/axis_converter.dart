import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_safe.dart';

class AxisConverter implements JsonConverter<Axis, dynamic> {
  const AxisConverter();

  @override
  Axis fromJson(dynamic json) {
    switch (JsonSafe.string(json)) {
      case 'horizontal':
        return Axis.horizontal;
      case 'vertical':
        return Axis.vertical;
      default:
        return Axis.horizontal;
    }
  }

  @override
  String toJson(Axis axis) {
    switch (axis) {
      case Axis.horizontal:
        return 'horizontal';
      case Axis.vertical:
        return 'vertical';
    }
  }
}
