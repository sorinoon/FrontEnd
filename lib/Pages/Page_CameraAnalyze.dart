import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/globalMicButton.dart';

class Page_CameraAnalyze extends StatefulWidget {
  @override
  State<Page_CameraAnalyze> createState() => _Page_CameraAnalyzeState();
}

class _Page_CameraAnalyzeState extends State<Page_CameraAnalyze> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 카메라 화면
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              if (!_isProcessing && barcodes.isNotEmpty) {
                _isProcessing = true;
                controller.stop();
                debugPrint('Detected: ${barcodes.first.rawValue}');

                await Future.delayed(Duration(seconds: 2));
                _isProcessing = false;
                controller.start();
              }
            },
          ),

          // 커스텀 뒤로가기 버튼 (이미지 사용)
          Positioned(
            top: 70,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 30,
                height: 30,
                child: Image.asset(
                  'assets/images/Arrow_back.png',
                  fit: BoxFit.scaleDown, // 또는 BoxFit.fill
                ),
              ),
            ),
          ),

          // 상단 인식 모드 텍스트 (크기 증가)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '인식 모드',
                  style: TextStyle(
                    fontSize: 20, // 폰트 크기 증가
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // 글로벌 마이크 버튼 (왼쪽 하단)
          GlobalMicButton(
            onPressed: () {
              debugPrint('Global Mic Button tapped!');
              // 음성 인식 로직 추가 가능
            },
          ),

          // 중앙 하단 버튼 (이미지 버튼)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  debugPrint('Camera button tapped!');
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
