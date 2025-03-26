import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home_protector.dart';
import 'package:provider/provider.dart';
import 'ProtectorSettingsProvider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isToggled = false;

  @override
  Widget build(BuildContext context) {
    final protectorSettings = Provider.of<ProtectorSettingsProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // 배경
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // 로고 및 이름
          Positioned(
            top: 230 - protectorSettings.fontSizeOffset * 4,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: isToggled ? Color(0xff80C5A4) : Color(0xffF8CB38), // 네모 박스 색상
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image, // 로고 대체
                        color: Colors.white,
                        size: 40 + protectorSettings.fontSizeOffset,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  // 앱 이름
                  Text(
                    '소리눈',
                    style: TextStyle(
                      fontSize: 40 + protectorSettings.fontSizeOffset,
                      fontWeight: FontWeight.bold,
                      color: isToggled ? Color(0xff80C5A4) : Color(0xffF8CB38),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 450 - protectorSettings.fontSizeOffset * 5), // 로고와 버튼 간격 조정
                Container(
                  width: 307 + protectorSettings.fontSizeOffset * 10,
                  height: 57 + protectorSettings.fontSizeOffset * 2,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFE726),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all( // 테두리
                      color: Color(0xffe2e2e2),
                      width: 1,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      print("버튼 1");
                    },
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center, // 이미지와 텍스트가 중앙에 오도록
                      children: [
                        Image.asset(
                          'assets/images/kakao_logo.jpg',
                          width: 46,
                          height: 37,
                        ),
                        SizedBox(width: 2),
                        Text(
                          '카카오로 3초만에 시작하기',
                          style: TextStyle(
                            color: Color(0xff4D3033),
                            fontWeight: FontWeight.bold,
                            fontSize: 18 + protectorSettings.fontSizeOffset,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20), // 버튼 간 간격 조정
                Container(
                  width: 307 + protectorSettings.fontSizeOffset * 10,
                  height: 57 + protectorSettings.fontSizeOffset * 2,
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    borderRadius:
                    BorderRadius.circular(50), // 둥근 모서리 적용
                    border:
                    Border.all(color: Colors.black, width: 1), // 테두리 적용
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder:
                            (context) => HomeScreen()),
                      );
                      print("버튼 2");
                    },
                    child:
                    Text(
                      '어플 둘러보기',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18 + protectorSettings.fontSizeOffset,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 800,
            left: 0,
            right: 0,
            child: Center( // 중앙 정렬
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // CupertinoSwitch 토글
                  CupertinoSwitch(
                    value: isToggled,
                    onChanged: (bool value) {
                      setState(() {
                        isToggled = value;
                      });
                    },
                    activeTrackColor: Color(0xff80C5A4), // 활성화된 트랙 색상
                    inactiveTrackColor: Color(0xffF8CB38), // 비활성화된 트랙 색상
                    thumbColor: CupertinoColors.white, // 원 색상
                  ),
                  SizedBox(width: 5),
                  // 텍스트
                  Text(
                    isToggled ? '보호자로 로그인' : '사용자로 로그인',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18 + protectorSettings.fontSizeOffset,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
