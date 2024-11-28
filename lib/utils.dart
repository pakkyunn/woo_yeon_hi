import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:mailer/mailer.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/provider/login_register_provider.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'dao/user_dao.dart';
import 'dialogs.dart';

/// Datetime 객체를 날짜 저장 형식으로 변환합니다.
String dateToString(DateTime date) {
  String formattedDay = DateFormat('yyyy. M. d.').format(date);
  // String year = DateFormat('yyyy').format(date);
  // String month = date.month.toString().padLeft(2, " ");
  // String day = date.day.toString().padLeft(2, " ");
  return formattedDay;
}

/// 'yyyy. M. d.' 형태의 문자열 날짜 데이터를 DateTime으로 변환합니다.
DateTime stringToDate(String date) {
  List<String> splitDate = date.split(".");
  String year = splitDate[0];
  String month = splitDate[1].replaceAll(" ", "");
  String day = splitDate[2].replaceAll(" ", "");

  return DateTime(int.parse(year), int.parse(month), int.parse(day));
}

/// 'yy. M. d.' 형태의 문자열 날짜 데이터를 DateTime으로 변환합니다.
DateTime stringToDateLight(String date) {
  List<String> splitDate = date.split(".");
  int yearLight = int.parse(splitDate[0]);
  String year = "${yearLight+2000}";
  String month = splitDate[1].replaceAll(" ", "");
  String day = splitDate[2].replaceAll(" ", "");

  return DateTime(int.parse(year), int.parse(month), int.parse(day));
}

/// Datetime 객체를 날짜 저장 형식으로 변환합니다.
/// 날짜 뒤 요일이 추가된 형식입니다. (E)
String dateToStringWithDay(DateTime date) {
  String formattedDay = DateFormat('yyyy. M. d.(E)', 'ko_KR').format(date);

  return formattedDay;
}

/// 요일표시형식에서 연도를 간단하게 표시한 형태입니다. (E)
String dateToStringWithDayLight(DateTime date) {
  String formattedDay = DateFormat('yy. M. d.(E)', 'ko_KR').format(date);

  return formattedDay;
}

/// 현재 시각을 int 저장 형식으로 변환합니다.
int dateTimeToInt(DateTime dateTime) {
  int year = dateTime.year;
  int month = dateTime.month;
  int day = dateTime.day;
  int hour = dateTime.hour;
  int minute = dateTime.minute;
  int second = dateTime.second;

  var _dateTimeString = '$year$month$day$hour$minute$second';
  var _dateTimeInt = stringToInt(_dateTimeString);

  return _dateTimeInt;
}

String listToString(List<int> list) {
  return list.join(',');
}

/// 문자열 객체를 ,를 기준으로 나누어 리스트 저장 형식으로 변환합니다.
List<int> stringToList(String input) {
  List<int> result = [];

  List<String> parts = input.split(',');
  for (String part in parts) {
    result.add(int.parse(part.trim()));
  }

  return result;
}

/// FlutterSecureStorage에 저장된 value객체(String)를 int타입으로 변환합니다.
int stringToInt(String value) {
  int number = 0;
  try {
    number = int.parse(value);
  } catch (e) {
    print('Error: $e');
  }
  return number;
}

/// signIn 과정에서 호출 시 중간 저장된 DB데이터와 내부 저장데이터를 삭제 후 로그인 화면으로 이동합니다.
void signOut(BuildContext context) async {
  const storage = FlutterSecureStorage();
  switch (Provider.of<UserProvider>(context, listen: false).loginType) {
    case 1:
      await GoogleSignIn().signOut();
      break;
    case 2:
      try {
        await UserApi.instance.logout();
        print('로그아웃 성공, SDK에서 토큰 삭제');
      } catch (error) {
        print('로그아웃 실패, SDK에서 토큰 삭제 $error');
      }
      break;
    case 0:
      break;
  }
  await deleteUserData(Provider.of<UserProvider>(context, listen: false).userIdx);
  await storage.delete(key: "userIdx");
  await storage.delete(key: "userAccount");
  Provider.of<UserProvider>(context, listen: false).setUserIdx(0);
  Provider.of<UserProvider>(context, listen: false).setLoginType(0);
  Provider.of<UserProvider>(context, listen: false).setUserBirth(dateToString(DateTime.now()));
  Provider.of<UserProvider>(context, listen: false).setLoverNickname("");
  showBlackToast("등록이 취소되었습니다");
}

Future<Map<String, dynamic>> fetchUserData() async {
  const storage = FlutterSecureStorage();
  /// 계정 테스트용
  // await storage.write(
  //     key: "userAccount",
  //     value: "pakkyunn@gmail.com");
  // await storage.write(
  //     key: "userIdx",
  //     value: "50");
  final userIdx = stringToInt((await storage.read(key: "userIdx")) ?? "");
  // final userAccount = await getSpecificUserData(userIdx, 'user_account') ?? "";
  final userAccount = (await storage.read(key: "userAccount")) ?? "";
  final notificationAllow = await getSpecificUserData(userIdx, 'notification_allow') ?? false;
  final appLockState = await getSpecificUserData(userIdx, 'app_lock_state') ?? 0;
  final homePresetType = await getSpecificUserData(userIdx, 'home_preset_type') ?? 0;
  final loginType = await getSpecificUserData(userIdx, 'login_type') ?? 0;
  final loveDday = await getSpecificUserData(userIdx, 'love_dDay') ?? "${DateTime.now()}";
  final loverIdx = await getSpecificUserData(userIdx, 'lover_idx') ?? 0;
  final userProfileMessage = await getSpecificUserData(userIdx, 'profile_message') ?? "";
  final loverProfileMessage = await getSpecificUserData(loverIdx, 'profile_message') ?? "";
  final topBarType = await getSpecificUserData(userIdx, 'top_bar_type') ?? 0;
  final userBirth = await getSpecificUserData(userIdx, 'user_birth') ?? "${DateTime.now()}";
  final userNickname = await getSpecificUserData(userIdx, 'user_nickname') ?? "기본별명";
  final loverNickname = await getSpecificUserData(userIdx, 'lover_nickname') ?? "기본별명";
  var userProfileImagePath = await getSpecificUserData(userIdx, 'user_profile_image') ?? "lib/assets/images/default_profile.png";
  var loverProfileImagePath = await getSpecificUserData(loverIdx, 'user_profile_image') ?? "lib/assets/images/default_profile.png";
  final userProfileImage =
  userProfileImagePath == "lib/assets/images/default_profile.png"
          ? Image.asset("lib/assets/images/default_profile.png")
          : await getProfileImage(userProfileImagePath);
  final loverProfileImage =
  loverProfileImagePath == "lib/assets/images/default_profile.png"
      ? Image.asset("lib/assets/images/default_profile.png")
      : await getProfileImage(loverProfileImagePath);
  final userState = await getSpecificUserData(userIdx, 'user_state') ?? 2;
  var memoryBannerImagePath = await getSpecificUserData(userIdx, 'memory_banner_image') ?? "";
  final memoryBannerImage =
  memoryBannerImagePath == ""
      ? Image.asset("lib/assets/images/default_profile.png")
      : await getMemoryBannerImage(memoryBannerImagePath);

  return {
    'userIdx': userIdx,
    'userAccount': userAccount,
    'notificationAllow': notificationAllow,
    'appLockState': appLockState,
    'homePresetType': homePresetType,
    'loginType': loginType,
    'loveDday': loveDday,
    'loverIdx': loverIdx,
    'userProfileMessage': userProfileMessage,
    'loverProfileMessage': loverProfileMessage,
    'topBarType': topBarType,
    'userBirth': userBirth,
    'userNickname': userNickname,
    'loverNickname': loverNickname,
    'userProfileImagePath': userProfileImagePath,
    'loverProfileImagePath': loverProfileImagePath,
    'userProfileImage': userProfileImage,
    'loverProfileImage': loverProfileImage,
    'userState': userState,
    'memoryBannerImagePath': memoryBannerImagePath,
    'memoryBannerImage': memoryBannerImage,
  };
}

//TODO 추후 메일 양식 수정(디자인, 내용 등)
Future<void> sendEmail(String recipientEmail, String code) async {
  String wooyeonhiMail = 'pakkyunn@gmail.com'; // 관리자 이메일 계정
  String password = 'qnhfeuwghjxelnpn'; // 관리자 이메일 계정의 앱 비밀번호

  final smtpServer = gmail(wooyeonhiMail, password);

  final message = Message()
    ..from = Address('우연히 ($wooyeonhiMail)')
    ..recipients.add(recipientEmail)
    ..subject = '[우연히] 앱 잠금 초기화 인증 요청'
    ..html = '''
    <html>
      <body>
        <p style="font-size: 15px; font-family: Malgun Gothic, sans-serif; text-align: center;">우연히 앱 잠금 초기화를 위한 인증코드입니다.</p>
        <p style="font-size: 15px;>""</p>
        <p style="font-size: 30px; font-family: Malgun Gothic, sans-serif; text-align: center;">$code</p>
        <p style="font-size: 15px;>""</p>
        <p style="font-size: 15px; font-family: Malgun Gothic, sans-serif; text-align: center;">유효시간 내에 입력 후 확인을 눌러주세요 :)</p>
      </body>
    </html>
      ''';

  try {
    await send(message, smtpServer);
    print('메일 발송 성공');
  } on MailerException catch (e) {
    print('메일 발송 실패 \n${e.toString()}');
  }
}

const _chars = 'ABCDEFGHIJKLMNPQRSTUVWXYZ23456789';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

//알림 권한 설정
Future<bool> checkAndRequestNotificationPermission(BuildContext context, Function showDialogFunction) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.getNotificationSettings();

  if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
    NotificationSettings newSettings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (newSettings.authorizationStatus == AuthorizationStatus.authorized) {
      return true;
    } else if (newSettings.authorizationStatus == AuthorizationStatus.denied) {
      return false;
    }
  } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    showDialogFunction();
    return false;
  }

  // If permission is already authorized, return true
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    return true;
  }

  // Default case to handle any other authorization status
  return false;
}