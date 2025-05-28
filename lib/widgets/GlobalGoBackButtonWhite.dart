import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../Pages/User_SettingsProvider.dart';
import '../Pages/NOK_SettingsProvider.dart';
import '../Pages/LoginModeProvider.dart';

class GlobalGoBackButtonWhite extends StatelessWidget {
  final Widget? targetPage;
  final VoidCallback? onTap;

  const GlobalGoBackButtonWhite({
    super.key,
    this.targetPage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 40,
      child: GestureDetector(
        onTap: () async {
          if (onTap != null) {
            onTap!();
            return;
          }

          final isProtectorMode = Provider.of<LoginModeProvider>(context, listen: false).isProtectorMode;

          if (isProtectorMode) {
            Provider.of<NOKSettingsProvider>(context, listen: false).vibrate();
          } else {
            Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
          }
          // 화면 밝기 복원
          await ScreenBrightness().setApplicationScreenBrightness(1.0);

          // 특정 페이지로 이동 혹은 이전 페이지로 이동
          if (targetPage != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => targetPage!),
            );
          } else if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        child: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
