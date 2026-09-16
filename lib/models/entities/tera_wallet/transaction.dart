import 'package:inspireui/inspireui.dart';

import '../user.dart';

class Transaction {
  final String id;
  final String? type;
  final double amount;
  final String details;
  final String? createdTime;
  final String currency;
  final User? userCreate;

  const Transaction({
    this.id = '',
    this.type,
    this.amount = 0.0,
    this.details = '',
    this.createdTime,
    this.currency = '',
    this.userCreate,
  });

  factory Transaction.fromJson(Map parsedJson) {
    try {
      return Transaction(
        id: parsedJson['transaction_id']?.toString() ?? '',
        type: parsedJson['type']?.toString(),
        amount: double.tryParse(parsedJson['amount']?.toString() ?? '') ?? 0.0,
        details: parsedJson['details']?.toString() ?? '',
        createdTime: parsedJson['date']?.toString(),
        currency: parsedJson['currency']?.toString() ?? '',
        userCreate: parsedJson['created_by'] is Map
            ? User.fromJson(_normalizeUserJson(parsedJson['created_by']))
            : null,
      );
    } catch (e, trace) {
      printLog(trace);
      return const Transaction();
    }
  }

  static Map _normalizeUserJson(Map json) {
    return {
      ...json,
      if (json['firstName'] == null && json['firstname'] != null)
        'firstName': json['firstname'],
      if (json['lastName'] == null && json['lastname'] != null)
        'lastName': json['lastname'],
    };
  }

  bool get isCredit => type == 'credit';

  bool get isTransfer => type == 'debit' && details.contains('transfer');

  String get transferNote => details;
}
