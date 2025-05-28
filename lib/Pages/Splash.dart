import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _overlayOpacity = 1.0;

  @override
  void initState() {
    super.initState();

    // 3.5초 후 흐려지기 시작
    Future.delayed(const Duration(milliseconds: 4500), () {
      setState(() => _overlayOpacity = 0.0);

      // 2초 동안 흐려진 후 Login 페이지로 이동
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const LoginScreen(), // 배경에 미리 렌더링
        AnimatedOpacity(
          duration: const Duration(seconds: 2),
          opacity: _overlayOpacity,
          child: Container(
            color: const Color(0xFFF8CB38),
            child: Center(
              child: Lottie.asset(
                'assets/lottie/Splash.json',
                width: 500,
                repeat: false,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
