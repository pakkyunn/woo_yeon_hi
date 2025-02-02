import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:woo_yeon_hi/utils.dart';

import '../dao/user_dao.dart';
import '../dialogs.dart';

class UserProvider extends ChangeNotifier {
  int _userIdx = 0;
  String _userAccount = "";
  bool _notificationAllow = false;
  int _appLockState = 0;
  int _homePresetType = 0;
  int _loginType = 0;
  String _loveDday = dateToString(DateTime.now());
  int _loverIdx = 0;
  String _userProfileMessage = "";
  String _loverProfileMessage = "";
  int _topBarType = 0;
  String _userBirth = dateToString(DateTime.now());
  String _userNickname = "기본별명";
  String _loverNickname = "기본별명";
  String _userProfileImagePath = "lib/assets/images/default_profile.png";
  String _loverProfileImagePath = "lib/assets/images/default_profile.png";
  late Image _userProfileImage;
  late Image _loverProfileImage;
  int _userState = 2;
  String _memoryBannerImagePath = "";
  late Image _memoryBannerImage;

  bool _loginSuccess = false;
  List<int> _lockPassword = [0, 0, 0, 0];

  int get userIdx => _userIdx;
  String get userAccount => _userAccount;
  bool get notificationAllow => _notificationAllow;
  int get appLockState => _appLockState;
  int get homePresetType => _homePresetType;
  int get loginType => _loginType;
  String get loveDday => _loveDday;
  int get loverIdx => _loverIdx;
  String get userProfileMessage => _userProfileMessage;
  String get loverProfileMessage => _loverProfileMessage;
  int get topBarType => _topBarType;
  String get userBirth => _userBirth;
  String get userNickname => _userNickname;
  String get loverNickname => _loverNickname;
  String get userProfileImagePath => _userProfileImagePath;
  String get loverProfileImagePath => _loverProfileImagePath;
  Image get userProfileImage => _userProfileImage;
  Image get loverProfileImage => _loverProfileImage;
  int get userState => _userState;
  String get memoryBannerImagePath => _memoryBannerImagePath;
  Image get memoryBannerImage => _memoryBannerImage;
  bool get loginSuccess => _loginSuccess;
  List<int> get lockPassword => _lockPassword;

  final TextEditingController _codeTextEditController = TextEditingController();
  TextEditingController get codeTextEditController => _codeTextEditController;

  XFile? _image;
  XFile? get image => _image;

  void setImage(XFile? image) {
    _image = image;
    notifyListeners();
  }

  void setUserIdx(int userIdx) {
    _userIdx = userIdx;
    notifyListeners();
  }

  void setUserAccount(String userAccount) {
    _userAccount = userAccount;
    notifyListeners();
  }

  void setLoginType(int loginType) {
    _loginType = loginType;
    notifyListeners();
  }

  void setUserState(int userState) {
    _userState = userState;
    notifyListeners();
  }

  void setLoverIdx(int loverIdx) {
    _loverIdx = loverIdx;
    notifyListeners();
  }

  void setLoginSuccess(bool loginSuccess) {
    _loginSuccess = loginSuccess;
    notifyListeners();
  }

  void setAppLockState(int state) {
    _appLockState = state;
    notifyListeners();
  }

  void setLockPassword(List<int> passwordList) {
    _lockPassword = passwordList;
    notifyListeners();
  }

  void setUserNickname(String userNickname) {
    _userNickname = userNickname;
    notifyListeners();
  }

  void setLoverNickname(String loverNickname) {
    _loverNickname = loverNickname;
    notifyListeners();
  }

  void setUserProfileMessage(String message) {
    _userProfileMessage = message;
    notifyListeners();
  }

  void setLoverProfileMessage(String message) {
    _loverProfileMessage = message;
    notifyListeners();
  }

  void setUserProfileImagePath(String imagePath) {
    _userProfileImagePath = imagePath;
    notifyListeners();
  }

  void setLoverProfileImagePath(String imagePath) {
    _loverProfileImagePath = imagePath;
  }

  void setUserProfileImage(Image userProfileImage) {
    _userProfileImage = userProfileImage;
    notifyListeners();
  }

  void setLoverProfileImage(Image loverProfileImage) {
    _loverProfileImage = loverProfileImage;
    notifyListeners();
  }

  void setUserBirth(String date) {
    _userBirth = date;
    notifyListeners();
  }

  void setNotificationAllow(bool allow) {
    _notificationAllow = allow;
    notifyListeners();
  }

  void setLoveDday(String date) {
    _loveDday = date;
    notifyListeners();
  }

  void setHomePresetType(int presetIndex) {
    _homePresetType = presetIndex;
    notifyListeners();
  }

  void setTopBarType(int type) {
    _topBarType = type;
    notifyListeners();
  }

  void setMemoryBannerImagePath(String imagePath) {
    _memoryBannerImagePath = imagePath;
    notifyListeners();
  }

  void setMemoryBannerImage(Image image) {
    _memoryBannerImage = image;
    notifyListeners();
  }

  Future<Image> fetchMemoryBannerImage(String imagePath) async {
    Image updatedBannerImage =
      imagePath == ""
      ? Image.asset("lib/assets/images/memory_banner_icon_image.png")
      : await getMemoryBannerImage(imagePath);

    return updatedBannerImage;
  }

  void setUserAllData(
      int userIdx,
      String userAccount,
      int appLockState,
      int homePresetType,
      int loginType,
      String loveDday,
      int loverIdx,
      bool notificationAllow,
      String userProfileMessage,
      String loverProfileMessage,
      int topBarType,
      String userBirth,
      String userNickname,
      String loverNickname,
      String userProfileImagePath,
      String loverProfileImagePath,
      Image userProfileImage,
      Image loverProfileImage,
      int userState,
      String memoryBannerImagePath,
      Image memoryBannerImage) {
    _userIdx = userIdx;
    _userAccount = userAccount;
    _appLockState = appLockState;
    _homePresetType = homePresetType;
    _loginType = loginType;
    _loveDday = loveDday;
    _loverIdx = loverIdx;
    _notificationAllow = notificationAllow;
    _userProfileMessage = userProfileMessage;
    _loverProfileMessage = loverProfileMessage;
    _topBarType = topBarType;
    _userBirth = userBirth;
    _userNickname = userNickname;
    _loverNickname = loverNickname;
    _userProfileImagePath = userProfileImagePath;
    _loverProfileImagePath = loverProfileImagePath;
    _userProfileImage = userProfileImage;
    _loverProfileImage = loverProfileImage;
    _userState = userState;
    _memoryBannerImagePath = memoryBannerImagePath;
    _memoryBannerImage = memoryBannerImage;
  }

  String _tempImagePath = "lib/assets/images/default_profile.png";
  String get tempImagePath => _tempImagePath;

  void setTempImagePath(String tempImagePath) {
    _tempImagePath = tempImagePath;
    notifyListeners();
  }

  late Image _tempImage;
  Image get tempImage => _tempImage;

  void setTempImage(Image tempImage) {
    _tempImage = tempImage;
    notifyListeners();
  }


  Future<void> setUserProfile(String userProfileImagePath, Image userProfileImage, String userNickname,
      String userBirth, String message) async {
    _userProfileImagePath = userProfileImagePath;
    _userProfileImage = userProfileImage;
    _userNickname = userNickname;
    _userBirth = userBirth;
    _userProfileMessage = message;

    notifyListeners();
  }

  bool checkProvider(TextEditingController textEditingController) {
    if (textEditingController.text.isEmpty ||
        textEditingController.text == "") {
      return false;
    } else {
      return true;
    }
  }

  // signInWithGoogle() async {
  //   GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //
  //   if (googleUser != null) {
  //     print('email = ${googleUser.email}');
  //     print('id = ${googleUser.id}');
  //
  //     setUserAccount(googleUser.email);
  //     setLoginSuccess(true);
  //   } else {
  //     showBlackToast("구글 계정 로그인에 실패하였습니다");
  //   }
  // }

  // signInWithKakao() async {
  //   if (await isKakaoTalkInstalled()) {
  //     try {
  //       //카카오톡 설치됨, 카카오톡으로 로그인 시도
  //       await UserApi.instance.loginWithKakaoTalk();
  //       setLoginSuccess(true);
  //       // setUserAccount(카카오계정정보);
  //     } catch (error) {
  //       print('카카오톡으로 로그인 실패 $error');
  //       showBlackToast("카카오 계정 로그인에 실패하였습니다");
  //       if (error is PlatformException && error.code == 'CANCELED') {
  //         print('사용자가 로그인 취소');
  //         showBlackToast("카카오 계정 로그인을 취소하였습니다");
  //         return;
  //       }
  //
  //       print('카카오 계정으로 로그인 시도');
  //       try {
  //         await UserApi.instance.loginWithKakaoAccount();
  //         // setUserAccount(카카오계정정보);
  //         setLoginSuccess(true);
  //       } catch (error) {
  //         print('카카오 계정으로 로그인 실패 $error');
  //         showBlackToast("카카오 계정 로그인에 실패하였습니다");
  //       }
  //     }
  //   } else {
  //     //카카오톡 설치 안됨, 카카오계정으로 로그인 시도
  //     try {
  //       await UserApi.instance.loginWithKakaoAccount();
  //       // setUserAccount(카카오계정정보);
  //       setLoginSuccess(true);
  //     } catch (error) {
  //       showBlackToast("카카오 계정 로그인에 실패하였습니다");
  //     }
  //   }
  // }

  Future<bool> isUserAccountRegistered(String userAccount) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('UserData')
          .where('user_account', isEqualTo: userAccount);

      print("쿼리 시작: $userAccount");
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
      print("쿼리 결과: ${querySnapshot.docs.length}");

      // 조건에 맞는 문서가 하나라도 존재하면 true 반환
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("isUserAccountRegistered 에러 발생: $e");
      return false; // 기본값
    }
  }
}

class ConnectCodeProvider extends ChangeNotifier {
  bool _isCodeGenerated = false;
  bool _isCodeExpired = false;
  String _connectCodeText = "";
  TextEditingController _codeTextEditController = TextEditingController();

  bool get isCodeGenerated => _isCodeGenerated;

  bool get isCodeExpired => _isCodeExpired;

  String get connectCodeText => _connectCodeText;

  TextEditingController get codeTextEditController => _codeTextEditController;

  void setIsCodeGenerated(bool bool) {
    _isCodeGenerated = bool;
    notifyListeners();
  }

  void setIsCodeExpired(bool bool) {
    _isCodeExpired = bool;
    notifyListeners();
  }

  void setConnectCodeText(String randomCode) {
    _connectCodeText = randomCode;
    notifyListeners();
  }

  void setCodeText(String randomCode) {
    _connectCodeText = randomCode;
    notifyListeners();
  }
}

class CalendarProvider extends ChangeNotifier {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  DateTime get focusedDay => _focusedDay;

  DateTime? get selectedDay => _selectedDay;

  void setFocusedDay(DateTime date) {
    _focusedDay = date;
    notifyListeners();
  }

  void setSelectedDay(DateTime date) {
    _selectedDay = date;
    notifyListeners();
  }
}
