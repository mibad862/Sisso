import 'package:flutter/cupertino.dart';

import '../../../common/config.dart';
import '../../../screens/checkout/widgets/shipping_address.dart';
import '../../../services/service_config.dart';
import '../views/checkout_form.dart';

mixin CheckoutFieldManagerServiceMixin {
  Widget renderCheckoutShippingAddress({required VoidCallback onNext}) {
    if (kAdvanceConfig.enableWooCheckoutFieldManager &&
        ServerConfig().isWooPluginSupported) {
      return CheckoutForm(onNext: onNext);
    } else {
      return ShippingAddress(onNext: onNext);
    }
  }
}
