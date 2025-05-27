import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  double _overlayOpacity = 1.0;
  bool _showLottie = false;

  @override
  void initState() {
    super.initState();

    // 5초간 배경 보여주기 → 이후 Lottie 재생
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showLottie = true;
      });
    });

    // 로티 재생 + 흐려짐 → Login 화면 이동
    Future.delayed(const Duration(seconds: 4), () {
      setState(() => _overlayOpacity = 0.0);
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Login 화면 구조 미리 렌더링 (인터랙션은 막힘)
    return Stack(
      children: [
        const LoginScreen(), // 백그라운드
        AnimatedOpacity(
          duration: const Duration(seconds: 2),
          opacity: _overlayOpacity,
          child: Container(
            color: const Color(0xFFF8CB38),
            child: Center(
              child: _showLottie
                  ? SizedBox(
                width: MediaQuery.of(context).size.width * 4.0,
                child: Lottie.asset(
                  'assets/lottie/splash_fill.json',
                  repeat: false,
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}
