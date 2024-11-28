import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:woo_yeon_hi/dao/schedule_dao.dart';
import 'package:woo_yeon_hi/provider/ledger_provider.dart';
import 'package:woo_yeon_hi/screen/home/home_screen_set1.dart';
import 'package:woo_yeon_hi/screen/home/home_screen_set2.dart';
import 'package:woo_yeon_hi/screen/home/home_screen_set3.dart';
import 'package:woo_yeon_hi/screen/home/home_screen_set4.dart';

import '../../dao/plan_dao.dart';
import '../../dao/user_dao.dart';
import '../../model/plan_model.dart';
import '../../provider/footprint_provider.dart';
import '../../provider/login_register_provider.dart';
import '../../provider/schedule_provider.dart';
import '../../style/color.dart';
import '../../style/font.dart';
import '../../style/text_style.dart';
import '../../utils.dart';
import '../../widget/diary/diary_calendar_bottom_sheet.dart';
import '../../widget/home/lover_nickname_edit_dialog.dart';
import '../calendar/calendar_screen.dart';
import '../dDay/dDay_screen.dart';
import '../footPrint/footprint_date_plan_edit_screen.dart';

class HomeScreenContainer extends StatefulWidget {
  const HomeScreenContainer({super.key});

  @override
  State<HomeScreenContainer> createState() => _HomeScreenContainerState();
}

class _HomeScreenContainerState extends State<HomeScreenContainer> {
  @override
  void initState() {
    super.initState();
    // _getDatePlanData();
    _getLedgerData();
    _getScheduleData();
  }

  // Future<void> _getDatePlanData() async {
  //   // 데이트플랜 데이터 가져오기
  //   var homeDatePlanProvider =
  //       Provider.of<HomeDatePlanProvider>(context, listen: false);
  //   var datePlanList = await getHomePlanList(context);
  //   homeDatePlanProvider.setDatePlanList(datePlanList);
  // }

  Future<void> _getLedgerData() async {
    // 캘린더 데이터 가져오기
    var ledgerProvider = Provider.of<LedgerProvider>(context, listen: false);
    await ledgerProvider.getMonthExpenditureSum();

  }

  Future<void> _getScheduleData() async {
    // 캘린더 데이터 가져오기
    var homeCalendarProvider = Provider.of<HomeCalendarProvider>(context, listen: false);
    var scheduleList = await getHomeCalendarScheduleList(context);
    homeCalendarProvider.setScheduleList(scheduleList);
    homeCalendarProvider.setListIndex();
    homeCalendarProvider.setSelectedDayScheduleList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, provider, child) {
      return provider.homePresetType == 0
          ? const HomeScreenSet1()
          : provider.homePresetType == 1
              ? const HomeScreenSet2()
              : provider.homePresetType == 2
                  ? const HomeScreenSet3()
                  : const HomeScreenSet4();
    });
  }
}

//추억 배너
Widget memoryBanner(BuildContext context) {
  var deviceWidth = MediaQuery.of(context).size.width;
  var deviceHeight = MediaQuery.of(context).size.height;

  return Consumer<UserProvider>(builder: (context, provider, child) {
    return _cardContainer(
        context,
        SizedBox(),
        provider.memoryBannerImagePath == ""
            ? InkWell(
                splashColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                onTap: () async {
                  final ImagePicker picker = ImagePicker(); //ImagePicker 초기화
                  final XFile? pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    provider.setImage(XFile(pickedFile.path));
                    provider.setMemoryBannerImage(
                        Image.file(File(pickedFile.path), fit: BoxFit.cover));
                    var imageName =
                        "${provider.userIdx}_memory_banner_${DateTime.now()}";
                    provider.setMemoryBannerImagePath(imageName);
                    updateSpecificUserData(provider.userIdx,
                        "memory_banner_image", provider.memoryBannerImagePath);
                    updateSpecificUserData(provider.loverIdx,
                        "memory_banner_image", provider.memoryBannerImagePath);
                    uploadMemoryBannerImage(provider.image!, imageName);
                  }
                },
                child: Container(
                    decoration: BoxDecoration(
                        // color: ColorFamily.white,
                        borderRadius: BorderRadius.circular(15),
                        image: null),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                              'lib/assets/icons/memory_banner_icon.svg',
                              width: 40,
                              height: 40),
                        ],
                      ),
                    )),
              )
            : InkWell(
                splashColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      backgroundColor: ColorFamily.white,
                      builder: (context) {
                        return Consumer<UserProvider>(builder: (context, provider, child) {
                          return Wrap(
                            children: [
                              Column(
                                children: [
                                  InkWell(
                                    splashColor: ColorFamily.gray.withOpacity(0.5),
                                    onTap: () async {
                                      final ImagePicker picker = ImagePicker(); //ImagePicker 초기화
                                      final XFile? pickedFile =
                                          await picker.pickImage(source: ImageSource.gallery);
                                      if (pickedFile != null) {
                                        deleteMemoryBannerImage(provider.memoryBannerImagePath);
                                        provider.setImage(XFile(pickedFile.path));
                                        provider.setMemoryBannerImage(
                                            Image.file(File(pickedFile.path), fit: BoxFit.cover));
                                        var imageName =
                                            "${provider.userIdx}_memory_banner_${DateTime.now()}";
                                        provider.setMemoryBannerImagePath(imageName);
                                        updateSpecificUserData(provider.userIdx,
                                            "memory_banner_image", provider.memoryBannerImagePath);
                                        updateSpecificUserData(provider.loverIdx,
                                            "memory_banner_image", provider.memoryBannerImagePath);
                                        uploadMemoryBannerImage(provider.image!, imageName);
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 30),
                                      height: 70,
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SvgPicture.asset(
                                            'lib/assets/icons/gallery.svg',
                                            height: 20,
                                          ),
                                          const Text(
                                            "사진 변경",
                                            style: TextStyleFamily.smallTitleTextStyle,
                                          ),
                                          const SizedBox(
                                            width: 24,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 0.5,
                                    child: Divider(
                                      color: ColorFamily.gray,
                                      thickness: 0.5,
                                    ),
                                  ),
                                  InkWell(
                                    splashColor: ColorFamily.gray.withOpacity(0.5),
                                    onTap: () {
                                      deleteMemoryBannerImage(provider.memoryBannerImagePath);
                                      provider.setMemoryBannerImagePath("");
                                      updateSpecificUserData(provider.userIdx,
                                          "memory_banner_image", provider.memoryBannerImagePath);
                                      updateSpecificUserData(provider.loverIdx,
                                          "memory_banner_image", provider.memoryBannerImagePath);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 30),
                                      height: 70,
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SvgPicture.asset('lib/assets/icons/delete_pink.svg',
                                              height: 20),
                                          const Text(
                                            "사진 삭제",
                                            style: TextStyle(fontFamily: FontFamily.mapleStoryLight, fontSize: 15, color: ColorFamily.pink),
                                          ),
                                          const SizedBox(
                                            width: 24,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        });
                      });
                },
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                            image: provider.memoryBannerImage.image,
                            fit: BoxFit.cover))),
              ),
        // FutureBuilder(
        //     future: provider.fetchMemoryBannerImage(provider.memoryBannerImagePath),
        //     builder: (context, snapshot) {
        //       if (snapshot.hasData == false) {
        //         return const Center(
        //           child: CircularProgressIndicator(
        //             color: ColorFamily.pink,
        //           ),
        //         );
        //       } else if (snapshot.hasError) {
        //         return const Text(
        //           "오류 발생",
        //           style: TextStyleFamily.normalTextStyle,
        //         );
        //       } else {
        //         return provider.memoryBannerImagePath == ""
        //             ? InkWell(
        //                 splashColor: Colors.transparent,
        //                 splashFactory: NoSplash.splashFactory,
        //                 onTap: () async {
        //                   // TODO 바로 사진첩 띄워도 괜찮을듯?
        //                   final ImagePicker picker =
        //                       ImagePicker(); //ImagePicker 초기화
        //                   final XFile? pickedFile = await picker.pickImage(
        //                       source: ImageSource.gallery);
        //                   if (pickedFile != null) {
        //                     provider.setImage(XFile(pickedFile.path));
        //                     provider.setMemoryBannerImage(Image.file(File(pickedFile.path), fit: BoxFit.cover));
        //                     provider.setMemoryBannerImagePath(pickedFile.path);
        //                     updateSpecificUserData(provider.userIdx, "memory_banner_image", provider.memoryBannerImagePath);
        //                     var imageName = "${provider.userIdx}_memory_banner_${DateTime.now()}";
        //                     uploadMemoryBannerImage(provider.image!, imageName);
        //                   }
        //                 },
        //                 child: Container(
        //                     decoration: BoxDecoration(
        //                         // color: ColorFamily.white,
        //                         borderRadius: BorderRadius.circular(15),
        //                         image: null),
        //                     child: Center(
        //                       child: Row(
        //                         mainAxisAlignment: MainAxisAlignment.center,
        //                         children: [
        //                           SvgPicture.asset(
        //                               'lib/assets/icons/memory_banner_icon.svg',
        //                               width: 40,
        //                               height: 40),
        //                         ],
        //                       ),
        //                     )),
        //               )
        //             : InkWell(
        //                 splashColor: Colors.transparent,
        //                 splashFactory: NoSplash.splashFactory,
        //                 onTap: () {
        //                   //TODO 다이얼로그/바텀시트 띄우면서 이미지삭제, 변경 기능 추가
        //                 },
        //                 child: Container(
        //                     decoration: BoxDecoration(
        //                         borderRadius: BorderRadius.circular(15),
        //                         image: DecorationImage(
        //                             image: provider.memoryBannerImage.image,
        //                             fit: BoxFit.cover))),
        //               );
        //       }
        //     }),
        deviceHeight * 0.15);
  });
}

//디데이
Widget dDay(BuildContext context) {
  var deviceWidth = MediaQuery.of(context).size.width;
  var deviceHeight = MediaQuery.of(context).size.height;

  return Consumer<UserProvider>(builder: (context, provider, child) {
    return _cardContainer(
        context,
        InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const dDayScreen()));
          },
          splashColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          child: Row(
            children: [
              const Text("디데이",
                  style: TextStyle(
                      color: ColorFamily.black,
                      fontSize: 20,
                      fontFamily: FontFamily.mapleStoryLight)),
              SvgPicture.asset('lib/assets/icons/expand.svg'),
            ],
          ),
        ),
        Row(
          children: [
            SizedBox(
              width: deviceWidth * 0.38,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                      onTap: () {
                        provider.userProfileImagePath ==
                                "lib/assets/images/default_profile.png"
                            ? showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Center(
                                    child: Material(
                                      color: Colors.transparent, // 기본 배경 제거
                                      child: Container(
                                        width: deviceWidth * 0.8,
                                        height: deviceHeight * 0.5,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(30), // 모든 모서리를 둥글게
                                        ),
                                        child: Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // 상단 모서리 둥글게
                                              child: Image(
                                                  image: AssetImage(
                                                      "lib/assets/images/default_profile.png")), // 이미지나 위젯을 둥글게 클립
                                            ),
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)), // 하단 모서리 둥글게
                                                child: Container(
                                                  color: ColorFamily.white,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Expanded(
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(15),
                                                              child: Text(
                                                                "테스트상태메시지테 \n테스트상태메시지테 \n테스트상태메시지테 \n테스트상태메시지테",
                                                                style: TextStyleFamily.normalTextStyle,
                                                                overflow: TextOverflow.clip,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                })
                        : showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Center(
                              child: Material(
                                color: Colors.transparent, // 기본 배경 제거
                                child: Container(
                                  width: deviceWidth * 0.8,
                                  height: deviceHeight * 0.5,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30), // 모든 모서리를 둥글게
                                  ),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // 상단 모서리 둥글게
                                        child: provider.userProfileImage, // 이미지나 위젯을 둥글게 클립
                                      ),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)), // 하단 모서리 둥글게
                                          child: Container(
                                            color: ColorFamily.white,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(15),
                                                        child: Text(
                                                          "테스트상태메시지테 스테스트상태메시지테스테스트상 태메시지테스테스트상태 메시지테스테스 트상태메시지테스 테스트상태메시지테스",
                                                          style: TextStyleFamily.normalTextStyle,
                                                          overflow: TextOverflow.clip,
                                                          softWrap: true,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                              width: deviceWidth * 0.20,
                              height: deviceWidth * 0.20,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: provider.userProfileImage.image,
                                      // Image 객체의 image 속성을 사용
                                      fit: BoxFit.cover) // 이미지를 원 안에 꽉 차게 함
                                  )))),
                  const SizedBox(height: 5),
                  Text(provider.userNickname,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14,
                          color: ColorFamily.black,
                          fontFamily: FontFamily.mapleStoryLight)),
                ],
              ),
            ),
            SizedBox(
              width: deviceWidth * 0.14,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('lib/assets/icons/like.svg'),
                  const SizedBox(height: 5),
                  Text(
                    '${DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).difference(stringToDateLight(provider.loveDday)).inDays}일',
                    style:
                        const TextStyle(fontFamily: FontFamily.mapleStoryLight),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: deviceWidth * 0.38,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                      onTap: () {
                        provider.loverProfileImagePath ==
                                "lib/assets/images/default_profile.png"
                            ? showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Center(
                                    child: Material(
                                      color: Colors.transparent, // 기본 배경 제거
                                      child: Container(
                                        width: deviceWidth * 0.8,
                                        height: deviceHeight * 0.5,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(30), // 모든 모서리를 둥글게
                                        ),
                                        child: Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // 상단 모서리 둥글게
                                              child: Image(
                                                  image: AssetImage(
                                                      "lib/assets/images/default_profile.png")), // 이미지나 위젯을 둥글게 클립
                                            ),
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)), // 하단 모서리 둥글게
                                                child: Container(
                                                  color: ColorFamily.white,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Expanded(
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(15),
                                                              child: Text(
                                                                "테스트상태메시지테 \n테스트상태메시지테 \n테스트상태메시지테 \n테스트상태메시지테",
                                                                style: TextStyleFamily.normalTextStyle,
                                                                overflow: TextOverflow.clip,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                })
                            : showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Center(
                                    child: Material(
                                      color: Colors.transparent, // 기본 배경 제거
                                      child: Container(
                                        width: deviceWidth * 0.8,
                                        height: deviceHeight * 0.5,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(30), // 모든 모서리를 둥글게
                                        ),
                                        child: Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // 상단 모서리 둥글게
                                              child: provider.loverProfileImage, // 이미지나 위젯을 둥글게 클립
                                            ),
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)), // 하단 모서리 둥글게
                                                child: Container(
                                                  color: ColorFamily.white,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Expanded(
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(15),
                                                              child: Text(
                                                                "테스트상태메시지테 스테스트상태메시지테스테스트상 태메시지테스테스트상태 메시지테스테스 트상태메시지테스 테스트상태메시지테스",
                                                                style: TextStyleFamily.normalTextStyle,
                                                                overflow: TextOverflow.clip,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                      },
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                              width: deviceWidth * 0.20,
                              height: deviceWidth * 0.20,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: provider.loverProfileImage.image,
                                      // Image 객체의 image 속성을 사용
                                      fit: BoxFit.cover) // 이미지를 원 안에 꽉 차게 함
                                  )))),
                  const SizedBox(height: 5),
                  InkWell(
                    splashFactory: NoSplash.splashFactory,
                    splashColor: Colors.transparent,
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return LoverNicknameEditDialog();
                          });
                    },
                    child: Text(provider.loverNickname,
                        style: const TextStyle(
                            fontSize: 14,
                            color: ColorFamily.black,
                            fontFamily: FontFamily.mapleStoryLight)),
                  ),
                ],
              ),
            ),
          ],
        ),
        deviceHeight * 0.15);
  });
}

//가계부
Widget accountBook(BuildContext context) {
  // var ledgerProvider = Provider.of<LedgerProvider>(context, listen: false);

  var deviceWidth = MediaQuery.of(context).size.width;
  var deviceHeight = MediaQuery.of(context).size.height;

  // Future<bool> _asyncData(LedgerProvider provider) async {
  //   await provider.getMonthExpenditureSum();
  //
  //   return true;
  // }

  // return FutureBuilder(
  //   future: _asyncData(ledgerProvider),
  //   builder: (context, snapshot) {
  //     if (snapshot.hasData == false) {
  //       return const Center(
  //         child: CircularProgressIndicator(
  //           color: ColorFamily.pink,
  //         ),
  //       );
  //     } else if (snapshot.hasError) {
  //       return const Text(
  //         "오류 발생",
  //         style: TextStyleFamily.normalTextStyle,
  //       );
  //     } else {
  return Consumer<LedgerProvider>(builder: (context, provider, child) {
    return _cardContainer(
        context,
        const Row(
          children: [
            Text("가계부",
                style: TextStyle(
                    color: ColorFamily.black,
                    fontSize: 20,
                    fontFamily: FontFamily.mapleStoryLight)),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: deviceWidth * 0.38,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 35,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                            "${provider.monthExpenditureTargetDateTime.year}",
                            style: TextStyleFamily.normalTextStyle),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () async {
                          provider.updatePreviousMonth();
                          await provider.getMonthExpenditureSum();
                        },
                        icon: SvgPicture.asset(
                            'lib/assets/icons/arrow_left.svg'),
                      ),
                      Text(
                          "${provider.monthExpenditureTargetDateTime.month}월",
                          style: const TextStyle(
                              color: ColorFamily.black,
                              fontSize: 24,
                              fontFamily: FontFamily.mapleStoryLight)),
                      IconButton(
                        onPressed: () async {
                          provider.updateNextMonth();
                          await provider.getMonthExpenditureSum();
                        },
                        icon: SvgPicture.asset(
                            'lib/assets/icons/arrow_right.svg'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(width: 2, height: 70, color: ColorFamily.pink),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        provider.monthExpenditureSum,
                        style: const TextStyle(
                            color: ColorFamily.black,
                            fontSize: 20,
                            fontFamily: FontFamily.mapleStoryLight),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const Text(
                      "원 소비",
                      style: TextStyle(
                          color: ColorFamily.black,
                          fontSize: 20,
                          fontFamily: FontFamily.mapleStoryLight),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ]),
            ),
            const SizedBox(width: 20),
          ],
        ),
        deviceHeight * 0.15);
  });
      // }
    // },
  // );
}

//데이트플랜
// Widget datePlan(BuildContext context) {
//   var deviceHeight = MediaQuery.of(context).size.height;
//
//   var provider = Provider.of<HomeDatePlanProvider>(context, listen: false);
//   final controller = PageController(viewportFraction: 1, keepPage: true);
//
//   final pages = List.generate(provider.datePlanList.length, (index) => Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(provider.datePlanList[index]["plan_title"],
//                   style: const TextStyle(
//                     color: ColorFamily.black,
//                     fontSize: 15,
//                     fontFamily: FontFamily.mapleStoryBold
//                   )),
//               const SizedBox(height: 5),
//               Text(provider.datePlanList[index]["plan_date"],
//                   style: const TextStyle(
//                       color: ColorFamily.black,
//                       fontSize: 14,
//                       fontFamily: FontFamily.mapleStoryLight
//                   )),
//               const SizedBox(height: 10),
//               Text("${provider.datePlanList[index]["plan_user_nickname"]}의 플랜",
//                   textAlign: TextAlign.right,
//                   style: const TextStyle(
//                       color: ColorFamily.black,
//                       fontSize: 12,
//                       fontFamily: FontFamily.mapleStoryLight)),
//             ],
//           ));
//
//   return _cardContainer(
//       context,
//       const Row(
//         children: [
//           Text("데이트 플랜",
//               style: TextStyle(
//                   color: ColorFamily.black,
//                   fontSize: 20,
//                   fontFamily: FontFamily.mapleStoryLight)),
//         ],
//       ),
//       InkWell(
//         onTap: (){
//           Navigator.push(context, MaterialPageRoute(builder: (context) => const FootprintDatePlanEditScreen()));
//         },
//         child: Padding(
//           padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
//           child: Column(
//             children: <Widget>[
//               Expanded(
//                 child:
//                 provider.datePlanList.isNotEmpty
//                 ? PageView.builder(
//                   controller: controller,
//                   itemCount: provider.datePlanList.length,
//                   itemBuilder: (_, index) {
//                     return pages[index];
//                   },
//                 )
//                 : const Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text("데이트 플랜 없음", style: TextStyleFamily.normalTextStyle)
//                   ],
//                 )
//               ),
//               provider.datePlanList.isNotEmpty
//               ? Container(
//                 padding: const EdgeInsets.all(5),
//                 decoration: const BoxDecoration(
//                   borderRadius: BorderRadius.all(Radius.circular(15)),
//                   color: ColorFamily.beige,
//                 ),
//                 child: SmoothPageIndicator(
//                   controller: controller,
//                   count: provider.datePlanList.isNotEmpty ? provider.datePlanList.length : 1,
//                   effect: const ScrollingDotsEffect(
//                     dotHeight: 8,
//                     dotWidth: 8,
//                     activeDotColor: ColorFamily.pink,
//                     dotColor: ColorFamily.white,
//                   ),
//                 ),
//               )
//               : const SizedBox(),
//               const SizedBox(height: 5)
//             ],
//           ),
//         ),
//       ),
//       deviceHeight * 0.15);
// }

//캘린더_달력
Widget calendar(BuildContext context) {
  DateTime _focusedDay = Provider.of<HomeCalendarProvider>(context).focusedDay;
  DateTime? _selectedDay = Provider.of<HomeCalendarProvider>(context).selectedDay;

  // CalendarFormat _calendarFormat = CalendarFormat.month;

  return Consumer<HomeCalendarProvider>(builder: (context, provider, child) {
    return _cardContainer(
        context,
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CalendarScreen()));
          },
          splashColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          child: Row(
            children: [
              const Text("캘린더",
                  style: TextStyle(
                      color: ColorFamily.black,
                      fontSize: 20,
                      fontFamily: FontFamily.mapleStoryLight)),
              SvgPicture.asset('lib/assets/icons/expand.svg'),
            ],
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(children: [
                TableCalendar(
                  availableGestures: AvailableGestures.none,
                  firstDay:
                      DateTime(DateTime.now().year, DateTime.now().month, 1),
                  lastDay:
                      DateTime(DateTime.now().year, DateTime.now().month, 31),
                  focusedDay: _focusedDay,
                  locale: 'ko_kr',
                  rowHeight: MediaQuery.of(context).size.height*0.05,
                  daysOfWeekHeight: MediaQuery.of(context).size.height*0.055,
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    titleTextStyle: TextStyleFamily.appBarTitleBoldTextStyle,
                    formatButtonVisible: false,
                    leftChevronVisible: false,
                    rightChevronVisible: false,
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyleFamily.normalTextStyle,
                      weekendStyle: TextStyleFamily.normalTextStyle),
                  calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                    return Container(
                      alignment: Alignment.center,
                      child: Text(
                        textAlign: TextAlign.center,
                        DateFormat('d').format(day),
                        style: TextStyle(
                            color: isWeekend(day)
                                ? Colors.red
                                : isSaturday(day)
                                    ? Colors.blueAccent
                                    : ColorFamily.black,
                            fontFamily: FontFamily.mapleStoryLight),
                      ),
                    );
                  }, outsideBuilder: (context, day, focusedDay) {
                    return Container(
                      alignment: Alignment.center,
                      child: Text(
                        textAlign: TextAlign.center,
                        DateFormat('d').format(day),
                        style: const TextStyle(
                            color: ColorFamily.gray,
                            fontFamily: FontFamily.mapleStoryLight),
                      ),
                    );
                  }, disabledBuilder: (context, day, focusedDay) {
                    return Container(
                      alignment: Alignment.center,
                      child: Text(
                        textAlign: TextAlign.center,
                        DateFormat('d').format(day),
                        style: const TextStyle(
                            color: ColorFamily.gray,
                            fontFamily: FontFamily.mapleStoryLight),
                      ),
                    );
                  }, selectedBuilder: (context, day, focusedDay) {
                    return Container(
                      alignment: Alignment.center,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: ColorFamily.pink,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            DateFormat('d').format(day),
                            style: TextStyle(
                                color: isWeekend(day)
                                    ? ColorFamily.white
                                    : isSaturday(day)
                                        ? ColorFamily.white
                                        : ColorFamily.black,
                                fontFamily: FontFamily.mapleStoryLight),
                          ),
                        ),
                      ),
                    );
                  }, todayBuilder: (context, day, focusedDay) {
                    return Container(
                      alignment: Alignment.center,
                      child: Text(
                        textAlign: TextAlign.center,
                        DateFormat('d').format(day),
                        style: const TextStyle(
                            color: ColorFamily.pink,
                            fontFamily: FontFamily.mapleStoryLight),
                      ),
                    );
                  }, markerBuilder: (context, day, events) {
                    return FutureBuilder(
                        future: isExistOnSchedule(day, context),
                        builder: (context, snapshot) {
                          if (snapshot.hasData == false) {
                            return const SizedBox();
                          } else if (snapshot.hasError) {
                            return const SizedBox();
                          } else {
                            if (snapshot.data == true) {
                              return Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 30),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                      color: (day == _selectedDay)
                                          ? ColorFamily.white
                                          : ColorFamily.pink,
                                      shape: BoxShape.circle),
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          }
                        });
                  }),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    provider.setSelectedDay(selectedDay);
                    provider.setFocusedDay(focusedDay);
                    provider.setListIndex();
                    provider.setSelectedDayScheduleList();
                  },
                ),
                const SizedBox(height: 20),
                scheduleListWidget(context)
              ]))
        ]),
        null);
  });
}

//캘린더_일정
Widget scheduleListWidget(BuildContext context) {
  var provider = Provider.of<HomeCalendarProvider>(context, listen: false);
  String selectedDayParse = dateToStringWithDay(provider.selectedDay);

  return provider.selectedDayScheduleList.isNotEmpty
      ? SizedBox(
          height: 110,
          child: ListView.builder(
              itemCount: provider.selectedDayScheduleList.length,
              itemBuilder: (context, index) => Container(
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 5),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: ColorFamily.beige,
                  ),
                  child: Row(
                    children: [
                      // 1.하루일정인 경우
                      provider.selectedDayScheduleList[index]['schedule_start_date'] ==
                                  selectedDayParse &&
                              provider.selectedDayScheduleList[index]
                                      ['schedule_finish_date'] ==
                                  selectedDayParse
                          ? SizedBox(
                              width: 140,
                              child: Row(
                                children: [
                                  const SizedBox(width: 20),
                                  Text(
                                      provider.selectedDayScheduleList[index]
                                          ['schedule_start_time'],
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontFamily:
                                              FontFamily.mapleStoryLight)),
                                  const Text(" - ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontFamily:
                                              FontFamily.mapleStoryLight)),
                                  Text(
                                      provider.selectedDayScheduleList[index]
                                          ['schedule_finish_time'],
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontFamily:
                                              FontFamily.mapleStoryLight)),
                                ],
                              ),
                            )
                          // 2-1. 여러날 일정 중 첫날인 경우
                          : provider.selectedDayScheduleList[index]
                                          ['schedule_start_date'] ==
                                      selectedDayParse &&
                                  provider.selectedDayScheduleList[index]
                                          ['schedule_finish_date'] !=
                                      selectedDayParse
                              ? SizedBox(
                                  width: 140,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 20),
                                      Text(
                                          provider.selectedDayScheduleList[index]
                                              ['schedule_start_time'],
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontFamily:
                                                  FontFamily.mapleStoryLight)),
                                      const Text(" ~ ",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontFamily:
                                                  FontFamily.mapleStoryLight)),
                                    ],
                                  ),
                                )
                              // 2-2. 여러날 일정 중 중간날인 경우
                              : provider.selectedDayScheduleList[index]
                                              ['schedule_start_date'] !=
                                          selectedDayParse &&
                                      provider.selectedDayScheduleList[index]
                                              ['schedule_finish_date'] !=
                                          selectedDayParse
                                  ? const SizedBox(
                                      width: 140,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(" ~ ",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: FontFamily
                                                      .mapleStoryLight)),
                                        ],
                                      ),
                                    )
                                  // 2-3. 여러날 일정 중 마지막날인 경우
                                  // : selectedDayScheduleList[index]['schedule_start_date'] != selectedDayParse && selectedDayScheduleList[index]['schedule_finish_date'] == selectedDayParse
                                  : SizedBox(
                                      width: 140,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(" ~ ",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: FontFamily
                                                      .mapleStoryLight)),
                                          Text(
                                              provider.selectedDayScheduleList[index]
                                                  ['schedule_finish_time'],
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: FontFamily
                                                      .mapleStoryLight))
                                        ],
                                      ),
                                    ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                provider.selectedDayScheduleList[index]
                                    ['schedule_title'],
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: FontFamily.mapleStoryLight)),
                          ],
                        ),
                      )

                      // const Text("13:00 PM", style: TextStyle(fontSize: 16, fontFamily: FontFamily.mapleStoryLight)),
                      // const Text("우연녀와 보드카페", style: TextStyle(fontSize: 16, fontFamily: FontFamily.mapleStoryLight)),
                    ],
                  ))),
        )
      : Container(
          padding: const EdgeInsets.only(bottom: 20),
          height: 110,
          child: const Center(
            child: Text(
              "일정 없음",
              style: TextStyleFamily.normalTextStyle,
            ),
          ));
}

Widget _cardContainer(
    BuildContext context, Widget title, Widget child, double? height) {
  var deviceWidth = MediaQuery.of(context).size.width;

  return Column(
    // crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      title,
      const SizedBox(height: 5),
      SizedBox(
        width: deviceWidth * 0.95,
        height: height,
        child: Material(
            color: ColorFamily.white,
            elevation: 0.5,
            shadowColor: ColorFamily.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: SizedBox(
              child: child,
            )),
      ),
    ],
  );
}
