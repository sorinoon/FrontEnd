import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'UserSettingsProvider.dart';
import 'ProtectorSettingsProvider.dart';
import 'login_protector.dart'; // LoginScreen 임포트

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserSettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProtectorSettingsProvider()),
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
      home: LoginScreen(), // 초기 화면
    );
  }
}
