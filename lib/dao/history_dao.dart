import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/enums.dart';
import 'package:woo_yeon_hi/model/history_model.dart';
import 'package:woo_yeon_hi/provider/footprint_provider.dart';

import '../provider/login_register_provider.dart';

Future<int> getHistorySequence() async {
  var querySnapShot = await FirebaseFirestore.instance
      .collection('Sequence')
      .doc('HistorySequence')
      .get();
  var sequence = querySnapShot.data()!.values.first;
  return sequence;
}

Future<void> setHistorySequence(int sequence) async {
  await FirebaseFirestore.instance
      .collection('Sequence')
      .doc('HistorySequence')
      .set({'value': sequence});
}

Future<void> addHistory(History history) async {
  await FirebaseFirestore.instance.collection('HistoryData').add({
    "history_idx": history.historyIdx,
    // "history_map_idx": history.historyMapIdx,
    "history_place_name": history.historyPlaceName,
    "history_location": history.historyLocation,
    "history_user_idx": history.historyUserIdx,
    "history_title": history.historyTitle,
    "history_date": history.historyDate,
    "history_content": history.historyContent,
    "history_image": history.historyImage,
    "history_state": history.historyState
  });
}

Future<List<History>> getHistory(BuildContext context) async {
  List<History> results = [];

  var userProvider = Provider.of<UserProvider>(context, listen: false);
  var userIdx = userProvider.userIdx;
  var loverIdx = userProvider.loverIdx;

  var querySnapshot = await FirebaseFirestore.instance
      .collection('HistoryData')
      .where('history_user_idx', whereIn: [userIdx, loverIdx])
      .where('history_state', isEqualTo: HistoryState.STATE_NORMAL.state)
      .get();

  List<Map<String, dynamic>> dataList = [];

  // Firestore에서 데이터를 가져오고 날짜 문자열을 DateTime으로 변환
  for (var doc in querySnapshot.docs) {
    var data = doc.data();
    String dateString = data['history_date'];

    // 날짜 문자열을 DateTime으로 변환
    DateTime parsedDate = DateFormat('yyyy. M. d.').parse(dateString);

    // 변환된 DateTime을 함께 추가
    data['parsed_date'] = parsedDate;

    dataList.add(data);
  }

  // 날짜를 기준으로 내림차순으로 정렬
  dataList.sort((a, b) => b['parsed_date'].compareTo(a['parsed_date']));

  // 정렬된 데이터를 History 객체로 변환
  for (var data in dataList) {
    results.add(History.fromData(data));
  }

  return results;
}

Future<void> uploadHistoryImage(XFile imageFile, String imageName) async {
  await FirebaseStorage.instance
      .ref('image/history/$imageName')
      .putFile(File(imageFile.path));
}

Future<Image> getHistoryImage(String? path) async {
  var imageURL = await FirebaseStorage.instance
      .ref('image/history/$path')
      .getDownloadURL();
  var image = Image.network(
    imageURL,
    fit: BoxFit.cover,
  );
  return image;
}

Future<List<Image>> getHistoryImageList(List<dynamic> pathList) async {
  List<Image> result = [];
  for (var path in pathList) {
    var imageURL = await FirebaseStorage.instance
        .ref('image/history/$path')
        .getDownloadURL();
    var image = Image.network(
      imageURL,
      fit: BoxFit.cover,
    );
    result.add(image);
  }
  return result;
}

Future<void> editHistory(
    int historyIdx, Map<String, dynamic> historyMap) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('HistoryData')
      .where('history_idx', isEqualTo: historyIdx)
      .get();

  await FirebaseFirestore.instance
      .collection('HistoryData')
      .doc(querySnapshot.docs.first.id)
      .update(historyMap);
}

Future<void> deleteHistory(int historyIdx) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('HistoryData')
      .where('history_idx', isEqualTo: historyIdx)
      .get();

  await FirebaseFirestore.instance
      .collection('HistoryData')
      .doc(querySnapshot.docs.first.id)
      .update({"history_state": HistoryState.STATE_DELETE.state});
}
