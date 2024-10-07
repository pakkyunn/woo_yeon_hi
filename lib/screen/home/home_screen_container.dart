import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
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

class HomeScreenContainer extends StatefulWidget {
  const HomeScreenContainer({super.key});

  @override
  State<HomeScreenContainer> createState() => _HomeScreenContainerState();
}

class _HomeScreenContainerState extends State<HomeScreenContainer> {
  @override
  void initState() {
    super.initState();
    getFutureScheduleList();
  }

  Future<void> getFutureScheduleList() async {
    var scheduleList = await getScheduleList(context);
    Provider.of<HomeCalendarProvider>(context, listen: false)
        .setScheduleList(scheduleList);
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

//디데이
Widget dDay(BuildContext context) {
  var deviceWidth = MediaQuery.of(context).size.width;
  var deviceHeight = MediaQuery.of(context).size.height;

  return Consumer<UserProvider>(builder: (context, provider, child) {
    return _cardContainer(
        context,
        Row(
          children: [
            const Text("디데이",
                style: TextStyle(
                    color: ColorFamily.black,
                    fontSize: 20,
                    fontFamily: FontFamily.mapleStoryLight)),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const dDayScreen()));
              },
              splashColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              child: SvgPicture.asset('lib/assets/icons/expand.svg'),
            )
          ],
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
                    '${DateTime.now().difference(stringToDate(provider.loveDday)).inDays + 1}일',
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
                            ? null
                            : showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: SizedBox(
                                        width: deviceWidth * 0.8,
                                        height: deviceHeight * 0.6,
                                        child: provider.loverProfileImage),
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
                  // ClipOval(child: Image.asset('lib/assets/images/test_wooyeon_women.jpg', width: 75, height: 75)),
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
                            color: Colors.black,
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
  var ledgerProvider = Provider.of<LedgerProvider>(context, listen: false);

  var deviceWidth = MediaQuery.of(context).size.width;
  var deviceHeight = MediaQuery.of(context).size.height;

  Future<bool> _asyncData(LedgerProvider provider) async {
    await provider.getMonthExpenditureSum();

    return true;
  }

  return FutureBuilder(
    future: _asyncData(ledgerProvider),
    builder: (context, snapshot) {
      if (snapshot.hasData == false) {
        return const Center(
          child: CircularProgressIndicator(
            color: ColorFamily.pink,
          ),
        );
      } else if (snapshot.hasError) {
        return const Text(
          "오류 발생",
          style: TextStyleFamily.normalTextStyle,
        );
      } else {
        return _cardContainer(
            context,
            const Row(
              children: [
                Text("가계부",
                    style: TextStyle(
                        color: Colors.black,
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
                        height: 40,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                                "${ledgerProvider.monthExpenditureTargetDateTime.year}",
                                style: TextStyleFamily.normalTextStyle),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              ledgerProvider.updatePreviousMonth();
                            },
                            icon: SvgPicture.asset(
                                'lib/assets/icons/arrow_left.svg'),
                          ),
                          Text(
                              "${ledgerProvider.monthExpenditureTargetDateTime.month}월",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontFamily: FontFamily.mapleStoryLight)),
                          IconButton(
                            onPressed: () {
                              ledgerProvider.updateNextMonth();
                            },
                            icon: SvgPicture.asset(
                                'lib/assets/icons/arrow_right.svg'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
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
                            ledgerProvider.monthExpenditureSum,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: FontFamily.mapleStoryLight),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const Text(
                          "원 소비",
                          style: TextStyle(
                              color: Colors.black,
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
      }
    },
  );
}

//데이트플랜
Widget datePlan(BuildContext context) {
  var deviceHeight = MediaQuery.of(context).size.height;

  Future<bool> _asyncData(FootPrintSlidableProvider provider) async {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Plan> result = await getPlanData(userProvider.userIdx);
    provider.addPlanList(result);
    return true;
  }

  var datePlanProvider =
      Provider.of<FootPrintSlidableProvider>(context, listen: false);
  final controller = PageController(viewportFraction: 1, keepPage: true);

  final pages = List.generate(
      4,
      (index) => const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("제주도 여행",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: FontFamily.mapleStoryLight)),
              Text("2024.6.13(수) - 2024.6.17(월)",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: FontFamily.mapleStoryLight)),
              Text("2024.5.17 작성 by 우연녀",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontFamily: FontFamily.mapleStoryLight)),
            ],
          ));

  return _cardContainer(
      context,
      const Row(
        children: [
          Text("데이트 플랜",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: FontFamily.mapleStoryLight)),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                itemBuilder: (_, index) {
                  return FutureBuilder(
                    future: _asyncData(datePlanProvider),
                    builder: (context, snapshot) {
                      if (snapshot.hasData == false) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: ColorFamily.pink,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Text(
                          "오류 발생",
                          style: TextStyleFamily.normalTextStyle,
                        );
                      } else {
                        return pages[index % pages.length];
                      }
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: ColorFamily.beige,
              ),
              child: SmoothPageIndicator(
                controller: controller,
                count: pages.length,
                effect: const ScrollingDotsEffect(
                  dotHeight: 11,
                  dotWidth: 11,
                  activeDotColor: ColorFamily.pink,
                  dotColor: ColorFamily.white,
                ),
              ),
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
      deviceHeight * 0.15);
}

//캘린더_달력
Widget calendar(BuildContext context) {
  DateTime _focusedDay = Provider.of<HomeCalendarProvider>(context).focusedDay;
  DateTime? _selectedDay =
      Provider.of<HomeCalendarProvider>(context).selectedDay;

  // CalendarFormat _calendarFormat = CalendarFormat.month;

  return Consumer<HomeCalendarProvider>(builder: (context, provider, child) {
    return _cardContainer(
        context,
        Row(
          children: [
            const Text("캘린더",
                style: TextStyle(
                    color: ColorFamily.black,
                    fontSize: 20,
                    fontFamily: FontFamily.mapleStoryLight)),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CalendarScreen()));
              },
              splashColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              child: SvgPicture.asset('lib/assets/icons/expand.svg'),
            )
          ],
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
                  rowHeight: 45,
                  daysOfWeekHeight: 40,
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
                  },
                ),
                const SizedBox(height: 20),
                calendarFutureBuilderWidget(context, provider.selectedDay)
              ]))
        ]),
        null);
  });
}

//캘린더_일정
Widget calendarFutureBuilderWidget(BuildContext context, DateTime selectedDay) {
  var provider = Provider.of<HomeCalendarProvider>(context, listen: false);
  var selectedDayScheduleList = provider.scheduleList[provider.listIndex];
  String selectedDayParse = dateToStringWithDay(selectedDay);

  return selectedDayScheduleList.isNotEmpty
      ? SizedBox(
          height: 110,
          child: ListView.builder(
              itemCount: selectedDayScheduleList.length,
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
                      selectedDayScheduleList[index]['schedule_start_date'] ==
                                  selectedDayParse &&
                              selectedDayScheduleList[index]
                                      ['schedule_finish_date'] ==
                                  selectedDayParse
                          ? SizedBox(
                              width: 140,
                              child: Row(
                                children: [
                                  const SizedBox(width: 20),
                                  Text(
                                      selectedDayScheduleList[index]
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
                                      selectedDayScheduleList[index]
                                          ['schedule_finish_time'],
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontFamily:
                                              FontFamily.mapleStoryLight)),
                                ],
                              ),
                            )
                          // 2-1. 여러날 일정 중 첫날인 경우
                          : selectedDayScheduleList[index]
                                          ['schedule_start_date'] ==
                                      selectedDayParse &&
                                  selectedDayScheduleList[index]
                                          ['schedule_finish_date'] !=
                                      selectedDayParse
                              ? SizedBox(
                                  width: 140,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 20),
                                      Text(
                                          selectedDayScheduleList[index]
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
                              : selectedDayScheduleList[index]
                                              ['schedule_start_date'] !=
                                          selectedDayParse &&
                                      selectedDayScheduleList[index]
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
                                              selectedDayScheduleList[index]
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
                                selectedDayScheduleList[index]
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
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: SizedBox(
              child: child,
            )),
      ),
    ],
  );
}
