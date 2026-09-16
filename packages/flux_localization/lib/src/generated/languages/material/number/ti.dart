import 'package:intl/number_symbols.dart';

/// Tigrinya Number Symbols
///
/// Tigrinya is spoken in Eritrea and Ethiopia.
/// Uses Ge'ez/Ethiopic script (ትግርኛ) but commonly uses Western digits
/// in modern contexts for number formatting.

/// Tigrinya - Uses Western/Latin digits
const tiNumberSymbols = NumberSymbols(
  NAME: 'ti',
  DECIMAL_SEP: '.', // Period for decimal
  GROUP_SEP: ',', // Comma for thousands
  PERCENT: '%',
  ZERO_DIGIT: '0', // Western digits (0-9)
  PLUS_SIGN: '+',
  MINUS_SIGN: '-',
  EXP_SYMBOL: 'E',
  PERMILL: '\u2030',
  INFINITY: '\u221E',
  NAN: 'NaN',
  DECIMAL_PATTERN: '#,##0.###',
  SCIENTIFIC_PATTERN: '#E0',
  PERCENT_PATTERN: '#,##0%',
  CURRENCY_PATTERN: '\u00A4#,##0.00',
  DEF_CURRENCY_CODE: 'ERN', // Eritrean Nakfa
);
