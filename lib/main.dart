import 'package:flutter/material.dart';
import 'login_protector.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // 전역 폰트 설정
        fontFamily: 'KoddiUDOnGothic',
      ),
      home: LoginScreen(),
    );
  }
}
