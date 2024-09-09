import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/style/color.dart';

import '../../provider/diary_provider.dart';
import '../../widget/diary/diary_write_album.dart';
import '../../widget/diary/diary_write_textInput.dart';
import '../../widget/diary/diary_write_top_app_bar.dart';
import '../../widget/diary/diary_write_info.dart';

class DiaryWriteScreen extends StatefulWidget {
  const DiaryWriteScreen({super.key});

  @override
  State<DiaryWriteScreen> createState() => _DiaryWriteScreenState();
}

class _DiaryWriteScreenState extends State<DiaryWriteScreen> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DiaryEditProvider(),
      child: Consumer<DiaryEditProvider>(
        builder: (context, provider, _){
          return Scaffold(
            backgroundColor: ColorFamily.cream,
            appBar: DiaryWriteTopAppBar(provider),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(20,0,20,20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20,0,10,0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 날짜, 쓴 사람
                        DiaryWriteInfo(provider),
                        // 썸네일 등록
                        DiaryWriteAlbum(provider)
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // 일기 작성
                  Expanded(
                      child: LayoutBuilder(
                          builder: (context, constraints){
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight
                                ),
                                child: IntrinsicHeight(
                                  child: DiaryWriteTextInput(provider),
                                ),
                              ),
                            );
                          }
                      )
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
