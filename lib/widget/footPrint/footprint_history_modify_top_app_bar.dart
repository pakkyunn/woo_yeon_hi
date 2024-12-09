import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/history_dao.dart';
import 'package:woo_yeon_hi/model/history_model.dart';
import 'package:woo_yeon_hi/provider/footprint_provider.dart';
import 'package:woo_yeon_hi/screen/footPrint/footprint_history_detail_screen.dart';

import '../../dialogs.dart';
import '../../provider/login_register_provider.dart';
import '../../screen/footPrint/footprint_history_write_place_screen.dart';
import '../../screen/footPrint/footprint_history_screen.dart';
import '../../screen/footPrint/footprint_photo_map_detail_screen.dart';
import '../../style/color.dart';
import '../../style/text_style.dart';

class FootprintHistoryModifyTopAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  FootprintHistoryModifyTopAppBar(
      this.provider, this.history, this.index, this.historyList,
      {super.key});

  FootprintHistoryWriteProvider provider;
  History history;
  int index;
  List<History> historyList;

  @override
  State<FootprintHistoryModifyTopAppBar> createState() =>
      _FootprintHistoryModifyTopAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _FootprintHistoryModifyTopAppBarState
    extends State<FootprintHistoryModifyTopAppBar> {

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: ColorFamily.cream,
      backgroundColor: ColorFamily.cream,
      centerTitle: true,
      title: const Text(
        "히스토리 수정",
        style: TextStyleFamily.appBarTitleLightTextStyle,
      ),
      leading: IconButton(
        onPressed: () {
          // 바뀐 내용이 있는지 확인
          if (_isHistoryChanged()) {
            dialogTitleWithContent(
                context,
                "히스토리 수정을 취소하시겠습니까?",
                "수정된 내용은 삭제됩니다",
                () => _onCancle_back(context),
                () => _onConfirm_back(context));
          } else {
            //해당 히스토리로 이동
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FootprintHistoryDetailScreen(widget.index)));
          }
        },
        icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
      ),
      actions: [
        IconButton(
          onPressed: () {
            if(!_isHistoryChanged()){
              showBlackToast("수정된 내용이 없습니다");
            } else if (_isAllEntered()) {
              dialogOnlyTitle(
                  context,
                  "히스토리를 수정하시겠습니까?",
                      () => _onCancle_done(context),
                      () => _onConfirm_done(context));
            } else {
              showBlackToast("모든 항목을 입력해주세요!");
            }
          },
          icon: SvgPicture.asset('lib/assets/icons/done.svg'))
      ],
    );
  }

  bool _isHistoryChanged() {
    return widget.provider.selectedPlace != null ||
        widget.provider.date != widget.history.historyDate ||
        widget.provider.titleController.text != widget.history.historyTitle ||
        widget.provider.contentController.text != widget.history.historyContent;
  }

  bool _isAllEntered() {
    return widget.provider.date != null &&
        widget.provider.titleController.text.isNotEmpty &&
        widget.provider.contentController.text.isNotEmpty;
  }

  void _onCancle_back(BuildContext context) {
    Navigator.pop(context);
  }

  void _onConfirm_back(BuildContext context) {
    Navigator.pop(context); // 다이얼로그 팝
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => FootprintHistoryDetailScreen(widget.index)));
  }

  void _onCancle_done(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _onConfirm_done(BuildContext context) async {
    var historyProvider =
        Provider.of<FootprintHistoryProvider>(context, listen: false);
    late dynamic coordinate;
    Map<String, dynamic> historyMap = {};

    if(widget.provider.selectedPlace != null){
      coordinate = convertCoordinate(widget.provider.selectedPlace!.mapx, widget.provider.selectedPlace!.mapy);
    }
    historyMap = {
      "history_location": widget.provider.selectedPlace != null
        ? GeoPoint(coordinate.latitude, coordinate.longitude)
        : widget.history.historyLocation,
      "history_place_name": widget.provider.selectedPlace != null
          ? widget.provider.selectedPlace!.title
          : widget.history.historyPlaceName,
      "history_date": widget.provider.date,
      "history_title": widget.provider.titleController.text,
      "history_content": widget.provider.contentController.text
    };

    Navigator.pop(context); // 다이얼로그 팝

    final snackBar = SnackBar(
      content: Text("히스토리 수정 중...",
          textAlign: TextAlign.center, style: TextStyleFamily.normalTextStyle),
      backgroundColor: ColorFamily.pink,
      duration: Duration(minutes: 5), // 히스토리 저장작업이 끝날 때까지 스낵바가 유지되도록 설정
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    await editHistory(widget.history.historyIdx, historyMap);
    historyProvider.modifyHistory(historyMap, widget.index);
    // Navigator.pop(context, "refresh"); // 히스토리 수정 페이지 팝
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => FootprintHistoryDetailScreen(widget.index)));
    showPinkSnackBar(context, "히스토리가 수정되었습니다");
  }
}
