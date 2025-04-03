import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/GlobalMicButton.dart';
import '../widgets/GlobalGoBackButton.dart';
import '../Pages/Page_UserHome.dart';
import '../Pages/Page_CameraQR.dart';

class PageNokregistration extends StatefulWidget {
  const PageNokregistration({super.key});

  @override
  _PageNokRegistrationState createState() => _PageNokRegistrationState();
}

class _PageNokRegistrationState extends State<PageNokregistration> {
  final String password = "123456"; // 비교할 고유번호 설정
  String enteredPin = "";

  void _onKeyPressed(String value) {
    if (enteredPin.length < 6) {
      setState(() {
        enteredPin += value;
      });
    }
    if (enteredPin.length == 6) {
      _validatePin();
    }
  }

  void _validatePin() {
    if (enteredPin == password) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => U_HomePage()),
      );
    } else {
      setState(() {
        enteredPin = ""; // 실패 시 초기화
      });

      // 🍎 iOS 스타일 팝업 (화면 터치 시 닫힘)
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.3),
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation1, animation2) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Material(
              type: MaterialType.transparency,
              child: Center(
                child: CupertinoPopupSurface(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    width: 260,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "찾을 수 없는 고유번호입니다.",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          "(화면을 터치해 닫기)",
                          style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.systemGrey,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  void _onDelete() {
    if (enteredPin.isNotEmpty) {
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image.jpg',
              fit: BoxFit.cover,
            ),
          ),

          GlobalGoBackButton(

          ),
          // 콘텐츠
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "보호자 등록",
                style: TextStyle(fontSize: 32, color: Colors.black, fontWeight: FontWeight.w500),
              ),
              const Text(
                "보호자 고유번호를 입력해주세요",
                style: TextStyle(fontSize: 15, color: Color(0xFF878787)),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    margin: const EdgeInsets.all(5),
                    width: 45,
                    height: 55,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        enteredPin.length > index ? enteredPin[index] : "",
                        style: const TextStyle(fontSize: 24, color: Colors.black),
                      ),
                    ),
                  );
                }),
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                padding: const EdgeInsets.all(40),
                children: [
                  for (var i = 1; i <= 9; i++) _buildKeyButton(i.toString()),
                  _buildKeyButton("C", onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CameraQR()),
                    );
                  }),
                  _buildKeyButton("0"),
                  _buildKeyButton("⌫", isDelete: true, onPressed: _onDelete),
                ],
              ),
            ],
          ),
          // ✅ 좌하단 마이크 버튼
          GlobalMicButton(
            onPressed: () {
              print("마이크 버튼 눌림 - NokRegistrationPage");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKeyButton(String label, {bool isDelete = false, VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed ?? () => _onKeyPressed(label),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFC300), width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
