import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'User_SettingsProvider.dart';
import 'NOK_Home.dart';
import 'User_NOKList.dart';
import 'User_Home.dart';
import '../Pages/User_NOKConnect.dart';
import '../widgets/GlobalMicButton.dart';
import '../widgets/GlobalGoBackButton.dart';
import '../widgets/SettingMicButton.dart';

class UserSettingScreen extends StatefulWidget {
  const UserSettingScreen({super.key});

  @override
  _UserSettingScreenState createState() => _UserSettingScreenState();
}

class _UserSettingScreenState extends State<UserSettingScreen> {
  late FlutterTts _flutterTts; // TTS 객체 선언
  bool isDoubleTap = false;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("ko-KR");
  }

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop(); // 앱 종료 시 TTS 멈추기
  }

  // TTS로 텍스트 읽기
  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  bool toggleValue1 = false;
  bool toggleValue2 = false;

  @override
  Widget build(BuildContext context) {
    final UserSettings = Provider.of<UserSettingsProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image.jpg',
              fit: BoxFit.cover,
            ),
          ),

          GlobalGoBackButton(targetPage: UserHomeScreen()),

          // 제목
          Positioned(
            top: 45.5,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _speak("설정");
                  Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                },
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
          ),

          // 설정 목록
          Positioned(
            top: 105,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /*SettingItem(
                    title: '카카오계정',
                    rightText: 'user_hansungKim123@naver.com',
                    hasToggle: false,
                    onTap: () {
                      _speak("카카오계정");
                      Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                    },
                  ),
                  Divider(
                    color: Color(0xff5B5B5B),
                    thickness: 1,
                    indent: 15, // 선의 시작 위치
                    endIndent: 15, // 선의 끝 위치
                  ),*/
                  SettingItem(
                    title: '저전력 모드',
                    subtitle: '네비게이션 사용 시\n자동으로 저전력 모드로 전환합니다.',
                    hasToggle: true,
                    toggleValue: UserSettings.isLowPowerModeEnabled,
                    onTap: () {
                      _speak("저전력 모드 : 네비게이션 사용 시 자동으로 저전력 모드로 전환합니다.");
                      Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                    },
                    onToggleChanged: (value) {
                      UserSettings.toggleLowPowerMode(value);
                      Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                    },
                  ),
                  Divider(
                    color: Color(0xff5B5B5B),
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                  ),
                  SettingItem(
                    title: '진동 모드',
                    subtitle: '버튼 터치 시 진동 피드백을 제공합니다.',
                    hasToggle: true,
                    onTap: () {
                      _speak("진동 모드 : 버튼 터치 시 진동 피드백을 제공합니다.");
                      Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                    },
                    toggleValue: UserSettings.isVibrationEnabled,
                    onToggleChanged: (value) {
                      UserSettings.toggleVibration(value);
                      Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                    },
                  ),
                  Divider(
                    color: Color(0xff5B5B5B),
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                  ),
                  SettingItem(
                    title: '글자 크기 키우기',
                    subtitle: '저시력 사용자를 위해 글자 크기를 최대로 키웁니다.',
                    hasToggle: true,
                    onTap: () {
                      _speak("글자 크기 키우기 : 저시력 사용자를 위해 글자 크기를 최대로 키웁니다.");
                      Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                    },
                    toggleValue: UserSettings.isFontSizeIncreased, // 토글 - 전역 상태 사용
                    onToggleChanged: (value) {
                      UserSettings.toggleFontSize(value); // 전역 상태 업데이트
                      Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                    },
                  ),
                  Divider(
                    color: Color(0xff5B5B5B),
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                  ),

                  // 보호자 관리
                  /*Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 5, left: 15, right: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '보호자 관리',
                        style: TextStyle(
                          fontSize: 20 + UserSettings.fontSizeOffset,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),*/
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 5, left: 15, right: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          _speak("보호자 관리");
                          Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                        },
                        child: Text(
                          '보호자 관리',
                          style: TextStyle(
                            fontSize: 20 + UserSettings.fontSizeOffset,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Divider(
                    color: Color(0xff5B5B5B),
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                  ),
                  SettingItem(
                    title: '보호자 등록하기',
                    subtitle: '보호자를 추가로 등록합니다.\n고유 번호 혹은 QR 코드를 이용할 수 있습니다.',
                    hasToggle: false,
                    rightIcon: Icons.arrow_forward_ios,
                    onTap: () {
                      _speak("보호자 등록하기 : 보호자를 추가로 등록합니다. 고유 번호 혹은 QR 코드를 이용할 수 있습니다.");
                      Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                    },
                    onDoubleTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NOKConnectScreen()),
                      );
                      Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                    },
                  ),
                  Divider(
                    color: Color(0xff5B5B5B),
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                  ),
                  SettingItem(
                    title: '보호자 목록',
                    hasToggle: false,
                    rightIcon: Icons.arrow_forward_ios,
                    onTap: () {
                      _speak("보호자 목록");
                      Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                    },
                    onDoubleTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProtectorListScreen()),
                      );
                      Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                    },
                  ),
                  Divider(
                    color: Color(0xff5B5B5B),
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                  ),

                ],
              ),
            ),
          ),
          SettingMicButton(
            onPressed: () {
              Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
            },
          ),
        ],
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? rightText;
  final IconData? rightIcon;
  final bool hasToggle;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const SettingItem({super.key,
    required this.title,
    this.subtitle,
    this.rightText,
    this.rightIcon,
    this.hasToggle = false,
    this.toggleValue,
    this.onToggleChanged,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final fontSizeOffset = Provider.of<UserSettingsProvider>(context).fontSizeOffset;

    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 11, horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 제목과 subtitle을 포함하는 왼쪽 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 텍스트
                  Text(
                    title,
                    style: TextStyle(fontSize: 20 + fontSizeOffset),
                  ),
                  // subtitle
                  if (subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle!,
                        style: TextStyle(fontSize: 14 + fontSizeOffset, color: Color(0xff8F8996)),
                        overflow: TextOverflow.visible, // 텍스트가 길어질 경우 자동 줄바꿈
                      ),
                    ),
                ],
              ),
            ),

            // 우측 요소 (토글, 텍스트, 아이콘)
            if (hasToggle)
              CupertinoSwitch(
                value: toggleValue ?? false,
                onChanged: onToggleChanged,
                activeTrackColor: Color(0xffF8CB38), // 활성화된 트랙 색상
                inactiveTrackColor: Color(0xffE7E7E8),  // 비활성화된 트랙 색상
                thumbColor: CupertinoColors.white, // 원 색상
              )
            else if (rightText != null) // 토글이 없어도 우측 정렬
              Flexible(
                child: Text(
                  rightText!,
                  style: TextStyle(fontSize: 14 + fontSizeOffset, color: Color(0xff8F8996)),
                  overflow: TextOverflow.visible,
                ),
              )
            else if (rightIcon != null)
              GestureDetector(
                onTap: onTap,
                onDoubleTap: onDoubleTap,
                child: Icon(
                  rightIcon,
                  size: 25,
                ),
              ),
          ],
        ),
      ),
    );
  }
}