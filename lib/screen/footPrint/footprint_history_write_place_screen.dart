import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/retrofit_interface/place_search_api.dart';
import 'package:woo_yeon_hi/style/color.dart';

import '../../enums.dart';
import '../../provider/footprint_provider.dart';
import '../../retrofit_interface/reverse_geo_coding_api.dart';
import '../../style/font.dart';
import '../../style/text_style.dart';
import '../../widget/footPrint/footprint_history_write_place_info.dart';

class FootprintHistoryWritePlaceScreen extends StatefulWidget {
  FootprintHistoryWritePlaceScreen(this.provider, this.mapType, {super.key});

  FootprintHistoryWriteProvider provider;
  int mapType;

  @override
  State<FootprintHistoryWritePlaceScreen> createState() =>
      _FootprintHistoryWritePlaceScreenState();
}

class _FootprintHistoryWritePlaceScreenState
    extends State<FootprintHistoryWritePlaceScreen> {
  late NaverMapController _mapController;
  final searchBarController = FloatingSearchBarController();
  final Dio _searchDio = Dio();
  final Dio _reverseGCDio = Dio();
  late PlaceSearchApi _placeSearchApi;
  late ReverseGeoCodingApi _reverseGCApi;
  OverlayInfo overlayInfo = OverlayInfo.KOREA_FULL;
  Place _selectedPlace = Place(title: "", link: "", category: "", description: "", telephone: "", address: "", roadAddress: "", mapx: "", mapy: "");

  void _onMapCreated(NaverMapController controller) {
    _mapController = controller;
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      if(widget.provider.selectedPlace != null){

        // 카드뷰
        setState(() {
          _selectedPlace = widget.provider.selectedPlace!;
        });

        // 마커 이미지 최초 생성
        final iconImage = await NOverlayImage.fromWidget(
            widget: SvgPicture.asset('lib/assets/icons/marker_fill_white.svg'),
            size: const Size(55, 55),
            context: context);

        // 현재 선택된 장소 마커 표시
        final selectedMarker = NMarker(
          id: 'dummy_marker',
          position: convertCoordinate(widget.provider.selectedPlace!.mapx,
              widget.provider.selectedPlace!.mapy),
          icon: iconImage,
        );

        await _mapController.addOverlay(selectedMarker);

        _mapController.updateCamera(NCameraUpdate.scrollAndZoomTo(
            target: convertCoordinate(widget.provider.selectedPlace!.mapx,
                widget.provider.selectedPlace!.mapy), zoom: 16));

        // 초기화 완료 로그
        debugPrint('지도 초기화 완료');
      }
    } catch (e) {
      debugPrint('지도 초기화 중 에러 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    setHttp();

    return ChangeNotifierProvider(
      create: (context) => FootprintPhotoMapOverlayProvider(),
      child: Consumer<FootprintPhotoMapOverlayProvider>(
          builder: (context, overlayProvider, _) {
        return Scaffold(
            backgroundColor: ColorFamily.cream,
            // appBar: const FootprintHistoryEditPlaceTopAppBar(),
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                NaverMap(
                    onMapReady: (NaverMapController controller) {
                      _onMapCreated(controller);
                      _mapController = controller;
                    },
                    onSymbolTapped: (NSymbolInfo symbolInfo) async {
                      var roadaddr =
                          await reverseGeoCoding(symbolInfo.position);

                      // 검색창 심볼 이름 삽입
                      // searchBarController.query = symbolInfo.caption;

                      // // 검색 결과 비우기
                      // widget.provider.clearSearchPlace();

                      // 심볼 이름으로 검색
                      await searchPlace(symbolInfo.caption);
                      if (widget.provider.searchPlaces.isNotEmpty) {
                        // 첫 번째 항목으로 selectedPlace 설정
                        setState(() {
                          _selectedPlace = widget.provider.searchPlaces[0];
                        });
                        // widget.provider
                        //     .setPlace(widget.provider.searchPlaces[0]);
                      }
                      // // 정보 변경
                      // widget.provider.changeSelectedPlaceInfo(symbolInfo.caption, roadaddr!);
                      // 카메라 이동
                      _mapController.updateCamera(NCameraUpdate.scrollAndZoomTo(
                          target: symbolInfo.position));
                      // 마커 찍기
                      await _addMarkerOverlay(symbolInfo.position);
                      // // 카메라 이동
                      // _mapController.updateCamera(NCameraUpdate.scrollAndZoomTo(
                      //     target: symbolInfo.position,
                      //     zoom: 16));

                      setState(() {});
                    },
                    options: NaverMapViewOptions(
                        consumeSymbolTapEvents: false,
                        locale: NLocale.fromLocale(const Locale('ko', 'KR')),
                        scaleBarEnable: false,
                        logoClickEnable: false,
                        minZoom: overlayInfo.zoom,
                        initialCameraPosition: NCameraPosition(
                          target: overlayInfo.coordinate,
                          zoom: overlayInfo.zoom,
                        ))),
                FloatingSearchBar(
                  controller: searchBarController,
                  borderRadius: BorderRadius.circular(20),
                  automaticallyImplyBackButton: false,
                  iconColor: ColorFamily.black,
                  hint: "장소 검색",
                  hintStyle: TextStyleFamily.hintTextStyle,
                  queryStyle: TextStyleFamily.normalTextStyle,
                  clearQueryOnClose: false,
                  onSubmitted: (query) async {
                    // 검색
                    await searchPlace(query);
                  },
                  leadingActions: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
                    )
                  ],
                  builder: (context, transition) {
                    if (widget.provider.searchPlaces.isNotEmpty) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Material(
                            color: Colors.white,
                            elevation: 4.0,
                            child: SizedBox(
                              height: 300,
                              child: ListView.builder(
                                  itemCount:
                                      widget.provider.searchPlaces.length,
                                  itemBuilder: (context, index) =>
                                      makeSearchResultItem(context, index)),
                            )),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                // 장소 카드뷰 생성
                _selectedPlace.title != ""
                    ? Positioned(
                        bottom: 40,
                        left: 20,
                        right: 20,
                        child: FootprintHistoryWritePlaceInfo(widget.provider, _selectedPlace))
                    : const SizedBox()
              ],
            ));
      }),
    );
  }

  Future<NLatLng> _addMarkerOverlay(NLatLng? position) async {
    _mapController.clearOverlays();
    late NLatLng coordinate;
    if (position != null) {
      coordinate = position;
    } else {
      // 좌표계 변환
      coordinate = convertCoordinate(_selectedPlace.mapx,
          _selectedPlace.mapy);
    }

    try {
      debugPrint('아이콘 이미지 생성 시작');

      final iconImage = await NOverlayImage.fromWidget(
          widget: SvgPicture.asset('lib/assets/icons/marker_fill_white.svg'),
          size: const Size(55, 55),
          context: context);

      debugPrint('아이콘 이미지 생성 완료');

      final marker = NMarker(
          id: 'marker_${coordinate.latitude}_${coordinate.longitude}_${DateTime.now().millisecondsSinceEpoch}',
          position: coordinate,
          icon: iconImage);

      debugPrint('마커 추가 시작');

      _mapController.addOverlay(marker);

      debugPrint('마커 추가 완료');

      setState(() {});

      debugPrint('상태 갱신 완료');

    } catch (e) {
      debugPrint('마커 추가 중 오류 발생: $e');
    }
    return coordinate;
  }

  Future<void> setHttp() async {
    await dotenv.load(fileName: ".env");
    _searchDio.options.headers = {
      'X-Naver-Client-Id': dotenv.env['NAVER_SEARCH_CLIENT_ID'],
      'X-Naver-Client-Secret': dotenv.env['NAVER_SEARCH_CLIENT_SECRET'],
    };
    _placeSearchApi = PlaceSearchApi(_searchDio);

    _reverseGCDio.options.headers = {
      'X-NCP-APIGW-API-KEY-ID': dotenv.env['X_NCP_APIGW_API_KEY_ID'],
      'X-NCP-APIGW-API-KEY': dotenv.env['X_NCP_APIGW_API_KEY'],
    };
    _reverseGCApi = ReverseGeoCodingApi(_reverseGCDio);
  }

  Future<void> searchPlace(String query) async {
    try {
      final response = await _placeSearchApi.search(query, 5);
      widget.provider.clearSearchPlace();
      for (var item in response.items) {
        widget.provider.addSearchPlace(item);
      }
      setState(() {});
    } catch (e) {
      print("");
      print("Error: $e");
      print("");
    }
  }

  Future<String?> reverseGeoCoding(NLatLng coords) async {
    try {
      final response = await _reverseGCApi.reverseGeocode(
          "${coords.longitude},${coords.latitude}", "roadaddr", "json");

      var result = response.results.first;
      var region = result.region;

      var roadaddr = result.land!.number2.isEmpty
          ? "${region.area1.name} ${region.area2.name} ${region.area3.name} ${region.area4.name} ${result.land!.number1}"
          : "${region.area1.name} ${region.area2.name} ${region.area3.name} ${region.area4.name} ${result.land!.number1}-${result.land!.number2}";

      return roadaddr;
    } catch (e) {
      print("");
      print("Error: $e");
      print("");
    }
    return null;
  }

  Widget makeSearchResultItem(BuildContext context, int index) {
    return InkWell(
      onTap: () async {
        setState(() {
          _selectedPlace = widget.provider.searchPlaces[index];
        });
        // widget.provider.setPlace(widget.provider.searchPlaces[index]);
        // // 검색 결과 비우기
        // widget.provider.clearSearchPlace();
        // 서치바 닫음
        searchBarController.close();
        // 마커 찍기
        var coordinate = await _addMarkerOverlay(null);
        // 카메라 이동
        await _mapController.updateCamera(NCameraUpdate.scrollAndZoomTo(
            target: coordinate, // 서울
            zoom: 16));
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          children: [
            index != 0
            ? SizedBox(height: 10)
            : SizedBox(),
            Row(
              children: [
                Flexible(
                  child: Text(
                    widget.provider.searchPlaces[index].title,
                    style: TextStyleFamily.normalTextStyle,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Flexible(
                  child: Text(
                    widget.provider.searchPlaces[index].category,
                    style: const TextStyle(
                        fontFamily: FontFamily.mapleStoryLight,
                        fontSize: 10,
                        color: ColorFamily.gray),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Flexible(
                    child: Text(
                  widget.provider.searchPlaces[index].roadAddress,
                  style: const TextStyle(
                      fontFamily: FontFamily.mapleStoryLight,
                      fontSize: 12,
                      color: ColorFamily.black),
                )),
              ],
            ),
            SizedBox(height: 15),
            index != widget.provider.searchPlaces.length-1
                ? const Divider(
              color: ColorFamily.gray,
              thickness: 0.5,
              height: 0,
            )
                : SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

NLatLng convertCoordinate(String x, String y) {
  var double_x = double.tryParse(x) ?? 0.0;
  var double_y = double.tryParse(y) ?? 0.0;

  var converted = NLatLng(
    (double_y / pow(10.0, y.length - 2)),
    (double_x / pow(10.0, x.length - 3)),
  );
  return converted;
}
