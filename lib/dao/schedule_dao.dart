import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:woo_yeon_hi/model/schedule_model.dart';
import 'package:woo_yeon_hi/utils.dart';

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
Future<void> saveSchedule(Schedule schedule) async {
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

// Firebase - ScheduleDate 로 부터 List<Map<St, d>> 형태의 값을 받아옴
Future<List<Map<String, dynamic>>> getScheduleData(BuildContext context) async {
  var userProvider = Provider.of<UserProvider>(context, listen: false);

  var userIdx = userProvider.userIdx;
  var loverIdx = userProvider.loverIdx;

  List<Map<String, dynamic>> results = [];

  var querySnapShot = await FirebaseFirestore.instance.collection('ScheduleData').where('ledger_user_idx', whereIn: [userIdx, loverIdx]).get();

  for(var doc in querySnapShot.docs){
    results.add(doc.data());
  }

  return results;
}

// 요일에 데이터가 있는지
Future<bool> isExistOnSchedule(DateTime date, BuildContext context) async {
  var userProvider = Provider.of<UserProvider>(context, listen: false);

  var userIdx = userProvider.userIdx;
  var loverIdx = userProvider.loverIdx;

  // Datetime 객체를 날짜 저장 형식으로 변환
  var stringDate = dateToStringWithDay(date);

  // 필드의 문자열 날짜 객체를 DateTime으로 변환(범위 계산을 위함)
  DateTime parseDate(String dateString) {
    DateFormat format = DateFormat('yyyy. MM. dd.');
    return format.parse(dateString.substring(0, 13)); // 요일은 제외
  }

  // 날짜의 범위를 산출하는 함수
  List<DateTime> getDateRange(DateTime start, DateTime finish) {
    List<DateTime> dateRange = [];
    DateTime currentDate = start;

    while (currentDate.isBefore(finish) || currentDate.isAtSameMomentAs(finish)) {
      dateRange.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1)); // 하루씩 더함
    }

    return dateRange;
  }

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

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  var querySnapShot = await FirebaseFirestore.instance
      .collection('ScheduleData')
      .where('schedule_user_idx', whereIn: [userIdx, loverIdx])
      .get();

  for (var doc in querySnapShot.docs) {
    String startDateString = doc.get('schedule_start_date');
    String finishDateString = doc.get('schedule_finish_date');

    DateTime targetDateTime = parseDate(stringDate);
    DateTime startDateTime = parseDate(startDateString);
    DateTime finishDateTime = parseDate(finishDateString);

    //하루 일정인 경우
    if (isSameDay(startDateTime, finishDateTime)) {
      if (isSameDay(startDateTime, targetDateTime)) {
        return true;
      }
    }
    //여러 날 일정인 경우
    else{
      List<DateTime> dateRange = getDateRange(startDateTime, finishDateTime);

      for (var target in dateRange) {
        if (isSameDay(target, targetDateTime)) {
          return true;
          }
        }
    }
  }
  return false;
}