import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/diary_dao.dart';
import 'package:woo_yeon_hi/provider/diary_provider.dart';

import '../../style/color.dart';
import '../../style/font.dart';

class DiaryWriteAlbum extends StatefulWidget {
  DiaryWriteAlbum(this.provider, {super.key});
  DiaryEditProvider provider;

  @override
  State<DiaryWriteAlbum> createState() => _DiaryWriteAlbumState();
}

class _DiaryWriteAlbumState extends State<DiaryWriteAlbum> {
  final ImagePicker picker = ImagePicker(); //ImagePicker 초기화

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Card(
        color: ColorFamily.white,
        surfaceTintColor: ColorFamily.white,
        elevation: 1,
        child: Container(
          child: (widget.provider.image != null)
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: (widget.provider.image?.path != null)
                          ?Image.file(
                        File(widget.provider.image!.path),
                        fit: BoxFit.cover,
                      ):Image.asset('lib/assets/images/test_couple.png', fit: BoxFit.cover,),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        onTap: (){
                          setState(() {
                            widget.provider.setImage(null);
                          });
                        },
                        child:SvgPicture.asset(
                            'lib/assets/icons/close_circle_white.svg'),
                      ),
                    )
                  ],
                )
              : IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    getImage(widget.provider, ImageSource.gallery);
                  },
                  icon: SvgPicture.asset(
                    'lib/assets/icons/add.svg',
                    width: 40,
                    height: 40,
                    colorFilter: const ColorFilter.mode(
                        ColorFamily.gray, BlendMode.srcIn),
                  )),
        ),
      ),
    );
  }

  Future getImage(DiaryEditProvider diaryProvider, ImageSource imagesource) async {
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? pickedFile = await picker.pickImage(source: imagesource);
    if (pickedFile != null) {
      setState(() {
        diaryProvider.setImage(XFile(pickedFile.path));
      });
    }
  }
}
