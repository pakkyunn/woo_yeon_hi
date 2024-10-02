import 'package:flutter/cupertino.dart';

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

  void setSelectedDay(DateTime selectedDay){
    _selectedDay = selectedDay;
    notifyListeners();
  }
  void setFocusedDay(DateTime focusedDay){
    _focusedDay = focusedDay;
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

