import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/dao/history_dao.dart';
import 'package:woo_yeon_hi/dao/plan_dao.dart';
import 'package:woo_yeon_hi/enums.dart';
import 'package:woo_yeon_hi/model/place_info.dart';

import '../dao/photo_map_dao.dart';
import '../model/history_model.dart';
import '../model/photo_map_model.dart';
import '../model/plan_model.dart';
import '../retrofit_interface/place_search_api.dart';
import '../screen/footPrint/footprint_history_detail_screen.dart';
import '../widget/footPrint/footprint_photo_map_marker.dart';

/// 탭 전환 상태 관리 프로바이더
class FootprintProvider extends ChangeNotifier{

  int _currentPageIndex = 0;

  int get currentPageIndex => _currentPageIndex;

  void setCurrentPageIndex(int index){
    _currentPageIndex = index;
    notifyListeners();
  }

}

/// 히스토리 항목 상태관리 프로바이더
class FootprintHistoryProvider extends ChangeNotifier {

  List<History> _historyList = [];
  List<History> get historyList => _historyList;

  Future<bool> fetchHistoryData(BuildContext context) async {
    var list = await getHistory(context);
    setHistoryList(list);

    return true;
  }

  void setHistoryList(List<History> historyList) {
    _historyList = historyList;
    notifyListeners();
  }

  void modifyHistory(Map<String, dynamic> historyMap, int index) {
    _historyList[index].historyLocation = historyMap["history_location"];
    _historyList[index].historyPlaceName = historyMap["history_place_name"];
    _historyList[index].historyDate = historyMap["history_date"];
    _historyList[index].historyTitle = historyMap["history_title"];
    _historyList[index].historyContent = historyMap["history_content"];
    notifyListeners();
  }
}

/// 포토맵화면 히스토리 항목 상태관리 프로바이더
class FootprintPhotoMapHistoryProvider extends ChangeNotifier{

  List<History> _historyList = [];
  List<History> get historyList => _historyList;

  // Future<bool> fetchHistoryData(BuildContext context) async {
  //   _historyList = await getHistory(context);
  //   notifyListeners();
  //   return true;
  // }

  Future<bool> getHistoryList(BuildContext context) async {
    List<History> list = await getHistory(context);
    _historyList = list;
    notifyListeners();
    return true;
  }

  // Future<void> loadMapData(BuildContext context, NaverMapController mapController) async {
  //   await _preloadImages(_historyList, context);
  //   await _addMarkerOverlay(Provider.of<FootprintPhotoMapOverlayProvider>(context, listen: false), _historyList, context, mapController);
  //   notifyListeners();
  // }
  //
  // Future<void> _preloadImages(List<History> historyList, BuildContext context) async {
  //   for (var history in historyList) {
  //     final imageURL = await FirebaseStorage.instance
  //         .ref('image/history/${history.historyImage[0]}')
  //         .getDownloadURL();
  //     final imageProvider = NetworkImage(imageURL);
  //
  //     try {
  //         await precacheImage(imageProvider, context);
  //     } catch (e) {
  //       print("Failed to cache image: $imageURL - $e"); // 캐싱 실패 로그
  //     }
  //   }
  // }
  //
  // Future<void> _addMarkerOverlay(
  //     FootprintPhotoMapOverlayProvider provider, List<History> historyList, BuildContext context, NaverMapController mapController) async {
  //     await _addMarker(provider, historyList, context, mapController);
  // }
  //
  // Future<void> _addMarker(FootprintPhotoMapOverlayProvider provider,
  //     List<History> historyList, BuildContext context, NaverMapController mapController) async {
  //     for (var i = 0; i < historyList.length; i++) {
  //       final imageURL = await FirebaseStorage.instance
  //           .ref('image/history/${historyList[i].historyImage[0]}')
  //           .getDownloadURL();
  //
  //       final markerWidget = PhotoMapMarker(await _loadNetworkImage(imageURL));
  //
  //       final iconImage = await NOverlayImage.fromWidget(
  //           widget: markerWidget, size: const Size(70, 80), context: context);
  //
  //       final marker = NMarker(
  //         id: "${historyList[i].historyIdx}",
  //         position: NLatLng(
  //             historyList[i].historyLocation.latitude, historyList[i].historyLocation.longitude),
  //         icon: iconImage,
  //       );
  //
  //       marker.setOnTapListener((overlay) async {
  //           Navigator.push(context, MaterialPageRoute(builder: (context) =>
  //               FootprintHistoryDetailScreen(i, historyList)));
  //       });
  //
  //       provider.addMarker(marker);
  //       await mapController.addOverlay(marker);
  //     }
  // }
  //
  // Future<Image> _loadNetworkImage(String imageUrl) async {
  //   final completer = Completer<Image>();
  //   final image = NetworkImage(imageUrl);
  //
  //   image.resolve(ImageConfiguration()).addListener(
  //     ImageStreamListener((ImageInfo info, bool _) {
  //       completer.complete(Image(image: image, fit: BoxFit.cover));
  //     }, onError: (error, stackTrace) {
  //       completer.completeError(error);
  //     }),
  //   );
  //
  //   return completer.future;
  // }
}

/// 히스토리 목록 ExpansionTile 상태 관리 프로바이더
// class FootprintExpandedHistoryProvider extends ChangeNotifier{
//
//   List<bool> _isExpandedList = [];
//
//   FootprintExpandedHistoryProvider(int itemCount){
//     _isExpandedList.add(true);
//     for (int i = 1; i < itemCount; i++) {
//       _isExpandedList.add(false);
//     }
//   }
//
//   List<bool> get isExpandedList => _isExpandedList;
//
//   void setExpansionState(int index, bool isExpanded) {
//     _isExpandedList[index] = isExpanded;
//     notifyListeners();
//   }
//
//   void expandAll() {
//     _isExpandedList = List.filled(_isExpandedList.length, true);
//     notifyListeners();
//   }
//
//   void collapseAll() {
//     _isExpandedList = List.filled(_isExpandedList.length, false);
//     notifyListeners();
//   }
// }

/// 히스토리 내용 더보기 버튼 상태 관리 프로바이더
class FootprintHistoryMoreProvider extends ChangeNotifier{
  List<bool> _isMoreList = [];

  FootprintHistoryMoreProvider(int itemCount){
    for(int i = 0; i< itemCount; i++){
      _isMoreList.add(true);
    }
  }

  List<bool> get isMoreList => _isMoreList;

  void setMoreState(int index, bool isMore){
    _isMoreList[index] = isMore;
  }

  void notify(){
    notifyListeners();
  }
}

/// 히스토리 작성, 수정 상태 관리 프로바이더
class FootprintHistoryWriteProvider extends ChangeNotifier{
  List<XFile> _albumImages = [];
  List<Image> _albumModifyImages = [];
  Place? _selectedPlace;
  List<Place> _searchPlaces = [];
  String? _date;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  List<XFile> get albumImages => _albumImages;
  List<Image> get albumModifyImages => _albumModifyImages;
  Place? get selectedPlace => _selectedPlace;
  List<Place> get searchPlaces => _searchPlaces;
  String? get date => _date;
  TextEditingController get titleController => _titleController;
  TextEditingController get contentController => _contentController;

  void addAlbumImage(XFile image){
    _albumImages.add(image);
    notifyListeners();
  }

  void addAlbumModifyImage(Image image){
    _albumModifyImages.add(image);
    notifyListeners();
  }

  void removeAlbumImage(int index){
    _albumImages.removeAt(index);
    notifyListeners();
  }

  void removeAlbumModifyImage(int index){
    _albumModifyImages.removeAt(index);
    notifyListeners();
  }

  void clearAlbumImages(){
    _albumImages.clear();
    notifyListeners();
  }

  void clearAlbumModifyImages(){
    _albumModifyImages.clear();
    notifyListeners();
  }

  void setPlace(Place? place){
    _selectedPlace = place;
    notifyListeners();
  }

  void changeSelectedPlaceInfo(String title, String addr){
    _selectedPlace!.title = title;
    _selectedPlace!.roadAddress = addr;
    notifyListeners();
  }

  void addSearchPlace(Place place){
    _searchPlaces.add(place);
    notifyListeners();
  }

  void clearSearchPlace(){
    _searchPlaces.clear();
    notifyListeners();
  }

  void setDate(String date){
    _date = date;
    notifyListeners();
  }

  void setTitle(String title){
    _titleController.text = title;
    notifyListeners();
  }

  void setContent(String content){
    _contentController.text = content;
    notifyListeners();
  }

  void modifySetting(History history){
    _titleController.text = history.historyTitle;
    _contentController.text = history.historyContent;
    _date = history.historyDate;
  }
}

/// 포토맵 오버레이 상태관리 프로바이더
class FootprintPhotoMapOverlayProvider extends ChangeNotifier{
  // OverlayInfo? _overlayInfo;
  Map<int, PlaceInfo> _polygonInfos = {};
  List<NPolygonOverlay> _polygonOverlays = [];
  List<NMarker> _markers = [];

  // OverlayInfo? get overlayInfo => _overlayInfo;
  Map<int, PlaceInfo> get polygonInfos => _polygonInfos;
  List<NPolygonOverlay> get polygonOverlays => _polygonOverlays;
  List<NMarker> get markers => _markers;

  // FootprintPhotoMapOverlayProvider(){
  //   setOverlayInfo();
  // }

  // void setMapType(int type){
  //   _mapType = MapType.fromType(type);
  //   notifyListeners();
  // }

  // void setOverlayInfo(){
  //   if(mapType != null){
  //     _overlayInfo = OverlayInfo.fromType(mapType!.type);
  //     notifyListeners();
  //   }
  // }

  void addInfo(int id, PlaceInfo info){
    _polygonInfos[id] = info;
    notifyListeners();
  }

  void addOverlay(NPolygonOverlay overlay){
    _polygonOverlays.add(overlay);
    notifyListeners();
  }

  void addMarker(NMarker marker){
    _markers.add(marker);
    notifyListeners();
  }

  void clearMarker(){
    _markers.clear();
    notifyListeners();
  }

}

// 데이트 플랜 메인 화면 상태관리
class DatePlanSlidableProvider extends ChangeNotifier {
  List<Plan> _items = [];
  // List<Item> _items = [
  //   Item(title: 'Item 1'),
  //   Item(title: 'Item 2'),
  //   Item(title: 'Item 3'),
  //   Item(title: 'Item 4'),
  //   Item(title: 'Item 5'),
  //   Item(title: 'Item 6'),
  //   Item(title: 'Item 7'),
  // ];

  List<Plan> get items => _items;
  void addPlanList(List<Plan> list){
    _items = list;
    notifyListeners();
  }

  void addPlan(Plan plan) {
    _items.add(plan);
    notifyListeners();
  }

  void removeItem(int index, Plan plan) {
    _items.removeAt(index);
    deletePlan(plan);
    notifyListeners();
  }

  void toggleCompleteItem(int index, Plan plan) {
    if(_items[index].planState == PlanState.STATE_NORMAL.state){
      normalPlan(plan);
      _items[index].planState = PlanState.STATE_NORMAL.state;
    }else{
      successPlan(plan);
      _items[index].planState = PlanState.STATE_SUCCESS.state;
    }
    notifyListeners();
  }
}

// 데이트 플랜 메인 화면 상태관리
class Item {
  final String title;
  bool isCompleted;

  Item({required this.title, this.isCompleted = false});
}

// 데이트 플랜 생성 화면 슬라이드 상태관리
class DatePlanMakeSlidableProvider extends ChangeNotifier {
  final List<Item> _items = List<Item>.generate(5, (index) => Item(title: "방이역 ${index + 1}"));
  List<Place> _searchPlaces = [];
  Place? _selectedPlace;
  List<Map<String, dynamic>> _planList = [];
  Plan? _planedList;
  final TextEditingController _memoController = TextEditingController();
  final TextEditingController _planTitleController = TextEditingController();
  final TextEditingController _planDateStartController = TextEditingController();
  final TextEditingController _planDateEndController = TextEditingController();


  List<Item> get items => _items;
  List<Place> get searchPlaces => _searchPlaces;
  Place? get selectedPlace => _selectedPlace;
  List<Map<String, dynamic>> get planList => _planList;
  Plan? get planedList => _planedList;
  TextEditingController get memoController => _memoController;
  TextEditingController get planTitleController => _planTitleController;
  TextEditingController get planDateStartController => _planDateStartController;
  TextEditingController get planDateEndController => _planDateEndController;

  void setPlanedList(Plan plan){
    _planedList = plan;
  }

  void clearTitleController(){
    _planTitleController.clear();
    _planDateStartController.clear();
    _planDateEndController.clear();
    notifyListeners();
  }

  void setPlanDateStart(String date){
    _planDateStartController.text = date;
    notifyListeners();
  }

  void setPlanDateEnd(String date){
    _planDateEndController.text = date;
    notifyListeners();
  }

  void addItem(String title) {
    _items.add(Item(title: title));
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void addSearchPlace(Place place){
    _searchPlaces.add(place);
    notifyListeners();
  }

  void clearSearchPlace(){
    _searchPlaces.clear();
    notifyListeners();
  }

  void setPlace(Place? place){
    _selectedPlace = place;
    notifyListeners();
  }

  void addPlan(Map<String, dynamic> plan){
    _planList.add(plan);
    notifyListeners();
  }

  void removePlan(int index) {
    _planList.removeAt(index);
    notifyListeners();
  }

  // 항목 아이템 순서 변경
  void reorderPlans(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final plan = _planList.removeAt(oldIndex);
    _planList.insert(newIndex, plan);
    notifyListeners();
  }
}

// 데이트 플랜 DraggableSheet 상태관리
class FootprintDraggableSheetProvider extends ChangeNotifier {

  // 상세 화면에서 사용할 입력 컨트롤러
  final TextEditingController memoTitleController = TextEditingController();
  final TextEditingController memoSubController = TextEditingController();

  //List<String> _items = ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'];
  List<String> _items = List.generate(20, (index) => "방이역");

  List<String> get items => _items;

  void addItem(String item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  // 항목 아이템 순서 변경
  void reorderItems(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    notifyListeners();
  }
}

class HomeDatePlanProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _datePlanList = [];
  List<Map<String, dynamic>> get datePlanList => _datePlanList;

  Map<String, dynamic> _currentDatePlan = {};
  Map<String, dynamic> get currentDatePlanList => _currentDatePlan;

  void setDatePlanList(List<Map<String, dynamic>> planList){
    _datePlanList = planList;
    notifyListeners();
  }

  void setCurrentDatePlanList(int index){
    _currentDatePlan = _datePlanList[index];
    notifyListeners();
  }

}