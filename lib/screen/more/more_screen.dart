import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/user_dao.dart';
import 'package:woo_yeon_hi/screen/more/app_setting_screen.dart';
import 'package:woo_yeon_hi/screen/more/daily_summary_screen.dart';
import 'package:woo_yeon_hi/screen/more/help_screen.dart';
import 'package:woo_yeon_hi/screen/more/profile_edit_screen.dart';
import 'package:woo_yeon_hi/screen/more/ui_style_setting_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';
import 'package:woo_yeon_hi/style/text_style.dart';
import '../../model/user_model.dart';
import '../../provider/login_register_provider.dart';
import '../../widget/more/more_top_app_bar.dart';
import 'account_management_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var deviceHeight = MediaQuery.of(context).size.height;

    // final userSyncNickname = Provider.of<String>(context);
    // Provider.of<UserProvider>(context).setUserNickname(userSyncNickname);

    return Scaffold(
        resizeToAvoidBottomInset: false, // 키보드로 인한 레이아웃 변화 방지
        appBar: const MoreTopAppBar(),
        body: Container(
            height: deviceHeight,
            width: deviceWidth,
            padding: const EdgeInsets.all(20),
            color: ColorFamily.cream,
            child: Consumer<UserProvider>(builder: (context, provider, child) {
              return Column(
                children: [
                  SizedBox(
                    width: deviceWidth - 40,
                    child: Row(
                      children: [
                        Material(
                          elevation: 1,
                          borderRadius: BorderRadius.circular(65),
                          child: InkWell(
                            onTap: () {
                              provider.userProfileImagePath ==
                                  "lib/assets/images/default_profile.png"
                                  ? null
                                  : showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: SizedBox(
                                          width: deviceWidth * 0.8,
                                          height: deviceHeight * 0.6,
                                          child: provider.userProfileImage),
                                    );
                                  });
                            },
                            borderRadius: BorderRadius.circular(65),
                            splashColor: Colors.transparent,
                            child: ClipRRect(
                                  borderRadius: BorderRadius.circular(65),
                                  child: Container(
                                      width: deviceWidth * 0.35,
                                      height: deviceWidth * 0.35,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: provider
                                                  .userProfileImage.image,
                                              // Image 객체의 image 속성을 사용
                                              fit: BoxFit.cover))))

                              // child: provider.image != null
                              //     ? Image.file(File(provider.image!.path),
                              //         width: deviceWidth * 0.35,
                              //         height: deviceWidth * 0.35,
                              //         fit: BoxFit.cover)
                              //     : Image.asset(
                              //         provider.profileImagePath,
                              //         width: deviceWidth * 0.35,
                              //         height: deviceWidth * 0.35,
                              //       ),
                            ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          height: deviceWidth*0.3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(provider.userNickname,
                                      style: const TextStyle(
                                          color: ColorFamily.black,
                                          fontSize: 16,
                                          fontFamily:
                                          FontFamily.mapleStoryBold)),
                                  InkWell(
                                      onTap: () async {
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ProfileEditScreen()));
                                      },
                                      child: SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: SvgPicture.asset(
                                            'lib/assets/icons/expand.svg',
                                            fit: BoxFit.none,
                                          )))
                                ],
                              ),
                              const SizedBox(height: 10),
                              provider.userProfileMessage.isEmpty
                              ? SizedBox(
                                  width: deviceWidth * 0.4,
                                  child: Text("프로필 메시지로 내 마음을\n표현해보세요!",
                                      style: const TextStyle(
                                          color: ColorFamily.gray,
                                          fontSize: 12,
                                          fontFamily:
                                          FontFamily.mapleStoryLight),
                                      maxLines: 4))
                              : SizedBox(
                                  width: deviceWidth * 0.4,
                                  child: Text(provider.userProfileMessage,
                                      style: const TextStyle(
                                          color: ColorFamily.black,
                                          fontSize: 12,
                                          fontFamily:
                                              FontFamily.mapleStoryLight),
                                      maxLines: 4))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: deviceHeight * 0.05),
                  // _buildMenuItem(context, '추억 모아보기', 'lib/assets/icons/box.svg',
                  //     const DailySummaryScreen()),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                      context,
                      '화면 스타일 설정',
                      'lib/assets/icons/magicpen.svg',
                      const UiStyleSettingScreen()),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                      context,
                      '도움말',
                      'lib/assets/icons/message-question.svg',
                      const HelpScreen()),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                      context,
                      '계정 관리',
                      'lib/assets/icons/user_edit.svg',
                      const AccountManagementScreen()),
                  const SizedBox(height: 10),
                  _buildMenuItem(context, '앱 설정',
                      'lib/assets/icons/setting.svg', const AppSettingScreen()),
                ],
              );
            })));
  }
}

Widget _buildMenuItem(
    BuildContext context, String title, String iconPath, Widget screen) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Material(
        color: ColorFamily.white,
        elevation: 1,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: InkWell(
          splashFactory: NoSplash.splashFactory,
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => screen));
          },
          borderRadius: BorderRadius.circular(10.0),
          child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: SvgPicture.asset(iconPath, width: 24, height: 24),
                  ),
                  Text(title, style: TextStyleFamily.normalTextStyle),
                  Container(
                      margin: const EdgeInsets.only(right: 10),
                      height: 24,
                      width: 24)
                ],
              )),
        )),
  );
}
