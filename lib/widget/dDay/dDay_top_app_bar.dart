import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:woo_yeon_hi/style/color.dart';

import '../../screen/dDay/dDay_make_screen.dart';
import '../../style/text_style.dart';

class dDayTopAppBar extends StatefulWidget implements PreferredSizeWidget{
  const dDayTopAppBar({super.key});

  @override
  State<dDayTopAppBar> createState() => _dDayTopAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _dDayTopAppBarState extends State<dDayTopAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: ColorFamily.cream,
      backgroundColor: ColorFamily.cream,
      centerTitle: true,
      title: const Text("디데이", style: TextStyleFamily.appBarTitleBoldTextStyle,),
      leading: IconButton(
        splashColor: Colors.transparent,
        onPressed: () {
          Navigator.pop(context);
        },
        icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
      ),
      actions: [
        Row(
          children: [
            InkWell(
              splashColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const dDayMakeScreen()));
              },
              child: SizedBox(width: 40, height: 40, child: SvgPicture.asset('lib/assets/icons/add.svg', fit: BoxFit.none,)),
            ),
            const SizedBox(width: 15)
          ],
        )
      ],
    );
  }
}
