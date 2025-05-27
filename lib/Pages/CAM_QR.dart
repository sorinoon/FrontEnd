import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/GlobalMicButton.dart';
import '../widgets/GlobalGoBackButton.dart';
import 'User_Home.dart';

class CAMQRScreen extends StatefulWidget {
  @override
  _CAMQRState createState() => _CAMQRState();
}

class _CAMQRState extends State<CAMQRScreen> {
  MobileScannerController controller = MobileScannerController();
  final FlutterTts flutterTts = FlutterTts();
  final String validCode = "123456"; // 비교할 QR 코드 (6자리 숫자)
  bool _isScanned = false;

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  void _handleQRCode(String? code) async {
    if (code == null || _isScanned) return;
    _isScanned = true;
    controller.stop();

    if (code == validCode) {
      await _speak("보호자 등록에 성공하였습니다.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserHomeScreen()),
      );
    } else {
      await _speak("보호자 등록에 실패하였습니다. 이전 화면으로 돌아갑니다.");
      Navigator.pop(context);
    }

    _isScanned = false;
    controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final cutOutSize = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 카메라 화면
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                _handleQRCode(code);
              }
            },
          ),

          // 뒤로가기 버튼
          GlobalGoBackButton(),

          // 중앙 텍스트 + 가이드 박스
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - cutOutSize / 2 - 70,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: cutOutSize,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Text(
                        '중앙에 QR코드를 위치해주세요',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: cutOutSize,
                    height: cutOutSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 6),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 마이크 버튼
          GlobalMicButton(
            onPressed: () {
              debugPrint('Global Mic Button tapped!');
            },
          ),

          // 카메라 버튼
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  print('Camera button tapped!');
                },
                child: Container(
                  width: 130,
                  height: 130,
                  child: Image.asset(
                    'assets/images/camBtn.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    flutterTts.stop();
    super.dispose();
  }
}
