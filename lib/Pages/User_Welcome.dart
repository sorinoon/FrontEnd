import 'package:sorinoon/Pages/User_Home.dart';

import '../Pages/User_NOKConnect.dart';
import 'package:flutter/material.dart';
import '../widgets/GlobalMicButton.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 배경 (격자무늬 이미지)
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png', // 격자 배경 이미지
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 140.0, left: 20.0, right: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 프로필 이미지
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    'assets/images/profile.png', // 프로필 이미지
                    width: 80,
                    height: 80,
                  ),
                ),
                const SizedBox(height: 20),

                // 환영 인사
                const Text(
                  '전준혁님 환영해요!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                // 설명 박스
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '소리눈은 시각장애인을 위한 다양한 편의 기능을 제공하는 앱입니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '보호자 등록을 원한다면\n6자리 고유번호나 QR 코드를 통해\n등록할 수 있어요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '등록하지 않아도 사용 가능하니\n편한 방식으로 진행하세요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 보호자 등록 버튼
                SizedBox(
                  width: screenWidth * 0.8,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NOKConnectScreen()),
                    );},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      '보호자 고유번호 등록하기',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // or 텍스트
                const Text(
                  'or',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 10),

                // 등록하지 않고 사용 버튼
                SizedBox(
                  width: screenWidth * 0.8,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const UserHomeScreen()),
                      );},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      '등록하지 않고 사용하기',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 하단 설명 텍스트
                const Text(
                  '보호자는 나중에 설정에서 추가로 등록할 수도 있어요..',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          // 글로벌 위젯 (GlobalMicButton.dart)
          GlobalMicButton(
            onPressed: () {
              // 마이크 버튼 눌렀을 때 실행될 코드 (선택)
              print("마이크 버튼 눌림 - WelcomePage");
            },
          ),
        ],
      ),
    );
  }
}
