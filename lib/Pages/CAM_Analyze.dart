import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:screenshot/screenshot.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../widgets/globalMicButton.dart';
import '../widgets/GlobalGoBackButton.dart';
import 'package:flutter_tts/flutter_tts.dart';

class CameraAnalyzeScreen extends StatefulWidget {
  @override
  State<CameraAnalyzeScreen> createState() => CameraAnalyzeState();
}

class CameraAnalyzeState extends State<CameraAnalyzeScreen> {
  final MobileScannerController controller = MobileScannerController();
  final ScreenshotController screenshotController = ScreenshotController();
  final FlutterTts flutterTts = FlutterTts();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ko-KR");
    flutterTts.setSpeechRate(0.5);
  }

  // ✅ 화면 캡처 후 백엔드로 전송하고, summary를 TTS로 읽음
  Future<void> captureAndSendScreen() async {
    try {
      final capturedImage = await screenshotController.capture();
      if (capturedImage == null) {
        debugPrint('화면 캡처 실패');
        return;
      }

      final uri = Uri.parse('http://172.30.1.55:8000/ocr-summary/');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(http.MultipartFile.fromBytes(
        'image',
        capturedImage,
        filename: 'screenshot.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        debugPrint('서버 전송 성공');

        final decoded = jsonDecode(responseBody);
        final summary = decoded['summary'];

        if (summary != null && summary is String) {
          await flutterTts.speak(summary); // ✅ TTS로 음성 출력
        }

      } else {
        debugPrint('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('전송 중 예외 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            MobileScanner(
              controller: controller,
              onDetect: (capture) async {
                final List<Barcode> barcodes = capture.barcodes;
                if (!_isProcessing && barcodes.isNotEmpty) {
                  _isProcessing = true;
                  controller.stop();
                  final barcodeValue = barcodes.first.rawValue ?? 'Unknown';
                  debugPrint('Detected: $barcodeValue');

                  await Future.delayed(Duration(seconds: 2));
                  _isProcessing = false;
                  controller.start();
                }
              },
            ),

            GlobalGoBackButton(),

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
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            GlobalMicButton(
              onPressed: () async {
                debugPrint('마이크 버튼 클릭됨');
                await captureAndSendScreen();
              },
            ),

            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    debugPrint('카메라 버튼 클릭됨');
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
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    flutterTts.stop(); // ✅ TTS 종료 처리
    super.dispose();
  }
}



// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'dart:typed_data';
// import 'dart:convert';
// import '../widgets/globalMicButton.dart';
// import '../widgets/GlobalGoBackButton.dart';
// import 'package:flutter_tts/flutter_tts.dart';
//
// class CameraAnalyzeScreen extends StatefulWidget {
//   @override
//   //State<CameraAnalyzeScreen> createState() => _Page_CameraAnalyzeState();
//   State<CameraAnalyzeScreen> createState() => CameraAnalyzeState();
// }
//
// class CameraAnalyzeState extends State<CameraAnalyzeScreen> {
//   final MobileScannerController controller = MobileScannerController();
//   final ScreenshotController screenshotController = ScreenshotController();
//   bool _isProcessing = false;
//   final FlutterTts flutterTts = FlutterTts();
//
//   // 화면 캡처 후 백엔드로 전송
//   Future<void> captureAndSendScreen() async {
//     try {
//       final capturedImage = await screenshotController.capture();
//       if (capturedImage == null) {
//         debugPrint('화면 캡처 실패');
//         return;
//       }
//
//       final uri = Uri.parse('http://192.168.45.250:8000/ocr-summary/'); // ← 여기에 백엔드 주소 입력
//       final request = http.MultipartRequest('POST', uri);
//         //..files.add(http.MultipartFile.fromBytes('image', capturedImage, filename: 'screenshot.jpg'));
//
//       request.files.add(http.MultipartFile.fromBytes(
//         'image',
//         capturedImage,
//         filename: 'screenshot.jpg',
//         contentType: MediaType('image', 'jpeg'),
//       ));
//
//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//       if (response.statusCode == 200) {
//         debugPrint('서버 전송 성공');
//       } else {
//         debugPrint('서버 오류: ${response.statusCode}');;
//       }
//     } catch (e) {
//       debugPrint('전송 중 예외 발생: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Screenshot(
//       controller: screenshotController,
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Stack(
//           children: [
//             // 카메라 화면
//             MobileScanner(
//               controller: controller,
//               onDetect: (capture) async {
//                 final List<Barcode> barcodes = capture.barcodes;
//                 if (!_isProcessing && barcodes.isNotEmpty) {
//                   _isProcessing = true;
//                   controller.stop();
//                   final barcodeValue = barcodes.first.rawValue ?? 'Unknown';
//                   debugPrint('Detected: $barcodeValue');
//
//                   // 백엔드 연동 제거됨
//
//                   await Future.delayed(Duration(seconds: 2));
//                   _isProcessing = false;
//                   controller.start();
//                 }
//               },
//             ),
//
//             GlobalGoBackButton(),
//
//             // 상단 텍스트
//             Positioned(
//               top: 60,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.yellow,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '인식 모드',
//                     style: TextStyle(
//                       fontSize: 20,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // Global Mic Button (왼쪽 하단)
//             GlobalMicButton(
//               onPressed: () async {
//                 debugPrint('마이크 버튼 클릭됨');
//                 await captureAndSendScreen();
//               },
//             ),
//
//             // 중앙 하단 이미지 버튼
//             Positioned(
//               bottom: 30,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: GestureDetector(
//                   onTap: () {
//                     debugPrint('📸 카메라 버튼 클릭됨');
//                   },
//                   child: Container(
//                     width: 130,
//                     height: 130,
//                     child: Image.asset(
//                       'assets/images/camBtn.png',
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
// }
//
//
