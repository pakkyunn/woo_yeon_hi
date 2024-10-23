import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/enums.dart';
import 'package:woo_yeon_hi/provider/diary_provider.dart';
import 'package:woo_yeon_hi/provider/login_register_provider.dart';

import '../../style/color.dart';
import '../../style/font.dart';
import '../../style/text_style.dart';
import '../../utils.dart';


class DiaryWriteInfo extends StatefulWidget {
  DiaryWriteInfo(this.provider, {super.key});
  DiaryEditProvider provider;

  @override
  State<DiaryWriteInfo> createState() => _DiaryWriteInfoState();
}

class _DiaryWriteInfoState extends State<DiaryWriteInfo> {
  // int weatherSelected = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          dateToString(DateTime.now()),
          style: TextStyleFamily.normalTextStyle,
        ),
        const SizedBox(
          height: 10,
        ),
         Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 일기 쓰는 사람
            Text(
              Provider.of<UserProvider>(context, listen: false).userNickname,
              style: const TextStyle(
                  fontFamily: FontFamily.mapleStoryBold,
                  fontSize: 14,
                  color: ColorFamily.black),
            ),
            const Text(
              " 님의 일기",
              style: TextStyleFamily.normalTextStyle,
            )
          ],
        ),
        // const SizedBox(
        //   height: 30,
        // ),
        // 날씨 토글 버튼
        // SizedBox(
        //   width: (MediaQuery.of(context).size.width * 2 / 3) - 20,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     children: [
        //       InkWell(
        //           splashColor: Colors.transparent,
        //           highlightColor: Colors.transparent,
        //           hoverColor: Colors.transparent,
        //           focusColor: Colors.transparent,
        //           onTap: () {
        //             widget.provider.setWeather(DiaryWeather.SUNNY.type);
        //           },
        //           child: Container(
        //               width: 60,
        //               height: 60,
        //               decoration: BoxDecoration(
        //                 borderRadius: BorderRadius.circular(5), // corner radius를 5로 설정
        //                 border: Border.all(color: (widget.provider.weatherType == DiaryWeather.SUNNY.type)
        //                     ?ColorFamily.pink
        //                     :Colors.transparent), // stroke 색상을 red로 설정
        //               ),
        //               child: Padding(
        //                 padding: const EdgeInsets.all(5.0),
        //                 child: Image.asset(DiaryWeather.SUNNY.image),
        //               ))
        //       ),
        //       const SizedBox(width:3,),
        //       InkWell(
        //           splashColor: Colors.transparent,
        //           highlightColor: Colors.transparent,
        //           hoverColor: Colors.transparent,
        //           focusColor: Colors.transparent,
        //           onTap: () {
        //             widget.provider.setWeather(DiaryWeather.CLOUDY.type);
        //           },
        //           child: Container(
        //               width: 60,
        //               height: 60,
        //               decoration: BoxDecoration(
        //                 borderRadius: BorderRadius.circular(5), // corner radius를 5로 설정
        //                 border: Border.all(color: (widget.provider.weatherType == DiaryWeather.CLOUDY.type)
        //                     ?ColorFamily.pink
        //                     :Colors.transparent), // stroke 색상을 red로 설정
        //               ),
        //               child: Padding(
        //                 padding: const EdgeInsets.all(5.0),
        //                 child: Image.asset(DiaryWeather.CLOUDY.image),
        //               ))
        //       ),
        //       const SizedBox(width:3,),
        //       InkWell(
        //           splashColor: Colors.transparent,
        //           highlightColor: Colors.transparent,
        //           hoverColor: Colors.transparent,
        //           focusColor: Colors.transparent,
        //           onTap: () {
        //             widget.provider.setWeather(DiaryWeather.RAINY.type);
        //           },
        //           child: Container(
        //               width: 60,
        //               height: 60,
        //               decoration: BoxDecoration(
        //                 borderRadius: BorderRadius.circular(5), // corner radius를 5로 설정
        //                 border: Border.all(color: (widget.provider.weatherType == DiaryWeather.RAINY.type)?ColorFamily.pink:Colors.transparent), // stroke 색상을 red로 설정
        //               ),
        //               child: Padding(
        //                 padding: const EdgeInsets.all(5.0),
        //                 child: Image.asset(DiaryWeather.RAINY.image),
        //               ))
        //       ),
        //       const SizedBox(width:3,),
        //       InkWell(
        //           splashColor: Colors.transparent,
        //           highlightColor: Colors.transparent,
        //           hoverColor: Colors.transparent,
        //           focusColor: Colors.transparent,
        //           onTap: () {
        //             widget.provider.setWeather(DiaryWeather.SNOWY.type);
        //           },
        //           child: Container(
        //               width: 60,
        //               height: 60,
        //               decoration: BoxDecoration(
        //                 borderRadius: BorderRadius.circular(5), // corner radius를 5로 설정
        //                 border: Border.all(color: (widget.provider.weatherType == DiaryWeather.SNOWY.type)?ColorFamily.pink:Colors.transparent), // stroke 색상을 red로 설정
        //               ),
        //               child: Padding(
        //                 padding: const EdgeInsets.all(5.0),
        //                 child: Image.asset(DiaryWeather.SNOWY.image),
        //               ))
        //       )
        //     ],
        //   ),
        // )
      ],
    );
  }
}
