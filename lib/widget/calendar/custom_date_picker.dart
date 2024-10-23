import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;

class CustomMonthDayPicker extends picker.DatePickerModel {
  CustomMonthDayPicker({DateTime? currentTime, DateTime? minTime, DateTime? maxTime, picker.LocaleType? locale})
      : super(locale: locale, currentTime: currentTime, minTime: minTime, maxTime: maxTime);

  // 월/일만 표시
  @override
  String? leftStringAtIndex(int index) {
    if (index >= 1 && index <= 12) {
      return '$index월';
    } else {
      return null;
    }
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index >= 1 && index <= 31) {
      return '$index일';
    } else {
      return null;
    }
  }

  // 연도는 표시하지 않음
  @override
  String? rightStringAtIndex(int index) {
    return null;
  }

  @override
  List<int> layoutProportions() {
    return [1, 1, 0]; // 연도를 숨기기 위해 3번째 열을 0으로 설정
  }
}

class CustomDatePicker extends StatefulWidget {
  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime selectedDateTime = DateTime.now();

  void _showDatePicker() {
    picker.DatePicker.showPicker(
      context,
      showTitleActions: true,
      onConfirm: (date) {
        setState(() {
          selectedDateTime = date;
        });
      },
      pickerModel: CustomMonthDayPicker(
        currentTime: selectedDateTime,
        minTime: DateTime(2000, 1, 1),
        maxTime: DateTime(2099, 12, 31),
        locale: picker.LocaleType.ko,
      ),
      theme: picker.DatePickerTheme(
        headerColor: Colors.white,
        backgroundColor: Colors.white,
        itemStyle: TextStyle(color: Colors.black, fontSize: 18),
        doneStyle: TextStyle(color: Colors.blue, fontSize: 16),
        cancelStyle: TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom Date Picker')),
      body: Center(
        child: ElevatedButton(
          onPressed: _showDatePicker,
          child: Text('Select Date'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: CustomDatePicker()));
}
