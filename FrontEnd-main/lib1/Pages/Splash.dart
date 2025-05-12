import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sorinoon/Pages/Login.dart';
import '../Pages/Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showLogo = false; // 로고 표시 여부

  @override
  void initState() {
    super.initState();

    // 3초 후에 Lottie 애니메이션을 숨기고 로고 이미지를 표시
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 설정
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!showLogo) // showLogo가 false일 때 Lottie 애니메이션 표시
              Lottie.asset(
                'assets/lottie/loadingY.json', // Lottie 파일 경로
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              )
            else // showLogo가 true일 때 로고 이미지 표시
              Column(
                children: [
                  Image.asset(
                    'assets/Image/Logo_L.png', // 로고 이미지
                    width: 150,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '똑똑',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'LogoFont',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
