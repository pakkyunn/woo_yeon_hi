import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/screen/more/more_screen.dart';
import 'package:woo_yeon_hi/screen/more/top_bar_ui_setting_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/text_style.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:woo_yeon_hi/utils.dart';

import '../../dao/user_dao.dart';
import '../../dialogs.dart';
import '../../model/user_model.dart';
import '../../provider/login_register_provider.dart';
import '../../style/font.dart';
import '../../widget/more/profile_edit_album.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final FocusNode _nickNamefocusNode = FocusNode();
  final FocusNode _profileMessageFocusNode = FocusNode();

  late String tempProfileImagePath;
  late String tempUserNickname;
  late String tempProfileMessage;
  late String tempUserBirth;
  late DateTime _selectedDate;


  @override
  void initState() {
    super.initState();
    _tempDataInitiate();
  }

  Future<void> _tempDataInitiate() async {
    var provider = Provider.of<UserProvider>(context, listen: false);
    provider.setTempImagePath(provider.profileImagePath);
    provider.setTempImage(provider.userProfileImage);
    tempUserNickname = provider.userNickname;
    tempProfileMessage = provider.profileMessage;
    tempUserBirth = provider.userBirth;
    _selectedDate = stringToDate(tempUserBirth);
  }

  @override
  void dispose() {
    _nickNamefocusNode.dispose();
    _profileMessageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var deviceHeight = MediaQuery.of(context).size.height;

    return Consumer<UserProvider>(builder: (context, provider, child) {
      return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) {
              return;
            }
            if (tempProfileImagePath != provider.profileImagePath ||
                tempUserNickname != provider.userNickname ||
                tempUserBirth != provider.userBirth ||
                tempProfileMessage != provider.profileMessage) {
              dialogTitleWithContent(
                  context, "프로필 편집 나가기", "변경사항은 저장되지 않습니다.",
                    () {
                  Navigator.pop(context, false);
                  _nickNamefocusNode.unfocus();
                  _profileMessageFocusNode.unfocus();
                  },
                    () {
                  Navigator.pop(context, true);
                  _nickNamefocusNode.unfocus();
                  _profileMessageFocusNode.unfocus();
                  Future.delayed(const Duration(milliseconds: 100), () {
                  Navigator.of(context).pop();
                  });
              });
            } else {
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              surfaceTintColor: ColorFamily.cream,
              backgroundColor: ColorFamily.cream,
              centerTitle: true,
              title: const Text(
                "프로필 편집",
                style: TextStyleFamily.appBarTitleLightTextStyle,
              ),
              leading: IconButton(
                onPressed: () {
                  if (tempProfileImagePath != provider.profileImagePath ||
                      tempUserNickname != provider.userNickname ||
                      tempUserBirth != provider.userBirth ||
                      tempProfileMessage != provider.profileMessage) {
                    dialogTitleWithContent(
                        context, "프로필 편집 나가기", "변경사항은 저장되지 않습니다.",
                            () {
                          Navigator.pop(context, false);
                          _nickNamefocusNode.unfocus();
                          _profileMessageFocusNode.unfocus();
                        },
                            () {
                          Navigator.pop(context, true);
                          _nickNamefocusNode.unfocus();
                          _profileMessageFocusNode.unfocus();
                          Future.delayed(const Duration(milliseconds: 100), () {
                            Navigator.of(context).pop();
                          });
                        });
                  } else {
                    FocusScope.of(context).unfocus();
                    Navigator.of(context).pop();
                  }
                },
                icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if (tempUserNickname.isNotEmpty) {
                        FocusScope.of(context).unfocus();
                        var imageName = "${provider.userIdx}_${DateTime.now()}";
                        deleteProfileImage(provider.profileImagePath); //storage에 저장되어 있던 기존 프로필사진 파일 삭제

                        // 기본 프로필 이미지로 변경하는 경우
                        if(provider.tempImagePath=="lib/assets/images/default_profile.png"){
                          updateUserProfileData(provider.userIdx,'user_profile_image','user_nickname', 'user_birth','profile_message',
                              "lib/assets/images/default_profile.png", tempUserNickname, tempUserBirth, tempProfileMessage);
                          await provider.setUserProfile(provider.tempImagePath, Image.asset("lib/assets/images/default_profile.png"),
                              tempUserNickname, tempUserBirth, tempProfileMessage);
                        } else{ // 새로운 프로필사진으로 변경하는 경우
                          uploadProfileImage(provider.image!, imageName);
                          updateUserProfileData(provider.userIdx,'user_profile_image','user_nickname', 'user_birth','profile_message',
                              imageName, tempUserNickname, tempUserBirth, tempProfileMessage);
                          await provider.setUserProfile(imageName, Image.file(File(provider.tempImagePath)),
                              tempUserNickname, tempUserBirth, tempProfileMessage);
                          // 상단바스타일3,4를 사용중인 경우 이미지 업데이트
                          if(provider.topBarType==3 || provider.topBarType==4){
                            //TODO 상대프로필사진 가져오는 코드
                            showCustomNotification(provider.loveDday, provider.topBarType, provider.userProfileImage, provider.userProfileImage);
                          }
                        }
                        Navigator.pop(context);
                        showPinkSnackBar(context, '프로필이 저장되었습니다!');
                    } else {
                      FocusScope.of(context).unfocus();
                      showBlackToast("닉네임을 입력해주세요!");
                    }
                  },
                  icon: SvgPicture.asset('lib/assets/icons/done.svg'),
                )
              ],
            ),
            body: Container(
              width: deviceWidth,
              height: deviceHeight,
              color: ColorFamily.cream,
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Column(
                    children: [
                      Column(
                        children: [
                          Stack(
                            children: [
                              Material(
                                elevation: 1,
                                borderRadius: BorderRadius.circular(65),
                                child: InkWell(
                                  onTap: () {
       //TODO 기본프로필이 아닌 상태에서 편집을 들어와서 바로 탭할 경우 provider.image와 provider.tempImage가 null임을 고려해서 수정 필요.
                                    provider.image != null
                                        ? showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Container(
                                                  width: deviceWidth * 0.8,
                                                  height: deviceHeight * 0.6,
                                                  // decoration: BoxDecoration(
                                                    // image: DecorationImage(
                                                    //   image: FileImage(File(
                                                    //       provider
                                                    //           .tempImagePath)),
                                                    //   fit: BoxFit.contain,
                                                    // ),
                                                  // ),
                                                  child: provider.tempImage,
                                                ),
                                              );
                                            })
                                        : null;
                                  },
                                  borderRadius: BorderRadius.circular(65),
                                  splashColor: Colors.transparent,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(65),
                                    child: Container(child: provider.tempImage,width: deviceWidth * 0.35, height: deviceWidth * 0.35),
                                    // child: provider.image != null
                                    //     ? Image.file(
                                    //         File(provider.image!.path),
                                    //         width: deviceWidth * 0.35,
                                    //         height: deviceWidth * 0.35,
                                    //         fit: BoxFit.cover,
                                    //       )
                                    //     : Container(child: provider.tempImage,width: deviceWidth * 0.35, height: deviceWidth * 0.35)
                                    // Image.asset(
                                    //         provider.tempImagePath,
                                    //         width: deviceWidth * 0.35,
                                    //         height: deviceWidth * 0.35,
                                    //       ),
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: deviceWidth * 0.25,
                                  left: deviceWidth * 0.26,
                                  child: const ProfileEditAlbum()),
                            ],
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "닉네임",
                            style: TextStyleFamily.normalTextStyle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        width: deviceWidth - 60,
                        child: Material(
                          elevation: 0.5,
                          color: ColorFamily.white,
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: TextFormField(
                              autofocus: false,
                              focusNode: _nickNamefocusNode,
                              maxLength: 10,
                              initialValue: tempUserNickname,
                              onChanged: (value) {
                                tempUserNickname = value;
                              },
                              onFieldSubmitted: (value) {
                                tempUserNickname = value;
                              },
                              onTapOutside: (event) {
                                FocusScope.of(context).unfocus();
                              },
                              style: TextStyleFamily.smallTitleTextStyle,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counter: SizedBox()),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "생년월일",
                            style: TextStyleFamily.normalTextStyle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        width: deviceWidth - 60,
                        child: Material(
                          elevation: 0.5,
                          color: ColorFamily.white,
                          borderRadius: BorderRadius.circular(15),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              picker.DatePicker.showDatePicker(
                                context,
                                showTitleActions: true,
                                minTime: DateTime(1900, 1, 1),
                                maxTime: DateTime.now(),
                                theme: const picker.DatePickerTheme(
                                  titleHeight: 60,
                                  containerHeight: 300,
                                  itemHeight: 50,
                                  headerColor: ColorFamily.white,
                                  backgroundColor: ColorFamily.white,
                                  itemStyle:
                                      TextStyleFamily.smallTitleTextStyle,
                                  cancelStyle: TextStyle(
                                    color: ColorFamily.black,
                                    fontSize: 18,
                                    fontFamily: FontFamily.mapleStoryLight,
                                  ),
                                  doneStyle: TextStyle(
                                    color: ColorFamily.black,
                                    fontSize: 18,
                                    fontFamily: FontFamily.mapleStoryLight,
                                  ),
                                ),
                                locale: picker.LocaleType.ko,
                                currentTime: _selectedDate,
                                onConfirm: (date) {
                                  setState(() {
                                    _selectedDate = date;
                                    tempUserBirth = dateToString(_selectedDate);
                                  });
                                  _nickNamefocusNode.unfocus();
                                  _profileMessageFocusNode.unfocus();
                                },
                                onCancel: () {
                                  _nickNamefocusNode.unfocus();
                                  _profileMessageFocusNode.unfocus();
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  tempUserBirth,
                                  style: TextStyleFamily.smallTitleTextStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "상태 메시지",
                            style: TextStyleFamily.normalTextStyle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 100,
                        width: deviceWidth - 60,
                        child: Material(
                          elevation: 0.5,
                          color: ColorFamily.white,
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: TextFormField(
                              focusNode: _profileMessageFocusNode,
                              initialValue: tempProfileMessage,
                              onChanged: (value) {
                                setState(() {
                                  tempProfileMessage = value;
                                });
                              },
                              onFieldSubmitted: (value) {
                                tempProfileMessage = value;
                              },
                              maxLines: 4,
                              maxLength: 60,
                              onTapOutside: (event) {
                                FocusScope.of(context).unfocus();
                              },
                              style: TextStyleFamily.smallTitleTextStyle,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counter: SizedBox(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ));
    });
  }
}
