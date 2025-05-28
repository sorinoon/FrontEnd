import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/GlobalGoBackButton.dart';
import '../Pages/NOK_SettingsProvider.dart';
import 'NOK_Home.dart';
import '../Pages/NOK_UserLocation.dart'; // <-- CustomMapScreen 정의되어 있는 곳

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final List<String> userNames = ['이영주', '김규리', '전준혁'];
  //['이영주', '김규리', '전준혁'];
  List<String> userNotes = ['팀원 1', '팀원 2', '팀원 3'];

  @override
  Widget build(BuildContext context) {
    final protectorSettings = Provider.of<NOKSettingsProvider>(context);

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
            top: 45,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '사용자 목록',
                style: TextStyle(
                  fontSize: 25 + protectorSettings.fontSizeOffset,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
                    itemCount: userNames.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        padding: EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 프로필
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xffEDEDED),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 15),

                            // 이름 + 메모
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userNames[index],
                                    style: TextStyle(
                                      fontSize: 22 + protectorSettings.fontSizeOffset,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      Provider.of<NOKSettingsProvider>(context, listen: false).vibrate();
                                      String? updatedNote = await showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          TextEditingController controller =
                                          TextEditingController(text: userNotes[index]);

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
                                                  Provider.of<NOKSettingsProvider>(context, listen: false).vibrate();
                                                },
                                                child: Text(
                                                  '취소',
                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, controller.text);
                                                  Provider.of<NOKSettingsProvider>(context, listen: false).vibrate();
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
                                        setState(() {
                                          userNotes[index] = updatedNote;
                                        });
                                      }
                                    },
                                    child: Text(
                                      userNotes[index],
                                      style: TextStyle(
                                        fontSize: 14 + protectorSettings.fontSizeOffset,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.visible,
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),

                            // 위치 보기 버튼
                            Container(
                              width: 95 + protectorSettings.fontSizeOffset * 4,
                              height: 40 + protectorSettings.fontSizeOffset * 2,
                              decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Color(0xff959595),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    Provider.of<NOKSettingsProvider>(context, listen: false).vibrate();

                                    // 사용자별 지도/역 정보 설정
                                    String mapPath;
                                    String nearestStation;

                                    switch (userNames[index]) {
                                      case '전준혁':
                                        mapPath = 'assets/images/map1.png';
                                        nearestStation = '태평역';
                                        break;
                                      case '김규리':
                                        mapPath = 'assets/images/map3.png';
                                        nearestStation = '길음역';
                                        break;
                                      case '이영주':
                                        mapPath = 'assets/images/map2.png';
                                        nearestStation = '창신역';
                                        break;
                                      default:
                                        mapPath = 'assets/images/map1.png';
                                        nearestStation = '미상';
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CustomMapScreen(
                                          userName: userNames[index],
                                          mapImage: mapPath,
                                          nearestStation: nearestStation,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    '위치 보기',
                                    style: TextStyle(
                                      fontSize: 14 + protectorSettings.fontSizeOffset,
                                      color: Colors.black,
                                    ),
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
