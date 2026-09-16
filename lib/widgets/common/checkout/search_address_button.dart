import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../models/index.dart';
import '../place_picker.dart';

class SearchAddressButton extends StatelessWidget {
  const SearchAddressButton({
    super.key,
    required this.address,
    required this.onChanged,
  });
  final Address address;
  final Function(Address) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: ButtonTheme(
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.colorScheme.secondary,
                backgroundColor: theme.primaryColorLight,
                elevation: 0.0,
              ),
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlacePicker(
                      kIsWeb
                          ? kGoogleApiKey.web
                          : isIos
                          ? kGoogleApiKey.ios
                          : kGoogleApiKey.android,
                    ),
                  ),
                );

                if (result is LocationResult) {
                  var updatedAddress = address.copyWith(
                    country: result.country,
                    street: result.street,
                    state: result.state,
                    city: result.city,
                    zipCode: result.zip,
                  );

                  final latitude = result.latLng?.latitude;
                  final longitude = result.latLng?.longitude;
                  if (latitude != null && longitude != null) {
                    updatedAddress = updatedAddress.copyWith(
                      mapUrl:
                          'https://maps.google.com/maps?q=$latitude,$longitude&output=embed',
                      latitude: latitude.toString(),
                      longitude: longitude.toString(),
                    );
                  }

                  onChanged(updatedAddress);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(CupertinoIcons.arrow_up_right_diamond, size: 18),
                  const SizedBox(width: 10.0),
                  Text(S.of(context).searchingAddress.toUpperCase()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
