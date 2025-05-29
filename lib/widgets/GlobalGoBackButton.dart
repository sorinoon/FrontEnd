import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../Pages/User_SettingsProvider.dart';
import '../Pages/NOK_SettingsProvider.dart';
import '../Pages/LoginModeProvider.dart';

class GlobalGoBackButton extends StatelessWidget {
  final Widget? targetPage;
  final String? currentPageName;

  static const platform = MethodChannel('tmap_channel');

  const GlobalGoBackButton({super.key, this.targetPage, this.currentPageName});

  static const MethodChannel _channel = MethodChannel('tmap_channel');

  Future<void> _reloadMapIfNeeded() async {
    if (currentPageName == 'UserMapPage') {
      try {
        await _channel.invokeMethod('reloadMap');
      } catch (e) {
        debugPrint('Failed to reload map: $e');
      }
    }
  }

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

          // user_map 페이지에서만 reloadMap 호출
          await _reloadMapIfNeeded();

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
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
}
