import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';

import '../../dao/user_dao.dart';
import '../../dialogs.dart';
import '../../provider/login_register_provider.dart';
import '../../style/text_style.dart';

class HomeUiSettingScreen extends StatefulWidget {
  const HomeUiSettingScreen({super.key});

  @override
  State<HomeUiSettingScreen> createState() => _HomeUiSettingScreenState();
}

class _HomeUiSettingScreenState extends State<HomeUiSettingScreen> {
  var presetImages = [
    "lib/assets/images/home_preset_1.png",
    "lib/assets/images/home_preset_2.png",
    "lib/assets/images/home_preset_3.png",
    "lib/assets/images/home_preset_4.png",
  ];

  late int presetIndex;

  @override
  void initState() {
    super.initState();
    _dataInitiate();
  }

  Future<void> _dataInitiate() async {
    var provider = Provider.of<UserProvider>(context, listen: false);
    presetIndex = provider.homePresetType;
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var deviceHeight = MediaQuery.of(context).size.height;

    return Consumer<UserProvider>(builder: (context, provider, child) {
      return Scaffold(
          appBar: AppBar(
            surfaceTintColor: ColorFamily.cream,
            backgroundColor: ColorFamily.cream,
            centerTitle: true,
            title: const Text(
              "홈 화면 스타일",
              style: TextStyleFamily.appBarTitleLightTextStyle,
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
            ),
            actions: [
              IconButton(
                  onPressed: () async {
                    await updateSpecificUserData(
                        provider.userIdx, 'home_preset_type', presetIndex);
                    provider.setHomePresetType(presetIndex);
                    Navigator.pop(context);
                    showPinkSnackBar(context, '홈 화면 설정이 저장되었습니다');
                  },
                  icon: SvgPicture.asset('lib/assets/icons/done.svg'))
            ],
          ),
          body: Container(
              width: deviceWidth,
              height: deviceHeight,
              padding: const EdgeInsets.all(20),
              color: ColorFamily.cream,
              child: Column(children: [
                SizedBox(height: deviceHeight * 0.05),
                presetIndex == provider.homePresetType
                    ? SizedBox(
                        height: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "lib/assets/images/tick-circle_36px.png",
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              "현재 적용됨",
                              style: TextStyle(
                                  color: ColorFamily.black,
                                  fontSize: 12,
                                  fontFamily: FontFamily.mapleStoryLight),
                            )
                          ],
                        ),
                      )
                    : const SizedBox(height: 20),
                const SizedBox(height: 5),
                SizedBox(
                  height: deviceHeight * 0.65,
                  child: Swiper(
                    index: presetIndex,
                    viewportFraction: 0.6,
                    scale: 0.7,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          Container(
                              decoration: presetIndex == index
                                  ? BoxDecoration(
                                      border: Border.all(
                                          color: ColorFamily.pink, width: 1.5),
                                      borderRadius: BorderRadius.circular(20))
                                  : BoxDecoration(
                                      border: Border.all(
                                          color: Colors.transparent,
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(20)),
                              child: Material(
                                  borderRadius: BorderRadius.circular(20),
                                  elevation: 1.0,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        presetImages[index],
                                        fit: BoxFit.cover,
                                      )))),
                        ],
                      );
                    },
                    itemCount: presetImages.length,
                    loop: false,
                    autoplay: false,
                    onIndexChanged: (index) {
                      setState(() {
                        presetIndex = index;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 15),
                AnimatedSmoothIndicator(
                  activeIndex: presetIndex,
                  count: presetImages.length,
                  effect: const ScrollingDotsEffect(
                    dotColor: ColorFamily.beige,
                    activeDotColor: ColorFamily.pink,
                    spacing: 10,
                    dotHeight: 10,
                    dotWidth: 10,
                    activeDotScale: 1.5,
                  ),
                )
              ])));
    });
  }
}
