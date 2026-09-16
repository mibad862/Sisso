import 'package:flutter/material.dart';

import '../../../../common/constants.dart';

class SettingCardWidget extends StatelessWidget {
  const SettingCardWidget({
    super.key,
    required this.child,
    this.style,
    this.colorCard,
  });

  final Widget child;
  final SettingItemStyle? style;

  /// Current only use for [SettingItemStyle.listTile]
  final Color? colorCard;

  @override
  Widget build(BuildContext context) {
    final styleCard = style ?? kItemProfileTypeDefault;

    switch (styleCard) {
      case SettingItemStyle.flat:
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          child: child,
        );
      case SettingItemStyle.flatListTile:
        return Card(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          child: child,
        );
      case SettingItemStyle.flatShadow:
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              width: 1,
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.2),
            ),
          ),
          elevation: 0,
          color: Theme.of(context).cardColor,
          child: child,
        );
      default:
        return Card(
          color: colorCard,
          margin: const EdgeInsets.only(bottom: 2.0),
          elevation: 0,
          child: child,
        );
    }
  }
}
