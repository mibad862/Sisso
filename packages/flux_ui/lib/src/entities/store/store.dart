import 'package:html_unescape/html_unescape.dart';
import 'package:inspireui/inspireui.dart';
import 'package:intl/intl.dart';
import 'package:quiver/strings.dart';

import '../../core/helpers/helpers.dart';
import '../vacation_settings.dart';
import 'store_hour.dart';

class Store {
  // Support both Dokan and WCFM
  int? id;
  String? name;
  String? email;
  bool showEmail = true;
  String? chatEmail;
  double? rating;
  String? reviewCount;
  String? image;
  String? address;
  String? banner;
  String? phone;
  String? website;
  double? lat;
  double? long;
  Map<String, String>? socials;
  StoreHour? storeHour;
  String? link;

  // WCFM parses from API, Dokan uses defaults
  bool showAddress = true;
  bool showPhone = true;
  bool showDescription = true;

  // Support only WCFM
  double? minOrderAmount;
  String? description;
  bool enableChat = false;
  VacationSettings? vacationSettings;

  // Support only Dokan
  bool? isFeatured;
  String? storeOpenNote;
  String? storeCloseNote;

  Store.fromDokanJson(Map<String, dynamic> parsedJson) {
    id = FluxUiHelper.formatInt(parsedJson['id']);

    final firstName = FluxUiHelper.formatString(parsedJson['first_name']);
    final lastName = FluxUiHelper.formatString(parsedJson['last_name']);
    if (firstName != null && lastName != null) {
      name = '$firstName $lastName';
    }

    link = FluxUiHelper.formatString(parsedJson['shop_url']);

    final parsedName = FluxUiHelper.formatString(parsedJson['name']);
    if (parsedName != null) {
      name = parsedName;
    }
    final shopName = FluxUiHelper.formatString(parsedJson['shop_name']);
    if (shopName != null) {
      name = shopName;
    }
    final storeName = FluxUiHelper.formatString(parsedJson['store_name']);
    if (storeName != null) {
      name = storeName;
    }
    if (name != null) {
      name = HtmlUnescape().convert(name!);
    }

    email = FluxUiHelper.formatString(parsedJson['email']) ?? '';
    chatEmail = email;
    showEmail = parsedJson['show_email'] != null
        ? FluxUiHelper.formatBool(parsedJson['show_email'])
        : true;
    rating = 0.0;
    final ratingJson = parsedJson['rating'];
    if (ratingJson is Map) {
      rating = FluxUiHelper.formatDouble(ratingJson['rating']) ?? 0.0;
      reviewCount = FluxUiHelper.formatString(ratingJson['count']);
    } else if (ratingJson != null) {
      rating = FluxUiHelper.formatDouble(ratingJson) ?? 0.0;
    }

    String? stringLocation;
    final location = parsedJson['location'];
    if (location is String) {
      stringLocation = FluxUiHelper.formatString(location);
    } else if (location is List) {
      stringLocation = location
          .map((item) => FluxUiHelper.formatString(item) ?? '')
          .where((item) => item.isNotEmpty)
          .join(',');
    }

    if (stringLocation?.isNotEmpty ?? false) {
      final arrLocation = stringLocation!.split(',');
      lat = arrLocation.isNotEmpty
          ? FluxUiHelper.formatDouble(arrLocation[0]) ?? 0.0
          : 0.0;
      long = arrLocation.length > 1
          ? FluxUiHelper.formatDouble(arrLocation[1]) ?? 0.0
          : 0.0;
    }

    image = _parseImage(parsedJson['gravatar']);

    if (parsedJson['address'] is Map) {
      address = _formatDokanAddress(parsedJson['address']);
    }

    banner = _parseImage(parsedJson['banner']);
    phone = FluxUiHelper.formatString(parsedJson['phone']);
    isFeatured = FluxUiHelper.formatBool(parsedJson['featured']);
    showDescription = false;

    final dynamic storeOpenCloseRaw = parsedJson['store_open_close'];
    final storeOpenClose = storeOpenCloseRaw is Map ? storeOpenCloseRaw : null;
    final time = storeOpenClose?['time'];

    if (FluxUiHelper.formatBool(storeOpenClose?['enabled']) &&
        time != null &&
        time is Map &&
        time.isNotEmpty) {
      storeHour = StoreHour.fromDokan(time);
    }

    // Full social information is retrieved from Dokan settings
    // in Admin -> Edit Profile (user account settings).
    // Note: The "My Profile" page (domain/my-profile/) may not include social data.
    socials = _parseSocials(parsedJson['social']);
    storeOpenNote = FluxUiHelper.formatString(storeOpenClose?['open_notice']);
    storeCloseNote = FluxUiHelper.formatString(storeOpenClose?['close_notice']);
  }

  Store.fromWCFMJson(Map<String, dynamic> parsedJson) {
    id = FluxUiHelper.formatInt(parsedJson['vendor_id']);

    final vendorShopName = FluxUiHelper.formatString(
      parsedJson['vendor_shop_name'],
    );
    if (vendorShopName != null) {
      name = vendorShopName;
    }
    if (name != null) {
      name = HtmlUnescape().convert(name!);
    }

    email = FluxUiHelper.formatString(parsedJson['vendor_email']);
    link = FluxUiHelper.formatString(parsedJson['shop_url']);
    chatEmail = FluxUiHelper.formatString(parsedJson['chat_email']) ?? email;
    rating = FluxUiHelper.formatDouble(parsedJson['store_rating']) ?? 0.0;

    reviewCount = FluxUiHelper.formatString(parsedJson['vendor_reviews_count']);

    address = _formatWCFMAddress(parsedJson['vendor_address']);

    showDescription = _isWCFMFieldVisible(parsedJson['store_hide_description']);
    showAddress = _isWCFMFieldVisible(parsedJson['store_hide_address']);
    showEmail = _isWCFMFieldVisible(parsedJson['store_hide_email']);
    showPhone = _isWCFMFieldVisible(parsedJson['store_hide_phone']);

    description = FluxUiHelper.formatString(parsedJson['vendor_description']);
    if (Bidi.stripHtmlIfNeeded(description ?? '').trim().isEmpty) {
      showDescription = false;
    }

    final settings = parsedJson['settings'];
    if (settings is Map) {
      image = _parseImage(settings['gravatar']);
      if (isBlank(image)) {
        image = _parseImage(parsedJson['vendor_shop_logo']);
      }

      banner = _parseImage(settings['mobile_banner']);
      if (isBlank(banner)) {
        banner = _parseImage(settings['banner']);
      }
      if (isBlank(banner)) {
        banner = _parseImage(parsedJson['mobile_banner']);
      }
      if (isBlank(banner)) {
        banner = _parseImage(parsedJson['vendor_banner']);
      }
      if (isBlank(banner)) {
        banner = _parseImage(parsedJson['vendor_list_banner']);
      }

      lat = FluxUiHelper.formatDouble(settings['store_lat']);
      long = FluxUiHelper.formatDouble(settings['store_lng']);
      var geolocation = settings['geolocation'];
      if (geolocation is Map) {
        lat ??= FluxUiHelper.formatDouble(geolocation['store_lat']);
        long ??= FluxUiHelper.formatDouble(geolocation['store_lng']);
      }

      phone = '';
      final settingPhone = settings['phone'];
      if (settingPhone is List) {
        if (settingPhone.isNotEmpty) {
          phone = FluxUiHelper.formatString(settingPhone.first) ?? '';
        }
      } else {
        phone = FluxUiHelper.formatString(settingPhone) ?? '';
      }

      // Social information is retrieved from
      // Store Manager -> Profile -> Social (domain/store-manager/profile/)
      socials = _parseSocials(settings['social']);

      final storeHours = settings['wcfm_store_hours'];
      if (storeHours is Map) {
        storeHour = StoreHour.fromWCFM(storeHours);
      }
      vacationSettings = VacationSettings.fromJson(settings);
    } else {
      banner = _parseImage(parsedJson['mobile_banner']);
      if (isBlank(banner)) {
        banner = _parseImage(parsedJson['vendor_shop_logo']);
      }
      if (isBlank(banner)) {
        banner = _parseImage(parsedJson['vendor_banner']);
      }
      if (isBlank(banner)) {
        banner = _parseImage(parsedJson['vendor_list_banner']);
      }
    }
    minOrderAmount = FluxUiHelper.formatDouble(
      parsedJson['min_order_amt'],
      null,
    );
    enableChat = FluxUiHelper.formatBool(parsedJson['enable_chat']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'rating': rating,
      'image': image,
      'address': address,
      'banner': banner,
      'phone': phone,
      'website': website,
    };
  }

  Store.fromLocalJson(Map json) {
    try {
      id = FluxUiHelper.formatInt(json['id']);
      name = FluxUiHelper.formatString(json['name']);
      email = FluxUiHelper.formatString(json['email']);
      rating = FluxUiHelper.formatDouble(json['rating'], null);
      image = FluxUiHelper.formatString(json['image']);
      address = FluxUiHelper.formatString(json['address']);
      banner = FluxUiHelper.formatString(json['banner']);
      phone = FluxUiHelper.formatString(json['phone']);
      website = FluxUiHelper.formatString(json['website']);
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
    }
  }
}

extension on Store {
  bool _isWCFMFieldVisible(dynamic value) {
    final normalizedValue = FluxUiHelper.formatString(value)?.toLowerCase();
    return normalizedValue == 'no' ||
        normalizedValue == 'false' ||
        normalizedValue == '0';
  }

  Map<String, String>? _parseSocials(dynamic socialJson) {
    if (socialJson is! Map) {
      return null;
    }

    final safeSocials = <String, String>{};
    const socialKeyMap = {'fb': 'facebook', 'ggplus': 'googleplus'};

    for (final MapEntry(:key, :value) in socialJson.entries) {
      final keyStr = FluxUiHelper.formatString(key);
      final valueStr = FluxUiHelper.formatString(value);

      if (keyStr == null || valueStr == null) continue;

      safeSocials[socialKeyMap[keyStr] ?? keyStr] = valueStr;
    }

    return safeSocials.isEmpty ? null : safeSocials;
  }

  String? _formatDokanAddress(dynamic jsonData) {
    if (jsonData is! Map || jsonData.isEmpty) {
      return null;
    }

    return [
      FluxUiHelper.formatString(jsonData['street_1']),
      FluxUiHelper.formatString(jsonData['street_2']),
      FluxUiHelper.formatString(jsonData['city']),
      FluxUiHelper.formatString(jsonData['state']),
      FluxUiHelper.formatString(jsonData['country']),
      FluxUiHelper.formatString(jsonData['zip']),
    ].whereType<String>().join(', ').trim();
  }

  String? _formatWCFMAddress(dynamic data) {
    var addressFormat = '';
    var postCode = '';
    final address = FluxUiHelper.formatString(data);
    if (address == null || address.isEmpty) return addressFormat;

    final splitPostcode = address.split('-');
    final splitAddress = splitPostcode.first.split(',');

    if (splitPostcode.length > 1) {
      postCode = splitPostcode.sublist(1).join('-').trim();
    }
    if (splitAddress.isNotEmpty) {
      final newSplitAddress = splitAddress
          .map((e) => e.trim().replaceAll(RegExp(r'\s+'), ' '))
          .toList();
      newSplitAddress.removeWhere((address) => address.isEmpty);
      addressFormat = newSplitAddress.join(', ');
    }
    if (postCode.isNotEmpty) {
      if (addressFormat.isNotEmpty) {
        addressFormat += ' - $postCode';
      } else {
        addressFormat += postCode;
      }
    }

    return addressFormat;
  }

  String? _parseImage(dynamic data) {
    final image = FluxUiHelper.formatString(data);
    if (image != null && image.isURL) {
      return image;
    }
    return null;
  }
}
