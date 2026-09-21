import 'dart:async';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:inspireui/widgets/will_pop_scope.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/config/models/cart_config.dart';
import '../../common/constants.dart';
import '../../models/booking/booking_confirmation.dart';
import '../../models/checkout/review_model.dart';
import '../../models/index.dart' show CartModel, Order;
import '../../models/tera_wallet/wallet_model.dart';
import '../../modules/analytics/analytics.dart';
import '../../modules/dynamic_layout/helper/helper.dart';
import '../../services/index.dart';
import '../../widgets/common/webview.dart';
import '../../widgets/product/product_bottom_sheet.dart';
import '../../widgets/web_layout/web_layout.dart';
import '../base_screen.dart';
import '../cart/my_cart_layout/my_cart_normal_layout_web.dart';
import 'booking_confirmation_screen.dart';
import 'review_screen.dart';
import 'widgets/payment_methods.dart';
import 'widgets/stepper_checkout_widet.dart';
import 'widgets/success.dart';

class CheckoutArgument {
  final bool? isModal;

  const CheckoutArgument({this.isModal});
}

class Checkout extends StatefulWidget {
  final bool? isModal;

  const Checkout({this.isModal});

  @override
  BaseScreen<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends BaseScreen<Checkout> {
  int tabIndex = 0;
  Order? newOrder;
  bool isPayment = false;
  bool isLoading = false;
  bool enabledShipping = kPaymentConfig.enableShipping;
  bool get isDesktop => Layout.isDisplayDesktop(context);

  bool get isEnabledHybridCheckout =>
      kPaymentConfig.enableHybridPayment && ServerConfig().isWooType;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final cartModel = Provider.of<CartModel>(context, listen: false);
      Analytics.triggerBeginCheckout(context);
      setState(() {
        enabledShipping = cartModel.isEnabledShipping();
      });
    });
  }

  void setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

  OrderSummaryStyle get summaryStyle {
    if (isDesktop) {
      switch (tabIndex) {
        case 0:
          return OrderSummaryStyle.webCheckoutShippingAddress;
        case 1:
          return OrderSummaryStyle.webCheckoutShippingMethod;
        case 2:
          return OrderSummaryStyle.webCheckoutReview;
        case 3:
          return OrderSummaryStyle.webCheckoutPayment;
        default:
          return OrderSummaryStyle.normal;
      }
    }
    return OrderSummaryStyle.normal;
  }

  Widget _renderProgressBar() {
    final theme = Theme.of(context);

    // Steps disabled in the config take no part in the flow, so build the
    // stepper from the enabled ones instead of a fixed list.
    final steps = <(int, String)>[
      if (kPaymentConfig.enableAddress) (0, S.of(context).address),
      if (enabledShipping) (1, S.of(context).shipping),
      if (kPaymentConfig.enablePreview) (2, S.of(context).review.toTitleCase()),
      if (!isEnabledHybridCheckout) (3, S.of(context).payment),
    ];
    if (steps.isEmpty) {
      return const SizedBox();
    }

    var currentStep = steps.indexWhere((step) => step.$1 == tabIndex);
    if (currentStep < 0) {
      currentStep = 0;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 18, bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValueOpacity(0.4)),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => StepperCheckoutWidget(
          currentStep: currentStep,
          width: constraints.maxWidth,
          items: [
            for (var i = 0; i < steps.length; i++)
              StepperCheckoutItem(index: i, title: steps[i].$2),
          ],
        ),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Initialize the first index
    if (!kPaymentConfig.enableAddress) {
      setState(() {
        tabIndex = 1;
      });
      if (!enabledShipping) {
        setState(() {
          tabIndex = 2;
        });
        if (!kPaymentConfig.enablePreview) {
          setState(() {
            tabIndex = 3;
            isPayment = true;
          });
        }
      }
    }
  }

  /// Appointments get a booking confirmation; everything else keeps the
  /// standard order receipt.
  Widget _buildOrderResult() {
    final order = newOrder!;
    final receipt = OrderedSuccess(order: order, hasScroll: isDesktop == false);

    return FutureBuilder<List<BookingConfirmation>?>(
      future: Services().api.fetchBookingConfirmations(
        orderId: '${order.id}',
        customerId: order.customerId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return receipt;
        }
        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return receipt;
        }
        return BookingConfirmationScreen(
          orderId: '${order.id}',
          customerId: order.customerId,
          bookings: bookings,
          useScaffold: false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var body = newOrder != null
        ? _buildOrderResult()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (!isPayment && isDesktop == false) _renderProgressBar(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: renderContent()),
                    if (isDesktop)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 30),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Container(
                                  width: 400,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 5,
                                        color: kGrey400.withValueOpacity(0.15),
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: OrderSummaryWidget(
                                    errMsg: '',
                                    isModal: false,
                                    style: summaryStyle,
                                    onBack: _onPaymentBack,
                                    onFinish: _onPaymentFinish,
                                    onLoading: setLoading,
                                    onNext: () {
                                      if (tabIndex == 2) {
                                        goToPaymentTab();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );

    if (isDesktop) {
      body = SliverWebLayout(
        actionBuilder: () {
          return SizedBox(
            height: 60,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: MediaQuery.sizeOf(context).width * 0.1,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: StepperCheckoutWidget(
                  currentStep: tabIndex,
                  items: [
                    StepperCheckoutItem(index: 0, title: S.of(context).address),
                    StepperCheckoutItem(
                      index: 1,
                      title: S.of(context).shipping,
                    ),
                    StepperCheckoutItem(
                      index: 2,
                      title: S.of(context).review.toTitleCase(),
                    ),
                    StepperCheckoutItem(index: 3, title: S.of(context).payment),
                  ],
                  width: MediaQuery.sizeOf(context).width * 0.4,
                ),
              ),
            ),
          );
        },
        slivers: [
          if (newOrder == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: LayoutLimitWidthScreen(child: body),
            )
          else
            SliverToBoxAdapter(child: LayoutLimitWidthScreen(child: body)),
        ],
      );
    }

    return WillPopScopeWidget(
      onWillPop: () async {
        // Reset CartModel values when closing/cancelling checkout
        await context.read<CartModel>().resetCheckoutInfo().onError((
          Object e,
          StackTrace t,
        ) async {
          printError(e, t);
        });

        return true;
      },
      child: Stack(
        children: <Widget>[
          Scaffold(
            backgroundColor: isDesktop
                ? theme.colorScheme.surface.withValueOpacity(0.1)
                : (theme.brightness == Brightness.dark
                      ? theme.colorScheme.surface
                      : const Color(0xFFF7F7F9)),
            appBar: isDesktop
                ? null
                : AppBar(
                    backgroundColor: theme.colorScheme.surface,
                    title: Text(
                      S.of(context).checkout,
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    actions: <Widget>[
                      if (widget.isModal != null && widget.isModal == true)
                        IconButton(
                          icon: const Icon(Icons.close, size: 24),
                          onPressed: _onPressCloseButton,
                        ),
                    ],
                  ),
            body: SafeArea(bottom: false, child: body),
          ),
          isLoading ||
                  context.select<CartModel, bool>(
                    (cart) => cart.calculatingDiscount,
                  )
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white.withValueOpacity(0.36),
                  child: kLoadingWidget(context),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget renderContent() {
    switch (tabIndex) {
      case 0:
        return SizedBox(
          key: const ValueKey(0),
          child: Services().renderCheckoutShippingAddress(
            onNext: () {
              // DO NOT remove `Future.delayed(Duration.zero)` here. Thanks~
              Future.delayed(Duration.zero, goToShippingTab);
            },
          ),
        );
      case 1:
        return SizedBox(
          key: const ValueKey(1),
          child: Services().widget.renderShippingMethods(
            context,
            onBack: () => goToAddressTab(true),
            onNext: goToReviewTab,
          ),
        );
      case 2:
        return SizedBox(
          key: const ValueKey(2),
          child: ChangeNotifierProvider(
            create: (context) => ReviewModel(),
            child: ReviewScreen(
              onBack: () => goToShippingTab(true),
              onNext: goToPaymentTab,
            ),
          ),
        );
      case 3:
      default:
        return SizedBox(
          key: const ValueKey(3),
          child: PaymentMethods(
            hideCheckout: isDesktop,
            onBack: _onPaymentBack,
            onFinish: _onPaymentFinish,
            onLoading: setLoading,
          ),
        );
    }
  }

  void _onPaymentBack() {
    context.read<CartModel>()
      ..setWalletAmount(0.0)
      ..resetSmartCod();

    goToReviewTab(true);
  }

  void _onPaymentFinish(Order order) async {
    setState(() {
      newOrder = order;
    });

    Analytics.triggerPurchased(order, context);

    await Services().widget.updateOrderAfterCheckout(context, order);
    await Services().onCheckoutSuccess(context, order);
    unawaited(context.read<CartModel>().clearCart());
    unawaited(context.read<WalletModel>().refreshWallet());

    final redirectUrl = order.redirectUrl;
    if (redirectUrl != null) {
      unawaited(
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => WebView(
              order.redirectUrl!,
              onPageFinished: (url) {
                printLog('redirect url: $url');
                EasyDebounce.debounce(
                  'checkout_redirect',
                  const Duration(seconds: 5),
                  () {
                    if (!url.contains('order') && !url.contains('checkout')) {
                      Navigator.of(
                        context,
                      ).popUntil(ModalRoute.withName(RouteList.dashboard));
                    }
                  },
                );
              },
            ),
          ),
          ModalRoute.withName(RouteList.dashboard),
        ),
      );
      return;
    }

    if (isDesktop) {
      unawaited(
        Navigator.of(
          context,
        ).pushNamed(RouteList.orderdSuccess, arguments: {'order': order}),
      );
    }
  }

  /// tabIndex: 0
  void goToAddressTab([bool isGoingBack = false]) {
    if (kPaymentConfig.enableAddress) {
      setState(() {
        tabIndex = 0;
      });
    } else {
      if (!isGoingBack) {
        goToShippingTab(isGoingBack);
      }
    }
  }

  /// tabIndex: 1
  void goToShippingTab([bool isGoingBack = false]) {
    if (enabledShipping) {
      setState(() {
        tabIndex = 1;
      });
    } else {
      if (isGoingBack) {
        goToAddressTab(isGoingBack);
      } else {
        goToReviewTab();
      }
    }
  }

  /// tabIndex: 2
  void goToReviewTab([bool isGoingBack = false]) {
    if (kPaymentConfig.enablePreview) {
      setState(() {
        tabIndex = 2;
      });
    } else {
      if (isGoingBack) {
        goToShippingTab(isGoingBack);
      } else {
        goToPaymentTab();
      }
    }
  }

  /// tabIndex: 3
  void goToPaymentTab() {
    if (isEnabledHybridCheckout) {
      /// Create order via API then open webview for payment with pay URL
      Services().widget.placeOrder(
        context,
        cartModel: context.read<CartModel>(),
        onLoading: setLoading,
        paymentMethod: null,
        success: (Order? order) async {
          if (order != null) {
            _onPaymentFinish(order);
          }
          setLoading(false);
        },
        error: (message) {
          setLoading(false);
          if (message != null) {
            Tools.showSnackBar(ScaffoldMessenger.of(context), message);
          }
        },
      );
      return;
    }

    setState(() {
      tabIndex = 3;
    });
  }

  void _onPressCloseButton() {
    if (Navigator.of(context).canPop()) {
      Navigator.popUntil(
        context,
        (Route<dynamic> route) => route.settings.name == RouteList.checkout,
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    } else {
      ExpandingBottomSheet.of(context, isNullOk: true)?.close();
    }
  }
}
