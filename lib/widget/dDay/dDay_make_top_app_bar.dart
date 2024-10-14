import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/model/dDay_model.dart';
import 'package:woo_yeon_hi/provider/dDay_provider.dart';

import '../../dao/d_day_dao.dart';
import '../../dialogs.dart';
import '../../provider/login_register_provider.dart';
import '../../style/color.dart';
import '../../style/text_style.dart';
import '../../utils.dart';

class dDayMakeTopAppBar extends StatefulWidget implements PreferredSizeWidget{
  dDayMakeTopAppBar({super.key});

  @override
  State<dDayMakeTopAppBar> createState() => _dDayMakeTopAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _dDayMakeTopAppBarState extends State<dDayMakeTopAppBar> {
  DdayModel? dDayModel;

  Future<void> _setDdayModel (BuildContext context) async {
    var dDayMakeProvider = Provider.of<DdayMakeProvider>(context, listen: false);

    int dDayIdx = await getDdaySequence() + 1;
    await setDdaySequence(dDayIdx);
    int userIdx = Provider.of<UserProvider>(context, listen: false).userIdx;
    String dDayTitle = dDayMakeProvider.titleController.text;
    String dDayDsc = dDayMakeProvider.descriptionController.text;
    String dDayDate = dateToStringWithDayLight(dDayMakeProvider.selectedDay!);

    setState(() {
      dDayModel = DdayModel(user_idx: userIdx, dDay_idx: dDayIdx, title: dDayTitle, description: dDayDsc, date: dDayDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DdayMakeProvider>(builder: (context, provider, child) {
      return AppBar(
        surfaceTintColor: ColorFamily.cream,
        backgroundColor: ColorFamily.cream,
        centerTitle: true,
        title: const Text("디데이 생성", style: TextStyleFamily.appBarTitleLightTextStyle,),
        leading: IconButton(
          splashColor: Colors.transparent,
          onPressed: () {
            if(provider.titleController.text.isNotEmpty || provider.descriptionController.text.isNotEmpty){
              _showBackDialog(context);
            }
            else{
              Navigator.pop(context);
            }
          },
          icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
        ),
        actions: [
          Row(
            children: [
              InkWell(
                splashColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                onTap: () async {
                  if(provider.titleController.text.isEmpty){
                    showBlackToast("내용을 입력해주세요");
                  }
                  else{
                    await _setDdayModel(context);
                    await addDday(dDayModel!);
                    var dDayList = await getDdayList(context);
                    Provider.of<DdayProvider>(context, listen: false).setDdayList(dDayList);
                    initProvider(context);
                    showPinkSnackBar(context, "디데이가 생성되었습니다");
                    Navigator.pop(context);
                  }
                },
                child: SizedBox(width: 40, height: 40, child: SvgPicture.asset('lib/assets/icons/done.svg', fit: BoxFit.none,)),
              ),
              const SizedBox(width: 15)
            ],
          )
          // IconButton(
          //   splashColor: Colors.amber,
          //   onPressed: (){
          //     if(widget.provider.title.text.isEmpty && widget.provider.content.text.isEmpty){
          //       showBlackToast("내용을 입력해주세요");
          //     }
          //     else{
          //       showPinkSnackBar(context, "디데이가 생성되었습니다");
          //       Navigator.pop(context);
          //     }
          //   },
          //   icon: SvgPicture.asset('lib/assets/icons/done.svg'),
          // )
        ],
      );
    },
    );
  }

  void initProvider (BuildContext context){
    var dDayMakeProvider = Provider.of<DdayMakeProvider>(context, listen: false);

    dDayMakeProvider.titleController.clear();
    dDayMakeProvider.descriptionController.clear();
    dDayMakeProvider.setSelectedDay(null);
    dDayMakeProvider.setFocusedDay(DateTime.now());
  }

  void _showBackDialog(BuildContext context) {
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
                                initProvider(context);
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
