import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woo_yeon_hi/provider/login_register_provider.dart';
import 'package:woo_yeon_hi/utils.dart';
import '../dao/more_dao.dart';
import '../model/user_model.dart';
import '../provider/tab_page_index_provider.dart';
import 'diary/diary_screen.dart';
import 'footPrint/footprint_screen.dart';
import 'home/home_screen_container.dart';
import 'home/home_screen_set1.dart';
import 'home/home_screen_set4.dart';
import 'ledger/ledger_screen.dart';
import 'more/more_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainScreenContainer extends StatefulWidget {
  const MainScreenContainer({super.key});

  @override
  State<MainScreenContainer> createState() => _MainScreenContainerState();
}

class _MainScreenContainerState extends State<MainScreenContainer> {

  @override
  Widget build(BuildContext context) {
    var tabPageIndexProvider = Provider.of<TabPageIndexProvider>(context, listen:false);
    var userProvider = Provider.of<UserProvider>(context, listen:false);

    var currentPageIndex = tabPageIndexProvider.currentPageIndex;
    tabPageIndexProvider.addListener(() {
      // 화면의 순서값을 변경한다.
      setState(() {
        currentPageIndex = tabPageIndexProvider.currentPageIndex;
      });
    });

    _saveAndLoadDdayPrefs(userProvider.loveDday);

    return MultiProvider(
        providers: [
          StreamProvider<String>(
            create: (_) => userNicknameStream(userProvider.userIdx),
            initialData: '',
            catchError: (_, __) => '',
          )
    ],
    child: Container(
      alignment: Alignment.center,
      child: [
        const DiaryScreen(),
        const LedgerScreen(),
        const HomeScreenContainer(),
        const FootprintScreen(),
        const MoreScreen()
      ][currentPageIndex],
    ));
  }
}

Future<void> _saveAndLoadDdayPrefs(String loveDday) async {
  DateTime loveDdayDate = stringToDate(loveDday);

  final prefs = await SharedPreferences.getInstance();

  // 데이터를 저장하는 비동기 작업
  bool success = await prefs.setString("loveDday", DateFormat('yyyy-MM-dd').format(loveDdayDate));

  if (success) {
    print('날짜가 성공적으로 저장되었습니다!');

    // 1초 지연 추가
    await Future.delayed(Duration(seconds: 1));

    // 저장이 완료된 후 데이터를 읽음
    String? savedDate = prefs.getString("loveDday");
    if (savedDate != null) {
      print('저장된 날짜: $savedDate');
    } else {
      print('저장된 날짜가 없습니다.');
    }
  } else {
    print('날짜 저장에 실패했습니다.');
  }
}
