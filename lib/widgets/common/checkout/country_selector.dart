import 'package:country_pickers/country.dart' as picker_country;
import 'package:country_pickers/country_pickers.dart' as picker;
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';

import '../../../common/theme/colors.dart';
import '../../../models/entities/country.dart';
import '../../../modules/dynamic_layout/helper/helper.dart';

class CountrySelector extends StatelessWidget {
  const CountrySelector({
    super.key,
    required this.countries,
    this.currentCountryText,
    required this.onChanged,
  });
  final List<Country> countries;
  final String? currentCountryText;
  final Function(Country country) onChanged;

  @override
  Widget build(BuildContext context) {
    final isDesktopLayout = Layout.isDisplayDesktop(context);
    var countryName = S.of(context).country;
    final currentCountry = currentCountryText ?? '';
    if (currentCountry.isNotEmpty) {
      try {
        if (countries.isEmpty) {
          countryName = picker.CountryPickerUtils.getCountryByIsoCode(
            currentCountry,
          ).name;
        } else {
          countryName = countries
              .firstWhere((element) => element.code == currentCountry)
              .name!;
        }
      } catch (e) {
        countryName = S.of(context).country;
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktopLayout == false) ...[
          const SizedBox(height: 10),
          Text(
            S.of(context).country,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: Colors.grey,
            ),
          ),
        ],
        (countries.length == 1)
            ? Text(countryName, style: const TextStyle(fontSize: 18))
            : DropdownStyleWidget(
                countryName: countryName,
                onTap: () => _openCountryPickerDialog(context),
              ),
      ],
    );
  }

  void _openCountryPickerDialog(BuildContext context) => showDialog(
    context: context,
    useRootNavigator: false,
    builder: (contextBuilder) => countries.isEmpty
        ? Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.pink),
            child: SizedBox(
              height: 500,
              child: picker.CountryPickerDialog(
                titlePadding: const EdgeInsets.all(8.0),
                contentPadding: const EdgeInsets.all(2.0),
                searchCursorColor: Colors.pinkAccent,
                searchInputDecoration: InputDecoration(
                  hintText: S.of(context).search,
                ),
                isSearchable: true,
                title: Text(S.of(context).country),
                onValuePicked: (picker_country.Country country) {
                  var c = Country(id: country.isoCode, name: country.name);
                  onChanged(c);
                },
                itemBuilder: (country) {
                  return Row(
                    children: <Widget>[
                      picker.CountryPickerUtils.getDefaultFlagImage(country),
                      const SizedBox(width: 8.0),
                      Expanded(child: Text(country.name)),
                    ],
                  );
                },
              ),
            ),
          )
        : Dialog(
            child: CountrySelectorWidget(
              countries: countries,
              onTap: (Country country) async {
                onChanged(country);
                Navigator.pop(contextBuilder);
              },
            ),
          ),
  );
}

class CountrySelectorWidget extends StatefulWidget {
  const CountrySelectorWidget({super.key, this.countries, required this.onTap});

  final List<Country>? countries;
  final void Function(Country) onTap;

  @override
  State<CountrySelectorWidget> createState() => _CountrySelectorWidgetState();
}

class _CountrySelectorWidgetState extends State<CountrySelectorWidget> {
  late final _listCountry = List<Country>.from(widget.countries ?? []);
  late final _listCountryShow = List<Country>.from(_listCountry);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.7,
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              S.of(context).country,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          TextFormField(
            decoration: InputDecoration(hintText: S.of(context).country),
            onChanged: (value) {
              setState(() {
                final listItem = List<Country>.from(_listCountry);
                if (value.isNotEmpty) {
                  listItem.removeWhere((element) {
                    final valueCompare = value.toLowerCase();
                    final notContainsName =
                        element.name!.toLowerCase().contains(valueCompare) ==
                        false;

                    final notContainsIsoCode =
                        element.code!.toLowerCase().contains(valueCompare) ==
                        false;

                    return notContainsIsoCode && notContainsName;
                  });
                }

                _listCountryShow
                  ..clear()
                  ..addAll(listItem);
              });
            },
          ),
          const SizedBox(height: 5),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(_listCountryShow.length, (index) {
                  return GestureDetector(
                    onTap: () async {
                      widget.onTap(_listCountryShow[index]);
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: _listCountryShow[index].icon != null
                          ? SizedBox(
                              height: 30,
                              width: 50,
                              child: FluxImage(
                                imageUrl: _listCountryShow[index].icon!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : (_listCountryShow[index].code != null
                                ? Image.asset(
                                    picker
                                        .CountryPickerUtils.getFlagImageAssetPath(
                                      _listCountryShow[index].code!,
                                    ),
                                    height: 30,
                                    width: 50,
                                    fit: BoxFit.fill,
                                    package: 'country_pickers',
                                  )
                                : const SizedBox(
                                    height: 30,
                                    width: 50,
                                    child: Icon(Icons.streetview),
                                  )),
                      title: Text(_listCountryShow[index].name!),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DropdownStyleWidget extends StatelessWidget {
  const DropdownStyleWidget({super.key, required this.countryName, this.onTap});

  final String countryName;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    if (Layout.isDisplayDesktop(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              S.of(context).country,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 20 / 14,
              ),
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Container(
              height: 51,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).colorScheme.surface,
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      countryName,
                      style: const TextStyle(fontSize: 17.0),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    countryName,
                    style: const TextStyle(fontSize: 17.0),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          const Divider(height: 1, color: kGrey900),
        ],
      ),
    );
  }
}
