import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/GlobalMicButton.dart';
import '../widgets/GlobalGoBackButton.dart';
import '../Pages/User_NOKList.dart';
import '../Pages/User_SettingsProvider.dart';

class ProtectorEditScreen extends StatefulWidget {
  const ProtectorEditScreen({super.key});

  @override
  _ProtectorEditScreenState createState() => _ProtectorEditScreenState();
}

class _ProtectorEditScreenState extends State<ProtectorEditScreen> {
  final List<String> protectorNames = [
    '어머니',
    '아버지',
    '딸',
    '아들',
  ];

  List<String> contactNotes = [
    '010-1234-5678',
    '010-1234-1234',
    '010-5678-1234',
    '010-5678-5678',
  ];

  void deleteItem(int index) {
    setState(() {
      protectorNames.removeAt(index);
      contactNotes.removeAt(index);
    });
  }

  Color getCircleColor(int index) {
    if (index == 0) {
      return Color(0xFFF8CB38);
    } else {
      return Color(0xFFD6D6D6);
    }
  }

  late FlutterTts _flutterTts; // TTS 객체 선언

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
  }

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop(); // 앱 종료 시 TTS 멈추기
  }

  // TTS로 텍스트 읽기
  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeOffset = Provider.of<UserSettingsProvider>(context).fontSizeOffset;

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

          // 제목
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _speak("보호자 목록 : 연락처 삭제");
                },
                child: Text(
                  '보호자 목록',
                  style: TextStyle(
                    fontSize: 25 + fontSizeOffset,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          // 부제목
          Positioned(
            top: 77,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '연락처 삭제',
                style: TextStyle(
                  fontSize: 15 + fontSizeOffset,
                  color: Color(0xff848484),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 100),
                Expanded(
                  child: ListView.builder(
                    itemCount: protectorNames.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          buildListItem(index),
                          Divider(
                            color: Color(0xff6B6B6B),
                            thickness: 1,
                            indent: 15,
                            endIndent: 15,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          GlobalMicButton(
            onPressed: () {
              // 마이크 버튼 눌렀을 때 동작 정의
              print('마이크 버튼 클릭');
            },
          ),
          Positioned(
            bottom: 48,
            right: 43,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProtectorListScreen()),
                );
                Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
              },
              child: Container(
                width: 69,
                height: 69,
                decoration: BoxDecoration(
                  color: Color(0xFFFFE48A),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.black,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListItem(int index) {
    final fontSizeOffset = Provider.of<UserSettingsProvider>(context).fontSizeOffset;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: getCircleColor(index),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 15),
          SizedBox(
            width: 100,
            child: Text(
              protectorNames[index],
              style: TextStyle(fontSize: 22 + fontSizeOffset, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: 140,
            alignment: Alignment.centerLeft,
            child: Text(
              contactNotes[index],
              style: TextStyle(fontSize: 16 + fontSizeOffset, color: Color(0xff4E4E4E)),
            ),
          ),
          SizedBox(width: 38),
          GestureDetector(
            onTap: () {
              Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
              deleteItem(index);
            },
            child: Icon(
              Icons.delete,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
