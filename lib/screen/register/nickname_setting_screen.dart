import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/screen/register/birthday_setting_screen.dart';
import 'package:woo_yeon_hi/screen/login/login_screen.dart';
import 'package:woo_yeon_hi/style/text_style.dart';

import '../../dao/user_dao.dart';
import '../../dialogs.dart';
import '../../provider/login_register_provider.dart';
import '../../style/color.dart';
import '../../style/font.dart';
import '../../utils.dart';

class NickNameSettingScreen extends StatefulWidget {
  // final bool isHost;

  const NickNameSettingScreen({super.key});

  @override
  State<NickNameSettingScreen> createState() => _NickNameSettingScreenState();
}

class _NickNameSettingScreenState extends State<NickNameSettingScreen> {
  bool _showErrorMessages = false;

  dynamic loverNickNameTextEditController;
  late String loverNickname;

  @override
  void initState() {
    super.initState();

    loverNickname = UserProvider().loverNickname;
    loverNickNameTextEditController =
        TextEditingController(text: loverNickname);
  }

  @override
  void dispose() {
    loverNickNameTextEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Container(
      color: ColorFamily.cream,
      padding: const EdgeInsets.all(20),
      child: Consumer<UserProvider>(builder: (context, provider, child) {
        return SingleChildScrollView(
            child: Column(children: [
          SizedBox(
            height: deviceHeight - 40,
            width: deviceWidth - 40,
            child: Column(
              children: [
                SizedBox(
                    height: deviceHeight - 90,
                    width: deviceWidth - 40,
                    child: Column(
                      children: [
                        SizedBox(
                          height: deviceHeight - 140,
                          width: deviceWidth - 40,
                          child: Column(
                            children: [
                              SizedBox(height: deviceHeight * 0.1),
                              // widget.isHost
                                  const Text(
                                      "3 / 5",
                                      style: TextStyle(
                                          fontFamily: FontFamily.mapleStoryBold,
                                          fontSize: 15,
                                          color: ColorFamily.pink),
                                  ),
                                  // : const Text(
                                  //     "2 / 4",
                                  //     style: TextStyle(
                                  //         fontFamily: FontFamily.mapleStoryBold,
                                  //         fontSize: 15,
                                  //         color: ColorFamily.pink),
                                  //   ),
                              const SizedBox(height: 20),
                              // widget.isHost
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                            "lib/assets/icons/heart_fill.svg",
                                            height: 24),
                                        SvgPicture.asset(
                                            "lib/assets/icons/triple_right_arrow.svg",
                                            height: 24),
                                        SvgPicture.asset(
                                            "lib/assets/icons/heart_fill.svg",
                                            height: 24),
                                        SvgPicture.asset(
                                            "lib/assets/icons/triple_right_arrow.svg",
                                            height: 24),
                                        SvgPicture.asset(
                                            "lib/assets/icons/heart_fill.svg",
                                            height: 24),
                                        SvgPicture.asset(
                                            "lib/assets/icons/triple_right_arrow.svg",
                                            height: 24),
                                        SvgPicture.asset(
                                            "lib/assets/icons/heart_outlined.svg",
                                            height: 24),
                                        SvgPicture.asset(
                                            "lib/assets/icons/triple_right_arrow.svg",
                                            height: 24),
                                        SvgPicture.asset(
                                            "lib/assets/icons/heart_outlined.svg",
                                            height: 24),
                                      ],
                                    ),
                                  // : Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.center,
                                  //     children: [
                                  //       SvgPicture.asset(
                                  //           "lib/assets/icons/heart_fill.svg",
                                  //           height: 24),
                                  //       SvgPicture.asset(
                                  //           "lib/assets/icons/triple_right_arrow.svg",
                                  //           height: 24),
                                  //       SvgPicture.asset(
                                  //           "lib/assets/icons/heart_fill.svg",
                                  //           height: 24),
                                  //       SvgPicture.asset(
                                  //           "lib/assets/icons/triple_right_arrow.svg",
                                  //           height: 24),
                                  //       SvgPicture.asset(
                                  //           "lib/assets/icons/heart_outlined.svg",
                                  //           height: 24),
                                  //       SvgPicture.asset(
                                  //           "lib/assets/icons/triple_right_arrow.svg",
                                  //           height: 24),
                                  //       SvgPicture.asset(
                                  //           "lib/assets/icons/heart_outlined.svg",
                                  //           height: 24),
                                  //     ],
                                  //   ),
                              SizedBox(height: deviceHeight * 0.05),
                              const Text("연인의 별명을 지어주세요!",
                                  style: TextStyleFamily.smallTitleTextStyle),
                              SizedBox(height: deviceHeight * 0.2),
                              SizedBox(
                                width: 250,
                                child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      loverNickname = value;
                                    });
                                  },
                                  onFieldSubmitted: (value) {
                                    loverNickname = value;
                                  },
                                  controller: loverNickNameTextEditController,
                                  onTapOutside: (event) {
                                    FocusScope.of(context).unfocus();
                                  },
                                  decoration: const InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ColorFamily.black)),
                                    errorStyle: TextStyle(
                                      color: ColorFamily.black,
                                      fontSize: 12,
                                      fontFamily: FontFamily.mapleStoryLight,
                                    ),
                                  ),
                                  autovalidateMode: _showErrorMessages
                                      ? AutovalidateMode.always
                                      : AutovalidateMode.disabled,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '별명을 입력해주세요!';
                                    }
                                    return null;
                                  },
                                  cursorColor: ColorFamily.black,
                                  maxLength: 10,
                                  keyboardType: TextInputType.text,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: ColorFamily.black,
                                      fontSize: 20,
                                      fontFamily: FontFamily.mapleStoryLight),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // widget.isHost
                                Material(
                                    color: ColorFamily.white,
                                    elevation: 0.5,
                                    shadowColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0),
                                    ),
                                    child: InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        child: SizedBox(
                                            height: deviceHeight * 0.045,
                                            width: deviceWidth * 0.4,
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: const Text(
                                                "이전",
                                                style: TextStyleFamily
                                                    .normalTextStyle,
                                              ),
                                            ))),
                                  ),
                                // : SizedBox(
                                //     height: deviceHeight * 0.045,
                                //     width: deviceWidth * 0.4),
                            Material(
                              color: ColorFamily.beige,
                              elevation: 0.5,
                              shadowColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  if (provider.checkProvider(
                                      loverNickNameTextEditController)) {
                                    await updateSpecificUserData(provider.userIdx,
                                        'lover_nickname', loverNickname);
                                    await updateSpecificUserData(provider.loverIdx,
                                        'user_nickname', loverNickname);
                                    provider.setLoverNickname(loverNickname);
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BirthdaySettingScreen()));
                                  } else {
                                    setState(() {
                                      _showErrorMessages = true;
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(20.0),
                                child: SizedBox(
                                    height: deviceHeight * 0.045,
                                    width: deviceWidth * 0.4,
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "다음",
                                        style:
                                            TextStyleFamily.normalTextStyle,
                                      ),
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      signOut(context);
                      showBlackToast("등록이 취소되었습니다");
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                          (route) => false);
                    },
                    child: const Text(
                      "나가기",
                      style: TextStyleFamily.normalTextStyle,
                    ),
                  ),
                )
              ],
            ),
          ),
        ]));
      }),
    ));
  }
}
