import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../widgets/GlobalMicButton.dart';
import '../widgets/GlobalEditButton.dart';
import '../widgets/GlobalGoBackButton.dart';
import '../Pages/User_NOKEdit.dart';
import '../Pages/User_SettingsProvider.dart';
import '../Pages/ProtectorListProvider.dart';
import '../Pages/User_setting.dart';

class ProtectorListScreen extends StatefulWidget {
  const ProtectorListScreen({super.key});

  @override
  State<ProtectorListScreen> createState() => _ProtectorListScreenState();
}

class _ProtectorListScreenState extends State<ProtectorListScreen> {
  int? draggingIndex;
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
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
          GlobalGoBackButton(targetPage: UserSettingScreen()),

          // 제목
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _speak("보호자 목록 : 긴급 연락처 순서 설정"),
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
                '긴급 연락처 순서 설정',
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
                    itemCount: protectorNames.length + 1,
                    itemBuilder: (context, index) {
                      if (index == protectorNames.length) {
                        return DragTarget<int>(
                          onAcceptWithDetails: (details) {
                            protectorProvider.moveItem(details.data, protectorNames.length);
                          },
                          builder: (context, _, __) => const SizedBox(height: 60),
                        );
                      }

                      return Column(
                        children: [
                          GestureDetector(
                            onPanUpdate: (_) {
                              draggingIndex ??= index;
                            },
                            onPanEnd: (_) {
                              if (draggingIndex != null) {
                                protectorProvider.moveItem(draggingIndex!, index);
                                draggingIndex = null;
                              }
                            },
                            child: Draggable<int>(
                              data: index,
                              axis: Axis.vertical,
                              childWhenDragging: const SizedBox.shrink(),
                              feedback: Material(
                                color: Colors.transparent,
                                child: buildListItem(index, protectorNames, contactNotes, fontSizeOffset),
                              ),
                              onDragStarted: () {
                                Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                                draggingIndex = index;
                              },
                              onDragCompleted: () => draggingIndex = null,
                              child: DragTarget<int>(
                                onAcceptWithDetails: (details) {
                                  protectorProvider.moveItem(details.data, index);
                                },
                                builder: (context, _, __) {
                                  return buildListItem(index, protectorNames, contactNotes, fontSizeOffset);
                                },
                              ),
                            ),
                          ),
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

          GlobalMicButton(
            onPressed: () => print('마이크 버튼 클릭'),
          ),

          GlobalEditButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProtectorEditScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildListItem(int index, List<String> names, List<String> contacts, double fontSizeOffset) {
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

          // 이름
          SizedBox(
            width: 100,
            child: Text(
              names[index],
              style: TextStyle(fontSize: 22 + fontSizeOffset, fontWeight: FontWeight.bold),
            ),
          ),

          // 연락처
          Container(
            width: 140,
            alignment: Alignment.centerLeft,
            child: Text(
              contacts[index],
              style: TextStyle(fontSize: 16 + fontSizeOffset, color: const Color(0xff4E4E4E)),
            ),
          ),
          const SizedBox(width: 38),

          const Icon(Icons.menu, size: 30),
        ],
      ),
    );
  }
}
