import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart';
import 'package:quiver/strings.dart';

import '../../../models/entities/country.dart';
import '../../../models/entities/user.dart';
import '../../../services/https.dart';
import '../../../services/services.dart';
import '../models/checkout_field.dart';
import '../models/checkout_fields_manager.dart';
import 'checkout_cache_service.dart';

class CheckoutServices {
  final domain = Services().api.domain;

  Future<CheckoutFieldsManager> getCheckoutFields(BuildContext context) async {
    try {
      var response = await httpGet(
        Uri.parse('$domain/wp-json/api/flutter_checkout/checkout_fields'),
      );
      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode is Map && isNotBlank(jsonDecode['message'])) {
        throw Exception(jsonDecode['message']);
      } else {
        var billing = List.from(
          jsonDecode['billing'],
        ).map((item) => CheckoutField.fromJson(item)).toList();
        var shipping = List.from(
          jsonDecode['shipping'],
        ).map((item) => CheckoutField.fromJson(item)).toList();
        var additional = List.from(
          jsonDecode['additional'],
        ).map((item) => CheckoutField.fromJson(item)).toList();

        final fieldsManager = CheckoutFieldsManager(
          billing: billing,
          shipping: shipping,
          additional: additional,
        );

        await CheckoutCacheService.saveCheckoutFields(fieldsManager);

        return fieldsManager;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<CheckoutFieldsManager?> getCachedCheckoutFields() async {
    return await CheckoutCacheService.getCachedCheckoutFields();
  }

  Future<List<Country>?> getCachedCountries(String key) async {
    if ('shipping_country' == key) {
      return CheckoutCacheService.getCachedCheckoutShippingCountries();
    }
    return CheckoutCacheService.getCachedCheckoutBillingCountries();
  }

  Future<List<Country>> getCountries(String key) async {
    try {
      var url = '$domain/wp-json/api/flutter_checkout/countries?key=$key';
      final response = await httpCache(url.toUri()!);
      var jsonDecode = convert.jsonDecode(response.body);
      if (jsonDecode is Map && isNotBlank(jsonDecode['message'])) {
        throw Exception(jsonDecode['message']);
      } else {
        var countries = List.from(
          jsonDecode,
        ).map((item) => Country.fromWooJson(item)).toList();
        return countries;
      }
    } catch (err) {
      rethrow;
    }
  }

  Future<Map<String, Map<String, dynamic>>> getCustomerInfo(User? user) async {
    try {
      var url = '$domain/wp-json/api/flutter_checkout/customer';
      final response = await httpGet(
        url.toUri()!,
        headers: {
          'Content-Type': 'application/json',
          'User-Cookie': EncodeUtils.encodeCookie(user?.cookie ?? ''),
        },
      );
      var jsonDecode = convert.jsonDecode(response.body);
      if (jsonDecode is Map && isNotBlank(jsonDecode['message'])) {
        throw Exception(jsonDecode['message']);
      } else {
        return Map<String, dynamic>.from(jsonDecode).map((key, value) {
          if (value is List) {
            jsonDecode[key] = Map.fromEntries(
              value.map((e) => MapEntry(e['key'], e['value'])),
            );
          }
          return MapEntry(key, Map<String, dynamic>.from(value));
        });
      }
    } catch (err) {
      rethrow;
    }
  }
}
