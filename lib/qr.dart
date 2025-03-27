import 'package:flutter/material.dart';
import 'home_protector.dart'; // HomeScreen 임포트
import 'dart:math';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart'; // 스크린샷 패키지
import 'package:share_plus/share_plus.dart'; // 공유 패키지
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'ProtectorSettingsProvider.dart';

Set<String> usedCodes = {}; // 이미 사용된 코드 저장 (중복 방지)

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final String uniqueCode = generateUniqueCode(); // 고유 번호 생성
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final protectorSettings = Provider.of<ProtectorSettingsProvider>(context);

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
                Provider.of<ProtectorSettingsProvider>(context, listen: false).vibrate();
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 325,
                height: 386,
                decoration: BoxDecoration(
                  color: Color(0xffF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Screenshot(
                      controller: screenshotController,
                      child: Container(
                        color: Color(0xffF0F0F0),
                        child: QrImageView(
                          data: uniqueCode.replaceAll(" ", ""), // QR 데이터 (공백 제거)
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Color(0xffF0F0F0),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      uniqueCode, // 랜덤 숫자
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30 + protectorSettings.fontSizeOffset / 2,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 복사 버튼, 공유 버튼, 저장 버튼
          Positioned(
            bottom: 300,
            left: 105,
            right: 105,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 버튼 간격 조정
              children: [
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: uniqueCode.replaceAll(" ", "")));
                    showCustomSnackBar(context, "고유 번호가 복사되었습니다.");
                    Provider.of<ProtectorSettingsProvider>(context, listen: false).vibrate();
                  },
                  child: Icon(
                    Icons.content_copy,
                    color: Colors.black,
                    size: 30 + protectorSettings.fontSizeOffset,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    Provider.of<ProtectorSettingsProvider>(context, listen: false).vibrate();
                    await _shareQRCode();
                  },
                  child: Icon(
                    Icons.ios_share,
                    color: Colors.black,
                    size: 30 + protectorSettings.fontSizeOffset,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    Provider.of<ProtectorSettingsProvider>(context, listen: false).vibrate();
                    await _saveQRCode(context);
                  },
                  child: Image.asset(
                    'assets/images/download.png',
                    width: 31 + protectorSettings.fontSizeOffset,
                    height: 31 + protectorSettings.fontSizeOffset,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 250,
            left: 30,
            right: 30,
            child: Container(
              height: 2,
              color: Color(0xffA5A5A5),
            ),
          ),
          Positioned(
            bottom: 100 - protectorSettings.fontSizeOffset * 4 ,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                '사용자의 기기에서 로그인 후\n고유 번호를 입력 혹은 QR 코드를 인식해주세요.\n\n이후에는 사용자 기기의 설정에서\n보호자 추가 등록이 가능합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16 + protectorSettings.fontSizeOffset / 2,
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

  // QR 코드 공유 기능
  Future<void> _shareQRCode() async {
    try {
      final directory = await getTemporaryDirectory();
      final imageFile = await screenshotController.captureAndSave(directory.path, fileName: "qr_code.png");

      if (imageFile != null) {
        await Share.shareXFiles([XFile(imageFile)], text: "QR 코드를 공유합니다.");
      } else {
        print("QR 코드 캡처 실패");
      }
    } catch (e) {
      print("QR 코드 공유 실패: $e");
    }
  }


  // QR 코드 저장 기능
  Future<void> _saveQRCode(BuildContext context) async {
    try {
      final directory = await getExternalStorageDirectory(); // ✅ 외부 저장소 경로로 변경
      final imagePath = '${directory!.path}/qr_code.png';
      //final directory = await getApplicationDocumentsDirectory();

      print("📂 QR 코드 저장 경로: $imagePath");
      await screenshotController.captureAndSave(directory.path, fileName: "qr_code.png");
      showCustomSnackBar(context, "QR 코드가 저장되었습니다.");
    } catch (e) {
      print("QR 코드 저장 실패: $e");
    }
  }
}

// 6자리 고유 번호 생성 함수
String generateUniqueCode() {
  Random random = Random();
  String newCode;

  do {
    Set<int> uniqueNumbers = {}; // 중복 방지
    while (uniqueNumbers.length < 6) {
      uniqueNumbers.add(random.nextInt(10)); // 0~9 랜덤 숫자 생성
    }
    newCode = uniqueNumbers.join(""); // 숫자를 하나의 문자열로 변환
  } while (usedCodes.contains(newCode)); // 기존에 생성된 코드와 중복되면 다시 생성

  usedCodes.add(newCode); // 새로운 코드 저장
  return newCode.split("").join("  "); // 숫자 사이 공백 추가
}

// 사용자 지정 스낵바
void showCustomSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Color(0xffA5A5A5),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      duration: Duration(seconds: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
