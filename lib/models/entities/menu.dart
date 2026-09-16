class Menu {
  String? name;
  String? price;
  String? description;
  bool? bookable;
  String? bookableOptions; // "onetime", "byguest", "bydays", "byguestanddays"
  bool? bookableQuantity;
  String? bookableQuantityMax;
  String? image;
  String? thumb;

  static String _normalizePrice(dynamic value) {
    final priceString = value?.toString().trim();
    return (priceString == null || priceString.isEmpty) ? '0' : priceString;
  }

  bool get isFreePrice {
    final parsedPrice = num.tryParse(_normalizePrice(price));
    return parsedPrice == null || parsedPrice == 0;
  }

  Menu.fromJson(Map json) {
    name = json['name'];
    price = _normalizePrice(json['price']);
    final bookableValue = json['bookable'];
    bookable = bookableValue is bool ? bookableValue : bookableValue == 'on';
    bookableOptions = json['bookable_options'];
    bookableQuantity = json['bookable_quantity'] == 'on';
    bookableQuantityMax = json['bookable_quantity_max'];
    description = json['description'];
    image = json['image'];
    thumb = json['thumb'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'bookable': bookable,
      'bookable_options': bookableOptions,
      'bookable_quantity': bookableQuantity,
      'bookable_quantity_max': bookableQuantityMax,
      'description': description,
      'image': image,
      'thumb': thumb,
    };
  }
}
