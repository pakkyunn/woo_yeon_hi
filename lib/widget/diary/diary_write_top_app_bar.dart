import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/diary_dao.dart';
import 'package:woo_yeon_hi/model/diary_model.dart';
import 'package:woo_yeon_hi/model/enums.dart';
import 'package:woo_yeon_hi/provider/login_register_provider.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/text_style.dart';

import '../../dialogs.dart';
import '../../provider/diary_provider.dart';
import '../../utils.dart';

class DiaryWriteTopAppBar extends StatefulWidget implements PreferredSizeWidget {
  DiaryWriteTopAppBar(this.provider, {super.key});
  DiaryEditProvider provider;

  @override
  State<DiaryWriteTopAppBar> createState() => _DiaryWriteTopAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DiaryWriteTopAppBarState extends State<DiaryWriteTopAppBar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, provider, child) {
      return AppBar(
        surfaceTintColor: ColorFamily.cream,
        backgroundColor: ColorFamily.cream,
        centerTitle: true,
        title: const Text(
          "일기 작성",
          style: TextStyleFamily.appBarTitleLightTextStyle,
        ),
        leading: IconButton(
          onPressed: () {
            // 작성한 내용이 하나라도 있을 때, 삭제된다는 알림을 띄운다.
            if (widget.provider.checkProvider()) {
              dialogTitleWithContent(
                  context,
                  "일기 작성을 취소하시겠습니까?",
                  "지금까지 작성된 내용은 삭제됩니다",
                      () => _onCancleBack(context),
                      () => _onConfirmBack(context)
              );
            } else {
              Navigator.pop(context);
            }
          },
          icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                //썸네일이 등록되지 않은 경우
                if(widget.provider.checkValid()==1) {
                  showBlackToast("썸네일 이미지를 등록해주세요");
                }
                //내용이 입력되지 않은 경우
                else if(widget.provider.checkValid()==2){
                  showBlackToast("제목과 내용을 모두 입력해주세요");
                }
                //모든 항목이 정상적으로 입력된 경우
                else {
                  dialogTitleWithContent(
                      context,
                      "일기를 작성하시겠습니까?",
                      "작성 후 수정 및 삭제를 할 수 없습니다",
                          () => _onCancleDone(context),
                          () {_onConfirmDone(context, widget.provider, provider.userIdx); showPinkSnackBar(context, "연인에게 일기를 전달하였습니다:)");});
                }
              },
              icon: SvgPicture.asset('lib/assets/icons/done.svg'))
        ],
      );
    },
    );
  }
}

void _onCancleDone(BuildContext context) {
  Navigator.pop(context);
}

Future<void> _onConfirmDone(BuildContext context, DiaryEditProvider provider, int userIdx) async {
  Navigator.pop(context); // 다이얼로그 팝
  Navigator.pop(context); // 일기 작성 페이지 팝

  var diaryIdx = await getDiarySequence() + 1;
  await setDiarySequence(diaryIdx);
  var now = DateTime.now();
  var todayFormatted = dateToString(now);
  var imageName = "${userIdx}_$now";

  var diary = Diary(
      diaryIdx: diaryIdx,
      diaryUserIdx: userIdx, // 임시
      diaryDate: todayFormatted,
      diaryWeather: provider.weatherType,
      diaryImage: imageName,
      diaryTitle: provider.titleTextEditController.text,
      diaryContent: provider.contentTextEditController.text,
      diaryLoverCheck: false,
      diaryState: DiaryState.STATE_NORMAL.state);
  await addDiary(diary);
  await uploadDiaryImage(provider.image!, imageName);
  provider.providerNotify();
}

void _onCancleBack(BuildContext context){
  Navigator.pop(context);
}

void _onConfirmBack(BuildContext context){
  Navigator.pop(context); // 다이얼로그 팝
  Navigator.pop(context); // 일기 작성 페이지 팝
}
