import 'package:flutter/cupertino.dart';
import 'package:flux_localization/flux_localization.dart';

import '../../../common/constants.dart';
import '../models/checkout_field.dart';
import '../models/checkout_fields_manager.dart';

String? validateField(BuildContext context, String? val, CheckoutField field) {
  if (!field.required) {
    if (field.type == 'number' && val != null && val.isNotEmpty) {
      final n = num.tryParse(val);
      if (n != null) {
        if (field.min != null && n < field.min!) {
          return S.of(context).minValue(field.min!);
        }
        if (field.max != null && n > field.max!) {
          return S.of(context).maxValue(field.max!);
        }
      }
    }
    return null;
  }

  final label = field.label;
  if ((val?.isEmpty ?? true) && label != null) {
    return S.of(context).theFieldIsRequired(label);
  }
  if (val != null && field.type == 'email') {
    return validateEmail(val);
  }
  if (field.type == 'number' && val != null && val.isNotEmpty) {
    final n = num.tryParse(val);
    if (n != null) {
      if (field.min != null && n < field.min!) {
        return S.of(context).minValue(field.min!);
      }
      if (field.max != null && n > field.max!) {
        return S.of(context).maxValue(field.max!);
      }
    }
  }
  return null;
}

String? validateEmail(String email) {
  if (email.isEmail) {
    return null;
  }
  return S.current.errorEmailFormat;
}

TextInputType? getKeyboardType(String type) {
  switch (type) {
    case 'text':
    case 'password':
      return TextInputType.text;
    case 'number':
      return TextInputType.number;
    case 'email':
      return TextInputType.emailAddress;
    case 'url':
      return TextInputType.url;
    case 'tel':
      return TextInputType.phone;
    case 'textarea':
      return TextInputType.multiline;

    default:
      return null;
  }
}

void _initFields<T>(
  Map<String, T> map,
  List<CheckoutField>? fields,
  T Function() createInstance,
) {
  for (var i = 0; i < (fields?.length ?? 0); i++) {
    var key = fields?[i].key;
    if (key?.isNotEmpty ?? false) {
      if (map[key] == null) {
        map[key!] = createInstance();
      }
    }
  }
}

void initCheckoutFields(
  Map<String, TextEditingController> mapCtrls,
  Map<String, FocusNode> mapFocusNodes,
  CheckoutFieldsManager? fields,
) {
  _initFields<TextEditingController>(
    mapCtrls,
    fields?.billing,
    () => TextEditingController(),
  );
  _initFields<TextEditingController>(
    mapCtrls,
    fields?.shipping,
    () => TextEditingController(),
  );
  _initFields<TextEditingController>(
    mapCtrls,
    fields?.additional,
    () => TextEditingController(),
  );

  _initFields<FocusNode>(
    mapFocusNodes,
    fields?.billing?.where((e) => isTextInputFieldType(e)).toList(),
    () => FocusNode(),
  );
  _initFields<FocusNode>(
    mapFocusNodes,
    fields?.shipping?.where((e) => isTextInputFieldType(e)).toList(),
    () => FocusNode(),
  );
  _initFields<FocusNode>(
    mapFocusNodes,
    fields?.additional?.where((e) => isTextInputFieldType(e)).toList(),
    () => FocusNode(),
  );
}

String getLabelInput(CheckoutField field) {
  var label = field.label ?? '';
  if (label.isNotEmpty) {
    if (field.required == false) {
      label += ' (${S.current.optional})';
    }
    return label;
  } else {
    return '';
  }
}

bool isTextInputFieldType(CheckoutField field) {
  const textInputTypes = {
    'text',
    'password',
    'number',
    'email',
    'url',
    'tel',
    'textarea',
  };
  return textInputTypes.contains(field.type);
}

const defaultBillingFields = [
  'first_name',
  'last_name',
  'company',
  'address_1',
  'address_2',
  'city',
  'postcode',
  'country',
  'state',
  'email',
  'phone',
];

const defaultShippingFields = [
  'first_name',
  'last_name',
  'company',
  'address_1',
  'address_2',
  'city',
  'postcode',
  'country',
  'state',
  'phone',
];

final Set<String> _defaultBillingFieldSet = defaultBillingFields.toSet();
final Set<String> _defaultShippingFieldSet = defaultShippingFields.toSet();

Set<String> _defaultFieldSet(bool isBilling) =>
    isBilling ? _defaultBillingFieldSet : _defaultShippingFieldSet;

String _normalizeToken(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'_+'), '_')
    .replaceAll(RegExp(r'^_|_$'), '');

bool _hasToken(String normalized, String token) {
  if (normalized == token) {
    return true;
  }
  return normalized.startsWith('${token}_') ||
      normalized.endsWith('_$token') ||
      normalized.contains('_${token}_');
}

bool _hasAnyToken(String normalized, List<String> tokens) {
  for (final token in tokens) {
    if (_hasToken(normalized, token)) {
      return true;
    }
  }
  return false;
}

String _fieldSignature(CheckoutField field) => [
  field.label,
  field.placeholder,
  field.key,
  field.name,
].whereType<String>().join(' ').toLowerCase();

bool _containsAny(String source, List<String> tokens) {
  for (final token in tokens) {
    if (source.contains(token)) {
      return true;
    }
  }
  return false;
}

bool _isStreetAddressSemantic(CheckoutField field) {
  final signature = _fieldSignature(field);
  return _containsAny(signature, [
    'street address',
    'address line 1',
    'house number and street',
  ]);
}

bool _isAddressLine2Semantic(CheckoutField field) {
  final signature = _fieldSignature(field);
  return _containsAny(signature, [
    'address line 2',
    'apartment',
    'suite',
    'unit',
    'flat',
  ]);
}

String? _extractCanonicalFromIdentifier(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }

  final token = _normalizeToken(
    raw,
  ).replaceAll('billing_', '').replaceAll('shipping_', '');

  if (_hasAnyToken(token, ['first_name', 'firstname', 'first'])) {
    return 'first_name';
  }
  if (_hasAnyToken(token, ['last_name', 'lastname', 'last'])) {
    return 'last_name';
  }
  if (_hasAnyToken(token, ['company', 'organisation', 'organization'])) {
    return 'company';
  }
  if (_hasAnyToken(token, ['address_1', 'address1', 'street_address'])) {
    return 'address_1';
  }
  if (_hasAnyToken(token, ['address_2', 'address2', 'apartment'])) {
    return 'address_2';
  }
  if (_hasAnyToken(token, ['city', 'town'])) {
    return 'city';
  }
  if (_hasAnyToken(token, [
    'postcode',
    'post_code',
    'postal_code',
    'zipcode',
    'zip',
  ])) {
    return 'postcode';
  }
  if (_hasAnyToken(token, ['country'])) {
    return 'country';
  }
  if (_hasAnyToken(token, ['state', 'province', 'region', 'county'])) {
    return 'state';
  }
  if (_hasAnyToken(token, ['email', 'email_address'])) {
    return 'email';
  }
  if (_hasAnyToken(token, ['phone', 'telephone', 'mobile', 'ship_phone'])) {
    return 'phone';
  }
  return null;
}

String? _resolveCanonicalWooField(
  CheckoutField field, {
  required bool isBilling,
}) {
  // Some plugins send wrong identifiers (e.g. shipping_state for Street
  // address), so semantic label/placeholder must win in these cases.
  if (_isStreetAddressSemantic(field)) {
    return 'address_1';
  }
  if (_isAddressLine2Semantic(field)) {
    return 'address_2';
  }

  final byName = _extractCanonicalFromIdentifier(field.name);
  if (byName != null) {
    return byName;
  }

  final byKey = _extractCanonicalFromIdentifier(field.key);
  if (byKey != null) {
    return byKey;
  }

  final signature = _fieldSignature(field);
  if (signature.isEmpty) {
    return null;
  }

  if (_containsAny(signature, ['first name', 'given-name', 'given name'])) {
    return 'first_name';
  }
  if (_containsAny(signature, ['last name', 'family-name', 'family name'])) {
    return 'last_name';
  }
  if (_containsAny(signature, ['company', 'organization', 'organisation'])) {
    return 'company';
  }
  if (_containsAny(signature, ['city', 'town'])) {
    return 'city';
  }
  if (_containsAny(signature, [
    'postcode',
    'postal code',
    'zip code',
    'zipcode',
  ])) {
    return 'postcode';
  }
  if (_containsAny(signature, ['country'])) {
    return 'country';
  }
  if (_containsAny(signature, ['state', 'province', 'region', 'county'])) {
    return 'state';
  }
  if (isBilling && _containsAny(signature, ['email', 'email address'])) {
    return 'email';
  }
  if (_containsAny(signature, ['phone', 'telephone', 'mobile'])) {
    return 'phone';
  }

  return null;
}

bool _isDefaultAddressField(CheckoutField field, {required bool isBilling}) {
  final canonical = _resolveCanonicalWooField(field, isBilling: isBilling);
  if (canonical == null) {
    return false;
  }
  return _defaultFieldSet(isBilling).contains(canonical);
}

Map<String, dynamic> _buildAddressJsonData(
  List<CheckoutField>? fields,
  Map<String, dynamic> jsonData, {
  required bool isBilling,
}) {
  final addressJsonData = <String, dynamic>{};

  for (final field in fields ?? <CheckoutField>[]) {
    final key = field.key;
    if (key == null || jsonData[key] == null) {
      continue;
    }

    final canonical = _resolveCanonicalWooField(field, isBilling: isBilling);
    if (canonical == null) {
      continue;
    }

    if (!_defaultFieldSet(isBilling).contains(canonical)) {
      continue;
    }

    addressJsonData[canonical] = jsonData[key];
  }

  return addressJsonData;
}

void _appendAdditionalFields(
  Map<String, dynamic> additionalJsonData,
  List<CheckoutField>? fields,
  Map<String, dynamic> jsonData, {
  required bool isBilling,
  required bool isFromAdditionalSection,
}) {
  for (final field in fields ?? <CheckoutField>[]) {
    final key = field.key;
    if (key == null || jsonData[key] == null) {
      continue;
    }

    if (!isFromAdditionalSection &&
        _isDefaultAddressField(field, isBilling: isBilling)) {
      continue;
    }

    additionalJsonData['_$key'] = jsonData[key];
  }
}

Map<String, dynamic> getAdditionalJsonData(
  CheckoutFieldsManager? fields,
  Map<String, dynamic> jsonData,
) {
  final additionalJsonData = <String, dynamic>{};

  _appendAdditionalFields(
    additionalJsonData,
    fields?.additional,
    jsonData,
    isBilling: false,
    isFromAdditionalSection: true,
  );
  _appendAdditionalFields(
    additionalJsonData,
    fields?.billing,
    jsonData,
    isBilling: true,
    isFromAdditionalSection: false,
  );
  _appendAdditionalFields(
    additionalJsonData,
    fields?.shipping,
    jsonData,
    isBilling: false,
    isFromAdditionalSection: false,
  );

  return additionalJsonData;
}

Map<String, dynamic> getBillingJsonData(
  CheckoutFieldsManager? fields,
  Map<String, dynamic> jsonData,
) {
  return _buildAddressJsonData(fields?.billing, jsonData, isBilling: true);
}

Map<String, dynamic> getShippingJsonData(
  CheckoutFieldsManager? fields,
  Map<String, dynamic> jsonData,
) {
  return _buildAddressJsonData(fields?.shipping, jsonData, isBilling: false);
}
