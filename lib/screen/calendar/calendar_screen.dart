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

  // @override
  // void initState() {
  //   super.initState();
  //   _loadData();
  // }

  // Future<void> _loadData() async {
  //   await getScheduleData(); // 비동기로 데이터를 가져옵니다.
  //
  //   // 데이터를 가져온 후 setState를 호출하여 상태를 업데이트
  //   setState(() {
  //     isDataLoaded = true;
  //   });
  // }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //
  //   getScheduleData();
  // }
  //
  // // 데이터를 가져옴
  // Future<bool> getScheduleData() async {
  //   // 캘린더 데이터 가져오기
  //   var calendarScreenProvider = Provider.of<CalendarScreenProvider>(context, listen: false);
  //   calendarScreenProvider.setScheduleList(await getCalendarScreenScheduleList(context));
  //
  //   return true;
  // }

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
                  ? Text(_setSelectedMonthTitle(provider.focusedDay),
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
                    provider.setFocusedDay(DateTime.now());
                  },
                  icon: _isCalendar
                      ? SvgPicture.asset("lib/assets/icons/list.svg")
                      : SvgPicture.asset("lib/assets/icons/calendar.svg"),
                ),
                IconButton(
                  onPressed: () async {
                    bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CalendarAddScreen()),
                    );
                    if (result == true) {
                      // 데이터 갱신 로직
                      final provider = Provider.of<CalendarScreenProvider>(context, listen: false);
                      var scheduleList = await getCalendarScreenScheduleList(context); // 데이터를 불러오는 메서드 호출
                      provider.setScheduleList(scheduleList);
                    }
                    // Navigator.of(context).push(MaterialPageRoute(
                    //     builder: (context) => const CalendarAddScreen()));
                  },
                  icon: SvgPicture.asset('lib/assets/icons/add.svg'),
                ),
              ],
            ),
            body:
            // isDataLoaded ?
            _isCalendar
                ? CalendarDate()
                : CalendarList()
          //     : const Center(
          //   child: CircularProgressIndicator(
          //     color: ColorFamily.pink,
          //   ),
          // )
        );
      //   return FutureBuilder(
      //       future: getScheduleData(),
      //       builder: (context, snapshot) {
      //         if (snapshot.hasData == false) {
      //           return const Center(
      //             child: CircularProgressIndicator(
      //               color: ColorFamily.pink,
      //             ),
      //           );
      //         } else if (snapshot.hasError) {
      //           return const Text(
      //             "오류 발생",
      //             style: TextStyleFamily.normalTextStyle,
      //           );
      //         } else {
      //
      //         }
      //
      // });
  });}

  String _setSelectedMonthTitle(DateTime selectedDate) {
    DateFormat formatter = DateFormat('yy년 M월');
    return formatter.format(selectedDate);
  }
}
