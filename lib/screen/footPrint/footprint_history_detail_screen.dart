import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:woo_yeon_hi/dao/history_dao.dart';
import 'package:woo_yeon_hi/dialogs.dart';
import 'package:woo_yeon_hi/model/history_model.dart';
import 'package:woo_yeon_hi/model/photo_map_model.dart';
import 'package:woo_yeon_hi/provider/footprint_provider.dart';
import 'package:woo_yeon_hi/provider/login_register_provider.dart';
import 'package:woo_yeon_hi/screen/footPrint/footprint_history_write_screen.dart';
import 'package:woo_yeon_hi/screen/footPrint/footprint_history_modify_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/text_style.dart';
import 'package:woo_yeon_hi/widget/footPrint/footprint_history_detail_top_app_bar.dart';

import '../../style/font.dart';

class FootprintHistoryDetailScreen extends StatefulWidget {
  FootprintHistoryDetailScreen(this.index, {super.key});

  int index;

  @override
  State<FootprintHistoryDetailScreen> createState() =>
      _FootprintHistoryDetailScreenState();
}

class _FootprintHistoryDetailScreenState
    extends State<FootprintHistoryDetailScreen> {
  // scroll controller.
  final AutoScrollController _controller = AutoScrollController();

  List<bool> _overflowStates = [];

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
    var provider =
        Provider.of<FootprintHistoryGridViewProvider>(context, listen: false);
    var updatedList = await getHistory(context);
    provider.setHistoryList(updatedList);
    _checkOverflowForAllItems();
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

  void _checkOverflowForAllItems() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<bool> tempOverflowStates = [];

      for (var item in Provider.of<FootprintHistoryGridViewProvider>(context,
              listen: false)
          .historyList) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: item.historyContent,
            style: TextStyleFamily.normalTextStyle,
          ),
          maxLines: 2,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: MediaQuery.of(context).size.width * 0.8);

        tempOverflowStates.add(textPainter.didExceedMaxLines);
      }

      setState(() {
        _overflowStates = tempOverflowStates;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FootprintHistoryGridViewProvider>(
        builder: (context, historyGridViewProvider, _) {
      return _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: ColorFamily.pink,
            ))
          : ChangeNotifierProvider(
              create: (context) => FootprintHistoryMoreProvider(
                  historyGridViewProvider.historyList.length),
              child: Consumer<FootprintHistoryMoreProvider>(
                builder: (context, historyMoreProvider, _) {
                  // 해당 인덱스로 스크롤을 이동합니다.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _controller.scrollToIndex(
                      widget.index,
                      duration: const Duration(milliseconds: 300),
                      preferPosition: AutoScrollPosition.begin,
                    );
                  });
                  return Scaffold(
                      backgroundColor: ColorFamily.cream,
                      appBar: const FootprintHistoryDetailTopAppBar(),
                      body: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: ListView.builder(
                            controller: _controller,
                            itemCount:
                                historyGridViewProvider.historyList.length,
                            itemBuilder: (context, index) {
                              return AutoScrollTag(
                                  key: ValueKey(index),
                                  controller: _controller,
                                  index: index,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10),
                                      makeHistoryDetail(
                                          context,
                                          index,
                                          historyMoreProvider,
                                          historyGridViewProvider
                                              .historyList[index]),
                                    ],
                                  ));
                            }),
                      ));
                },
              ),
            );
    });
  }

  Widget makeHistoryDetail(BuildContext context, int index,
      FootprintHistoryMoreProvider provider, History history) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var deviceHeight = MediaQuery.of(context).size.height;
    int imageIndex = 0;

    var userProvider = Provider.of<UserProvider>(context, listen: false);

    return Column(
      children: [
        // 프로필 사진, 타이틀, 날짜, 메뉴
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // 프로필 사진
                ClipOval(
                    child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: history.historyUserIdx ==
                                        userProvider.userIdx
                                    ? userProvider.userProfileImage.image
                                    : userProvider.loverProfileImage.image,
                                // Image 객체의 image 속성을 사용
                                fit: BoxFit.cover) // 이미지를 원 안에 꽉 차게 함
                            ))),
                const SizedBox(
                  width: 15,
                ),
                // 제목, 날짜
                SizedBox(
                  width: deviceWidth * 0.5,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(history.historyTitle,
                              style: TextStyleFamily.dialogButtonTextStyle),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            history.historyDate,
                            style: dateTextStyle,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            // 수정, 삭제
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    splashColor: Colors.transparent,
                    onPressed: () {
                      _showModalBottomSheet(context, history);
                    },
                    icon: SvgPicture.asset('lib/assets/icons/dotdotdot.svg')),
              ],
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        // 사진
        ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: FlutterCarousel(
              items: List.generate(
                  history.historyImage.length,
                  (index) => FutureBuilder(
                        future: getHistoryImage(history.historyImage[index]),
                        builder: (context, snapshot) {
                          if (snapshot.hasData == false) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: ColorFamily.pink,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                "network error",
                                style: TextStyleFamily.normalTextStyle,
                              ),
                            );
                          } else {
                            return snapshot.data!;
                          }
                        },
                      )),
              options: FlutterCarouselOptions(
                  viewportFraction: 1.0,
                  showIndicator: true,
                  floatingIndicator: false,
                  aspectRatio: 2 / 3,
                  slideIndicator: CircularSlideIndicator(
                      slideIndicatorOptions: SlideIndicatorOptions(
                          itemSpacing: 20,
                          currentIndicatorColor: ColorFamily.pink,
                          indicatorBackgroundColor: ColorFamily.beige))),
            )),
        const SizedBox(
          height: 20,
        ),
        // 내용
        Column(
          children: [
            SizedBox(
              width: deviceWidth * 0.85,
              child: Text(
                history.historyContent,
                style: TextStyleFamily.normalTextStyle,
                overflow:
                    provider.isMoreList[index] ? TextOverflow.ellipsis : null,
                maxLines: provider.isMoreList[index] ? 2 : null,
              ),
            ),
            SizedBox(height: 30),
            if (_overflowStates.length > index &&
                _overflowStates[index]) // overflow인 경우에만 표시
              Column(
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    width: deviceWidth * 0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            if (provider.isMoreList[index]) {
                              provider.setMoreState(index, false);
                            } else {
                              provider.setMoreState(index, true);
                            }
                            provider.notify();
                          },
                          child: Text(
                            provider.isMoreList[index] ? "더보기" : "접기",
                            style: contentMoreTextStyle,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
          ],
        ),
        const Divider(
          height: 20,
          color: ColorFamily.gray,
        )
      ],
    );
  }

  void _showModalBottomSheet(BuildContext context, History history) {
    var deviceWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        backgroundColor: ColorFamily.white,
        builder: (context) {
          return Wrap(
            children: [
              Column(
                children: [
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      // 바텀 시트 다이얼로그 팝
                      Navigator.pop(context);
                      // 수정 페이지로
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FootprintHistoryModifyScreen(
                                  history,
                                  widget.index,
                                  Provider.of<FootprintHistoryGridViewProvider>(
                                          context,
                                          listen: false)
                                      .historyList)));
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 5, 30, 15),
                      child: SizedBox(
                        width: deviceWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset(
                              'lib/assets/icons/edit.svg',
                              height: 20,
                            ),
                            const Text(
                              "수정",
                              style: TextStyleFamily.smallTitleTextStyle,
                            ),
                            const SizedBox(
                              width: 24,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: ColorFamily.gray,
                  ),
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      _showDeleteDialog(context, history);
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 20, 30, 25),
                      child: SizedBox(
                        width: deviceWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset('lib/assets/icons/delete.svg',
                                height: 20,
                                colorFilter: const ColorFilter.mode(
                                    ColorFamily.pink, BlendMode.srcIn)),
                            const Text(
                              "삭제",
                              style: TextStyleFamily.smallTitleTextStyle_pink,
                            ),
                            const SizedBox(
                              width: 24,
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          );
        });
  }

  void _showDeleteDialog(BuildContext context, History history) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            surfaceTintColor: ColorFamily.white,
            backgroundColor: ColorFamily.white,
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "히스토리를 삭제하시겠습니까?",
                        style: TextStyleFamily.dialogButtonTextStyle,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(
                                      ColorFamily.gray)),
                              onPressed: () {
                                Navigator.pop(context); // 다이얼로그
                              },
                              child: const Text(
                                "취소",
                                style: TextStyleFamily.dialogButtonTextStyle,
                              )),
                          TextButton(
                              style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(
                                      ColorFamily.gray)),
                              onPressed: () {
                                deleteHistory(history.historyIdx);
                                Navigator.pop(context); // 다이얼로그 팝
                                Navigator.pop(context); // 바텀시트 팝
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            FootprintHistoryDetailScreen(0)));
                                // Navigator.pop(context, "refresh"); // 히스토리 페이지 팝
                                showPinkSnackBar(context, "히스토리가 삭제되었습니다");
                              },
                              child: const Text(
                                "확인",
                                style:
                                    TextStyleFamily.dialogButtonTextStyle_pink,
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}

TextStyle dateTextStyle = const TextStyle(
    fontFamily: FontFamily.mapleStoryLight,
    fontSize: 12,
    color: ColorFamily.black);

TextStyle contentMoreTextStyle = const TextStyle(
    fontFamily: FontFamily.mapleStoryLight,
    fontSize: 12,
    color: ColorFamily.gray);
