import 'package:flutter/material.dart';

import '../../helpers/checkout_helper.dart';
import '../../models/checkout_field.dart';

class RadioFormField extends FormField<String> {
  RadioFormField({
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
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const SizedBox(height: 15),
               Text(
                 getLabelInput(field),
                 style: Theme.of(state.context).textTheme.titleMedium,
               ),
               const SizedBox(height: 7),
               RadioGroup<String>(
                 groupValue: state.value,
                 onChanged: (String? selected) {
                   if (selected != null) {
                     state.didChange(selected);
                   }
                 },
                 child: Column(
                   children: List.generate(field.options?.length ?? 0, (index) {
                     final option = field.options![index];
                     final optionValue = CheckoutField.optionValue(option);
                     final optionLabel = CheckoutField.optionLabel(option);
                     return Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: <Widget>[
                             SizedBox(
                               height: 24,
                               width: 24,
                               child: Radio<String>(
                                 value: optionValue,
                                 materialTapTargetSize:
                                     MaterialTapTargetSize.shrinkWrap,
                               ),
                             ),
                             const SizedBox(width: 5),
                             Expanded(
                               child: Text(
                                 optionLabel,
                                 style: Theme.of(
                                   state.context,
                                 ).textTheme.labelLarge,
                               ),
                             ),
                           ],
                         ),
                         if (index != field.options!.length - 1)
                           const SizedBox(height: 15),
                       ],
                     );
                   }),
                 ),
               ),
               if (state.hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 4),
                   child: Text(
                     state.errorText!,
                     style: TextStyle(
                       color: Theme.of(state.context).colorScheme.error,
                       fontSize: 12,
                     ),
                   ),
                 ),
             ],
           );
         },
       );
}
