import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/model/enums.dart';
import 'package:woo_yeon_hi/model/ledger_model.dart';

import '../provider/login_register_provider.dart';
import '../utils.dart';

class LedgerDao{

  // 가계부 시퀀스값 가져오기
  Future<int> getLedgerSequence() async {
    var querySnapShot = await FirebaseFirestore.instance.collection('Sequence').doc('LedgerSequence').get();
    var sequence = querySnapShot.data()!['value'];
    return sequence;
  }

  // 가계부 시퀀스값 업데이트
  Future<void> updateLedgerSequence(int ledgerSequence) async {
    await FirebaseFirestore.instance.collection('Sequence').doc('LedgerSequence').set({
      'value': ledgerSequence
    });
  }

  // 가계부 데이터를 Firestore에 저장하기
  Future<void> saveLedger(Ledger ledger) async {
    await FirebaseFirestore.instance.collection('LedgerData').add(ledger.toMap());
  }

  // 가계부 데이터를 Firestore에서 가져오기
  Future<List<Ledger>> getLedgerData(BuildContext context) async {
    var userProvider = Provider.of<UserProvider>(context, listen: false);

    var userIdx = userProvider.userIdx;
    var loverIdx = userProvider.loverIdx;

    var querySnapShot = await FirebaseFirestore.instance.collection('LedgerData').where('ledger_user_idx', whereIn: [userIdx, loverIdx]).get();
    return querySnapShot.docs.map((doc) => Ledger.fromMap(doc.data())).toList();
  }

  // 가계부 상세 데이터 가져오기
  Future<List<Ledger>> readLedger(String ledgerDate, BuildContext context) async {
    var userProvider = Provider.of<UserProvider>(context, listen: false);

    var userIdx = userProvider.userIdx;
    var loverIdx = userProvider.loverIdx;

    var querySnapShot = await FirebaseFirestore.instance
        .collection('LedgerData')
        .where('ledger_user_idx', whereIn: [userIdx, loverIdx])
        .where('ledger_date', isGreaterThanOrEqualTo: ledgerDate, isLessThan: '${ledgerDate}T23:59:59.999')
        .where('ledger_state', isEqualTo: LedgerState.STATE_NORMAL.state)
        .get();
    return querySnapShot.docs.map((doc) => Ledger.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  // 가계부 데이터 수정하기
  Future<List<Ledger>> updateLedger(Ledger ledger) async{
    var querySnapShot = await FirebaseFirestore.instance
        .collection('LedgerData')
        .where('ledger_idx', isEqualTo: ledger.ledgerIdx)
        .get();

    var document = querySnapShot.docs.first.id;
    await FirebaseFirestore.instance
        .collection('LedgerData')
        .doc(document)
        .update(ledger.toMap());
    return querySnapShot.docs.map((doc) => Ledger.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  // 가계부 데이터 삭제 (상태 값 업데이트)
  Future<void> deleteLedger(Ledger ledger) async{
    var querySnapShot = await FirebaseFirestore.instance
        .collection('LedgerData')
        .where('ledger_idx', isEqualTo: ledger.ledgerIdx)
        .get();
    var document = querySnapShot.docs.first;
    document.reference.delete();
  }

  // 연도와 월 조건으로 현재 월 데이터 가져오기
  Future<List<Ledger>> getMonthlyLedgerData(DateTime focusedDay, BuildContext context) async {
    var userProvider = Provider.of<UserProvider>(context, listen: false);

    var userIdx = userProvider.userIdx;
    var loverIdx = userProvider.loverIdx;

    String yearMonth = '${focusedDay.year.toString().padLeft(4, '0')}-${focusedDay.month.toString().padLeft(2, '0')}';
    var querySnapshot = await FirebaseFirestore.instance.collection('LedgerData')
        .where('ledger_user_idx', whereIn: [userIdx, loverIdx])
        .where('ledger_date', isGreaterThanOrEqualTo: '$yearMonth-01T00:00:00.000')
        .where('ledger_date', isLessThan: '$yearMonth-32T00:00:00.000')
        .get();
    return querySnapshot.docs.map((doc) => Ledger.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  // 연도와 월 조건으로 지난달 데이터 가져오기
  Future<List<Ledger>> getPreviousMonthLedgerData(DateTime focusedDay, BuildContext context) async {
    var userProvider = Provider.of<UserProvider>(context, listen: false);

    var userIdx = userProvider.userIdx;
    var loverIdx = userProvider.loverIdx;

    DateTime previousMonth = DateTime(focusedDay.year, focusedDay.month - 1, 1);
    String yearMonth = '${previousMonth.year.toString().padLeft(4, '0')}-${previousMonth.month.toString().padLeft(2, '0')}';
    var querySnapshot = await FirebaseFirestore.instance.collection('LedgerData')
        .where('ledger_user_idx', whereIn: [userIdx, loverIdx])
        .where('ledger_date', isGreaterThanOrEqualTo: '$yearMonth-01T00:00:00.000')
        .where('ledger_date', isLessThan: '$yearMonth-32T00:00:00.000')
        .get();
    return querySnapshot.docs.map((doc) => Ledger.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}

// Future<bool> isLedgerExistOnDate(DateTime date, BuildContext context) async {
//   var userProvider = Provider.of<UserProvider>(context, listen: false);
//
//   var userIdx = userProvider.userIdx;
//   var loverIdx = userProvider.loverIdx;
//
//   var stringDate = dateToString(date);
//   var querySnapshot = await FirebaseFirestore.instance
//       .collection('Ledger')
//       .where('ledger_user_idx', whereIn: [userIdx, loverIdx])
//       .where('ledger_date', isEqualTo: stringDate)
//       .get();
//   if (querySnapshot.docs.isNotEmpty) {
//     return true;
//   } else {
//     return false;
//   }
// }