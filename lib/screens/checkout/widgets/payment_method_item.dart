import 'package:flutter/material.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:inspireui/extensions/color_extension.dart';

import '../../../common/config.dart';
import '../../../models/index.dart' show PaymentMethod;
import '../../../services/index.dart';

class PaymentMethodItem extends StatelessWidget {
  const PaymentMethodItem({
    super.key,
    required this.paymentMethod,
    this.onSelected,
    this.selectedId,
    this.descWidget,
    this.useDesktopStyle = false,
  });

  final PaymentMethod paymentMethod;
  final Function(String?)? onSelected;
  final String? selectedId;
  final Widget? descWidget;
  final bool useDesktopStyle;

  @override
  Widget build(BuildContext context) {
    final isSelected = paymentMethod.id == selectedId;

    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            onSelected?.call(paymentMethod.id);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColorLight
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(
                        context,
                      ).colorScheme.secondary.withValueOpacity(0.15),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Column(
                children: [
                  Row(
                    children: <Widget>[
                      _SelectionIndicator(isSelected: isSelected),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: [
                                    if (paymentMethod.title != null) ...[
                                      Flexible(
                                        fit: useDesktopStyle
                                            ? FlexFit.tight
                                            : FlexFit.loose,
                                        child: Services().widget
                                            .renderShippingPaymentTitle(
                                              context,
                                              paymentMethod.title!,
                                            ),
                                      ),
                                      const SizedBox(width: 7),
                                    ],
                                    if (kPayments[paymentMethod.id] != null)
                                      FluxImage(
                                        imageUrl: kPayments[paymentMethod.id],
                                        height: 30,
                                      )
                                    else if (paymentMethod.image?.isNotEmpty ??
                                        false)
                                      FluxImage(
                                        imageUrl: paymentMethod.image!,
                                        height: 30,
                                      ),
                                  ],
                                ),
                                if (paymentMethod.description != null)
                                  if (paymentMethod.id == selectedId) ...[
                                    const SizedBox(height: 15),
                                    HtmlWidget(paymentMethod.description!),
                                  ],
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  ?descWidget,
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: useDesktopStyle ? 15 : 10),
      ],
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).colorScheme.secondary.withValueOpacity(0.35);
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            )
          : null,
    );
  }
}
