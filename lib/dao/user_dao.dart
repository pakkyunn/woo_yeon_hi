import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../model/user_model.dart';

Future<void> addUserData(UserModel user) async {
  await FirebaseFirestore.instance.collection('UserData').add({
    "user_idx": user.userIdx,
    "login_type": user.loginType,
    "user_account": user.userAccount,
    "user_nickname": user.userNickname,
    "user_birth": user.userBirth,
    "user_profile_image": user.userProfileImage,
    "lover_idx": user.loverIdx,
    "home_preset_type": user.homePresetType,
    "top_bar_type": user.topBarType,
    "profile_message": user.profileMessage,
    "notification_allow": user.notificationAllow,
    "user_state": user.userState,
    "love_dDay": user.loveDday,
  });
}

Future<Map<String, dynamic>> getUserData(int userIdx) async {
  Map<String, dynamic> results = {};

  Query<Map<String, dynamic>> query = FirebaseFirestore.instance
      .collection('UserData')
      .where('user_idx', isEqualTo: userIdx);

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