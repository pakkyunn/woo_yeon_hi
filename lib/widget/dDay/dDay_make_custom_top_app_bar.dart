import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:woo_yeon_hi/provider/dDay_provider.dart';

import '../../dialogs.dart';
import '../../style/color.dart';
import '../../style/text_style.dart';

class dDayMakeCustomTopAppBar extends StatefulWidget implements PreferredSizeWidget{
  dDayMakeCustomTopAppBar(this.provider, {super.key});

  dDayMakeCustomProvider provider;

  @override
  State<dDayMakeCustomTopAppBar> createState() => _dDayMakeCustomTopAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _dDayMakeCustomTopAppBarState extends State<dDayMakeCustomTopAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: ColorFamily.cream,
      backgroundColor: ColorFamily.cream,
      centerTitle: true,
      title: const Text("커스텀 디데이", style: TextStyleFamily.appBarTitleLightTextStyle,),
      leading: IconButton(
        onPressed: () {
          if(widget.provider.title.text.isNotEmpty || widget.provider.content.text.isNotEmpty){
            _showBackDialog(context, widget.provider);
          }
          else{
            Navigator.pop(context);
          }
        },
        icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
      ),
      actions: [
        IconButton(
          onPressed: (){
            if(widget.provider.title.text.isEmpty && widget.provider.content.text.isEmpty){
              showBlackToast("내용을 입력해주세요");
            }
            else{
              showPinkSnackBar(context, "디데이가 생성되었습니다");
              Navigator.pop(context);
            }
          },
          icon: SvgPicture.asset('lib/assets/icons/done.svg'),
        )
      ],
    );
  }

  void _showBackDialog(BuildContext context, dDayMakeCustomProvider provider) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            surfaceTintColor: ColorFamily.white,
            backgroundColor: ColorFamily.white,
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        children: [
                          Text(
                            "디데이 생성을 취소하시겠습니까?",
                            style: TextStyleFamily.dialogTitleTextStyle,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "지금까지 작성된 내용은 삭제됩니다",
                            style: TextStyleFamily.normalTextStyle,
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(
                                      ColorFamily.gray)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "취소",
                                style: TextStyleFamily.dialogButtonTextStyle,
                              )),
                          TextButton(
                              style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(
                                      ColorFamily.gray)),
                              onPressed: () {
                                Navigator.pop(context); // 다이얼로그 팝
                                Navigator.pop(context); // 작성 페이지 팝
                              },
                              child: const Text(
                                "확인",
                                style:
                                TextStyleFamily.dialogButtonTextStyle_pink,
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
