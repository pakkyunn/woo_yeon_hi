import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/user_dao.dart';
import 'package:woo_yeon_hi/dialogs.dart';
import 'package:woo_yeon_hi/provider/login_register_provider.dart';

import '../../style/color.dart';
import '../../style/text_style.dart';

class LoverNicknameEditDialog extends StatefulWidget {
  LoverNicknameEditDialog({super.key});

  @override
  State<LoverNicknameEditDialog> createState() => _LoverNicknameEditDialogState();
}

class _LoverNicknameEditDialogState extends State<LoverNicknameEditDialog> {
  late TextEditingController loverNicknameController;
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    loverNicknameController = TextEditingController(text: userProvider.loverNickname);
  }

  @override
  Widget build(BuildContext context) {
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
                Column(
                  children: [
                    const Text(
                      "연인 별명 바꾸기",
                      style: TextStyleFamily.dialogButtonTextStyle,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: loverNicknameController,
                      textAlign: TextAlign.center,
                      cursorColor: ColorFamily.black,
                      maxLength: 10,
                      autofocus: true,
                      style: TextStyleFamily.normalTextStyle,
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          counter: SizedBox()),
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
                        style: TextButton.styleFrom(
                            overlayColor: Colors.transparent),
                        onPressed: (){Navigator.pop(context);},
                        child: const Text(
                          "취소",
                          style: TextStyleFamily.dialogButtonTextStyle,
                        )),
                    TextButton(
                        style: TextButton.styleFrom(
                            overlayColor: Colors.transparent),
                        onPressed: () async {
                          if(loverNicknameController.text.isNotEmpty){
                            await updateSpecificUserData(userProvider.userIdx, "lover_nickname", loverNicknameController.text);
                            await updateSpecificUserData(userProvider.loverIdx, "user_nickname", loverNicknameController.text);
                            userProvider.setLoverNickname(loverNicknameController.text);
                            Navigator.pop(context);
                            showPinkSnackBar(context, "연인의 별명을 바꾸었습니다!");
                          } else {
                            showBlackToast("별명을 입력해주세요!");
                          }
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
  }
}
