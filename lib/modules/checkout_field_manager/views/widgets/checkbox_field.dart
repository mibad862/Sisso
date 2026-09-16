import 'package:flutter/material.dart';

import '../../helpers/checkout_helper.dart';
import '../../models/checkout_field.dart';

class CheckboxFormField extends FormField<String> {
  CheckboxFormField({
    super.key,
    required CheckoutField field,
    TextEditingController? controller,
    super.validator,
    super.onSaved,
  }) : super(
         initialValue: controller?.value.text,
         builder: (FormFieldState<String> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const SizedBox(height: 15),
               Row(
                 children: <Widget>[
                   SizedBox(
                     height: 24,
                     width: 24,
                     child: Checkbox(
                       value: state.value == 'checked',
                       onChanged: (bool? newValue) {
                         if (newValue == null) return;
                         state.didChange(newValue == true ? 'checked' : '');
                         if (controller != null) {
                           controller.value = controller.value.copyWith(
                             text: newValue == true ? 'checked' : '',
                           );
                         }
                       },
                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                     ),
                   ),
                   const SizedBox(width: 5),
                   Expanded(
                     child: Text(
                       getLabelInput(field),
                       style: Theme.of(state.context).textTheme.labelLarge,
                     ),
                   ),
                 ],
               ),
               if (state.hasError)
                 Text(
                   state.errorText!,
                   style: TextStyle(
                     color: Theme.of(state.context).colorScheme.error,
                     fontSize: 12,
                   ),
                 ),
             ],
           );
         },
       );
}
