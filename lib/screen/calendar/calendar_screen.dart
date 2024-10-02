import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:woo_yeon_hi/dao/schedule_dao.dart';
import 'package:woo_yeon_hi/screen/calendar/calendar_add_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/text_style.dart';
import 'package:woo_yeon_hi/widget/calendar/calendar_date.dart';
import 'package:woo_yeon_hi/widget/calendar/calendar_list.dart';


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {

  // 일정 데이터
  List<Map<String, dynamic>> scheduleData = [];

  // 참 거짓으로 상태를 나눔
  bool _isCalendar = true;

  @override
  void initState() {
    super.initState();

    // 화면 생성 시
    getData();
  }

  // 데이터를 가져옴
  Future<void> getData() async {
    var tempScheduleData = await getScheduleData(context);

    setState(() {
      scheduleData = tempScheduleData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorFamily.cream,
      appBar: AppBar(
        backgroundColor: ColorFamily.cream,
        surfaceTintColor: ColorFamily.cream,
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: _isCalendar
            ? Text(_getCurrentMonth(), style: TextStyleFamily.appBarTitleBoldTextStyle)
            : const Text("일정 목록", style: TextStyleFamily.appBarTitleBoldTextStyle),
        leading: IconButton(
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
            icon:
            _isCalendar
                ? SvgPicture.asset("lib/assets/icons/list.svg")
                : SvgPicture.asset("lib/assets/icons/calendar.svg"),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CalendarAddScreen()));
              },
            icon: SvgPicture.asset('lib/assets/icons/add.svg'),
          ),
        ],
      ),
      body: _isCalendar ? CalendarDate(scheduleData) : CalendarList(scheduleData),
    );
  }

  String _getCurrentMonth() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy년 M월');
    return formatter.format(now);
  }

}
