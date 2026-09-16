import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';

import 'ku.dart';
import 'ti.dart';

final _registeredCustomNumberSymbolLocales = <String>{};

/// Get custom NumberSymbols for locales not supported by intl package
NumberSymbols? getCustomNumberSymbols(String locale) {
  return switch (locale) {
    'ku' => kuNumberSymbols,
    'ti' => tiNumberSymbols,
    _ => null,
  };
}

/// Registers custom number symbols during app language setup on the UI isolate.
void registerCustomNumberSymbols(String? locale) {
  if (locale == null) {
    return;
  }

  final normalizedLocale = _normalizeCustomNumberLocale(locale);
  final customSymbol = getCustomNumberSymbols(normalizedLocale);
  if (customSymbol == null) {
    return;
  }

  final localeKeys = <String>[locale];
  if (locale != normalizedLocale) {
    localeKeys.add(normalizedLocale);
  }

  for (final localeKey in localeKeys) {
    if (_registeredCustomNumberSymbolLocales.add(localeKey)) {
      numberFormatSymbols[localeKey] = customSymbol;
    }
  }
}

String _normalizeCustomNumberLocale(String locale) =>
    locale.split(RegExp('[-_]')).first.toLowerCase();
