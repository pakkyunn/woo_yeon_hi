import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/schedule_dao.dart';
import 'package:woo_yeon_hi/enums.dart';
import 'package:woo_yeon_hi/model/schedule_model.dart';
import 'package:woo_yeon_hi/provider/login_register_provider.dart';
import 'package:woo_yeon_hi/provider/schedule_provider.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/utils.dart';
import 'package:woo_yeon_hi/widget/calendar/calendar_switch.dart';
import 'package:woo_yeon_hi/widget/calendar/calendar_term_finish.dart';
import 'package:woo_yeon_hi/widget/calendar/calendar_term_start.dart';

import '../../style/text_style.dart';

class CalendarAddScreen extends StatefulWidget {
  const CalendarAddScreen({super.key});

  @override
  State<CalendarAddScreen> createState() => _CalendarAddScreenState();
}

class _CalendarAddScreenState extends State<CalendarAddScreen> {

  // 현재 선택된 색상
  Color currentColor = ScheduleColorType.GREEN_COLOR.colorCode;

  // 다이얼로그 위치
  double? left;
  double? top;

  // 하루 종일 체크여부
  bool checkAllDay = false;

  // 시작일 날짜
  DateTime termStart = DateTime.now().subtract(Duration(minutes: DateTime.now().minute));
  // 종료일 날짜 +1 hour
  DateTime termFinish = DateTime.now().add(const Duration(hours: 1)).subtract(Duration(minutes: DateTime.now().minute));

  // 색 업데이트 함수
  void updateColor(Color color) {
    setState(() {
      currentColor = color;
    });
  }

  // 스위치 버튼 - 하루종일
  void isAllDay(bool isTrue) {
    setState(() {
      checkAllDay = !checkAllDay;
    });
  }

  // 시작일이 변경될 때
  void onTermStartChanged(DateTime date) {
    setState(() {
      termStart = date;
    });
  }

  // 종료일이 변경될 때
  void onTermFinishChanged(DateTime date) {
    setState(() {
      termFinish = date;
    });
  }

  // // 종료일 상태 업데이트
  // void updateFinishDateField() {
  //   // 년, 월, 일
  //   var startDay = termStart.year + termStart.month + termStart.day;
  //   var finishDay = termFinish.year + termFinish.month + termFinish.day;
  //
  //   // 하루종일 - true
  //   if (checkAllDay) {
  //
  //     // 년, 월, 일이 같다면
  //     if (startDay == finishDay) {
  //       checkTerm = true;
  //       finishTextDecoration = TextDecoration.none;
  //     }
  //     else {
  //       // 종료일이 시작일보다 먼저라면
  //       if (termFinish.isBefore(termStart)) {
  //         checkTerm = false;
  //         finishTextDecoration = TextDecoration.lineThrough;
  //       } else {
  //         checkTerm = true;
  //         finishTextDecoration = TextDecoration.none;
  //       }
  //     }
  //   }
  //   // 하루종일 - false
  //   else {
  //     // 종료일이 시작일보다 먼저라면
  //     if (termFinish.isBefore(termStart)) {
  //       checkTerm = false;
  //       finishTextDecoration = TextDecoration.lineThrough;
  //     } else {
  //       checkTerm = true;
  //       finishTextDecoration = TextDecoration.none;
  //     }
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ScheduleProvider(),
      child: Consumer<ScheduleProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: ColorFamily.cream,
            appBar: AppBar(
              surfaceTintColor: ColorFamily.cream,
              backgroundColor: ColorFamily.cream,
              centerTitle: true,
              scrolledUnderElevation: 0,
              title: const Text(
                  "일정 추가",
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
                  onPressed: () async {
                    // 일정 오류
                    if (termFinish.isBefore(termStart)) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            surfaceTintColor: ColorFamily.white,
                            backgroundColor: ColorFamily.white,
                            child: Wrap(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Column(
                                        children: [
                                          Text(
                                            "오류가 발생했습니다",
                                            style: TextStyleFamily.dialogTitleTextStyle,
                                          ),
                                          SizedBox(height: 15),
                                          Text(
                                            "시작일은 종료일의 이전이어야 합니다",
                                            style: TextStyleFamily.hintTextStyle,
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 30),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            style: ButtonStyle(
                                                overlayColor: MaterialStateProperty.all(ColorFamily.gray)
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "취소",
                                              style: TextStyleFamily.dialogButtonTextStyle,
                                            ),
                                          ),
                                          TextButton(
                                            style: ButtonStyle(
                                                overlayColor: MaterialStateProperty.all(ColorFamily.gray)
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "확인",
                                              style: TextStyleFamily.dialogButtonTextStyle_pink,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      );
                      // 오류가 없을 경우
                    } else {
                      await onConfirm_done(context, provider);  // 저장처리
                      Navigator.pop(context);    // 화면 종료
                    }
                  },
                  icon: SvgPicture.asset("lib/assets/icons/done.svg"),
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Builder(
                        builder: (BuildContext context) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: currentColor // 선택된 색상
                            ),
                            // 색 선택 다이얼로그 띄우기
                            onPressed: () {
                              _showColorPickerDialog(context, currentColor, updateColor);
                            },
                            child: const Text(""),
                          );
                        }
                      ),
                      Expanded(
                        child: TextField(
                          controller: provider.titleController,
                          style: TextStyleFamily.appBarTitleBoldTextStyle,
                          keyboardType: TextInputType.text,
                          cursorColor: ColorFamily.black,
                          maxLength: 12,
                          onTapOutside: (event) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          decoration: const InputDecoration(
                            counter: SizedBox(),
                            hintText: "제목",
                            hintStyle: TextStyleFamily.hintTitleTextStyle,
                            border: InputBorder.none, // 밑줄 제거
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child:
                            Row(
                              children: [
                                const Text("하루 종일", style: TextStyleFamily.normalTextStyle),
                                const Spacer(),
                                CalendarSwitch(onSwitchChanged: isAllDay), // 스위치 버튼
                              ],
                            ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            const Text("시작", style: TextStyleFamily.normalTextStyle),
                            const Spacer(),
                            // 시작 날짜를 선택하는 위젯
                            CalendarTermStart(
                              onDateChanged: onTermStartChanged,
                              initialDate: termStart,
                              isTrue: checkAllDay,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            const Text("종료", style: TextStyleFamily.normalTextStyle),
                            const Spacer(),
                            // 종료 날짜를 선택하는 위젯
                            CalendarTermFinish(
                              onDateChanged: onTermFinishChanged,
                              initialDate: termFinish,
                              isTrue: checkAllDay,
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Card(
                          color: ColorFamily.white,
                          surfaceTintColor: ColorFamily.white,
                          elevation: 1,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: 320, // 위젯의 최소 크기
                              maxHeight: double.infinity, // 최대 크기에 맞춰 늘어나도록
                            ),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: TextField(
                                  controller: provider.memoController,
                                  keyboardType: TextInputType.multiline,
                                  cursorColor: ColorFamily.black,
                                  onTapOutside: (event) =>
                                      FocusManager.instance.primaryFocus?.unfocus(),
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                      hintText: "메모를 입력해주세요",
                                      hintStyle: TextStyleFamily.hintTextStyle,
                                      border: InputBorder.none
                                  ),
                                  style: TextStyleFamily.normalTextStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )
                ],
              ),
            )
          );
        },
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context, Color currentColor, ValueChanged<Color> onColorChanged) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderObject = context.findRenderObject();
      if (renderObject is RenderBox) {
        final RenderBox renderBox = renderObject;
        final offset = renderBox.localToGlobal(Offset.zero);

        setState(() {
          left = offset.dx - 10; // x 좌표
          top = offset.dy - 15;  // y 좌표
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Stack(
              children: [
                Positioned(
                  left: left ?? 0,
                  top: top ?? 0,
                  child: Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      width: 200,
                      height: 140,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            direction: Axis.horizontal, // 정렬 방향
                            alignment: WrapAlignment.start, // 정렬 방식
                            spacing: 10, // 좌우 간격
                            runSpacing: 5,  // 상하 간격
                            children: [
                              _buildColorOption(context, ScheduleColorType.RED_COLOR, currentColor, onColorChanged),
                              _buildColorOption(context, ScheduleColorType.ORANGE_COLOR, currentColor, onColorChanged),
                              _buildColorOption(context, ScheduleColorType.YELLOW_COLOR, currentColor, onColorChanged),
                              _buildColorOption(context, ScheduleColorType.GREEN_COLOR, currentColor, onColorChanged),
                              _buildColorOption(context, ScheduleColorType.BLUE_COLOR, currentColor, onColorChanged),
                              _buildColorOption(context, ScheduleColorType.NAVY_COLOR, currentColor, onColorChanged),
                              _buildColorOption(context, ScheduleColorType.PURPLE_COLOR, currentColor, onColorChanged),
                              _buildColorOption(context, ScheduleColorType.BLACK_COLOR, currentColor, onColorChanged),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    });
  }

  // 완료 작업
  Future<void> onConfirm_done(BuildContext context, ScheduleProvider provider) async {
    var schedule_idx = await getScheduleSequence() + 1; // 저장할 때 idx 값 1씩 증가
    var schedule_user_idx = Provider.of<UserProvider>(context, listen: false).userIdx;
    await setScheduleSequence(schedule_idx);
    var schedule_start_date = dateToStringWithDay(termStart);
    var schedule_finish_date = dateToStringWithDay(termFinish);
    var schedule_start_time = checkAllDay
          ? '00:00'
          : DateFormat('HH:mm').format(termStart);
    var schedule_finish_time = checkAllDay
          ? '11:59'
          : DateFormat('HH:mm').format(termFinish);
    var schedule = Schedule(
      scheduleIdx: schedule_idx,
      scheduleUserIdx: schedule_user_idx,
      scheduleStartDate: schedule_start_date,
      scheduleFinishDate: schedule_finish_date,
      scheduleStartTime: schedule_start_time,
      scheduleFinishTime: schedule_finish_time,
      scheduleTitle: provider.titleController.text,
      scheduleColor: Provider.of<CalendarScreenProvider>(context, listen: false).selectedColorType,
      scheduleMemo: provider.memoController.text,
      scheduleState: ScheduleState.STATE_NORMAL.state
    );

    await addSchedule(schedule); // 컬렉션에 저장
    provider.providerNotify();
  }
}

Widget _buildColorOption(BuildContext context, ScheduleColorType color, Color currentColor, ValueChanged<Color> onColorChanged) {
  return GestureDetector(
    onTap: () {
      onColorChanged(color.colorCode);
      Provider.of<CalendarScreenProvider>(context, listen: false).setSelectedColorType(color.typeIdx);
      Navigator.of(context).pop();
    },
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 50,
          decoration: BoxDecoration(
            color: color.colorCode,
            shape: BoxShape.circle,
          ),
        ),
        if(currentColor == color.colorCode)
          Positioned(
            child: SvgPicture.asset(
              "lib/assets/icons/done.svg",
              color: ColorFamily.white,
            ),
          )
      ],
    ),
  );
}