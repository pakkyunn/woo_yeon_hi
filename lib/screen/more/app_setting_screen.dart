import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/widget/more/app_setting_top_app_bar.dart';
import 'package:app_settings/app_settings.dart';

import '../../provider/login_register_provider.dart';
import '../../dao/user_dao.dart';
import '../../dialogs.dart';
import '../../style/color.dart';
import '../../style/text_style.dart';
import '../../utils.dart';
import '../login/login_screen.dart';
import 'app_lock_setting_screen.dart';

class AppSettingScreen extends StatefulWidget {
  const AppSettingScreen({super.key});

  @override
  State<AppSettingScreen> createState() => _AppSettingScreenState();
}

class _AppSettingScreenState extends State<AppSettingScreen> {
  static const storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var deviceHeight = MediaQuery.of(context).size.height;

      return Consumer<UserProvider>(builder: (context, provider, child) {
        return Scaffold(
          appBar: const AppSettingTopAppBar(),
          body: Container(
              width: deviceWidth,
              height: deviceHeight,
              padding: const EdgeInsets.all(20),
              color: ColorFamily.cream,
              child: Column(
                children: [
                  SizedBox(
                      width: deviceWidth - 40,
                      height: 60,
                      child: Material(
                        color: ColorFamily.cream,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("앱 활동 알림",
                                    style: TextStyleFamily.smallTitleTextStyle),
                                Switch(
                                    value: provider.notificationAllow,
                                    activeColor: ColorFamily.white,
                                    activeTrackColor: ColorFamily.pink,
                                    inactiveThumbColor: ColorFamily.gray,
                                    inactiveTrackColor: ColorFamily.white,
                                    trackOutlineColor: provider.notificationAllow
                                        ? MaterialStateProperty.all(
                                            Colors.transparent)
                                        : MaterialStateProperty.all(
                                            ColorFamily.gray),
                                    trackOutlineWidth:
                                        const MaterialStatePropertyAll(1),
                                    onChanged: (bool value) async {
                                      value
                                      ? await checkAndRequestNotificationPermission(context, _showDialog)
                                        ? showPinkSnackBar(context, '앱 활동 알림이 설정되었습니다')
                                        : setState(() {
                                          value = false;
                                        })
                                      : showPinkSnackBar(context, '앱 활동 알림이 해제되었습니다');
                                      await updateSpecificUserData(provider.userIdx, 'notification_allow', value);
                                      provider.setNotificationAllow(value);
                                    }),
                              ],
                            ),
                            const SizedBox(
                              height: 0.5,
                              child: Divider(
                                  color: ColorFamily.gray, thickness: 0.5),
                            )
                          ],
                        ),
                      )),
                  SizedBox(
                      width: deviceWidth - 40,
                      height: 60,
                      child: Material(
                        color: ColorFamily.cream,
                        child: InkWell(
                          splashFactory: NoSplash.splashFactory,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AppLockSettingScreen()
                                ));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("잠금 설정",
                                      style:
                                          TextStyleFamily.smallTitleTextStyle),
                                  SvgPicture.asset(
                                      "lib/assets/icons/expand.svg")
                                ],
                              ),
                              const SizedBox(
                                height: 0.5,
                                child: Divider(
                                    color: ColorFamily.gray, thickness: 0.5),
                              )
                            ],
                          ),
                        ),
                      )),
                  SizedBox(
                      width: deviceWidth - 40,
                      height: 60,
                      child: const Material(
                        color: ColorFamily.cream,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("현재 앱 버전",
                                    style: TextStyleFamily.smallTitleTextStyle),
                                Text("v 1.0",
                                    style: TextStyleFamily.smallTitleTextStyle),
                              ],
                            ),
                            SizedBox(
                              height: 0.5,
                              child: Divider(
                                  color: ColorFamily.gray, thickness: 0.5),
                            )
                          ],
                        ),
                      )),
                  SizedBox(
                      width: deviceWidth - 40,
                      height: 60,
                      child: Material(
                        color: ColorFamily.cream,
                        child: InkWell(
                          splashFactory: NoSplash.splashFactory,
                          onTap: () async {
                            _logOut(context);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(height: 5),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: const Text("로그아웃",
                                    style: TextStyleFamily.smallTitleTextStyle),
                              ),
                              const SizedBox(
                                height: 0.5,
                                child: Divider(
                                    color: ColorFamily.gray, thickness: 0.5),
                              )
                            ],
                          ),
                        ),
                      )),
                ],
              )));
    });
  }

  void _showDialog(){
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            surfaceTintColor: ColorFamily.white,
            backgroundColor: ColorFamily.white,
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        children: [
                          Text(
                            '알림 권한 필요',
                            style: TextStyleFamily.dialogTitleTextStyle,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            '설정에서 알림 권한을 허용해주세요.',
                            style: TextStyleFamily.normalTextStyle,
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(
                                      ColorFamily.gray)),
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                "취소",
                                style: TextStyleFamily.dialogButtonTextStyle,
                              )),
                          TextButton(
                              style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(
                                      ColorFamily.gray)),
                              onPressed: () {
                                Navigator.of(context).pop();
                                AppSettings.openAppSettings(type: AppSettingsType.notification);
                              },
                              child: const Text(
                                "설정 열기",
                                style:
                                TextStyleFamily.dialogButtonTextStyle_pink,
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  void _logOut(BuildContext context) async {
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
    await updateSpecificUserData(Provider.of<UserProvider>(context, listen: false).userIdx, 'login_type', 0);
    await updateSpecificUserData(Provider.of<UserProvider>(context, listen: false).userIdx, 'user_state', 2);
    await storage.delete(key: "lockPassword");
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false);
    showBlackToast("로그아웃 되었습니다");
  }
}
