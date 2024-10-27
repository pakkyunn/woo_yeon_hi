import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/enums.dart';
import 'package:woo_yeon_hi/provider/schedule_provider.dart';
import 'package:woo_yeon_hi/screen/calendar/calendar_edit_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';
import 'package:woo_yeon_hi/style/text_style.dart';

class CalendarDetailScreen extends StatefulWidget {
  CalendarDetailScreen({super.key});

  @override
  State<CalendarDetailScreen> createState() => _CalendarDetailScreenState();
}

class _CalendarDetailScreenState extends State<CalendarDetailScreen> {
  // final Map<String, dynamic> _selectedSchedule = {}; // 일정 데이터를 담을 변수

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarScreenProvider>(builder: (context, provider, child) {
      return Scaffold(
      backgroundColor: ColorFamily.cream,
      appBar: AppBar(
        surfaceTintColor: ColorFamily.cream,
        backgroundColor: ColorFamily.cream,
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: const Text(
          "일정 상세",
          style: TextStyleFamily.appBarTitleLightTextStyle
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SvgPicture.asset("lib/assets/icons/arrow_back.svg"),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CalendarEditScreen()));
            },
            icon: SvgPicture.asset("lib/assets/icons/edit.svg"),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              splashFactory: NoSplash.splashFactory,
                                shape: CircleBorder(),
                                backgroundColor: ScheduleColorType.values.firstWhere((e) => e.typeIdx == provider.selectedDaySchedule['schedule_color']).colorCode, // 선택된 색상
                            ),
                            onPressed: () {},
                            child: Icon(null)
                        ),
                        Expanded(
                          child: Text(
                            provider.selectedDaySchedule['schedule_title'],
                            style: TextStyleFamily.appBarTitleBoldTextStyle,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 일정 날짜
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              provider.selectedDaySchedule['schedule_start_date'] == provider.selectedDaySchedule['schedule_finish_date']
                                ? "${provider.selectedDaySchedule['schedule_start_date']}"
                                : "${provider.selectedDaySchedule['schedule_start_date']} ~ ${provider.selectedDaySchedule['schedule_finish_date']}",
                              style: const TextStyle(fontFamily: FontFamily.mapleStoryLight, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                // 일정 시각
                                // 하루종일 일정인 경우
                                provider.selectedDaySchedule['schedule_start_time']=="00:00" && provider.selectedDaySchedule['schedule_finish_time']=="23:59"
                                    ? const Text("하루 종일", style: TextStyleFamily.normalTextStyle)
                                    : Text(
                                      "${provider.selectedDaySchedule['schedule_start_time']} - ${provider.selectedDaySchedule['schedule_finish_time']}",
                                      style: TextStyleFamily.normalTextStyle),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Card(
                            color: ColorFamily.white,
                            surfaceTintColor: ColorFamily.white,
                            elevation: 1,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: 320, // 위젯의 최소 크기
                                maxHeight: double.infinity  // 최대 크기에 맞춰 늘어나도록
                              ),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: ColorFamily.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      provider.selectedDaySchedule['schedule_memo'],
                                      style: TextStyleFamily.normalTextStyle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      )
    );});
  }
}
