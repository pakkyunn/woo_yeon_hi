import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/history_dao.dart';
import 'package:woo_yeon_hi/enums.dart';
import 'package:woo_yeon_hi/model/history_model.dart';
import 'package:woo_yeon_hi/provider/footprint_provider.dart';

import '../../dialogs.dart';
import '../../provider/login_register_provider.dart';
import '../../screen/footPrint/footprint_history_detail_screen.dart';
import '../../screen/footPrint/footprint_history_screen.dart';
import '../../screen/footPrint/footprint_history_write_place_screen.dart';
import '../../style/color.dart';
import '../../style/text_style.dart';

class FootprintHistoryWriteTopAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  FootprintHistoryWriteTopAppBar(this.provider, {super.key});
  FootprintHistoryWriteProvider provider;

  @override
  State<FootprintHistoryWriteTopAppBar> createState() =>
      _FootprintHistoryWriteTopAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _FootprintHistoryWriteTopAppBarState
    extends State<FootprintHistoryWriteTopAppBar> {

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: ColorFamily.cream,
      backgroundColor: ColorFamily.cream,
      centerTitle: true,
      title: const Text(
        "히스토리 작성",
        style: TextStyleFamily.appBarTitleLightTextStyle,
      ),
      leading: IconButton(
        onPressed: () {
          if (widget.provider.albumImages.isNotEmpty ||
              widget.provider.titleController.text.isNotEmpty ||
              widget.provider.contentController.text.isNotEmpty ||
              widget.provider.selectedPlace != null ||
              widget.provider.date != null) {
            // 작성한 내용이 하나라도 있을 경우
            dialogTitleWithContent(
                context,
                "히스토리 작성을 취소하시겠습니까?",
                "지금까지 작성된 내용은 삭제됩니다",
                () => _onCancle_back(context),
                () => _onConfirm_back(context));
          } else {
            Navigator.pop(context);
          }
        },
        icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
      ),
      actions: [
        IconButton(
            onPressed: () {
              if (widget.provider.albumImages.isNotEmpty &&
                  widget.provider.titleController.text.isNotEmpty &&
                  widget.provider.contentController.text.isNotEmpty &&
                  widget.provider.selectedPlace != null &&
                  widget.provider.date != null) {
                dialogOnlyTitle(
                    context,
                    "히스토리를 작성하시겠습니까?",
                    () => _onCancle_done(context),
                    () => _onConfirm_done(context));
              } else if(widget.provider.albumImages.isEmpty) {
                showBlackToast("히스토리 사진이 등록되지 않았습니다");
              } else {
                showBlackToast("모든 항목을 입력해주세요!");
              }
            },
            icon: SvgPicture.asset('lib/assets/icons/done.svg'))
      ],
    );
  }

  void _onCancle_back(BuildContext context) {
    Navigator.pop(context);
  }

  void _onConfirm_back(BuildContext context) {
    Navigator.pop(context); // 다이얼로그 팝
    Navigator.pop(context); // 히스토리 작성 페이지 팝
  }

  void _onCancle_done(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _onConfirm_done(BuildContext context) async {
    var historySequence = await getHistorySequence() + 1;
    setHistorySequence(historySequence);
    var userProvider = Provider.of<UserProvider>(context, listen: false);

    var imageNameList = List.generate(
        widget.provider.albumImages.length,
            (index) => "${userProvider.userIdx}_${DateTime.now()}");
    var coordinate = convertCoordinate(widget.provider.selectedPlace!.mapx, widget.provider.selectedPlace!.mapy);

    var history = History(
        historyIdx: historySequence,
        historyPlaceName: widget.provider.selectedPlace!.title,
        historyLocation: GeoPoint(coordinate.latitude, coordinate.longitude),
        historyUserIdx: userProvider.userIdx,
        historyTitle: widget.provider.titleController.text,
        historyDate: widget.provider.date!,
        historyContent: widget.provider.contentController.text,
        historyImage: imageNameList,
        historyState: HistoryState.STATE_NORMAL.state
    );

    Navigator.pop(context); // 다이얼로그 팝

    final snackBar = SnackBar(
      content: Text("히스토리를 저장하고 있습니다..", textAlign: TextAlign.center, style: TextStyleFamily.normalTextStyle),
      backgroundColor: ColorFamily.pink,
      duration: Duration(minutes: 5), // 히스토리 저장작업이 끝날 때까지 스낵바가 유지되도록 설정
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    await addHistory(history);
    var newHistoryList = await getHistory(context);
    var newHistoryIndex = newHistoryList.indexWhere((history) => history.historyIdx == historySequence);
    for(var i = 0 ; i < imageNameList.length ; i++){
      await uploadHistoryImage(widget.provider.albumImages[i], imageNameList[i]);
    }
    // Provider.of<FootprintPhotoMapHistoryProvider>(context, listen: false).setHistoryList(newHistoryList);

    // Navigator.pop(context); // 히스토리 작성 페이지 팝
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    //해당 히스토리로 이동
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
        FootprintHistoryDetailScreen(newHistoryIndex)));
    showPinkSnackBar(context, "히스토리가 작성되었습니다!");
  }
}


