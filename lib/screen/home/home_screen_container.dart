import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:woo_yeon_hi/screen/home/home_screen_set1.dart';
import 'package:woo_yeon_hi/screen/home/home_screen_set2.dart';
import 'package:woo_yeon_hi/screen/home/home_screen_set3.dart';
import 'package:woo_yeon_hi/screen/home/home_screen_set4.dart';

import '../../dao/user_dao.dart';
import '../../provider/login_register_provider.dart';
import '../../style/color.dart';
import '../../style/font.dart';
import '../../style/text_style.dart';
import '../../utils.dart';
import '../calendar/calendar_screen.dart';
import '../dDay/dDay_screen.dart';

class HomeScreenContainer extends StatefulWidget {
  const HomeScreenContainer({super.key});

  @override
  State<HomeScreenContainer> createState() => _HomeScreenContainerState();
}

class _HomeScreenContainerState extends State<HomeScreenContainer> {
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

Widget dDay(BuildContext context) {
  var deviceWidth = MediaQuery.of(context).size.width;
  var deviceHeight = MediaQuery.of(context).size.height;

  return Consumer<UserProvider>(builder: (context, provider, child) {
    return _cardContainer(
      Row(
        children: [
          const Text("디데이",
              style: TextStyle(
                  color: ColorFamily.black,
                  fontSize: 20,
                  fontFamily: FontFamily.mapleStoryLight)),
          SizedBox(
            width: 40,
            height: 40,
            child: FittedBox(
              child: IconButton(
                icon: SvgPicture.asset('lib/assets/icons/expand.svg'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const dDayScreen()));
                },
              ),
            ),
          )
        ],
      ),
      Row(
        children: [
          SizedBox(
            width: deviceWidth*0.38,
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
                                image: provider.userProfileImage.image, // Image 객체의 image 속성을 사용
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
            width: deviceWidth*0.14,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('lib/assets/icons/like.svg'),
                const SizedBox(height: 5),
                Text(
                  '${DateTime.now().difference(stringToDate(provider.loveDday)).inDays + 1}일',
                  style: const TextStyle(fontFamily: FontFamily.mapleStoryLight),
                ),
              ],
            ),
          ),
          SizedBox(
            width: deviceWidth*0.38,
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
                                    image: provider.loverProfileImage.image, // Image 객체의 image 속성을 사용
                                    fit: BoxFit.cover) // 이미지를 원 안에 꽉 차게 함
                            )))),
                // ClipOval(child: Image.asset('lib/assets/images/test_wooyeon_women.jpg', width: 75, height: 75)),
                const SizedBox(height: 5),
                Text(provider.loverNickname,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontFamily: FontFamily.mapleStoryLight)),
              ],
            ),
          ),
        ],
      ),
      deviceWidth*0.95, deviceHeight*0.15
    );
  });
}

Widget datePlan(BuildContext context) {
  var deviceWidth = MediaQuery.of(context).size.width;
  var deviceHeight = MediaQuery.of(context).size.height;

  final controller = PageController(viewportFraction: 1, keepPage: true);
  final pages = List.generate(4, (index) => const Column(
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
    const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                return pages[index % pages.length];
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
      deviceWidth*0.95, deviceHeight*0.15
  );
}

Widget accountBook(BuildContext context) {
  var deviceWidth = MediaQuery.of(context).size.width;
  var deviceHeight = MediaQuery.of(context).size.height;

  return _cardContainer(
    const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("가계부",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: FontFamily.mapleStoryLight)),
      ],
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ClipRRect(
          child: Material(
            child: IconButton(
              onPressed: () {},
              icon: SvgPicture.asset('lib/assets/icons/arrow_left.svg'),
            ),
          ),
        ),
        const Text("10월",
            style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: FontFamily.mapleStoryLight)),
        ClipRRect(
          child: Material(
            child: IconButton(
              onPressed: () {},
              icon: SvgPicture.asset('lib/assets/icons/arrow_right.svg'),
            ),
          ),
        ),
        Container(width: 2, height: 70, color: ColorFamily.pink),
        const Text("526,300원 소비",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: FontFamily.mapleStoryLight))
      ],
    ),
      deviceWidth*0.95, deviceHeight*0.15
  );
}

Widget calendar(BuildContext context) {
  var deviceWidth = MediaQuery.of(context).size.width;
  var deviceHeight = MediaQuery.of(context).size.height;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final kToday = DateTime.now();
  final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
  final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

  return _cardContainer(
      Row(
        children: [
          const Text("캘린더",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: FontFamily.mapleStoryLight)),
          SizedBox(
            width: 40, // 원하는 너비
            height: 40, // 원하는 높이
            child: FittedBox(
              child: IconButton(
                icon: SvgPicture.asset('lib/assets/icons/expand.svg'),
                onPressed: () {
                  // 버튼이 눌렸을 때의 액션
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CalendarScreen()));
                },
              ),
            ),
          )
        ],
      ),
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TableCalendar(
              locale: 'ko_KR',
              headerStyle: const HeaderStyle(
                titleCentered: true,
                titleTextStyle: TextStyleFamily.appBarTitleBoldTextStyle,
                formatButtonVisible: false,
              ),
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  // setState(() {
                  //   _selectedDay = selectedDay;
                  //   _focusedDay = focusedDay;
                  // });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  // setState(() {
                  //   _calendarFormat = format;
                  // });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            const SizedBox(height: 10),
            Container(
              height: 50,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: ColorFamily.beige,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("11:50 AM",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: FontFamily.mapleStoryLight)),
                  Text("우연녀와 점심 데이트",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: FontFamily.mapleStoryLight)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 50,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: ColorFamily.beige,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("13:00 PM",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: FontFamily.mapleStoryLight)),
                  Text("우연녀와 보드카페",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: FontFamily.mapleStoryLight)),
                ],
              ),
            ),
          ],
        ),
      ),
      null, null);
}

Widget _cardContainer(Widget title, Widget child, double? width, double? height) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      title,
      const SizedBox(height: 8),
      Container(
        width: 320,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: child,
      )
    ],
  );
}
