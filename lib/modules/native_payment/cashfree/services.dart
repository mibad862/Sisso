import 'dart:convert';

import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

import '../../../common/constants.dart';
import '../../../models/order/order.dart';
import '../../../services/services.dart';

class CashfreeServices {
  final _cfPaymentGatewayService = CFPaymentGatewayService();

  final Order? order;
  final Function(bool)? onLoading;
  final Function(String cashfreeOrderId, Order? order) onPaymentSuccess;
  final Function(CFErrorResponse errorResponse, String cashfreeOrderId)
  onPaymentFailure;

  CashfreeServices({
    this.order,
    this.onLoading,
    required this.onPaymentSuccess,
    required this.onPaymentFailure,
  });

  CFEnvironment _toEnvironment(dynamic value) {
    final env = value?.toString().toLowerCase();
    if (env == 'production') {
      return CFEnvironment.PRODUCTION;
    }
    if (env == 'sandbox') {
      return CFEnvironment.SANDBOX;
    }
    return CFEnvironment.SANDBOX;
  }

  Future<Map<String, dynamic>> _createCashfreeOrder() async {
    final wooOrderId = order?.id;
    if (wooOrderId.isEmptyOrNull) {
      throw Exception('Order ID is required');
    }

    final response = await httpPost(
      '${Services().api.domain}/wp-json/api/flutter_cashfree/create_order'
          .toUri()!,
      body: jsonEncode({'orderId': wooOrderId}),
      headers: {'content-type': 'application/json'},
    );

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && responseJson['message'] == null) {
      return responseJson;
    }

    if (responseJson['message'] != null) {
      throw responseJson['message'] as Object;
    }

    throw 'Failed to create Woo Cashfree order (status ${response.statusCode})';
  }

  /// Opens the Cashfree Web Checkout payment sheet.
  ///
  /// Calls [onPaymentSuccess] when the payment attempt is complete (caller
  /// must verify order status server-side), or [onPaymentFailure] on error.
  Future<void> openPayment() async {
    try {
      final orderData = await _createCashfreeOrder();
      final cashfreeOrderId = orderData['order_id'].toString();
      final paymentSessionId = orderData['payment_session_id'].toString();
      final checkoutEnvironment = _toEnvironment(orderData['environment']);

      _cfPaymentGatewayService.setCallback(
        (String cfOrderId) async {
          onPaymentSuccess(cfOrderId, order);
        },
        (CFErrorResponse errorResponse, String cfOrderId) =>
            onPaymentFailure(errorResponse, cfOrderId),
      );

      final session = CFSessionBuilder()
          .setEnvironment(checkoutEnvironment)
          .setOrderId(cashfreeOrderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

      final cfWebCheckout = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          .build();

      _cfPaymentGatewayService.doPayment(cfWebCheckout);
    } on CFException catch (e) {
      throw e.message;
    } catch (e) {
      rethrow;
    }
  }
}
