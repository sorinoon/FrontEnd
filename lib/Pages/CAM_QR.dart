import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/GlobalMicButton.dart';
import '../widgets/GlobalGoBackButton.dart';

class CAMQRScreen extends StatefulWidget {
  @override
  _CAMQRState createState() => _CAMQRState();
}

class _CAMQRState extends State<CAMQRScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _isScanned = false;

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
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              if (!_isScanned && barcodes.isNotEmpty) {
                _isScanned = true;
                controller.stop();
                debugPrint('QR Code Scanned: ${barcodes.first.rawValue}');

                await Future.delayed(Duration(seconds: 2));
                _isScanned = false;
                controller.start();
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
                    width: cutOutSize, // 박스와 너비 동일하게 맞춤!
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8), // 텍스트 수직 패딩만
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
                      border: Border.all(
                        color: Colors.yellow,
                        width: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 글로벌 마이크 버튼
          GlobalMicButton(
            onPressed: () {
              debugPrint('Global Mic Button tapped!');
              // 음성 인식 기능 연결 가능
            },
          ),

          // 중앙 하단 카메라 버튼
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
    super.dispose();
  }
}
