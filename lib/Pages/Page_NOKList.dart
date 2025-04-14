import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/GlobalMicButton.dart';
import '../widgets/GlobalEditButton.dart';
import '../widgets/GlobalGoBackButton.dart';
import '../Pages/Page_NokEdit.dart';
import '../Pages/User_SettingsProvider.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreen();
}

class _ListScreen extends State<ListScreen> {
  List<Map<String, dynamic>> guardians = [
    {'name': '어머니', 'phone': '010-1234-5678', 'highlight': true},
    {'name': '아버지', 'phone': '010-1234-1234'},
    {'name': '딸', 'phone': '010-5678-1234'},
    {'name': '아들', 'phone': '010-5678-5678'},
  ];

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
            top: 50,
            left: 0,
            right: 0,
            child: Center(
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
          // 부제목
          Positioned(
            top: 87,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '긴급 연락처 순서 설정',
                style: TextStyle(
                  fontSize: 15 + fontSizeOffset,
                  color: Color(0xff848484),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Expanded(
                    child: ReorderableListView.builder(
                      itemCount: guardians.length,
                      itemBuilder: (context, index) {
                        final guardian = guardians[index];
                        return ReorderableDragStartListener(
                          key: ValueKey(guardian),
                          index: index,
                          child: GestureDetector(
                            onTapDown: (_) {
                              Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 25,
                                    height: 25,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: guardian['highlight'] == true
                                          ? Color(0xFFF8CB38)
                                          : Color(0xFFD6D6D6),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      guardian['name'],
                                      style: TextStyle(
                                        fontSize: 22 + fontSizeOffset,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 140,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      guardian['phone'],
                                      style: TextStyle(
                                        fontSize: 16 + fontSizeOffset,
                                        color: Color(0xff4E4E4E),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 38),
                                  const Icon(Icons.drag_handle, size: 30),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = guardians.removeAt(oldIndex);
                          guardians.insert(newIndex, item);
                          for (int i = 0; i < guardians.length; i++) {
                            guardians[i]['highlight'] = i == 0;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          GlobalMicButton(
            onPressed: () {
              print("마이크 버튼 클릭");
              },
          ),
          GlobalEditButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PageNokEdit()),
              );
              },
          ),
        ],
      ),
    );
  }
}
