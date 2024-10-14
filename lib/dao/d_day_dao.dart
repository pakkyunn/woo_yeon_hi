import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/dDay_model.dart';
import '../model/diary_model.dart';
import '../provider/login_register_provider.dart';

Future<int> getDdaySequence() async {
  var querySnapShot = await FirebaseFirestore.instance
      .collection('Sequence')
      .doc('DdaySequence')
      .get();
  var sequence = querySnapShot.data()!.values.first;
  return sequence;
}

Future<void> setDdaySequence(int sequence) async {
  await FirebaseFirestore.instance
      .collection('Sequence')
      .doc('DdaySequence')
      .set({'value': sequence});
}

Future<void> addDday(DdayModel dDayModel) async {
  await FirebaseFirestore.instance.collection('DdayData').add({
    "user_idx": dDayModel.user_idx,
    "dDay_idx": dDayModel.dDay_idx,
    "dDay_title": dDayModel.title,
    "dDay_description": dDayModel.description,
    "dDay_date": dDayModel.date
  });
}

Future<List<Map<String, dynamic>>> getDdayList(BuildContext context) async {
  var userProvider = Provider.of<UserProvider>(context, listen: false);

  var userIdx = userProvider.userIdx;
  var loverIdx = userProvider.loverIdx;

  var query = FirebaseFirestore.instance.collection('DdayData').where('user_idx', whereIn: [userIdx, loverIdx]);
  query = query.orderBy('dDay_date', descending: false);
  var querySnapshot = await query.get();

  List<Map<String, dynamic>> results = [];

// 문자열을 DateTime으로 변환하는 함수
  DateTime parseDate(String dateString) {
    List<String> parts = dateString.split('.');
    int year = int.parse(parts[0].trim()) + 2000; // '25'년도를 2025로 변환
    int month = int.parse(parts[1].trim());
    int day = int.parse(parts[2].trim());

    return DateTime(year, month, day);
  }

  for (var doc in querySnapshot.docs) {
    Map<String, dynamic> data = doc.data();
    data['parsedDate'] = parseDate(data['dDay_date']); // DateTime 필드를 추가
    results.add(data);
  }

// parsedDate 필드를 기준으로 정렬
  results.sort((a, b) => a['parsedDate'].compareTo(b['parsedDate']));

// 필요시 parsedDate 필드를 제거
  for (var result in results) {
    result.remove('parsedDate');
  }

  // 결과 출력 테스트
  // print('디데이리스트1: ${results[0]}');
  // print('디데이리스트2: ${results[1]}');
  // print('디데이리스트3: ${results[2]}');

  return results;
}
