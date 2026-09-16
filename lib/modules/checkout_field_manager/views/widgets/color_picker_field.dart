import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flux_localization/flux_localization.dart';

import '../../helpers/checkout_helper.dart';
import '../../models/checkout_field.dart';

class ColorPickerFormField extends FormField<String> {
  ColorPickerFormField({
    super.key,
    required CheckoutField field,
    TextEditingController? controller,
    super.validator,
    FormFieldSetter<String>? onSaved,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
  }) : super(
         initialValue: controller?.text.isNotEmpty == true
             ? controller!.text
             : field.defaultValue,
         onSaved: (value) {
           if (controller != null && value != null) {
             controller.text = value;
           }
           if (onSaved != null) onSaved(value);
         },
         builder: (FormFieldState<String> state) {
           Color currentColor;
           try {
             currentColor = _hexToColor(state.value ?? '#FFFFFF');
           } catch (_) {
             currentColor = Colors.white;
           }
           final defaultValue = (state.value?.isNotEmpty ?? false)
               ? state.value!
               : field.defaultValue;

           final placeholderValue = (field.placeholder?.isNotEmpty ?? false)
               ? field.placeholder
               : null;

           final theme = Theme.of(state.context);

           void showColorPicker(BuildContext context) {
             showDialog(
               context: context,
               builder: (_) {
                 var tempColor = currentColor;
                 return AlertDialog(
                   content: SingleChildScrollView(
                     child: ColorPicker(
                       hexInputBar: true,
                       pickerColor: currentColor,
                       onColorChanged: (Color color) {
                         tempColor = color;
                       },
                     ),
                   ),
                   actions: [
                     TextButton(
                       child: Text(S.of(context).select),
                       onPressed: () {
                         final newHex = _colorToHex(tempColor);
                         state.didChange(newHex);
                         Navigator.of(context).pop();
                       },
                     ),
                   ],
                 );
               },
             );
           }

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const SizedBox(height: 15),
               Text(getLabelInput(field), style: theme.textTheme.titleMedium),
               const SizedBox(height: 7),
               GestureDetector(
                 onTap: () => showColorPicker(state.context),
                 child: Container(
                   height: 50,
                   padding: const EdgeInsets.symmetric(horizontal: 12),
                   decoration: BoxDecoration(
                     border: Border.all(
                       color: state.hasError
                           ? theme.colorScheme.error
                           : theme.dividerColor,
                     ),
                     borderRadius: BorderRadius.circular(2),
                     color: currentColor,
                   ),
                   child: Align(
                     alignment: Alignment.centerLeft,
                     child: Text(
                       defaultValue ??
                           placeholderValue ??
                           S.of(state.context).select,
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                     ),
                   ),
                 ),
               ),
               if (state.hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 4),
                   child: Text(
                     state.errorText!,
                     style: TextStyle(
                       color: theme.colorScheme.error,
                       fontSize: 12,
                     ),
                   ),
                 ),
             ],
           );
         },
       );

  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // add alpha if missing
    return Color(int.parse(hex, radix: 16));
  }

  static String _colorToHex(Color color) {
    final argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${argb.substring(2).toUpperCase()}';
  }
}
