import '../../../data/boxes.dart';
import '../../../models/entities/country.dart';

typedef CountryCacheSetter =
    Future<void> Function(List<Map<String, dynamic>> data);
typedef CountryCacheGetter = dynamic Function();
typedef CountryCacheClearer = Future<void> Function();

class CountryCacheManager {
  static Future<void> saveCountries(
    List<Country> countries,
    CountryCacheSetter setter, {
    required CacheBox cacheBox,
  }) async {
    try {
      await cacheBox.init();
      final data = countries.map((e) => e.toJson()).toList();
      await setter(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Country>?> getCachedCountries(
    CountryCacheGetter getter, {
    required CacheBox cacheBox,
  }) async {
    try {
      await cacheBox.init();
      final cachedData = getter();
      if (cachedData == null) return null;

      return List.from(
        cachedData,
      ).map((item) => Country.fromLocalJson(item)).toList();
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearCountries(
    CountryCacheClearer clearer, {
    required CacheBox cacheBox,
  }) async {
    try {
      await cacheBox.init();
      await clearer();
    } catch (e) {
      rethrow;
    }
  }
}
