import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../model/user_model.dart';

Future<void> registerUserData(int userIdx, String loveDday, String userBirth, String userProfileImage, int homePresetType, bool topBarActivate, int topBarType, String profileMessage, bool notificationAllow, int userState, int appLockState, String memoryBannerImage) async {
  var myQuerySnapshot = await FirebaseFirestore.instance
      .collection('UserData')
      .where('user_idx', isEqualTo: userIdx)
      .get();
  var myDocument = myQuerySnapshot.docs.first;

  if (myQuerySnapshot.docs.isNotEmpty) {
    await myDocument.reference.update({
      "love_dDay": loveDday,
      "user_birth": userBirth,
      "user_profile_image": userProfileImage,
      "home_preset_type": homePresetType,
      "top_bar_activate": topBarType,
      "top_bar_type": topBarType,
      "profile_message": profileMessage,
      "notification_allow": notificationAllow,
      "user_state": userState,
      "app_lock_state": appLockState,
      "memory_banner-image": memoryBannerImage,
    });
  }
}

Future<Map<String, dynamic>> getUserData(String userAccount) async {
  Map<String, dynamic> results = {};

  Query<Map<String, dynamic>> query = FirebaseFirestore.instance
      .collection('UserData')
      .where('user_account', isEqualTo: userAccount);

  var querySnapShot = await query.get();
  for (var doc in querySnapShot.docs) {
    results = doc.data();
  }

  return results;
}

dynamic getSpecificUserData(int userIdx, String data) async {
  Map<String, dynamic> results = {};
  dynamic result;

  Query<Map<String, dynamic>> query = FirebaseFirestore.instance
      .collection('UserData')
      .where('user_idx', isEqualTo: userIdx);

  var querySnapShot = await query.get();
  for (var doc in querySnapShot.docs) {
    results = doc.data();
  }

  result = results[data];

  return result;
}

Future<void> updateSpecificUserData(
    int userIdx, String updateItem, var updateContent) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('UserData')
      .where('user_idx', isEqualTo: userIdx)
      .get();

  var document = querySnapshot.docs.first;
  document.reference.update({updateItem: updateContent});
}

Future<void> updateUserProfileData(int userIdx, String userProfileImageField, String userNicknameField, String userBirthField, String profileMessageField,
                                   String userProfileImage, String userNickname,String userBirth,String profileMessage) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('UserData')
      .where('user_idx', isEqualTo: userIdx)
      .get();

  var document = querySnapshot.docs.first;
  document.reference.update({userProfileImageField: userProfileImage});
  document.reference.update({userNicknameField: userNickname});
  document.reference.update({userBirthField: userBirth});
  document.reference.update({profileMessageField: profileMessage});
}


Future<void> deleteUserData(int userIdx) async {
  QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
      .instance
      .collection('UserData')
      .where('user_idx', isEqualTo: userIdx)
      .get();

  for (DocumentSnapshot<Map<String, dynamic>> docSnapshot
      in querySnapshot.docs) {
    await docSnapshot.reference.delete();
  }
}

Future<int> getUserSequence() async {
  var querySnapShot = await FirebaseFirestore.instance
      .collection('Sequence')
      .doc('UserSequence')
      .get();
  var sequence = querySnapShot.data()!.values.first;
  return sequence;
}

Future<void> setUserSequence(int sequence) async {
  await FirebaseFirestore.instance
      .collection('Sequence')
      .doc('UserSequence')
      .set({'value': sequence});
}

Future<void> uploadProfileImage(XFile imageFile, String imageName) async {
  await FirebaseStorage.instance
      .ref('image/userProfile/$imageName')
      .putFile(File(imageFile.path));
}

Future<Image> getProfileImage(String path) async {
  var imageURL = await FirebaseStorage.instance
      .ref('image/userProfile/$path')
      .getDownloadURL();
  var image = Image.network(
    imageURL,
    fit: BoxFit.cover,
  );
  return image;
}

Future<void> deleteProfileImage(String path) async {
  try {
    // 파일의 참조를 가져옴
    final imageURL = FirebaseStorage.instance.ref('image/userProfile/$path');

    // 파일 삭제
    await imageURL.delete();

    print("File deleted successfully");
  } catch (e) {
    print("Failed to delete file: $e");
  }
}

Future<void> uploadMemoryBannerImage(XFile imageFile, String imageName) async {
  await FirebaseStorage.instance
      .ref('image/memoryBanner/$imageName')
      .putFile(File(imageFile.path));
}

Future<Image> getMemoryBannerImage(String path) async {
  var imageURL = await FirebaseStorage.instance
      .ref('image/memoryBanner/$path')
      .getDownloadURL();
  var image = Image.network(
    imageURL,
    fit: BoxFit.cover,
  );
  return image;
}

Future<void> deleteMemoryBannerImage(String path) async {
  try {
    // 파일의 참조를 가져옴
    final imageURL = FirebaseStorage.instance.ref('image/memoryBanner/$path');

    // 파일 삭제
    await imageURL.delete();

    print("File deleted successfully");
  } catch (e) {
    print("Failed to delete file: $e");
  }
}