import 'package:flutter/cupertino.dart';

import '../dao/schedule_dao.dart';

class ScheduleProvider extends ChangeNotifier {
  final TextEditingController _titleController = TextEditingController(); // 일정 제목
  final TextEditingController _memoController = TextEditingController();  // 일정 메모

  TextEditingController get titleController => _titleController;
  TextEditingController get memoController => _memoController;

  void setTitleController(String title){
    _titleController.text = title;
    notifyListeners();
  }

  void setMemoController(String memo){
    _memoController.text = memo;
    notifyListeners();
  }

  void providerNotify(){
    notifyListeners();
  }

}

class HomeCalendarProvider extends ChangeNotifier {
  DateTime _selectedDay = DateTime.now();
  DateTime get selectedDay => _selectedDay;

  DateTime _focusedDay = DateTime.now();
  DateTime get focusedDay => _focusedDay;

  List<List<Map<String, dynamic>>> _scheduleList = [];
  List<List<Map<String, dynamic>>> get scheduleList => _scheduleList;

  int _listIndex = 0;
  int get listIndex => _listIndex;

  void setSelectedDay(DateTime selectedDay){
    _selectedDay = selectedDay;
    notifyListeners();
  }

  void setFocusedDay(DateTime focusedDay){
    _focusedDay = focusedDay;
    notifyListeners();
  }

  void setScheduleList(List<List<Map<String, dynamic>>> scheduleList){
    _scheduleList = scheduleList;
    notifyListeners();
  }

  void setListIndex() {
    _listIndex = selectedDay.day - 1;

    notifyListeners();
  }
}

class CalendarScreenProvider extends ChangeNotifier {
  DateTime _selectedDay = DateTime.now();
  DateTime get selectedDay => _selectedDay;

  DateTime _focusedDay = DateTime.now();
  DateTime get focusedDay => _focusedDay;

  void setSelectedDay(DateTime selectedDay){
    _selectedDay = selectedDay;
    notifyListeners();
  }
  void setFocusedDay(DateTime focusedDay){
    _focusedDay = focusedDay;
    notifyListeners();
  }
}

