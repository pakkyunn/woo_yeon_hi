import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/diary_provider.dart';
import '../provider/footprint_provider.dart';
import '../provider/ledger_provider.dart';
import '../provider/more_provider.dart';
import '../provider/tab_page_index_provider.dart';
import 'package:woo_yeon_hi/screen/main_screen_container.dart';
import '../style/color.dart';
import '../widget/main_bottom_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      initialIndex: 2,
      length: 5,
      child: Scaffold(
        backgroundColor: ColorFamily.white,
        bottomNavigationBar: MainBottomNavigationBar(),
        body: MainScreenContainer(),
      ),
    );
  }
}
