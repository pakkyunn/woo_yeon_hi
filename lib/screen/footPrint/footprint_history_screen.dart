import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/history_dao.dart';
import 'package:woo_yeon_hi/enums.dart';
import 'package:woo_yeon_hi/model/history_model.dart';
import 'package:woo_yeon_hi/model/photo_map_model.dart';
import 'package:woo_yeon_hi/screen/footPrint/footprint_history_detail_screen.dart';
import 'package:woo_yeon_hi/screen/footPrint/footprint_history_write_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';
import 'package:woo_yeon_hi/widget/footPrint/footprint_history_top_app_bar.dart';

import '../../dao/photo_map_dao.dart';
import '../../provider/footprint_provider.dart';
import '../../retrofit_interface/reverse_geo_coding_api.dart';
import '../../style/text_style.dart';

class FootprintHistoryScreen extends StatefulWidget {
  const FootprintHistoryScreen({super.key});

  @override
  State<FootprintHistoryScreen> createState() => FootprintHistoryScreenState();
}

class FootprintHistoryScreenState extends State<FootprintHistoryScreen> {
  // late Map<String, List<History>> historyMap;
  // final Dio _reverseGCDio = Dio();
  // late ReverseGeoCodingApi _reverseGCApi;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<FootprintHistoryGridViewProvider>(context, listen: false).fetchHistoryData(context);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 처음 빌드될 때가 아닌, 다른 화면에서 돌아왔을 때만 새로고침이 되도록 체크
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // setHttp();
    return Consumer<FootprintHistoryGridViewProvider>(
        builder: (context, provider, _) {
          return _isLoading
          ? const Center(
                      child: CircularProgressIndicator(
                        color: ColorFamily.pink,
                      ))
          : RefreshIndicator(
                    onRefresh: () async {
                      await _fetchData();
                      // setState(() {}); // 데이터가 갱신된 후 화면을 다시 그리기 위해 호출
                    },
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.all(10),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // 열의 개수
                              mainAxisSpacing: 5,
                              crossAxisSpacing: 5,
                              childAspectRatio: 1,
                            ),
                            delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                return makeHistoryItem(context, index, provider);
                              },
                              childCount: provider.historyList.length, // 항목 수
                            ),
                          ),
                        ),
                        // 추가 여백 공간을 위한 Sliver
                        SliverToBoxAdapter(
                          child: SizedBox(height: 70), // 플로팅 버튼이 가리지 않도록 할 높이
                        ),
                      ],
                    ),
                  );
                }
          );
        }


  // return ChangeNotifierProvider(
  //     create: (context) =>
  //         FootprintExpandedHistoryProvider(historyMap.keys.length),
  //     child: Consumer<FootprintExpandedHistoryProvider>(
  //         builder: (context, provider, _) {
  //           return Padding(
  //               padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
  //               child: Column(
  //                 children: [
  //                   SizedBox(
  //                     width: MediaQuery.of(context).size.width - 40,
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       children: [
  //                         TextButton(
  //                           onPressed: () {
  //                             provider.expandAll();
  //                           },
  //                           style: ButtonStyle(
  //                             overlayColor: MaterialStateProperty.all(
  //                                 Colors.transparent),
  //                           ),
  //                           child: Text(
  //                             "모두펼치기",
  //                             style: textStyle,
  //                           ),
  //                         ),
  //                         TextButton(
  //                           onPressed: () {
  //                             provider.collapseAll();
  //                           },
  //                           style: ButtonStyle(
  //                             overlayColor: MaterialStateProperty.all(
  //                                 Colors.transparent),
  //                           ),
  //                           child: Text(
  //                             "모두접기",
  //                             style: textStyle,
  //                           ),
  //                         )
  //                       ],
  //                     ),
  //                   ),
  //                   Expanded(
  //                       child: ListView.builder(
  //                           itemCount: historyMap.keys.length,
  //                           itemBuilder: (context, index) =>
  //                               makeHistory(context, index, provider,
  //                                   historyMap.keys.toList()[index]))),
  //                 ],
  //               ));
  //         }));


  // Widget makeHistory(BuildContext context, int index,
  //     FootprintExpandedHistoryProvider provider, String key) {
  //   return ExpansionTile(
  //     key: UniqueKey(),
  //     controlAffinity: ListTileControlAffinity.leading,
  //     tilePadding: EdgeInsets.zero,
  //     shape: const Border(),
  //     backgroundColor: Colors.transparent,
  //     iconColor: ColorFamily.black,
  //     dense: true,
  //     initiallyExpanded: provider.isExpandedList[index],
  //     expansionAnimationStyle: AnimationStyle(
  //         curve: Curves.ease, duration: const Duration(milliseconds: 300)),
  //     onExpansionChanged: (isExpanded) {
  //       provider.setExpansionState(index, isExpanded);
  //     },
  //     title: Text(
  //       key,
  //       style: TextStyleFamily.normalTextStyle,
  //     ),
  //     children: [
  //       SizedBox(
  //           height: 120,
  //           child: ListView.builder(
  //               scrollDirection: Axis.horizontal,
  //               itemCount: historyMap[key]!.length,
  //               itemBuilder: (context, itemIndex) => makeHistoryItem(
  //                   context,
  //                   itemIndex,
  //                   historyMap[key]![itemIndex],
  //                   key)))
  //     ],
  //   );
  // }

  Widget makeHistoryItem(BuildContext context, int index,
      FootprintHistoryGridViewProvider provider) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    FootprintHistoryDetailScreen(index)));
      },
      child: SizedBox(
        width: 120,
        height: 120,
        child: Card(
          color: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          elevation: 2,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: FutureBuilder(
                    future: getHistoryImage(
                        provider.historyList[index].historyImage.first),
                    builder: (context, snapshot) {
                      if (snapshot.hasData == false) {
                        return const SizedBox();
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text(
                              "network error",
                              style: TextStyleFamily.normalTextStyle,
                            ));
                      } else {
                        return snapshot.data!;
                      }
                    },
                  )),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Wrap(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff393939).withOpacity(0.6),
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5)), // 원하는 반지름 값
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              SizedBox(
                                  width: 120,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        provider
                                            .historyList[index].historyTitle,
                                        style: historyCardTextStyle,
                                      )
                                    ],
                                  )),
                              SizedBox(
                                  width: 120,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        provider.historyList[index].historyDate,
                                        style: historyCardTextStyle,
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> setHttp() async {
  //   await dotenv.load(fileName: ".env");
  //   _reverseGCDio.options.headers = {
  //     'X-NCP-APIGW-API-KEY-ID': dotenv.env['X_NCP_APIGW_API_KEY_ID'],
  //     'X-NCP-APIGW-API-KEY': dotenv.env['X_NCP_APIGW_API_KEY'],
  //   };
  //   _reverseGCApi = ReverseGeoCodingApi(_reverseGCDio);
  // }

  // Future<Map> getHisotryCategorization() async {
  //   Map<String, List<History>> historyCategory = {};
  //
  //   var historyList = await getHistory(context);
  //
  //   for (var history in historyList) {
  //     // var map = await getPhotoMapByMapIdx();
  //     // var place = await reverseGeoCoding(history.historyLocation, map.mapType);
  //     var place = await reverseGeoCoding(history.historyLocation);
  //
  //     if (place != null) {
  //       if (historyCategory[place] != null) {
  //         historyCategory[place]!.add(history);
  //       } else {
  //         historyCategory[place] = [history];
  //       }
  //     }
  //   }
  //
  //   return historyCategory;
  // }

//   Future<String?> reverseGeoCoding(GeoPoint coords) async {
//     try {
//       final response = await _reverseGCApi.reverseGeocode(
//           "${coords.longitude},${coords.latitude}", "legalcode", "json");
//       var result = response.results.first;
//
//       return "${result.region.area1.name} ${result.region.area2.name}";
//       // if (MapType.fromType(mapType)!.type == MapType.KOREA_FULL.type) {
//       //   // 지도 타입이 한국 전체 지도인경우 00시 00구까지 리턴
//       //   return "${result.region.area1.name} ${result.region.area2.name}";
//       // } else {
//       //   // 그 외 지도 타입은 좀 더 세부적인 정보 리턴
//       //   return "${result.region.area2.name} ${result.region.area3.name}";
//       // }
//     } catch (e) {
//       print("");
//       print("Error: $e");
//       print("");
//     }
//     return null;
//   }
// }

  TextStyle historyCardTextStyle = const TextStyle(
      fontFamily: FontFamily.mapleStoryLight,
      fontSize: 10,
      color: ColorFamily.white);

  // 모두 펼치기, 모두 접기 텍스트 스타일
  TextStyle textStyle = const TextStyle(
      fontFamily: FontFamily.mapleStoryLight,
      fontSize: 12,
      color: ColorFamily.black);

}