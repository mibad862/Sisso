class ListeoEditorField {
  static const _multiValueTypes = {
    'select_multiple',
    'multicheck_split',
    'repeatable',
  };
  static const _optionSupportedTypes = {
    'select',
    'select_multiple',
    'multicheck_split',
    'repeatable',
  };

  final String id;
  final String name;
  final String type;
  final bool required;
  final String placeholder;
  final String icon;
  final String image;
  final String desc;
  final String defaultValue;
  final String cssClass;
  final bool showValueBeforeLabel;
  final bool invert;
  final String value;
  final String valueLabel;
  final List<ListeoFieldItem> selectedItems;
  final List<ListeoFieldItem> options;

  const ListeoEditorField({
    required this.id,
    required this.name,
    required this.type,
    required this.required,
    required this.placeholder,
    required this.icon,
    required this.image,
    required this.desc,
    required this.defaultValue,
    required this.cssClass,
    required this.showValueBeforeLabel,
    required this.invert,
    required this.value,
    required this.valueLabel,
    this.selectedItems = const [],
    this.options = const [],
  });

  bool get isCheckbox => type == 'checkbox';

  bool get isFileType => type == 'file';

  bool get isRepeatable => type == 'repeatable';

  bool get isMultiValueType => _multiValueTypes.contains(type);

  bool get supportsOptions => _optionSupportedTypes.contains(type);

  bool get isCheckboxChecked => _parseMetaValueToBool(value);

  String get displayValueText {
    if (isMultiValueType && selectedItems.isNotEmpty) {
      return selectedItems.map((item) => item.displayName).join(', ');
    }

    return valueLabel.isNotEmpty ? valueLabel : value;
  }

  bool get hasDisplayValue => displayValueText.isNotEmpty;

  /// Groups repeatable field items by name
  Map<String, ({String? image, String? icon, List<String> values})>
  get groupedRepeatableItems {
    if (!isRepeatable) return {};

    final grouped =
        <String, ({String? image, String? icon, List<String> values})>{};
    for (final item in selectedItems) {
      final key = item.name.isNotEmpty ? item.name : item.value;
      if (!grouped.containsKey(key)) {
        grouped[key] = (image: item.image, icon: item.icon, values: []);
      }
      if (item.value.isNotEmpty && item.value != key) {
        grouped[key]!.values.add(item.value);
      }
    }
    return grouped;
  }

  factory ListeoEditorField.fromJson(Map<String, dynamic> json) {
    final type = json['type'].toString();
    final isMultiValueType = _multiValueTypes.contains(type);
    final supportsOptions = _optionSupportedTypes.contains(type);

    final selectedItems = isMultiValueType
        ? _normalizeFieldItems(json['selected_items'])
        : const <ListeoFieldItem>[];
    final options = supportsOptions
        ? _normalizeFieldItems(json['options'])
        : const <ListeoFieldItem>[];

    return ListeoEditorField(
      id: json['id'].toString(),
      name: json['name'].toString(),
      type: type,
      required: _parseMetaValueToBool(json['required']),
      placeholder: json['placeholder'].toString(),
      icon: json['icon'].toString(),
      image: json['image'].toString(),
      desc: json['desc'].toString(),
      defaultValue: json['default'].toString(),
      cssClass: json['css_class'].toString(),
      showValueBeforeLabel: _parseMetaValueToBool(
        json['show_value_before_label'],
      ),
      invert: _parseMetaValueToBool(json['invert']),
      value: isMultiValueType
          ? selectedItems.map((item) => item.valueOrName).join(', ')
          : _normalizeFieldValueItems(json['value']).firstOrNull ?? '',
      valueLabel: isMultiValueType
          ? selectedItems.map((item) => item.displayName).join(', ')
          : _normalizeFieldValueItems(json['value_label']).firstOrNull ?? '',
      selectedItems: selectedItems,
      options: options,
    );
  }

  static List<ListeoFieldItem> _normalizeFieldItems(dynamic rawItems) {
    if (rawItems is! List) return const [];

    return rawItems
        .whereType<Map>()
        .map(
          (item) => ListeoFieldItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .where(
          (item) => item.name.trim().isNotEmpty || item.value.trim().isNotEmpty,
        )
        .toList();
  }

  static bool _parseMetaValueToBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes' ||
          normalized == 'on';
    }

    return false;
  }

  static List<String> _normalizeFieldValueItems(dynamic rawValue) {
    if (rawValue == null) return const [];

    final items = switch (rawValue) {
      List list => list,
      Map map => map.values,
      _ => [rawValue],
    };

    return items
        .where((item) => item != null)
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'required': required,
    'placeholder': placeholder,
    'icon': icon,
    'image': image,
    'desc': desc,
    'default': defaultValue,
    'css_class': cssClass,
    'show_value_before_label': showValueBeforeLabel,
    'invert': invert,
    if (supportsOptions)
      'options': options.map((item) => item.toJson()).toList(),
    if (isMultiValueType)
      'selected_items': selectedItems.map((item) => item.toJson()).toList()
    else ...{
      'value': value,
      'value_label': valueLabel,
    },
  };
}

class ListeoFieldItem {
  final String name;
  final String value;
  final String icon;
  final String image;

  const ListeoFieldItem({
    required this.name,
    required this.value,
    required this.icon,
    this.image = '',
  });

  String get displayName => name.isNotEmpty ? name : value;
  String get valueOrName => value.isNotEmpty ? value : name;

  factory ListeoFieldItem.fromJson(Map<String, dynamic> json) =>
      ListeoFieldItem(
        name: json['name']?.toString() ?? '',
        value: json['value']?.toString() ?? '',
        icon: json['icon']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'icon': icon,
    'image': image,
  };
}

class ListeoFieldsEditorResponse {
  final List<ListeoEditorField> listingTypeFields;
  final List<ListeoEditorField> termFields;

  const ListeoFieldsEditorResponse({
    this.listingTypeFields = const [],
    this.termFields = const [],
  });

  static const empty = ListeoFieldsEditorResponse();

  factory ListeoFieldsEditorResponse.fromJson(Map<String, dynamic> json) {
    final listingTypeFields =
        (json['listing_type_fields'] as List?)
            ?.whereType<Map>()
            .map(
              (item) =>
                  ListeoEditorField.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList() ??
        const <ListeoEditorField>[];

    final termFields =
        (json['term_fields'] as List?)?.whereType<Map>().expand((termItem) {
          final fields = termItem['fields'];
          if (fields is! List) return <ListeoEditorField>[];

          return fields.whereType<Map>().map(
            (item) =>
                ListeoEditorField.fromJson(Map<String, dynamic>.from(item)),
          );
        }).toList() ??
        const <ListeoEditorField>[];

    return ListeoFieldsEditorResponse(
      listingTypeFields: listingTypeFields,
      termFields: termFields,
    );
  }
}
