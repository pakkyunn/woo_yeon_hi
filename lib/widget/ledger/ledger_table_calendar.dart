import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:woo_yeon_hi/enums.dart';
import 'package:woo_yeon_hi/model/ledger_model.dart';
import 'package:woo_yeon_hi/provider/ledger_provider.dart';
import 'package:woo_yeon_hi/provider/login_register_provider.dart';
import 'package:woo_yeon_hi/screen/ledger/ledger_detail_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';
import 'package:woo_yeon_hi/utils.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

import '../../dao/ledger_dao.dart';
import '../../screen/ledger/ledger_write_screen.dart';
import '../../style/text_style.dart';

class LedgerTableCalendar extends StatefulWidget {
  const LedgerTableCalendar({super.key});

  @override
  State<LedgerTableCalendar> createState() => _LedgerTableCalendarState();
}

class _LedgerTableCalendarState extends State<LedgerTableCalendar> {

  // 캘린더에 보여주는 지출, 수입 총액
  Map<DateTime, List<Ledger>> _groupEvents(List<Ledger> ledgers) {
    Map<DateTime, List<Ledger>> _showMainEvents = {};
    for (var ledger in ledgers) {
      // ledger_state가 0인 데이터만 조회하여 보여준다
      if (ledger.ledgerState.state == LedgerState.STATE_NORMAL.state) {
        DateTime date = DateTime.parse(ledger.ledgerDate).toLocal();
        DateTime day = DateTime(date.year, date.month, date.day);
        if (_showMainEvents[day] == null) {
          _showMainEvents[day] = [];
        }
        _showMainEvents[day]!.add(ledger);
      }
    }
    return _showMainEvents;
  }

  // ledgerType(지출, 수입)에 따라 총 금액을 계산
  Map<String, int> calculateTotalMoney(List<Ledger> ledgers) {
    int expenditure = 0;
    int income = 0;

    for (var ledger in ledgers) {
      if (ledger.ledgerType.type == 0) {
        expenditure += ledger.ledgerAmount;
      } else if (ledger.ledgerType.type == 1) {
        income += ledger.ledgerAmount;
      }
    }
    return {
      'expenditure': expenditure,
      'income': income,
    };
  }

  // 캘린더 이벤트 텍스트에 콤마
  String formatNumber(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  String cleanCurrencyString(String value) {
    // 문자열에서 숫자만 추출
    final cleanedString = value.replaceAll(RegExp(r'[^0-9]'), '');
    // 문자열을 정수로 변환
    return cleanedString;
  }

  int sumCurrencyStrings(List<String> values) {
    int total = 0;

    for (var value in values) {
      String cleanedValue = cleanCurrencyString(value);
      if (cleanedValue.isNotEmpty) {
        total += int.parse(cleanedValue);
      }
    }
    return total;
  }

  // 이벤트 리스트의 카테고리 아이콘 정의
  String getIconPath(LedgerCategory category) {
    const categoryIconMap = {
      LedgerCategory.FOOD_EXPENSES: 'lib/assets/icons/spoon_fork.svg',
      LedgerCategory.CAFFE: 'lib/assets/icons/coffee_cup.svg',
      LedgerCategory.PUBLIC_TRANSPORT: 'lib/assets/icons/bus.svg',
      LedgerCategory.SHOPPING: 'lib/assets/icons/shopping_cart.svg',
      LedgerCategory.CULTURE: 'lib/assets/icons/culture_popcorn.svg',
      LedgerCategory.HOBBY: 'lib/assets/icons/hobby_puzzle.svg',
      LedgerCategory.DATE_WITH: 'lib/assets/icons/lover.svg',
      LedgerCategory.GAME: 'lib/assets/icons/game.svg',
      LedgerCategory.TRAVEL: 'lib/assets/icons/travel.svg',
      LedgerCategory.DWELLING: 'lib/assets/icons/maintain_home.svg',
      LedgerCategory.LIFE: 'lib/assets/icons/life_leaf.svg',
      LedgerCategory.ETC: 'lib/assets/icons/etc_more.svg',
      LedgerCategory.DEPOSIT: 'lib/assets/icons/money_deposit.svg',
      LedgerCategory.INCOME_ADD: 'lib/assets/icons/income_add.svg',
      LedgerCategory.INCOME_BONUS: 'lib/assets/icons/income_bonus.svg',
      LedgerCategory.INCOME_ETC: 'lib/assets/icons/etc_more.svg',
    };

    return categoryIconMap[category] ?? 'lib/assets/icons/etc_more.svg';
  }

  bool isToday(DateTime date) {
    return date.day == DateTime.now().day;
  }

  bool isSaturday(DateTime day) {
    return day.weekday == DateTime.saturday;
  }

  bool isWeekend(DateTime day) {
    return day.weekday == DateTime.sunday;
  }

  bool _dataLoaded = false;

  Future<void> _asyncData(LedgerProvider provider) async {
    await provider.carouselSliderInitialData();
    await provider.updateTextsOnMonthChange(provider.focusedDay);
    await provider.fetchLedgers(); // 초기 데이터를 가져옴
    setState(() {
      _dataLoaded = true; // 데이터가 로드되었음을 표시
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LedgerProvider>(builder: (context, ledgerProvider, child) {
      // 캘린더에 보여 줄 이벤트 (지출, 수입 내역)
      Map<DateTime, List<Ledger>> _showMainEvents =
          _groupEvents(ledgerProvider.ledgers);

      // 선택된 날짜의 이벤트를 필터링 (상세 이벤트 리스트)
      List<Ledger> selectedDayLedgers = ledgerProvider.ledgers
          .where((ledger) =>
              ledger.ledgerState.state == LedgerState.STATE_NORMAL.state)
          .where((ledger) =>
              DateTime.parse(ledger.ledgerDate).toLocal().day ==
                  ledgerProvider.selectedDay?.day &&
              DateTime.parse(ledger.ledgerDate).toLocal().month ==
                  ledgerProvider.selectedDay?.month &&
              DateTime.parse(ledger.ledgerDate).toLocal().year ==
                  ledgerProvider.selectedDay?.year)
          .toList();
      // 캘린더 이벤트에 보이는 데이터를 오름차순(ASC)으로 정렬
      selectedDayLedgers.sort((a, b) =>
          DateTime.parse(a.ledgerDate).compareTo(DateTime.parse(b.ledgerDate)));

      // 지출, 수입의 계산 결과
      Map<String, int> totalMoney = calculateTotalMoney(selectedDayLedgers);

      if (!_dataLoaded) {
        // 처음 한 번만 Future를 실행하여 데이터를 불러옴
        _asyncData(ledgerProvider);
      }

      return _dataLoaded
          ? Column(
              children: [
                calendarCustomHeader(),
                TableCalendar(
                  availableGestures: AvailableGestures.horizontalSwipe,
                  firstDay: stringToDate(
                      Provider.of<UserProvider>(context, listen: false)
                          .loveDday),
                  lastDay: DateTime.now(),
                  focusedDay: ledgerProvider.focusedDay,
                  eventLoader: (day) {
                    return _showMainEvents[day] ?? [];
                  },
                  locale: 'ko_KR',
                  daysOfWeekHeight: 40,
                  rowHeight: 80,
                  headerVisible: false,
                  selectedDayPredicate: (day) =>
                      isSameDay(ledgerProvider.selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      final now = DateTime.now();
                      final updatedSelectedDay = DateTime(
                        selectedDay.year,
                        selectedDay.month,
                        selectedDay.day,
                        now.hour,
                        now.minute,
                        now.second,
                      );
                      ledgerProvider.setSelectedDay(updatedSelectedDay);
                      ledgerProvider.setFocusedDay(focusedDay);
                    });
                  },
                  onPageChanged: (focusedDay) {
                    ledgerProvider.setFocusedDay(focusedDay);
                    ledgerProvider.setSelectedDay(null);
                    ledgerProvider
                        .updateTextsOnMonthChange(focusedDay); // 상단 배너 데이터 업데이트
                  },
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: true,
                    markersMaxCount: 0,
                  ),
                  calendarBuilders: CalendarBuilders(
                    // 요일
                    dowBuilder: (context, day) {
                      // if (isWeekend(day)) {
                      //   // DateFormat.E(): 요일
                      //   // DateFormat.d(): 일자
                      //   final text = DateFormat.E('ko').format(day);
                      //   return Padding(
                      //     padding: const EdgeInsets.only(bottom: 10),
                      //     child: Center(
                      //       child: Text(
                      //           text, style: const TextStyle(fontSize: 14, color: Colors.red, fontFamily: FontFamily.mapleStoryBold)
                      //       ),
                      //     ),
                      //   );
                      // } else if (isSaturday(day)) {
                      //   final text = DateFormat.E('ko').format(day);
                      //   return Padding(
                      //     padding: const EdgeInsets.only(bottom: 10),
                      //     child: Center(
                      //       child: Text(
                      //           text, style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontFamily: FontFamily.mapleStoryBold)
                      //       ),
                      //     ),
                      //   );
                      // }
                      // else{
                      final text = DateFormat.E('ko').format(day);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Center(
                          child: Text(text,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: ColorFamily.black,
                                  fontFamily: FontFamily.mapleStoryBold)),
                        ),
                      );
                      //   }
                    },

                    // 범위에 포함 되어 있지 않은 날짜
                    disabledBuilder: (context, day, focusedDay) {
                      return Column(
                        children: [
                          Text('${day.day}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: ColorFamily.gray,
                                  fontFamily: FontFamily.mapleStoryLight)),
                        ],
                      );
                    },

                    // 모든 날짜
                    defaultBuilder: (context, date, focusedDay) {
                      DateTime day = DateTime(date.year, date.month, date.day);
                      List<Ledger> dayEvents = _showMainEvents[day] ?? [];
                      // 지출 총합
                      //int totalMoney = calculateTotalMoney(dayEvents);
                      Map<String, int> dayTotalMoney =
                          calculateTotalMoney(dayEvents);

                      return Column(
                        children: [
                          Text('${day.day}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: ColorFamily.black,
                                  fontFamily: FontFamily.mapleStoryLight)),
                          // 이벤트 목록
                          Container(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  if (dayTotalMoney['expenditure'] != 0)
                                    Text(
                                      '-${formatNumber(dayTotalMoney['expenditure']!)}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.pink,
                                          fontFamily:
                                              FontFamily.mapleStoryLight),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  if (dayTotalMoney['income'] != 0)
                                    Text(
                                      '+${formatNumber(dayTotalMoney['income']!)}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.blueAccent,
                                          fontFamily:
                                              FontFamily.mapleStoryLight),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                ],
                              )),
                        ],
                      );
                    },

                    // 오늘 날짜
                    todayBuilder: (context, date, focusedDay) {
                      DateTime day = DateTime(date.year, date.month, date.day);
                      List<Ledger> dayEvents = _showMainEvents[day] ?? [];
                      Map<String, int> dayTotalMoney =
                          calculateTotalMoney(dayEvents);

                      return Column(
                        children: [
                          Text('${day.day}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: ColorFamily.pink,
                                  fontFamily: FontFamily.mapleStoryBold)),
                          // 이벤트 목록
                          Container(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  if (dayTotalMoney['expenditure'] != 0)
                                    Text(
                                      '-${formatNumber(dayTotalMoney['expenditure']!)}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.pink,
                                          fontFamily:
                                              FontFamily.mapleStoryLight),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  if (dayTotalMoney['income'] != 0)
                                    Text(
                                      '+${formatNumber(dayTotalMoney['income']!)}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.blueAccent,
                                          fontFamily:
                                              FontFamily.mapleStoryLight),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                ],
                              )),
                        ],
                      );
                    },

                    // 선택된 날짜
                    selectedBuilder: (context, date, focusedDay) {
                      DateTime day = DateTime(date.year, date.month, date.day);
                      List<Ledger> dayEvents = _showMainEvents[day] ?? [];
                      Map<String, int> dayTotalMoney =
                          calculateTotalMoney(dayEvents);
                      print('dayTotalMoney: ${dayTotalMoney}');

                      // 이벤트 값 확인
                      print(
                          '선택된 이벤트 확인 Date: $day, Events: $dayEvents, TotalMoney: $totalMoney, dayTotalMoney: $dayTotalMoney');

                      return Column(
                        children: [
                          Container(
                            width: 60,
                            height: 70,
                            decoration: const BoxDecoration(
                                color: Color(0x50FEBE98),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Column(
                              children: [
                                Text(
                                  '${day.day}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: isToday(day)
                                          ? ColorFamily.pink
                                          : ColorFamily.black,
                                      fontFamily: isToday(day)
                                          ? FontFamily.mapleStoryBold
                                          : FontFamily.mapleStoryLight,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                // 이벤트 목록
                                Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        if (dayTotalMoney['expenditure'] != 0)
                                          Text(
                                            '-${formatNumber(dayTotalMoney['expenditure']!)}',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.pink,
                                                fontFamily:
                                                    FontFamily.mapleStoryLight),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        if (dayTotalMoney['income'] != 0)
                                          Text(
                                            '+${formatNumber(dayTotalMoney['income']!)}',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.blueAccent,
                                                fontFamily:
                                                    FontFamily.mapleStoryLight),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                        ],
                      );
                    },

                    // 다른 달의 날짜
                    outsideBuilder: (context, date, focusedDay) {
                      DateTime day = DateTime(date.year, date.month, date.day);
                      List<Ledger> dayEvents = _showMainEvents[day] ?? [];
                      Map<String, int> dayTotalMoney =
                          calculateTotalMoney(dayEvents);

                      return Column(
                        children: [
                          Text('${day.day}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: ColorFamily.gray,
                                  fontFamily: FontFamily.mapleStoryLight,
                                  overflow: TextOverflow.ellipsis)),
                          // 이벤트 목록
                          Container(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  if (dayTotalMoney['expenditure'] != 0)
                                    Text(
                                      '-${formatNumber(dayTotalMoney['expenditure']!)}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.pink,
                                          fontFamily:
                                              FontFamily.mapleStoryLight),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  if (dayTotalMoney['income'] != 0)
                                    Text(
                                      '+${formatNumber(dayTotalMoney['income']!)}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.blueAccent,
                                          fontFamily:
                                              FontFamily.mapleStoryLight),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                ],
                              )),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // 상세 이벤트 항목
                SizedBox(
                  height: 180, //TODO 최대로 표시할 리스트뷰 항목의 개수에 맞추어 높이 지정해둘 것
                  child: ListView.builder(
                    // ListTile의 리스트뷰의 높이를 자식 아이템들의 높이에 맞춰 설정
                    shrinkWrap: true,
                    // ListTile의 리스트뷰 자체의 스크롤을 비활성화
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedDayLedgers.length,
                    itemBuilder: (context, index) {
                      final ledger = selectedDayLedgers[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                        child: Material(
                          color: ColorFamily.white,
                          elevation: 1,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: ColorFamily.white),
                            child: ListTile(
                              leading: SvgPicture.asset(
                                  getIconPath(ledger.ledgerCategory),
                                  width: 24,
                                  height: 24),
                              title: Text(ledger.ledgerTitle,
                                  style: const TextStyle(
                                      color: ColorFamily.black,
                                      fontSize: 14,
                                      fontFamily: FontFamily.mapleStoryLight)),
                              trailing: Text(
                                  '${ledger.ledgerType.type == 0 ? '-' : '+'}${formatNumber(ledger.ledgerAmount)}원',
                                  style: const TextStyle(
                                      color: ColorFamily.black,
                                      fontSize: 10,
                                      fontFamily: FontFamily.mapleStoryLight)),
                              onTap: () {
                                // 날짜만 추출 (예시: "2024-06-11T15:16:00.000" -> "2024-06-11")
                                String dateOnly =
                                    ledger.ledgerDate.split('T')[0];
                                // 날짜에 맞는 데이터로 갱신
                                ledgerProvider.readLedger(dateOnly);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    // 보여질 다음 화면을 설정한다.
                                    builder: (context) => const LedgerDetailScreen()
                                  ),
                                ).then((value) => _asyncData(ledgerProvider));
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 80),
              ],
            )
          : Center(
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.25),
              child: const CircularProgressIndicator(
                color: ColorFamily.pink,
              ),
            ),
          );
    });
  }

  // 커스텀 헤더
  Widget calendarCustomHeader() {
    var ledgerProvider = Provider.of<LedgerProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 20, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 50),
          InkWell(
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            onTap: () {
              picker.DatePicker.showPicker(
                context,
                showTitleActions: true,
                // minTime: DateTime(1900, 1, 1), // 최소 선택 가능한 날짜
                // maxTime: DateTime.now(), // 최대 선택 가능한 날짜
                theme: const picker.DatePickerTheme(
                    titleHeight: 60,
                    containerHeight: 300,
                    itemHeight: 50,
                    headerColor: Colors.white,
                    backgroundColor: Colors.white,
                    itemStyle: TextStyleFamily.smallTitleTextStyle,
                    cancelStyle: TextStyle(
                        color: ColorFamily.black,
                        fontSize: 18,
                        fontFamily: FontFamily.mapleStoryLight),
                    doneStyle: TextStyle(
                        color: ColorFamily.black,
                        fontSize: 18,
                        fontFamily: FontFamily.mapleStoryLight)),
                pickerModel: CustomYearMonthPicker(
                  currentTime: ledgerProvider.focusedDay,
                  minTime: stringToDate(
                      Provider.of<UserProvider>(context, listen: false)
                          .loveDday),
                  maxTime: DateTime.now(),
                ),
                onConfirm: (date) {
                  ledgerProvider
                      .setFocusedDay(DateTime(date.year, date.month, 1));
                },
                locale: picker.LocaleType.ko,
              );
            },
            child: Row(
              children: [
                Text(
                  DateFormat.yMMM('ko').format(ledgerProvider.focusedDay),
                  style: const TextStyle(
                      fontSize: 20,
                      color: ColorFamily.black,
                      fontFamily: FontFamily.mapleStoryBold),
                ),
                // 제목 옆에 아이콘 추가
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                      child: SvgPicture.asset(
                          'lib/assets/icons/under_triangle.svg')),
                )
              ],
            ),
          ),
          InkWell(
              splashColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              onTap: () {
                // showDialog(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return LedgerDialog('LedgerScreen', '미등록 거래내역이 있습니다.', '이동하시겠습니까?');
                //     });
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LedgerWriteScreen(
                                ledgerProvider.selectedDay ?? DateTime.now())))
                    .then((value) => _asyncData(ledgerProvider));
              },
              child: SizedBox(
                  width: 30,
                  height: 30,
                  child: SvgPicture.asset('lib/assets/icons/add.svg')))
        ],
      ),
    );
  }
}

// DatePicker 커스텀 class
class CustomYearMonthPicker extends picker.DatePickerModel {
  CustomYearMonthPicker({super.currentTime, super.minTime, super.maxTime})
      : super(locale: picker.LocaleType.ko);

  @override
  String? rightStringAtIndex(int index) {
    // Day는 숨김 처리
    return null;
  }

  @override
  List<int> layoutProportions() {
    // Year와 Month의 비율만 설정, Day는 비율 0으로 숨김
    return [3, 2, 0];
  }
}
