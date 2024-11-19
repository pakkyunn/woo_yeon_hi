import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';
import 'package:woo_yeon_hi/style/text_style.dart';

import '../../dialogs.dart';
import '../../provider/footprint_provider.dart';
import '../../retrofit_interface/place_search_api.dart';

class FootprintHistoryWritePlaceInfo extends StatefulWidget {
  FootprintHistoryWritePlaceInfo(this.provider, this.selectedPlace, {super.key});
  FootprintHistoryWriteProvider provider;
  Place selectedPlace;

  @override
  State<FootprintHistoryWritePlaceInfo> createState() =>
      _FootprintHistoryWritePlaceInfoState();
}

class _FootprintHistoryWritePlaceInfoState
    extends State<FootprintHistoryWritePlaceInfo> {
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 1,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
            color: ColorFamily.white,
            borderRadius: BorderRadius.circular(20), // 모서리를 둥글게 설정
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7 - 40,
                  child: Column(
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7 - 40,
                          child: Wrap(
                            spacing: 10, // 요소 간의 간격
                            children: [
                              Baseline(
                                baseline: 16.0, // 기준선 높이 (title의 폰트 크기에 맞춤)
                                baselineType: TextBaseline.alphabetic,
                                child: Text(
                                  widget.selectedPlace.title,
                                  style: TextStyleFamily.normalTextStyle,
                                ),
                              ),
                              Baseline(
                                baseline: 16.0, // 동일한 기준선 높이
                                baselineType: TextBaseline.alphabetic,
                                child: Text(
                                  widget.selectedPlace.category,
                                  style: const TextStyle(
                                    fontFamily: FontFamily.mapleStoryLight,
                                    fontSize: 10,
                                    color: ColorFamily.gray,
                                  ),
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7 - 40,
                        child: RichText(
                          text: TextSpan(
                            text: widget.selectedPlace.roadAddress,
                            style: const TextStyle(
                              fontFamily: FontFamily.mapleStoryLight,
                              fontSize: 14,
                              color: ColorFamily.black,
                            ),
                          ),
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  splashColor: ColorFamily.gray,
                  onTap: () {
                    dialogTitleWithContent(
                        context,
                        widget.selectedPlace.title,
                        "지역을 선택하시겠습니까?",
                        () => _onCancle_back(context),
                        () => _onConfirm_back(widget.provider, context, widget.selectedPlace));
                  },
                  child: SvgPicture.asset('lib/assets/icons/add.svg'),
                )
              ],
            ),
          ),
        ));
  }
}

void _onCancle_back(BuildContext context) {
  Navigator.pop(context);
}

void _onConfirm_back(FootprintHistoryWriteProvider provider, BuildContext context, Place selectedPlace) {
  provider.setPlace(selectedPlace);
  Navigator.pop(context); // 다이얼로그 팝
  Navigator.pop(context); // 일기 작성 페이지 팝
}
