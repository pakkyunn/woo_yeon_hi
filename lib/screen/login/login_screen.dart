import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/login_register_dao.dart';
import 'package:woo_yeon_hi/dao/user_dao.dart';
import 'package:woo_yeon_hi/dialogs.dart';
import 'package:woo_yeon_hi/provider/login_register_provider.dart';
import 'package:woo_yeon_hi/screen/login/account_processing_screen.dart';
import 'package:woo_yeon_hi/screen/register/code_connect_screen.dart';
import 'package:woo_yeon_hi/style/font.dart';
import 'package:woo_yeon_hi/style/text_style.dart';
import '../../style/color.dart';

import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _RegisterScreen();
}

class _RegisterScreen extends State<LoginScreen> {
  bool loginSuccess = false;

  signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      Provider.of<UserProvider>(context, listen: false)
          .setUserAccount(googleUser.email);
      setState(() {
        loginSuccess = true;
      });
    } else {
      showBlackToast("구글 계정 로그인에 실패하였습니다");
    }
  }

  signInWithKakao() async {
    if (await isKakaoTalkInstalled()) {
      try {
        // 카카오톡 설치됨, 카카오톡으로 로그인 시도
        await UserApi.instance.loginWithKakaoTalk();
        await _fetchKakaoUserInfo();
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');
        showBlackToast("카카오톡 로그인에 실패하였습니다");
        if (error is PlatformException && error.code == 'CANCELED') {
          print('사용자가 로그인 취소');
          showBlackToast("카카오톡 로그인을 취소하였습니다");
          return;
        }

        print('카카오 계정으로 로그인 시도');
        try {
          await UserApi.instance.loginWithKakaoAccount();
          await _fetchKakaoUserInfo();
        } catch (error) {
          print('카카오 계정으로 로그인 실패 $error');
          showBlackToast("카카오 계정 로그인에 실패하였습니다");
        }
      }
    } else {
      // 카카오톡 설치 안됨, 카카오계정으로 로그인 시도
      try {
        await UserApi.instance.loginWithKakaoAccount();
        await _fetchKakaoUserInfo();
      } catch (error) {
        showBlackToast("카카오 계정 로그인에 실패하였습니다");
      }
    }
  }

  _fetchKakaoUserInfo() async {
    try {
      User user = await UserApi.instance.me();
      Provider.of<UserProvider>(context, listen: false)
          .setUserAccount(user.id.toString());
      setState(() {
        loginSuccess = true;
      });
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
      showBlackToast("사용자 정보 요청에 실패하였습니다");
    }
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
            width: deviceWidth,
            color: ColorFamily.cream,
            padding: const EdgeInsets.all(20),
            child: Consumer<UserProvider>(builder: (context, provider, child) {
              return Column(
                children: [
                  SizedBox(height: deviceHeight * 0.2),
                  Image.asset(
                    'lib/assets/images/wooyeonhi_logo.png',
                    height: deviceHeight * 0.35,
                  ),
                  SizedBox(height: deviceHeight * 0.18),
                  Column(
                    children: [
                      Material(
                          color: ColorFamily.white,
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: InkWell(
                            onTap: () async {
                              switch (provider.userState) {
                                case 0: // 미등록 상태
                                  await signInWithGoogle();
                                  if (loginSuccess == true) {
                                    var userData =
                                        await getUserData(provider.userAccount);
                                    // 기존 등록 계정이 있는 경우
                                    if (userData != {}) {
                                      if(context.mounted){
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                surfaceTintColor:
                                                ColorFamily.white,
                                                backgroundColor:
                                                ColorFamily.white,
                                                child: Wrap(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 30, 0, 20),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Text(
                                                                "기존 계정 로그인",
                                                                style: TextStyleFamily
                                                                    .dialogTitleTextStyle,
                                                              ),
                                                              const SizedBox(
                                                                height: 15,
                                                              ),
                                                              Text(
                                                                "이미 등록된 계정이 있습니다.\n해당 계정으로 로그인합니다.",
                                                                style: TextStyleFamily
                                                                    .hintTextStyle,
                                                              )
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 30,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                            children: [
                                                              TextButton(
                                                                  style: ButtonStyle(
                                                                      overlayColor:
                                                                      MaterialStateProperty.all(ColorFamily
                                                                          .gray)),
                                                                  onPressed: (){Navigator.pop(context);},
                                                                  child:
                                                                  const Text(
                                                                    "확인",
                                                                    style: TextStyleFamily
                                                                        .dialogButtonTextStyle_pink,
                                                                  ))
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).then((_) async {
                                          final snackBar = SnackBar(
                                            content: Text("기존 계정으로 로그인 중입니다...", textAlign: TextAlign.center, style: TextStyleFamily.normalTextStyle),
                                            backgroundColor: ColorFamily.pink,
                                            duration: Duration(minutes: 5), // 히스토리 저장작업이 끝날 때까지 스낵바가 유지되도록 설정
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                          var loverProfileMessage = await getSpecificUserData(userData["lover_idx"], "profile_message");
                                          var loverProfileImagePath = await getSpecificUserData(userData["lover_idx"], "user_profile_image");
                                          final userProfileImage =
                                          userData["user_profile_image"] == "lib/assets/images/default_profile.png"
                                              ? Image.asset("lib/assets/images/default_profile.png")
                                              : await getProfileImage(userData["user_profile_image"]);
                                          final loverProfileImage =
                                          loverProfileImagePath == "lib/assets/images/default_profile.png"
                                              ? Image.asset("lib/assets/images/default_profile.png")
                                              : await getProfileImage(loverProfileImagePath);
                                          final memoryBannerImage =
                                          userData["memory_banner_image"] == ""
                                              ? Image.asset("lib/assets/images/default_profile.png")
                                              : await getMemoryBannerImage(userData["memory_banner_image"]);
                                          provider.setUserAllData(
                                              userData[
                                              "user_idx"],
                                              userData[
                                              "user_account"],
                                              userData[
                                              "app_lock_state"],
                                              userData[
                                              "home_preset_type"],
                                              1,
                                              userData[
                                              "love_dDay"],
                                              userData[
                                              "lover_idx"],
                                              userData[
                                              "notification_allow"],
                                              userData[
                                              "profile_message"],
                                              loverProfileMessage,
                                              userData[
                                              "top_bar_type"],
                                              userData[
                                              "user_birth"],
                                              userData[
                                              "user_nickname"],
                                              userData[
                                              "lover_nickname"],
                                              userData[
                                              "user_profile_image"],
                                              loverProfileImagePath,
                                              userProfileImage,
                                              loverProfileImage,
                                              userData[
                                              "user_state"],
                                              userData[
                                              "memory_banner_image"],
                                              memoryBannerImage);
                                          if(context.mounted){
                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                    const MainScreen()));
                                            showPinkSnackBar(context, "로그인 성공!");
                                            updateSpecificUserData(provider.userIdx, "user_state", 1);
                                            updateSpecificUserData(provider.userIdx, "login_type", 1);
                                            const storage = FlutterSecureStorage();
                                            storage.write(
                                                key: "userAccount",
                                                value: provider.userAccount);
                                            storage.write(
                                                key: "userIdx",
                                                value: "${provider.userIdx}");
                                          }
                                        });
                                      }
                                    }
                                    // 기존 등록 계정이 없는 경우
                                    else {
                                      var userIdx = await getUserSequence() + 1;
                                      await saveUserInfo(
                                          provider.userAccount, userIdx, 1);
                                      provider.setUserIdx(userIdx);
                                      provider.setLoginType(1);
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                              const CodeConnectScreen()));
                                      showBlackToast("구글 계정으로 로그인 되었습니다");
                                    }
                                  }

                                case 2: // 로그아웃 상태
                                  provider.loginType == 1
                                      ? {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MainScreen())),
                                          updateSpecificUserData(
                                              provider.userIdx,
                                              "user_state",
                                              1),
                                        showPinkSnackBar(context, "로그인 성공!")
                                        }
                                      : showBlackToast("기존에 등록된 다른 계정이 존재합니다");

                                case 3: // 삭제 처리중 상태
                                  dialogTitleWithContent(context, "계정 삭제 처리중",
                                      "삭제 대기중인 계정이 있습니다.\n처리 화면으로 이동합니다.", () {
                                    Navigator.pop(context);
                                  }, () {
                                    Navigator.pop(context);
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) =>
                                            const AccountProcessingScreen()));
                                  });
                              }
                            },
                            borderRadius: BorderRadius.circular(20.0),
                            child: SizedBox(
                                height: deviceHeight * 0.06,
                                width: deviceWidth * 0.75,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: SvgPicture.asset(
                                            "lib/assets/icons/google_logo.svg",
                                            height: 24,
                                            width: 24)),
                                    const Text("구글 계정으로 로그인하기",
                                        style: TextStyleFamily
                                            .smallTitleTextStyle),
                                    const SizedBox(height: 24, width: 24)
                                  ],
                                )),
                          )),
                      const SizedBox(height: 10),
                      Material(
                          color: const Color(0xFFFEE500),
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: InkWell(
                            onTap: () async {
                              switch (provider.userState) {
                                case 0: // 미등록 상태
                                  await signInWithKakao();
                                  if (loginSuccess == true) {
                                    var userData =
                                    await getUserData(provider.userAccount);
                                    // 기존 등록 계정이 있는 경우
                                    if (userData != {}) {
                                      if(context.mounted){
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                surfaceTintColor:
                                                ColorFamily.white,
                                                backgroundColor:
                                                ColorFamily.white,
                                                child: Wrap(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 30, 0, 20),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Text(
                                                                "기존 계정 로그인",
                                                                style: TextStyleFamily
                                                                    .dialogTitleTextStyle,
                                                              ),
                                                              const SizedBox(
                                                                height: 15,
                                                              ),
                                                              Text(
                                                                "이미 등록된 계정이 있습니다.\n해당 계정으로 로그인합니다.",
                                                                style: TextStyleFamily
                                                                    .hintTextStyle,
                                                              )
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 30,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                            children: [
                                                              TextButton(
                                                                  style: ButtonStyle(
                                                                      overlayColor:
                                                                      MaterialStateProperty.all(ColorFamily
                                                                          .gray)),
                                                                  onPressed: (){Navigator.pop(context);},
                                                                  child:
                                                                  const Text(
                                                                    "확인",
                                                                    style: TextStyleFamily
                                                                        .dialogButtonTextStyle_pink,
                                                                  ))
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).then((_) async {
                                          var loverProfileMessage = await getSpecificUserData(userData["lover_idx"], "profile_message");
                                          var loverProfileImagePath = await getSpecificUserData(userData["lover_idx"], "user_profile_image");
                                          final userProfileImage =
                                          userData["user_profile_image"] == "lib/assets/images/default_profile.png"
                                              ? Image.asset("lib/assets/images/default_profile.png")
                                              : await getProfileImage(userData["user_profile_image"]);
                                          final loverProfileImage =
                                          loverProfileImagePath == "lib/assets/images/default_profile.png"
                                              ? Image.asset("lib/assets/images/default_profile.png")
                                              : await getProfileImage(loverProfileImagePath);
                                          final memoryBannerImage =
                                          userData["memory_banner_image"] == ""
                                              ? Image.asset("lib/assets/images/default_profile.png")
                                              : await getMemoryBannerImage(userData["memory_banner_image"]);
                                          provider.setUserAllData(
                                              userData[
                                              "user_idx"],
                                              userData[
                                              "user_account"],
                                              userData[
                                              "app_lock_state"],
                                              userData[
                                              "home_preset_type"],
                                              2,
                                              userData[
                                              "love_dDay"],
                                              userData[
                                              "lover_idx"],
                                              userData[
                                              "notification_allow"],
                                              userData[
                                              "profile_message"],
                                              loverProfileMessage,
                                              userData[
                                              "top_bar_type"],
                                              userData[
                                              "user_birth"],
                                              userData[
                                              "user_nickname"],
                                              userData[
                                              "lover_nickname"],
                                              userData[
                                              "user_profile_image"],
                                              loverProfileImagePath,
                                              userProfileImage,
                                              loverProfileImage,
                                              userData[
                                              "user_state"],
                                              userData[
                                              "memory_banner_image"],
                                              memoryBannerImage);
                                          if(context.mounted){
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                    const MainScreen()));
                                            showPinkSnackBar(context, "로그인 성공!");
                                            updateSpecificUserData(provider.userIdx, "user_state", 1);
                                            updateSpecificUserData(provider.userIdx, "login_type", 2);
                                            const storage = FlutterSecureStorage();
                                            storage.write(
                                                key: "userAccount",
                                                value: provider.userAccount);
                                            storage.write(
                                                key: "userIdx",
                                                value: "${provider.userIdx}");
                                          }
                                        });
                                      }
                                    }
                                    else {
                                      var userIdx = await getUserSequence() + 1;
                                      await saveUserInfo(
                                          provider.userAccount, userIdx, 1);
                                      provider.setUserIdx(userIdx);
                                      provider.setLoginType(2);
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                              const CodeConnectScreen()));
                                      showBlackToast("카카오 계정으로 로그인 되었습니다");
                                    }
                                  }

                                case 2: // 로그아웃 상태
                                  provider.loginType == 2
                                      ? {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const MainScreen())),
                                    updateSpecificUserData(
                                        provider.userIdx,
                                        "user_state",
                                        1),
                                  showPinkSnackBar(context, "로그인 성공!")
                                  }
                                      : showBlackToast("기존에 등록된 다른 계정이 존재합니다");

                                case 3: // 삭제 처리중 상태
                                  dialogTitleWithContent(context, "계정 삭제 처리중",
                                      "삭제 대기중인 계정이 있습니다.\n처리 화면으로 이동합니다.", () {
                                        Navigator.pop(context);
                                      }, () {
                                        Navigator.pop(context);
                                        Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) =>
                                            const AccountProcessingScreen()));
                                      });
                              }
                            },
                            borderRadius: BorderRadius.circular(20.0),
                            child: SizedBox(
                                height: deviceHeight * 0.06,
                                width: deviceWidth * 0.75,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: SvgPicture.asset(
                                            "lib/assets/icons/kakao_logo.svg",
                                            height: 24,
                                            width: 24)),
                                    const Text("카카오 계정으로 로그인하기",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontFamily:
                                                FontFamily.mapleStoryLight,
                                            color: Color(0xD9000000))),
                                    const SizedBox(height: 24, width: 24)
                                  ],
                                )),
                          )),
                    ],
                  ),
                ],
              );
            })));
  }
}
