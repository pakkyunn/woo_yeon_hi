import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/text_style.dart';
import '../../provider/login_register_provider.dart';
import '../../provider/schedule_provider.dart';
import '../../style/font.dart';
import '../../utils.dart';

class CalendarTermStart extends StatefulWidget {
  final bool isTrue;

  const CalendarTermStart({
    required this.isTrue,
    super.key
  });

  @override
  State<CalendarTermStart> createState() => _CalendarTermStartState();
}

class _CalendarTermStartState extends State<CalendarTermStart> {

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarScreenProvider>(
        builder: (context, provider, _) {
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
              currentTime: provider.termStart,
              onConfirm: (date) {
                provider.setTermStart(DateTime(date.year, date.month, date.day, 00, 00));
                provider.setTermFinish(provider.termStart.add(const Duration(hours: 1)));
              }
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
            child: Text(dateToStringWithDay(provider.termStart), style: TextStyleFamily.normalTextStyle),
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
                provider.setTermStart(dateTime);
                provider.setTermFinish(provider.termStart.add(const Duration(hours: 1)));
              },
              currentTime: provider.termStart,
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
              DateFormat('yyyy. M. d.(E) HH:mm', 'ko_KR').format(provider.termStart),
              style: TextStyleFamily.normalTextStyle
            ),
          ),
        ),
      ],
    );

});}}
