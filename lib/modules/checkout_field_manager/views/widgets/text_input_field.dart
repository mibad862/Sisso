import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';

import '../../../../widgets/common/checkout/text_input.dart';
import '../../helpers/checkout_helper.dart';
import '../../models/checkout_field.dart';

class TextInputField extends StatelessWidget {
  const TextInputField({
    super.key,
    required this.field,
    this.controller,
    this.hasNext = false,
    this.focusNode,
    this.nextFieldFocus,
  });
  final CheckoutField field;
  final TextEditingController? controller;
  final bool hasNext;
  final FocusNode? focusNode;
  final FocusNode? nextFieldFocus;

  @override
  Widget build(BuildContext context) {
    String? helperText;
    final hintText = (field.placeholder?.isNotEmpty ?? false)
        ? field.placeholder
        : null;

    if (field.type == 'number' && (field.min != null || field.max != null)) {
      final parts = [
        if (field.min != null) S.of(context).minValue(field.min!),
        if (field.max != null) S.of(context).maxValue(field.max!),
      ];
      helperText = parts.join('  ·  ');
    }

    return TextInput(
      focusNode: focusNode,
      nextFieldFocus: nextFieldFocus,
      textFieldController: controller,
      hasNext: hasNext,
      obscureText: field.type == 'password',
      isTextarea: field.type == 'textarea',
      keyboardType: getKeyboardType(field.type ?? ''),
      label: getLabelInput(field),
      hintText: hintText,
      helperText: helperText,
      tooltipMessage: (field.description?.isNotEmpty ?? false)
          ? field.description
          : null,
      validator: (val) {
        return validateField(context, val, field);
      },
    );
  }
}
