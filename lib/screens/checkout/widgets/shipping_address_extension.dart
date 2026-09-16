part of 'shipping_address.dart';

extension on _ShippingAddressState {
  void updateAddress(Address newAddress) {
    address = newAddress;
    loadUserInfoFromAddress(newAddress);
    loadAddressFields(address);
  }

  void loadUserInfoFromAddress(Address address) {
    _textControllers[AddressFieldType.firstName]?.text =
        address.firstName?.trim() ?? '';
    _textControllers[AddressFieldType.lastName]?.text =
        address.lastName?.trim() ?? '';
    _textControllers[AddressFieldType.phoneNumber]?.text =
        address.phoneNumber?.trim() ?? '';
    _textControllers[AddressFieldType.email]?.text =
        address.email?.trim() ?? '';
  }

  void loadAddressFields(Address address) {
    _textControllers[AddressFieldType.country]?.text =
        address.country?.trim() ?? '';
    _textControllers[AddressFieldType.state]?.text =
        address.state?.trim() ?? '';
    _textControllers[AddressFieldType.city]?.text = address.city?.trim() ?? '';
    _textControllers[AddressFieldType.apartment]?.text =
        address.apartment?.trim() ?? '';
    _textControllers[AddressFieldType.block]?.text =
        address.block?.trim() ?? '';
    _textControllers[AddressFieldType.street]?.text =
        address.street?.trim() ?? '';
    _textControllers[AddressFieldType.zipCode]?.text =
        address.zipCode?.trim() ?? '';
    refresh();
  }

  bool checkToSave() {
    var listAddress = <Address>[];
    var data = UserBox().addresses;
    if (data.isNotEmpty) {
      listAddress.addAll(data);
    }
    for (var local in listAddress) {
      final isNotExistedInLocal = local.isDiff(
        Address(
          city: _textControllers[AddressFieldType.city]?.text,
          street: _textControllers[AddressFieldType.street]?.text,
          zipCode: _textControllers[AddressFieldType.zipCode]?.text,
          state: _textControllers[AddressFieldType.state]?.text,
        ),
      );

      if (isNotExistedInLocal) {
        continue;
      }

      context.showFluxDialogText(
        title: S.of(context).yourAddressExistYourLocal,
        secondaryAction: S.of(context).ok,
      );

      return false;
    }
    return true;
  }

  void saveDataToLocal() {
    var listAddress = <Address>[];
    final address = this.address;
    listAddress.add(address);
    var listData = UserBox().addresses;
    if (listData.isNotEmpty) {
      for (var item in listData) {
        listAddress.add(item);
      }
    }
    UserBox().addresses = listAddress;
    FlashHelper.message(
      context,
      message: S.of(context).yourAddressHasBeenSaved,
    );
  }

  /// Load Shipping beforehand
  void _loadShipping({bool beforehand = true}) {
    Services().widget.loadShippingMethods(
      context,
      Provider.of<CartModel>(context, listen: false),
      beforehand,
    );
  }

  /// on tap to Next Button
  void _onNext({bool ignoreFormValidation = false}) async {
    final cartModel = context.read<CartModel>();

    try {
      final isFormValid =
          ignoreFormValidation || _formKey.currentState!.validate();

      if (isFormValid) {
        if (ignoreFormValidation == false) _formKey.currentState!.save();

        await Services().widget.updateCartBuyerIdentity(
          cartModel: cartModel,
          address: address,
        );

        cartModel.setAddress(address);
        _loadShipping(beforehand: false);
        widget.onNext!();
      } else {
        await FlashHelper.errorMessage(
          context,
          message: S.of(context).pleaseInput,
        );
      }
    } catch (e) {
      final errorMessage = e is ErrorType
          ? e.getMessage(context)
          : e.toString();
      await FlashHelper.errorMessage(context, message: errorMessage);
    }
  }

  void onTextFieldSaved(String? value, AddressFieldType type) {
    switch (type) {
      case AddressFieldType.firstName:
        address = address.copyWith(firstName: value);
        break;
      case AddressFieldType.lastName:
        address = address.copyWith(lastName: value);
        break;
      case AddressFieldType.phoneNumber:
        address = address.copyWith(phoneNumber: value);
        break;
      case AddressFieldType.email:
        address = address.copyWith(email: value);
        break;
      case AddressFieldType.country:
        address = address.copyWith(country: value);
        break;
      case AddressFieldType.state:
        address = address.copyWith(state: value);
        break;
      case AddressFieldType.city:
        address = address.copyWith(city: value);
        break;
      case AddressFieldType.apartment:
        address = address.copyWith(apartment: value);
        break;
      case AddressFieldType.block:
        address = address.copyWith(block: value);
        break;
      case AddressFieldType.street:
        address = address.copyWith(street: value);
        break;
      case AddressFieldType.zipCode:
        address = address.copyWith(zipCode: value?.trim());
        break;
      case AddressFieldType.company:
        address = address.copyWith(company: value);
        break;

      /// Unsupported.
      case AddressFieldType.searchAddress:
      case AddressFieldType.selectAddress:
      case AddressFieldType.unknown:
        break;
    }
  }

  Widget _renderSelectAddressButton() => GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: _onShowSelectAddressForDesktop,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.person_crop_square,
            size: 16,
            color: Colors.blue[800],
          ),
          const SizedBox(width: 4),
          Text(
            S.of(context).selectAddress,
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}
