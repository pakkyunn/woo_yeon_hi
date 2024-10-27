import 'package:flutter/cupertino.dart';

import '../dao/schedule_dao.dart';
import '../model/schedule_model.dart';

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

  List<Map<String, dynamic>> _selectedDayScheduleList = [];
  List<Map<String, dynamic>> get selectedDayScheduleList => _selectedDayScheduleList;

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

  void setSelectedDayScheduleList(){
    _selectedDayScheduleList = _scheduleList[listIndex];
    notifyListeners();
  }

  void setListIndex() {
    _listIndex = selectedDay.day - 1;
    notifyListeners();
  }
}

class CalendarScreenProvider extends ChangeNotifier {
  //캘린더 화면

  DateTime _selectedDay = DateTime.now();
  DateTime get selectedDay => _selectedDay;

  DateTime _focusedDay = DateTime.now();
  DateTime get focusedDay => _focusedDay;

  List<Map<String, dynamic>> _scheduleList = [];
  List<Map<String, dynamic>> get scheduleList => _scheduleList;

  List<Map<String, dynamic>> _selectedDayScheduleList = [];
  List<Map<String, dynamic>> get selectedDayScheduleList => _selectedDayScheduleList;

  Map<String, dynamic> _selectedDaySchedule = {};
  Map<String, dynamic> get selectedDaySchedule => _selectedDaySchedule;

  void setSelectedDay(DateTime selectedDay){
    _selectedDay = selectedDay;
    notifyListeners();
  }

  void setFocusedDay(DateTime focusedDay){
    _focusedDay = focusedDay;
    notifyListeners();
  }

  void setScheduleList(List<Map<String, dynamic>> scheduleList){
    _scheduleList = scheduleList;
    notifyListeners();
  }

  void setSelectedDayScheduleList(List<Map<String, dynamic>> scheduleList){
    _selectedDayScheduleList = scheduleList;
    notifyListeners();
  }

  void setSelectedSchedule(Map<String, dynamic> schedule){
    _selectedDaySchedule = schedule;
    notifyListeners();
  }

  void setSelectedScheduleFromIndex(int index){
    _selectedDaySchedule = _selectedDayScheduleList[index];
    notifyListeners();
  }

  Future<void> updateScheduleList(BuildContext context) async {
    _scheduleList = await getCalendarScreenScheduleList(context);
    notifyListeners();
  }

  void updateSchedule(Schedule updatedModel){
    _selectedDaySchedule['schedule_start_date'] = updatedModel.scheduleStartDate;
    _selectedDaySchedule['schedule_finish_date'] = updatedModel.scheduleFinishDate;
    _selectedDaySchedule['schedule_start_time'] = updatedModel.scheduleStartTime;
    _selectedDaySchedule['schedule_finish_time'] = updatedModel.scheduleFinishTime;
    _selectedDaySchedule['schedule_title'] = updatedModel.scheduleTitle;
    _selectedDaySchedule['schedule_color'] = updatedModel.scheduleColor;
    _selectedDaySchedule['schedule_memo'] = updatedModel.scheduleMemo;

    notifyListeners();
  }

  // 일정 추가 화면

  int _selectedColorType = 3;
  int get selectedColorType => _selectedColorType;

  void setSelectedColorType(int colorType){
    _selectedColorType = colorType;
    notifyListeners();
  }

}
