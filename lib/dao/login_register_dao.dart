import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:woo_yeon_hi/dao/user_dao.dart';

Future<bool> saveConnectCodeData(String code, int idx) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('CodeData')
      .where('connect_code', isEqualTo: code)
      .get();
  if(querySnapshot.docs.isNotEmpty){
    return false;
  } else{
    await FirebaseFirestore.instance.collection('CodeData').add({
      'connect_code': code,
      'host_idx': idx,
      'code_connect_state': false,
      'expired_time': DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
    });
    return true;
  }
}

Future<void> deleteConnectCodeData(String code) async {
  QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
      .collection('CodeData')
      .where('connect_code', isEqualTo: code)
      .get();

  for (DocumentSnapshot<Map<String, dynamic>> docSnapshot in querySnapshot.docs) {
    await docSnapshot.reference.delete();
  }
}

Future<bool> isCodeDataExist(String code) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('CodeData')
      .where('connect_code', isEqualTo: code)
      .get();

// 해당 코드의 문서가 존재하는지 확인
  if (querySnapshot.docs.isNotEmpty) {
    return true;
  }

  return false;
}

Future<bool> isCodeConnected(String code) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('CodeData')
      .where('connect_code', isEqualTo: code)
      .get();

// 해당 코드의 code_connect_state를 확인
  if (querySnapshot.docs.isNotEmpty) {
    print("존재하는 문서");

    for (var doc in querySnapshot.docs) {
      if (doc.data()['code_connect_state'] == true) {
        print("true리턴");

        return true;
      }
    }
  }
  print("false리턴");

  return false;
}

Future<void> saveUserInfo(String userAccount, int userIdx, int loginType, String loveDday) async {
  try {
    await setUserSequence(userIdx);
    await FirebaseFirestore.instance.collection('UserData').add({
      'user_idx': userIdx,
      'user_account': userAccount,
      'user_nickname': "기본별명",
      'login_type': loginType,
      'love_dDay' : loveDday
    });
  } catch (e) {
    print("Error writing document: $e");
  }
}


Future<void> saveLoverIdx(int userIdx, int loverIdx) async {
  try {
    // userIdx 필드와 일치하는 문서 검색
    var querySnapshot = await FirebaseFirestore.instance.collection('UserData')
        .where('user_idx', isEqualTo: userIdx)
        .get();

    // 문서가 존재하는 경우 업데이트
    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        // 문서 ID 가져오기
        String docId = doc.id;

        // 새로운 필드를 추가하여 문서 업데이트
        await FirebaseFirestore.instance.collection('UserData').doc(docId).update({'lover_idx': loverIdx});
      }
      print('문서 업데이트 완료');
    } else {
      print('해당 user_idx를 가진 문서가 없습니다');
    }
  } catch (e) {
    print('문서 업데이트 중 오류 발생: $e');
  }
}

dynamic getSpecificConnectCodeData(String code, String dataField) async {
  Map<String, dynamic> results = {};
  dynamic result;

  Query<Map<String, dynamic>> query = FirebaseFirestore.instance
      .collection('CodeData')
      .where('connect_code', isEqualTo: code);

  var querySnapShot = await query.get();
  for (var doc in querySnapShot.docs) {
    results = doc.data();
  }

  result = results[dataField];

  return result;
}


Future<void> updateConnectCode(String code, int userIdx) async {
  try {
    // userIdx 필드와 일치하는 문서 검색
    var querySnapshot = await FirebaseFirestore.instance.collection('CodeData')
        .where('connect_code', isEqualTo: code)
        .get();

    // 문서가 존재하는 경우 업데이트
    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        // 문서 ID 가져오기
        String docId = doc.id;

        // 새로운 필드를 추가하여 문서 업데이트
        await FirebaseFirestore.instance.collection('CodeData').doc(docId).update({'code_connect_state': true});
        await FirebaseFirestore.instance.collection('CodeData').doc(docId).update({'guest_idx': userIdx});
      }
      print('문서 업데이트 완료');
    } else {
      print('해당 코드가 포함된 문서가 없습니다');
    }
  } catch (e) {
    print('문서 업데이트 중 오류 발생: $e');
  }
}