import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/config/models/address_field_config.dart';
import '../../../models/app_model.dart';
import 'helpers/checkout_helper.dart';

class PhoneInput extends StatelessWidget {
  const PhoneInput({
    super.key,
    this.config,
    this.autoFocus = false,
    this.focusNode,
    this.nextFieldFocus,
    this.textFieldController,
    this.hasNext = false,
    this.initialPhoneNumber,
    this.type = AddressFieldType.unknown,
    required this.onTextFieldSaved,
  });
  final AddressFieldConfig? config;
  final bool autoFocus;
  final FocusNode? focusNode;
  final FocusNode? nextFieldFocus;
  final TextEditingController? textFieldController;
  final bool hasNext;
  final PhoneNumber? initialPhoneNumber;
  final AddressFieldType type;
  final Function(String? value, AddressFieldType type) onTextFieldSaved;

  @override
  Widget build(BuildContext context) {
    var langCode = context.read<AppModel>().langCode;

    return InternationalPhoneNumberInput(
      autoFocus: autoFocus,
      textFieldController: textFieldController,
      focusNode: focusNode,
      isReadOnly: isFieldReadOnly(config),
      autofillHints: type.autofillHint != null
          ? ['${type.autofillHint}']
          : null,
      inputDecoration: InputDecoration(labelText: type.getTitle(context)),
      keyboardType: getKeyboardType(type),
      keyboardAction: hasNext ? TextInputAction.next : TextInputAction.done,
      onFieldSubmitted: (_) {
        if (hasNext) {
          nextFieldFocus?.requestFocus();
        }
      },
      onSaved: (value) {
        final parsedPhone = value.phoneNumber?.trim();
        final fallbackPhone = textFieldController?.text.trim();
        final phone = (parsedPhone?.isNotEmpty ?? false)
            ? parsedPhone
            : fallbackPhone;
        onTextFieldSaved(phone, type);
      },
      onInputChanged: (PhoneNumber number) {
        final parsedPhone = number.phoneNumber?.trim();
        final fallbackPhone = textFieldController?.text.trim();
        final phone = (parsedPhone?.isNotEmpty ?? false)
            ? parsedPhone
            : fallbackPhone;
        onTextFieldSaved(phone, type);
      },
      onInputValidated: (value) => {},
      spaceBetweenSelectorAndTextField: 0,
      selectorConfig: SelectorConfig(
        enable: kPhoneNumberConfig.useInternationalFormat,
        showFlags: kPhoneNumberConfig.showCountryFlag,
        selectorType: kPhoneNumberConfig.selectorType,
        setSelectorButtonAsPrefixIcon:
            kPhoneNumberConfig.selectorFlagAsPrefixIcon,
        leadingPadding: 0,
        trailingSpace: false,
      ),
      selectorTextStyle: Theme.of(context).textTheme.titleMedium,
      ignoreBlank: !(config?.required ?? true),
      initialValue: initialPhoneNumber,
      formatInput: kPhoneNumberConfig.formatInput,
      countries: kPhoneNumberConfig.customCountryList,
      locale: langCode,
      searchBoxDecoration: InputDecoration(
        labelText: S.of(context).searchByCountryNameOrDialCode,
      ),
      errorMessage: S.of(context).invalidPhoneNumber,
    );
  }
}
