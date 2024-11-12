import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/history_dao.dart';
import 'package:woo_yeon_hi/dao/photo_map_dao.dart';
import 'package:woo_yeon_hi/model/history_model.dart';
import 'package:woo_yeon_hi/model/photo_map_model.dart';
import 'package:woo_yeon_hi/screen/footPrint/footprint_history_detail_screen.dart';
import 'package:woo_yeon_hi/style/text_style.dart';
import 'package:woo_yeon_hi/widget/footPrint/footprint_photo_map_detail_top_app_bar.dart';


import '../../enums.dart';
import '../../provider/footprint_provider.dart';
import '../../style/color.dart';
import '../../widget/footPrint/footprint_photo_map_marker.dart';
import 'footprint_history_write_screen.dart';
import 'footprint_photo_map_detail_screen.dart';

class FootprintPhotoMapScreen extends StatefulWidget {
  const FootprintPhotoMapScreen({super.key});

  @override
  State<FootprintPhotoMapScreen> createState() =>
      _FootprintPhotoMapScreenState();
}

class _FootprintPhotoMapScreenState extends State<FootprintPhotoMapScreen> {
  late NaverMapController _mapController;
  var globalKey = GlobalKey();
  OverlayInfo overlayInfo = OverlayInfo.KOREA_FULL;
  bool isLoading = true;  // 로딩 상태 변수

  Future<bool> getHistoryData() async {
    var provider = Provider.of<FootprintPhotoMapHistoryProvider>(context, listen: false);
    var historyList = await getHistory(context);
    provider.setHistoryList(historyList);

    return true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getHistoryData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FootprintPhotoMapHistoryProvider, FootprintPhotoMapOverlayProvider>(
        builder: (context, photoMapHistoryProvider, photoMapOverlayProvider, _) {
          return FutureBuilder(
      future: getHistoryData(),
      builder: (context, snapshot){
        if(snapshot.hasData == false){
          return const Center(child: CircularProgressIndicator(color: ColorFamily.pink));
        }else if(snapshot.hasError){
          return const Center(child: Text("error"));
        }else{
          return Stack(
                    children: [
                    RepaintBoundary(
                        key: globalKey,
                      child: NaverMap(
                        onMapReady: (NaverMapController controller) async {
                          _mapController = controller;
                          loadMapData(photoMapHistoryProvider.historyList, photoMapOverlayProvider);
                        },
                        options: NaverMapViewOptions(
                            scaleBarEnable: false,
                            logoClickEnable: false,
                            minZoom: overlayInfo.zoom,
                            locale: NLocale.fromLocale(const Locale('ko', 'KR')),
                            // 지도 언어 한국어
                            initialCameraPosition: NCameraPosition(
                                target: NLatLng(
                                    overlayInfo.latitude, overlayInfo.longitude),
                                zoom: overlayInfo.zoom)),
                      )),
                      if (isLoading)
                        Center(
                          child: const Center(
                              child: CircularProgressIndicator(
                                color: ColorFamily.pink,
                              ))
                        ),
                    ]
                  );
              }
        });
                },
        );
  }

  Future<void> loadMapData(List<History> historyList, FootprintPhotoMapOverlayProvider provider) async {
    setState(() {
      isLoading = true;
    });
    if (!mounted) return;
    await _preloadImages(historyList);
    await _addMarkerOverlay(provider, historyList);
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _preloadImages(List<History> historyList) async {
    if (!mounted) return;
    for (var history in historyList) {
      final imageURL = await FirebaseStorage.instance
          .ref('image/history/${history.historyImage[0]}')
          .getDownloadURL();
      final imageProvider = NetworkImage(imageURL);

      try {
        if (mounted) {
          await precacheImage(imageProvider, context);
        }
      } catch (e) {
        print("Failed to cache image: $imageURL - $e"); // 캐싱 실패 로그
      }
    }
    if (!mounted) return;
  }

  // Future<void> _addMarkerOverlay(
  //     FootprintPhotoMapOverlayProvider provider, List<History> historyList) async {
  //   if(mounted){
  //     await _addMarker(provider, historyList);
  //     await _mapController.addOverlayAll(provider.markers.toSet());
  //   }
  // }

  Future<void> _addMarkerOverlay(
      FootprintPhotoMapOverlayProvider provider, List<History> historyList) async {
    if (!mounted) return;
    if (mounted) {
      await _addMarker(provider, historyList);
    }
    if (!mounted) return;
  }

  // Future<void> _addMarker(FootprintPhotoMapOverlayProvider provider, List<History> historyList) async {
  //   if(mounted){
  //     for (var i = 0; i < historyList.length; i++) {
  //       var image = await getHistoryImage(historyList[i].historyImage[0]);
  //       if (!mounted) return;
  //       final markerWidget = PhotoMapMarker(image);
  //
  //       final iconImage = await NOverlayImage.fromWidget(
  //           widget: markerWidget, size: const Size(70, 80), context: context);
  //
  //       final marker = NMarker(
  //         id: "${historyList[i].historyIdx}",
  //         position: NLatLng(historyList[i].historyLocation.latitude, historyList[i].historyLocation.longitude),
  //         icon: iconImage,
  //       );
  //       marker.setOnTapListener((overlay) async {
  //         if(mounted) {
  //           Navigator.push(context, MaterialPageRoute(builder: (context) =>
  //               FootprintHistoryDetailScreen(i, historyList)));
  //         }
  //       });
  //
  //       provider.addMarker(marker);
  //     }
  //   }
  // }

  Future<void> _addMarker(FootprintPhotoMapOverlayProvider provider, List<History> historyList) async {
    if (!mounted) return;

    for (var i = 0; i < historyList.length; i++) {
      if (!mounted) return;
      final imageURL = await FirebaseStorage.instance
          .ref('image/history/${historyList[i].historyImage[0]}')
          .getDownloadURL();

      final image = await _loadNetworkImage(imageURL);
      if (!mounted) return;

      final markerWidget = PhotoMapMarker(image);
      if (!mounted) return;

      final iconImage = await NOverlayImage.fromWidget(
          widget: markerWidget, size: const Size(70, 80), context: context);
      if (!mounted) return;

      final marker = NMarker(
        id: "${historyList[i].historyIdx}",
        position: NLatLng(
            historyList[i].historyLocation.latitude, historyList[i].historyLocation.longitude),
        icon: iconImage,
      );

      marker.setOnTapListener((overlay) async {
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
              FootprintHistoryDetailScreen(i)));
        }
      });

      provider.addMarker(marker);
      await _mapController.addOverlay(marker);
    }
    if (!mounted) return;
  }

  Future<Image> _loadNetworkImage(String imageUrl) {
    final completer = Completer<Image>();
    final image = NetworkImage(imageUrl);

    image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Image(image: image, fit: BoxFit.cover));
      }, onError: (error, stackTrace) {
        completer.completeError(error);
      }),
    );

    return completer.future;
  }

}
