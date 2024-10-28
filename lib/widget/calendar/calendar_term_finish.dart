import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../provider/login_register_provider.dart';
import '../../provider/schedule_provider.dart';
import '../../style/color.dart';
import '../../style/font.dart';
import '../../style/text_style.dart';
import '../../utils.dart';

class CalendarTermFinish extends StatefulWidget {
  final bool isTrue;

  const CalendarTermFinish({required this.isTrue, super.key});

  @override
  State<CalendarTermFinish> createState() => _CalendarTermFinishState();
}

class _CalendarTermFinishState extends State<CalendarTermFinish> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarScreenProvider>(builder: (context, provider, _) {
      return Column(
        children: [
          widget.isTrue
              // 하루 종일 일정인 경우 picker
              ? InkWell(
                  onTap: () {
                    picker.DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        minTime: stringToDateLight(
                            Provider.of<UserProvider>(context, listen: false)
                                .loveDday),
                        maxTime: DateTime(2099, 12, 31),
                        theme: const picker.DatePickerTheme(
                          titleHeight: 60,
                          containerHeight: 300,
                          itemHeight: 50,
                          headerColor: ColorFamily.white,
                          backgroundColor: ColorFamily.white,
                          itemStyle: TextStyleFamily.smallTitleTextStyle,
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
                        currentTime: provider.termFinish, onConfirm: (date) {
                      provider.setTermFinish(
                          DateTime(date.year, date.month, date.day, 23, 59));
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 1),
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: ColorFamily.black, width: 1))),
                    child: Text(
                        DateFormat('yyyy. M. d.(E)', 'ko_KR')
                            .format(provider.termFinish),
                        style: TextStyleFamily.normalTextStyle),
                  ),
                )
              // 하루 종일 일정이 아닌 경우 picker
              : InkWell(
                  onTap: () {
                    picker.DatePicker.showDateTimePicker(
                      context,
                      showTitleActions: true,
                      minTime: stringToDateLight(
                          Provider.of<UserProvider>(context, listen: false)
                              .loveDday),
                      maxTime: DateTime(2099, 12, 31),
                      onConfirm: (dateTime) {
                        provider.setTermFinish(dateTime);
                      },
                      currentTime: provider.termFinish,
                      locale: picker.LocaleType.ko,
                      theme: const picker.DatePickerTheme(
                          titleHeight: 60,
                          containerHeight: 300,
                          itemHeight: 50,
                          headerColor: ColorFamily.white,
                          backgroundColor: ColorFamily.white,
                          itemStyle: TextStyleFamily.smallTitleTextStyle,
                          cancelStyle: TextStyle(
                              color: ColorFamily.black,
                              fontSize: 18,
                              fontFamily: FontFamily.mapleStoryLight),
                          doneStyle: TextStyle(
                              color: ColorFamily.black,
                              fontSize: 18,
                              fontFamily: FontFamily.mapleStoryLight)),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.only(bottom: 1),
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: ColorFamily.black, width: 1))),
                    child: Text(
                        DateFormat('yyyy. M. d.(E) HH:mm', 'ko_KR')
                            .format(provider.termFinish),
                        style: TextStyleFamily.normalTextStyle),
                  ),
                )
        ],
      );
    });
  }
}
