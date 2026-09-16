import 'package:inspireui/inspireui.dart';
import 'package:intl/intl.dart';

import '../../core/helpers/helpers.dart';

class StoreHour {
  bool? isDisablePurchase;

  List<int> offDays = [];
  List<StoreWorkingHour> workingHours = [];

  StoreHour.fromWCFM(Map json) {
    isDisablePurchase = FluxUiHelper.formatBool(json['disable_purchase']);
    final dayTime = json['day_times'];
    if (dayTime is List) {
      for (var i = 0; i < dayTime.length; i++) {
        workingHours.add(StoreWorkingHour.fromWCFM(i + 1, dayTime[i]));
      }
    }

    final rawOffDays = json['off_days'];
    if (rawOffDays is List) {
      for (var time in rawOffDays) {
        final offDay = FluxUiHelper.formatInt(time);
        if (offDay != null) {
          offDays.add(offDay);
        }
      }
    }
  }

  StoreHour.fromDokan(Map json) {
    isDisablePurchase = false;
    json.forEach((key, value) {
      int weekday;
      switch (key) {
        case 'monday':
          weekday = 1;
          break;
        case 'tuesday':
          weekday = 2;
          break;
        case 'wednesday':
          weekday = 3;
          break;
        case 'thursday':
          weekday = 4;
          break;
        case 'friday':
          weekday = 5;
          break;
        case 'saturday':
          weekday = 6;
          break;
        case 'sunday':
          weekday = 7;
          break;
        default:
          weekday = 1;
          break;
      }
      if (value is! Map) {
        offDays.add(weekday);
        return;
      }
      if ((FluxUiHelper.formatString(value['status'])?.toLowerCase() ??
              'close') ==
          'close') {
        offDays.add(weekday);
      }
      workingHours.add(StoreWorkingHour.fromDokan(weekday, value));
    });
  }

  bool isOpen() {
    if (!isOffDay()) {
      final now = DateTime.now();
      StoreWorkingHour? todayWorkingHour;
      for (final workingHour in workingHours) {
        if (workingHour.weekday == now.weekday) {
          todayWorkingHour = workingHour;
          break;
        }
      }
      if (todayWorkingHour == null || todayWorkingHour.hours.isEmpty) {
        return true;
      }
      for (var hour in todayWorkingHour.hours) {
        if (hour.start != null && hour.end != null) {
          if (now.isAfter(hour.start!) && now.isBefore(hour.end!)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool isOffDay() {
    final now = DateTime.now();
    return offDays.contains(now.weekday);
  }
}

class StoreWorkingHour {
  int? weekday;
  List<WorkingHour> hours = [];

  StoreWorkingHour.fromWCFM(this.weekday, dayTimes) {
    if (dayTimes is List) {
      for (var hour in dayTimes) {
        if (hour is Map) {
          final startTime = FluxUiHelper.formatString(hour['start']);
          final endTime = FluxUiHelper.formatString(hour['end']);
          if (startTime != null && endTime != null) {
            hours.add(WorkingHour.fromWCFM(startTime, endTime));
          }
        }
      }
    }
    if (dayTimes is Map) {
      dayTimes.forEach((key, value) {
        if (value is Map) {
          final startTime = FluxUiHelper.formatString(value['start']);
          final endTime = FluxUiHelper.formatString(value['end']);
          if (startTime != null && endTime != null) {
            hours.add(WorkingHour.fromWCFM(startTime, endTime));
          }
        }
      });
    }
  }

  StoreWorkingHour.fromDokan(this.weekday, json) {
    try {
      if (json is! Map) {
        return;
      }
      if ((FluxUiHelper.formatString(json['status'])?.toLowerCase() ??
              'close') !=
          'close') {
        var openTimes = json['opening_time'];
        var closeTimes = json['closing_time'];
        if (openTimes is List && closeTimes is List) {
          final timeCount = openTimes.length < closeTimes.length
              ? openTimes.length
              : closeTimes.length;
          for (var i = 0; i < timeCount; i++) {
            final openTime = _parseDokanTime(openTimes[i]);
            final closeTime = _parseDokanTime(closeTimes[i]);
            if (openTime != null && closeTime != null) {
              hours.add(WorkingHour.fromDokan(openTime, closeTime));
            }
          }
        } else {
          final openTime = _parseDokanTime(openTimes);
          final closeTime = _parseDokanTime(closeTimes);
          if (openTime != null && closeTime != null) {
            hours.add(WorkingHour.fromDokan(openTime, closeTime));
          }
        }
      }
    } catch (e) {
      printLog(e.toString());
    }
  }
}

String? _parseDokanTime(dynamic data) {
  return FluxUiHelper.formatString(data)?.replaceAll('h', ':');
}

class WorkingHour {
  DateTime? start;
  DateTime? end;

  WorkingHour.fromWCFM(String startTime, String endTime) {
    start = getDateTimeFromTime(startTime);
    end = getDateTimeFromTime(endTime);
  }

  WorkingHour.fromDokan(String startTime, String endTime) {
    start = getDateTimeFromTime(startTime);
    end = getDateTimeFromTime(endTime);
  }

  DateTime? getDateTimeFromTime(String time) {
    final now = DateTime.now();
    time = time.toUpperCase();
    try {
      if (time.contains('AM') || time.contains('PM')) {
        final timeOfDay = DateFormat.jm('en').parse(time);
        return now.copyWith(hour: timeOfDay.hour, minute: timeOfDay.minute);
      }

      final timeOfDay = DateFormat('HH:mm', 'en').parse(time);
      return now.copyWith(hour: timeOfDay.hour, minute: timeOfDay.minute);
    } catch (e) {
      printError('Failed to parse timeOfDay');
      return null;
    }
  }
}
