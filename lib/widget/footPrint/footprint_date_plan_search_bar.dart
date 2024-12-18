import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/provider/footprint_provider.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';
import 'package:woo_yeon_hi/style/text_style.dart';

import '../../retrofit_interface/place_search_api.dart';
import '../../retrofit_interface/reverse_geo_coding_api.dart';

class FootprintDatePlanSearchBar extends StatefulWidget {
  const FootprintDatePlanSearchBar({super.key});

  @override
  State<FootprintDatePlanSearchBar> createState() => _FootprintDatePlanSearchBarState();
}

class _FootprintDatePlanSearchBarState extends State<FootprintDatePlanSearchBar> {
  final searchBarController = FloatingSearchBarController();
  final Dio _searchDio = Dio();
  final Dio _reverseGCDio = Dio();
  late PlaceSearchApi _placeSearchApi;
  late ReverseGeoCodingApi _reverseGCApi;

  @override
  Widget build(BuildContext context) {
    setHttp();
    return Consumer<DatePlanMakeSlidableProvider>(
      builder: (context, provider, child) {
        return FloatingSearchBar(
          showCursor: true,
          backgroundColor: ColorFamily.white,
          hint: '장소 검색',
          hintStyle: TextStyleFamily.hintTextStyle,
          elevation: 1,
          width: double.maxFinite,
          height: 50,
          clearQueryOnClose: false,
          borderRadius: BorderRadius.circular(20),
          automaticallyImplyBackButton: false,  // 뒤로가기 버튼 활성화 설정
          axisAlignment: 0.0,  // 검색 바가 화면에서 수평으로 중앙에 정렬되도록 설정
          openAxisAlignment: 0.0,  // 검색 바가 열렸을 때 수평으로 중앙에 정렬되도록 설정
          scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),  // 검색 바가 열릴 때의 스크롤 사이 간격
          transitionDuration: const Duration(milliseconds: 600),  // 검색 바의 열림/닫힘 애니메이션 지속 시간
          transitionCurve: Curves.easeInOut,  // 애니메이션의 커브 설정
          physics: const BouncingScrollPhysics(),  // 스크롤 동작을 바운싱으로 설정
          transition: CircularFloatingSearchBarTransition(),  // 검색 바의 열림/닫힘 애니메이션을 원형으로 설정
          debounceDelay: const Duration(milliseconds: 500),  // 검색어 입력 중 콜백 함수 딜레이 설정
          queryStyle: TextStyleFamily.normalTextStyle, // 검색어 입력 스타일. (검색된 항목의 title과 동일하게 설정)
          onSubmitted: (query) async {
            await searchPlace(query, provider);
          },

          // 검색 바를 위한 TextController 설정
          controller: searchBarController,

          // 검색 결과를 표시할 위젯을 빌드하는 함수
          builder: (context, transition) {
            if(provider.searchPlaces.isNotEmpty){
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),  // 검색 결과 리스트의 모서리를 둥글게 설정
                child: Material(
                  color: Colors.white,  // 검색 결과 리스트의 배경색 설정
                  elevation: 1.0,  // 검색 결과 리스트의 그림자 높이 설정
                  child: SizedBox(
                    height:  MediaQuery.of(context).size.height * 0.3 ,
                    child: SingleChildScrollView(
                      child: Column(
                        //mainAxisSize: MainAxisSize.min,  // 검색 결과 리스트의 크기에 맞게 최소화하여 설정
                        children: List.generate(provider.searchPlaces.length, (index) {
                          final item = provider.searchPlaces[index];
                          return makeListView(item, index);
                        }),
                      ),
                    ),
                  ),
                ),
              );
            }
            else{
              return const SizedBox();
            }
          },
        ) ;
      }
    );
  }

  // 검색된 항목 아이템
  Widget makeListView(Place item, int index){
    return Column(
      children: [
        makeSlidable(item, index),
        const Divider(
          height: 0.5,
          color: ColorFamily.gray,
        ),
      ],
    );
  }

  // 검색된 항목을 슬라이드 항목으로
  Widget makeSlidable(Place item, int index){
    return Consumer<DatePlanMakeSlidableProvider>(
      builder: (context, provider, child) {
        return InkWell(
          onTap: (){
            provider.setPlace(item);
            searchBarController.close();
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(item.title, style: TextStyleFamily.normalTextStyle)),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(item.category, style: const TextStyle(
                              fontFamily: FontFamily.mapleStoryLight,
                              fontSize: 10,
                              color: ColorFamily.gray)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(child: Text(item.roadAddress, style: TextStyleFamily.normalTextStyle)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> searchPlace(String query, DatePlanMakeSlidableProvider provider) async {
    try {
      final response = await _placeSearchApi.search(query, 5);
      provider.clearSearchPlace();
      for (var item in response.items) {
        provider.addSearchPlace(item);
      }
      setState(() {});
    } catch (e) {
      print("");
      print("Error: $e");
      print("");
    }
  }

  Future<void> setHttp() async {
    await dotenv.load(fileName: ".env");
    _searchDio.options.headers = {
      'X-Naver-Client-Id': dotenv.env['NAVER_SEARCH_CLIENT_ID'],
      'X-Naver-Client-Secret': dotenv.env['NAVER_SEARCH_CLIENT_SECRET'],
    };
    _placeSearchApi = PlaceSearchApi(_searchDio);

    _reverseGCDio.options.headers = {
      'X-NCP-APIGW-API-KEY-ID' : dotenv.env['X-NCP-APIGW-API-KEY-ID'],
      'X-NCP-APIGW-API-KEY': dotenv.env['X-NCP-APIGW-API-KEY'],
    };
    _reverseGCApi = ReverseGeoCodingApi(_reverseGCDio);
  }
}
