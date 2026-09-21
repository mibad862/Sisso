import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/tools.dart';
import '../../../models/index.dart'
    show AppModel, OrderStatus, UserModel, Order, Address;
import '../../../services/index.dart';
import '../../../widgets/common/loading_body.dart';
import '../../base_screen.dart';
import '../../checkout/booking_confirmation_screen.dart';
import '../../checkout/widgets/success.dart';
import '../models/order_history_detail_model.dart';
import 'widgets/order_notes.dart';
import 'widgets/order_total.dart';
import 'widgets/order_tracking.dart';
import 'widgets/product_order.dart';

class OrderDetailArguments {
  OrderHistoryDetailModel model;
  bool disableReview;

  OrderDetailArguments({required this.model, this.disableReview = false});
}

class OrderHistoryDetailScreen extends StatefulWidget {
  final bool enableReorder;
  final bool disableReview;

  const OrderHistoryDetailScreen({
    this.enableReorder = true,
    this.disableReview = false,
  });

  @override
  BaseScreen<OrderHistoryDetailScreen> createState() =>
      _OrderHistoryDetailScreenState();
}

class _OrderHistoryDetailScreenState
    extends BaseScreen<OrderHistoryDetailScreen> {
  OrderHistoryDetailModel get orderHistoryModel =>
      Provider.of<OrderHistoryDetailModel>(context, listen: false);

  bool _isHttpUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Widget _buildAdditionalInfoValue(BuildContext context, String value) {
    final theme = Theme.of(context);

    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.secondary,
    );

    final isUrl = _isHttpUrl(value);

    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: isUrl ? () => Tools.launchURL(value) : null,
        child: Text(
          isUrl
              ? Uri.decodeComponent(
                  Uri.tryParse(value)?.pathSegments.lastOrNull ?? value,
                )
              : value,
          style: baseStyle?.copyWith(
            color: isUrl
                ? theme.colorScheme.primary
                : theme.colorScheme.secondary,
            decoration: isUrl ? TextDecoration.underline : null,
          ),
        ),
      ),
    );
  }

  Widget _buildAddressInfoCard(BuildContext context, Address address) {
    final theme = Theme.of(context);
    final fields = <Widget>[
      _buildAddressInfoRow(
        context,
        icon: Icons.person_outline,
        label: S.of(context).firstName,
        value: address.firstName,
      ),
      _buildAddressInfoRow(
        context,
        icon: Icons.person_outline,
        label: S.of(context).lastName,
        value: address.lastName,
      ),
      _buildAddressInfoRow(
        context,
        icon: Icons.email_outlined,
        label: S.of(context).email,
        value: address.email,
        onTap: address.email?.trim().isNotEmpty == true
            ? () => Tools.launchURL('mailto:${address.email!.trim()}')
            : null,
      ),
      _buildAddressInfoRow(
        context,
        icon: Icons.phone_outlined,
        label: S.of(context).phone,
        value: address.phoneNumber,
        onTap: address.phoneNumber?.trim().isNotEmpty == true
            ? () => Tools.launchURL('tel:${address.phoneNumber!.trim()}')
            : null,
      ),
      _buildAddressInfoRow(
        context,
        icon: Icons.location_on_outlined,
        label: S.of(context).address,
        value: address.fullInfoAddress,
      ),
    ].where((widget) => widget is! SizedBox).toList();

    if (fields.isEmpty) {
      return Text(S.of(context).noData, style: theme.textTheme.bodyMedium);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: fields,
      ),
    );
  }

  Widget _buildAddressInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String? value,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      color: onTap != null
          ? theme.colorScheme.primary
          : theme.colorScheme.secondary,
      decoration: onTap != null ? TextDecoration.underline : null,
      fontWeight: FontWeight.w500,
    );

    return Row(
      spacing: 8.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: theme.colorScheme.secondary),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: Text(text, style: valueStyle),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    super.afterFirstLayout(context);
    orderHistoryModel.getOrderNote();
  }

  void _cancelOrder() async {
    final confirmed = await context.showFluxDialogConfirm(
      title: S.of(context).cancelOrder,
      body: S.of(context).areYouSureCancelOrder,
      primaryAsDestructiveAction: true,
    );
    if (confirmed) {
      try {
        await orderHistoryModel.cancelOrder();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).cancelOrderSuccess)),
        );
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).cancelOrderFailed)),
        );
      }
    }
  }

  void _handlePayment(Order? order) {
    orderHistoryModel.reloadCurrentOrder();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<OrderHistoryDetailModel>(
      builder: (context, model, child) {
        final order = model.order;
        final currencyCode =
            order.currencyCode ?? Provider.of<AppModel>(context).currencyCode;
        final currencyRate = (order.currencyCode?.isEmpty ?? true)
            ? Provider.of<AppModel>(context).currencyRate
            : null;
        final loggedIn = Provider.of<UserModel>(context).loggedIn;

        final isPending =
            [
              OrderStatus.refunded,
              OrderStatus.canceled,
              OrderStatus.completed,
            ].contains(order.status) ==
            false;

        final allowCancelAndRefund =
            kPaymentConfig.paymentListAllowsCancelAndRefund.isEmpty ||
            kPaymentConfig.paymentListAllowsCancelAndRefund.contains(
              order.paymentMethod,
            );

        final isCompositeCart =
            order.lineItems.firstWhereOrNull(
              (e) => e.product?.isCompositeProduct ?? false,
            ) !=
            null;

        return LoadingBody(
          isLoading: model.orderLoading,
          child: Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: theme.colorScheme.secondary,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                // TEMPORARY: entry point to preview the booking
                // confirmation screen while checkout is disabled.
                IconButton(
                  tooltip: 'Booking details',
                  icon: Icon(
                    Icons.event_available,
                    color: theme.colorScheme.secondary,
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingConfirmationScreen(
                        orderId: '${order.id}',
                        customerId: order.customerId,
                      ),
                    ),
                  ),
                ),
                if (kOrderConfig.enableReorder &&
                    ServerConfig().isSupportReorder &&
                    loggedIn &&
                    !isCompositeCart)
                  Center(child: Services().widget.reOrderButton(order)),
              ],
              title: Text(
                '${S.of(context).orderNo} #${order.number}',
                style: TextStyle(color: theme.colorScheme.secondary),
              ),
              backgroundColor: theme.colorScheme.surface,
              elevation: 0.0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: <Widget>[
                  ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 8),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.lineItems.length,
                    itemBuilder: (context, index) {
                      final item = order.lineItems[index];
                      return ProductOrder(
                        orderId: order.id!,
                        orderStatus: order.status!,
                        product: item,
                        index: index,
                        storeDeliveryDates: order.storeDeliveryDates,
                        currencyCode: currencyCode,
                        disableReview: widget.disableReview,
                      );
                    },
                  ),

                  OrderTotal(order: order),

                  if (order.smartCodIsRfOrder == true)
                    Container(
                      decoration: BoxDecoration(
                        color: theme.primaryColorLight,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: <Widget>[
                          _CustomListTile(
                            leading: S.of(context).advanceAmount,
                            trailing: PriceTools.getCurrencyFormatted(
                              order.orderSmartCod?.advanceAmount,
                              currencyRate,
                              currency: currencyCode,
                            )!,
                          ),
                          const SizedBox(height: 10),
                          _CustomListTile(
                            leading: S.of(context).remainingAmountCod,
                            trailing: PriceTools.getCurrencyFormatted(
                              order.orderSmartCod?.remainingAmount,
                              currencyRate,
                              currency: currencyCode,
                            )!,
                          ),
                          const SizedBox(height: 10),
                          _CustomListTile(
                            leading: S.of(context).totalAmount,
                            trailing: PriceTools.getCurrencyFormatted(
                              order.orderSmartCod?.realTotal,
                              currencyRate,
                              currency: currencyCode,
                            )!,
                          ),
                        ],
                      ),
                    ),

                  OrderTracking(order: order),

                  Services().widget.renderOrderTimelineTracking(context, order),

                  /// Render the Cancel and Refund
                  if (kPaymentConfig.enableRefundCancel && allowCancelAndRefund)
                    Services().widget.renderOrderActionButtons(
                      context,
                      order,
                      _cancelOrder,
                      _refundOrder,
                      _handlePayment,
                    ),

                  if (isPending && kPaymentConfig.showTransactionDetails) ...[
                    if (order.bacsInfo.isNotEmpty &&
                        kBankTransferConfig
                            .getValueList('paymentMethodIds')
                            .contains(order.paymentMethod))
                      _OrderDetailSection(
                        title: S.of(context).ourBankDetails,
                        child: Column(
                          children: order.bacsInfo
                              .map((e) => BankAccountInfo(bankInfo: e))
                              .toList(),
                        ),
                      ),

                    /// Thai PromptPay
                    /// false: hide show Thank you message - https://tppr.me/xrNh1
                    Services().thaiPromptPayBuilder(
                      showThankMsg: false,
                      order: order,
                    ),
                  ],

                  if (order.billing != null)
                    _OrderDetailSection(
                      title: S.of(context).billingAddress,
                      child: _buildAddressInfoCard(context, order.billing!),
                    ),

                  if (order.shipping != null)
                    _OrderDetailSection(
                      title: S.of(context).shippingAddress,
                      child: _buildAddressInfoCard(context, order.shipping!),
                    ),
                  if (order.additionalInformation.isNotEmpty)
                    _OrderDetailSection(
                      title: S.of(context).orderExtra,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: order.additionalInformation.entries.map((
                          entry,
                        ) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.key}:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              _buildAdditionalInfoValue(context, entry.value),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  if (order.customerNote?.trim().isNotEmpty ?? false)
                    _OrderDetailSection(
                      title: S.of(context).yourNote,
                      child: Text(order.customerNote!.trim()),
                    ),

                  if (kPaymentConfig.showOrderNotes)
                    OrderNotes(
                      isLoading: model.orderNoteLoading,
                      listOrderNote: model.listOrderNote,
                    ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _refundOrder() async {
    final confirmed = await context.showFluxDialogConfirm(
      title: S.of(context).refundRequest,
      body: S.of(context).areYouSureRefundOrder,
      primaryAsDestructiveAction: true,
    );
    if (confirmed) {
      try {
        await orderHistoryModel.createRefund();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).refundOrderSuccess)),
        );
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).refundOrderFailed)),
        );
      }
    }
  }
}

class _OrderDetailSection extends StatelessWidget {
  const _OrderDetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child,
      ],
    );
  }
}

class _CustomListTile extends StatelessWidget {
  const _CustomListTile({required this.leading, required this.trailing});

  final String leading;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.titleMedium!,
      child: Row(
        children: <Widget>[
          Expanded(child: Text(leading)),
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(trailing, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
