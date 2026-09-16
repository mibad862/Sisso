import 'dart:convert';

import '../../common/constants.dart';

class ListingBooking {
  // Booking details
  String? title;
  String? id;
  String? featuredImage;
  String? status;
  String? price;

  // Dates
  String? dateStart;
  String? dateEnd;
  String? createdDate;
  String? expiringDate;
  String? updatedAt;
  String? eventStart;
  String? eventEnd;

  // Order info
  String? orderId;
  String? orderStatus;
  Map<String, String?> adults = {};
  Map<String, String?> children = {};
  Map<String, String?> infants = {};
  Map<String, String?> animals = {};
  List<Map<String, String>> services = [];
  String? listingType;

  // Owner details
  String? ownerName;
  String? ownerEmail;
  String? ownerPhone;

  // Booking information
  BookingInfo? info;

  ListingBooking(
    this.title,
    this.id,
    this.featuredImage,
    this.status,
    this.dateStart,
    this.dateEnd,
    this.expiringDate,
    this.price,
    this.createdDate,
    this.updatedAt,
    this.adults,
    this.children,
    this.infants,
    this.animals,
    this.services,
    this.orderId,
    this.orderStatus,
    this.listingType,
    this.ownerName,
    this.ownerEmail,
    this.ownerPhone,
    this.eventStart,
    this.eventEnd,
    this.info,
  );

  static Map<String, dynamic> _parseCommentJson(dynamic raw) {
    var result = <String, dynamic>{};

    if (raw is Map) {
      result = Map<String, dynamic>.from(raw);
    } else if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          result = decoded;
        }
      } catch (_) {}
    }

    result.updateAll((_, value) => value ?? '');
    return result;
  }

  static BookingInfo _parseBookingInfo(Map json) {
    final commentJson = _parseCommentJson(
      json['comment_obj'] ?? json['comment'],
    );
    final servicesRaw = (commentJson['service'] is List)
        ? (commentJson['service'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
        : <Map<String, dynamic>>[];
    return BookingInfo.fromCommentJson(commentJson, servicesRaw);
  }

  ListingBooking.fromJson(Map json) {
    title = json['title'];
    id = json['ID'];

    final fImage = json['featured_image'];
    final gImages = json['gallery_images'];

    if (fImage is String && fImage.isNotEmpty) {
      featuredImage = fImage;
    } else if (gImages is List && gImages.isNotEmpty) {
      featuredImage = gImages[0]?.toString();
    } else {
      featuredImage = kDefaultImage;
    }

    status = json['status'];
    dateStart = json['date_start'];
    dateEnd = json['date_end'];
    expiringDate = json['expiring'];
    price = json['price'];
    createdDate = json['created'];
    orderId = json['order_id'];
    orderStatus = json['order_status'] ?? '';
    listingType = json['listing_type'];
    ownerName = json['owner_name'];
    ownerEmail = json['owner_email'];
    ownerPhone = json['owner_phone'];
    eventStart = json['event_start'];
    eventEnd = json['event_end'];
    info = _parseBookingInfo(json);
    final commentJson = jsonDecode(json['comment']);
    if (commentJson['adults'] != null) {
      adults['adults'] = commentJson['adults']?.toString();
    }
    if (commentJson['tickets'] != null) {
      adults['tickets'] = commentJson['tickets']?.toString();
    }
    if (commentJson['children'] != null) {
      children['children'] = commentJson['children']?.toString();
    }
    if (commentJson['infants'] != null) {
      infants['infants'] = commentJson['infants']?.toString();
    }
    if (commentJson['animals'] != null) {
      animals['animals'] = commentJson['animals']?.toString();
    }
    final servicesJson = commentJson['service'];
    if (servicesJson is List) {
      for (final item in servicesJson) {
        final service = item is Map ? item['service'] : null;
        if (service is Map) {
          services.add({
            'name': service['name']?.toString() ?? '',
            'price': service['price']?.toString() ?? '',
          });
        }
      }
    }
  }

  ListingBooking.fromServerlessJson(Map json) {
    orderId = json['id'];
    title = json['title'];
    featuredImage = json['featuredImage'] ?? kDefaultImage;
    status = json['statusBooking'];
    price = json['price']?.toString() ?? json['totalAmount']?.toString();

    final rawCreateDate = json['createdAt'] ?? json['orderDate'];
    final rawUpdatedAt = json['updatedAt'] ?? json['updateDate'];

    createdDate = DateTimeUtils.tryParseDateTime(rawCreateDate)?.toString();
    updatedAt = DateTimeUtils.tryParseDateTime(rawUpdatedAt)?.toString();
    orderStatus = json['status'] ?? '';
    final bookingInfo = json['bookingInfo'];
    if (bookingInfo != null) {
      adults['adults'] = bookingInfo['adults']?.toString() ?? '';
      adults['tickets'] = (bookingInfo['tickets'] ?? 1)?.toString() ?? '';
      children['children'] = bookingInfo['children']?.toString() ?? '';
      infants['infants'] = bookingInfo['infants']?.toString() ?? '';
      animals['animals'] = bookingInfo['animals']?.toString() ?? '';
      if (bookingInfo['services'] is List) {
        for (var item in bookingInfo['services']) {
          final quantityValue = int.parse(item['value']?.toString() ?? '1');
          final priceValue = double.parse(item['price']?.toString() ?? '0');
          services.add({
            'name': item['name']?.toString() ?? '',
            'price': priceValue.toString(),
            'id': item['id']?.toString() ?? '',
            'quantity': quantityValue.toString(),
            'total': (quantityValue * priceValue).toString(),
          });
        }
      }
    }
  }
}

class BookingInfo {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? message;
  final String? location;
  final String? billingAddress1;
  final String? billingPostcode;
  final String? billingCity;
  final String? billingCountry;
  final String? adults;
  final String? children;
  final String? infants;
  final String? animals;
  final String? tickets;
  final List<Map<String, dynamic>> servicesRaw;

  const BookingInfo({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.message,
    this.location,
    this.billingAddress1,
    this.billingPostcode,
    this.billingCity,
    this.billingCountry,
    this.adults,
    this.children,
    this.infants,
    this.animals,
    this.tickets,
    this.servicesRaw = const [],
  });

  factory BookingInfo.fromCommentJson(
    Map<String, dynamic> json,
    List<Map<String, dynamic>> services,
  ) {
    return BookingInfo(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      message: json['message'],
      location: json['booking_location'],
      billingAddress1: json['billing_address_1'],
      billingPostcode: json['billing_postcode'],
      billingCity: json['billing_city'],
      billingCountry: json['billing_country'],
      adults: json['adults']?.toString(),
      children: json['children']?.toString(),
      infants: json['infants']?.toString(),
      animals: json['animals']?.toString(),
      tickets: json['tickets']?.toString(),
      servicesRaw: services,
    );
  }

  int _parseCount(String? value) => int.tryParse(value ?? '') ?? 0;

  int get adultsCount => _parseCount(adults);
  int get childrenCount => _parseCount(children);
  int get infantsCount => _parseCount(infants);
  int get animalsCount => _parseCount(animals);
  int get ticketsCount => _parseCount(tickets);

  bool get hasBookingDetails => [
    adultsCount,
    childrenCount,
    infantsCount,
    animalsCount,
    ticketsCount,
  ].any((count) => count > 0);

  bool get hasServices => servicesRaw.isNotEmpty;

  List<Map<String, String>> get servicesSummary =>
      servicesRaw.where((e) => e['service'] is Map).map((e) {
        final s = e['service'] as Map? ?? {};
        return {
          'name': s['name']?.toString() ?? '',
          'price': s['price']?.toString() ?? '',
        };
      }).toList();

  String get address => [
    billingAddress1,
    billingCity,
    billingPostcode,
    billingCountry,
  ].where((e) => e != null && e.isNotEmpty).join(', ');
}
