import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';

import '../../../common/config.dart';
import '../../../screens/checkout/widgets/checkout_action.dart';

class BottomCheckoutActions extends StatelessWidget {
  const BottomCheckoutActions({super.key, this.onNext, this.onSave});
  final void Function()? onNext;
  final void Function()? onSave;

  @override
  Widget build(BuildContext context) {
    final textButton = kPaymentConfig.enableShipping
        ? S.of(context).continueToShipping
        : kPaymentConfig.enablePreview
        ? S.of(context).continueToPreview
        : S.of(context).continueToPayment;

    return CheckoutActionWidget(
      labelPrimary: textButton,
      iconPrimary: Icons.local_shipping_outlined,
      onTapPrimary: onNext,
      labelSecondary: S.of(context).saveAddress,
      iconSecondary: CupertinoIcons.plus_app,
      onTapSecondary: onSave,
    );
  }
}
