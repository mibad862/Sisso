import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';

import '../../../common/constants.dart';
import '../../../models/entities/address.dart';
import '../../../screens/checkout/choose_address_screen.dart';

class SelectAddressButton extends StatelessWidget {
  const SelectAddressButton({
    super.key,
    required this.address,
    required this.onChanged,
  });
  final Address address;
  final Function(Address) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ButtonTheme(
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: theme.colorScheme.secondary,
          backgroundColor: theme.primaryColorLight,
          elevation: 0.0,
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            RouteList.selectAddress,
            arguments: ChooseAddressArguments(
              address: address,
              callback: (p0) {
                if (p0 != null) {
                  onChanged(p0);
                }
              },
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10.0,
          children: <Widget>[
            const Icon(CupertinoIcons.person_crop_square, size: 16),
            Text(S.of(context).selectAddress.toUpperCase()),
          ],
        ),
      ),
    );
  }
}
