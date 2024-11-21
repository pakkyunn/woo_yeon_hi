import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/history_dao.dart';
import 'package:woo_yeon_hi/model/history_model.dart';
import 'package:woo_yeon_hi/style/text_style.dart';
import 'package:woo_yeon_hi/widget/footPrint/footprint_history_write_album.dart';
import 'package:woo_yeon_hi/widget/footPrint/footprint_history_write_content.dart';
import 'package:woo_yeon_hi/widget/footPrint/footprint_history_write_top_app_bar.dart';

import '../../dialogs.dart';
import '../../model/photo_map_model.dart';
import '../../provider/footprint_provider.dart';
import '../../style/color.dart';

class FootprintHistoryWriteScreen extends StatefulWidget {
  const FootprintHistoryWriteScreen({super.key});

  @override
  State<FootprintHistoryWriteScreen> createState() => _FootprintHistoryWriteScreenState();
}

class _FootprintHistoryWriteScreenState extends State<FootprintHistoryWriteScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FootprintHistoryWriteProvider(),
      child: Consumer<FootprintHistoryWriteProvider>(
        builder: (context, provider, _) {
          return WillPopScope(
              onWillPop: () async {
                if (provider.albumImages.isNotEmpty ||
                    provider.titleController.text.isNotEmpty ||
                    provider.contentController.text.isNotEmpty ||
                    provider.selectedPlace != null ||
                    provider.date != null) {
                  // 작성한 내용이 하나라도 있을 경우
                  dialogTitleWithContent(
                      context,
                      "히스토리 작성을 취소하시겠습니까?",
                      "지금까지 작성된 내용은 삭제됩니다",
                          () => _onCancle_back(context),
                          () => _onConfirm_back(context));
                  return false;
                } else {
                  Navigator.pop(context);
                  return false;
                }
          },
          child: Scaffold(
            backgroundColor: ColorFamily.cream,
            appBar: FootprintHistoryWriteTopAppBar(provider),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    FootprintHistoryWriteAlbum(provider),
                    FootprintHistoryWriteContent(provider)
                  ],
                ),
              ),
            ),
          ));
        }
      ),
    );
  }
  void _onCancle_back(BuildContext context) {
    Navigator.pop(context);
  }

  void _onConfirm_back(BuildContext context) {
    Navigator.pop(context); // 다이얼로그 팝
    Navigator.pop(context); // 히스토리 작성 페이지 팝
  }
}
