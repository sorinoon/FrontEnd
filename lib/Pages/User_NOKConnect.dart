import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'User_Home.dart';
import 'CAM_QR.dart';
import '../widgets/GlobalMicButton.dart';
import '../widgets/GlobalGoBackButton.dart';

class NOKConnectScreen extends StatefulWidget {
  const NOKConnectScreen({super.key});

  @override
  _NOKConnectScreenState createState() => _NOKConnectScreenState();
}

class _NOKConnectScreenState extends State<NOKConnectScreen> {
  final FlutterTts flutterTts = FlutterTts();

  final String password = "235478";
  String enteredPin = "";

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ko-KR");
    flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _onKeyPressed(String value) {
    if (enteredPin.length < 6) {
      setState(() {
        enteredPin += value;
      });
      _speak(value);
    }
    if (enteredPin.length == 6) {
      _validatePin();
    }
  }

  void _validatePin() {
    if (enteredPin == password) {
      _speak("보호자가 성공적으로 등록되었습니다");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserHomeScreen()),
      );
    } else {
      setState(() {
        enteredPin = "";
      });

      _speak("찾을 수 없는 고유번호입니다.");

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
                            fontSize: 15,
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
      _speak("지우기");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image.jpg',
              fit: BoxFit.cover,
            ),
          ),

          const GlobalGoBackButton(),

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
                  for (var i = 1; i <= 9; i++)
                    _buildKeyButton(
                      Text(
                        i.toString(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  _buildKeyButton(
                    Image.asset('assets/images/camera.png', width: 30),
                    onPressed: () {
                      _speak("카메라로 등록");
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CAMQRScreen()),
                      );
                    },
                  ),
                  _buildKeyButton(
                    const Text(
                      "0",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  _buildKeyButton(
                    const Text(
                      "⌫",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    onPressed: _onDelete,
                  ),
                ],
              ),
            ],
          ),

          GlobalMicButton(
            onPressed: () {
              print("마이크 버튼 눌림 - NokRegistrationPage");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKeyButton(Widget child, {VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed ??
              () {
            if (child is Text) {
              _onKeyPressed(child.data!);
            }
          },
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFC300), width: 1.5),
        ),
        child: Center(child: child),
      ),
    );
  }
}
