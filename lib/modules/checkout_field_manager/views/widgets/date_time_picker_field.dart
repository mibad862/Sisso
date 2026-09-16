import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../dynamic_layout/helper/helper.dart';
import '../../helpers/checkout_helper.dart';
import '../../models/checkout_field.dart';

class DateTimePickerFormField extends FormField<String> {
  DateTimePickerFormField({
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
           final fieldType = field.type ?? '';

           DateTime resolveInitialDateTime() {
             final currentValue = state.value ?? controller?.text;
             final parsed = currentValue != null
                 ? DateTime.tryParse(currentValue)
                 : null;
             return parsed ?? DateTime.now();
           }

           Future<void> selectDateTime(BuildContext context) async {
             if (fieldType == 'time') {
               final picked = await showTimePicker(
                 context: context,
                 initialTime: TimeOfDay.fromDateTime(resolveInitialDateTime()),
               );
               if (picked != null) {
                 final localizations = MaterialLocalizations.of(context);
                 final formatted = localizations.formatTimeOfDay(
                   picked,
                   alwaysUse24HourFormat: false,
                 );
                 state.didChange(formatted);
               }
             } else if (fieldType == 'datetime_local') {
               final initialDateTime = resolveInitialDateTime();
               final pickedDate = await showDatePicker(
                 context: context,
                 initialDate: initialDateTime,
                 firstDate: DateTime(1900),
                 lastDate: DateTime(2100),
               );
               if (pickedDate == null) {
                 return;
               }

               final pickedTime = await showTimePicker(
                 context: context,
                 initialTime: TimeOfDay.fromDateTime(initialDateTime),
               );
               if (pickedTime == null) {
                 return;
               }

               final combined = DateTime(
                 pickedDate.year,
                 pickedDate.month,
                 pickedDate.day,
                 pickedTime.hour,
                 pickedTime.minute,
               );
               final formatted = DateFormat(
                 "yyyy-MM-dd'T'HH:mm",
               ).format(combined);
               state.didChange(formatted);
             } else {
               final picked = await showDatePicker(
                 context: context,
                 initialDate: resolveInitialDateTime(),
                 firstDate: DateTime(1900),
                 lastDate: DateTime(2100),
               );
               if (picked != null) {
                 final formatted = DateFormat('yyyy-MM-dd').format(picked);
                 state.didChange(formatted);
               }
             }
           }

           if (controller != null && state.value != controller.text) {
             controller.text = state.value ?? '';
           }

           return Column(
             mainAxisSize: MainAxisSize.min,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               if (isDesktopLayout)
                 Padding(
                   padding: const EdgeInsets.only(bottom: 6.0),
                   child: Text(
                     getLabelInput(field),
                     style: const TextStyle(
                       fontWeight: FontWeight.w500,
                       fontSize: 14,
                       height: 20 / 14,
                     ),
                   ),
                 ),
               TextField(
                 controller: controller,
                 readOnly: true,
                 onTap: () => selectDateTime(state.context),
                 decoration: InputDecoration(
                   labelText: getLabelInput(field),
                   suffixIcon: fieldType == 'date'
                       ? const Icon(Icons.calendar_today)
                       : fieldType == 'time'
                       ? const Icon(Icons.access_time)
                       : const Icon(Icons.event),
                   border: isDesktopLayout ? const OutlineInputBorder() : null,
                   fillColor: isDesktopLayout
                       ? Theme.of(state.context).colorScheme.surface
                       : null,
                   filled: isDesktopLayout,
                   errorText: state.errorText,
                 ),
               ),
             ],
           );
         },
       );
}
