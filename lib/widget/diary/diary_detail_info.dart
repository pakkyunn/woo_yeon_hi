import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/user_dao.dart';
import 'package:woo_yeon_hi/model/diary_model.dart';
import 'package:woo_yeon_hi/enums.dart';
import 'package:woo_yeon_hi/provider/login_register_provider.dart';

import '../../style/color.dart';
import '../../style/font.dart';
import '../../style/text_style.dart';

class DiaryDetailInfo extends StatefulWidget {
  DiaryDetailInfo(this.diary, {super.key});

  Diary diary;

  @override
  State<DiaryDetailInfo> createState() => _DiaryDetailInfoState();
}

class _DiaryDetailInfoState extends State<DiaryDetailInfo> {
  late String diaryUserNickname;

  Future<String> _asyncData() async {
    diaryUserNickname =
        await getSpecificUserData(widget.diary.diaryUserIdx, 'user_nickname');

    return diaryUserNickname;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _asyncData(),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return const Center(
                child: CircularProgressIndicator(color: ColorFamily.pink));
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("error"),
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.diary.diaryDate,
                      style: TextStyleFamily.normalTextStyle,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // 일기 쓴 사람
                    Text(
                      diaryUserNickname,
                      style: const TextStyle(
                          fontFamily: FontFamily.mapleStoryBold,
                          fontSize: 14,
                          color: ColorFamily.black),
                    ),
                    const Text(
                      " 님이 쓴 일기",
                      style: TextStyleFamily.normalTextStyle,
                    )
                  ],
                ),
              ],
            );
          }
        });
  }
}
