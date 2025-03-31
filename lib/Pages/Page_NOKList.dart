import 'package:flutter/material.dart';
import '../widgets/GlobalMicButton.dart';
import '../Pages/Page_NokEdit.dart';
import '../widgets/GlobalEditButton.dart'; // 추가!

class PageNOKList extends StatefulWidget {
  const PageNOKList({super.key});

  @override
  State<PageNOKList> createState() => _PageNOKListState();
}

class _PageNOKListState extends State<PageNOKList> {
  List<Map<String, dynamic>> guardians = [
    {'name': '어머니', 'phone': '010-1234-5678', 'highlight': true},
    {'name': '아버지', 'phone': '010-1234-5678'},
    {'name': '딸', 'phone': '010-1234-5678'},
    {'name': '아들', 'phone': '010-1234-5678'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // 상단 바
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Text(
                        '보호자 목록',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '긴급 연락처 순서 설정',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // 보호자 리스트 (드래그 가능)
                  Expanded(
                    child: ReorderableListView.builder(
                      itemCount: guardians.length,
                      itemBuilder: (context, index) {
                        final guardian = guardians[index];
                        return ReorderableDragStartListener(
                          key: ValueKey(guardian),
                          index: index,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // 순위 동그라미
                                Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: guardian['highlight'] == true
                                        ? Colors.yellow
                                        : Colors.grey,
                                  ),
                                ),
                                // 이름 및 전화번호
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        guardian['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        guardian['phone'],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.drag_handle),
                              ],
                            ),
                          ),
                        );
                      },
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = guardians.removeAt(oldIndex);
                          guardians.insert(newIndex, item);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // GlobalMicButton
          GlobalMicButton(
            onPressed: () {
              print("마이크 버튼 클릭");
            },
          ),

// GlobalEditButton
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
