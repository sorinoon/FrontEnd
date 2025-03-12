import 'package:flutter/material.dart';
import 'home_protector.dart'; // HomeScreen 임포트

class QRScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          Positioned(
            top: 115,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 325,
                    height: 386,
                    decoration: BoxDecoration(
                      color: Color(0xffF0F0F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 190,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Image.asset(
                      'assets/images/qr.png',
                      fit: BoxFit.cover,
                      width: 180,
                      height: 180,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 410,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                '6  6  0  5  8  4',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Positioned(
            top: 540,
            left: 105,
            child: GestureDetector(
              child: Icon(
                Icons.content_copy,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),
          Positioned(
            top: 540,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                child: Icon(
                  Icons.ios_share,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
          ),
          Positioned(
            top: 540,
            right : 105,
            child: GestureDetector(
              child: Image.asset(
                'assets/images/download.png',
                width: 31,
                height: 31,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 590,
            left: 30,
            right: 30,
            child: Container(
              height: 2,
              color: Color(0xffA5A5A5),
            ),
          ),
          Positioned(
            top: 630,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                '사용자의 기기에서 로그인 후\n고유 번호를 입력 혹은 QR 코드를 인식해주세요.\n\n이후에는 사용자 기기의 설정에서\n보호자 추가 등록이 가능합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffA5A5A5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}