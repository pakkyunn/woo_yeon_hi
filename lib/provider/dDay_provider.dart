import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:woo_yeon_hi/model/dDay_model.dart';

class dDayAddProvider extends ChangeNotifier{
  List<bool> _isChecked = [];

  List<bool> get isChecked => _isChecked;

  dDayAddProvider(int itemCount){
    for(int i = 0; i< itemCount; i++){
      _isChecked.add(false);
    }
  }

  void toggleCheck(int index){
    _isChecked[index] = !_isChecked[index];
    notifyListeners();
  }
}

class DdayMakeProvider extends ChangeNotifier{
  TextEditingController _titleController = TextEditingController(text: "");
  TextEditingController _descriptionController = TextEditingController(text: "");
  List<bool> _isChecked = [true, false];
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  DdayModel? _dDayModel;

  TextEditingController get titleController => _titleController;
  TextEditingController get descriptionController => _descriptionController;
  List<bool> get isChecked => _isChecked;
  DateTime? get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;
  DdayModel? get dDayModel => _dDayModel;

  void checkedChange(){
    _isChecked[0] = !_isChecked[0];
    _isChecked[1] = !_isChecked[1];
    notifyListeners();
  }

  void setSelectedDay(DateTime? day){
    _selectedDay = day;
    notifyListeners();
  }

  void setFocusedDay(DateTime day){
    _focusedDay = day;
    notifyListeners();
  }

  void setDdayModel(DdayModel model){
    _dDayModel = model;
    notifyListeners();
  }

  void setTitleControllerText(String text){
    _titleController.text = text;
    notifyListeners();
  }

  void setDescriptionControllerText(String text){
    _descriptionController.text = text;
    notifyListeners();
  }

  void providerNotify(){
    notifyListeners();
  }
}

class DdayProvider extends ChangeNotifier{
  List<Map<String, dynamic>> _dDayList = [];
  List<Map<String, dynamic>> get dDayList => _dDayList;

  void setDdayList(List<Map<String, dynamic>> dDayList){
    _dDayList = dDayList;
    notifyListeners();
  }
}


// 날짜 계산용 오늘 날짜
DateTime _today(){
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}