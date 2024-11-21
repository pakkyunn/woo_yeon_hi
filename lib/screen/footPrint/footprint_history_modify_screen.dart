import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/provider/footprint_provider.dart';
import 'package:woo_yeon_hi/style/color.dart';

import '../../dialogs.dart';
import '../../model/history_model.dart';
import '../../widget/footPrint/footprint_history_modify_album.dart';
import '../../widget/footPrint/footprint_history_modify_top_app_bar.dart';
import '../../widget/footPrint/footprint_history_modify_content.dart';
import 'footprint_history_detail_screen.dart';

class FootprintHistoryModifyScreen extends StatefulWidget {
  FootprintHistoryModifyScreen(this.history, this.index, this.historyList, {super.key});
  History history;
  int index;
  List<History> historyList;

  @override
  State<FootprintHistoryModifyScreen> createState() =>
      _FootprintHistoryModifyScreenState();
}

class _FootprintHistoryModifyScreenState
    extends State<FootprintHistoryModifyScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => FootprintHistoryWriteProvider(),
        child: Consumer<FootprintHistoryWriteProvider>(
          builder: (context, provider, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.modifySetting(widget.history);
            });
            return WillPopScope(
                onWillPop: () async {
                  // 바뀐 내용이 있는지 확인
                  if(provider.selectedPlace != null ||
                      provider.date != widget.history.historyDate ||
                      provider.titleController.text != widget.history.historyTitle ||
                      provider.contentController.text != widget.history.historyContent){
                    dialogTitleWithContent(
                        context,
                        "히스토리 수정을 취소하시겠습니까?",
                        "지금까지 작성된 내용은 삭제됩니다",
                            () => _onCancle_back(context),
                            () => _onConfirm_back(context)
                    );
                    return false; // 기본 뒤로가기 동작 막기
                  } else{
                    //해당 히스토리로 이동
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FootprintHistoryDetailScreen(widget.index)));
                    return false; // 기본 pop 방지
                  }
                },
              child: Scaffold(
                backgroundColor: ColorFamily.cream,
                appBar: FootprintHistoryModifyTopAppBar(provider, widget.history, widget.index, widget.historyList),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        FootprintHistoryModifyAlbum(provider, widget.history),
                        FootprintHistoryModifyContent(provider, widget.history)
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
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
}
