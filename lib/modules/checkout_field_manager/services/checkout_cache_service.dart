import '../../../common/constants.dart';
import '../../../data/boxes.dart';
import '../../../models/entities/country.dart';
import '../models/checkout_fields_manager.dart';
import 'country_cache_manager.dart';

class CheckoutCacheService {
  static final CacheBox _cacheBox = CacheBox();

  static Future<void> saveCheckoutFields(
    CheckoutFieldsManager fieldsManager,
  ) async {
    try {
      await _cacheBox.init();
      await _cacheBox.setCheckoutFieldsCache(fieldsManager.toJson());
    } catch (e) {
      printLog('❌ Error saving checkout fields to cache: $e');
    }
  }

  static Future<CheckoutFieldsManager?> getCachedCheckoutFields() async {
    try {
      await _cacheBox.init();
      final cachedData = _cacheBox.getCheckoutFieldsCache();

      if (cachedData == null) {
        return null;
      }

      final fieldsManager = CheckoutFieldsManager.fromJson(cachedData);
      return fieldsManager;
    } catch (e) {
      printLog('❌ Error loading checkout fields from cache: $e');
      return null;
    }
  }

  static Future<void> clearCache() async {
    try {
      await _cacheBox.init();
      await _cacheBox.clearCheckoutFieldsCache();
    } catch (e) {
      printLog('❌ Error clearing checkout fields cache: $e');
    }
  }

  static Future<void> saveCheckoutBillingCountries(List<Country> countries) {
    return CountryCacheManager.saveCountries(
      countries,
      _cacheBox.setCheckoutBillingCountriesCache,
      cacheBox: _cacheBox,
    );
  }

  static Future<List<Country>?> getCachedCheckoutBillingCountries() async {
    return CountryCacheManager.getCachedCountries(
      _cacheBox.getCheckoutBillingCountriesCache,
      cacheBox: _cacheBox,
    );
  }

  static Future<void> clearCheckoutBillingCountriesCache() async {
    return CountryCacheManager.clearCountries(
      _cacheBox.clearCheckoutBillingCountriesCache,
      cacheBox: _cacheBox,
    );
  }

  static Future<void> saveCheckoutShippingCountries(
    List<Country> countries,
  ) async {
    return CountryCacheManager.saveCountries(
      countries,
      _cacheBox.setCheckoutShippingCountriesCache,
      cacheBox: _cacheBox,
    );
  }

  static Future<List<Country>?> getCachedCheckoutShippingCountries() async {
    return CountryCacheManager.getCachedCountries(
      _cacheBox.getCheckoutShippingCountriesCache,
      cacheBox: _cacheBox,
    );
  }

  static Future<void> clearCheckoutShippingCountriesCache() async {
    return CountryCacheManager.clearCountries(
      _cacheBox.clearCheckoutShippingCountriesCache,
      cacheBox: _cacheBox,
    );
  }

  static Future<void> saveCheckoutValues(
    Map<String, dynamic> checkoutValues,
  ) async {
    try {
      await _cacheBox.init();
      await _cacheBox.setCheckoutValuesCache(checkoutValues);
    } catch (e) {
      printLog('❌ Error saving checkout fields to cache: $e');
    }
  }

  static Future<Map<String, dynamic>?> getCachedCheckoutValues() async {
    try {
      await _cacheBox.init();
      final cachedData = _cacheBox.getCheckoutValuesCache();

      return cachedData;
    } catch (e) {
      printLog('❌ Error loading checkout values from cache: $e');
      return null;
    }
  }

  static Future<void> clearCheckoutValuesCache() async {
    try {
      await _cacheBox.init();
      await _cacheBox.clearCheckoutValuesCache();
    } catch (e) {
      printLog('❌ Error clearing checkout values cache: $e');
    }
  }
}
