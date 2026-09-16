import 'package:flutter/material.dart';

import '../../helpers/checkout_helper.dart';
import '../../models/checkout_field.dart';

class MultiCheckboxFormField extends FormField<List<String>> {
  MultiCheckboxFormField({
    super.key,
    required CheckoutField field,
    TextEditingController? controller,
    super.validator,
    FormFieldSetter<List<String>>? onSaved,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
  }) : super(
         initialValue:
             controller?.text
                 .split(',')
                 .where((val) => val.isNotEmpty)
                 .toList() ??
             [],
         onSaved: (value) {
           if (controller != null && value != null) {
             controller.text = value.where((val) => val.isNotEmpty).join(',');
           }
           if (onSaved != null) {
             onSaved(value);
           }
         },
         builder: (FormFieldState<List<String>> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const SizedBox(height: 15),
               Text(
                 getLabelInput(field),
                 style: Theme.of(state.context).textTheme.titleMedium,
               ),
               const SizedBox(height: 7),
               ...List.generate(field.options?.length ?? 0, (index) {
                 final option = field.options![index];
                 final optionValue = CheckoutField.optionValue(option);
                 final optionLabel = CheckoutField.optionLabel(option);
                 final isChecked = state.value!.contains(optionValue);

                 return Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: <Widget>[
                         SizedBox(
                           height: 24,
                           width: 24,
                           child: Checkbox(
                             value: isChecked,
                             onChanged: (bool? checked) {
                               if (checked == null) return;

                               final updated = [...state.value!];
                               if (checked) {
                                 if (!updated.contains(optionValue)) {
                                   updated.add(optionValue);
                                 }
                               } else {
                                 updated.remove(optionValue);
                               }
                               state.didChange(updated);
                             },
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
                     if (index != (field.options!.length - 1))
                       const SizedBox(height: 15),
                   ],
                 );
               }),
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
