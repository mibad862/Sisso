import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:inspireui/extensions/color_extension.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/entities/order_delivery_date.dart';
import '../../../models/index.dart';

class DeliveryCalendar extends StatefulWidget {
  final List<OrderDeliveryDate> dates;
  const DeliveryCalendar({super.key, required this.dates});

  @override
  State<DeliveryCalendar> createState() => _DeliveryCalendarState();
}

class _DeliveryCalendarState extends State<DeliveryCalendar> {
  final List<DateTime> _list = [];

  DateTime _currentDate = DateTime.now();
  String _currentMonth = DateFormat.yMMM().format(DateTime.now());
  DateTime _targetDateTime = DateTime.now();
  OrderDeliveryDate? _currentOrderDeliveryDate;

  String _getTimeSlotLabel(OrderDeliveryTimeSlot slot) {
    final value = slot.time ?? '';
    final schedule = _currentOrderDeliveryDate?.schedule;
    if (schedule != null && schedule.isAsapSlotTime(value)) {
      return schedule.asapLabel.isNotEmpty
          ? schedule.asapLabel
          : S.of(context).asSoonAsPossible;
    }
    return value;
  }

  bool _isAvailableDate(DateTime day) {
    return _list.any((date) => DateUtils.isSameDay(date, day));
  }

  Widget _buildDay({
    required BuildContext context,
    required DateTime day,
    required bool isSelectedDay,
    required bool isToday,
    required bool isPrevMonthDay,
    required bool isNextMonthDay,
  }) {
    final theme = Theme.of(context);
    final isAvailable = _isAvailableDate(day);
    final isOutsideMonth = isPrevMonthDay || isNextMonthDay;
    final isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    Color textColor;
    Color? backgroundColor;
    BoxBorder? border;
    var fontWeight = FontWeight.w500;

    if (isSelectedDay) {
      textColor = Colors.white;
      backgroundColor = theme.primaryColor;
      fontWeight = FontWeight.w700;
    } else if (isOutsideMonth) {
      textColor = theme.colorScheme.secondary.withValueOpacity(0.18);
    } else if (isAvailable) {
      textColor = isWeekend ? Colors.redAccent : theme.primaryColor;
      fontWeight = FontWeight.w700;
    } else {
      textColor = isWeekend
          ? Colors.redAccent.withValueOpacity(0.35)
          : theme.colorScheme.secondary.withValueOpacity(0.32);
    }

    if (isToday && !isSelectedDay) {
      border = Border.all(
        color: isAvailable
            ? theme.primaryColor
            : theme.colorScheme.secondary.withValueOpacity(0.35),
      );
    }

    return Center(
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Text(
          '${day.day}',
          style: TextStyle(color: textColor, fontWeight: fontWeight),
        ),
      ),
    );
  }

  void _selectDeliveryDate(OrderDeliveryDate selectedDate) {
    _currentDate = selectedDate.dateTime!;
    _currentOrderDeliveryDate = selectedDate;

    final cartModel = context.read<CartModel>();
    cartModel.setOrderDeliveryDate(selectedDate);
    cartModel.setOrderDeliveryTimeSlot(selectedDate.selectedTimeSlot);
  }

  void _getDates() {
    _selectDeliveryDate(widget.dates.first);

    for (var element in widget.dates) {
      _list.add(element.dateTime!);
    }
  }

  void _updateDate(DateTime date) {
    if (_list.contains(date)) {
      final index = widget.dates.indexWhere(
        (element) => element.dateTime == date,
      );
      if (index != -1) {
        _selectDeliveryDate(widget.dates[index]);
      }
      setState(() {});
    }
  }

  void _updateTimeSlot(OrderDeliveryTimeSlot? slot) {
    final selectedDate = _currentOrderDeliveryDate;
    if (selectedDate == null) {
      return;
    }
    setState(() {
      selectedDate.selectedTimeSlot = slot;
    });
    final cartModel = context.read<CartModel>();
    cartModel.setOrderDeliveryTimeSlot(slot);
  }

  @override
  void initState() {
    _getDates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppModel>();
    final theme = Theme.of(context);
    final deliveryTimeLabel =
        _currentOrderDeliveryDate?.schedule.deliveryTimeSlotLabel.isNotEmpty ==
            true
        ? _currentOrderDeliveryDate!.schedule.deliveryTimeSlotLabel
        : S.of(context).deliveryTime;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        spacing: 10.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 25.0,
            children: [
              Expanded(
                child: Text(
                  _currentMonth,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  final today = DateTime.now();
                  setState(() {
                    _targetDateTime = DateTime(today.year, today.month);
                    _currentMonth = DateFormat.yMMM().format(_targetDateTime);
                  });
                },
                child: Text(
                  S.of(context).today.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _targetDateTime = DateTime(
                      _targetDateTime.year,
                      _targetDateTime.month - 1,
                    );
                    _currentMonth = DateFormat.yMMM().format(_targetDateTime);
                  });
                },
                child: Text(
                  S.of(context).prev.toUpperCase(),
                  style: theme.textTheme.bodySmall,
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _targetDateTime = DateTime(
                      _targetDateTime.year,
                      _targetDateTime.month + 1,
                    );
                    _currentMonth = DateFormat.yMMM().format(_targetDateTime);
                  });
                },
                child: Text(
                  S.of(context).next.toUpperCase(),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(top: 10.0),
            decoration: BoxDecoration(
              border: Border.all(color: theme.primaryColorLight),
              borderRadius: BorderRadius.circular(9.0),
            ),
            child: CalendarCarousel<Event>(
              locale: app.langCode,
              onDayPressed: (DateTime date, List<Event> events) {
                _updateDate(date);
              },
              weekendTextStyle: const TextStyle(color: Colors.redAccent),
              onCalendarChanged: (DateTime date) {
                setState(() {
                  _targetDateTime = date;
                  _currentMonth = DateFormat.yMMM().format(_targetDateTime);
                });
              },
              thisMonthDayBorderColor: Colors.transparent,
              weekFormat: false,
              showHeader: false,
              height: 300.0,
              targetDateTime: _targetDateTime,
              selectedDateTime: _currentDate,
              daysHaveCircularBorder: true,
              todayButtonColor: Colors.transparent,
              todayBorderColor: Colors.transparent,
              selectedDayButtonColor: theme.primaryColor,
              prevMonthDayBorderColor: Colors.transparent,
              customDayBuilder:
                  (
                    bool isSelectable,
                    int index,
                    bool isSelectedDay,
                    bool isToday,
                    bool isPrevMonthDay,
                    TextStyle textStyle,
                    bool isNextMonthDay,
                    bool isThisMonthDay,
                    DateTime day,
                  ) {
                    return _buildDay(
                      context: context,
                      day: day,
                      isSelectedDay: isSelectedDay,
                      isToday: isToday,
                      isPrevMonthDay: isPrevMonthDay,
                      isNextMonthDay: isNextMonthDay,
                    );
                  },
            ),
          ),
          if ((_currentOrderDeliveryDate?.schedule.enableTimeSlot ?? false) &&
              (_currentOrderDeliveryDate?.timeSlots.isNotEmpty ?? false)) ...[
            Text(
              (_currentOrderDeliveryDate?.schedule.isTimeSlotMandatory ?? false)
                  ? '$deliveryTimeLabel *'
                  : deliveryTimeLabel,
              style: theme.textTheme.bodySmall,
            ),
            DropdownButtonFormField<OrderDeliveryTimeSlot>(
              initialValue: _currentOrderDeliveryDate!.selectedTimeSlot,
              hint: Text(S.of(context).selectTimeSlot),
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: _updateTimeSlot,
              items: _currentOrderDeliveryDate!.timeSlots.map((slot) {
                return DropdownMenuItem<OrderDeliveryTimeSlot>(
                  value: slot,
                  child: Text(_getTimeSlotLabel(slot)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
