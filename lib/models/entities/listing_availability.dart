import 'dart:convert';

import 'package:inspireui/utils.dart';
import 'package:intl/intl.dart';

/// Represents listing availability data including closed dates and custom pricing
/// Used for listing products (service, rental, event, classifieds)
class ListingAvailability {
  /// Cached date formatter for performance in hot paths (calendar rendering)
  static final _dateFormat = DateFormat(DateTimeFormatConstants.ddMMyyyy);

  /// Set of dates when the listing is closed (unavailable)
  final Set<DateTime> closedDates;

  /// Custom pricing for specific dates (key: 'dd-MM-yyyy', value: price)
  final Map<String, double> customPrices;

  const ListingAvailability({
    required this.closedDates,
    required this.customPrices,
  });

  /// Creates a ListingAvailability instance from dynamic data (API response)
  ///
  /// Handles both Map and JSON string formats from the API.
  /// Returns an empty ListingAvailability if value is null or invalid.
  factory ListingAvailability.fromDynamic(dynamic value) {
    if (value == null) {
      return const ListingAvailability(closedDates: {}, customPrices: {});
    }

    Map<String, dynamic>? data;

    if (value is Map) {
      data = value.map((key, value) => MapEntry('$key', value));
    } else if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return const ListingAvailability(closedDates: {}, customPrices: {});
      }

      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          data = decoded.map((key, value) => MapEntry('$key', value));
        }
      } catch (_) {
        return const ListingAvailability(closedDates: {}, customPrices: {});
      }
    }

    if (data == null) {
      return const ListingAvailability(closedDates: {}, customPrices: {});
    }

    return ListingAvailability.fromJson(data);
  }

  /// Creates a ListingAvailability instance from JSON data
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "dates": "01-05-2024|15-05-2024|25-12-2024",  // pipe-separated dates
  ///   "price": "{\"01-05-2024\":150.0,\"15-05-2024\":200.0}"  // JSON string or Map
  /// }
  /// ```
  factory ListingAvailability.fromJson(Map<String, dynamic> json) {
    final closedDates = _parseClosedDates(json['dates']);
    final customPrices = _parseCustomPrices(json['price']);

    return ListingAvailability(
      closedDates: closedDates,
      customPrices: customPrices,
    );
  }

  /// Parses closed dates from pipe-separated string
  static Set<DateTime> _parseClosedDates(dynamic rawDates) {
    final result = <DateTime>{};

    if (rawDates is String) {
      final parts = rawDates.split('|');
      for (final dateText in parts) {
        final trimmed = dateText.trim();
        if (trimmed.isEmpty) continue;
        try {
          final date = _dateFormat.parseStrict(trimmed);
          result.add(_stripTime(date));
        } catch (_) {
          // Ignore invalid date format from API payload
        }
      }
    }
    return result;
  }

  /// Parses custom prices from JSON string or Map
  static Map<String, double> _parseCustomPrices(dynamic rawPrice) {
    final result = <String, double>{};
    dynamic source = rawPrice;

    if (source is String) {
      final trimmed = source.trim();
      if (trimmed.isEmpty) {
        return result;
      }
      try {
        source = jsonDecode(trimmed);
      } catch (_) {
        return result;
      }
    }

    if (source is Map) {
      source.forEach((key, value) {
        final parsedPrice = double.tryParse('$value');
        if (parsedPrice != null) {
          result['$key'] = parsedPrice;
        }
      });
    }

    return result;
  }

  /// Strips time component from DateTime, keeping only date
  static DateTime _stripTime(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Checks if a specific date is closed
  bool isClosed(DateTime day) => closedDates.contains(_stripTime(day));

  /// Gets custom price for a specific date
  double? getCustomPrice(DateTime day) {
    final key = _dateFormat.format(_stripTime(day));
    return customPrices[key];
  }

  /// Converts to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'dates': closedDates.map((d) => _dateFormat.format(d)).join('|'),
      'price': customPrices,
    };
  }
}
