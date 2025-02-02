import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/ledger_dao.dart';
import 'package:woo_yeon_hi/provider/ledger_provider.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';
import 'package:woo_yeon_hi/widget/ledger/ledger_list_view.dart';
import 'package:woo_yeon_hi/widget/ledger/ledger_top_app_bar.dart';

import '../../style/text_style.dart';

class LedgerDetailScreen extends StatefulWidget {
  const LedgerDetailScreen({super.key});

  @override
  State<LedgerDetailScreen> createState() => _LedgerDetailScreenState();
}

class _LedgerDetailScreenState extends State<LedgerDetailScreen> {
  final LedgerDao _ledgerDao = LedgerDao();

  // 날짜 포맷팅
  String formatLedgerDate(String ledgerDate) {
    try {
      DateTime dateTime = DateTime.parse(ledgerDate);
      String formattedDate = DateFormat('yyyy. M. d.(E)', 'ko').format(dateTime);
      return formattedDate;
    } catch (e) {
      // ledgerDate 값이 유효하지 않은 날짜 형식일 경우
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LedgerProvider>(
      builder: (context, ledgerProvider, child) {
        final selectedLedgerDate = ledgerProvider.selectedLedgerDate;

        // 날짜만 추출 (예시: "2024-06-11T15:16:00.000" -> "2024-06-11")
        // selectedLedgerDate가 비어 있을 때를 대비하여 오늘 날짜를 세팅
        String ledgerDateString = selectedLedgerDate.isNotEmpty
            ? selectedLedgerDate.first.ledgerDate.split('T')[0]
            : DateTime.now().toString().split(' ')[0];

        return Scaffold(
            appBar: LedgerTopAppBar(
              title: '가계부 상세',
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
              ),
            ),
            backgroundColor: ColorFamily.white,
            body: FutureBuilder(
                future: _ledgerDao.readLedger(ledgerDateString, context),
                builder: (context, snapshot) {
                  if(snapshot.hasData == false){
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ColorFamily.pink,
                      ),
                    );
                  }else if(snapshot.hasError){
                    return const Text("오류 발생", style: TextStyleFamily.normalTextStyle);
                  }else {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(formatLedgerDate(ledgerDateString), style: const TextStyle(color: ColorFamily.black, fontSize: 20, fontFamily: FontFamily.mapleStoryBold)),
                          ),
                          const SizedBox(height: 30),
                          // 아이템 항목 (snapshot.data! : 항목 삭제 시 데이터가 화면에 갱신)
                          LedgerListView(snapshot.data!, ledgerProvider),

                          // // 확인 버튼
                          // Container(
                          //   padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                          //   child: Material(
                          //     color: ColorFamily.beige,
                          //     elevation: 1,
                          //     shadowColor: Colors.black,
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(20.0),
                          //     ),
                          //     child: InkWell(
                          //       onTap: () {
                          //         Navigator.pop(context);
                          //       },
                          //       borderRadius: BorderRadius.circular(20.0),
                          //       child: Container(
                          //         height: 40,
                          //         alignment: Alignment.center,
                          //         child: const Text(
                          //           "확인",
                          //           style: TextStyleFamily.normalTextStyle,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    );
                  }
                }
            )
        );
      },
    );
  }
}
