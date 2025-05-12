import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/GlobalGoBackButton.dart';
import '../widgets/GlobalMicButton.dart';
import '../Pages/Page_NOKList.dart';
import '../Pages/User_SettingsProvider.dart';

class PageNokEdit extends StatefulWidget {
  const PageNokEdit({super.key});

  @override
  _PageNOKEditState createState() => _PageNOKEditState();
}

class _PageNOKEditState extends State<PageNokEdit> {
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
                '연락처 삭제',
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
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: guardians.length,
                      itemBuilder: (context, index) {
                        final guardian = guardians[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                              const SizedBox(width: 22),
                              // Delete icon
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  size: 30,
                                ),
                                onPressed: () {
                                  setState(() {
                                    guardians.removeAt(index); // Remove the item from the list
                                  });
                                },
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          GlobalMicButton(
            onPressed: () {
              print("마이크 버튼 클릭");
              },
          ),
          Positioned(
            bottom: 48,
            right: 43,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListScreen()),
                );},
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
}
