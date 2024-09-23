import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/provider/ledger_provider.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';
import 'package:woo_yeon_hi/widget/ledger/ledger_carousel_slider.dart';
import 'package:woo_yeon_hi/widget/ledger/ledger_dialog.dart';
import 'package:woo_yeon_hi/widget/ledger/ledger_table_calendar.dart';
import 'package:woo_yeon_hi/widget/ledger/ledger_top_app_bar.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: ColorFamily.cream,
      appBar: LedgerTopAppBar(
        title: '가계부',
      ),
      body: SingleChildScrollView(
          child: Column(
            children: [
              // 상단 배너
              SizedBox(height: 150, child: LedgerCarouselSlider()),
              // 캘린더
              LedgerTableCalendar(),
            ],
          ),
        )

      // 하단 오른쪽에 FloatingActionButton 배치
      // floatingActionButton: FloatingActionButton(
      //   shape: CircleBorder(),
      //   backgroundColor: ColorFamily.beige,
      //   child: SvgPicture.asset('lib/assets/icons/edit.svg'),
      //   onPressed: () {
      //     showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         return LedgerDialog('LedgerScreen', '미등록 거래내역이 있습니다.', '이동하시겠습니까?');
      //       },
      //     );
      //   },
      // ),
    );
  }
}