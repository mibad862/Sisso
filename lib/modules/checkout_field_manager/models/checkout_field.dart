class CheckoutField {
  const CheckoutField({
    this.key,
    this.name,
    this.label,
    this.required = false,
    this.type,
    this.disabled = false,
    this.order = 0,
    this.placeholder,
    this.defaultValue,
    this.description,
    this.conditional = false,
    this.conditionalParentKey,
    this.conditionalParentValue,
    this.options,
    this.countryField,
    this.min,
    this.max,
  });

  final String? key;
  final String? name;
  final String? label;
  final bool required;
  final String? type;
  final bool disabled;
  final int order;
  final String? placeholder;
  final String? defaultValue;
  final String? description;
  final bool conditional;
  final String? conditionalParentKey;
  final String? conditionalParentValue;
  final List? options;
  final String? countryField; //use for state
  final num? min;
  final num? max;

  static List? _parseOptions(dynamic raw) {
    // Different plugins return different option formats:
    // - Checkout Field Manager/Checkout Manager: String or List
    // - Checkout Field Editor: Map object
    if (raw is List) {
      return raw.where((e) => e != null).toList();
    }
    if (raw is Map) {
      return raw.entries
          .map((e) => {'key': e.key.toString(), 'value': e.value.toString()})
          .toList();
    }
    return null;
  }

  static String optionValue(dynamic option) {
    if (option is Map) {
      return (option['key'] ?? option['value'] ?? option['label'] ?? '')
          .toString();
    }
    return option?.toString() ?? '';
  }

  static String optionLabel(dynamic option) {
    if (option is Map) {
      return (option['label'] ?? option['value'] ?? option['key'] ?? '')
          .toString();
    }
    return option?.toString() ?? '';
  }

  static bool _parseBool(dynamic raw) {
    if (raw is bool) {
      return raw;
    }
    final value = raw?.toString().trim().toLowerCase();
    return value == '1' || value == 'true' || value == 'yes';
  }

  static int _parseInt(dynamic raw, {int defaultValue = 0}) {
    if (raw is int) {
      return raw;
    }
    return int.tryParse(raw?.toString() ?? '') ?? defaultValue;
  }

  static num? _parseNum(dynamic raw) {
    if (raw == null) {
      return null;
    }
    if (raw is num) {
      return raw;
    }
    final value = raw.toString().trim();
    if (value.isEmpty) {
      return null;
    }
    return num.tryParse(value);
  }

  static String? _parseString(dynamic raw) {
    if (raw == null) {
      return null;
    }
    final value = raw.toString();
    return value.isEmpty ? null : value;
  }

  factory CheckoutField.fromJson(Map parsedJson) {
    final customAttributes = parsedJson['custom_attributes'];
    final minRaw = parsedJson['min'] ?? customAttributes?['min'];
    final maxRaw = parsedJson['max'] ?? customAttributes?['max'];

    return CheckoutField(
      name: _parseString(parsedJson['name']),
      key: _parseString(parsedJson['key']),
      label: _parseString(parsedJson['label']),
      required: _parseBool(parsedJson['required']),
      type: _parseString(parsedJson['type']) ?? 'text',
      disabled: _parseBool(parsedJson['disabled']),
      order: _parseInt(parsedJson['order']),
      placeholder: _parseString(parsedJson['placeholder']),
      defaultValue: _parseString(parsedJson['default']),
      description: _parseString(parsedJson['description']),
      conditional: _parseBool(parsedJson['conditional']),
      conditionalParentKey:
          _parseString(parsedJson['conditional_parent_key']) ??
          _parseString(customAttributes?['data-conditional-parent']),
      conditionalParentValue:
          _parseString(parsedJson['conditional_parent_value']) ??
          _parseString(customAttributes?['data-conditional-parent-value']),
      options: _parseOptions(parsedJson['options']),
      countryField: _parseString(parsedJson['country_field']),
      min: _parseNum(minRaw),
      max: _parseNum(maxRaw),
    );
  }

  /// Convert CheckoutField to JSON for caching
  Map<String, dynamic> toJson() => {
    'name': name,
    'key': key,
    'label': label,
    'required': required,
    'type': type,
    'disabled': disabled,
    'order': order,
    'placeholder': placeholder,
    'default': defaultValue,
    'description': description,
    'conditional': conditional,
    'conditional_parent_key': conditionalParentKey,
    'conditional_parent_value': conditionalParentValue,
    'options': options,
    'country_field': countryField,
    'min': min,
    'max': max,
  };
}
