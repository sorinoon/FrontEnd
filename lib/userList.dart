import 'package:flutter/material.dart';
import 'home_protector.dart'; // HomeScreen 임포트
import 'location.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  // 미리 저장된 사용자 이름 리스트
  final List<String> userNames = [
    '홍길동',
    '김철수',
    '이영희',
    '박민수',
  ];

  // 각 사용자의 메모 리스트 (초기값 - 기본 텍스트)
  List<String> userNotes = [
    '사용자 특징 및 메모',
    '사용자 특징 및 메모',
    '사용자 특징 및 메모',
    '사용자 특징 및 메모',
  ];

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
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),

          // 제목
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '사용자 목록',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // 사용자 리스트
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 100),
                Expanded(
                  child: ListView.builder(
                    itemCount: userNames.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xffEDEDED),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userNames[index], // 미리 저장된 이름
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    // 텍스트 입력 다이얼로그
                                    String? updatedNote = await showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        TextEditingController controller = TextEditingController(text: userNotes[index]);

                                        return AlertDialog(
                                          backgroundColor: Color(0xffF7F7F7),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          title: Text('사용자 특징 또는 메모'),
                                          content: TextField(
                                            controller: controller,
                                            decoration: InputDecoration(
                                              hintText: '메모를 입력하세요.',
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                '취소',
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, controller.text); // 텍스트 입력 후 반환
                                              },
                                              child: Text(
                                                '확인',
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (updatedNote != null && updatedNote.isNotEmpty) {
                                      // 수정된 메모를 저장하면
                                      setState(() {
                                        userNotes[index] = updatedNote; // 해당 인덱스에 메모를 업데이트
                                      });
                                    }
                                  },
                                  child: Text(
                                    userNotes[index], // 수정된 메모 또는 기본 텍스트
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Container(
                              width: 87,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Color(0xff959595),
                                  width: 1.5,
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => LocationScreen()),
                                  );
                                },
                                child: Text(
                                  '위치 보기',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
