import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../models/entities/user.dart';
import '../../models/checkout_fields_manager.dart';
import '../../services/checkout_cache_service.dart';
import '../../services/index.dart';

mixin CheckoutFieldsLoaderMixin<T extends StatefulWidget> on State<T> {
  final CheckoutServices _checkoutServices = CheckoutServices();

  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;
  CheckoutFieldsManager? fieldsManager;

  Future<void> loadCheckoutFields(
    void Function(CheckoutFieldsManager?) onLoaded,
  ) async {
    _setLoading(true);
    try {
      final cachedFields = await _checkoutServices.getCachedCheckoutFields();
      if (cachedFields != null) {
        onLoaded(cachedFields);
        _setLoading(false);
        unawaited(_refreshInBackground(onLoaded));
        return;
      }

      final fieldsManager = await _checkoutServices.getCheckoutFields(context);
      onLoaded(fieldsManager);
      _setLoading(false);
    } catch (e) {
      _setError(true, e.toString());
    }
  }

  Future<void> _refreshInBackground(
    void Function(CheckoutFieldsManager?) onLoaded,
  ) async {
    try {
      final freshFields = await _checkoutServices.getCheckoutFields(context);
      if (mounted && fieldsManager != freshFields) {
        onLoaded(freshFields);
      }
    } catch (e) {
      debugPrint('Background refresh failed: $e');
    }
  }

  void _setLoading(bool value) {
    if (mounted) {
      setState(() {
        isLoading = value;
        hasError = false;
        errorMessage = null;
      });
    }
  }

  void _setError(bool error, String? message) {
    if (mounted) {
      setState(() {
        isLoading = false;
        hasError = error;
        errorMessage = message;
      });
    }
  }

  void loadCheckoutValues(
    User? user,
    void Function(Map<String, dynamic>?) onLoaded,
  ) async {
    final cachedValues = await CheckoutCacheService.getCachedCheckoutValues();
    if (cachedValues != null && cachedValues.isNotEmpty) {
      onLoaded(cachedValues);
    } else if (user != null && (user.cookie?.isNotEmpty ?? false)) {
      final customerInfo = await _checkoutServices.getCustomerInfo(user);
      var results = <String, dynamic>{};
      for (var entry in customerInfo.entries) {
        for (var e in entry.value.entries) {
          results['${entry.key}_${e.key}'] = e.value.toString();
        }
      }
      onLoaded(results);
    } else {
      onLoaded({});
    }
  }
}
