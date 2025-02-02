import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/diary_dao.dart';
import 'package:woo_yeon_hi/model/diary_model.dart';
import 'package:woo_yeon_hi/provider/login_register_provider.dart';
import 'package:woo_yeon_hi/screen/diary/diary_detail_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/text_style.dart';

import '../../provider/tab_page_index_provider.dart';

class DiaryUncheckedScreen extends StatefulWidget {
  DiaryUncheckedScreen(this.unCheckedDiary, {super.key});
  Diary unCheckedDiary;

  @override
  State<DiaryUncheckedScreen> createState() => _DiaryUncheckedScreenState();
}

class _DiaryUncheckedScreenState extends State<DiaryUncheckedScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorFamily.cream,
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: (){
          readDiary(widget.unCheckedDiary);
          //TODO 바텀네비게이션 탭이동 후 화면이동
          Provider.of<TabPageIndexProvider>(context, listen: false).setCurrentPageIndex(0);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DiaryDetailScreen(widget.unCheckedDiary)));
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(Provider.of<UserProvider>(context, listen: false).loverNickname, style: TextStyleFamily.appBarTitleBoldTextStyle,),
                    Text(" 님이",style: TextStyleFamily.normalTextStyle,)
                  ],
                ),
              ),
              SizedBox(height: 10),
              const Text("작성한 일기가 도착했습니다!", style: TextStyleFamily.normalTextStyle,),
              const SizedBox(height: 70,),
              Image.asset('lib/assets/images/diary_arrived.gif'),
              const SizedBox(height: 70,),
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("화면을 터치하시면 해당 일기로 이동합니다.",style: TextStyleFamily.normalTextStyle,)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
