import 'package:flutter/material.dart';

import '../../../services/index.dart';
import '../booking.dart';

class BookingChangeNotifier extends BookingModel with ChangeNotifier {
  bool _hasRestrictedDays = false;
  List<String>? _restrictedDays;

  /// Dates (`yyyy-MM-dd`) known to have at least one free slot.
  final Set<String> _availableDates = {};

  /// Month keys (`yyyy-MM`) already fetched for the current staff, so that
  /// navigating back and forth in the calendar does not refetch.
  final Set<String> _loadedMonths = {};

  /// Only becomes true once availability has been fetched successfully.
  /// Until then no day is greyed out because of availability.
  bool _hasAvailabilityData = false;

  bool _isLoadingAvailability = false;

  BookingChangeNotifier({super.idProduct}) {
    final currentDate = DateTime.now();
    setDay(currentDate);
  }

  static String dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}'
      '-${date.day.toString().padLeft(2, '0')}';

  static String _monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  void initRestrictedDays({
    bool? hasRestrictedDays,
    List<String>? restrictedDays,
  }) {
    _hasRestrictedDays = hasRestrictedDays ?? false;
    _restrictedDays = restrictedDays;
    var currentTime = current;
    if (_hasRestrictedDays) {
      var count = 0;
      while (isRestrictedDay(currentTime) && count < 7) {
        count++;
        currentTime = currentTime.add(const Duration(days: 1));
      }
      super.setDay(currentTime);
    }
    notifyListeners();
  }

  /// Fetches which days of [month] have free slots and greys out the rest.
  ///
  /// Results are cached per month, so calling this while scrolling the
  /// calendar is cheap. Pass [force] to bypass the cache.
  Future<void> loadAvailability(
    DateTime month, {
    String? idStaff,
    bool force = false,
  }) async {
    final key = _monthKey(month);
    if (!force && _loadedMonths.contains(key)) {
      return;
    }

    final firstOfMonth = DateTime(month.year, month.month);
    final today = DateTime.now();
    // Never ask for days in the past.
    final minDate = firstOfMonth.isBefore(today) ? today : firstOfMonth;
    final maxDate = DateTime(month.year, month.month + 1, 0);
    if (maxDate.isBefore(minDate)) {
      _loadedMonths.add(key);
      return;
    }

    _isLoadingAvailability = true;
    notifyListeners();

    try {
      final dates = await Services().api.getAvailableBookingDates(
        idProduct,
        idStaff: idStaff,
        minDate: minDate,
        maxDate: maxDate,
      );
      if (dates == null) {
        // Platform cannot report availability: leave every day selectable.
        return;
      }
      _availableDates.addAll(dates);
      _loadedMonths.add(key);
      _hasAvailabilityData = true;
      _skipToSelectableDay();
    } finally {
      _isLoadingAvailability = false;
      notifyListeners();
    }
  }

  /// Drops cached availability, e.g. after the staff member changed.
  void resetAvailability() {
    _availableDates.clear();
    _loadedMonths.clear();
    _hasAvailabilityData = false;
    notifyListeners();
  }

  /// Moves the selection off a greyed-out day onto the next selectable one.
  void _skipToSelectableDay() {
    var candidate = current;
    var count = 0;
    while (isRestrictedDay(candidate) && count < 60) {
      count++;
      candidate = candidate.add(const Duration(days: 1));
    }
    if (count > 0 && !isRestrictedDay(candidate)) {
      super.setDay(candidate);
    }
  }

  DateTime get current {
    var date = DateTime.now();
    return DateTime(
      year ?? date.year,
      month ?? date.month,
      day ?? date.day,
      timeStart?.hour ?? date.hour,
    );
  }

  StaffBookingModel? get staff =>
      (staffs?.isNotEmpty ?? false) ? staffs?.first : null;

  bool get hasRestrictedDays => _hasRestrictedDays || _hasAvailabilityData;

  bool get isLoadingAvailability => _isLoadingAvailability;

  /// True once a month of availability has been fetched successfully.
  bool get hasAvailabilityData => _hasAvailabilityData;

  /// True only for the very first fetch, so moving between months does not
  /// blank out a calendar that already shows useful data.
  bool get isLoadingFirstAvailability =>
      _isLoadingAvailability && !_hasAvailabilityData;

  bool get canBooking {
    if (_hasRestrictedDays && (_restrictedDays?.isEmpty ?? true)) {
      return false;
    }
    return true;
  }

  /// A day is restricted when the product does not trade on that weekday,
  /// or when it has no free appointment slot.
  bool isRestrictedDay(DateTime date) {
    if (_isRestrictedWeekday(date)) {
      return true;
    }
    if (_hasAvailabilityData && !_availableDates.contains(dateKey(date))) {
      return true;
    }
    return false;
  }

  bool _isRestrictedWeekday(DateTime date) {
    // The days are not restricted
    final days = _restrictedDays ?? [];
    if (days.isEmpty) {
      return false;
    }
    // [0->6] Sunday -> Saturday
    final weekday = date.weekday % 7;
    return !days.contains(weekday.toString());
  }

  @override
  void setDay(DateTime date) {
    super.setDay(date);
    notifyListeners();
  }

  @override
  void setHour(DateTime time) {
    super.setHour(time);
    notifyListeners();
  }

  void setStaff(StaffBookingModel? staff) {
    if (staff == null) {
      return;
    }
    staffs = [];
    staffs?.add(staff);
    notifyListeners();
  }

  BookingModel toBookingModel() {
    var value = toJson();
    return BookingModel.fromLocalJson(value);
  }
}
