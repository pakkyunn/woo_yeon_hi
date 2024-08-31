import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/provider/footprint_provider.dart';
import 'package:woo_yeon_hi/screen/footPrint/footprint_date_plan_screen.dart';
import 'package:woo_yeon_hi/screen/footPrint/footprint_photo_map_add_screen.dart';
import 'package:woo_yeon_hi/screen/footPrint/footprint_photo_map_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/widget/footPrint/footprint_tab_bar.dart';
import 'package:woo_yeon_hi/widget/footPrint/footprint_top_app_bar.dart';

import 'footprint_date_plan_write_screen.dart';

class FootprintScreen extends StatefulWidget {
  const FootprintScreen({super.key});

  @override
  State<FootprintScreen> createState() => _FootprintScreenState();
}

class _FootprintScreenState extends State<FootprintScreen> {
  @override
  Widget build(BuildContext context) {
    var footprintProvider =
        Provider.of<FootprintProvider>(context, listen: false);

    var currentPageIndex = footprintProvider.currentPageIndex;
    footprintProvider.addListener(() {
      if(mounted){
        setState(() {
          currentPageIndex = footprintProvider.currentPageIndex;
        });
      }
    });

    return DefaultTabController(
      length: 2,
      initialIndex: footprintProvider.currentPageIndex,
      child: Scaffold(
        backgroundColor: ColorFamily.cream,
        appBar: const FootprintTopAppBar(),
        floatingActionButton: FloatingActionButton(
          // mini: true,
          // splashColor: Colors.transparent,
          // elevation: 3,
          backgroundColor: ColorFamily.beige,
          shape: const CircleBorder(),
          child: SvgPicture.asset('lib/assets/icons/add.svg'),
          onPressed: () {
            if(footprintProvider.currentPageIndex == 0){
              // 포토맵
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FootprintPhotoMapAddScreen()));
            }else{
              // 데이트 플랜
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FootprintDatePlanWriteScreen()));
            }
          },
        ),
        body: Column(
          children: [
            const FootprintTabBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: [
                  const FootprintPhotoMapScreen(),
                  const FootprintDatePlanScreen()
                ][currentPageIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
