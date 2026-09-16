import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/tools/flash.dart';
import '../../../models/cart/cart_base.dart';
import '../../../services/services.dart';
import '../../../widgets/common/checkout/bottom_checkout_actions.dart';
import '../../dynamic_layout/helper/helper.dart';
import '../helpers/checkout_helper.dart';
import '../models/checkout_field.dart';
import '../models/checkout_fields_manager.dart';
import '../services/checkout_cache_service.dart';
import 'mixin/checkout_fields_loader_mixin.dart';
import 'widgets/checkbox_field.dart';
import 'widgets/color_picker_field.dart';
import 'widgets/country_field.dart';
import 'widgets/date_time_picker_field.dart';
import 'widgets/file_upload_form_field.dart';
import 'widgets/heading_field.dart';
import 'widgets/multi_checkbox_field.dart';
import 'widgets/radio_field.dart';
import 'widgets/select_field.dart';
import 'widgets/state_field.dart';
import 'widgets/text_input_field.dart';

class CheckoutForm extends StatefulWidget {
  const CheckoutForm({super.key, required this.onNext});
  final VoidCallback onNext;

  @override
  State<CheckoutForm> createState() => _CheckoutFormState();
}

class _CheckoutFormState extends State<CheckoutForm>
    with CheckoutFieldsLoaderMixin {
  static const _nonCacheFieldTypes = {'file', 'date', 'time', 'datetime_local'};

  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  bool _isControllerListenersBound = false;
  Set<String> _conditionalParentKeys = {};
  Set<String> _previouslyVisibleFieldKeys = {};

  bool _showShipping = false;

  @override
  void initState() {
    super.initState();
    loadCheckoutFields((manager) {
      initCheckoutFields(_textControllers, _focusNodes, manager);
      _conditionalParentKeys = _collectConditionalParentKeys(manager);
      _bindControllerListeners();
      if (!mounted) return;

      setState(() {
        fieldsManager = manager;
      });

      final user = context.read<CartModel>().user;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        loadCheckoutValues(user, (Map<String, dynamic>? values) async {
          final sanitizedValues = _sanitizeLoadedCacheValues(values);
          if (values != null && values.length != sanitizedValues.length) {
            await CheckoutCacheService.saveCheckoutValues(sanitizedValues);
          }

          if (sanitizedValues.isNotEmpty) {
            for (var entry in sanitizedValues.entries) {
              if (entry.value != null && entry.value != 'null') {
                _textControllers[entry.key]?.text = entry.value.toString();
              }
            }
          }

          // Apply default values for fields that don't have cached values
          _applyDefaultValuesForVisibleFields();
        });
      });
    });
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _bindControllerListeners() {
    if (_isControllerListenersBound) {
      return;
    }
    _isControllerListenersBound = true;

    for (final entry in _textControllers.entries) {
      final key = entry.key;
      final controller = entry.value;
      controller.addListener(() => _onFieldValueChanged(key));
    }
  }

  Set<String> _collectConditionalParentKeys(CheckoutFieldsManager? manager) {
    final result = <String>{};

    void collect(List<CheckoutField>? fields) {
      for (final field in fields ?? <CheckoutField>[]) {
        final parentKey = field.conditionalParentKey?.trim();
        if (field.conditional && (parentKey?.isNotEmpty ?? false)) {
          result.add(parentKey!);
        }
      }
    }

    collect(manager?.billing);
    collect(manager?.shipping);
    collect(manager?.additional);
    return result;
  }

  void _onFieldValueChanged(String key) {
    if (!_conditionalParentKeys.contains(key)) {
      return;
    }
    if (!mounted) {
      return;
    }

    final previousKeys = _previouslyVisibleFieldKeys;
    setState(() {});

    // Apply default values only to newly visible conditional fields
    final currentKeys = _collectVisibleFieldKeys();
    final newlyVisibleKeys = currentKeys.difference(previousKeys);

    if (newlyVisibleKeys.isNotEmpty) {
      _applyDefaultValuesForSpecificFields(newlyVisibleKeys);
    }

    _previouslyVisibleFieldKeys = currentKeys;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktopLayout = Layout.isDisplayDesktop(context);
    final billingFields = fieldsManager?.billing ?? <CheckoutField>[];
    final shippingFields = fieldsManager?.shipping ?? <CheckoutField>[];
    final additionalFields = fieldsManager?.additional ?? <CheckoutField>[];
    final hasBillingFields = billingFields.isNotEmpty;
    final hasShippingFields = shippingFields.isNotEmpty;
    final hasAdditionalFields = additionalFields.isNotEmpty;
    final shouldShowShippingFields =
        hasShippingFields && (!hasBillingFields || _showShipping);

    if (isLoading && fieldsManager == null) {
      return Center(child: kLoadingWidget(context));
    }

    if (hasError && fieldsManager == null) {
      return Center(
        child: Text(
          errorMessage ?? S.of(context).failedToLoadCheckoutFields,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (fieldsManager == null) {
      return Center(child: Text(S.of(context).noCheckoutFieldsAvailable));
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 16.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasBillingFields) ...[
                    _buildSectionTitle(S.of(context).billingAddress),
                    ..._buildFieldsList(billingFields),
                  ],
                  if (hasBillingFields && hasShippingFields)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Checkbox(
                          value: _showShipping,
                          onChanged: (val) {
                            final previousKeys = _previouslyVisibleFieldKeys;
                            setState(() {
                              _showShipping = !_showShipping;
                            });

                            // Apply default values to newly visible shipping fields
                            final currentKeys = _collectVisibleFieldKeys();
                            final newlyVisibleKeys = currentKeys.difference(
                              previousKeys,
                            );
                            if (newlyVisibleKeys.isNotEmpty) {
                              _applyDefaultValuesForSpecificFields(
                                newlyVisibleKeys,
                              );
                            }
                            _previouslyVisibleFieldKeys = currentKeys;
                          },
                        ),
                        Expanded(
                          child: Text(
                            S.of(context).shipToADifferentAddress,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  if (shouldShowShippingFields) ...[
                    _buildSectionTitle(S.of(context).shippingAddress),
                    ..._buildFieldsList(shippingFields),
                  ],
                  if (hasAdditionalFields)
                    ..._buildFieldsList(additionalFields),
                ],
              ),
            ),
          ),
          Align(
            alignment: isDesktopLayout
                ? AlignmentDirectional.centerStart
                : Alignment.center,
            child: BottomCheckoutActions(
              onNext: () async {
                await _validateForm((submitData, cacheData) async {
                  await CheckoutCacheService.saveCheckoutValues(cacheData);

                  var additionalJsonData = getAdditionalJsonData(
                    fieldsManager,
                    submitData,
                  );
                  final additionalFieldLabels = _buildAdditionalFieldLabels(
                    fieldsManager,
                    additionalJsonData,
                  );
                  var billingJsonData = getBillingJsonData(
                    fieldsManager,
                    submitData,
                  );
                  var shippingJsonData = shouldShowShippingFields
                      ? getShippingJsonData(fieldsManager, submitData)
                      : _buildShippingFromBilling(billingJsonData);
                  shippingJsonData = _fillMissingShippingFromBilling(
                    shippingJsonData,
                    billingJsonData,
                  );
                  context.read<CartModel>().setWooCheckoutValues({
                    'billing': billingJsonData,
                    'shipping': shippingJsonData,
                    'additional': additionalJsonData,
                    'additionalFieldLabels': additionalFieldLabels,
                    'shouldShowShipping': shouldShowShippingFields,
                  });
                  _loadShipping();
                  widget.onNext();
                });
              },
              onSave: () async {
                await _validateForm((_, cacheData) async {
                  await CheckoutCacheService.saveCheckoutValues(cacheData);
                  await FlashHelper.message(
                    context,
                    message: S.of(context).yourAddressHasBeenSaved,
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Load Shipping beforehand
  void _loadShipping({bool beforehand = true}) {
    Services().widget.loadShippingMethods(
      context,
      context.read<CartModel>(),
      beforehand,
    );
  }

  Future<void> _validateForm(
    Future<void> Function(
      Map<String, dynamic> submitData,
      Map<String, dynamic> cacheData,
    )
    callback,
  ) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final submitData = _buildSubmitData();
      final cacheData = _buildCacheData(submitData);
      await callback(submitData, cacheData);
    } else {
      await FlashHelper.errorMessage(
        context,
        message: S.of(context).pleaseInput,
      );
    }
  }

  Map<String, dynamic> _buildSubmitData() {
    final visibleKeys = _collectVisibleFieldKeys();
    return {
      for (var entry in _textControllers.entries)
        if (visibleKeys.contains(entry.key) &&
            entry.value.text.trim().isNotEmpty)
          entry.key: entry.value.text,
    };
  }

  Map<String, dynamic> _buildCacheData(Map<String, dynamic> submitData) {
    final nonCacheKeys = _collectNonCacheFieldKeys();
    return {
      for (final entry in submitData.entries)
        if (!nonCacheKeys.contains(entry.key)) entry.key: entry.value,
    };
  }

  Map<String, dynamic> _sanitizeLoadedCacheValues(
    Map<String, dynamic>? values,
  ) {
    if (values == null || values.isEmpty) {
      return const {};
    }

    final nonCacheKeys = _collectNonCacheFieldKeys();
    return {
      for (final entry in values.entries)
        if (!nonCacheKeys.contains(entry.key)) entry.key: entry.value,
    };
  }

  Set<String> _collectNonCacheFieldKeys() {
    return {
      for (final field in _allFields())
        if ((field.key?.isNotEmpty ?? false) &&
            _nonCacheFieldTypes.contains(field.type))
          field.key!,
    };
  }

  Iterable<CheckoutField> _allFields() sync* {
    yield* fieldsManager?.billing ?? <CheckoutField>[];
    yield* fieldsManager?.shipping ?? <CheckoutField>[];
    yield* fieldsManager?.additional ?? <CheckoutField>[];
  }

  Iterable<CheckoutField> _visibleFields() sync* {
    for (final field in fieldsManager?.billing ?? <CheckoutField>[]) {
      if (_shouldShowField(field)) {
        yield field;
      }
    }

    final hasBillingFields =
        (fieldsManager?.billing ?? <CheckoutField>[]).isNotEmpty;
    final hasShippingFields =
        (fieldsManager?.shipping ?? <CheckoutField>[]).isNotEmpty;
    final shouldShowShippingFields =
        hasShippingFields && (!hasBillingFields || _showShipping);

    if (shouldShowShippingFields) {
      for (final field in fieldsManager?.shipping ?? <CheckoutField>[]) {
        if (_shouldShowField(field)) {
          yield field;
        }
      }
    }

    for (final field in fieldsManager?.additional ?? <CheckoutField>[]) {
      if (_shouldShowField(field)) {
        yield field;
      }
    }
  }

  void _applyDefaultValuesForVisibleFields() {
    for (final field in _visibleFields()) {
      final key = field.key;
      if (key == null || key.isEmpty) {
        continue;
      }

      final controller = _textControllers[key];
      final defaultValue = field.defaultValue;
      if (controller == null || defaultValue == null) {
        continue;
      }

      if (controller.text.trim().isNotEmpty || defaultValue.trim().isEmpty) {
        continue;
      }

      controller.text = defaultValue;
    }

    // Update tracking after applying defaults
    _previouslyVisibleFieldKeys = _collectVisibleFieldKeys();
  }

  void _applyDefaultValuesForSpecificFields(Set<String> fieldKeys) {
    for (final field in _visibleFields()) {
      final key = field.key;
      if (key == null || !fieldKeys.contains(key)) {
        continue;
      }

      final controller = _textControllers[key];
      final defaultValue = field.defaultValue;
      if (controller == null || defaultValue == null) {
        continue;
      }

      if (controller.text.trim().isNotEmpty || defaultValue.trim().isEmpty) {
        continue;
      }

      controller.text = defaultValue;
    }
  }

  bool _isNullOrEmpty(dynamic value) {
    if (value == null) {
      return true;
    }
    if (value is String) {
      return value.trim().isEmpty;
    }
    return false;
  }

  Map<String, dynamic> _buildShippingFromBilling(Map<String, dynamic> billing) {
    return {
      for (final fieldName in defaultShippingFields)
        if (billing[fieldName] != null) fieldName: billing[fieldName],
    };
  }

  Map<String, dynamic> _fillMissingShippingFromBilling(
    Map<String, dynamic> shipping,
    Map<String, dynamic> billing,
  ) {
    if (billing.isEmpty) {
      return shipping;
    }

    final merged = <String, dynamic>{...shipping};
    for (final key in defaultShippingFields) {
      final shippingValue = merged[key];
      final billingValue = billing[key];

      if (_isNullOrEmpty(shippingValue) && !_isNullOrEmpty(billingValue)) {
        merged[key] = billingValue;
      }
    }
    return merged;
  }

  Set<String> _collectVisibleFieldKeys() {
    final keys = <String>{};

    for (final field in _visibleFields()) {
      final key = field.key;
      if (key?.isNotEmpty ?? false) {
        keys.add(key!);
      }
    }

    return keys;
  }

  bool _shouldShowField(CheckoutField field) {
    if (!field.conditional) {
      return true;
    }

    final parentKey = field.conditionalParentKey?.trim();
    if (parentKey == null || parentKey.isEmpty) {
      return true;
    }

    final expected = field.conditionalParentValue?.trim() ?? '';
    final parentValue = _textControllers[parentKey]?.text.trim() ?? '';

    if (expected.isEmpty) {
      return parentValue.isNotEmpty;
    }

    if (parentValue == expected) {
      return true;
    }

    // Multi-value controls are usually serialized as comma-separated values.
    final values = parentValue
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return values.contains(expected);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Map<String, String> _buildAdditionalFieldLabels(
    CheckoutFieldsManager? fieldsManager,
    Map<String, dynamic> additionalJsonData,
  ) {
    if (additionalJsonData.isEmpty) {
      return const {};
    }

    final labels = <String, String>{};

    void collect(List<CheckoutField>? fields) {
      for (final field in fields ?? <CheckoutField>[]) {
        final key = field.key;
        final label = field.label?.trim();
        if (key == null || key.isEmpty || label == null || label.isEmpty) {
          continue;
        }

        final prefixedKey = '_$key';
        if (additionalJsonData.containsKey(prefixedKey)) {
          labels[prefixedKey] = label;
        }
      }
    }

    collect(fieldsManager?.additional);
    collect(fieldsManager?.billing);
    collect(fieldsManager?.shipping);

    return labels;
  }

  List<Widget> _buildFieldsList(List<CheckoutField> fields) {
    final visibleFields = fields
        .where((field) => _shouldShowField(field))
        .toList();

    final visibleInputKeys = visibleFields
        .where((field) => isTextInputFieldType(field))
        .map((field) => field.key)
        .whereType<String>()
        .toList();

    return visibleFields.mapIndexed((int index, CheckoutField field) {
      final sourceIndex = fields.indexOf(field);
      final hasNext = index < visibleFields.length - 1;

      final controller = _textControllers[field.key];
      if (isTextInputFieldType(field)) {
        final keyIndex = visibleInputKeys.indexOf(field.key ?? '');
        final nextKey = visibleInputKeys.elementAtOrNull(keyIndex + 1);
        FocusNode? nextFieldFocus;
        if (nextKey != null) {
          nextFieldFocus = _focusNodes[nextKey];
        }

        final textInputField = TextInputField(
          field: field,
          focusNode: _focusNodes[field.key],
          nextFieldFocus: nextFieldFocus,
          controller: controller,
          hasNext: hasNext,
        );

        return _withFieldKey(
          field: field,
          index: sourceIndex,
          child: textInputField,
        );
      }
      switch (field.type) {
        case 'country':
          return _withFieldKey(
            field: field,
            index: sourceIndex,
            child: CountryField(field: field, controller: controller),
          );
        case 'state':
          return _withFieldKey(
            field: field,
            index: sourceIndex,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable:
                  _textControllers[field.countryField] ??
                  const AlwaysStoppedAnimation<TextEditingValue>(
                    TextEditingValue(),
                  ),
              builder: (context, value, child) {
                return StateField(
                  field: field,
                  controller: controller,
                  countryCode: value.text,
                );
              },
            ),
          );
        case 'date':
        case 'time':
        case 'datetime_local':
          return _withFieldKey(
            field: field,
            index: sourceIndex,
            child: DateTimePickerFormField(
              field: field,
              controller: controller,
              validator: (val) {
                return validateField(context, val, field);
              },
            ),
          );
        case 'hidden':
          return _withFieldKey(
            field: field,
            index: sourceIndex,
            child: const SizedBox.shrink(),
          );
        case 'heading':
          return _withFieldKey(
            field: field,
            index: sourceIndex,
            child: HeadingField(field: field),
          );
        case 'file':
          return _withFieldKey(
            field: field,
            index: sourceIndex,
            child: FileUploadFormField(
              field: field,
              controller: controller,
              validator: (val) => validateField(context, val, field),
            ),
          );
        case 'select':
          return _withFieldKey(
            field: field,
            index: sourceIndex,
            child: SelectFormField(
              field: field,
              controller: controller,
              validator: (val) {
                return validateField(context, val, field);
              },
            ),
          );
        case 'radio':
          return _withFieldKey(
            field: field,
            index: sourceIndex,
            child: RadioFormField(
              field: field,
              controller: controller,
              validator: (val) {
                return validateField(context, val, field);
              },
            ),
          );
        case 'checkbox':
          return _withFieldKey(
            field: field,
            index: sourceIndex,
            child: CheckboxFormField(
              field: field,
              controller: controller,
              validator: (val) {
                return validateField(context, val, field);
              },
            ),
          );
        case 'multicheckbox':
        case 'multiselect':
          return _withFieldKey(
            field: field,
            index: sourceIndex,
            child: MultiCheckboxFormField(
              field: field,
              controller: controller,
              validator: (List<String>? val) {
                return validateField(context, val?.join(','), field);
              },
            ),
          );
        case 'colorpicker':
          return _withFieldKey(
            field: field,
            index: sourceIndex,
            child: ColorPickerFormField(
              field: field,
              controller: controller,
              validator: (val) {
                return validateField(context, val, field);
              },
            ),
          );
        default:
          return _withFieldKey(
            field: field,
            index: sourceIndex,
            child: const SizedBox(),
          );
      }
    }).toList();
  }

  Widget _withFieldKey({
    required CheckoutField field,
    required int index,
    required Widget child,
  }) {
    return KeyedSubtree(key: _buildFieldWidgetKey(field, index), child: child);
  }

  Key _buildFieldWidgetKey(CheckoutField field, int index) {
    final rawKey = field.key?.trim();
    if (rawKey?.isNotEmpty ?? false) {
      return ValueKey<String>('checkout_field:$rawKey');
    }

    final fallbackIdentity = field.label?.trim();
    return ValueKey<String>(
      'checkout_field:${field.type}:${fallbackIdentity ?? 'index'}:$index',
    );
  }
}
