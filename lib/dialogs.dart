import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/text_style.dart';

void showBlackToast(String message){
  Fluttertoast.showToast(
      msg: message, //메세지입력
      toastLength: Toast.LENGTH_SHORT, //메세지를 보여주는 시간(길이)
      gravity: ToastGravity.BOTTOM, //위치지정
      timeInSecForIosWeb: 1, //ios및웹용 시간
      backgroundColor: ColorFamily.black,
      textColor: ColorFamily.white, //글자색
      fontSize: 14.0 //폰트사이즈
  );
}

void showPinkSnackBar(BuildContext context, String message){
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center, style: TextStyleFamily.normalTextStyle),
        backgroundColor: ColorFamily.pink,
        duration: const Duration(seconds: 1))
  );
}

void dialogTitleWithContent(BuildContext context, String title, String content, VoidCallback onCancel, VoidCallback onConfirm){
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
                    Column(
                      children: [
                        Text(
                          title,
                          style: TextStyleFamily.dialogTitleTextStyle,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          content,
                          style: TextStyleFamily.hintTextStyle,
                          textAlign: TextAlign.center,
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
                            onPressed: onCancel,
                            child: const Text(
                              "취소",
                              style: TextStyleFamily.dialogButtonTextStyle,
                            )),
                        TextButton(
                            style: ButtonStyle(
                                overlayColor: MaterialStateProperty.all(
                                    ColorFamily.gray)),
                            onPressed: onConfirm,
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
  );
}

void dialogOnlyTitle(BuildContext context, String title,VoidCallback onCancle, VoidCallback onConfirm){
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
                    Text(
                      title,
                      style: TextStyleFamily.dialogButtonTextStyle,
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
                            onPressed: onCancle,
                            child: const Text(
                              "취소",
                              style: TextStyleFamily.dialogButtonTextStyle,
                            )),
                        TextButton(
                            style: TextButton.styleFrom(
                                overlayColor: Colors.transparent),
                            onPressed: onConfirm,
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