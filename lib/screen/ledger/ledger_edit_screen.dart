import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/ledger_dao.dart';
import 'package:woo_yeon_hi/enums.dart';
import 'package:woo_yeon_hi/model/ledger_model.dart';
import 'package:woo_yeon_hi/provider/ledger_provider.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';
import 'package:woo_yeon_hi/style/text_style.dart';
import 'package:woo_yeon_hi/widget/ledger/ledger_dialog.dart';
import 'package:woo_yeon_hi/widget/ledger/ledger_top_app_bar.dart';

import '../../dialogs.dart';
import '../../provider/login_register_provider.dart';
import '../../utils.dart';

class LedgerEditScreen extends StatefulWidget {
  //const LedgerEditScreen({super.key});
  Ledger ledger;

  LedgerEditScreen(this.ledger, {super.key});

  @override
  State<LedgerEditScreen> createState() => _LedgerEditScreenState();
}

class _LedgerEditScreenState extends State<LedgerEditScreen> {
  final List<Map<String, String>> categoryList = [
    {'name': '식비', 'path': 'lib/assets/icons/spoon_fork.svg'},
    {'name': '카페', 'path': 'lib/assets/icons/coffee_cup.svg'},
    {'name': '교통', 'path': 'lib/assets/icons/bus.svg'},
    {'name': '쇼핑', 'path': 'lib/assets/icons/shopping_cart.svg'},
    {'name': '문화', 'path': 'lib/assets/icons/culture_popcorn.svg'},
    {'name': '취미', 'path': 'lib/assets/icons/hobby_puzzle.svg'},
    {'name': '데이트', 'path': 'lib/assets/icons/lover.svg'},
    {'name': '오락', 'path': 'lib/assets/icons/game.svg'},
    {'name': '여행', 'path': 'lib/assets/icons/travel.svg'},
    {'name': '주거', 'path': 'lib/assets/icons/maintain_home.svg'},
    {'name': '생활', 'path': 'lib/assets/icons/life_leaf.svg'},
    {'name': '기타', 'path': 'lib/assets/icons/etc_more.svg'},
    {'name': '입금', 'path': 'lib/assets/icons/money_deposit.svg'},
    {'name': '부수입', 'path': 'lib/assets/icons/income_add.svg'},
    {'name': '보너스', 'path': 'lib/assets/icons/income_bonus.svg'},
    {'name': '기타', 'path': 'lib/assets/icons/etc_more.svg'},
  ];

  // 인스턴스 생성 (dao, 텍스트필드)
  LedgerDao ledgerDao = LedgerDao();
  final _priceFocusNode = FocusNode();
  final _titleFocusNode = FocusNode();

  // 날짜 설정
  late DateTime _dateSettingSave;

  // DateTime _dateModifySave = DateTime.now();
  // 날짜 포맷팅 변환 용도
  late String _dateSettingSave2;
  late String formatDateString;

  // 요일 변환
  String _getWeekday(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }

  // 날짜 포맷팅
  String formatLedgerDate(DateTime ledgerDate) {
    try {
      DateTime dateTime = ledgerDate;
      String formattedDate =
          DateFormat('yyyy. M. d.(E) HH:mm', 'ko').format(dateTime);
      print('포맷 확인: $formattedDate');
      return formattedDate;
    } catch (e) {
      // 유효하지 않은 날짜 형식일 경우
      print('날짜 포맷 오류: $e');
      return 'Invalid Date';
    }
  }

  // 지출, 수입 버튼 상태
  final List<bool> _selectTypeState = [true, false];
  final List<bool> _selectTypeState2 = [false, true];

  // 가계부 타입 버튼
  late bool _ledgerTypeButton;

  // 현재 선택된 카테고리 항목의 인덱스 변수
  int _selectedValue = 0;

  // GlobalKey
  final _formKey = GlobalKey<FormState>();

  // 각 입력 필드별 Key
  final _priceKey = GlobalKey<FormFieldState>();
  final _titleKey = GlobalKey<FormFieldState>();
  final _memoKey = GlobalKey<FormFieldState>();

  // 입력 요소들과 연결될 컨트롤러
  TextEditingController priceController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController memoController = TextEditingController();

  // // GlobalKey를 사용하여 2개의 필드 유효성 검사
  // bool validateFieldsCheck() {
  //   return _titleKey.currentState!.validate() &
  //   _priceKey.currentState!.validate();
  // }

  // 제목과 내용, 이미지가 다 작성되었는지 검사합니다.
  int validateFieldsCheck() {
    //금액 입력 체크
    if (priceController.text.isEmpty) {
      return 1;
    }
    //내역 이름 입력 체크
    else if (titleController.text.isEmpty) {
      return 2;
    }
    //정상인 경우
    else {
      return 0;
    }
  }

  bool isModifiedCheck() {
    if(_dateSettingSave != DateTime.parse(widget.ledger.ledgerDate) || int.tryParse(priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) != widget.ledger.ledgerAmount
        || titleController.text != widget.ledger.ledgerTitle || LedgerCategory.fromValue(_selectedValue) != widget.ledger.ledgerCategory
        || memoController.text != widget.ledger.ledgerMemo) {
      print("!!: ${_dateSettingSave}");
      print("!!: ${DateTime.parse(widget.ledger.ledgerDate)}");
      print("@@: ${priceController.text}");
      print("@@: ${widget.ledger.ledgerAmount.toString()}");
      print("##: ${titleController.text}");
      print("##: ${widget.ledger.ledgerTitle}");
      print("%%: ${LedgerCategory.fromValue(_selectedValue)}");
      print("%%: ${widget.ledger.ledgerCategory}");
      print("^^: ${memoController.text}");
      print("^^: ${widget.ledger.ledgerMemo}");
      return true;
    } else{
      return false;
    }
  }

  // // 최초 오류 메시지 false (유효성 검사)
  // bool _showErrorMessages = false;

  // DatePicker 기능
  void _showDateTimePickerEdit() {
    picker.DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        minTime: stringToDate(
            Provider.of<UserProvider>(context, listen: false).loveDday),
        maxTime: DateTime.now().add(const Duration(seconds: 1)),
        onConfirm: (date) {
      setState(() {
        // 보여주기 용도
        formatDateString =
            '${date.year}. ${date.month}. ${date.day}.\(${_getWeekday(date.weekday)}\) ${date.hour}:${date.minute}';
        // 저장 용도
        _dateSettingSave = date;
      });
    },
        currentTime: _dateSettingSave,
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
              fontFamily: FontFamily.mapleStoryLight),
        ));
  }

  void _formatNumber() {
    // 숫자가 아닌 문자를 모두 제거 (쉼표 제외).
    String text = priceController.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 텍스트가 비어 있으면 컨트롤러 값을 빈 텍스트로 설정하고 커서 위치를 재설정한다.
    if (text.isEmpty) {
      priceController.value = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      return;
    }

    // 숫자를 쉼표로 형식 지정 (텍스트를 정수 값으로 구문 분석한다.)
    int value = int.tryParse(text) ?? 0;

    // NumberFormat을 사용하여 쉼표로 숫자 형식 지정
    final formatter = NumberFormat('#,###');
    String formatted = formatter.format(value);

    // 문자 요소 뒤에 "원" 붙이기
    priceController.value = TextEditingValue(
      text: '$formatted 원',
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  void initState() {
    super.initState();
    // 사용 날짜 가져오기
    _dateSettingSave2 =
        widget.ledger.ledgerDate; // ex: 2024-06-21T10:40:22.967776
    // 데이터 픽커에 맞게 변환
    _dateSettingSave =
        DateTime.parse(_dateSettingSave2); // ex: 2024-06-21 10:40:22.967776

    // 숫자를 쉼표로 형식 지정 (텍스트를 정수 값으로 구문 분석한다.)
    int value = int.tryParse(widget.ledger.ledgerAmount.toString()) ?? 0;

    // NumberFormat을 사용하여 쉼표로 숫자 형식 지정
    final formatter = NumberFormat('#,###');
    String formatted = formatter.format(value);

    // 문자 요소 뒤에 "원" 붙이기
    priceController.value = TextEditingValue(
      text: '$formatted 원',
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    // 내역 이름 가져오기
    titleController = TextEditingController(text: widget.ledger.ledgerTitle);
    // 메모 가져오기
    memoController = TextEditingController(text: widget.ledger.ledgerMemo);

    // 텍스트 변경 시 숫자 형식을 지정하기 위해 컨트롤러에 리스너를 추가
    priceController.addListener(_formatNumber);

    // 가계부 타입 가져오기
    _ledgerTypeButton = widget.ledger.ledgerType.type == 0
        ? _selectTypeState[0]
        : _selectTypeState[1];

    // 가계부 카테고리 가져오기
    _selectedValue = widget.ledger.ledgerCategory.number;
  }

  @override
  void dispose() {
    // 컨트롤러를 제거할 때 리스너를 제거
    priceController.removeListener(_formatNumber);
    // 컨트롤러를 제거 하여 리소스 확보
    priceController.dispose();
    titleController.dispose();
    memoController.dispose();
    _priceFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 카테고리에 필요한 항목만 필터링
    List<Map<String, String>> displayCategory = _ledgerTypeButton
        ? categoryList.sublist(0, 12) // 지출 항목
        : categoryList.sublist(12, 16); // 수입 항목

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          appBar: LedgerTopAppBar(
            title: '가계부 수정',
            leading: IconButton(
              onPressed: () {
                if (isModifiedCheck()) {
                  dialogTitleWithContent(
                      context, "가계부 수정 나가기", "수정된 내용은 저장되지 않습니다.", () {
                    Navigator.pop(context, false);
                  }, () {
                    Navigator.pop(context, true);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      Navigator.of(context).pop();
                    });
                  });
                  // Navigator.popUntil(context, (route) => route.isFirst);
                } else {
                  Navigator.pop(context);
                }
              },
              icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
            ),
          ),
          // 전체 배경색
          backgroundColor: ColorFamily.cream,
          body: SizedBox(
            // width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //날짜 부분
                  InkWell(
                    // 클릭 제스처 투명
                    splashColor: Colors.transparent,
                    onTap: () {
                      _showDateTimePickerEdit();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          formatLedgerDate(_dateSettingSave),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14,
                              fontFamily: FontFamily.mapleStoryLight,
                              color: ColorFamily.gray),
                        ),
                        const SizedBox(width: 7),
                        SvgPicture.asset('lib/assets/icons/calendar.svg',
                            colorFilter: const ColorFilter.mode(
                                ColorFamily.gray, BlendMode.srcIn)),
                      ],
                    ),
                  ),

                  //금액 부분
                  TextFormField(
                    textAlign: TextAlign.center,
                    key: _priceKey,
                    controller: priceController,
                    style: const TextStyle(
                        color: ColorFamily.black,
                        fontSize: 30,
                        fontFamily: FontFamily.mapleStoryLight),
                    // 커서 숨김
                    showCursor: false,
                    cursorColor: ColorFamily.black,
                    // 키보드 타입
                    keyboardType: TextInputType.number,
                    focusNode: _priceFocusNode,
                    maxLines: 1,
                    maxLength: 7,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      // 텍스트 제한 수 표시 숨김
                      counterText: '',
                      hintText: '금액을 입력하세요',
                      hintStyle: TextStyle(
                        color: ColorFamily.gray,
                        fontSize: 20,
                        fontFamily: FontFamily.mapleStoryLight,
                      ),
                      errorStyle: TextStyle(
                        color: ColorFamily.pink,
                        fontSize: 14,
                        fontFamily: FontFamily.mapleStoryLight,
                      ),
                    ),
                    inputFormatters: [
                      // 숫자만 입력 할 수 있도록.
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    // // 유효성 검사를 수행
                    // autovalidateMode: _showErrorMessages
                    //     ? AutovalidateMode.always
                    //     : AutovalidateMode.disabled,
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     showBlackToast('금액을 입력해주세요');
                    //   }
                    //   return null;
                    // },
                    onChanged: (value) {
                      _formatNumber();
                    },
                  ),

                  // 탭 조정 (가계부 타입)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 50),
                        child: ToggleButtons(
                          isSelected: _ledgerTypeButton
                              ? _selectTypeState
                              : _selectTypeState2,
                          constraints: const BoxConstraints(
                              minWidth: 90.0, minHeight: 40.0),
                          borderRadius: BorderRadius.circular(5.0),
                          // 기본 배경색
                          color: ColorFamily.white,
                          // 클릭 된 배경색
                          fillColor: _ledgerTypeButton
                              ? ColorFamily.pink
                              : ColorFamily.green,
                          onPressed: (int index) {
                            setState(() {
                              for (int buttonIndex = 0;
                                  buttonIndex < _selectTypeState.length;
                                  buttonIndex++) {
                                if (buttonIndex == index) {
                                  _selectTypeState[buttonIndex] = true;
                                } else {
                                  _selectTypeState[buttonIndex] = false;
                                }
                              }
                              // 가계부 타입 변경
                              _ledgerTypeButton = index == 0;

                              // 가계부 타입 변경에 따른 인덱스 값 조정
                              if (_selectedValue < 12) {
                                // 현재 지출 타입의 카테고리를 선택 중이였다면, 12로 조정
                                _selectedValue = 12;
                              } else {
                                // 현재 수입 타입의 카테고리를 선택 중이였다면, 0로 조정
                                _selectedValue = 0;
                              }
                            });
                          },
                          children: [
                            Text('지출',
                                style: TextStyle(
                                    color: _ledgerTypeButton
                                        ? ColorFamily.black
                                        : ColorFamily.gray,
                                    fontSize: 14,
                                    fontFamily: FontFamily.mapleStoryLight)),
                            Text('수입',
                                style: TextStyle(
                                    color: _ledgerTypeButton
                                        ? ColorFamily.gray
                                        : ColorFamily.black,
                                    fontSize: 14,
                                    fontFamily: FontFamily.mapleStoryLight)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Container(
                    color: ColorFamily.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('내역',
                                  style: TextStyle(
                                      color: ColorFamily.black,
                                      fontSize: 20,
                                      fontFamily: FontFamily.mapleStoryLight)),
                              TextFormField(
                                key: _titleKey,
                                controller: titleController,
                                cursorColor: ColorFamily.black,
                                maxLength: 20,
                                maxLines: 1,
                                focusNode: _titleFocusNode,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                    color: ColorFamily.black,
                                    fontSize: 14,
                                    fontFamily: FontFamily.mapleStoryLight),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                  hintText: '20자 이내로 입력해주세요',
                                  hintMaxLines: 1,
                                  hintStyle: TextStyle(
                                    color: ColorFamily.gray,
                                    fontSize: 14,
                                    fontFamily: FontFamily.mapleStoryLight,
                                    decorationThickness: 0,
                                  ),
                                  errorMaxLines: 1,
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontFamily: FontFamily.mapleStoryLight,
                                  ),
                                ),
                                // 유효성 검사를 수행
                                // autovalidateMode: _showErrorMessages
                                //     ? AutovalidateMode.always
                                //     : AutovalidateMode.disabled,
                                // validator: (value) {
                                //   if (value == null || value.isEmpty) {
                                //     showBlackToast('내역을 입력해주세요');
                                //   }
                                //   return null;
                                // },
                              ),
                              const SizedBox(height: 30),
                              const Text('카테고리',
                                  style: TextStyle(
                                      color: ColorFamily.black,
                                      fontSize: 20,
                                      fontFamily: FontFamily.mapleStoryLight)),
                              const SizedBox(height: 10),
                              Container(
                                //decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.red)),
                                child: gridViewCategory(displayCategory),
                              ),
                              const SizedBox(height: 30),
                              const Text('메모',
                                  style: TextStyle(
                                      color: ColorFamily.black,
                                      fontSize: 20,
                                      fontFamily: FontFamily.mapleStoryLight)),
                              const SizedBox(height: 10),
                              TextFormField(
                                key: _memoKey,
                                controller: memoController,
                                maxLength: 50,
                                maxLines: 5,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                    color: ColorFamily.black,
                                    fontSize: 14,
                                    fontFamily: FontFamily.mapleStoryLight),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                  hintText: '메모를 입력하세요',
                                  hintMaxLines: 1,
                                  hintStyle: TextStyle(
                                    color: ColorFamily.gray,
                                    fontSize: 14,
                                    fontFamily: FontFamily.mapleStoryLight,
                                    decorationThickness: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          color: ColorFamily.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 취소 버튼
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: Material(
                                    color: ColorFamily.white,
                                    elevation: 1,
                                    shadowColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          color: ColorFamily.gray, width: 0.1),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                    if(isModifiedCheck()){
                                        dialogTitleWithContent(
                                            context,
                                            "가계부 수정 나가기",
                                            "수정된 내용은 저장되지 않습니다.",
                                                () {Navigator.pop(context, false);},
                                                () {Navigator.pop(context, true);
                                            Future.delayed(const Duration(milliseconds: 100), () {Navigator.of(context).pop();});}
                                        );
                                    } else{
                                      Navigator.pop(context);
                                    }
                                      },
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: Container(
                                        height: 40,
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "취소",
                                          style:
                                              TextStyleFamily.normalTextStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // 취소, 수정 버튼의 간격
                              const SizedBox(width: 20),

                              // 수정 버튼
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: Material(
                                    color: ColorFamily.beige,
                                    elevation: 1,
                                    shadowColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        final ledgerProvider = Provider.of<LedgerProvider>(context, listen: false);

                                        if(validateFieldsCheck()==0){
                                          _priceKey.currentState!.save();

                                          // ledgerAmount를 정수로 변환
                                          String cleanedValue =
                                              priceController.text.replaceAll(
                                                  RegExp(r'[^0-9]'), '');
                                          int _priceController = int.tryParse(cleanedValue) ?? 0;

                                          // 수정 로직 넣기.
                                          Ledger updatedLedger = Ledger(
                                            ledgerIdx: widget.ledger.ledgerIdx,
                                            ledgerUserIdx:
                                                widget.ledger.ledgerUserIdx,
                                            ledgerDate: _dateSettingSave
                                                .toIso8601String(),
                                            ledgerAmount: _priceController,
                                            ledgerType: _ledgerTypeButton
                                                ? LedgerType.EXPENDITURE
                                                : LedgerType.INCOME,
                                            ledgerTitle: titleController.text,
                                            ledgerCategory:
                                                LedgerCategory.fromValue(
                                                    _selectedValue),
                                            ledgerMemo: memoController.text,
                                            ledgerState:
                                                widget.ledger.ledgerState,
                                            //ledgerModifyDate: DateTime.now().toIso8601String(),
                                            // ledgerModifyDate: formatLedgerDate(_dateModifySave),
                                          );

                                          // Ledger 업데이트
                                          await ledgerProvider.updateLedger(
                                              updatedLedger, context);

                                          Navigator.pop(context);
                                          showPinkSnackBar(
                                              context, "가계부 항목이 수정되었습니다");
                                        } else if(validateFieldsCheck()==1) {
                                            _priceFocusNode.requestFocus();
                                            showBlackToast("금액을 입력해주세요");
                                          } else {
                                            _titleFocusNode.requestFocus();
                                            showBlackToast("내역을 입력해주세요");
                                          }
                                      },
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: Container(
                                        height: 40,
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "수정",
                                          style:
                                              TextStyleFamily.normalTextStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  // 카테고리 정의
  Widget gridViewCategory(List<Map<String, String>> displayCategory) {
    return SingleChildScrollView(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        // GridView의 자체 스크롤을 비활성화
        shrinkWrap: true,
        // GridView가 자식의 크기에 맞추어 크기를 조정
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // 가로로 4개씩 배치
          crossAxisSpacing: 20.0, // 그리드 사이의 좌우 간격
          mainAxisSpacing: 20.0, // 그리드 사이의 수직 간격
        ),
        itemCount: displayCategory.length,
        itemBuilder: (context, index) {
          String? name = displayCategory[index]['name'];
          String? path = displayCategory[index]['path'];

          // Null 체크 필요
          if (path == null || name == null) {
            return const Text('카테고리 파일이 비어있습니다.');
          }

          // 커스텀 라디오 버튼 형태
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedValue = _ledgerTypeButton ? index : index + 12;
              });
            },
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        _selectedValue == (index + (_ledgerTypeButton ? 0 : 12))
                            ? _selectTypeState[0]
                                ? ColorFamily.pink
                                : ColorFamily.green
                            : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(path),
                    const SizedBox(height: 10.0),
                    Text(
                      name,
                      style: const TextStyle(
                          color: ColorFamily.black,
                          fontSize: 10,
                          fontFamily: FontFamily.mapleStoryLight),
                    ),
                  ],
                )),
          );
        },
      ),
    );
  }
}
