import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:woo_yeon_hi/enums.dart';
import 'package:woo_yeon_hi/utils.dart';

import '../model/diary_model.dart';

Future<int> getDiarySequence() async {
  var querySnapShot = await FirebaseFirestore.instance
      .collection('Sequence')
      .doc('DiarySequence')
      .get();
  var sequence = querySnapShot.data()!.values.first;
  return sequence;
}

Future<void> setDiarySequence(int sequence) async {
  await FirebaseFirestore.instance
      .collection('Sequence')
      .doc('DiarySequence')
      .set({'value': sequence});
}

Future<void> addDiary(Diary diary) async {
  await FirebaseFirestore.instance.collection('DiaryData').add({
    "diary_idx": diary.diaryIdx,
    "diary_user_idx": diary.diaryUserIdx,
    "diary_date": diary.diaryDate,
    "diary_weather": diary.diaryWeather,
    "diary_image": diary.diaryImagePath,
    "diary_title": diary.diaryTitle,
    "diary_content": diary.diaryContent,
    "diary_lover_check": diary.diaryLoverCheck,
    "diary_state": diary.diaryState
  });
}

// Future<List<Map<String, dynamic>>> getDiaryData(
//     int user_idx,
//     int lover_idx,
//     int filter_editor,
//     int filter_sort,
//     String filter_start,
//     String filter_end) async {
//   List<Map<String, dynamic>> results = [];
//
//   Query<Map<String, dynamic>> query =
//       FirebaseFirestore.instance.collection('DiaryData');
//
//   // 내가 쓴 일기
//   if (filter_editor == DiaryEditorState.EDITOR_USER.type) {
//     query = query.where('diary_user_idx', isEqualTo: user_idx);
//   }
//   // 연인이 쓴 일기
//   else if (filter_editor == DiaryEditorState.EDITOR_LOVER.type) {
//     query = query.where('diary_user_idx', isEqualTo: lover_idx);
//   }
//   else if (filter_editor == DiaryEditorState.EDITOR_ALL.type){
//     query = query.where('diary_user_idx', whereIn: [user_idx, lover_idx]);
//   }
//
//   // 기간 조회
//   if (filter_start.isNotEmpty && filter_end.isNotEmpty) {
//     query = query
//         .where('diary_date', isGreaterThanOrEqualTo: filter_start)
//         .where('diary_date', isLessThanOrEqualTo: filter_end);
//   } else if (filter_start.isNotEmpty && filter_end.isEmpty) {
//     query = query.where('diary_date', isGreaterThanOrEqualTo: filter_start);
//   } else if (filter_start.isEmpty && filter_end.isNotEmpty) {
//     query = query.where('diary_date', isLessThanOrEqualTo: filter_end);
//   }
//
//   // 정렬 조건
//   if (filter_sort == DiarySortState.SORT_ASC.type) {
//     query = query.orderBy('diary_idx', descending: false);
//   } else {
//     query = query.orderBy('diary_idx', descending: true);
//   }
//
//   var querySnapShot = await query.get();
//   for (var doc in querySnapShot.docs) {
//     results.add(doc.data());
//   }
//
//   return results;
// }

Future<List<Map<String, dynamic>>> getDiaryData(
    int user_idx,
    int lover_idx,
    int filter_editor,
    int filter_sort,
    String filter_start,
    String filter_end) async {
  // List<Map<String, dynamic>> results = [];

  Query<Map<String, dynamic>> query =
  FirebaseFirestore.instance.collection('DiaryData');

  // 로그 추가: filter_editor 상태 확인
  print("filter_editor: $filter_editor");

  // 내가 쓴 일기
  if (filter_editor == DiaryEditorState.EDITOR_USER.type) {
    query = query.where('diary_user_idx', isEqualTo: user_idx);
  }
  // 연인이 쓴 일기
  else if (filter_editor == DiaryEditorState.EDITOR_LOVER.type) {
    query = query.where('diary_user_idx', isEqualTo: lover_idx);
  }
  // 내가 쓴 것과 연인이 쓴 일기 모두
  else if (filter_editor == DiaryEditorState.EDITOR_ALL.type){
    query = query.where('diary_user_idx', whereIn: [user_idx, lover_idx]);
  }

  // 정렬 조건
  if (filter_sort == DiarySortState.SORT_ASC.type) {
    query = query.orderBy('diary_idx', descending: false);
  } else {
    query = query.orderBy('diary_idx', descending: true);
  }

  // 우선 기간에 상관없이 데이터 가져오기
  var querySnapShot = await query.get();

  DateTime? filterStartDate = filter_start.isNotEmpty
      ? stringToDate(filter_start)
      : null;
  DateTime? filterEndDate = filter_end.isNotEmpty
      ? stringToDate(filter_end)
      : null;

  // 기간 조회
  List<Map<String, dynamic>> results = querySnapShot.docs
      .map((doc) => doc.data())
      .where((entry) {
    if (filterStartDate != null || filterEndDate != null) {
      String diaryDateStr = entry['diary_date'] as String;
      DateTime diaryDate = stringToDate(diaryDateStr);

      // 날짜 비교
      if (filterStartDate != null && filterEndDate != null) {
        return diaryDate.isAfter(filterStartDate.subtract(Duration(days: 1))) &&
            diaryDate.isBefore(filterEndDate.add(Duration(days: 1)));
      } else if (filterStartDate != null) {
        return diaryDate.isAfter(filterStartDate.subtract(Duration(days: 1)));
      } else if (filterEndDate != null) {
        return diaryDate.isBefore(filterEndDate.add(Duration(days: 1)));
      }
    }
    return true; // 날짜 필터가 없으면 모든 데이터를 포함
  }).toList();

  // for (var doc in querySnapShot.docs) {
  //   results.add(doc.data());
  // }

  return results;
}

Future<void> uploadDiaryImage(XFile imageFile, String imageName) async {
  await FirebaseStorage.instance
      .ref('image/diary/$imageName')
      .putFile(File(imageFile.path));
}

Future<Image> getDiaryImage(String path) async {
  var imageURL =
      await FirebaseStorage.instance.ref('image/diary/$path').getDownloadURL();
  var image = Image.network(
    imageURL,
    fit: BoxFit.cover,
  );
  return image;
}

Future<void> readDiary(Diary diary) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('DiaryData')
      .where('diary_idx', isEqualTo: diary.diaryIdx)
      .get();
  var document = querySnapshot.docs.first;
  document.reference.update({'diary_lover_check': true});
}

Future<bool> isDiaryExistOnDate(DateTime date) async {
  var stringDate = dateToString(date);
  var querySnapshot = await FirebaseFirestore.instance
      .collection('DiaryData')
      .where('diary_date', isEqualTo: stringDate)
      .get();
  if (querySnapshot.docs.isNotEmpty) {
    return true;
  } else {
    return false;
  }
}
