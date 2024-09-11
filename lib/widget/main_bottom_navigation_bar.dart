import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/provider/tab_page_index_provider.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/text_style.dart';

class MainBottomNavigationBar extends StatefulWidget {
  const MainBottomNavigationBar({super.key});

  @override
  State<MainBottomNavigationBar> createState() => _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    // TabControllerProvider에서 TabController 초기화
    Provider.of<TabPageIndexProvider>(context, listen: false).init(this, 5);
  }

  @override
  Widget build(BuildContext context) {

    // 시스템 내비게이션 바의 배경색 설정
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: ColorFamily.white, // 시스템 내비게이션의 배경색
      systemNavigationBarIconBrightness: Brightness.dark, // 시스템 내비게이션의 아이콘 색상
    ));

    return Consumer<TabPageIndexProvider>(
        builder: (context, provider, child) {
          return TabBar(
            controller: provider.tabController,
            indicatorColor: Colors.transparent,
            overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
            unselectedLabelColor: ColorFamily.black,
            labelColor: ColorFamily.pink,
            labelStyle: TextStyleFamily.tabBarTextStyle,
            unselectedLabelStyle: TextStyleFamily.tabBarTextStyle,
            dividerHeight: 0,
            tabs: [
              Tab(
                text: "교환일기",
                icon: SvgPicture.asset(
                  'lib/assets/icons/diary.svg',
                  colorFilter: ColorFilter.mode(
                      provider.currentPageIndex == 0
                          ? ColorFamily.pink
                          : ColorFamily.black,
                      BlendMode.srcIn),
                ),
              ),
              Tab(
                text: "가계부",
                icon: SvgPicture.asset(
                  'lib/assets/icons/piggy_bank.svg',
                  colorFilter: ColorFilter.mode(
                      provider.currentPageIndex == 1
                          ? ColorFamily.pink
                          : ColorFamily.black,
                      BlendMode.srcIn),
                ),
              ),
              Tab(
                text: "홈",
                icon: SvgPicture.asset(
                  'lib/assets/icons/home.svg',
                  colorFilter: ColorFilter.mode(
                      provider.currentPageIndex == 2
                          ? ColorFamily.pink
                          : ColorFamily.black,
                      BlendMode.srcIn),
                ),
              ),
              Tab(
                text: "발자국",
                icon: SvgPicture.asset(
                  'lib/assets/icons/foot_print.svg',
                  colorFilter: ColorFilter.mode(
                      provider.currentPageIndex == 3
                          ? ColorFamily.pink
                          : ColorFamily.black,
                      BlendMode.srcIn),),
              ),
              Tab(
                text: "더보기",
                icon: SvgPicture.asset(
                  'lib/assets/icons/more.svg',
                  colorFilter: ColorFilter.mode(
                      provider.currentPageIndex == 4
                          ? ColorFamily.pink
                          : ColorFamily.black,
                      BlendMode.srcIn),),
              ),
            ],
            onTap: (value) {
              setState(() {
                provider.setCurrentPageIndex(value);
              });
            },
          );
        }
    );
  }
}
