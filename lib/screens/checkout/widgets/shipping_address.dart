import 'package:collection/collection.dart' show IterableExtension;
import 'package:country_pickers/country.dart' as picker_country;
import 'package:country_pickers/country_pickers.dart' as picker;
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/config/models/address_field_config.dart';
import '../../../common/constants.dart';
import '../../../common/error_codes/error_codes.dart';
import '../../../common/extensions/dialog_ext.dart';
import '../../../common/tools/flash.dart';
import '../../../data/boxes.dart';
import '../../../models/index.dart'
    show Address, AppModel, CartModel, City, Country, CountryState, UserModel;
import '../../../modules/dynamic_layout/helper/helper.dart';
import '../../../services/index.dart';
import '../../../widgets/common/checkout/checkout_widgets.dart';
import '../choose_address_screen.dart';

part 'shipping_address_extension.dart';

class ShippingAddress extends StatefulWidget {
  final Function? onNext;

  const ShippingAddress({this.onNext});

  @override
  State<ShippingAddress> createState() => _ShippingAddressState();
}

class _ShippingAddressState extends State<ShippingAddress> {
  String get langCode => Provider.of<AppModel>(context, listen: false).langCode;

  bool get isDesktopLayout => Layout.isDisplayDesktop(context);

  bool _showSelectAddress = false;

  final _formKey = GlobalKey<FormState>();

  final Map<int, AddressFieldType> _fieldPosition = {};

  final Map<int, AddressFieldConfig> _configs = {};

  final Map<AddressFieldType, TextEditingController> _textControllers = {
    AddressFieldType.firstName: TextEditingController(),
    AddressFieldType.lastName: TextEditingController(),
    AddressFieldType.phoneNumber: TextEditingController(),
    AddressFieldType.email: TextEditingController(),
    AddressFieldType.country: TextEditingController(),
    AddressFieldType.state: TextEditingController(),
    AddressFieldType.city: TextEditingController(),
    AddressFieldType.apartment: TextEditingController(),
    AddressFieldType.block: TextEditingController(),
    AddressFieldType.street: TextEditingController(),
    AddressFieldType.zipCode: TextEditingController(),
  };

  final Map<AddressFieldType, FocusNode> _focusNodes = {
    AddressFieldType.firstName: FocusNode(),
    AddressFieldType.lastName: FocusNode(),
    AddressFieldType.phoneNumber: FocusNode(),
    AddressFieldType.email: FocusNode(),
    AddressFieldType.state: FocusNode(),
    AddressFieldType.city: FocusNode(),
    AddressFieldType.apartment: FocusNode(),
    AddressFieldType.block: FocusNode(),
    AddressFieldType.street: FocusNode(),
    AddressFieldType.zipCode: FocusNode(),
  };

  Address address = const Address();
  List<Country> countries = [];
  List<CountryState> states = [];
  List<City> cities = [];

  PhoneNumber? initialPhoneNumber;

  @override
  void dispose() {
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    /// Init field positions.
    for (var config in Configurations.addressFields) {
      final index = _fieldPosition.values.length;
      _configs[index] = config;
      _fieldPosition[index] = config.type;
    }

    /// Pre-fill the address fields.
    WidgetsBinding.instance.endOfFrame.then((_) async {
      /// Load saved addresses.
      final addressValue = await context.read<CartModel>().getAddress();
      if (addressValue != null) {
        updateAddress(addressValue);
      } else {
        var user = context.read<UserModel>().user;
        setState(() {
          address = Address(
            country: kPaymentConfig.defaultCountryISOCode,
            state: kPaymentConfig.defaultStateISOCode,
            firstName: user?.firstName,
            lastName: user?.lastName,
            email: user?.email,
          );
          _textControllers[AddressFieldType.country]?.text =
              address.country ?? '';
          _textControllers[AddressFieldType.state]?.text = address.state ?? '';
          if (user != null) {
            loadUserInfoFromAddress(address);
          }
        });
      }

      /// Init default fields.
      for (var field in _configs.values) {
        if ([
          AddressFieldType.searchAddress,
          AddressFieldType.selectAddress,
          AddressFieldType.country,
          AddressFieldType.state,
        ].contains(field.type)) {
          /// Not support default value.
          continue;
        }

        /// Replace current value with default value.
        /// Force to use default value for non-editable field.
        if (field.defaultValue.isNotEmpty && !field.editable) {
          _textControllers[field.type]?.text = field.defaultValue;
          onTextFieldSaved(field.defaultValue, field.type);
        }

        /// When the field is editable, replacing only when it's empty.
        if (field.defaultValue.isNotEmpty &&
            field.editable &&
            (_textControllers[field.type]?.text.isEmpty ?? false)) {
          _textControllers[field.type]?.text = field.defaultValue;
          onTextFieldSaved(field.defaultValue, field.type);
        }
      }

      if (kPhoneNumberConfig.enablePhoneNumberValidation) {
        /// Load phone number.
        try {
          final phoneNumber = _textControllers[AddressFieldType.phoneNumber]
              ?.text
              .trim();
          if (phoneNumber?.isNotEmpty ?? false) {
            initialPhoneNumber = await PhoneNumber.getParsablePhoneNumber(
              PhoneNumber(
                dialCode: kPhoneNumberConfig.dialCodeDefault,
                isoCode: kPhoneNumberConfig.countryCodeDefault,
                phoneNumber: phoneNumber,
              ),
            );
          }
          // In case the phone number is empty, a default `PhoneNumber`
          // object will still be assigned to initialize `dial Code` and
          // `iso Code` for the validator
          initialPhoneNumber ??= PhoneNumber(
            dialCode: kPhoneNumberConfig.dialCodeDefault,
            isoCode: kPhoneNumberConfig.countryCodeDefault,
          );
        } catch (e, trace) {
          printError(e, trace);
        }
      }

      /// Load country list.
      countries = await Services().widget.loadCountries() ?? [];
      var country = countries.firstWhereOrNull(
        (element) =>
            element.id == address.country || element.code == address.country,
      );
      if (country == null) {
        if (countries.isNotEmpty) {
          country = countries[0];
          address = address.copyWith(country: country.code);
        } else {
          country = Country.fromConfig(address.country, null, null, []);
        }
      } else {
        address = address.copyWith(
          country: country.code,
          countryId: country.id,
        );
      }
      _textControllers[AddressFieldType.country]?.text = country.code!;
      refresh();

      /// Load states.
      states = await Services().widget.loadStates(country);
      refresh();

      /// Load cities.
      var state = states.firstWhereOrNull(
        (element) =>
            element.id == address.state || element.code == address.state,
      );
      if (state != null) {
        cities = await Services().widget.loadCities(country, state) ?? [];
        var city = cities.firstWhereOrNull(
          (element) => element.name == address.city,
        );

        /// Load zipCode
        if (city != null) {
          var zipCode = await Services().widget.loadZipCode(
            country,
            state,
            city,
          );
          if (zipCode != null) {
            /// Override the default value with this value
            address = address.copyWith(zipCode: zipCode);
            _textControllers[AddressFieldType.zipCode]?.text = zipCode;
          }
        }
        refresh();
      }
    });
  }

  void _reloadState() async {
    picker_country.Country country;
    final currentCountry = address.country ?? '';
    try {
      country = picker.CountryPickerUtils.getCountryByIsoCode(currentCountry);
      address = address.copyWith(country: country.isoCode);
    } catch (_) {
      country = picker.CountryPickerUtils.getCountryByName(currentCountry);
      address = address.copyWith(country: country.isoCode);
    }
    states = await Services().widget.loadStates(
      Country(id: country.isoCode, name: country.name),
    );
    refresh();
  }

  void _onShowSelectAddressForDesktop() {
    setState(() {
      _showSelectAddress = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _renderFormItem();
    final form = Form(
      key: _formKey,
      child: AutofillGroup(
        child: ShippingAddressLayout(
          children: List.generate(
            items.length,
            (index) => (
              items[index],
              _fieldPosition[index] ?? AddressFieldType.unknown,
              _configs[index]?.visible ?? true,
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isDesktopLayout) ...[
          if (_showSelectAddress) ...[
            ChooseAddressScreen(
              ChooseAddressArguments(
                address: address,
                isModal: true,
                callback: (p0) {
                  setState(() {
                    _showSelectAddress = false;
                  });
                  if (p0 != null) {
                    updateAddress(p0);
                    _reloadState();
                  }
                },
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              child: Row(
                children: [
                  Text(
                    S.of(context).addNewAddress,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      height: 28 / 18,
                    ),
                  ),
                  const Spacer(),
                  _renderSelectAddressButton(),
                ],
              ),
            ),
            form,
          ],
        ] else
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 50.0,
                ),
                child: form,
              ),
            ),
          ),
        if (_showSelectAddress == false) ...[
          Align(
            alignment: isDesktopLayout
                ? AlignmentDirectional.centerStart
                : Alignment.center,
            child: BottomCheckoutActions(
              onNext: _onNext,
              onSave: () {
                if (!checkToSave()) return;
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  context.read<CartModel>().setAddress(address);
                  saveDataToLocal();
                } else {
                  FlashHelper.errorMessage(
                    context,
                    message: S.of(context).pleaseInput,
                  );
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  List<Widget> _renderFormItem() {
    return List.generate(_fieldPosition.length, (index) {
      final isVisible = _configs[index]?.visible ?? true;
      if (!isVisible) {
        return const SizedBox();
      }

      final currentFieldType =
          _fieldPosition[index] ?? AddressFieldType.unknown;

      if (currentFieldType == AddressFieldType.country) {
        return CountrySelector(
          countries: countries,
          currentCountryText: _textControllers[AddressFieldType.country]?.text,
          onChanged: (Country country) async {
            _textControllers[AddressFieldType.country]?.text =
                country.code ?? country.id ?? '';
            address = address.copyWith(
              country: country.id,
              countryId: country.id,
            );
            refresh();
            states = await Services().widget.loadStates(country);
            address = address.copyWith(zipCode: '');
            _textControllers[AddressFieldType.zipCode]?.text = '';
            refresh();
          },
        );
      }

      if (currentFieldType == AddressFieldType.state && states.isNotEmpty) {
        return StateSelector(
          states: states,
          state: address.state,
          onChanged: (CountryState state) async {
            address = address.copyWith(state: state.id);
            final country = Country(id: address.country);
            cities = await Services().widget.loadCities(country, state) ?? [];
            address = address.copyWith(zipCode: '');
            _textControllers[AddressFieldType.zipCode]?.text = '';
            refresh();
          },
        );
      }

      if (currentFieldType == AddressFieldType.city && cities.isNotEmpty) {
        return CitySelector(
          cities: cities,
          address: address,
          config: _configs[index],
          type: _fieldPosition[index],
          onChanged: (City city) async {
            address = address.copyWith(city: city.id);
            final country = Country(id: address.country);
            final state = CountryState(id: address.state);
            final zipCode = await Services().widget.loadZipCode(
              country,
              state,
              city,
            );
            if (zipCode != null) {
              address = address.copyWith(zipCode: zipCode);
              _textControllers[AddressFieldType.zipCode]?.text = zipCode;
            }
            refresh();
          },
        );
      }

      if (currentFieldType == AddressFieldType.searchAddress) {
        if (kPaymentConfig.allowSearchingAddress && kGoogleApiKey.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: SearchAddressButton(
              address: address,
              onChanged: (Address address) async {
                loadAddressFields(address);
                final c = Country(id: address.country, name: address.country);
                states = await Services().widget.loadStates(c);
                setState(() {});
              },
            ),
          );
        }
        return const SizedBox();
      }

      if (currentFieldType == AddressFieldType.selectAddress) {
        return Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: SelectAddressButton(
            address: address,
            onChanged: updateAddress,
          ),
        );
      }

      final currentFieldController = _textControllers[currentFieldType];
      final currentFieldFocusNode = _focusNodes[currentFieldType];

      var hasNext = false;
      var nextFieldIndex = index + 1;
      AddressFieldType? nextFieldType;
      FocusNode? nextFieldFocus;

      while (nextFieldIndex < _fieldPosition.length) {
        nextFieldType = _fieldPosition[nextFieldIndex];
        nextFieldFocus = _focusNodes[nextFieldType];
        if (nextFieldType == AddressFieldType.country ||
            (nextFieldType == AddressFieldType.state && states.isNotEmpty) ||
            (nextFieldType == AddressFieldType.city && cities.isNotEmpty)) {
          hasNext = false;
          break;
        }
        if (nextFieldFocus != null) {
          hasNext = true;
          break;
        }
        nextFieldIndex++;
      }

      if (currentFieldType == AddressFieldType.phoneNumber &&
          kPhoneNumberConfig.enablePhoneNumberValidation) {
        return PhoneInput(
          /// Auto focus first field if it's empty.
          autoFocus:
              index == 0 && (currentFieldController?.text.isEmpty ?? false),
          config: _configs[index],
          focusNode: currentFieldFocusNode,
          nextFieldFocus: nextFieldFocus,
          textFieldController: currentFieldController,
          hasNext: hasNext,
          initialPhoneNumber: initialPhoneNumber,
          type: currentFieldType,
          onTextFieldSaved: (phoneNumber, type) {
            onTextFieldSaved(phoneNumber, type);
          },
        );
      }

      return TextInput(
        /// Auto focus first field if it's empty.
        autoFocus:
            index == 0 && (currentFieldController?.text.isEmpty ?? false),
        focusNode: currentFieldFocusNode,
        nextFieldFocus: nextFieldFocus,
        textFieldController: currentFieldController,
        hasNext: hasNext,
        keyboardType: getKeyboardType(currentFieldType),
        readOnly: isFieldReadOnly(_configs[index]),
        label: currentFieldType.getTitle(context),
        autofillHints: currentFieldType.autofillHint != null
            ? ['${currentFieldType.autofillHint}']
            : null,
        validator: (val) {
          if (_configs[index] == null) {
            return null;
          }
          return validateField(
            context,
            val,
            _configs[index]!,
            currentFieldType,
          );
        },
        onTextFieldSaved: (value) {
          onTextFieldSaved(value, currentFieldType);
        },
      );
    });
  }
}

class ShippingAddressLayout extends StatelessWidget {
  const ShippingAddressLayout({super.key, required this.children});

  final List<(Widget, AddressFieldType?, bool)> children;

  @override
  Widget build(BuildContext context) {
    final isDesktopLayout = Layout.isDisplayDesktop(context);
    if (isDesktopLayout) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: List.generate(children.length, (index) {
                final item = children[index];
                if ([
                      AddressFieldType.firstName,
                      AddressFieldType.phoneNumber,
                      AddressFieldType.country,
                      AddressFieldType.state,
                      AddressFieldType.street,
                    ].contains(item.$2) &&
                    item.$3) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: item.$1,
                  );
                }

                return const SizedBox();
              }),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: List.generate(children.length, (index) {
                final item = children[index];
                if ([
                      AddressFieldType.lastName,
                      AddressFieldType.email,
                      AddressFieldType.city,
                      AddressFieldType.zipCode,
                      AddressFieldType.apartment,
                      AddressFieldType.block,
                    ].contains(item.$2) &&
                    item.$3) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: item.$1,
                  );
                }

                return const SizedBox();
              }),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((e) => e.$1).toList(),
    );
  }
}
