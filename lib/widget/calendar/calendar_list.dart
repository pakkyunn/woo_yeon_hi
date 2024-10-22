import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/screen/calendar/calendar_detail_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';
import 'package:woo_yeon_hi/style/text_style.dart';

import '../../dao/schedule_dao.dart';
import '../../provider/schedule_provider.dart';

class CalendarList extends StatefulWidget {
  CalendarList(this.scheduleList, {super.key});
  List<Map<String, dynamic>> scheduleList;

  @override
  State<CalendarList> createState() => _CalendarListState();
}

class _CalendarListState extends State<CalendarList> {

  // 일정 데이터를 날짜별로 그룹화하여 담을 변수
  Map<String, List<Map<String, dynamic>>> _groupedScheduleMap = {};

  @override
  void initState() {
    super.initState();

    setState(() {
      _groupedScheduleMap = _groupSameDate(widget.scheduleList);
    });
  }

  // 같은 날짜의 일정을 날짜별로 그룹화하는 함수
  Map<String, List<Map<String, dynamic>>> _groupSameDate(List<Map<String, dynamic>> scheduleData) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    for (var schedule in scheduleData) {
      String date = schedule['schedule_start_date'];  // 시작일을 맵에서 비교할 key 값

      // key 값이 없다면 빈 리스트 반환
      if (groupedData[date] == null) {
        groupedData[date] = [];
      }
      // key 값이 있다면 맵 데이터 추가
      groupedData[date]!.add(schedule);
    }

    // 시작 날짜의 key 를 담아서 return
    return groupedData;
  }

  
  @override
  Widget build(BuildContext context) {

    // 날짜 키를 DateTime으로 변환 후 정렬
    List<String> sortKey = _groupedScheduleMap.keys.toList()
      ..sort((a, b){
        DateFormat dateFormat = DateFormat('yy. M. d.(E)', 'ko_KR');
        DateTime dateA = dateFormat.parse(a); // DateTime 객체로 변환
        DateTime dateB = dateFormat.parse(b);

        // 최신 날짜가 먼저 오도록 정렬
        return dateB.compareTo(dateA);
      });

    return Expanded(
      child: _groupedScheduleMap.isEmpty
          ? const Center(
              child: Text("일정이 없습니다", style: TextStyleFamily.hintTextStyle),
            )
          : ListView.builder(
              itemCount: sortKey.length,  // 최신순 정렬한 데이터
              itemBuilder: (context, index) {
                String scheduleDate = sortKey[index];   // 날짜의 key 값을 담을 변수
                List<Map<String, dynamic>> scheduleList = _groupedScheduleMap[scheduleDate]!;  // key 값에 해당하는 모든 일정을 담을 변수
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        scheduleDate,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: FontFamily.mapleStoryLight,
                          color: ColorFamily.black,
                        ),
                      ),
                    ),
                    ...scheduleList.map((schedule) => InkWell(
                      splashFactory: NoSplash.splashFactory,
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => CalendarDetailScreen(schedule))
                        );
                      },
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Divider(color: ColorFamily.gray),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 5, height: 35,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: ColorFamily.green
                                      ),
                                    )
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  schedule['schedule_title'],
                                  style: TextStyleFamily.normalTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 30),
                  ],
                );
              },
          ),
    );
  }
}

