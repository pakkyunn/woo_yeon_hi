import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/screen/main_screen_container.dart';
import '../dao/user_dao.dart';
import '../provider/login_register_provider.dart';
import '../provider/tab_page_index_provider.dart';
import '../style/color.dart';
import '../widget/main_bottom_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _listenToCollection();
  }

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      initialIndex: 2,
      length: 5,
      child: Scaffold(
        backgroundColor: ColorFamily.white,
        bottomNavigationBar: MainBottomNavigationBar(),
        body: MainScreenContainer(),
      ),
    );
  }

  void _initializeNotifications() {
    final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  //알림 탭 동작
  Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse response) async {
    if (response.payload != null) {
      Provider.of<TabPageIndexProvider>(context, listen: false).setCurrentPageIndex(0);
      Provider.of<TabPageIndexProvider>(context, listen: false).changeTab(0);
      // switch (response.payload) {
      //   case 'document1':
      //     Navigator.of(context)
      //         .pushNamed('/detail1', arguments: response.payload);
      //     break;
      //   case 'document2':
      //     Navigator.of(context)
      //         .pushNamed('/detail2', arguments: response.payload);
      //     break;
      //   default:
      //     Navigator.of(context).pushNamed('/');
      //     break;
      // }
    }
  }

  void _listenToCollection() {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    var userProvider = Provider.of<UserProvider>(context, listen:false);

    int loverIdx = Provider
        .of<UserProvider>(context, listen: false)
        .loverIdx;
    bool notificationIsAllowed = true;

    _firestore
        .collection('DiaryData')
        .where('diary_user_idx', isEqualTo: loverIdx)
        .snapshots()
        .listen((snapshot) {
      if (notificationIsAllowed) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            _checkDocumentChanges(change.doc, 'DiaryData', context);
          }
        }
      }
    });

    _firestore
        .collection('HistoryData')
        .where('history_user_idx', isEqualTo: loverIdx)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docChanges.isNotEmpty && notificationIsAllowed) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            _checkDocumentChanges(change.doc, 'HistoryData', context);
          }
        }
      }
    });

    _firestore
        .collection('LedgerData')
        .where('ledger_user_idx', isEqualTo: loverIdx)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docChanges.isNotEmpty && notificationIsAllowed) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            _checkDocumentChanges(change.doc, 'LedgerData', context);
          }
        }
      }
    });

    _firestore
        .collection('PlanData')
        .where('plan_user_idx', isEqualTo: loverIdx)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docChanges.isNotEmpty && notificationIsAllowed) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            _checkDocumentChanges(change.doc, 'PlanData', context);
          }
        }
      }
    });

    //연인의 별명 변경 시
    _firestore
        .collection('UserData')
        .where('user_idx', isEqualTo: loverIdx)
        .snapshots()
        .listen((snapshot) {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.modified) {
          var updatedData = docChange.doc.data();

          if (docChange.doc.metadata.hasPendingWrites == false &&
              updatedData!.containsKey('user_nickname')) {
            String updatedNickname = updatedData['user_nickname'];

            // Provider를 통해 상태 업데이트
            userProvider.setLoverNickname(updatedNickname);
          }
        }
      }
    });

    //연인의 프로필 사진 변경 시
    _firestore
        .collection('UserData')
        .where('user_idx', isEqualTo: loverIdx)
        .snapshots()
        .listen((snapshot) async {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.modified) {
          var updatedData = docChange.doc.data();

          if (docChange.doc.metadata.hasPendingWrites == false &&
              updatedData!.containsKey('user_profile_image')) {
            String loverProfileImagePath = updatedData['user_profile_image'];
            Image loverProfileImage = loverProfileImagePath == "lib/assets/images/default_profile.png"
                ? Image.asset("lib/assets/images/default_profile.png")
                : await getProfileImage(loverProfileImagePath);

            // Provider를 통해 상태 업데이트
            userProvider.setLoverProfileImagePath(loverProfileImagePath);
            userProvider.setLoverProfileImage(loverProfileImage);
          }
        }
      }});
  }
}


Future<void> _showNotification(String title, String body) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  AndroidNotificationDetails androidPlatformChannelSpecifics =
  const AndroidNotificationDetails(
    '우연히 알림 채널',
    '우연히',
    icon: 'app_icon',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  int notificationId =
      DateTime
          .now()
          .millisecondsSinceEpoch ~/ 1000; // 고유 ID 생성
  await flutterLocalNotificationsPlugin.show(
    notificationId,
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

void _checkDocumentChanges(DocumentSnapshot document, String collectionName, BuildContext context) {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final data = document.data() as Map<String, dynamic>;
  bool notificationAllow = Provider.of<UserProvider>(context, listen: false).notificationAllow;

  // 문서에 'notified' 필드가 없거나 false로 설정되어 있는 경우에만 알림 전송
  if (data['notified'] == null || data['notified'] == false) {
    switch (collectionName) {
      case 'DiaryData':
        notificationAllow == true
            ? _showNotification("우연히 알림", "연인이 작성한 일기가 도착했습니다!")
            : null;
      case 'HistoryData':
        notificationAllow == true
            ? _showNotification("우연히 알림", "새로운 히스토리가 생성되었습니다!")
            : null;
      case 'LedgerData':
        notificationAllow == true
            ? _showNotification("우연히 알림", "가계부가 업데이트되었습니다!")
            : null;
      case 'PlanData':
        notificationAllow == true
            ? _showNotification("우연히 알림", "새로운 데이트플랜이 등록되었습니다!")
            : null;
      case 'ScheduleData':
        notificationAllow == true
            ? _showNotification("우연히 알림", "새로운 일정이 등록되었습니다!")
            : null;
    }
    // 중복알림 방지를 위해, 알림을 보낸 후 'notified' 필드를 true로 업데이트
    firestore
        .collection(collectionName)
        .doc(document.id)
        .update({'notified': true});
  }
}
