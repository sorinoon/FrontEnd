import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Pages/Login.dart';
import 'Pages/User_SettingsProvider.dart';
import 'Pages/NOK_SettingsProvider.dart';
import 'Pages/LoginModeProvider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'Pages/User_Navigate.dart';
import 'Pages/Splash.dart';
import 'Pages/ProtectorListProvider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  KakaoSdk.init(
    nativeAppKey: '	3628913fe999ed14d1f21804b34cb8ae', // 카카오 네이티브 앱 키
    javaScriptAppKey: '31e0f394a6fff7b5d25aaf635b5838cb',
  );
  //AuthRepository.initialize(appKey: '31e0f394a6fff7b5d25aaf635b5838cb');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserSettingsProvider()),
        ChangeNotifierProvider(create: (_) => NOKSettingsProvider()),
        ChangeNotifierProvider(create: (_) => LoginModeProvider()),
        ChangeNotifierProvider(create: (_) => ProtectorListProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'KoddiUDOnGothic', // 전역 폰트 설정
      ),
      home: SplashScreen(),
    );
  }
}
