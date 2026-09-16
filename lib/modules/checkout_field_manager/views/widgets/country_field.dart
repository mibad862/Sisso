import 'package:flutter/material.dart';

import '../../../../models/entities/country.dart';
import '../../../../widgets/common/checkout/country_selector.dart';
import '../../models/checkout_field.dart';
import '../mixin/checkout_countries_loader_mixin.dart';

class CountryField extends StatefulWidget {
  const CountryField({super.key, required this.field, this.controller});
  final CheckoutField field;
  final TextEditingController? controller;

  @override
  State<CountryField> createState() => _CountryFieldState();
}

class _CountryFieldState extends State<CountryField>
    with CheckoutCountriesLoaderMixin {
  @override
  Widget build(BuildContext context) {
    return CountrySelector(
      countries: countries ?? [],
      currentCountryText: widget.controller?.text,
      onChanged: (Country country) async {
        final currentText = country.code ?? country.id ?? '';
        widget.controller?.text = currentText;

        // Trigger rebuild to show country name immediately
        setState(() {});
      },
    );
  }

  @override
  String get countryKey => widget.field.key ?? '';
}
