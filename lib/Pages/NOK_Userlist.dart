import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/GlobalGoBackButton.dart';
import '../Pages/NOK_SettingsProvider.dart';
import '../Pages/NOK_UserLocation.dart'; // CustomMapScreen 정의된 파일
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final List<String> userNames = ['이영주', '김규리', '전준혁', '백강두'];

  final List<String> connectionStatus = [
    '연결됨',
    '연결 상태 나쁨',
    '연결 끊어짐',
    '연결 안됨',
  ];

  final List<Color> signalColors = [
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.grey,
  ];

  final List<LatLng> userLocations = [
    LatLng(37.582942, 127.010356), // 이영주
    LatLng(37.602680, 127.021767), // 김규리
    LatLng(37.489, 127.010), // 전준혁 (예시)
    LatLng(37.561, 126.998), // 백강두 (예시)
  ];

  @override
  Widget build(BuildContext context) {
    final protectorSettings = Provider.of<NOKSettingsProvider>(context);
    final userNotes = protectorSettings.userNotes;

    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
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
                            // 프로필 원
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xffEDEDED),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 15),

                            // 이름, 상태, 메모
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
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.signal_cellular_alt,
                                        size: 16,
                                        color: signalColors[index],
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        connectionStatus[index],
                                        style: TextStyle(
                                          fontSize: 14 + protectorSettings.fontSizeOffset,
                                          color: signalColors[index],
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      protectorSettings.vibrate();
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
                                                  protectorSettings.vibrate();
                                                },
                                                child: Text(
                                                  '취소',
                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, controller.text);
                                                  protectorSettings.vibrate();
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
                                        protectorSettings.updateNoteAt(index, updatedNote);
                                      }
                                    },
                                    child: Text(
                                      userNotes[index],
                                      style: TextStyle(
                                        fontSize: 13 + protectorSettings.fontSizeOffset,
                                        color: Colors.black,
                                      ),
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
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: signalColors[index],
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () {
                                    protectorSettings.vibrate();

                                    // 연결 상태 안 좋으면 팝업만 띄움
                                    if (connectionStatus[index] == '연결 끊어짐' || connectionStatus[index] == '연결 안됨') {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: Color(0xffF7F7F7),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            title: Text(
                                              '알림',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            content: Text(
                                              '연결이 끊겼습니다.',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: Text(
                                                  '확인',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      return;
                                    }

                                    // 사용자별 지도/역 설정
                                    String mapPath;
                                    String nearestStation;

                                    switch (userNames[index]) {
                                      case '전준혁':
                                        mapPath = 'assets/images/map1.png';
                                        nearestStation = '태평역';
                                        break;
                                      case '이영주':
                                        mapPath = 'assets/images/map2.png';
                                        nearestStation = '창신역';
                                        break;
                                      case '김규리':
                                        mapPath = 'assets/images/map3.png';
                                        nearestStation = '길음역';
                                        break;
                                      case '백강두':
                                        mapPath = 'assets/images/map2.png';
                                        nearestStation = '미상';
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
                                          location: userLocations[index],
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
