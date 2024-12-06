import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:woo_yeon_hi/provider/diary_provider.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/text_style.dart';

import '../../main.dart';
import '../../model/diary_model.dart';
import '../../provider/login_register_provider.dart';
import '../../widget/diary/diary_filter_list_view.dart';
import '../../widget/diary/diary_grid_view.dart';
import '../../widget/diary/diary_modal_bottom_sheet.dart';
import '../../widget/diary/diary_top_app_bar.dart';
import 'diary_write_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> with RouteAware {

  @override
  void initState() {
    super.initState();
    Provider.of<DiaryProvider>(context, listen: false).fetchDiaries(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DiaryProvider, UserProvider>(
      builder: (context, diaryProvider, userProvider, _) {
        return Scaffold(
            backgroundColor: ColorFamily.cream,
            appBar: const DiaryTopAppBar(),
            floatingActionButton: FloatingActionButton(
              splashColor: Colors.transparent,
              elevation: 3,
              backgroundColor: ColorFamily.beige,
              shape: const CircleBorder(),
              child: SvgPicture.asset('lib/assets/icons/edit.svg'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                const DiaryWriteScreen()));
              },
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            showFilterBottomSheet(diaryProvider, userProvider.userIdx, userProvider.loverIdx, context: context);
                          },
                          child: SvgPicture.asset(
                            'lib/assets/icons/filter_alt_fill.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: DiaryFilterListView(
                                diaryProvider))
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Consumer<DiaryProvider>(
                  //   builder: (context, diary2Provider, child) {
                  //     if (diary2Provider.isLoading) {
                  //       return const Expanded(
                  //         child: Center(
                  //           child: CircularProgressIndicator(
                  //             color: ColorFamily.pink,
                  //           ),
                  //         ),
                  //       );
                  //     } else if (diary2Provider.hasError) {
                  //       return const Center(child: Text("오류 발생", style: TextStyleFamily.normalTextStyle));
                  //     } else if (diary2Provider.diaryData.isEmpty) {
                  //       return const Expanded(child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.center,
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Text("일기 목록 없음", style: TextStyleFamily
                  //                 .smallTitleTextStyle),
                  //             SizedBox(height: 10)
                  //           ]));
                  //     } else {
                  //       return Expanded(child: DiaryGridView(diary2Provider));
                  //     }
                  //   }),
                  FutureBuilder(
                    future: diaryProvider.diaryFuture,
                    builder: (context, snapshot){
                      if(snapshot.hasData == false){
                        return const Center(
                            child: CircularProgressIndicator(
                              color: ColorFamily.pink,
                            )
                        );
                      }else if(snapshot.hasError){
                        return const Text("오류 발생", style: TextStyleFamily.normalTextStyle);
                      } else{
                        //TODO 필터링 조건에 맞는 일기가 없을 때
                        if(diaryProvider.diaryList.isEmpty) {
                          return const Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("일기 목록 없음", style: TextStyleFamily
                                    .smallTitleTextStyle)
                              ]));
                        } else {
                          return Expanded(child: DiaryGridView(diaryProvider));
                        }
                      }
                    },
                  ),
                ],
              ),
            )
        );
      },
    );
  }

  bool isSaturday(DateTime day) {
    return day.weekday == DateTime.saturday;
  }

  bool isWeekend(DateTime day) {
    return day.weekday == DateTime.sunday;
  }
}