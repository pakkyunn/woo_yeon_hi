import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/screen/main_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/text_style.dart';

import '../../dao/user_dao.dart';
import '../../model/enums.dart';
import '../../model/user_model.dart';
import '../../style/font.dart';

class RegisterDoneScreen extends StatefulWidget {
  RegisterDoneScreen({super.key, required this.title, required this.isHost});

  final String title;
  final bool isHost;

  @override
  State<RegisterDoneScreen> createState() => _RegisterDoneScreen();
}

class _RegisterDoneScreen extends State<RegisterDoneScreen>
    with TickerProviderStateMixin {

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

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          color: ColorFamily.cream,
          padding: const EdgeInsets.all(20),
          child: AnimatedBackground(
            behaviour:
            RandomParticleBehaviour(
              options: const ParticleOptions(
                opacityChangeRate: 25,
                spawnMinRadius: 10,
                spawnMaxRadius: 30,
                spawnMinSpeed: 30,
                spawnMaxSpeed: 50,
                particleCount: 30,
                minOpacity: 0.1,
                maxOpacity: 0.4,
                spawnOpacity: 0.5,
                baseColor: ColorFamily.cream,
                image: Image(image: AssetImage('lib/assets/images/heart_fill.png')),
              ),
            ),
            vsync: this,
            child: Column(
              children: [
                Container(
                    height: deviceHeight - 40,
                    width: deviceWidth - 40,
                    child: Column(
                      children: [
                        Container(
                            height: deviceHeight - 90,
                            width: deviceWidth - 40,
                            child: Column(children: [
                              SizedBox(
                                height: deviceHeight - 140,
                                width: deviceWidth - 40,
                                child: Column(children: [
                                    SizedBox(height: deviceHeight * 0.1),
                               const Text(
                                  "우연히",
                                  style: TextStyle(
                                      color: ColorFamily.pink,
                                      fontSize: 40,
                                      fontFamily: FontFamily.cafe24Moyamoya),
                                ),
                              SizedBox(height: deviceHeight * 0.2),
                              const Text(
                                "커플 등록이 완료되었습니다!",
                                style: TextStyle(
                                    color: ColorFamily.black,
                                    fontSize: 18,
                                    fontFamily: FontFamily.mapleStoryLight),
                              ),
                                    const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "지금부터 ",
                                    style: TextStyle(
                                        color: ColorFamily.black,
                                        fontSize: 18,
                                        fontFamily: FontFamily.mapleStoryLight),
                                  ),
                                  Text(
                                    userProvider.loverNickname,
                                    style: const TextStyle(
                                        color: ColorFamily.black,
                                        fontSize: 20,
                                        fontFamily: FontFamily.mapleStoryBold),
                                  ),const Text(
                                    " 님과",
                                    style: TextStyle(
                                        color: ColorFamily.black,
                                        fontSize: 18,
                                        fontFamily: FontFamily.mapleStoryLight),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                "소중한 추억을 쌓아보세요!",
                                style: TextStyle(
                                    color: ColorFamily.black,
                                    fontSize: 18,
                                    fontFamily: FontFamily.mapleStoryLight),
                              )
                            ])),
                              SizedBox(
                                height: deviceHeight * 0.045,
                                width: deviceWidth * 0.75,
                                child: Material(
                                color: ColorFamily.white,
                                elevation: 1,
                                shadowColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(20.0),
                                ),
                                child: InkWell(
                                    onTap: () async {
                                      widget.isHost
                                      ?saveUser(UserModel(userIdx: 1, loginType: userProvider.loginType, userAccount: userProvider.userAccount, userNickname: "기본닉네임", userBirth: userProvider.userBirth, userProfileImage: "", loverUserIdx: 2, loverNickname: userProvider.loverNickname, homePresetType: userProvider.homePresetType, topBarType: 0, profileMessage: "", alarmsAllow: false,appLockState: 0, topBarActivate: false, lockPassword: [], userState: 1, loveDday: userProvider.loveDday))
                                      :saveUser(UserModel(userIdx: 2, loginType: userProvider.loginType, userAccount: userProvider.userAccount, userNickname: "기본닉네임", userBirth: userProvider.userBirth, userProfileImage: "", loverUserIdx: 2, loverNickname: userProvider.loverNickname, homePresetType: userProvider.homePresetType, topBarType: 0, profileMessage: "", alarmsAllow: false,appLockState: 0, topBarActivate: false, lockPassword: [], userState: 1, loveDday: DateTime.now()));

                                      // 자동로그인
                                      // write 함수를 통하여 key에 맞는 정보를 적게 됩니다.
                                      // await storage.write(
                                      // key: "loginData",
                                      // value: userProvider.userAccount);

                                      runApp(const MainScreen());
                                    },
                                    borderRadius:
                                    BorderRadius.circular(20.0),
                                    child: Container(
                                      decoration: BoxDecoration(border: Border.all(color: ColorFamily.pink,width: 0.5),borderRadius: BorderRadius.circular(20)),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "홈 화면으로 이동",
                                        style: TextStyleFamily.smallTitleTextStyle
                                      ),
                                    )),
                              ),
                              )

                      ],
                    )),
              ],
            ),
          ),
        ]))));
  }
}