import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:woo_yeon_hi/style/color.dart';

import '../../provider/diary_provider.dart';
import '../../style/text_style.dart';
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
  bool _isMyTurn = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isMyTurn = Provider.of<DiaryProvider>(context, listen: false).isPersonToWrite(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DiaryEditProvider(),
      child: Consumer<DiaryEditProvider>(
        builder: (context, provider, _){
          return _isMyTurn
          ? Scaffold(
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
          )
          : Scaffold(
            backgroundColor: ColorFamily.cream,
            appBar: AppBar(
              surfaceTintColor: ColorFamily.cream,
              backgroundColor: ColorFamily.cream,
              centerTitle: true,
              title: const Text(
                "일기 작성",
                style: TextStyleFamily.appBarTitleLightTextStyle,
              ),
              leading: IconButton(
                onPressed: () {
                    Navigator.pop(context);
                },
                icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20,0,20,100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "연인이 일기를 작성할 차례예요!",
                      style: TextStyleFamily.appBarTitleLightTextStyle,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "일기가 도착할 때까지 기다려 보아요 :)",
                      style: TextStyleFamily.appBarTitleLightTextStyle,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
