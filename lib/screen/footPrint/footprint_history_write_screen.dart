import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/history_dao.dart';
import 'package:woo_yeon_hi/model/history_model.dart';
import 'package:woo_yeon_hi/style/text_style.dart';
import 'package:woo_yeon_hi/widget/footPrint/footprint_history_write_album.dart';
import 'package:woo_yeon_hi/widget/footPrint/footprint_history_write_content.dart';
import 'package:woo_yeon_hi/widget/footPrint/footprint_history_write_top_app_bar.dart';

import '../../model/photo_map_model.dart';
import '../../provider/footprint_provider.dart';
import '../../style/color.dart';

class FootprintHistoryWriteScreen extends StatefulWidget {
  FootprintHistoryWriteScreen(this.photoMap, {super.key});
  PhotoMap photoMap;

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
          return Scaffold(
            backgroundColor: ColorFamily.cream,
            appBar: FootprintHistoryWriteTopAppBar(provider, widget.photoMap.mapIdx),
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
          );
        }
      ),
    );
  }
}
