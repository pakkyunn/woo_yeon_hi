import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:woo_yeon_hi/dao/diary_dao.dart';
import 'package:woo_yeon_hi/provider/login_register_provider.dart';

import '../enums.dart';
import '../model/diary_model.dart';
import '../utils.dart';

// 교환일기 메인 프로바이더
class DiaryProvider extends ChangeNotifier{
  List<String> _editorType = ["전체", "나", "상대방"];
  List<bool> _isSelected_editor = [true, false, false];
  List<String> _sortType = ["최신순", "오래된순"];
  List<bool> _isSelected_sort = [true, false];
  String _startPeriod = "";
  String _endPeriod = "";
  final TextEditingController _startPeriodController = TextEditingController(text: "");
  final TextEditingController _endPeriodController = TextEditingController(text: "");
  List<String> _filterList = ["전체", "최신순"];

  int? _diaryUserIdx;
  List<Diary> _diaryList = [];
  Future<List<Diary>>? diaryFuture;

  bool _isLoading = false;
  String _errorMessage = '';

  List<String> get editorType => _editorType;
  String get startPeriod => _startPeriod;
  String get endPeriod => _endPeriod;
  TextEditingController get startPeriodController => _startPeriodController;
  TextEditingController get endPeriodController => _endPeriodController;
  List<String> get sortType => _sortType;
  List<bool> get isSelected_editor => _isSelected_editor;
  List<bool> get isSelected_sort => _isSelected_sort;
  List<String> get filterList => _filterList;
  List<Diary> get diaryList => _diaryList;
  int? get diaryUserIdx => _diaryUserIdx;


  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;


  Future<List<Diary>> getDiary(BuildContext context) async {
    _diaryList.clear();

    int user_idx = Provider.of<UserProvider>(context, listen: false).userIdx;
    int lover_idx = Provider.of<UserProvider>(context, listen: false).loverIdx;

    int filter_editor = _isSelected_editor.indexWhere((element) => element);
    int filter_sort = _isSelected_sort.indexWhere((element) => element);

    String filter_start = _startPeriod;
    String filter_end = _endPeriod;

    try {
      if (filter_start.isNotEmpty && filter_end.isNotEmpty) {
        DateTime pd1 = stringToDate(_startPeriod);
        DateTime pd2 = stringToDate(_endPeriod);
        if (pd1.compareTo(pd2) < 0) {
          filter_start = _startPeriod;
          filter_end = _endPeriod;
        } else {
          filter_start = _endPeriod;
          filter_end = _startPeriod;
        }
      }

      var mapList = await getDiaryData(
          user_idx, lover_idx, filter_editor, filter_sort, filter_start,
          filter_end);

      for (var mapData in mapList) {
        _diaryList.add(Diary.fromData(mapData));
      }

      return _diaryList;

    } catch(error) {
      _isLoading = false;
      _errorMessage = '데이터를 불러오는 중 문제가 발생했습니다.';
      notifyListeners();

      return [];
    }
  }

  Future<void> fetchDiaries(BuildContext context) async {
    // 데이터 가져오기
    diaryFuture = getDiary(context);
    _diaryList = await diaryFuture!;
    notifyListeners();
  }

  // 교환일기 작성 차례를 확인하는 메서드
  bool isPersonToWrite (BuildContext context) {
    int loverIdx = Provider.of<UserProvider>(context, listen: false).loverIdx;

    List<Diary> sortedList = _diaryList
        .toList() // 원본 리스트를 복사
      ..sort((a, b) {
        // "_" 이후의 날짜 문자열 추출
        DateTime dateA = DateTime.parse(a.diaryImagePath.split('_')[1]);
        DateTime dateB = DateTime.parse(b.diaryImagePath.split('_')[1]);

        return dateB.compareTo(dateA); // 내림차순 정렬
      });


    // 가장 최근 일기의 작성 유저가 연인일 경우
    if(sortedList[0].diaryUserIdx == loverIdx){
      return true;
    } else {
      return false;
    }
  }


  void setUserIdx(int? idx){
    _diaryUserIdx = idx;
  }

  void setStartPeriod(String date){
    _startPeriod = date;
  }

  void setEndPeriod(String date){
    _endPeriod = date;
  }

  void setStartControllerText(String text){
    _startPeriodController.text = text;
  }

  void setEndControllerText(String text){
    _endPeriodController.text = text;
  }

  void setSelected_editor(List<bool> values){
    _isSelected_editor = values;
  }

  void setSelected_sort(List<bool> values){
    _isSelected_sort = values;
  }

  void removeFilterListByIndex(int index){
    _filterList.removeAt(index);
    notifyListeners();
  }

  void updateSelected_editor(int index, bool value){
    _isSelected_editor[index] = value;
  }

  void updateSelected_sort(int index, bool value){
    _isSelected_sort[index] = value;
  }

  void setFilterList(List<String> value){
    _filterList = value;
  }

  void addFilterListItem(String item){
    _filterList.add(item);
  }

  void providerNotify(){
    notifyListeners();
  }
}

// 교환일기 작성 프로바이더
class DiaryEditProvider extends ChangeNotifier{
  final TextEditingController _titleTextEditController = TextEditingController();
  final TextEditingController _contentTextEditController = TextEditingController();
  XFile? _image;
  int _weatherType = 0;

  TextEditingController get titleTextEditController => _titleTextEditController;
  TextEditingController get contentTextEditController => _contentTextEditController;
  XFile? get image => _image;
  int get weatherType => _weatherType;

  // 제목과 내용, 이미지 중 하나라도 작성되었는지 검사합니다.
  bool checkProvider(){
    if(titleTextEditController.text.isNotEmpty || contentTextEditController.text.isNotEmpty || image != null){
      return true;
    }else{
      return false;
    }
  }

  // 제목과 내용, 이미지가 다 작성되었는지 검사합니다.
  int checkValid(){
    //썸네일 체크
    if(image == null){
      return 1;
    }
    //내용 체크
    else if(titleTextEditController.text.isEmpty || contentTextEditController.text.isEmpty){
      return 2;
    }
    else{
      return 0;
    }
  }

  void resetProvider(){
    _titleTextEditController.clear();
    _contentTextEditController.clear();
    _image = null;
    _weatherType = 0;
  }

  void setTitleController(String title){
    _titleTextEditController.text = title;
    notifyListeners();
  }

  void setContentController(String content){
    _contentTextEditController.text = content;
    notifyListeners();
  }

  void setImage(XFile? imagePath){
    _image = imagePath;
    notifyListeners();
  }

  void setWeather(int type){
    _weatherType = type;
    notifyListeners();
  }

  void providerNotify(){
    notifyListeners();
  }
}