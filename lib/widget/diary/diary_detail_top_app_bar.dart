import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/text_style.dart';


class DiaryDetailTopAppBar extends StatefulWidget implements PreferredSizeWidget{
  const DiaryDetailTopAppBar({super.key});

  @override
  State<DiaryDetailTopAppBar> createState() => _DiaryDetailTopAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DiaryDetailTopAppBarState extends State<DiaryDetailTopAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: ColorFamily.cream,
      backgroundColor: ColorFamily.cream,
      centerTitle: true,
      // title: const Text(
      //     "",
      //   style: TextStyleFamily.appBarTitleLightTextStyle,
      // ),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
      ),
    );
  }
}
