import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:quiver/strings.dart';

import '../../../common/config/models/product_card_config.dart';
import '../../../common/extensions/store_ext.dart';

class StoreName extends StatelessWidget {
  static StoreStyle get style01 => StoreStyle.style01;

  static StoreStyle byVisibility({
    required bool showStoreName,
    StoreStyle visibleStyle = StoreStyle.normal,
  }) {
    return showStoreName ? visibleStyle : StoreStyle.hide;
  }

  final Store? store;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final StoreStyle storeStyle;
  final VoidCallback? onTap;

  const StoreName({
    super.key,
    this.store,
    this.textStyle,
    this.padding,
    this.storeStyle = StoreStyle.normal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (storeStyle.isHide || store == null) {
      return const SizedBox();
    }

    final storeName = store?.name ?? '';
    final storeImage = store?.profileUrl ?? '';

    if (isBlank(storeName)) {
      return const SizedBox();
    }

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 5.0),
      child: GestureDetector(
        onTap: onTap,
        child: storeStyle.isNormal
            ? Text(
                '${S.of(context).soldBy} $storeName',
                style:
                    textStyle ??
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              )
            : Row(
                spacing: 4.0,
                children: [
                  if (isNotBlank(storeImage))
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: FluxImage(
                        imageUrl: storeImage,
                        height: 24,
                        width: 24,
                      ),
                    ),
                  Text(
                    storeName,
                    style:
                        textStyle ??
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}
