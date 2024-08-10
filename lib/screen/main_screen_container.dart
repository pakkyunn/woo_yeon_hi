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

    _saveAndLoadDdayPrefs2(userProvider.loveDday);

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

Future<void> _saveAndLoadDdayPrefs2(String loveDday) async {
  const storage = FlutterSecureStorage();
  await storage.write(
      key: "loveDday",
      value: loveDday);
}