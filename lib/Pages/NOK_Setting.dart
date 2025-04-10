import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../Pages/NOK_SettingsProvider.dart';
import 'NOK_Home.dart';


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
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // goBack 버튼
          Positioned(
            top: 40,
            left: 30,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NOKHomeScreen()),
                );
                Provider.of<NOKSettingsProvider>(context, listen: false).vibrate();
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),

          // 제목
          Positioned(
            top: 40,
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

          // 설정 목록
          Positioned(
            top: 105,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                SettingItem(
                  title: '카카오계정',
                  rightText: 'hansungKim123@naver.com',
                  hasToggle: false,
                ),
                Divider(
                  color: Color(0xff5B5B5B),
                  thickness: 1,
                  indent: 15, // 선의 시작 위치
                  endIndent: 15, // 선의 끝 위치
                ),
                SettingItem(
                  title: '진동 모드',
                  subtitle: '버튼 터치 시 진동 피드백을 제공합니다.',
                  hasToggle: true,
                  toggleValue: protectorSettings.isVibrationEnabled,
                  onToggleChanged: (value) {
                    protectorSettings.toggleVibration(value);
                    Provider.of<NOKSettingsProvider>(context, listen: false).vibrate();
                  },
                  // toggleValue: toggleValue1,
                  // onToggleChanged: (value) {
                  //   setState(() {
                  //     toggleValue1 = value;
                  //   });
                  // },
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
                  toggleValue: protectorSettings.isFontSizeIncreased,
                  onToggleChanged: (value) {
                    protectorSettings.toggleFontSize(value);
                    Provider.of<NOKSettingsProvider>(context, listen: false).vibrate();
                  }
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
        ],
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? rightText;
  final bool hasToggle;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final VoidCallback? onTap;

  const SettingItem({
    super.key,
    required this.title,
    this.subtitle,
    this.rightText,
    this.hasToggle = false,
    this.toggleValue,
    this.onToggleChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fontSizeOffset = Provider.of<NOKSettingsProvider>(context).fontSizeOffset;

    return InkWell(
      onTap: hasToggle ? null : onTap,
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
                    overflow: TextOverflow.visible, // 텍스트가 길어질 경우 줄바꿈
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle!,
                        style: TextStyle(fontSize: 14 + fontSizeOffset, color: Color(0xff8F8996)),
                        overflow: TextOverflow.visible, // 텍스트가 길어질 경우 줄바꿈
                      ),
                    ),
                ],
              ),
            ),

            // 우측 요소 (토글 또는 텍스트)
            if (hasToggle)
              CupertinoSwitch(
                value: toggleValue ?? false,
                onChanged: onToggleChanged,
                activeTrackColor: Color(0xff80C5A4), // 활성화된 트랙 색상
                inactiveTrackColor: Color(0xffE7E7E8), // 비활성화된 트랙 색상
                thumbColor: CupertinoColors.white, // 원 색상
              )
            else if (rightText != null)
              Flexible(
                child: Text(
                  rightText!,
                  style: TextStyle(fontSize: 14 + fontSizeOffset, color: Color(0xff8F8996)),
                  overflow: TextOverflow.visible, // 텍스트가 길어질 경우 줄바꿈
                ),
              ),
          ],
        ),
      ),
    );
  }
}
