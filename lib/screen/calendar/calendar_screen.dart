import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/schedule_dao.dart';
import 'package:woo_yeon_hi/screen/calendar/calendar_add_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/text_style.dart';
import 'package:woo_yeon_hi/widget/calendar/calendar_date.dart';
import 'package:woo_yeon_hi/widget/calendar/calendar_list.dart';

import '../../provider/schedule_provider.dart';
import '../../utils.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool isDataLoaded = false;
  bool _isCalendar = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await getScheduleData(); // 비동기로 데이터를 가져옵니다.

    // 데이터를 가져온 후 setState를 호출하여 상태를 업데이트
    setState(() {
      isDataLoaded = true;
    });
  }

  // 데이터를 가져옴
  Future<void> getScheduleData() async {
    // 캘린더 데이터 가져오기
    var calendarScreenProvider = Provider.of<CalendarScreenProvider>(context, listen: false);
    var scheduleList = await getCalendarScreenScheduleList(context);
    calendarScreenProvider.setScheduleList(scheduleList);
  }

  @override
  Widget build(BuildContext context) {
      return Consumer<CalendarScreenProvider>(builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: ColorFamily.cream,
          appBar: AppBar(
            backgroundColor: ColorFamily.cream,
            surfaceTintColor: ColorFamily.cream,
            centerTitle: true,
            scrolledUnderElevation: 0,
            title: _isCalendar
                ? Text(_setFocusedMonthTitle(provider.focusedDay),
                style: TextStyleFamily.appBarTitleBoldTextStyle)
                : const Text("일정 목록",
                style: TextStyleFamily.appBarTitleBoldTextStyle),
            leading: IconButton(
              splashColor: Colors.transparent,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: SvgPicture.asset("lib/assets/icons/arrow_back.svg"),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isCalendar = !_isCalendar;
                  });
                },
                icon: _isCalendar
                    ? SvgPicture.asset("lib/assets/icons/list.svg")
                    : SvgPicture.asset("lib/assets/icons/calendar.svg"),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CalendarAddScreen()));
                },
                icon: SvgPicture.asset('lib/assets/icons/add.svg'),
              ),
            ],
          ),
          body: isDataLoaded
            ? _isCalendar
              ? CalendarDate(provider.scheduleList)
              : CalendarList(provider.scheduleList)
            : const Center(
                child: CircularProgressIndicator(
                  color: ColorFamily.pink,
                ),
              )
        );
      });
  }

  String _setFocusedMonthTitle(DateTime selectedDate) {
    DateFormat formatter = DateFormat('yy년 M월');
    return formatter.format(selectedDate);
  }
}
