import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:woo_yeon_hi/dao/schedule_dao.dart';
import 'package:woo_yeon_hi/screen/calendar/calendar_detail_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';
import 'package:woo_yeon_hi/style/text_style.dart';
import 'package:woo_yeon_hi/utils.dart';

import '../../enums.dart';
import '../../provider/login_register_provider.dart';
import '../../provider/schedule_provider.dart';

class CalendarDate extends StatefulWidget {
  CalendarDate({super.key});

  @override
  State<CalendarDate> createState() => _CalendarDateState();
}

class _CalendarDateState extends State<CalendarDate> {
  // final List<Map<String, dynamic>> _selectedDayScheduleList = []; // 일정 데이터를 담을 변수

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // 주말인지
  bool isWeekend(DateTime day) {
    return day.weekday == DateTime.sunday;
  }

  // 토요일인지
  bool isSaturday(DateTime day) {
    return day.weekday == DateTime.saturday;
  }

  // @override
  // void initState() {
  //   super.initState();
  //
  //   addSelectedDaySchedule();
  //   sortSelectedDaySchedule();
  //   // _selectedDay = Provider.of<CalendarScreenProvider>(context, listen: false).selectedDay;
  //   // _focusedDay = Provider.of<CalendarScreenProvider>(context, listen: false).focusedDay;
  // }

  Future<bool> loadScheduleData() async {
    await getScheduleData();
    addSelectedDaySchedule();
    sortSelectedDaySchedule();

    return true;
  }

  Future<void> getScheduleData() async {
    var calendarScreenProvider =
        Provider.of<CalendarScreenProvider>(context, listen: false);
    calendarScreenProvider
        .setScheduleList(await getCalendarScreenScheduleList(context));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    addSelectedDaySchedule();
    sortSelectedDaySchedule();
  }

  // 선택한 날짜에 해당하는 스케쥴만 리스트에 담기
  void addSelectedDaySchedule() {
    var provider = Provider.of<CalendarScreenProvider>(context, listen: false);
    provider.selectedDayScheduleList.clear();

    for (var schedule in provider.scheduleList) {
      var startDay = stringToDate(schedule["schedule_start_date"]);
      var finishDay = stringToDate(schedule["schedule_finish_date"]);
      var scheduleStartDate =
          DateTime(startDay.year, startDay.month, startDay.day);
      var scheduleFinishDate =
          DateTime(finishDay.year, finishDay.month, finishDay.day);
      var selectedDate =
          DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

      if ((scheduleStartDate.isBefore(selectedDate) ||
              scheduleStartDate.isAtSameMomentAs(selectedDate)) &&
          (scheduleFinishDate.isAtSameMomentAs(selectedDate) ||
              scheduleFinishDate.isAfter(selectedDate))) {
        provider.selectedDayScheduleList.add(schedule);
      }
    }
  }

  void sortSelectedDaySchedule() {
    var provider = Provider.of<CalendarScreenProvider>(context, listen: false);

    provider.selectedDayScheduleList.sort((a, b) {
      DateTime startDateA = _parseDate(a['schedule_start_date']);
      DateTime finishDateA = _parseDate(a['schedule_finish_date']);
      DateTime startDateB = _parseDate(b['schedule_start_date']);
      DateTime finishDateB = _parseDate(b['schedule_finish_date']);

      TimeOfDay startTimeA = _parseTime(a['schedule_start_time']);
      TimeOfDay finishTimeA = _parseTime(a['schedule_finish_time']);
      TimeOfDay startTimeB = _parseTime(b['schedule_start_time']);
      TimeOfDay finishTimeB = _parseTime(b['schedule_finish_time']);

      DateTime selectedDay =
          DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

      bool isAMiddleSchedule =
          selectedDay != startDateA && selectedDay != finishDateA;
      bool isBMiddleSchedule =
          selectedDay != startDateB && selectedDay != finishDateB;

      // 1. a만 중간일정인 경우
      if (isAMiddleSchedule && !isBMiddleSchedule) {
        return -1;
      }

      // 2. b만 중간일정인 경우
      else if (isBMiddleSchedule && !isAMiddleSchedule) {
        return 1;
      }

      // 3. a와 b 둘 다 중간일정인 경우
      else if (isAMiddleSchedule && isBMiddleSchedule) {
        return a['schedule_title'].compareTo(b['schedule_title']);
      }

      // 4. a와 b 둘 다 시작일정인 경우
      else if (selectedDay == startDateA && selectedDay == startDateB) {
        if (_compareTimes(startTimeA, startTimeB) != 0) {
          return _compareTimes(startTimeA, startTimeB);
        } else {
          return a['schedule_title'].compareTo(b['schedule_title']);
        }
      }
      // 4. a와 b 둘 다 종료일정인 경우
      else if (selectedDay == finishDateA && selectedDay == finishDateB) {
        if (_compareTimes(finishTimeA, finishTimeB) != 0) {
          return _compareTimes(finishTimeA, finishTimeB);
        } else {
          return a['schedule_title'].compareTo(b['schedule_title']);
        }
      }

      // 5. a가 시작일정이고 b가 종료일정인 경우
      else if (selectedDay == startDateA && selectedDay == finishDateB) {
        return _compareTimes(startTimeA, finishTimeB);
      }

      // 6. a가 종료일정이고 b가 시작일정인 경우
      else if (selectedDay == finishDateA && selectedDay == startDateB) {
        return _compareTimes(finishTimeA, startTimeB);
      }
      return a['schedule_title'].compareTo(b['schedule_title']);
    });
  }

  DateTime _parseDate(String dateString) {
    DateFormat format = DateFormat('yyyy. MM. dd.');
    return format.parse(dateString.substring(0, 13)); // 요일은 제외
  }

  TimeOfDay _parseTime(String timeStr) {
    var parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  int _compareTimes(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour == time2.hour) {
      return time1.minute.compareTo(time2.minute).sign;
    } else {
      return time1.hour.compareTo(time2.hour).sign;
    }
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;

    return Consumer<CalendarScreenProvider>(
        builder: (context, provider, child) {
      return FutureBuilder(
          future: loadScheduleData(),
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return const Center(
                child: CircularProgressIndicator(
                  color: ColorFamily.pink,
                ),
              );
            } else if (snapshot.hasError) {
              return const Text(
                "오류 발생",
                style: TextStyleFamily.normalTextStyle,
              );
            } else {
              return Column(
                children: [
                  SizedBox(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        TableCalendar(
                          // sixWeekMonthsEnforced: true,
                          availableGestures: AvailableGestures.horizontalSwipe,
                          firstDay: stringToDate(
                              Provider.of<UserProvider>(context, listen: false)
                                  .loveDday),
                          lastDay: DateTime(2099, 12, 31),
                          focusedDay: _focusedDay,
                          locale: 'ko_kr',
                          rowHeight: MediaQuery.of(context).size.height * 0.05,
                          daysOfWeekHeight:
                              MediaQuery.of(context).size.height * 0.055,
                          headerVisible: false,
                          headerStyle: const HeaderStyle(
                            titleCentered: true,
                            titleTextStyle:
                                TextStyleFamily.appBarTitleBoldTextStyle,
                            formatButtonVisible: false,
                          ),
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
                                    color: isWeekend(day)
                                        ? Colors.red
                                        : isSaturday(day)
                                            ? Colors.blueAccent
                                            : ColorFamily.black,
                                    fontFamily: FontFamily.mapleStoryLight),
                              ),
                            );
                          }, outsideBuilder: (context, day, focusedDay) {
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
                          }, disabledBuilder: (context, day, focusedDay) {
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
                          }, selectedBuilder: (context, day, focusedDay) {
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
                                        color: isWeekend(day)
                                            ? ColorFamily.white
                                            : isSaturday(day)
                                                ? ColorFamily.white
                                                : ColorFamily.black,
                                        fontFamily: FontFamily.mapleStoryLight),
                                  ),
                                ),
                              ),
                            );
                          }, todayBuilder: (context, day, focusedDay) {
                            return Container(
                              alignment: Alignment.center,
                              child: Text(
                                textAlign: TextAlign.center,
                                DateFormat('d').format(day),
                                style: const TextStyle(
                                    color: ColorFamily.pink,
                                    fontFamily: FontFamily.mapleStoryLight),
                              ),
                            );
                          }, markerBuilder: (context, day, events) {
                            return FutureBuilder(
                                future: isExistOnSchedule(day, context),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData == false) {
                                    return const SizedBox();
                                  } else if (snapshot.hasError) {
                                    return const SizedBox();
                                  } else {
                                    if (snapshot.data == true) {
                                      return Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.only(top: 30),
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                              color: (day == _selectedDay)
                                                  ? ColorFamily.white
                                                  : ColorFamily.pink,
                                              shape: BoxShape.circle),
                                        ),
                                      );
                                    } else {
                                      return const SizedBox();
                                    }
                                  }
                                });
                          }),
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                            provider.setSelectedDay(selectedDay);
                            provider.selectedDayScheduleList.clear();
                            addSelectedDaySchedule();
                            sortSelectedDaySchedule();
                          },
                          onPageChanged: (focusedDay) {
                            setState(() {
                              _selectedDay = focusedDay;
                              _focusedDay = focusedDay;
                            });
                            provider.setSelectedDay(focusedDay);
                            provider.setFocusedDay(focusedDay);
                          },
                        ),
                      ],
                    ),
                  )),
                  Expanded(
                    // 일별 일정 리스트
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Container(
                        color: Colors.white,
                        child: provider.selectedDayScheduleList.isEmpty
                            ? const Center(
                                child: Text("일정이 없습니다",
                                    style: TextStyleFamily.hintTextStyle),
                              )
                            : ListView.separated(
                                itemCount:
                                    provider.selectedDayScheduleList.length,
                                itemBuilder: (context, index) {
                                  var schedule =
                                      provider.selectedDayScheduleList[
                                          index]; // 순서값을 담은 변수
                                  return Padding(
                                    padding: index == 0
                                        ? const EdgeInsets.fromLTRB(
                                            20, 10, 20, 0)
                                        : const EdgeInsets.symmetric(
                                            horizontal: 20),
                                    child: InkWell(
                                      onTap: () async {
                                        provider.setSelectedScheduleFromIndex(
                                            index);
                                        await Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CalendarDetailScreen()));
                                        addSelectedDaySchedule();
                                        sortSelectedDaySchedule();
                                      },
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: SizedBox(
                                              width: 5,
                                              height: 35,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: ScheduleColorType
                                                      .values
                                                      .firstWhere((e) =>
                                                          e.typeIdx ==
                                                          schedule[
                                                              "schedule_color"])
                                                      .colorCode,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            schedule['schedule_title'],
                                            style:
                                                TextStyleFamily.normalTextStyle,
                                          ),
                                          const Spacer(),
                                          schedule['schedule_start_date'] ==
                                                  schedule[
                                                      'schedule_finish_date']
                                              ? // 하루종일 일정인 경우
                                              schedule['schedule_start_time'] ==
                                                          "00:00" &&
                                                      schedule[
                                                              'schedule_finish_time'] ==
                                                          "23:59"
                                                  ? const Text("하루 종일",
                                                      style: TextStyleFamily
                                                          .normalTextStyle)
                                                  : Text(
                                                      "${schedule['schedule_start_time']} - ${schedule['schedule_finish_time']}",
                                                      style: TextStyleFamily
                                                          .normalTextStyle)
                                              : schedule['schedule_start_date'] ==
                                                      dateToStringWithDay(
                                                          _selectedDay)
                                                  ? Text(
                                                      "${schedule['schedule_start_time']} ~ ",
                                                      style: TextStyleFamily
                                                          .normalTextStyle,
                                                    )
                                                  : schedule['schedule_finish_date'] ==
                                                          dateToStringWithDay(
                                                              _selectedDay)
                                                      ? Text(
                                                          " ~ ${schedule['schedule_finish_time']}",
                                                          style: TextStyleFamily
                                                              .normalTextStyle,
                                                        )
                                                      : const Text(
                                                          " ~ ",
                                                          style: TextStyleFamily
                                                              .normalTextStyle,
                                                        )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Divider(color: ColorFamily.gray),
                                  );
                                },
                              ),
                      ),
                    ),
                  )
                ],
              );
            }
          });
    });
  }
}
