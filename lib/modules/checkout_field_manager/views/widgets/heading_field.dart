import 'package:flutter/material.dart';

import '../../models/checkout_field.dart';

class HeadingField extends StatelessWidget {
  const HeadingField({super.key, required this.field});
  final CheckoutField field;
  @override
  Widget build(BuildContext context) {
    return Text(
      field.label ?? '',
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
