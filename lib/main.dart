import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:woo_yeon_hi/provider/diary_provider.dart';
import 'package:woo_yeon_hi/provider/footprint_provider.dart';
import 'package:woo_yeon_hi/provider/ledger_provider.dart';
import 'package:woo_yeon_hi/provider/login_register_provider.dart';
import 'package:woo_yeon_hi/provider/more_provider.dart';
import 'package:woo_yeon_hi/provider/tab_page_index_provider.dart';
import 'package:woo_yeon_hi/screen/login/password_enter_screen.dart';
import 'package:woo_yeon_hi/screen/main_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/routes/routes_generator.dart';
import 'package:woo_yeon_hi/screen/login/login_screen.dart';
import 'package:woo_yeon_hi/utils.dart';

import 'dao/more_dao.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // .env 환경변수 파일 로드
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'],
  );
  await NaverMapSdk.instance.initialize(
      clientId: dotenv.env['NAVER_MAP_CLIENT_ID'],
      onAuthFailed: (ex) {
        print(ex);
      });
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  initializeDateFormatting().then((_) async {
    final userData = await fetchUserData();

    runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => UserProvider())
        ],
        child: WooYeonHi(
          userIdx: userData['userIdx'],
          userAccount: userData['userAccount'],
          appLockState: userData['appLockState'],
          homePresetType: userData['homePresetType'],
          loginType: userData['loginType'],
          loveDday: userData['loveDday'],
          loverIdx: userData['loverIdx'],
          notificationAllow: userData['notificationAllow'],
          profileMessage: userData['profileMessage'],
          topBarActivate: userData['topBarActivate'],
          topBarType: userData['topBarType'],
          userBirth: userData['userBirth'],
          userNickname: userData['userNickname'],
          userProfileImage: userData['userProfileImage'],
          userState: userData['userState'],
        )));
  });
}

class WooYeonHi extends StatefulWidget {
  WooYeonHi(
      {super.key,
      required this.userIdx,
      required this.userAccount,
      required this.appLockState,
      required this.homePresetType,
      required this.loginType,
      required this.loveDday,
      required this.loverIdx,
      required this.notificationAllow,
      required this.profileMessage,
      required this.topBarActivate,
      required this.topBarType,
      required this.userBirth,
      required this.userNickname,
      required this.userProfileImage,
      required this.userState});

  final int userIdx;
  final String userAccount;
  final int appLockState;
  final int homePresetType;
  final int loginType;
  final String loveDday;
  final int loverIdx;
  final bool notificationAllow;
  final String profileMessage;
  final bool topBarActivate;
  final int topBarType;
  final String userBirth;
  final String userNickname;
  final String userProfileImage;
  final int userState;

  @override
  State<WooYeonHi> createState() => _WooYeonHiState();
}

class _WooYeonHiState extends State<WooYeonHi> {
  @override
  build(BuildContext context) {

    Provider.of<UserProvider>(context, listen: false).setUserAllData(widget.userIdx, widget.userAccount, widget.appLockState, widget.homePresetType, widget.loginType, widget.loveDday, widget.loverIdx, widget.notificationAllow, widget.profileMessage, widget.topBarActivate, widget.topBarType, widget.userBirth, widget.userNickname, widget.userProfileImage, widget.userState);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => CalendarProvider()),
          ChangeNotifierProvider(create: (context) => PasswordProvider()),
          ChangeNotifierProvider(create: (context) => AuthCodeProvider()),
          ChangeNotifierProvider(create: (context) => TabPageIndexProvider()),
          ChangeNotifierProvider(create: (context) => DiaryProvider()),
          ChangeNotifierProvider(create: (context) => FootprintProvider()),
          ChangeNotifierProvider(create: (context) => LedgerProvider()),
          ChangeNotifierProvider(create: (context) => FootPrintSlidableProvider()),
          ChangeNotifierProvider(create: (context) => FootPrintDatePlanSlidableProvider()),
          ChangeNotifierProvider(create: (context) => FootprintDraggableSheetProvider()),
          ChangeNotifierProvider(create: (context) => BioAuthProvider()),
          ChangeNotifierProvider(create: (context) => PasswordProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "WooYeonHi",
          theme: ThemeData(
              colorScheme: const ColorScheme(
                brightness: Brightness.light,
                primary: Colors.white,
                onPrimary: Colors.black,
                secondary: Colors.white,
                onSecondary: Colors.black,
                error: Colors.red,
                onError: Colors.white,
                background: Colors.white,
                onBackground: Colors.black,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              useMaterial3: true),
          home: widget.userIdx == 0 // 미등록 계정
              ? const LoginScreen()
              : widget.userState == 0 // 등록계정 & 계정상태 정상
                  ? widget.appLockState == 0 // 앱 잠금 미설정
                    ? const MainScreen()
                    : const PasswordEnterScreen() // 앱 잠금 설정
                  : const LoginScreen(), // 등록계정 & 계정상태 비정상(삭제처리중/로그아웃)
          onGenerateRoute: RouteGenerator.generateRoute,
        ));
  }
}
