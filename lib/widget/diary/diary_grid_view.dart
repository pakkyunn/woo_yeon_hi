import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/diary_dao.dart';
import 'package:woo_yeon_hi/enums.dart';
import 'package:woo_yeon_hi/provider/diary_provider.dart';
import 'package:woo_yeon_hi/provider/login_register_provider.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/text_style.dart';

import '../../model/diary_model.dart';
import '../../screen/diary/diary_detail_screen.dart';
import '../../screen/diary/diary_unchecked_screen.dart';

class DiaryGridView extends StatefulWidget {
  DiaryGridView(this.provider, {super.key});

  DiaryProvider provider;

  @override
  State<DiaryGridView> createState() => _DiaryGridViewState();
}

class _DiaryGridViewState extends State<DiaryGridView> {
  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    var userIdx = userProvider.userIdx;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var unCheckedDiary = isReadAll(userIdx, widget.provider.diaryList);
      if (unCheckedDiary != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DiaryUncheckedScreen(unCheckedDiary)));
      }
    });
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<DiaryProvider>(context, listen: false).fetchDiaries(context);
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(10),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 열의 개수
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return FutureBuilder(
                      future:
                          makeDiary(context, widget.provider.diaryList[index]),
                      builder: (context, widgetSnapshot) {
                        if (widgetSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(); // 로딩 중일 때 표시할 위젯
                        } else if (widgetSnapshot.hasError) {
                          return const Center(
                            child: Text(
                              "이미지 오류",
                              style: TextStyleFamily.normalTextStyle,
                            ),
                          );
                        } else if (widgetSnapshot.hasData) {
                          return widgetSnapshot.data!;
                        } else {
                          return const SizedBox(); // 예외 처리
                        }
                      });
                },
                childCount: widget.provider.diaryList.length, // 항목 수
              ),
            ),
          ),
          // 추가 여백 공간을 위한 Sliver
          SliverToBoxAdapter(
            child: SizedBox(height: 50), // 플로팅 버튼이 가리지 않도록 할 높이
          ),
        ],
      ),

      // MasonryGridView.count(
      //     itemCount: widget.provider.diaryList.length,
      //     crossAxisCount: 2,
      //     mainAxisSpacing: 10,
      //     crossAxisSpacing: 10,
      //     itemBuilder: (context, index) {
      //       return FutureBuilder(
      //           future: makeDiary(context, widget.provider.diaryList[index]),
      //           builder: (context, widgetSnapshot) {
      //             if (widgetSnapshot.connectionState ==
      //                 ConnectionState.waiting) {
      //               return const SizedBox(); // 로딩 중일 때 표시할 위젯
      //             } else if (widgetSnapshot.hasError) {
      //               return const Center(
      //                 child: Text(
      //                   "이미지 오류",
      //                   style: TextStyleFamily.normalTextStyle,
      //                 ),
      //               );
      //             } else if (widgetSnapshot.hasData) {
      //               return widgetSnapshot.data!;
      //             } else {
      //               return const SizedBox(); // 예외 처리
      //             }
      //           });
      //     }),
    );
  }
}

Future<Widget> makeDiary(BuildContext context, Diary diary) async {
  var userProvider = Provider.of<UserProvider>(context, listen: false);

  // Future<void> _fetchData() async {
  //   var diaryProvider = Provider.of<DiaryProvider>(context, listen: false);
  //   diaryProvider.setLoading(true);
  //   await diaryProvider.getDiary(context);
  //   diaryProvider.setLoading(false);
  // }

  return InkWell(
    splashColor: Colors.transparent,
    onTap: () {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => DiaryDetailScreen(diary)));
    },
    child: Card(
      color: ColorFamily.white,
      surfaceTintColor: ColorFamily.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            AspectRatio(
                aspectRatio: 1.0, child: await getDiaryImage(diary.diaryImagePath)
                // child: await getDiaryImagePath(diary.diaryImage)
                ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  diary.diaryDate,
                  style: TextStyleFamily.normalTextStyle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  diary.diaryUserIdx == userProvider.userIdx
                      ? userProvider.userNickname
                      : userProvider.loverNickname,
                  style: TextStyleFamily.normalTextStyle,
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}

Diary? isReadAll(int user_index, List<Diary> diaryList) {
  for (var diary in diaryList) {
    // 자신이 쓴게 아니고, 읽지 않았다면
    if (diary.diaryUserIdx != user_index && !diary.diaryLoverCheck) {
      return diary;
    }
  }
  return null;
}
