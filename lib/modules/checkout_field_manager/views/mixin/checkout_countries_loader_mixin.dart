import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../models/entities/country.dart';
import '../../services/index.dart';

mixin CheckoutCountriesLoaderMixin<T extends StatefulWidget> on State<T> {
  final CheckoutServices _checkoutServices = CheckoutServices();

  String get countryKey;

  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;
  List<Country>? countries;

  Future<void> loadCheckoutCountries(
    void Function(List<Country>?) onLoaded,
  ) async {
    _setLoading(true);
    try {
      final cachedData = await _checkoutServices.getCachedCountries(countryKey);
      if (cachedData != null) {
        onLoaded(cachedData);
        _setLoading(false);
        unawaited(_refreshInBackground(onLoaded));
        return;
      }

      final data = await _checkoutServices.getCountries(countryKey);
      onLoaded(data);
      _setLoading(false);
    } catch (e) {
      _setError(true, e.toString());
    }
  }

  Future<void> _refreshInBackground(
    void Function(List<Country>?) onLoaded,
  ) async {
    try {
      final freshData = await _checkoutServices.getCountries(countryKey);
      if (mounted && countries != freshData) {
        onLoaded(freshData);
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
}
