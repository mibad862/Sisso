import 'checkout_field.dart';

class CheckoutFieldsManager {
  final List<CheckoutField>? billing;
  final List<CheckoutField>? shipping;
  final List<CheckoutField>? additional;

  const CheckoutFieldsManager({this.billing, this.shipping, this.additional});

  /// Create CheckoutFieldsManager from cached JSON
  factory CheckoutFieldsManager.fromJson(Map<String, dynamic> json) {
    return CheckoutFieldsManager(
      billing: json['billing'] != null
          ? List.from(
              json['billing'],
            ).map((item) => CheckoutField.fromJson(item)).toList()
          : null,
      shipping: json['shipping'] != null
          ? List.from(
              json['shipping'],
            ).map((item) => CheckoutField.fromJson(item)).toList()
          : null,
      additional: json['additional'] != null
          ? List.from(
              json['additional'],
            ).map((item) => CheckoutField.fromJson(item)).toList()
          : null,
    );
  }

  /// Convert CheckoutFieldsManager to JSON for caching
  Map<String, dynamic> toJson() => {
    'billing': billing?.map((field) => field.toJson()).toList(),
    'shipping': shipping?.map((field) => field.toJson()).toList(),
    'additional': additional?.map((field) => field.toJson()).toList(),
  };
}
