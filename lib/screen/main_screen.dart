import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/screen/main_screen_container.dart';
import '../dao/user_dao.dart';
import '../provider/login_register_provider.dart';
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

  Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse response) async {
    if (response.payload != null) {
      switch (response.payload) {
        case 'document1':
          Navigator.of(context)
              .pushNamed('/detail1', arguments: response.payload);
          break;
        case 'document2':
          Navigator.of(context)
              .pushNamed('/detail2', arguments: response.payload);
          break;
        default:
          Navigator.of(context).pushNamed('/');
          break;
      }
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
            _checkDocumentChanges(change.doc, 'DiaryData');
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
            _checkDocumentChanges(change.doc, 'HistoryData');
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
            _checkDocumentChanges(change.doc, 'LedgerData');
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
            _checkDocumentChanges(change.doc, 'PlanData');
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

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics =
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

void _checkDocumentChanges(DocumentSnapshot document, String collectionName) {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final data = document.data() as Map<String, dynamic>;

  // 문서에 'notified' 필드가 없거나 false로 설정되어 있는 경우에만 알림 전송
  if (data['notified'] == null || data['notified'] == false) {
    switch (collectionName) {
      case 'DiaryData':
        _showNotification("우연히 알림", "연인이 작성한 일기가 도착했습니다!");
      case 'HistoryData':
        _showNotification("우연히 알림", "새로운 히스토리가 생성되었습니다!");
      case 'LedgerData':
        _showNotification("우연히 알림", "가계부가 업데이트되었습니다!");
      case 'PlanData':
        _showNotification("우연히 알림", "새로운 데이트플랜이 등록되었습니다!");
      case 'ScheduleData':
        _showNotification("우연히 알림", "새로운 일정이 등록되었습니다!");
    }
    // 중복알림 방지를 위해, 알림을 보낸 후 'notified' 필드를 true로 업데이트
    firestore
        .collection(collectionName)
        .doc(document.id)
        .update({'notified': true});
  }
}
