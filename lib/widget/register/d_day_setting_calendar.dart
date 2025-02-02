import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/utils.dart';
import '../../provider/login_register_provider.dart';
import '../../style/font.dart';
import '../../style/text_style.dart';

class DdaySettingCalendar extends StatefulWidget {
  const DdaySettingCalendar({super.key});

  @override
  State<DdaySettingCalendar> createState() => _DdaySettingCalendarState();
}

class _DdaySettingCalendarState extends State<DdaySettingCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  bool isHoliday(DateTime day) {
    return day.weekday == DateTime.sunday;
  }

  bool isSaturday(DateTime day) {
    return day.weekday == DateTime.saturday;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: ColorFamily.white),
        child: Consumer2<UserProvider, CalendarProvider>(builder: (context, userProvider, calendarProvider, child) {
          return TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.now(),
            focusedDay: calendarProvider.focusedDay,
            locale: 'ko_kr',
            currentDay: DateTime.now(),
            availableGestures: AvailableGestures.horizontalSwipe,
            headerStyle: HeaderStyle(
              titleCentered: true,
              titleTextStyle: TextStyleFamily.appBarTitleBoldTextStyle,
              formatButtonVisible: false,
              leftChevronIcon: SvgPicture.asset(
                  'lib/assets/icons/arrow_left.svg'),
              rightChevronIcon: SvgPicture.asset(
                  'lib/assets/icons/arrow_right.svg'),
            ),
            daysOfWeekHeight: MediaQuery.of(context).size.height*0.055,
            rowHeight: MediaQuery.of(context).size.height*0.055,
            daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyleFamily.normalTextStyle,
                weekendStyle: TextStyleFamily.normalTextStyle),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    textAlign: TextAlign.center,
                    DateFormat('d').format(day),
                    style: TextStyle(
                        color: isHoliday(day)
                            ? Colors.red
                            : isSaturday(day)
                            ? Colors.blueAccent
                            : ColorFamily.black,
                        fontFamily: FontFamily.mapleStoryLight),
                  ),
                );
              },
              outsideBuilder: (context, day, focusedDay) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    textAlign: TextAlign.center,
                    DateFormat('d').format(day),
                    style: const TextStyle(
                        color: ColorFamily.gray,
                        fontFamily: FontFamily.mapleStoryLight),
                  ),
                );
              },
              disabledBuilder: (context, day, focusedDay) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    textAlign: TextAlign.center,
                    DateFormat('d').format(day),
                    style: const TextStyle(
                        color: ColorFamily.gray,
                        fontFamily: FontFamily.mapleStoryLight),
                  ),
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: ColorFamily.pink,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        DateFormat('d').format(day),
                        style: TextStyle(
                            color: isHoliday(day)
                                ? ColorFamily.white
                                : ColorFamily.black,
                            fontFamily: FontFamily.mapleStoryLight),
                      ),
                    ),
                  ),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                return Container(
                  alignment: Alignment.center,
                  child: Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      DateFormat('d').format(day),
                      style: const TextStyle(
                          color: ColorFamily.pink,
                          fontFamily: FontFamily.mapleStoryLight,
                          fontSize: 15),
                    ),
                  ),
                );
              },
            ),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(calendarProvider.selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(calendarProvider.selectedDay, selectedDay)) {
                calendarProvider.setSelectedDay(selectedDay);
                calendarProvider.setFocusedDay(focusedDay);
                userProvider.setLoveDday(dateToStringLight(calendarProvider.selectedDay!));
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              calendarProvider.setFocusedDay(focusedDay);
            },
          );
        },
        ));
  }
}
