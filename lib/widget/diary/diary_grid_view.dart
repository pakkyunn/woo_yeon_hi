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
    var userIdx = Provider.of<UserProvider>(context, listen: false).userIdx;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // executes after build
      var unCheckedDiary = isReadAll(userIdx, widget.provider.diaryData);
      if(unCheckedDiary != null){
        Navigator.push(context, MaterialPageRoute(builder: (context) => DiaryUncheckedScreen(unCheckedDiary)));
      }

    });
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<DiaryProvider>(context, listen: false).fetchDiaries(context);
        // setState(() {}); // 데이터가 갱신된 후 화면을 다시 그리기 위해 호출
      },
      child: MasonryGridView.count(
        itemCount: widget.provider.diaryData.length,
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemBuilder: (context, index) {
          return FutureBuilder(
              future: makeDiary(context, widget.provider.diaryData[index]),
              builder: (context, widgetSnapshot) {
                if (widgetSnapshot.connectionState == ConnectionState.waiting) {
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
      ),
    );
  }
}

Future<Widget> makeDiary(BuildContext context, Diary diary) async {
  var userProvider = Provider.of<UserProvider>(context, listen: false);

  return InkWell(
    splashColor: Colors.transparent,
    onTap: (){
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
                aspectRatio: 1.0,
                child: await getDiaryImage(diary.diaryImage)
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
                Text(diary.diaryUserIdx==userProvider.userIdx
                    ?userProvider.userNickname :userProvider.loverNickname,
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