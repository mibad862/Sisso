/// A confirmed appointment, with the details needed to show the customer
/// what they just booked.
///
/// WooCommerce Appointments returns ids rather than names, so the service,
/// practitioner and payment values are resolved from the related product,
/// staff and order records.
class BookingConfirmation {
  final int id;
  final DateTime start;
  final DateTime end;
  final String? timezone;
  final String? serviceName;
  final String? practitionerName;
  final String? paymentMethodTitle;
  final String? total;
  final String? currency;
  final String? status;

  const BookingConfirmation({
    required this.id,
    required this.start,
    required this.end,
    this.timezone,
    this.serviceName,
    this.practitionerName,
    this.paymentMethodTitle,
    this.total,
    this.currency,
    this.status,
  });

  /// Appointment length in minutes.
  int get durationInMinutes => end.difference(start).inMinutes;

  BookingConfirmation copyWith({
    String? serviceName,
    String? practitionerName,
    String? paymentMethodTitle,
    String? total,
    String? currency,
  }) {
    return BookingConfirmation(
      id: id,
      start: start,
      end: end,
      timezone: timezone,
      serviceName: serviceName ?? this.serviceName,
      practitionerName: practitionerName ?? this.practitionerName,
      paymentMethodTitle: paymentMethodTitle ?? this.paymentMethodTitle,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      status: status,
    );
  }

  /// Parses a record of `wc-appointments/v1/appointments`.
  ///
  /// `start` and `end` are unix timestamps in the site timezone.
  static BookingConfirmation? fromJson(Map json) {
    final id = int.tryParse('${json['id']}');
    final start = int.tryParse('${json['start']}');
    final end = int.tryParse('${json['end']}');
    if (id == null || start == null || end == null) {
      return null;
    }
    return BookingConfirmation(
      id: id,
      start: DateTime.fromMillisecondsSinceEpoch(start * 1000),
      end: DateTime.fromMillisecondsSinceEpoch(end * 1000),
      timezone: json['timezone']?.toString(),
      status: json['status']?.toString(),
    );
  }
}
