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

class FootprintHistoryModifyTopAppBar extends StatefulWidget implements PreferredSizeWidget{
  FootprintHistoryModifyTopAppBar(this.provider, this.history, this.index, this.historyList, {super.key});
  FootprintHistoryWriteProvider provider;
  History history;
  int index;
  List<History> historyList;

  @override
  State<FootprintHistoryModifyTopAppBar> createState() => _FootprintHistoryModifyTopAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _FootprintHistoryModifyTopAppBarState extends State<FootprintHistoryModifyTopAppBar> {
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
        onPressed: (){
          // 바뀐 내용이 있는지 확인
          if(widget.provider.selectedPlace != null ||
          widget.provider.date != widget.history.historyDate ||
          widget.provider.titleController.text != widget.history.historyTitle ||
          widget.provider.contentController.text != widget.history.historyContent){
            dialogTitleWithContent(
                context,
                "히스토리 수정을 취소하시겠습니까?",
                "지금까지 작성된 내용은 삭제됩니다",
                    () => _onCancle_back(context),
                    () => _onConfirm_back(context));
          }else{
            //해당 히스토리로 이동
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => FootprintHistoryDetailScreen(widget.index)));
          }
        },
        icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
      ),
      actions: [
        (widget.provider.selectedPlace != null ||
            widget.provider.date != widget.history.historyDate ||
            widget.provider.titleController.text != widget.history.historyTitle ||
            widget.provider.contentController.text != widget.history.historyContent)
            ?IconButton(
            onPressed: () {
              dialogOnlyTitle(
                  context,
                  "히스토리를 수정하시겠습니까?",
                      () => _onCancle_done(context),
                      () {_onConfirm_done(context);});
            },
            icon: SvgPicture.asset('lib/assets/icons/done.svg'))
            : const SizedBox()

      ],
    );
  }

  void _onCancle_back(BuildContext context) {
    Navigator.pop(context);
  }

  void _onConfirm_back(BuildContext context) {
    Navigator.pop(context); // 다이얼로그 팝
    // Navigator.pop(context); // 히스토리 수정 페이지 팝
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => FootprintHistoryDetailScreen(widget.index)));
  }

  void _onCancle_done(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _onConfirm_done(BuildContext context) async {
    Map<String, dynamic> historyMap = {};

    if(widget.provider.selectedPlace != null){
      var coordinate = convertCoordinate(widget.provider.selectedPlace!.mapx, widget.provider.selectedPlace!.mapy);
      historyMap = {
        "history_content" : widget.provider.contentController.text,
        "history_date" : widget.provider.date,
        "history_location" : GeoPoint(coordinate.latitude, coordinate.longitude),
        "history_place_name" : widget.provider.selectedPlace!.title,
        "history_title" : widget.provider.titleController.text
      };
      editHistory(widget.history.historyIdx, historyMap);
    }else{
      historyMap = {
        "history_content" : widget.provider.contentController.text,
        "history_date" : widget.provider.date,
        "history_title" : widget.provider.titleController.text
      };
      await editHistory(widget.history.historyIdx, historyMap);
    }
    Navigator.pop(context); // 다이얼로그 팝
    // Navigator.pop(context, "refresh"); // 히스토리 수정 페이지 팝
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => FootprintHistoryDetailScreen(widget.index)));
    showPinkSnackBar(context, "히스토리가 수정되었습니다");
  }
}
