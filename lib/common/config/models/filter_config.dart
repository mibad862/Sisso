import '../../../models/entities/filter_sorty_by.dart';

class FilterConfig {
  final bool showLayout;

  /// Except Haravan
  final bool showSort;

  /// Except Haravan, Listing, and Shopify
  final bool showPriceSlider;
  final bool showCategory;

  /// Only for listing app
  final bool showListingLocation;

  /// Except Haravan
  final bool showBrand;

  /// Except Haravan
  final bool showTag;

  /// Only for Prestashop
  final bool showFeature;

  /// Except Haravan, Listing, and Shopify
  final bool showAttribute;

  /// List of sort options to display. If null or empty, all framework-specific
  /// default options will be shown. Use OrderByType enum names as strings.
  /// Example: ["date", "price", "title", "popularity", "rating"]
  final List<String>? supportedSortByOptions;

  const FilterConfig({
    this.showLayout = true,
    this.showSort = true,
    this.showPriceSlider = true,
    this.showCategory = true,
    this.showListingLocation = true,
    this.showBrand = true,
    this.showTag = true,
    this.showFeature = true,
    this.showAttribute = true,
    this.supportedSortByOptions,
  });

  factory FilterConfig.fromJson(Map? config) {
    if (config == null) {
      return const FilterConfig();
    }

    List<String>? sortOptions;
    if (config['supportedSortByOptions'] != null) {
      final rawOptions = config['supportedSortByOptions'];
      if (rawOptions is List) {
        sortOptions = rawOptions.map((e) => e.toString()).toList();
      }
    }

    return FilterConfig(
      showLayout: config['showLayout'] ?? true,
      showSort: config['showSort'] ?? true,
      showPriceSlider: config['showPriceSlider'] ?? true,
      showCategory: config['showCategory'] ?? true,
      showListingLocation: config['showListingLocation'] ?? true,
      showBrand: config['showBrand'] ?? true,
      showTag: config['showTag'] ?? true,
      showFeature: config['showFeature'] ?? true,
      showAttribute: config['showAttribute'] ?? true,
      supportedSortByOptions: sortOptions,
    );
  }

  FilterConfig copyWith({
    bool? showLayout,
    bool? showSort,
    bool? showPriceSlider,
    bool? showCategory,
    bool? showListingLocation,
    bool? showBrand,
    bool? showTag,
    bool? showFeature,
    bool? showAttribute,
    List<String>? supportedSortByOptions,
  }) {
    return FilterConfig(
      showLayout: showLayout ?? this.showLayout,
      showSort: showSort ?? this.showSort,
      showPriceSlider: showPriceSlider ?? this.showPriceSlider,
      showCategory: showCategory ?? this.showCategory,
      showListingLocation: showListingLocation ?? this.showListingLocation,
      showBrand: showBrand ?? this.showBrand,
      showTag: showTag ?? this.showTag,
      showFeature: showFeature ?? this.showFeature,
      showAttribute: showAttribute ?? this.showAttribute,
      supportedSortByOptions:
          supportedSortByOptions ?? this.supportedSortByOptions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showLayout': showLayout,
      'showSort': showSort,
      'showPriceSlider': showPriceSlider,
      'showCategory': showCategory,
      'showListingLocation': showListingLocation,
      'showBrand': showBrand,
      'showTag': showTag,
      'showFeature': showFeature,
      'showAttribute': showAttribute,
      'supportedSortByOptions': supportedSortByOptions,
    };
  }

  /// Converts list of string names to OrderByType enums
  /// Returns null if supportedSortByOptions is null or empty
  List<OrderByType>? get sortByOptionsAsEnum {
    if (supportedSortByOptions == null || supportedSortByOptions!.isEmpty) {
      return null;
    }

    return supportedSortByOptions!
        .map((name) {
          try {
            return OrderByType.values.firstWhere((e) => e.name == name);
          } catch (e) {
            return null;
          }
        })
        .where((e) => e != null)
        .cast<OrderByType>()
        .toList();
  }
}
