import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:woo_yeon_hi/model/schedule_model.dart';
import 'package:woo_yeon_hi/utils.dart';

import '../enums.dart';
import '../provider/login_register_provider.dart';


// ScheduleSequence 로 부터 값을 받아옴
Future<int> getScheduleSequence() async {
  var querySnapShot = await FirebaseFirestore.instance
      .collection('Sequence')
      .doc('ScheduleSequence')
      .get();
  var sequence = querySnapShot.data()!.values.first;

  return sequence;
}

// Firebase - ScheduleSequence 에 저장
Future<void> setScheduleSequence(int sequence) async {
  await FirebaseFirestore.instance
      .collection('Sequence')
      .doc('ScheduleSequence')
      .set({'value' : sequence});
}

// Firebase - ScheduleData 에 저장
Future<void> addScheduleData(Schedule schedule) async {
  await FirebaseFirestore.instance.collection("ScheduleData").add({
    "schedule_idx" : schedule.scheduleIdx,
    "schedule_user_idx" : schedule.scheduleUserIdx,
    "schedule_start_date" : schedule.scheduleStartDate,
    "schedule_finish_date" : schedule.scheduleFinishDate,
    "schedule_start_time" : schedule.scheduleStartTime,
    "schedule_finish_time" : schedule.scheduleFinishTime,
    "schedule_title" : schedule.scheduleTitle,
    "schedule_color" : schedule.scheduleColor,
    "schedule_memo" : schedule.scheduleMemo,
    "schedule_state" : schedule.scheduleState,
  });
}

Future<void> updateScheduleData(Schedule schedule) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('ScheduleData')
      .where('schedule_idx', isEqualTo: schedule.scheduleIdx)
      .get();

  var document = querySnapshot.docs.first;
  document.reference.update({"schedule_user_idx": schedule.scheduleUserIdx});
  document.reference.update({"schedule_start_date": schedule.scheduleStartDate});
  document.reference.update({"schedule_finish_date": schedule.scheduleFinishDate});
  document.reference.update({"schedule_start_time": schedule.scheduleStartTime});
  document.reference.update({"schedule_finish_time": schedule.scheduleFinishTime});
  document.reference.update({"schedule_title": schedule.scheduleTitle});
  document.reference.update({"schedule_color": schedule.scheduleColor});
  document.reference.update({"schedule_memo": schedule.scheduleMemo});
}

Future<void> deleteScheduleData(int scheduleIdx) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('ScheduleData')
      .where('schedule_idx', isEqualTo: scheduleIdx)
      .get();

  await FirebaseFirestore.instance
      .collection('ScheduleData')
      .doc(querySnapshot.docs.first.id)
      .update({"schedule_state": ScheduleState.STATE_DELETE.state});
}

// 캘린더 화면에서 데이터를 가져오는 메서드
Future<List<Map<String, dynamic>>> getCalendarScreenScheduleList(BuildContext context) async {
  var userProvider = Provider.of<UserProvider>(context, listen: false);

  var userIdx = userProvider.userIdx;
  var loverIdx = userProvider.loverIdx;

  var query = FirebaseFirestore.instance.collection('ScheduleData')
      .where('schedule_user_idx', whereIn: [userIdx, loverIdx])
      .where('schedule_state', isEqualTo: ScheduleState.STATE_NORMAL.state);
  var querySnapshot = await query.get();

  List<Map<String, dynamic>> results = [];

  for(var doc in querySnapshot.docs){
    results.add(doc.data());
  }

  // 결과 출력 테스트
  // print('스케쥴 리스트: ${results[0]}');

  return results;
}

// 홈 화면 캘린더 위젯에서 데이터를 가져오는 메서드
Future<List<List<Map<String, dynamic>>>> getHomeCalendarScheduleList(BuildContext context) async {
  var userProvider = Provider.of<UserProvider>(context, listen: false);

  var userIdx = userProvider.userIdx;
  var loverIdx = userProvider.loverIdx;

  var query = FirebaseFirestore.instance.collection('ScheduleData')
      .where('schedule_user_idx', whereIn: [userIdx, loverIdx])
      .where('schedule_state', isEqualTo: ScheduleState.STATE_NORMAL.state);
  var querySnapshot = await query.get();

  List<Map<String, dynamic>> results = querySnapshot.docs.map((doc) => doc.data()).toList();

  // 오늘 날짜 기준으로 이번 달의 첫째 날과 마지막 날 구하기
  DateTime now = DateTime.now();
  DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
  DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);


  // 현재 달에 해당하는 일 수만큼 빈 리스트 생성
  List<List<Map<String, dynamic>>> monthScheduleList = List.generate(
      lastDayOfMonth.day,
          (_) => [] // 각 날짜에 대해 빈 리스트 생성
  );

  // 결과를 calendar 리스트에 추가하는 함수
  void addDocumentToCalendar(Map<String, dynamic> document, int dayIndex) {
    String startTime = document['schedule_start_time'] ?? '00:00';
    String finishTime = document['schedule_finish_time'] ?? '23:59';

    // 문서 추가
    monthScheduleList[dayIndex].add({
      'schedule_title': document['schedule_title'],
      'schedule_start_date': document['schedule_start_date'],
      'schedule_finish_date': document['schedule_finish_date'],
      'schedule_start_time': startTime,
      'schedule_finish_time': finishTime
    });
  }

  void fillCalendar(List<Map<String, dynamic>> results) {

    // 데이터 필터링 및 정렬
    for (var result in results) {
      DateTime startDate = _parseDate(result['schedule_start_date']);
      DateTime finishDate = _parseDate(result['schedule_finish_date']);

      // 현재 월에 속하는 날짜인지 확인
      bool isStartInCurrentMonth = startDate.month == now.month && startDate.year == now.year;
      bool isFinishInCurrentMonth = finishDate.month == now.month && finishDate.year == now.year;

      if (isStartInCurrentMonth || isFinishInCurrentMonth) {
        // 시작 날짜가 현재 월에 포함되지 않으면, 첫 번째 날짜를 기준 월의 첫째 날로 설정
        DateTime currentDay = startDate.isBefore(firstDayOfMonth)
            ? firstDayOfMonth
            : startDate;

        // 끝 날짜가 현재 월의 마지막 날을 넘어가면, 마지막 날짜를 기준 월의 마지막 날로 설정
        DateTime endDay = finishDate.isAfter(lastDayOfMonth)
            ? lastDayOfMonth
            : finishDate;

        // 시작일부터 마지막날까지의 범위 내의 날짜들에 대해 처리
        while (currentDay.isBefore(endDay) ||
            currentDay.isAtSameMomentAs(endDay)) {
          int dayIndex = currentDay.day - 1; // 리스트 인덱스는 0부터 시작

          // 날짜 인덱스에 문서를 추가
          addDocumentToCalendar(result, dayIndex);

          currentDay = currentDay.add(const Duration(days: 1)); // 하루씩 증가
        }
      }
    }
  }

  fillCalendar(results);

  // 각 날짜의 문서들을 정렬
  for (int i = 0; i < monthScheduleList.length-1; i++) {
    DateTime currentDay = DateTime(now.year, now.month, i+1);

    if (monthScheduleList[i].isNotEmpty) {
      monthScheduleList[i].sort((a, b) {
        DateTime startDateA = _parseDate(a['schedule_start_date']);
        DateTime finishDateA = _parseDate(a['schedule_finish_date']);
        DateTime startDateB = _parseDate(b['schedule_start_date']);
        DateTime finishDateB = _parseDate(b['schedule_finish_date']);
        TimeOfDay startTimeA = _parseTime(a['schedule_start_time']);
        TimeOfDay finishTimeA = _parseTime(a['schedule_finish_time']);
        TimeOfDay startTimeB = _parseTime(b['schedule_start_time']);
        TimeOfDay finishTimeB = _parseTime(b['schedule_finish_time']);

        bool isAMiddleSchedule = currentDay!=startDateA && currentDay!=finishDateA;
        bool isBMiddleSchedule = currentDay!=startDateB && currentDay!=finishDateB;

        // 1. a만 중간일정인 경우
        if (isAMiddleSchedule && !isBMiddleSchedule){
          return -1;
        }

        // 2. b만 중간일정인 경우
        else if (isBMiddleSchedule && !isAMiddleSchedule){
          return 1;
        }

        // 3. a와 b 둘 다 중간일정인 경우
        else if (isAMiddleSchedule && isBMiddleSchedule){
          return a['schedule_title'].compareTo(b['schedule_title']);
        }

        // 4. a와 b 둘 다 시작일정인 경우
        else if (currentDay == startDateA && currentDay == startDateB) {
          if (_compareTimes(startTimeA, startTimeB) != 0) {
            return _compareTimes(startTimeA, startTimeB);
          } else {
            return a['schedule_title'].compareTo(b['schedule_title']);
          }
        }

        // 4. a와 b 둘 다 종료일정인 경우
        else if (currentDay == finishDateA && currentDay == finishDateB) {
          if (_compareTimes(finishTimeA, finishTimeB) != 0) {
            return _compareTimes(finishTimeA, finishTimeB);
          } else {
            return a['schedule_title'].compareTo(b['schedule_title']);
          }
        }

        // 5. a가 시작일정이고 b가 종료일정인 경우
        else if (currentDay == startDateA && currentDay == finishDateB) {
          return _compareTimes(startTimeA, finishTimeB);
        }

        // 6. a가 종료일정이고 b가 시작일정인 경우
        else if (currentDay == finishDateA && currentDay == startDateB) {
          return _compareTimes(finishTimeA, startTimeB);
        }
        return a['schedule_title'].compareTo(b['schedule_title']);
      });
    }
  }

  // 결과 출력 테스트
  // print('정렬 후 결과 출력 1일: ${monthScheduleList[0]}');

  return monthScheduleList;
}

// 요일에 데이터가 있는지
Future<bool> isExistOnSchedule(DateTime date, BuildContext context) async {
  var userProvider = Provider.of<UserProvider>(context, listen: false);

  var userIdx = userProvider.userIdx;
  var loverIdx = userProvider.loverIdx;

  // Datetime 객체를 날짜 저장 형식으로 변환
  var stringDate = dateToStringWithDay(date);

  // Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('ScheduleData');

  // var querySnapshot = await FirebaseFirestore.instance
  //     .collection('ScheduleData')
  //     .where('schedule_start_date', isGreaterThanOrEqualTo: stringDate)
  //     .where('schedule_end_date', isLessThanOrEqualTo: stringDate)
  //     .get();

  // if (querySnapshot.docs.isNotEmpty) {
  //   return true;
  // } else {
  //   return false;
  // }

  var querySnapShot = await FirebaseFirestore.instance
      .collection('ScheduleData')
      .where('schedule_user_idx', whereIn: [userIdx, loverIdx])
      .where('schedule_state', isEqualTo: ScheduleState.STATE_NORMAL.state)
      .get();

  for (var doc in querySnapShot.docs) {
    String startDateString = doc.get('schedule_start_date');
    String finishDateString = doc.get('schedule_finish_date');

    DateTime targetDateTime = _parseDate(stringDate);
    DateTime startDateTime = _parseDate(startDateString);
    DateTime finishDateTime = _parseDate(finishDateString);

    //하루 일정인 경우
    if (_isSameDay(startDateTime, finishDateTime)) {
      if (_isSameDay(startDateTime, targetDateTime)) {
        return true;
      }
    }
    //여러 날 일정인 경우
    else{
      List<DateTime> dateRange = _getDateRange(startDateTime, finishDateTime);

      for (var target in dateRange) {
        if (_isSameDay(target, targetDateTime)) {
          return true;
          }
        }
    }
  }
  return false;
}


// 시간 파싱 함수: HH:mm 형식의 문자열을 TimeOfDay로 변환
TimeOfDay _parseTime(String timeStr) {
  var parts = timeStr.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}
// 시간 비교 함수: time1이 time2보다 이르면 -1, 같으면 0, 늦으면 1을 반환
int _compareTimes(TimeOfDay time1, TimeOfDay time2) {
  if (time1.hour == time2.hour) {
    return time1.minute.compareTo(time2.minute).sign;
  } else {
    return time1.hour.compareTo(time2.hour).sign;
  }
}

// 필드의 문자열 날짜 객체를 DateTime으로 변환(정렬과 범위 계산을 위함)
DateTime _parseDate(String dateString) {
  DateFormat format = DateFormat('yyyy. MM. dd.');
  return format.parse(dateString.substring(0, 13)); // 요일은 제외
}

// 날짜의 범위를 산출하는 함수
List<DateTime> _getDateRange(DateTime start, DateTime finish) {
  List<DateTime> dateRange = [];
  DateTime currentDate = start;

  while (currentDate.isBefore(finish) || currentDate.isAtSameMomentAs(finish)) {
    dateRange.add(currentDate);
    currentDate = currentDate.add(const Duration(days: 1)); // 하루씩 더함
  }

  return dateRange;
}

bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}