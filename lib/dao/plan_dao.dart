import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/enums.dart';

import '../model/plan_model.dart';
import '../provider/login_register_provider.dart';

Future<int> getPlanSequence() async {
  var querySnapShot = await FirebaseFirestore.instance
      .collection('Sequence')
      .doc('PlanSequence')
      .get();
  var sequence = querySnapShot.data()!.values.first;
  return sequence;
}

Future<void> setPlanSequence(int sequence) async {
  await FirebaseFirestore.instance
      .collection('Sequence')
      .doc('PlanSequence')
      .set({'value': sequence});
}

Future<void> addPlan(Plan plan) async {
  await FirebaseFirestore.instance.collection('PlanData').add({
    "plan_idx": plan.planIdx,
    "plan_title": plan.planTitle,
    "plan_date": plan.planDate,
    "plan_write_date": plan.planWriteDate,
    "plan_user_idx": plan.planUserIdx,
    "planed_array": plan.planedArray,
    "plan_state": plan.planState,
  });
}

Future<List<Map<String, dynamic>>> getHomePlanList(BuildContext context) async {
  var userProvider = Provider.of<UserProvider>(context, listen: false);

  var userIdx = userProvider.userIdx;
  var loverIdx = userProvider.loverIdx;

  var query = FirebaseFirestore.instance.collection('PlanData')
      .where('plan_user_idx', whereIn: [userIdx, loverIdx])
      .where('plan_state', isEqualTo: PlanState.STATE_NORMAL.state);

  List<Map<String, dynamic>> result = [];

  await query.get().then((snapshot) {
    DateTime now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    List<Map<String, dynamic>> filteredData = [];

    for (var doc in snapshot.docs) {
      String planDate = doc['plan_date'];
      List<String> dateParts = planDate.split(' ~ ');
      DateTime startDate = DateFormat('yyyy. MM. dd.').parse(dateParts[0]);

      if (startDate.isAtSameMomentAs(now)||startDate.isAfter(now)) {
        filteredData.add({
          'plan_idx': doc['plan_idx'],
          'plan_date': _formattingPlanDate(doc['plan_date']),
          'plan_title': doc['plan_title'],
          'plan_user_nickname': doc['plan_user_idx']==userIdx ? userProvider.userNickname : userProvider.loverNickname,
        });
      }
    }

    filteredData.sort((a, b) {
      DateTime startA = DateFormat('yy년 M월 d일 (E)', 'ko_KR').parse(a['plan_date'].split(' ~ ')[0]);
      DateTime startB = DateFormat('yy년 M월 d일 (E)', 'ko_KR').parse(b['plan_date'].split(' ~ ')[0]);

      // 두 날짜를 비교하여 정렬
      return startA.compareTo(startB);
    });

    // 조건에 맞는 데이터를 result에 저장
    result = filteredData.take(4).toList();

    print("플랜리스트: $result");
    // 가져온 데이터 처리
    return result;
  });
  return result;
}

Future<List<Plan>> getPlanData(int userIdx, BuildContext context) async {
  List<Plan> result = [];

  var userProvider = Provider.of<UserProvider>(context, listen: false);
  var userIdx = userProvider.userIdx;
  var loverIdx = userProvider.loverIdx;

  var querySnapshot = await FirebaseFirestore.instance
      .collection('PlanData')
      .where('plan_user_idx', whereIn: [userIdx, loverIdx])
      .where('plan_state', whereIn: [PlanState.STATE_NORMAL.state, PlanState.STATE_SUCCESS.state])
      .get();

  for (var doc in querySnapshot.docs) {
    result.add(Plan.fromData(doc.data()));
  }

  return result;
}

Future<void> normalPlan(Plan plan) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('PlanData')
      .where('plan_idx', isEqualTo: plan.planIdx)
      .get();

  await FirebaseFirestore.instance
      .collection('PlanData')
      .doc(querySnapshot.docs.first.id)
      .update({'plan_state': PlanState.STATE_SUCCESS.state});
}

Future<void> successPlan(Plan plan) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('PlanData')
      .where('plan_idx', isEqualTo: plan.planIdx)
      .get();
  var document = querySnapshot.docs.first;
  document.reference.update({'plan_state': PlanState.STATE_NORMAL.state});
}

Future<void> deletePlan(Plan plan) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('PlanData')
      .where('plan_idx', isEqualTo: plan.planIdx)
      .get();
  var document = querySnapshot.docs.first;
  document.reference.update({'plan_state': PlanState.STATE_DELETE.state});
}

Future<void> updatePlan(Plan plan, Map<String, dynamic> map) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('PlanData')
      .where('plan_idx', isEqualTo: plan.planIdx)
      .get();
  var document = querySnapshot.docs.first;
  document.reference.update(map);
}

String _formattingPlanDate(String dateRangeString) {
  // "2024. 10. 9. ~ 2024. 10. 10." 형식의 문자열에서 시작일과 종료일 추출
  final dateParts = dateRangeString.split(' ~ ');

  if (dateParts.length != 2) {
    throw const FormatException('잘못된 날짜 범위 형식입니다.');
  }

  // 시작일과 종료일을 DateTime 객체로 변환
  final startDate = DateFormat('yyyy. MM. dd.').parse(dateParts[0].trim());
  final endDate = DateFormat('yyyy. MM. dd.').parse(dateParts[1].trim());

  // 원하는 형식으로 포맷팅
  final formattedStartDate = DateFormat('yy년 M월 d일 (E)', 'ko_KR').format(startDate);
  final formattedEndDate = DateFormat('yy년 M월 d일 (E)', 'ko_KR').format(endDate);

  // 최종 문자열 결합
  return '$formattedStartDate ~ $formattedEndDate';
}