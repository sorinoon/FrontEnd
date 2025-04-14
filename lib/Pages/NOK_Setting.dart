import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../widgets/GlobalGoBackButton.dart';
import '../Pages/NOK_SettingsProvider.dart';
import '../Pages/NOK_Home.dart';


class NOKSettingScreen extends StatefulWidget {
  const NOKSettingScreen({super.key});

  @override
  _NOKSettingScreen createState() => _NOKSettingScreen();
}

class _NOKSettingScreen extends State<NOKSettingScreen> {
  // bool toggleValue1 = false;

  @override
  Widget build(BuildContext context) {
    final protectorSettings = Provider.of<NOKSettingsProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image.jpg',
              fit: BoxFit.cover,
            ),
          ),

          GlobalGoBackButton(),

          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '설정',
                style: TextStyle(
                  fontSize: 25 + protectorSettings.fontSizeOffset,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("카카오계정", style: TextStyle(fontSize: 20 + protectorSettings.fontSizeOffset)),
                      Expanded(
                        child: Text(
                          "hansungKim123@naver.com",
                          style: TextStyle(
                            fontSize: 14 + protectorSettings.fontSizeOffset,
                            color: Color(0xff8F8996),
                          ),
                          overflow: TextOverflow.visible,
                          textAlign: TextAlign.end, // 우측 정렬
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 40, color: Color(0xff5B5B5B)),

                  _buildSwitchTile(
                    '진동 모드',
                    '버튼 터치 시 진동 피드백을 제공합니다.',
                    protectorSettings.isVibrationEnabled,
                        (value) {
                          protectorSettings.toggleVibration(value);
                      Provider.of<ProtectorSettingsProvider>(context, listen: false).vibrate();
                    },
                  ),
                  _buildSwitchTile(
                    '글자 크기 키우기',
                    '저시력 사용자를 위해\n글자 크기를 최대로 키웁니다.',
                    protectorSettings.isFontSizeIncreased,
                        (value) {
                          protectorSettings.toggleFontSize(value); // 전역 상태 업데이트
                      Provider.of<ProtectorSettingsProvider>(context, listen: false).vibrate();
                    },
                  ),

                  const Divider(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool initialValue, ValueChanged<bool> onChanged) {
    final protectorSettings = Provider.of<ProtectorSettingsProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 20 + protectorSettings.fontSizeOffset)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14 + protectorSettings.fontSizeOffset, color: Color(0xff8F8996))),
                ],
              ),
            ),
            CupertinoSwitch(
              value: initialValue,
              onChanged: onChanged,
              activeTrackColor: const Color(0xff80C5A4), // 활성화된 트랙 색상
              inactiveTrackColor: const Color(0xffE7E7E8), // 비활성화된 트랙 색상
              thumbColor: CupertinoColors.white, // 스위치 원 색상
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}