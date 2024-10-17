import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:woo_yeon_hi/dao/d_day_dao.dart';
import 'package:woo_yeon_hi/provider/login_register_provider.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';
import 'package:woo_yeon_hi/style/text_style.dart';
import 'package:woo_yeon_hi/utils.dart';

import '../../model/dDay_model.dart';
import '../../provider/dDay_provider.dart';
import '../../widget/dDay/dDay_make_top_app_bar.dart';
import '../../widget/register/d_day_setting_calendar.dart';

class dDayMakeScreen extends StatefulWidget {
  const dDayMakeScreen({super.key});

  @override
  State<dDayMakeScreen> createState() => _dDayMakeScreenState();
}

class _dDayMakeScreenState extends State<dDayMakeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DdayMakeProvider>(builder: (context, provider, child) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            backgroundColor: ColorFamily.cream,
            appBar: dDayMakeTopAppBar(),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                child: Column(
                  children: [
                    // 타이틀 입력
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "디데이 이름",
                            style: TextStyleFamily.dialogButtonTextStyle,
                          )
                        ],
                      ),
                    ),
                    TextField(
                      controller: provider.titleController,
                      cursorColor: ColorFamily.black,
                      style: TextStyleFamily.normalTextStyle,
                      maxLines: 1,
                      maxLength: 20,
                      decoration: const InputDecoration(
                        counter: SizedBox(),
                        hintStyle: TextStyleFamily.hintTextStyle,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: ColorFamily.black),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: ColorFamily.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // d-day 설명
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "디데이 설명",
                            style: TextStyleFamily.dialogButtonTextStyle,
                          )
                        ],
                      ),
                    ),
                    TextField(
                      controller: provider.descriptionController,
                      cursorColor: ColorFamily.black,
                      style: TextStyleFamily.normalTextStyle,
                      maxLines: 1,
                      maxLength: 20,
                      decoration: const InputDecoration(
                        counter: SizedBox(),
                        hintStyle: TextStyleFamily.hintTextStyle,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: ColorFamily.black),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: ColorFamily.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "디데이 선택",
                            style: TextStyleFamily.dialogButtonTextStyle,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 날짜 표시 미리보기
                    Container(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 100,
                      decoration: BoxDecoration(
                        color: ColorFamily.white,
                        borderRadius: BorderRadius.circular(20)),
                      child:
                      provider.selectedDay == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("날짜를 선택해주세요", style: TextStyleFamily.normalTextStyle_pink),
                            ],
                          )
                        : _ymdFormatDate(provider.selectedDay!) == _today()
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("D-day", style: exampleTextStyle),
                            ],
                          )
                         : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("선택한 날짜로부터 오늘은", style: TextStyleFamily.normalTextStyle_pink),
                              const SizedBox(height: 10),
                              Text(
                                  _ymdFormatDate(provider.selectedDay!).difference(_today()).inDays < 0
                                  ? "D+${(provider.selectedDay!.difference(_today()).inDays).abs()+1}"
                                  : "D-${(provider.selectedDay!.difference(_today()).inDays).abs()}"
                                , style: exampleTextStyle),
                            ],
                           ),
                    ),
                    const SizedBox(height: 10),
                    // 캘린더
                    Wrap(
                      children: [
                        Card(
                          elevation: 1,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20), color: ColorFamily.white),
                                child: TableCalendar(
                                  // main 에서 받음
                                  locale: 'ko_KR',
                                  // 최소 날짜
                                  firstDay: DateTime.utc(1900, 1, 1),
                                  // 최대 날짜
                                  lastDay: DateTime.utc(2999, 12, 31),
                                  // 현재 선택
                                  focusedDay: provider.focusedDay,
                                  rowHeight: MediaQuery.of(context).size.height*0.05,
                                  daysOfWeekHeight: MediaQuery.of(context).size.height*0.055,
                                  availableGestures: AvailableGestures.none,
                                  headerStyle: const HeaderStyle(
                                      titleCentered: true,
                                      formatButtonVisible: false,
                                      titleTextStyle: TextStyleFamily
                                          .appBarTitleBoldTextStyle,
                                  ),
                                  daysOfWeekStyle: const DaysOfWeekStyle(
                                    weekdayStyle:
                                    TextStyleFamily.normalTextStyle, // 평일
                                    weekendStyle:
                                    TextStyleFamily.normalTextStyle, // 주말
                                  ),
                                  calendarBuilders: CalendarBuilders(
                                    // 기본 월의 빌더
                                    defaultBuilder: (context, day, focusedDay) {
                                      return Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          DateFormat('d').format(day),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: isWeekend(day)
                                                  ? Colors.red
                                                  : isSaturday(day)
                                                  ? Colors.blueAccent
                                                  : ColorFamily.black,
                                              fontFamily:
                                              FontFamily.mapleStoryLight),
                                        ),
                                      );
                                    },
                                    // 다른 월의 빌더
                                    outsideBuilder: (context, day, focusedDay) {
                                      return Container(
                                        alignment: Alignment.center,
                                        child: Text(DateFormat('d').format(day),
                                            textAlign: TextAlign.center,
                                            style:
                                            TextStyleFamily.hintTextStyle),
                                      );
                                    },
                                    // 비활성화된 날짜
                                    disabledBuilder:
                                        (context, day, focusedDay) {
                                      return Container(
                                        alignment: Alignment.center,
                                        child: Text(DateFormat('d').format(day),
                                            textAlign: TextAlign.center,
                                            style:
                                            TextStyleFamily.hintTextStyle),
                                      );
                                    },
                                    // 선택된 날짜
                                    selectedBuilder:
                                        (context, day, focusedDay) {
                                      return Container(
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: const BoxDecoration(
                                            color: ColorFamily.pink,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              DateFormat('d').format(day),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: isWeekend(day)
                                                    ? ColorFamily.white
                                                    : isSaturday(day)
                                                    ? ColorFamily.white
                                                    : ColorFamily.black,
                                                fontFamily:
                                                FontFamily.mapleStoryLight,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    // 오늘 날짜
                                    todayBuilder: (context, day, focusedDay) {
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
                                    },
                                  ),
                                  // 선택된 날짜
                                  selectedDayPredicate: (day) {
                                    return isSameDay(provider.selectedDay, day);
                                  },
                                  // 날짜 선택
                                  onDaySelected: (selectedDay, focusedDay) {
                                    setState(() {
                                      provider.setSelectedDay(selectedDay);
                                      provider.setFocusedDay(focusedDay);
                                    });
                                  },
                                  // 화면이 바뀔때
                                  onPageChanged: (focusedDay) {
                                    provider.setFocusedDay(focusedDay);
                                  },
                                )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      });
  }

  // 주말인지
  bool isWeekend(DateTime day) {
    return day.weekday == DateTime.sunday;
  }

  // 토요일인지
  bool isSaturday(DateTime day) {
    return day.weekday == DateTime.saturday;
  }

  // 날짜 계산용 오늘 날짜
  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _ymdFormatDate(DateTime providerSelectedDay){
    DateTime ymdFormatDate = DateTime(providerSelectedDay.year, providerSelectedDay.month, providerSelectedDay.day);
    return ymdFormatDate;
  }
}

TextStyle exampleTextStyle = const TextStyle(
    fontFamily: FontFamily.mapleStoryBold,
    fontSize: 20,
    color: ColorFamily.pink);

TextStyle exampleErrorTextStyle = const TextStyle(
    fontFamily: FontFamily.mapleStoryBold,
    fontSize: 12,
    color: ColorFamily.pink);

