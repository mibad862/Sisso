import 'package:flutter/material.dart';

import '../../../../models/index.dart';
import '../../common/extensions/extensions.dart';

class ShortDescription extends StatelessWidget {
  final Product product;
  final bool show;
  final int maxLines;
  final TextStyle? style;

  const ShortDescription({
    required this.product,
    required this.show,
    this.maxLines = 1,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final plainText = product.shortDescription?.parseHtmlString() ?? '';

    if (plainText.isEmpty || !show) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        plainText,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style ?? const TextStyle(fontSize: 13),
      ),
    );
  }
}
