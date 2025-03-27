import 'package:flutter/material.dart';
import 'package:sorinoon/protectorList.dart';
import 'package:provider/provider.dart';
import 'UserSettingsProvider.dart';

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

          // go back 버튼
          Positioned(
            top: 40,
            left: 30,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProtectorListScreen()),
                );
                Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
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
                  fontSize: 25 + fontSizeOffset,
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
          Positioned(
            bottom: 30,
            left: 20,
            child: ElevatedButton(
              onPressed: () {
                // 음성인식 기능
                Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(12),
                backgroundColor: Color(0xFFF8CB38),
              ),
              child: Icon(
                Icons.settings_voice,
                color: Colors.black,
                size: 38,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProtectorListScreen()),
                );
                Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFFFFE48A),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
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
