import '../../common/tools.dart';

class FilterAttribute {
  int? id;
  String? slug;
  String? name;
  bool isVisible = true;

  /// Only use for WooCommerce because we have customized the API response to
  /// return the sub attributes when getting attribute data
  List<SubAttribute>? subAttributes;

  FilterAttribute.fromJson(Map parsedJson) {
    id = int.tryParse('${parsedJson['id']}');
    slug = (parsedJson['slug'] ?? parsedJson['id'])?.toString();
    name = (parsedJson['name'] ?? parsedJson['public_name'])
        ?.toString()
        .unescape()
        .trim();
    final visibleValue = parsedJson['is_visible'];
    isVisible =
        visibleValue == null ||
        visibleValue == true ||
        visibleValue.toString() == '1' ||
        visibleValue.toString().toLowerCase() == 'true';

    if (parsedJson['terms'] != null) {
      subAttributes = [];
      for (var subAttribute in parsedJson['terms']) {
        subAttributes?.add(SubAttribute.fromJson(subAttribute));
      }
    }
  }
}

class SubAttribute {
  int? id;
  String? name;
  int? count;

  SubAttribute.fromJson(Map parsedJson) {
    id = int.tryParse('${parsedJson['id'] ?? parsedJson['term_id']}');
    name = parsedJson['name']?.toString().unescape().trim();
    count = int.tryParse('${parsedJson['count']}');
  }

  @override
  String toString() {
    return '[id: $id ===== name: $name]';
  }
}

extension SubAttributeExt on SubAttribute {
  /// Show sub attribute if count is null due to the old API or unsupported
  /// frameworks
  bool get isVisible => count == null || count! > 0;

  bool get isNotVisible => !isVisible;
}
