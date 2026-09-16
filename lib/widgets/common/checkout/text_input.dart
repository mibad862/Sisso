import 'package:flutter/material.dart';

import '../../../modules/dynamic_layout/helper/helper.dart';

class TextInput extends StatelessWidget {
  const TextInput({
    super.key,
    this.autoFocus = false,
    this.focusNode,
    this.nextFieldFocus,
    this.textFieldController,
    this.hasNext = false,
    this.readOnly = false,
    this.obscureText = false,
    this.isTextarea = false,
    this.label,
    this.autofillHints,
    this.keyboardType,
    this.validator,
    this.onTextFieldSaved,
    this.helperText,
    this.hintText,
    this.tooltipMessage,
  });
  final bool autoFocus;
  final FocusNode? focusNode;
  final FocusNode? nextFieldFocus;
  final TextEditingController? textFieldController;
  final bool hasNext;
  final bool readOnly;
  final bool obscureText;
  final bool isTextarea;
  final String? label;
  final Iterable<String>? autofillHints;
  final TextInputType? keyboardType;
  final FormFieldValidator? validator;
  final Function(String? value)? onTextFieldSaved;
  final String? helperText;
  final String? hintText;
  final String? tooltipMessage;

  @override
  Widget build(BuildContext context) {
    final isDesktopLayout = Layout.isDisplayDesktop(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktopLayout)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              children: [
                Text(
                  label ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 20 / 14,
                  ),
                ),
                if (tooltipMessage?.isNotEmpty ?? false)
                  Tooltip(
                    message: tooltipMessage!,
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
              ],
            ),
          ),
        TextFormField(
          maxLines: isTextarea ? null : 1,
          minLines: isTextarea ? 4 : null,

          /// Auto focus first field if it's empty.
          autofocus: autoFocus,
          autocorrect: false,
          controller: textFieldController,
          focusNode: focusNode,
          readOnly: readOnly,
          obscureText: obscureText,
          autofillHints: autofillHints,
          decoration: InputDecoration(
            labelText: isDesktopLayout ? null : label,
            hintText: hintText,
            helperText: helperText,
            suffixIcon:
                (!isDesktopLayout && (tooltipMessage?.isNotEmpty ?? false))
                ? Tooltip(
                    message: tooltipMessage!,
                    triggerMode: TooltipTriggerMode.tap,
                    child: Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Theme.of(context).hintColor,
                    ),
                  )
                : null,
            border: isDesktopLayout ? const OutlineInputBorder() : null,
            fillColor: isDesktopLayout
                ? Theme.of(context).colorScheme.surface
                : null,
            filled: isDesktopLayout,
          ),

          keyboardType: keyboardType,
          textCapitalization: TextCapitalization.words,
          textInputAction: hasNext
              ? TextInputAction.next
              : TextInputAction.done,
          validator: validator,
          onFieldSubmitted: (_) {
            if (hasNext) {
              nextFieldFocus?.requestFocus();
            }
          },
          onSaved: onTextFieldSaved,
        ),
      ],
    );
  }
}
