import 'package:intl/intl.dart';

/// Datetime 객체를 날짜 저장 형식으로 변환합니다.
String dateToString(DateTime date) {
  String year = DateFormat('yyyy').format(date);
  String month = date.month.toString().padLeft(2, " ");
  String day = date.day.toString().padLeft(2, " ");
  return '$year.$month.$day.';
}

/// 'yyyy.MM.dd.' 형태의 문자열 날짜 데이터를 DateTime으로 변환합니다.
DateTime stringToDate(String date){
  List<String> splitDate = date.split(".");
  String year = splitDate[0];
  String month = splitDate[1].replaceAll(" ", "");
  String day = splitDate[2].replaceAll(" ", "");

  return DateTime(int.parse(year), int.parse(month), int.parse(day));
}

/// Datetime 객체를 날짜 저장 형식으로 변환합니다.
/// 날짜 뒤 요일이 추가된 형식입니다. (E)
String dateToStringWithDay(DateTime date) {
  String selectedDay = DateFormat('yyyy. M. dd.(E)', 'ko_KR').format(date);

  return '$selectedDay';
}
