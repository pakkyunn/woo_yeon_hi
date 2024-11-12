// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:provider/provider.dart';
// import 'package:woo_yeon_hi/provider/footprint_provider.dart';
// import 'package:woo_yeon_hi/style/color.dart';
// import 'package:woo_yeon_hi/style/font.dart';
// import 'package:woo_yeon_hi/style/text_style.dart';
// import 'package:woo_yeon_hi/widget/footPrint/footprint_date_plan_top_app_bar.dart';
//
// class FootprintDatePlanDetailListViewScreen extends StatefulWidget {
//   FootprintDatePlanDetailListViewScreen({super.key});
//   @override
//   State<FootprintDatePlanDetailListViewScreen> createState() => _FootprintDatePlanDetailListViewScreenState();
// }
//
// class _FootprintDatePlanDetailListViewScreenState extends State<FootprintDatePlanDetailListViewScreen> {
//
//   Future<bool> _asyncData(DatePlanSlidableProvider provider) async {
//     //TODO 데이트플랜 상세데이터 가져오기
//     return true;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var datePlanProvider = Provider.of<DatePlanSlidableProvider>(context);
//
//     return FutureBuilder(
//       future: _asyncData(datePlanProvider),
//       builder: (context, snapshot) {
//         if (snapshot.hasData == false) {
//           return const Center(
//             child: CircularProgressIndicator(
//               color: ColorFamily.pink,
//             ),
//           );
//         } else if (snapshot.hasError) {
//           return const Text("오류 발생", style: TextStyleFamily.normalTextStyle,);
//         } else {
//           //현재 데이트플랜 상세프로바이더 만들어져 있지 않아서 임시로 다른 프로바이더 적용
//           return Consumer<DatePlanMakeSlidableProvider>(builder: (context, footPrintDatePlanSlidableProvider, child) {
//             return Scaffold(
//                 appBar: FootprintDatePlanTopAppBar(
//                   title: '데이트 플랜 리스트',
//                   actions: [
//                     Padding(
//                       padding: const EdgeInsets.only(right: 15),
//                       child: SvgPicture.asset('lib/assets/icons/done.svg'),
//                     )
//                   ],
//                   leading: IconButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     icon: SvgPicture.asset('lib/assets/icons/arrow_back.svg'),
//                   ),
//                 ),
//                 backgroundColor: ColorFamily.cream,
//                 body: ListView.builder(
//                   itemCount: footPrintDatePlanSlidableProvider.planList.length,
//                   itemBuilder: (context, index) {
//                     print(footPrintDatePlanSlidableProvider.planedList.toString());
//                     final item = footPrintDatePlanSlidableProvider.planList[index];
//                     return Column(
//                       children: [
//                         makeListView(item, index),
//                         Divider(),
//                       ],
//                     );
//                   },
//                 )
//             );
//           });
//         }
//       });
//   }
//
//   Widget makeListView(Map<String, dynamic> item, int index){
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Text('${index + 1}', style: TextStyleFamily.normalTextStyle),
//                   const SizedBox(width: 10),
//                   Text(item['planed_place_name'], style: TextStyleFamily.normalTextStyle),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   const SizedBox(width: 20),
//                   Text(item['planed_place_memo'], style: TextStyleFamily.normalTextStyle),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
