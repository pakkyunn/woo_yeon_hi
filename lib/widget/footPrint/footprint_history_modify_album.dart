import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../dao/history_dao.dart';
import '../../model/history_model.dart';
import '../../provider/footprint_provider.dart';
import '../../style/color.dart';

class FootprintHistoryModifyAlbum extends StatefulWidget {
  FootprintHistoryModifyAlbum(this.provider, this.history, {super.key});
  FootprintHistoryWriteProvider provider;
  History history;

  @override
  State<FootprintHistoryModifyAlbum> createState() =>
      _FootprintHistoryModifyAlbumState();
}

class _FootprintHistoryModifyAlbumState
    extends State<FootprintHistoryModifyAlbum> {
  final ImagePicker picker = ImagePicker(); //ImagePicker 초기화

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width - 40,
          height: 120,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                FutureBuilder(
                  future: getHistoryImageList(widget.history.historyImage),
                  builder: (context, snapshot){
                    if(snapshot.hasData == false){
                      return const SizedBox();
                    }else if(snapshot.hasError){
                      return const Center(child: Text("image download error"),);
                    }else{
                      return Expanded(
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) =>
                                makeImageCard(context, index, snapshot.data![index])),
                      );
                    }
                  },
                ),


              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget makeImageCard(BuildContext context, int index, Image image) {
    return Padding(
      padding: index != widget.provider.albumModifyImages.length - 1
          ? const EdgeInsets.only(right: 5)
          : const EdgeInsets.only(right: 0),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorFamily.gray, // 외곽선 색상
            width: 0.5, // 외곽선 두께
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: image,
            )
          ],
        ),
      ),
    );
  }
}
