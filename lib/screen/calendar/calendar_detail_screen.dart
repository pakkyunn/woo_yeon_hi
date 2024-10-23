import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:woo_yeon_hi/screen/calendar/calendar_edit_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';
import 'package:woo_yeon_hi/style/text_style.dart';

class CalendarDetailScreen extends StatefulWidget {
  Map<String, dynamic> scheduleData;
  CalendarDetailScreen(this.scheduleData, {super.key});

  @override
  State<CalendarDetailScreen> createState() => _CalendarDetailScreenState();
}

class _CalendarDetailScreenState extends State<CalendarDetailScreen> {

  Color currentColor = ColorFamily.green;

  @override
  Widget build(BuildContext context) {
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
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return CalendarEditScreen(widget.scheduleData);
                  }),
                );
              },
              icon: SvgPicture.asset("lib/assets/icons/edit.svg"),
            ),
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
                                shape: CircleBorder(),
                                backgroundColor: currentColor // 선택된 색상
                            ),
                            onPressed: () {},
                            child: Icon(null)
                        ),
                        Expanded(
                          child: Text(
                            widget.scheduleData['schedule_title'],
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
                          Text(
                            widget.scheduleData['schedule_start_date'] == widget.scheduleData['schedule_finish_date']
                              ? "${widget.scheduleData['schedule_start_date']}"
                              : "${widget.scheduleData['schedule_start_date']} ~ ${widget.scheduleData['schedule_finish_date']}",
                            style: TextStyleFamily.normalTextStyle,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              // 일정
                              Text(
                                "${widget.scheduleData['schedule_start_time']} ~ ${widget.scheduleData['schedule_finish_time']}",
                                style: TextStyleFamily.normalTextStyle,
                              ),
                            ],
                          ),
                          const SizedBox(height: 45),
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
                                      widget.scheduleData['schedule_memo'],
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
    );
  }
}
