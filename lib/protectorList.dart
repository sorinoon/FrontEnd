import 'package:flutter/material.dart';
import 'package:sorinoon/protectorList_edit.dart';
import 'setting_user.dart';
import 'protectorList_edit.dart';

class ProtectorListScreen extends StatefulWidget {
  @override
  _ProtectorListScreenState createState() => _ProtectorListScreenState();
}

class _ProtectorListScreenState extends State<ProtectorListScreen> {
  // 저장된 보호자 이름 리스트
  final List<String> protectorNames = [
    '어머니',
    '아버지',
    '딸',
    '아들',
  ];

  // 저장된 보호자의 연락처 리스트
  List<String> contactNotes = [
    '010-1234-5678',
    '010-1234-1234',
    '010-5678-1234',
    '010-5678-5678',
  ];

  // 현재 드래그 중인 항목의 인덱스를 추적
  int? draggingIndex;

  // 항목이 이동되었을 때 순서 변경
  void onItemMoved(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final String movedName = protectorNames.removeAt(oldIndex);
      protectorNames.insert(newIndex, movedName);

      final String movedContact = contactNotes.removeAt(oldIndex);
      contactNotes.insert(newIndex, movedContact);
    });
  }

  // 가장 위에 있는 항목의 색상을 결정하는 메서드
  Color getCircleColor(int index) {
    if (index == 0) {
      return Color(0xFFF8CB38); // 제일 위 항목 색상
    } else {
      return Color(0xFFD6D6D6);
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

          // goBack 버튼
          Positioned(
            top: 40,
            left: 30,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserSettingScreen()),
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
                '보호자 목록',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
                  fontSize: 15,
                  color: Color(0xff848484),
                ),
              ),
            ),
          ),

          // 보호자 리스트
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 100),
                Expanded(
                  child: ListView.builder(
                    itemCount: protectorNames.length + 1, // 가장 아래로도 이동이 가능하도록 빈 DragTarget 설정
                    itemBuilder: (context, index) {
                      if (index == protectorNames.length) {
                        // 마지막 빈 DragTarget
                        return DragTarget<int>(
                          onAccept: (receivedIndex) {
                            onItemMoved(receivedIndex, protectorNames.length);
                          },
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              height: 60,
                              color: Colors.transparent,
                            );
                          },
                        );
                      }
                      return Column(
                        children: [
                          GestureDetector(
                            onPanUpdate: (details) {
                              if (draggingIndex == null) {
                                setState(() {
                                  draggingIndex = index;
                                });
                              }
                            },
                            onPanEnd: (_) {
                              if (draggingIndex != null) {
                                int newIndex = index; // 드래그 종료 시 새로운 위치 계산
                                onItemMoved(draggingIndex!, newIndex);
                                setState(() {
                                  draggingIndex = null; // 드래그 상태 초기화
                                });
                              }
                            },
                            child: Draggable<int>(
                              data: index,
                              axis: Axis.vertical,
                              childWhenDragging: Container(),
                              feedback: Material(
                                color: Colors.transparent,
                                child: buildListItem(index), // 동일한 항목 레이아웃 재사용 / 코드 중복 방지 위함
                              ),
                              onDragStarted: () {
                                // 드래그 시작 시 상태 처리
                                setState(() {
                                  draggingIndex = index;
                                });
                              },
                              onDragCompleted: () {
                                // 드래그 완료 시 상태 처리
                                setState(() {
                                  draggingIndex = null;
                                });
                              },
                              child: DragTarget<int>(
                                onAccept: (receivedIndex) {
                                  // 항목을 놓았을 때 순서 변경
                                  onItemMoved(receivedIndex, index);
                                },
                                builder: (context, candidateData, rejectedData) {
                                  return buildListItem(index);
                                },
                              ),
                            ),
                          ),
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
          Positioned(
            bottom: 30,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProtectorEditScreen()),
                );
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFFD6D6D6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 항목 레이아웃을 정의하는 공통 메서드
  Widget buildListItem(int index) {
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

          // 이름
          Container(
            width: 90,
            child: Text(
              protectorNames[index],
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          // 연락처
          Container(
            width: 150,
            alignment: Alignment.centerLeft,
            child: Text(
              contactNotes[index],
              style: TextStyle(fontSize: 16, color: Color(0xff4E4E4E)),
            ),
          ),
          SizedBox(width: 38),

          // 아이콘
          Icon(
            Icons.menu,
            size: 30,
          ),
        ],
      ),
    );
  }
}
