import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_protector.dart'; // HomeScreen 임포트

class ProtectorSettingScreen extends StatefulWidget {
  @override
  _ProtectorSettingScreenState createState() => _ProtectorSettingScreenState();
}

class _ProtectorSettingScreenState extends State<ProtectorSettingScreen> {
  bool toggleValue1 = false;
  bool toggleValue2 = false;

  @override
  Widget build(BuildContext context) {
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
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
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
                  fontSize: 25,
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
                  subtitle: '어플리케이션 알림을 진동으로 전환합니다.',
                  hasToggle: true,
                  toggleValue: toggleValue1,
                  onToggleChanged: (value) {
                    setState(() {
                      toggleValue1 = value;
                    });
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
                  toggleValue: toggleValue2,
                  onToggleChanged: (value) {
                    setState(() {
                      toggleValue2 = value;
                    });
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

  SettingItem({
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
    return InkWell(
      onTap: hasToggle ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 11, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 제목과 subtitle을 묶어서 표시
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18),
                ),
                if (subtitle != null) // subtitle이 있는 경우
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle!,
                      style: TextStyle(fontSize: 12, color: Color(0xff8F8996)),
                    ),
                  ),
              ],
            ),

            // 우측 요소 (토글, 텍스트)
            if (hasToggle)
              CupertinoSwitch(
                value: toggleValue ?? false,
                onChanged: onToggleChanged,
                activeTrackColor: Color(0xff80C5A4), // 활성화된 트랙 색상
                inactiveTrackColor: Color(0xffE7E7E8), // 비활성화된 트랙 색상
                thumbColor: CupertinoColors.white, // 원 색상
              )
            else if (rightText != null) // 토글이 없어도 rightText가 있으면 우측 정렬
              Text(
                rightText!,
                style: TextStyle(fontSize: 14, color: Color(0xff8F8996)),
              ),
          ],
        ),
      ),
    );
  }
}