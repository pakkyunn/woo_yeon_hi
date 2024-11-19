import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:woo_yeon_hi/provider/footprint_provider.dart';
import 'package:woo_yeon_hi/style/text_style.dart';

import '../../enums.dart';
import '../../provider/login_register_provider.dart';
import '../../screen/footPrint/footprint_history_write_place_screen.dart';
import '../../style/color.dart';
import '../../style/font.dart';
import '../../utils.dart';

class FootprintHistoryWriteContent extends StatefulWidget {
  FootprintHistoryWriteContent(this.provider, {super.key});
  FootprintHistoryWriteProvider provider;

  @override
  State<FootprintHistoryWriteContent> createState() =>
      _FootprintHistoryWriteContentState();
}

class _FootprintHistoryWriteContentState extends State<FootprintHistoryWriteContent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 40,
        child: Column(
          children: [
            // 지역 선택
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FootprintHistoryWritePlaceScreen(
                            widget.provider, MapType.KOREA_FULL.type)));
                // widget.provider.setPlace(null);
                widget.provider.clearSearchPlace();
              },
              child: SizedBox(
                height: 50,
                child: Row(
                  children: [
                    SvgPicture.asset('lib/assets/icons/pin_alt.svg'),
                    const SizedBox(
                      width: 15,
                    ),
                    widget.provider.selectedPlace != null
                        ? Row(
                            children: [
                              Text(
                                widget.provider.selectedPlace!.title,
                                style: TextStyleFamily.normalTextStyle,
                              )
                            ],
                          )
                        : const Text(
                            "장소",
                            style: TextStyleFamily.hintTextStyle,
                          )
                  ],
                ),
              ),
            ),
            const Divider(
              color: ColorFamily.black,
              height: 5,
              thickness: 0.5,
            ),
            // 날짜 입력
            SizedBox(
              height: 50,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  _showCalendarBottomSheet(widget.provider);
                },
                child: Row(
                  children: [
                    SvgPicture.asset('lib/assets/icons/calendar.svg'),
                    const SizedBox(
                      width: 15,
                    ),
                    widget.provider.date != null
                        ? Row(
                            children: [
                              Text(
                                widget.provider.date!,
                                style: TextStyleFamily.normalTextStyle,
                              ),
                            ],
                          )
                        : const Text(
                            "날짜",
                            style: TextStyleFamily.hintTextStyle,
                          )
                  ],
                ),
              ),
            ),
            const Divider(
              color: ColorFamily.black,
              height: 5,
              thickness: 0.5,
            ),
            // 히스토리 제목
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  SvgPicture.asset('lib/assets/icons/woo_yeon_hi.svg'),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      controller: widget.provider.titleController,
                      style: TextStyleFamily.normalTextStyle,
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      cursorColor: ColorFamily.black,
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintStyle: TextStyleFamily.hintTextStyle,
                          hintText: "히스토리 제목"),
                    ),
                  )
                ],
              ),
            ),
            const Divider(
              color: ColorFamily.black,
              height: 5,
              thickness: 0.5,
            ),
            // 히스토리 내용
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  SvgPicture.asset('lib/assets/icons/message-question.svg'),
                  const SizedBox(
                    width: 15,
                  ),
                  const Text(
                    "어떤 추억을 만드셨나요?",
                    style: TextStyleFamily.normalTextStyle,
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ColorFamily.black, width: 0.5)),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                    controller: widget.provider.contentController,
                    style: TextStyleFamily.normalTextStyle,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    cursorColor: ColorFamily.black,
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintStyle: TextStyleFamily.hintTextStyle,
                        hintText: "\n\n\n\n\n\n\n\n"),
                  )
              ),
            )
          ],
        ),
      ),
    );
  }

  bool isSaturday(DateTime day) {
    return day.weekday == DateTime.saturday;
  }

  bool isWeekend(DateTime day) {
    return day.weekday == DateTime.sunday;
  }

  void _showCalendarBottomSheet(FootprintHistoryWriteProvider provider) {
    DateTime _selectedDay = DateTime.now();
    DateTime _focusedDay = DateTime.now();
    var deviceWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
        context: context,
        backgroundColor: ColorFamily.white,
        builder: (context) {
          return StatefulBuilder(builder: (context, bottomState) {
            return Wrap(
              children: [
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      children: [
                        TableCalendar(
                          sixWeekMonthsEnforced: true,
                          availableGestures: AvailableGestures.horizontalSwipe,
                          firstDay: stringToDate(Provider.of<UserProvider>(context, listen: false).loveDday),
                          lastDay: DateTime.now(),
                          focusedDay: _focusedDay,
                          locale: 'ko_kr',
                          rowHeight: 45,
                          daysOfWeekHeight:40,
                          headerStyle: const HeaderStyle(
                              titleCentered: true,
                              formatButtonVisible: false,
                              titleTextStyle: TextStyleFamily
                                  .appBarTitleBoldTextStyle),
                          daysOfWeekStyle: const DaysOfWeekStyle(
                              weekdayStyle: TextStyleFamily.normalTextStyle,
                              weekendStyle: TextStyleFamily.normalTextStyle
                          ),
                          calendarBuilders: CalendarBuilders(
                            // 기본 월의 빌더
                            defaultBuilder: (context, day, focusedDay) {
                              return Container(
                                alignment: Alignment.center,
                                child: Text(
                                  DateFormat('d').format(day),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: isWeekend(day)
                                          ? Colors.red
                                          : isSaturday(day)
                                          ? Colors.blueAccent
                                          : ColorFamily.black,
                                      fontFamily:
                                      FontFamily.mapleStoryLight),
                                ),
                              );
                            },
                            // 다른 월의 빌더
                            outsideBuilder: (context, day, focusedDay) {
                              return Container(
                                alignment: Alignment.center,
                                child: Text(
                                  textAlign: TextAlign.center,
                                  DateFormat('d').format(day),
                                  style: const TextStyle(
                                      color: ColorFamily.gray,
                                      fontFamily: FontFamily.mapleStoryLight
                                  ),
                                ),
                              );
                            },
                            // 비활성화된 날짜
                            disabledBuilder: (context, day, focusedDay) {
                              return Container(
                                alignment: Alignment.center,
                                child: Text(
                                  textAlign: TextAlign.center,
                                  DateFormat('d').format(day),
                                  style: const TextStyle(
                                      color: ColorFamily.gray,
                                      fontFamily: FontFamily.mapleStoryLight
                                  ),
                                ),
                              );
                            },
                            // 선택된 날짜
                            selectedBuilder:
                                (context, day, focusedDay) {
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
                                      DateFormat('d').format(day),
                                      style: TextStyle(
                                        color: isWeekend(day)
                                            ? ColorFamily.white
                                            : isSaturday(day)
                                            ? ColorFamily.white
                                            : ColorFamily.black,
                                        fontFamily:
                                        FontFamily.mapleStoryLight,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            // 오늘 날짜
                            todayBuilder: (context, day, focusedDay) {
                              return Container(
                                alignment: Alignment.center,
                                child: Text(
                                  textAlign: TextAlign.center,
                                  DateFormat('d').format(day),
                                  style: const TextStyle(
                                      color: ColorFamily.pink,
                                      fontFamily: FontFamily.mapleStoryLight
                                  ),
                                ),
                              );
                            },
                          ),
                          // 선택된 날짜
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          // 날짜 선택
                          onDaySelected: (selectedDay, focusedDay) {
                            bottomState(() {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            });
                          },
                          // 화면이 바뀔때
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                        ),
                        // TableCalendar(
                        //   firstDay: DateTime.utc(2024, 3, 16),
                        //   lastDay: DateTime.utc(2024, 8, 14),
                        //   focusedDay: _focusedDay,
                        //   locale: 'ko_kr',
                        //   rowHeight: 50,
                        //   headerStyle: const HeaderStyle(
                        //     titleCentered: true,
                        //     titleTextStyle:
                        //         TextStyleFamily.appBarTitleBoldTextStyle,
                        //     formatButtonVisible: false,
                        //   ),
                        //   daysOfWeekStyle: const DaysOfWeekStyle(
                        //       weekdayStyle: TextStyleFamily.normalTextStyle,
                        //       weekendStyle: TextStyleFamily.normalTextStyle),
                        //   calendarBuilders: CalendarBuilders(
                        //     defaultBuilder: (context, day, focusedDay) {
                        //       return Container(
                        //         alignment: Alignment.topCenter,
                        //         padding: const EdgeInsets.only(top: 15),
                        //         child: Text(
                        //           textAlign: TextAlign.center,
                        //           DateFormat('d').format(day),
                        //           style: TextStyle(
                        //               color: isWeekend(day)
                        //                   ? Colors.red
                        //                   : isSaturday(day)
                        //                       ? Colors.blueAccent
                        //                       : ColorFamily.black,
                        //               fontFamily: FontFamily.mapleStoryLight),
                        //         ),
                        //       );
                        //     },
                        //     outsideBuilder: (context, day, focusedDay) {
                        //       return Container(
                        //         alignment: Alignment.topCenter,
                        //         padding: const EdgeInsets.only(top: 15),
                        //         child: Text(
                        //           textAlign: TextAlign.center,
                        //           DateFormat('d').format(day),
                        //           style: const TextStyle(
                        //               color: ColorFamily.gray,
                        //               fontFamily: FontFamily.mapleStoryLight),
                        //         ),
                        //       );
                        //     },
                        //     disabledBuilder: (context, day, focusedDay) {
                        //       return Container(
                        //         alignment: Alignment.topCenter,
                        //         padding: const EdgeInsets.only(top: 15),
                        //         child: Text(
                        //           textAlign: TextAlign.center,
                        //           DateFormat('d').format(day),
                        //           style: const TextStyle(
                        //               color: ColorFamily.gray,
                        //               fontFamily: FontFamily.mapleStoryLight),
                        //         ),
                        //       );
                        //     },
                        //     selectedBuilder: (context, day, focusedDay) {
                        //       return Container(
                        //         alignment: Alignment.topCenter,
                        //         padding: const EdgeInsets.only(top: 10),
                        //         child: Container(
                        //           width: 30,
                        //           height: 30,
                        //           decoration: const BoxDecoration(
                        //             color: ColorFamily.pink,
                        //             shape: BoxShape.circle,
                        //           ),
                        //           child: Center(
                        //             child: Text(
                        //               textAlign: TextAlign.center,
                        //               DateFormat('d').format(day),
                        //               style: TextStyle(
                        //                   color: isWeekend(day)
                        //                       ? ColorFamily.white
                        //                       : isSaturday(day)
                        //                           ? ColorFamily.white
                        //                           : ColorFamily.black,
                        //                   fontFamily: FontFamily.mapleStoryLight),
                        //             ),
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //     todayBuilder: (context, day, focusedDay) {
                        //       return Container(
                        //         alignment: Alignment.topCenter,
                        //         padding: const EdgeInsets.only(top: 15),
                        //         child: Text(
                        //           textAlign: TextAlign.center,
                        //           DateFormat('d').format(day),
                        //           style: const TextStyle(
                        //               color: ColorFamily.pink,
                        //               fontFamily: FontFamily.mapleStoryLight),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        //   selectedDayPredicate: (day) {
                        //     return isSameDay(_selectedDay, day);
                        //   },
                        //   onDaySelected: (selectedDay, focusedDay) {
                        //     bottomState(() {
                        //       setState(() {
                        //         _selectedDay = selectedDay;
                        //         _focusedDay =
                        //             focusedDay; // update `_focusedDay` here as well
                        //       });
                        //     });
                        //   },
                        //   onPageChanged: (focusedDay) {
                        //     _focusedDay = focusedDay;
                        //   },
                        // ),
                        // 이벤트 버튼들
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: (deviceWidth-40)/2-5,
                          height: 40,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorFamily.white,
                                  surfaceTintColor: ColorFamily.white),
                              onPressed: () {
                                bottomState(() {
                                  _focusedDay = DateTime.now();
                                  _selectedDay = DateTime.now();
                                });
                              },
                              child: const Text(
                                "오늘 날짜로",
                                style: TextStyleFamily.normalTextStyle,
                              )),
                        ),
                        SizedBox(
                          width: (deviceWidth-40)/2-5,
                          height: 40,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorFamily.beige,
                                  surfaceTintColor: ColorFamily.white),
                              onPressed: () {
                                widget.provider.setDate(dateToString(_selectedDay));
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "확인",
                                style: TextStyleFamily.normalTextStyle,
                              )),
                        ),
                      ],
                    ),
                  ])))]
            );
          });
        });
  }
}
