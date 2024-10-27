import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../provider/login_register_provider.dart';
import '../../style/color.dart';
import '../../style/font.dart';
import '../../style/text_style.dart';
import '../../utils.dart';

class CalendarTermFinish extends StatefulWidget {
  final Function(DateTime) onDateChanged;
  final DateTime initialDate; // 초기 날짜
  final bool isTrue;

  const CalendarTermFinish({
    required this.onDateChanged,
    required this.initialDate,
    required this.isTrue,
    super.key
  });

  @override
  State<CalendarTermFinish> createState() => _CalendarTermFinishState();
}

class _CalendarTermFinishState extends State<CalendarTermFinish> {

  // 선택한 날짜 시간
  late DateTime selectedDateTime;

  @override
  void initState(){
    super.initState();

    // 현재 시간으로
    selectedDateTime = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.isTrue
        // 하루 종일 일정인 경우 picker
            ? InkWell(
          onTap: () {
            picker.DatePicker.showDatePicker(
              context,
              showTitleActions: true,
              minTime: stringToDateLight(Provider.of<UserProvider>(context, listen: false).loveDday),
              maxTime: DateTime(2099, 12, 31),
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
              currentTime: selectedDateTime,
              onConfirm: (date) {
                setState(() {
                  selectedDateTime = DateTime(date.year, date.month, date.day, 23, 59);
                  widget.onDateChanged(selectedDateTime);
                });
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.only(bottom: 1),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: ColorFamily.black,
                  width: 1
                )
              )
            ),
            child: Text(
              DateFormat('yyyy. M. d.(E)', 'ko_KR').format(selectedDateTime),
              style: TextStyleFamily.normalTextStyle
            ),
          ),
        )
        // 하루 종일 일정이 아닌 경우 picker
            : InkWell(
          onTap: () {
            picker.DatePicker.showDateTimePicker(
              context,
              showTitleActions: true,
              minTime: stringToDateLight(Provider.of<UserProvider>(context, listen: false).loveDday),
              maxTime: DateTime(2099, 12, 31),
              onConfirm: (dateTime) {
                setState(() {
                  selectedDateTime = dateTime;
                  widget.onDateChanged(selectedDateTime);
                });
              },
              currentTime: selectedDateTime,
              locale: picker.LocaleType.ko,
              theme: const picker.DatePickerTheme(
                  titleHeight: 60,
                  containerHeight: 300,
                  itemHeight: 50,
                  headerColor: ColorFamily.white,
                  backgroundColor:
                  ColorFamily.white,
                  itemStyle: TextStyleFamily
                      .smallTitleTextStyle,
                  cancelStyle: TextStyle(
                      color: ColorFamily.black,
                      fontSize: 18,
                      fontFamily: FontFamily
                          .mapleStoryLight),
                  doneStyle: TextStyle(
                      color: ColorFamily.black,
                      fontSize: 18,
                      fontFamily: FontFamily
                          .mapleStoryLight)),
            );
          },
          child: Container(
            padding: EdgeInsets.only(bottom: 1),
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: ColorFamily.black,
                        width: 1
                    )
                )
            ),
            child: Text(
              DateFormat('yyyy. M. d.(E) HH:mm', 'ko_KR').format(selectedDateTime),
              style: TextStyleFamily.normalTextStyle
              ),
          ),
        )
      ],
    );
  }
}
