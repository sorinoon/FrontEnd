import 'package:flutter/material.dart';
import 'dart:math';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NOK_SettingsProvider.dart';
import '../widgets/GlobalGoBackButton.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  String uniqueCode = "로딩 중...";
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadOrGenerateUniqueCode();
  }

  // ✅ 고유 코드 불러오기 or 생성
  Future<void> _loadOrGenerateUniqueCode() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    print("📦 SharedPreferences에서 꺼낸 email: $email");

    if (email == null) {
      setState(() {
        uniqueCode = "UNKNOWN";
      });
      return;
    }

    final codeKey = 'qr_code_for_$email';
    String? code = prefs.getString(codeKey);

    if (code == null) {
      code = _generate6DigitCode();
      await prefs.setString(codeKey, code);
    }

    setState(() {
      uniqueCode = code!;
    });
  }

  // ✅ 고유 6자리 숫자 생성 함수
  String _generate6DigitCode() {
    final random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  @override
  Widget build(BuildContext context) {
    final protectorSettings = Provider.of<NOKSettingsProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image.jpg',
              fit: BoxFit.cover,
            ),
          ),
          GlobalGoBackButton(),
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 325,
                height: 386,
                decoration: BoxDecoration(
                  color: const Color(0xffF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Screenshot(
                      controller: screenshotController,
                      child: Container(
                        color: const Color(0xffF0F0F0),
                        child: QrImageView(
                          data: uniqueCode,
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: const Color(0xffF0F0F0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      uniqueCode,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24 + protectorSettings.fontSizeOffset / 2,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 공유/복사/저장 버튼
          Positioned(
            bottom: 300,
            left: 105,
            right: 105,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: uniqueCode));
                    showCustomSnackBar(context, "고유 번호가 복사되었습니다.");
                    protectorSettings.vibrate();
                  },
                  child: Icon(
                    Icons.content_copy,
                    color: Colors.black,
                    size: 30 + protectorSettings.fontSizeOffset,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    protectorSettings.vibrate();
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
                    protectorSettings.vibrate();
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
              color: const Color(0xffA5A5A5),
            ),
          ),
          Positioned(
            bottom: 100 - protectorSettings.fontSizeOffset * 4,
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
                  color: const Color(0xffA5A5A5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Future<void> _saveQRCode(BuildContext context) async {
    try {
      final directory = await getExternalStorageDirectory();
      final imagePath = '${directory!.path}/qr_code.png';

      print("📂 QR 코드 저장 경로: $imagePath");
      await screenshotController.captureAndSave(directory.path, fileName: "qr_code.png");
      showCustomSnackBar(context, "QR 코드가 저장되었습니다.");
    } catch (e) {
      print("QR 코드 저장 실패: $e");
    }
  }
}

// ✅ 사용자 지정 스낵바
void showCustomSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      backgroundColor: const Color(0xffA5A5A5),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
