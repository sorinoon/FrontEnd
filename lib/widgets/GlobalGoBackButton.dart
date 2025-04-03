import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screen_wake/flutter_screen_wake.dart';
import '../Pages/UserSettingsProvider.dart';
import '../Pages/ProtectorSettingsProvider.dart';
import '../Pages/LoginModeProvider.dart';

class GlobalGoBackButton extends StatelessWidget {

  const GlobalGoBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 40,
      child: GestureDetector(
        onTap: () {
          final isProtectorMode = Provider.of<LoginModeProvider>(context, listen: false).isProtectorMode;

          if (isProtectorMode) {
            Provider.of<ProtectorSettingsProvider>(context, listen: false).vibrate();
          } else {
            Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
          }
          // 화면 밝기 복원
          FlutterScreenWake.setBrightness(1.0);

          // 기존 페이지를 닫고 이전 화면으로 돌아가기
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        child: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
}
