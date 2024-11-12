// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:provider/provider.dart';
// import 'package:woo_yeon_hi/model/photo_map_model.dart';
// import 'package:woo_yeon_hi/provider/login_register_provider.dart';
// import 'package:woo_yeon_hi/screen/footPrint/footprint_history_screen.dart';
//
// import '../../screen/footPrint/footprint_photo_map_detail_screen.dart';
// import '../../style/color.dart';
// import '../../style/text_style.dart';
//
// class FootprintPhotoMapDetailTopAppBar extends StatefulWidget implements PreferredSizeWidget{
//   FootprintPhotoMapDetailTopAppBar(this.globalkey, {super.key});
//   GlobalKey globalkey;
//
//   @override
//   State<FootprintPhotoMapDetailTopAppBar> createState() => _FootprintPhotoMapDetailTopAppBarState();
//
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
//
// class _FootprintPhotoMapDetailTopAppBarState extends State<FootprintPhotoMapDetailTopAppBar> {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<UserProvider>(builder: (context, provider, child) {
//       return AppBar(
//         surfaceTintColor: ColorFamily.cream,
//         backgroundColor: ColorFamily.cream,
//         centerTitle: true,
//         title: Text(
//           widget.photoMap.mapName,
//           style: TextStyleFamily.appBarTitleLightTextStyle,
//         ),
//         leading: IconButton(
//           onPressed: () async {
//             // 스냅샷 저장
//             await FootprintPhotoMapDetailScreen.capture(widget.globalkey, provider.userIdx, widget.photoMap.mapIdx);
//             Navigator.pop(context);
//           },
//           icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () async {
//               // 스냅샷 저장
//               await FootprintPhotoMapDetailScreen.capture(widget.globalkey, provider.userIdx, widget.photoMap.mapIdx);
//               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FootprintHistoryScreen(provider.userIdx, widget.photoMap)));
//             },
//             icon: SvgPicture.asset('lib/assets/icons/list.svg'),
//           ),
//         ],
//       );});
//   }
// }
