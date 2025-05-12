import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../widgets/GlobalMicButton.dart';
import '../widgets/GlobalGoBackButton.dart';
import '../Pages/User_NOKConnect.dart';
import '../Pages/Page_NOKList.dart';
import '../Pages/User_SettingsProvider.dart';

class PageSetting extends StatefulWidget {
  const PageSetting({super.key});

  @override
  _PageSettingState createState() => _PageSettingState();
}

class _PageSettingState extends State<PageSetting> {
  @override
  Widget build(BuildContext context) {
    final UserSettings = Provider.of<UserSettingsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          GlobalGoBackButton(

          ),

          // 제목
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '설정',
                style: TextStyle(
                  fontSize: 25 + UserSettings.fontSizeOffset,
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
                      Text("카카오계정", style: TextStyle(fontSize: 20 + UserSettings.fontSizeOffset)),
                      Expanded(
                        child: Text(
                          "user_hansungKim123@naver.com",
                          style: TextStyle(
                            fontSize: 14 + UserSettings.fontSizeOffset,
                            color: Color(0xff8F8996),
                          ),
                          overflow: TextOverflow.visible,
                          textAlign: TextAlign.end, // 우측 정렬
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: Color(0xff5B5B5B)),

                  _buildSwitchTile(
                    '저전력 모드',
                    '네비게이션 사용 시\n자동으로 저전력 모드로 전환합니다.',
                      UserSettings.isLowPowerModeEnabled,
                        (value) {
                      UserSettings.toggleLowPowerMode(value);
                      Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                    },
                  ),
                  _buildSwitchTile(
                    '진동 모드',
                    '버튼 터치 시 진동 피드백을 제공합니다.',
                    UserSettings.isVibrationEnabled,
                        (value) {
                      UserSettings.toggleVibration(value);
                      Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                    },
                  ),
                  _buildSwitchTile(
                    '글자 크기 키우기',
                    '저시력 사용자를 위해\n글자 크기를 최대로 키웁니다.',
                    UserSettings.isFontSizeIncreased,
                        (value) {
                      UserSettings.toggleFontSize(value); // 전역 상태 업데이트
                      Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                    },
                  ),

                  const Divider(height: 16, color: Color(0xff5B5B5B)),
                  const SizedBox(height: 25),

                  Text(
                    "보호자 관리",
                    style: TextStyle(
                      fontSize: 22 + UserSettings.fontSizeOffset,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildArrowTile(
                    '보호자 등록하기',
                    subtitle: '보호자를 추가로 등록합니다.\n고유 번호 혹은 QR 코드를 이용할 수 있습니다.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NOKConnectScreen()),
                      );
                      Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                    },
                  ),
                  const Divider(height: 8),
                  const SizedBox(height: 10),

                  _buildArrowTile(
                    '보호자 목록',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ListScreen()),
                      );
                      Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                    },
                  ),
                ],
              ),
            ),
          ),
          GlobalMicButton(
            onPressed: () {
              // 마이크 버튼 눌렀을 때 동작 정의
              print('마이크 버튼 클릭');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool initialValue, ValueChanged<bool> onChanged) {
    final userSettings = Provider.of<UserSettingsProvider>(context);
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
                  Text(title, style: TextStyle(fontSize: 20 + userSettings.fontSizeOffset)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14 + userSettings.fontSizeOffset, color: Color(0xff8F8996))),
                ],
              ),
            ),
            CupertinoSwitch(
              value: initialValue,
              onChanged: onChanged,
              activeTrackColor: const Color(0xffF8CB38), // 활성화된 트랙 색상
              inactiveTrackColor: const Color(0xffE7E7E8), // 비활성화된 트랙 색상
              thumbColor: CupertinoColors.white, // 스위치 원 색상
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildArrowTile(String title, {String? subtitle, VoidCallback? onTap}) {
    final userSettings = Provider.of<UserSettingsProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 20 + userSettings.fontSizeOffset)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(fontSize: 14 + userSettings.fontSizeOffset, color: Color(0xff8F8996))),
                    ]
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 25),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
