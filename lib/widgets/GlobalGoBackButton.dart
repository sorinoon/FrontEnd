import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../Pages/User_SettingsProvider.dart';
import '../Pages/NOK_SettingsProvider.dart';
import '../Pages/LoginModeProvider.dart';

class GlobalGoBackButton extends StatelessWidget {

  const GlobalGoBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 40,
      child: GestureDetector(
        onTap: () async {
          final isProtectorMode = Provider.of<LoginModeProvider>(context, listen: false).isProtectorMode;

          if (isProtectorMode) {
            Provider.of<NOKSettingsProvider>(context, listen: false).vibrate();
          } else {
            Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
          }
          // 화면 밝기 복원
          await ScreenBrightness().setApplicationScreenBrightness(1.0);

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
