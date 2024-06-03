import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:woo_yeon_hi/screen/register/birthday_setting_screen.dart';
import 'package:woo_yeon_hi/screen/register/d_day_setting_screen.dart';
import 'package:woo_yeon_hi/screen/register/register_screen.dart';
import 'package:woo_yeon_hi/style/text_style.dart';

import '../../style/color.dart';
import '../../style/font.dart';

class NickNameSettingScreen extends StatefulWidget {
  final bool isHost;

  NickNameSettingScreen({super.key, required this.isHost});

  @override
  State<NickNameSettingScreen> createState() => _NickNameSettingScreenState();
}

class _NickNameSettingScreenState extends State<NickNameSettingScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: ColorFamily.cream,
        padding: EdgeInsets.all(20),
        child: Stack(children: [
            ListView(children: [
              Column(children: [
                  Container(
                      height: 750,
                      child: Column(
                        children: [
                          Container(
                            height: 700,
                            child: Column(
                              children: [
                                Padding(padding: EdgeInsets.only(top: 60)),
                                widget.isHost
                                ? Container(
                                  child: Text(
                                    "3 / 5",
                                    style: TextStyle(
                                        fontFamily: FontFamily.mapleStoryBold,
                                        fontSize: 15,
                                        color: ColorFamily.pink),
                                  ),
                                )
                                : Container(
                                  child: Text(
                                    "2 / 4",
                                    style: TextStyle(
                                        fontFamily: FontFamily.mapleStoryBold,
                                        fontSize: 15,
                                        color: ColorFamily.pink),
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(top: 20)),
                                widget.isHost
                                ? Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset("lib/assets/icons/heart_fill.svg", height: 24),
                                      SvgPicture.asset("lib/assets/icons/triple_right_arrow.svg", height: 24),
                                      SvgPicture.asset("lib/assets/icons/heart_fill.svg", height: 24),
                                      SvgPicture.asset("lib/assets/icons/triple_right_arrow.svg", height: 24),
                                      SvgPicture.asset("lib/assets/icons/heart_fill.svg", height: 24),
                                      SvgPicture.asset("lib/assets/icons/triple_right_arrow.svg", height: 24),
                                      SvgPicture.asset("lib/assets/icons/heart_outlined.svg", height: 24),
                                      SvgPicture.asset("lib/assets/icons/triple_right_arrow.svg", height: 24),
                                      SvgPicture.asset("lib/assets/icons/heart_outlined.svg", height: 24),
                                    ],
                                  ),
                                )
                                : Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset("lib/assets/icons/heart_fill.svg", height: 24),
                                        SvgPicture.asset("lib/assets/icons/triple_right_arrow.svg", height: 24),
                                        SvgPicture.asset("lib/assets/icons/heart_fill.svg", height: 24),
                                        SvgPicture.asset("lib/assets/icons/triple_right_arrow.svg", height: 24),
                                        SvgPicture.asset("lib/assets/icons/heart_outlined.svg", height: 24),
                                        SvgPicture.asset("lib/assets/icons/triple_right_arrow.svg", height: 24),
                                        SvgPicture.asset("lib/assets/icons/heart_outlined.svg", height: 24),
                                      ],
                                  ),
                                  ),
                                Padding(padding: EdgeInsets.only(top: 50)),
                                Container(
                                  child: Text(
                                    "연인의 별명을 지어주세요!",
                                    style: TextStyle(
                                        color: ColorFamily.black,
                                        fontSize: 15,
                                        fontFamily: FontFamily.mapleStoryLight),
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(top: 175)),
                                Container(
                                  width: 250,
                                  child: TextField(
                                    onTapOutside: (event) {
                                      FocusScope.of(context).unfocus();
                                    },
                                    decoration: InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: ColorFamily.black))),
                                    cursorColor: ColorFamily.black,
                                    maxLength: 10,
                                    keyboardType: TextInputType.text,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: ColorFamily.black,
                                        fontSize: 20,
                                        fontFamily: FontFamily.mapleStoryLight),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.only(left: 50)),
                                widget.isHost
                                ? Expanded(
                                  child: Container(
                                    child: Material(
                                      color: ColorFamily.white,
                                      elevation: 0.5,
                                      shadowColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DdaySettingScreen(isHost: widget.isHost)));
                                          },
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          child:
                                          Container(
                                                height: 40,
                                                width: 120,
                                                child:
                                                Container(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "이전",
                                                    style: TextStyleFamily.normalTextStyle,
                                                  ),
                                                )
                                          )
                                  ),
                                    ),
                                  ),
                                )
                                : Expanded(
                                  child: Container(height: 40, width: 150),
                                ),
                                Padding(padding: EdgeInsets.only(left: 20)),
                                Expanded(
                                  child: Material(
                                    color: ColorFamily.beige,
                                    elevation: 0.5,
                                    shadowColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BirthdaySettingScreen(isHost: widget.isHost)));
                                      },
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: Container(
                                          height: 40,
                                          width: 120,
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "다음",
                                              style: TextStyleFamily.normalTextStyle,
                                            ),
                                          )),
                                    ),
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(right: 50)),
                              ],
                            ),
                          ),
                        ],
                      )),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 16, 16, 0),
                        child: TextButton(
                          style: ButtonStyle(
                              overlayColor: MaterialStateProperty.all<Color>(
                                  ColorFamily.beige)),
                          onPressed: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        RegisterScreen()));
                          },
                          child: Column(
                            children: [
                              Text(
                                "로그아웃",
                                style: TextStyleFamily.normalTextStyle,
                              )
                            ],
                          ),
                        ),
                      ))
                ],
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
