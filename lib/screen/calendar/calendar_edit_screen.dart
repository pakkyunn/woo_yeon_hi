import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dialogs.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';
import 'package:woo_yeon_hi/style/text_style.dart';
import 'package:woo_yeon_hi/widget/calendar/calendar_switch.dart';
import 'package:woo_yeon_hi/widget/calendar/calendar_term_finish.dart';
import 'package:woo_yeon_hi/widget/calendar/calendar_term_start.dart';

import '../../enums.dart';
import '../../provider/schedule_provider.dart';

class CalendarEditScreen extends StatefulWidget {
  Map<String, dynamic> scheduleData;
  CalendarEditScreen(this.scheduleData, {super.key});

  @override
  State<CalendarEditScreen> createState() => _CalendarEditScreenState();
}

class _CalendarEditScreenState extends State<CalendarEditScreen> {

  Map<String, dynamic> _scheduleData = {};

  // 현재 선택된 색상
  Color currentColor = ScheduleColorType.GREEN_COLOR.colorCode;

  // 하루 종일 체크여부
  bool checkAllDay = false;

  // 다이얼로그 위치
  double? left;
  double? top;

  // 시작일 날짜
  DateTime termStart = DateTime.now();
  // 종료일 날짜
  DateTime termFinish = DateTime.now();

  // 색 업데이트 함수
  void updateColor(Color color){
    setState(() {
      currentColor = color;
    });
  }

  // 스위치 버튼
  void isAllTime(bool isTrue){
    setState(() {
      checkAllDay = !checkAllDay;
    });
  }

  // 시작일이 변경될 때
  void onTermStartChanged(DateTime date){
    setState(() {
      termStart = date;
    });
  }

  // 종료일이 변경될 때
  void onTermFinishChanged(DateTime date){
    setState(() {
      termFinish = date;
    });
  }

  @override
  void initState() {
    super.initState();

    _scheduleData = widget.scheduleData;

    // 시작일
    termStart = stringToDateForStart(_scheduleData['schedule_start_date']);
    // 종료일
    termFinish = stringToDateForFinish(_scheduleData['schedule_finish_date']);
  }

  // 시작일을 DateTime 타입으로 변경
  DateTime stringToDateForStart(String strDateTime) {
    var date = _scheduleData['schedule_start_date'];
    var time = _scheduleData['schedule_start_time'];

    strDateTime = "$date $time";

    var dateFormat = DateFormat('yyyy. M. dd.(E) HH:mm', 'ko_KR');
    DateTime dateTime = dateFormat.parse(strDateTime);

    return dateTime;
  }

  // 종료일을 DateTime 타입으로 변경
  DateTime stringToDateForFinish(String strDateTime) {
    var date = _scheduleData['schedule_finish_date'];
    var time = _scheduleData['schedule_finish_time'];

    strDateTime = "$date $time";

    var dateFormat = DateFormat('yyyy. M. dd.(E) HH:mm', 'ko_KR');
    DateTime dateTime = dateFormat.parse(strDateTime);

    return dateTime;
  }


  /*


      수정 완료 처리


   */



  @override
  Widget build(BuildContext context) {

    // 제목
    TextEditingController titleController = TextEditingController(text: "${_scheduleData['schedule_title']}");
    // 메모 내용
    TextEditingController memoController = TextEditingController(text: "${_scheduleData['schedule_memo']}");

    return Scaffold(
      backgroundColor: ColorFamily.cream,
      appBar: AppBar(
        backgroundColor: ColorFamily.cream,
        surfaceTintColor: ColorFamily.cream,
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: const Text(
          "일정 편집",
          style: TextStyleFamily.appBarTitleLightTextStyle,
        ),
        leading: IconButton(
          onPressed: () {
            if(titleController.text != _scheduleData['schedule_title']
               || memoController.text != _scheduleData['schedule_memo']
               || termStart != stringToDateForStart(_scheduleData['schedule_start_date'])
               || termFinish != stringToDateForFinish(_scheduleData['schedule_finish_date'])){
              dialogTitleWithContent(
                  context,
                  "일정 편집 나가기",
                  "편집된 내용은 저장되지 않습니다.",
                      () {Navigator.pop(context, false);},
                      () {Navigator.pop(context, true);
                  Future.delayed(const Duration(milliseconds: 100), () {Navigator.of(context).pop();});}
              );
            } else{
              Navigator.pop(context);
            }
          },
          icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              //TODO 저장처리
              Navigator.pop(context);
              showPinkSnackBar(context, "일정이 편집되었습니다");
            },
            icon: SvgPicture.asset('lib/assets/icons/done.svg'),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: currentColor,
                          ),
                          onPressed: () {
                            _showColorPickerDialog(context, currentColor, updateColor);
                          },
                          // => showColorPickerDialog(context, currentColor, updateColor),
                          child: const Icon(null),
                        ),
                        Expanded(
                          child: TextField(
                            controller: titleController,
                            style: TextStyleFamily.appBarTitleBoldTextStyle,
                            keyboardType: TextInputType.text,
                            cursorColor: ColorFamily.black,
                            onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                            decoration: const InputDecoration(
                              hintText: "제목",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text("하루 종일", style: TextStyleFamily.normalTextStyle),
                              const Spacer(),
                              CalendarSwitch(onSwitchChanged: isAllTime)
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              const Text("시작", style: TextStyleFamily.normalTextStyle),
                              const Spacer(),
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
                              CalendarTermFinish(
                                onDateChanged: onTermFinishChanged,
                                initialDate: termFinish,
                                isTrue: checkAllDay,
                              )
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
                                maxHeight: double.infinity  // 최대 크기에 맞춰서 늘어나도록
                              ),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: ColorFamily.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: TextField(
                                    controller: memoController,
                                    keyboardType: TextInputType.multiline,
                                    cursorColor: ColorFamily.black,
                                    onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      hintText: "메모 작성",
                                      hintStyle: TextStyleFamily.hintTextStyle,
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyleFamily.normalTextStyle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorFamily.pink,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )
                        ),
                        onPressed: () {
                          // 다이얼로그
                          showDialog(
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
                                        // 공간을 차지하지 않고 각 끝으로
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // 텍스트마다 각각 속성을 부여하는 RichText - TextSpan
                                          RichText(
                                            text: const TextSpan(
                                                text: "해당 일정을 ",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: FontFamily.mapleStoryLight,
                                                  color: ColorFamily.black,
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: "삭제 ",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: FontFamily.mapleStoryBold,
                                                        color: ColorFamily.black,
                                                      )
                                                  ),
                                                  TextSpan(
                                                      text: "하시겠습니까?",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily: FontFamily.mapleStoryLight,
                                                          color: ColorFamily.black
                                                      )
                                                  )
                                                ]
                                            ),
                                          ),
                                          const SizedBox(height: 40),
                                          Row(
                                            // 같은 크기만큼 양 옆 공간차지
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  "취소",
                                                  style: TextStyleFamily.dialogButtonTextStyle,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  //TODO 삭제 처리 코드

                                                  Navigator.pop(context); // 다이얼로그
                                                  Navigator.pop(context); // 일정 편집 화면
                                                  Navigator.pop(context); // 일정 상세 화면
                                                  showPinkSnackBar(context, "일정이 삭제되었습니다");
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
                        },
                        child: const Text(
                          "일정 삭제",
                          style: TextStyle(
                            color: ColorFamily.white,
                            fontSize: 14,
                            fontFamily: FontFamily.mapleStoryLight
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        }
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