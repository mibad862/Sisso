import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';

import '../../../common/config/models/address_field_config.dart';
import '../../../models/entities/address.dart';
import '../../../models/entities/city.dart';
import 'helpers/checkout_helper.dart';

class CitySelector extends StatelessWidget {
  const CitySelector({
    super.key,
    required this.cities,
    required this.address,
    this.config,
    this.type,
    required this.onChanged,
  });
  final List<City> cities;
  final Address address;
  final AddressFieldConfig? config;
  final AddressFieldType? type;
  final Function(City) onChanged;

  @override
  Widget build(BuildContext context) {
    var items = <DropdownMenuItem>[];
    for (var item in cities) {
      items.add(DropdownMenuItem(value: item.id, child: Text(item.name!)));
    }
    String? value;

    Object? firstCity = cities.firstWhereOrNull(
      (o) => o.name.toString() == address.city.toString(),
    );

    if (firstCity != null) {
      value = address.city;
    }
    return DropdownButtonFormField<dynamic>(
      items: items,
      initialValue: value,
      validator: (val) {
        if (config == null) {
          return null;
        }
        return validateField(
          context,
          val,
          config!,
          type ?? AddressFieldType.unknown,
        );
      },
      onChanged: (dynamic val) async {
        final city = City(id: val, name: val);
        onChanged(city);
      },
      isExpanded: true,
      itemHeight: 70,
      hint: Text(S.of(context).city),
    );
  }
}
