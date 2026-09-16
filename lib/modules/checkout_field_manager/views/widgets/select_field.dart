import 'package:flutter/material.dart';

import '../../../dynamic_layout/helper/helper.dart';
import '../../helpers/checkout_helper.dart';
import '../../models/checkout_field.dart';

class SelectFormField extends FormField<String> {
  SelectFormField({
    super.key,
    required CheckoutField field,
    TextEditingController? controller,
    super.validator,
    FormFieldSetter<String>? onSaved,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
  }) : super(
         initialValue: controller?.text,
         onSaved: (value) {
           if (controller != null && value != null) {
             controller.text = value;
           }
           if (onSaved != null) onSaved(value);
         },
         builder: (FormFieldState<String> state) {
           final isDesktopLayout = Layout.isDisplayDesktop(state.context);

           return DropdownButtonFormField<String>(
             decoration: InputDecoration(
               labelText: getLabelInput(field),
               border: isDesktopLayout ? const OutlineInputBorder() : null,
               fillColor: isDesktopLayout
                   ? Theme.of(state.context).colorScheme.surface
                   : null,
               filled: isDesktopLayout,
               errorText: state.errorText,
             ),
             initialValue: state.value?.isNotEmpty == true ? state.value : null,
             isExpanded: true,
             onChanged: (String? value) {
               if (value != null) {
                 state.didChange(value);
               }
             },
             items: (field.options ?? []).map((dynamic option) {
               final optionValue = CheckoutField.optionValue(option);
               final optionLabel = CheckoutField.optionLabel(option);
               return DropdownMenuItem<String>(
                 value: optionValue,
                 child: Container(
                   height: 60,
                   alignment: Alignment.centerLeft,
                   child: Text(optionLabel),
                 ),
               );
             }).toList(),
           );
         },
       );
}
