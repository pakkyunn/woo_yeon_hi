import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dialogs.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';
import 'package:woo_yeon_hi/style/text_style.dart';
import 'package:woo_yeon_hi/utils.dart';
import 'package:woo_yeon_hi/widget/calendar/calendar_switch.dart';
import 'package:woo_yeon_hi/widget/calendar/calendar_term_finish.dart';
import 'package:woo_yeon_hi/widget/calendar/calendar_term_start.dart';

import '../../dao/schedule_dao.dart';
import '../../enums.dart';
import '../../model/schedule_model.dart';
import '../../provider/schedule_provider.dart';

class CalendarEditScreen extends StatefulWidget {
  CalendarEditScreen({super.key});

  @override
  State<CalendarEditScreen> createState() => _CalendarEditScreenState();
}

class _CalendarEditScreenState extends State<CalendarEditScreen> {

  // Map<String, dynamic> _scheduleData = {};

  // 제목
  late TextEditingController titleController;
  // 메모 내용
  late TextEditingController memoController;

  // 현재 선택된 색상
  late Color currentColor;

  // 하루 종일 체크여부
  bool checkAllDay = false;

  // 다이얼로그 위치
  double? left;
  double? top;

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

  @override
  void initState() {
    super.initState();

    var provider = Provider.of<CalendarScreenProvider>(context, listen: false);

    // 시작 일시
    provider.setTermStart(stringToDateForStart(provider.selectedDaySchedule['schedule_start_date']));
    // 종료 일시
    provider.setTermFinish(stringToDateForFinish(provider.selectedDaySchedule['schedule_finish_date']));

    // 제목
    titleController = TextEditingController(text: "${provider.selectedDaySchedule['schedule_title']}");
    // 메모 내용
    memoController = TextEditingController(text: "${provider.selectedDaySchedule['schedule_memo']}");

    // 일정 색상
    currentColor = ScheduleColorType.values.firstWhere((e) => e.typeIdx == provider.selectedDaySchedule['schedule_color']).colorCode;

    if(provider.selectedDaySchedule['schedule_start_time']=="00:00" && provider.selectedDaySchedule['schedule_finish_time']=="23:59"){
        checkAllDay = true;
    }
  }

  // 시작일을 DateTime 타입으로 변경
  DateTime stringToDateForStart(String strDateTime) {
    var provider = Provider.of<CalendarScreenProvider>(context, listen: false);

    var date = provider.selectedDaySchedule['schedule_start_date'];
    var time = provider.selectedDaySchedule['schedule_start_time'];

    strDateTime = "$date $time";

    var dateFormat = DateFormat('yyyy. M. dd.(E) HH:mm', 'ko_KR');
    DateTime dateTime = dateFormat.parse(strDateTime);

    return dateTime;
  }

  // 종료일을 DateTime 타입으로 변경
  DateTime stringToDateForFinish(String strDateTime) {
    var provider = Provider.of<CalendarScreenProvider>(context, listen: false);

    var date = provider.selectedDaySchedule['schedule_finish_date'];
    var time = provider.selectedDaySchedule['schedule_finish_time'];

    strDateTime = "$date $time";

    var dateFormat = DateFormat('yyyy. M. dd.(E) HH:mm', 'ko_KR');
    DateTime dateTime = dateFormat.parse(strDateTime);

    return dateTime;
  }

  Schedule updatedScheduleModel(){
    var provider = Provider.of<CalendarScreenProvider>(context, listen: false);

    Schedule scheduleModel = Schedule(
        scheduleIdx: provider.selectedDaySchedule["schedule_idx"],
        scheduleUserIdx: provider.selectedDaySchedule["schedule_user_idx"],
        scheduleStartDate: dateToStringWithDay(provider.termStart),
        scheduleFinishDate: dateToStringWithDay(provider.termFinish),
        scheduleStartTime: DateFormat('HH:mm').format(provider.termStart),
        scheduleFinishTime: DateFormat('HH:mm').format(provider.termFinish),
        scheduleTitle: titleController.text,
        scheduleColor: Provider.of<CalendarScreenProvider>(context, listen: false).selectedColorType,
        scheduleMemo: memoController.text,
        scheduleState: 0);

    return scheduleModel;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarScreenProvider>(builder: (context, provider, child) {
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
            if(titleController.text != provider.selectedDaySchedule['schedule_title']
               || memoController.text != provider.selectedDaySchedule['schedule_memo']
               || provider.termStart != stringToDateForStart(provider.selectedDaySchedule['schedule_start_date'])
               || provider.termFinish != stringToDateForFinish(provider.selectedDaySchedule['schedule_finish_date'])){
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
            onPressed: () async {
              provider.updateSchedule(updatedScheduleModel());
              await updateScheduleData(updatedScheduleModel());
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
                        Builder(
                          builder: (buttonContext) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: currentColor,
                              ),
                              onPressed: () {
                                _showColorPickerDialog(buttonContext, currentColor, updateColor);
                              },
                              child: const Icon(null),
                            );
                          }
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
                              Switch(
                                value: checkAllDay,
                                activeColor: ColorFamily.white,
                                activeTrackColor: ColorFamily.pink,
                                inactiveThumbColor: ColorFamily.gray,
                                inactiveTrackColor: ColorFamily.white,
                                trackOutlineColor: checkAllDay
                                    ? MaterialStateProperty.all(
                                    Colors.transparent)
                                    : MaterialStateProperty.all(
                                    ColorFamily.gray),
                                trackOutlineWidth: const MaterialStatePropertyAll(1),
                                onChanged: (value) {
                                  setState(() {
                                    checkAllDay = !checkAllDay;
                                  });
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              const Text("시작", style: TextStyleFamily.normalTextStyle),
                              const Spacer(),
                              CalendarTermStart(
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
                                      padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
                                      child: Column(
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
                                                onPressed: () async {
                                                  await deleteScheduleData(provider.selectedDaySchedule['schedule_idx']);
                                                  await provider.updateScheduleList(context);
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
    );});
  }
  void _showColorPickerDialog(BuildContext buttonContext, Color currentColor, ValueChanged<Color> onColorChanged) {
    final renderBox = buttonContext.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      // 버튼의 중앙 좌표 계산
      final offset = renderBox.localToGlobal(Offset.zero);
      final buttonCenterX = offset.dx + renderBox.size.width / 2;
      final buttonCenterY = offset.dy + renderBox.size.height / 2;

      // 화면 크기
      final screenWidth = MediaQuery.of(buttonContext).size.width;
      final screenHeight = MediaQuery.of(buttonContext).size.height;
      final statusBarHeight = MediaQuery.of(buttonContext).padding.top;  // 상태 바 높이
      final navigationBarHeight = MediaQuery.of(buttonContext).padding.bottom;  // 내비게이션 바 높이

      // 유효 높이 계산 (상태 바와 내비게이션 바를 제외한 높이)
      final availableHeight = screenHeight - statusBarHeight - navigationBarHeight;

      // 다이얼로그 크기
      final dialogWidth = screenWidth*0.2;
      final dialogHeight = availableHeight*0.15;

      // 다이얼로그의 왼쪽 상단 모서리를 버튼 중앙에 맞추기 위해 보정
      final left = buttonCenterX - (dialogWidth / 2);
      final top = buttonCenterY - (dialogHeight / 2);

      showDialog(
        context: buttonContext,
        builder: (BuildContext context) {
          return Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(15,10,15,0),
                    width: dialogWidth,
                    height: dialogHeight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Wrap(
                            direction: Axis.horizontal,
                            alignment: WrapAlignment.start,
                            spacing: 10,
                            runSpacing: 5,
                            children: [
                              _buildColorOption(
                                  context, ScheduleColorType.RED_COLOR,
                                  currentColor, onColorChanged),
                              _buildColorOption(
                                  context, ScheduleColorType.ORANGE_COLOR,
                                  currentColor, onColorChanged),
                              _buildColorOption(
                                  context, ScheduleColorType.YELLOW_COLOR,
                                  currentColor, onColorChanged),
                              _buildColorOption(
                                  context, ScheduleColorType.GREEN_COLOR,
                                  currentColor, onColorChanged),
                              _buildColorOption(
                                  context, ScheduleColorType.BLUE_COLOR,
                                  currentColor, onColorChanged),
                              _buildColorOption(
                                  context, ScheduleColorType.NAVY_COLOR,
                                  currentColor, onColorChanged),
                              _buildColorOption(
                                  context, ScheduleColorType.PURPLE_COLOR,
                                  currentColor, onColorChanged),
                              _buildColorOption(
                                  context, ScheduleColorType.BLACK_COLOR,
                                  currentColor, onColorChanged),
                            ],
                          ),
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
    }else{
      print("RenderBox is null.");
    }
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