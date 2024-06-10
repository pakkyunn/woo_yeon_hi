import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/screen/more/app_lock_setting_screen.dart';
import 'package:woo_yeon_hi/screen/more/password_setting_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/widget/more/app_lock_top_app_bar.dart';

import '../../model/user_model.dart';
import '../../style/font.dart';
import '../../style/text_style.dart';

class PasswordCheckScreen extends StatefulWidget {
  final bool bioAuth;

  List<int> password;

  PasswordCheckScreen(
      {required this.bioAuth, super.key, required this.password});

  @override
  State<PasswordCheckScreen> createState() => _PasswordCheckScreenState();
}

class _PasswordCheckScreenState extends State<PasswordCheckScreen> {
  dynamic userProvider;

  @override
  void initState() {
    super.initState();

    userProvider = Provider.of<UserModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var deviceHeight = MediaQuery.of(context).size.height;

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PasswordSettingScreen(bioAuth: widget.bioAuth))),
        child: Scaffold(
          appBar: AppBar(
            surfaceTintColor: ColorFamily.cream,
            backgroundColor: ColorFamily.cream,
            centerTitle: true,
            title: const Text(
              "앱 잠금 설정",
              style: TextStyleFamily.appBarTitleLightTextStyle,
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PasswordSettingScreen(bioAuth: widget.bioAuth)));
              },
              icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
            ),
          ),
          body: Container(
            width: deviceWidth,
            height: deviceHeight,
            padding: const EdgeInsets.all(20),
            color: ColorFamily.cream,
            child: Column(
              children: [
                SizedBox(height: deviceHeight * 0.1),
                const Text("비밀번호 확인", style: TextStyleFamily.passwordTextStyle),
                SizedBox(height: deviceHeight * 0.08),
                SizedBox(
                  height: 50,
                  width: deviceWidth * 0.6,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(4, (index) {
                        return _buildPasswordIcon(
                            index < checkingPassword.length);
                      })),
                ),
                SizedBox(height: deviceHeight * 0.25),
                SizedBox(
                  height: deviceHeight * 0.08,
                  width: deviceWidth - 40,
                  child: Row(
                    children: [
                      SizedBox(
                        height: deviceHeight * 0.08,
                        width: (deviceWidth - 40) / 3,
                        child: InkWell(
                          onTap: () {
                            _addNumber(1);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              "1",
                              style: TextStyleFamily.passwordTextStyle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: deviceHeight * 0.08,
                        width: (deviceWidth - 40) / 3,
                        child: InkWell(
                          onTap: () {
                            _addNumber(2);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              "2",
                              style: TextStyleFamily.passwordTextStyle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: deviceHeight * 0.08,
                        width: (deviceWidth - 40) / 3,
                        child: InkWell(
                          onTap: () {
                            _addNumber(3);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              "3",
                              style: TextStyleFamily.passwordTextStyle,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: deviceHeight * 0.08,
                  width: deviceWidth - 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: deviceHeight * 0.08,
                        width: (deviceWidth - 40) / 3,
                        child: InkWell(
                          onTap: () {
                            _addNumber(4);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              "4",
                              style: TextStyleFamily.passwordTextStyle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: deviceHeight * 0.08,
                        width: (deviceWidth - 40) / 3,
                        child: InkWell(
                          onTap: () {
                            _addNumber(5);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              "5",
                              style: TextStyleFamily.passwordTextStyle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: deviceHeight * 0.08,
                        width: (deviceWidth - 40) / 3,
                        child: InkWell(
                          onTap: () {
                            _addNumber(6);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              "6",
                              style: TextStyleFamily.passwordTextStyle,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: deviceHeight * 0.08,
                  width: deviceWidth - 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: deviceHeight * 0.08,
                        width: (deviceWidth - 40) / 3,
                        child: InkWell(
                          onTap: () {
                            _addNumber(7);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              "7",
                              style: TextStyleFamily.passwordTextStyle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: deviceHeight * 0.08,
                        width: (deviceWidth - 40) / 3,
                        child: InkWell(
                          onTap: () {
                            _addNumber(8);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              "8",
                              style: TextStyleFamily.passwordTextStyle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: deviceHeight * 0.08,
                        width: (deviceWidth - 40) / 3,
                        child: InkWell(
                          onTap: () {
                            _addNumber(9);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              "9",
                              style: TextStyleFamily.passwordTextStyle,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: deviceHeight * 0.08,
                  width: deviceWidth - 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: deviceHeight * 0.08,
                        width: (deviceWidth - 40) / 3,
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              "",
                              style: TextStyleFamily.passwordTextStyle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: deviceHeight * 0.08,
                        width: (deviceWidth - 40) / 3,
                        child: InkWell(
                          onTap: () {
                            _addNumber(0);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              "0",
                              style: TextStyleFamily.passwordTextStyle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: deviceHeight * 0.08,
                        width: (deviceWidth - 40) / 3,
                        child: InkWell(
                          onTap: () {
                            _removeNumber();
                          },
                          child: Container(
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                  "lib/assets/icons/backspace.svg")),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildPasswordIcon(bool isActive) {
    return isActive
        ? SvgPicture.asset("lib/assets/icons/woo_yeon_hi_48px.svg",
            width: 48, height: 48)
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SvgPicture.asset("lib/assets/icons/password_bar_24px.svg",
                width: 24),
          );
  }

  bool firstNumInput = false;
  bool secondNumInput = false;
  bool thirdNumInput = false;
  bool fourthNumInput = false;

  final List<int> checkingPassword = [];
  final int _maxNumbers = 4;

  void _numInputCheck() {
    setState(() {
      firstNumInput = checkingPassword.length > 0;
      secondNumInput = checkingPassword.length > 1;
      thirdNumInput = checkingPassword.length > 2;
      fourthNumInput = checkingPassword.length > 3;
    });
  }

  void _addNumber(int number) {
    setState(() {
      if (checkingPassword.length < _maxNumbers) {
        checkingPassword.add(number);
      }
      if (checkingPassword.length == _maxNumbers) {
        _checkPassword();
      }
    });
    _numInputCheck();
  }

  void _removeNumber() {
    setState(() {
      if (checkingPassword.isNotEmpty) {
        checkingPassword.removeLast();
      }
    });
    _numInputCheck();
  }

  void _checkPassword() {
    var listEquality = ListEquality();
    if (!listEquality.equals(checkingPassword, widget.password)) {
      Fluttertoast.showToast(
          msg: "비밀번호를 다르게 입력하였습니다.\n다시 확인해주세요.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: ColorFamily.black,
          textColor: ColorFamily.white,
          fontSize: 14.0);
      Future.delayed(const Duration(milliseconds: 100), () {
        _initiatePassword();
      });
    } else {
      setState(() {
        userProvider.lockPassword = checkingPassword;
        userProvider.appLockState = 1;
      });
      if (widget.bioAuth == true) {
        showBioAuthDialog(context);
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AppLockSettingScreen(isBioAuthSupported: widget.bioAuth)));
      }
    }
  }

  void _initiatePassword() {
    setState(() {
      firstNumInput = false;
      secondNumInput = false;
      thirdNumInput = false;
      fourthNumInput = false;

      checkingPassword.clear();
    });
  }

  final LocalAuthentication auth = LocalAuthentication();
  bool? _canCheckBiometrics;
  bool _isAuthenticating = false;

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
      });
      authenticated = await auth.authenticate(
        authMessages: [
          const AndroidAuthMessages(
            biometricHint: '',
            biometricNotRecognized: '생체정보가 일치하지 않습니다.',
            biometricRequiredTitle: '생체정보가 필요합니다.',
            biometricSuccess: '스캔 완료',
            cancelButton: '취소',
            deviceCredentialsRequiredTitle: '생체정보가 필요합니다.',
            deviceCredentialsSetupDescription: '기기 설정으로 이동하여 생체정보를 등록하세요.',
            goToSettingsButton: '설정',
            goToSettingsDescription: '기기 설정으로 이동하여 생체정보를 등록하세요.',
            signInTitle: '생체정보 스캔',
          )
        ],
        localizedReason: '기기에 등록된 생체정보를 스캔해주세요.',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
      });
      return;
    }
    if (!mounted) {
      return;
    }

    Future<void> _cancelAuthentication() async {
      await auth.stopAuthentication();
      setState(() => _isAuthenticating = false);
    }

    if (authenticated) {
      setState(() {
        userProvider.appLockState = 2;
      });
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AppLockSettingScreen(isBioAuthSupported: widget.bioAuth)));
    }
  }

  void showBioAuthDialog(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var deviceHeight = MediaQuery.of(context).size.height;

    showMaterialModalBottomSheet(
        backgroundColor: ColorFamily.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        context: context,
        builder: (context) => SizedBox(
            height: deviceHeight * 0.43,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Text('생체 인증 등록',
                        style: TextStyle(
                            color: ColorFamily.black,
                            fontFamily: FontFamily.mapleStoryLight,
                            fontSize: 20)),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: deviceWidth * 0.55,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: 64,
                              child: SvgPicture.asset(
                                  "lib/assets/icons/fingerprint.svg",
                                  height: 64)),
                          SvgPicture.asset("lib/assets/icons/face_id.svg",
                              width: 64, height: 64)
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: deviceWidth * 0.55,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("지문 인식",
                              style: TextStyleFamily.appBarTitleLightTextStyle),
                          Text("Face ID",
                              style: TextStyleFamily.appBarTitleLightTextStyle)
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text("기기에 등록되어 있는 생체정보를 통해",
                        style: TextStyleFamily.normalTextStyle),
                    const Text("앱 잠금을 해제할 수 있습니다.",
                        style: TextStyleFamily.normalTextStyle),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: deviceWidth - 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Material(
                        color: ColorFamily.white,
                        elevation: 0.5,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                userProvider.appLockState = 1;
                              });
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AppLockSettingScreen(
                                              isBioAuthSupported:
                                                  widget.bioAuth)));
                            },
                            borderRadius: BorderRadius.circular(20.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: ColorFamily.gray, width: 0.2),
                                  borderRadius: BorderRadius.circular(20)),
                              height: 40,
                              alignment: Alignment.center,
                              child: const Text(
                                "다음에",
                                style: TextStyleFamily.normalTextStyle,
                              ),
                            )),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Material(
                        color: ColorFamily.beige,
                        elevation: 0.5,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: InkWell(
                          onTap: () {
                            _authenticateWithBiometrics();
                          },
                          borderRadius: BorderRadius.circular(20.0),
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            child: const Text(
                              "사용하기",
                              style: TextStyleFamily.normalTextStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ])));
  }
}

//TODO 비밀번호 4자리 입력 완료시 widget.isBioAuthSupporeted = true 이면 생체인증 다이얼로그 띄우기
