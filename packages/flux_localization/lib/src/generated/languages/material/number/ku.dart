import 'package:intl/number_symbols.dart';

/// Kurdish Number Symbols
///
/// Kurdish has two main dialects:
/// - Kurmanji (Northern): Uses Latin script (Turkey, Syria)
/// - Sorani (Central): Uses Arabic script and Arabic-Indic digits (Iraq, Iran)
///
/// This implementation uses Sorani/Arabic-Indic format as it's the most
/// widely spoken dialect and matches the existing datetime formatting.

/// Kurdish - Uses Sorani/Arabic-Indic format
const kuNumberSymbols = NumberSymbols(
  NAME: 'ku',
  DECIMAL_SEP: '٫', // Arabic decimal separator
  GROUP_SEP: '٬', // Arabic thousands separator
  PERCENT: '٪', // Arabic percent sign
  ZERO_DIGIT: '٠', // Arabic-Indic digits (٠-٩)
  PLUS_SIGN: '+',
  MINUS_SIGN: '-',
  EXP_SYMBOL: 'E',
  PERMILL: '\u2030',
  INFINITY: '\u221E',
  NAN: 'NaN',
  DECIMAL_PATTERN: '#,##0.###',
  SCIENTIFIC_PATTERN: '#E0',
  PERCENT_PATTERN: '#,##0%',
  CURRENCY_PATTERN: '\u00A4\u00A0#,##0.00',
  DEF_CURRENCY_CODE: 'IQD', // Iraqi Dinar
);
