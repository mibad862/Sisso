part of '../../boxes.dart';

extension CheckoutCacheExtension on CacheBox {
  Map<String, dynamic>? getCheckoutFieldsCache() {
    try {
      final data = box.get(BoxKeys.checkoutFields);

      if (data == null) {
        return null;
      }

      return Map<String, dynamic>.from(data);
    } catch (e) {
      printLog('❌ Error loading checkout fields from cache: $e');
      unawaited(clearCheckoutFieldsCache());
      return null;
    }
  }

  Future<void> setCheckoutFieldsCache(Map<String, dynamic> data) async {
    try {
      await box.put(BoxKeys.checkoutFields, data);
    } catch (e) {
      printLog('❌ Error saving checkout fields to cache: $e');
    }
  }

  Future<void> clearCheckoutFieldsCache() async {
    try {
      await box.delete(BoxKeys.checkoutFields);
    } catch (e) {
      printLog('❌ Error clearing checkout fields cache: $e');
    }
  }

  List? getCheckoutBillingCountriesCache() {
    return box.get(BoxKeys.checkoutBillingCountries, defaultValue: null);
  }

  Future<void> setCheckoutBillingCountriesCache(List data) async {
    try {
      await box.put(BoxKeys.checkoutBillingCountries, data);
    } catch (e) {
      printLog('❌ Error saving checkout billing countries to cache: $e');
    }
  }

  Future<void> clearCheckoutBillingCountriesCache() async {
    try {
      await box.delete(BoxKeys.checkoutBillingCountries);
    } catch (e) {
      printLog('❌ Error clearing checkout billing countries cache: $e');
    }
  }

  List? getCheckoutShippingCountriesCache() {
    return box.get(BoxKeys.checkoutShippingCountries, defaultValue: null);
  }

  Future<void> setCheckoutShippingCountriesCache(List data) async {
    try {
      await box.put(BoxKeys.checkoutShippingCountries, data);
    } catch (e) {
      printLog('❌ Error saving checkout shipping countries to cache: $e');
    }
  }

  Future<void> clearCheckoutShippingCountriesCache() async {
    try {
      await box.delete(BoxKeys.checkoutShippingCountries);
    } catch (e) {
      printLog('❌ Error clearing checkout shipping countries cache: $e');
    }
  }

  Map<String, dynamic>? getCheckoutValuesCache() {
    try {
      final data = box.get(BoxKeys.checkoutValues, defaultValue: null);
      if (data == null) {
        return null;
      }
      return Map<String, dynamic>.from(data);
    } catch (e) {
      printLog('❌ Error loading checkout values cache: $e');
      unawaited(clearCheckoutValuesCache());
      return null;
    }
  }

  Future<void> setCheckoutValuesCache(Map<String, dynamic> data) async {
    try {
      await box.put(BoxKeys.checkoutValues, data);
    } catch (e) {
      printLog('❌ Error saving checkout values to cache: $e');
    }
  }

  Future<void> clearCheckoutValuesCache() async {
    try {
      await box.delete(BoxKeys.checkoutValues);
    } catch (e) {
      printLog('❌ Error clearing checkout values cache: $e');
    }
  }
}
