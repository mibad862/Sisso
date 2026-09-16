import 'package:flutter/cupertino.dart';
import 'package:flux_localization/flux_localization.dart';

import '../../../../common/config.dart';
import '../../../../common/config/models/address_field_config.dart';
import '../../../../common/constants.dart';

String? validateField(
  BuildContext context,
  String? val,
  AddressFieldConfig config,
  AddressFieldType type,
) {
  if (!config.required) {
    return null;
  }

  final label = type.getTitle(context)?.toLowerCase();
  if ((val?.isEmpty ?? true) && label != null) {
    return S.of(context).theFieldIsRequired(label);
  }
  if (val != null && type == AddressFieldType.email) {
    return validateEmail(val);
  }
  return null;
}

String? validateEmail(String email) {
  if (email.isEmail) {
    return null;
  }
  return S.current.errorEmailFormat;
}

TextInputType getKeyboardType(AddressFieldType type) {
  if (type == AddressFieldType.zipCode &&
      kPaymentConfig.enableAlphanumericZipCode) {
    return TextInputType.streetAddress;
  }
  return type.keyboardType;
}

bool isFieldReadOnly(AddressFieldConfig? config) {
  if (config == null) {
    return false;
  }

  /// Disable edit only when the field has a default value.
  if (!config.editable && config.defaultValue.isNotEmpty) {
    return true;
  }

  return false;
}
