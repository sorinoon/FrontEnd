import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../widgets/GlobalMicButton.dart';
import '../widgets/GlobalGoBackButton.dart';
import '../Pages/User_SettingsProvider.dart';
import '../Pages/ProtectorListProvider.dart';
import '../Pages/User_NOKList.dart'; // ProtectorListScreen 정의된 곳

class ProtectorEditScreen extends StatefulWidget {
  const ProtectorEditScreen({super.key});

  @override
  _ProtectorEditScreenState createState() => _ProtectorEditScreenState();
}

class _ProtectorEditScreenState extends State<ProtectorEditScreen> {
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
  }

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Color getCircleColor(int index) {
    return index == 0 ? const Color(0xFFF8CB38) : const Color(0xFFD6D6D6);
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeOffset = Provider.of<UserSettingsProvider>(context).fontSizeOffset;
    final protectorProvider = Provider.of<ProtectorListProvider>(context);

    final protectorNames = protectorProvider.protectorNames;
    final contactNotes = protectorProvider.contactNotes;

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

          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _speak("보호자 목록 : 연락처 삭제"),
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
          Positioned(
            top: 77,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '연락처 삭제',
                style: TextStyle(
                  fontSize: 15 + fontSizeOffset,
                  color: const Color(0xff848484),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Expanded(
                  child: ListView.builder(
                    itemCount: protectorNames.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          buildListItem(context, index, protectorNames, contactNotes),
                          const Divider(
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
          GlobalMicButton(onPressed: () {
            print('마이크 버튼 클릭');
          }),
          Positioned(
            bottom: 48,
            right: 43,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProtectorListScreen()),
                );
                Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
              },
              child: Container(
                width: 69,
                height: 69,
                decoration: const BoxDecoration(
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
                child: const Icon(
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

  Widget buildListItem(BuildContext context, int index, List<String> protectorNames, List<String> contactNotes) {
    final fontSizeOffset = Provider.of<UserSettingsProvider>(context).fontSizeOffset;
    final provider = Provider.of<ProtectorListProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          const SizedBox(width: 15),
          SizedBox(
            width: 100,
            child: Text(
              protectorNames[index],
              style: TextStyle(fontSize: 22 + fontSizeOffset, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(
              contactNotes[index],
              style: TextStyle(fontSize: 16 + fontSizeOffset, color: const Color(0xff4E4E4E)),
            ),
          ),
          const SizedBox(width: 38),
          GestureDetector(
            onTap: () {
              Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
              provider.deleteProtector(index); // ✅ provider를 통해 삭제
            },
            child: const Icon(Icons.delete, size: 30),
          ),
        ],
      ),
    );
  }
}
