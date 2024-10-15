import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/d_day_dao.dart';
import 'package:woo_yeon_hi/dao/user_dao.dart';
import 'package:woo_yeon_hi/dialogs.dart';
import 'package:woo_yeon_hi/provider/login_register_provider.dart';
import 'package:woo_yeon_hi/screen/footPrint/footprint_history_detail_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/text_style.dart';

import '../../model/dDay_model.dart';
import '../../provider/dDay_provider.dart';
import '../../style/font.dart';
import '../../utils.dart';

class DdayListView extends StatefulWidget {
  const DdayListView({super.key});

  @override
  State<DdayListView> createState() => _DdayListViewState();
}

class _DdayListViewState extends State<DdayListView> {
  // List<DdayModel> tempDdayList = [
  //   DdayModel(user_idx: 1, dDay_idx: 0, title: "연애 시작", description: "오래오래 가자", date: "24. 3. 1.(일)"),
  //   DdayModel(user_idx: 1, dDay_idx: 0, title: "생일", description: "우연녀 생일", date: "24. 8. 25.(일)"),
  //   DdayModel(user_idx: 1, dDay_idx: 0, title: "200일", description: "만난지 200일 ♥️", date: "24. 8. 25.(일)")
  // ];
  String? loverBirth;

  @override
  void initState() {
    super.initState();
    _getDdayData();
    _getLoverBirthday();
  }

  Future<void> _getDdayData() async {
    // 디데이 데이터 가져오기
    var dDayProvider = Provider.of<DdayProvider>(context, listen: false);
    var dDayList = await getDdayList(context);
    dDayProvider.setDdayList(dDayList);
  }

  Future<void> _getLoverBirthday() async {
    // 연인의 생일 정보 가져오기
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    loverBirth = await getSpecificUserData(userProvider.loverIdx, "user_birth");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return loverBirth == null
        ? const Center(
            child: CircularProgressIndicator(
            color: ColorFamily.pink,
          ))
        : Consumer2<DdayProvider, UserProvider>(
            builder: (context, dDayProvider, userProvider, child) {
            print("디데이리스트: ${dDayProvider.dDayList}");
            return Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.fromLTRB(20, 10, 20, 0),
                            child: Column(
                              children: [
                                // title, count
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("연애 시작", style: dDayTitleTextStyle),
                                    Text(
                                        countingOneOffDday(stringToDate(
                                            userProvider.loveDday)),
                                        style: dDayCountTextStyle)
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // content, date
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("우리가 만난 날",
                                        style: dDayContentTextStyle),
                                    Text(
                                        dateToStringWithDayLight(stringToDate(
                                            userProvider.loveDday)),
                                        style: dDayDateTextStyle)
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: ColorFamily.gray),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.fromLTRB(20, 10, 20, 0),
                            child: Column(
                              children: [
                                // title, count
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("내 생일", style: dDayTitleTextStyle),
                                    Text(
                                        countingAnnualDday(stringToDate(
                                            userProvider.userBirth)),
                                        style: dDayCountTextStyle)
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // content, date
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("", style: dDayContentTextStyle),
                                    Text(
                                        makeBirthToDday(
                                            userProvider.userBirth),
                                        style: dDayDateTextStyle)
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: ColorFamily.gray),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.fromLTRB(20, 10, 20, 0),
                            child: Column(
                              children: [
                                // title, count
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("연인 생일", style: dDayTitleTextStyle),
                                    Text(
                                        countingAnnualDday(
                                            stringToDate(loverBirth!)),
                                        style: dDayCountTextStyle)
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // content, date
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("", style: dDayContentTextStyle),
                                    Text(makeBirthToDday(loverBirth!),
                                        style: dDayDateTextStyle)
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: ColorFamily.gray),
                          const SizedBox(height: 2.5),
                        ],
                      ),
                      Column(
                        children: List.generate(dDayProvider.dDayList.length,
                            (index) {
                          return Dismissible(
                              key: Key(
                                  "${dDayProvider.dDayList[index]["dDay_idx"]}"),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                final result = await showDialog(
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
                                                const Text(
                                                  "디데이를 삭제하시겠습니까?",
                                                  style: TextStyleFamily.dialogButtonTextStyle,
                                                ),
                                                const SizedBox(height: 30),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    TextButton(
                                                      style: TextButton.styleFrom(
                                                        overlayColor: Colors.transparent,
                                                      ),
                                                      onPressed: () => Navigator.of(context).pop(false),
                                                      child: const Text(
                                                        "취소",
                                                        style: TextStyleFamily.dialogButtonTextStyle,
                                                      ),
                                                    ),
                                                    TextButton(
                                                      style: TextButton.styleFrom(
                                                        overlayColor: Colors.transparent,
                                                      ),
                                                      onPressed: () => Navigator.of(context).pop(true),
                                                      child: const Text(
                                                        "확인",
                                                        style: TextStyleFamily.dialogButtonTextStyle_pink,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                                return result; // true일 경우 삭제, false일 경우 삭제 안 함
                              },
                              onDismissed: (direction) async {
                                await deleteDday(context, dDayProvider.dDayList[index]["dDay_idx"]);
                                showPinkSnackBar(context, "디데이 항목이 삭제되었습니다");
                              },
                              child: _makeDdayItem(index));
                        }),
                      )
                    ],
                  ),
                )); // 항목들을 나열
          });
  }

  Widget _makeDdayItem(int index) {
    var provider = Provider.of<DdayProvider>(context, listen: false);
    return Column(
      children: [
        Wrap(
          children: [
            Card(
              elevation: 1.0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(
                  children: [
                    // title, count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          provider.dDayList[index]["dDay_title"],
                          style: dDayTitleTextStyle,
                        ),
                        Text(
                          countingOneOffDday(stringToDate(
                              provider.dDayList[index]["dDay_date"])),
                          style: dDayCountTextStyle,
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    // content, date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          provider.dDayList[index]["dDay_description"],
                          style: dDayContentTextStyle,
                        ),
                        Text(
                          provider.dDayList[index]["dDay_date"],
                          style: dDayDateTextStyle,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}

String countingOneOffDday(DateTime date) {
  var today = DateTime(
      DateTime.now().year - 2000, DateTime.now().month, DateTime.now().day);
  var dDay = DateTime(date.year, date.month, date.day);

  // D+ 인 경우
  if (dDay.isBefore(today)) {
    return "D + ${(dDay.difference(today).inDays.abs())}";
  }

  // D-day 인 경우
  else if (dDay.isAtSameMomentAs(today)) {
    return "D - day";
  }

  // D- 인 경우
  else if (dDay.isAfter(today)) {
    return "D - ${(dDay.difference(today).inDays).abs()}";
  } else {
    return "디데이 정보 없음";
  }
}

String countingAnnualDday(DateTime date) {
  var now = DateTime.now();
  DateTime currentYearDate = DateTime(now.year, date.month, date.day);
  DateTime nextYearDate = DateTime(now.year + 1, date.month, date.day);

  //올해 아직 지나지 않은 날짜인 경우
  if (currentYearDate.isAfter(DateTime(now.year, now.month, now.day))) {
    return "D - ${(currentYearDate.difference(now).inDays).abs()}";
  }

  //올해 이미 지난 날짜인 경우
  else if (currentYearDate.isBefore(DateTime(now.year, now.month, now.day))) {
    return "D - ${(nextYearDate.difference(now).inDays).abs()}";
  }

  //오늘이 디데이인 경우
  else if (currentYearDate
      .isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
    return "D - day";
  } else {
    return "디데이 정보 없음";
  }
}

String makeBirthToDday(String birthString) {
  var birthDate = stringToDate(birthString);
  String dDayFormattedBirth = DateFormat('M. d.(E)', 'ko_KR').format(birthDate);

  return dDayFormattedBirth;
}

TextStyle dDayTitleTextStyle = const TextStyle(
    fontFamily: FontFamily.mapleStoryLight,
    fontSize: 20,
    color: ColorFamily.black);

TextStyle dDayContentTextStyle = const TextStyle(
    fontFamily: FontFamily.mapleStoryLight,
    fontSize: 14,
    color: ColorFamily.gray);

TextStyle dDayCountTextStyle = const TextStyle(
    fontFamily: FontFamily.mapleStoryBold,
    fontSize: 20,
    color: ColorFamily.pink);
TextStyle dDayDateTextStyle = const TextStyle(
    fontFamily: FontFamily.mapleStoryLight,
    fontSize: 14,
    color: ColorFamily.gray);
