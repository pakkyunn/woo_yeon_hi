import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/provider/diary_provider.dart';
import 'package:woo_yeon_hi/style/font.dart';

import '../../style/color.dart';
import '../../style/text_style.dart';

class DiaryWriteTextInput extends StatefulWidget {
  DiaryWriteTextInput(this.provider, {super.key});
  DiaryEditProvider provider;

  @override
  State<DiaryWriteTextInput> createState() => _DiaryWriteTextInputState();
}

class _DiaryWriteTextInputState extends State<DiaryWriteTextInput> {

  @override
  Widget build(BuildContext context) {
    var diaryProvider = Provider.of<DiaryEditProvider>(context, listen:false);
    return SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      child: Card(
        color: ColorFamily.white,
        surfaceTintColor: ColorFamily.white,
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 제목
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: TextField(
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  maxLength: 20,
                  controller: diaryProvider.titleTextEditController,
                  cursorColor: ColorFamily.black,
                  onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: const InputDecoration(
                    hintText: '제목',
                    hintStyle: TextStyleFamily.hintTitleTextStyle,
                    border: InputBorder.none,
                    counter: SizedBox()
                  ),
                  style: const TextStyle(
                    fontFamily: FontFamily.mapleStoryLight,
                    fontSize: 20,
                    color: ColorFamily.black
                  ),
                )),
            // 내용
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: TextField(
                  maxLines: null,
                  controller: diaryProvider.contentTextEditController,
                  keyboardType: TextInputType.multiline,
                  cursorColor: ColorFamily.black,
                  scrollPhysics: const NeverScrollableScrollPhysics(),
                  onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: const InputDecoration(
                    hintText: '내용을 작성해주세요',
                    hintStyle: TextStyleFamily.hintTextStyle,
                    border: InputBorder.none,

                  ),
                  style: TextStyleFamily.normalTextStyle,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
