import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Pages/ProtectorSettingsProvider.dart';
import '../Pages/login_protector.dart';
import 'userList.dart';
import 'setting_protector.dart';
import 'setting_user.dart';
import '../Pages/qr.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final protectorSettings = Provider.of<ProtectorSettingsProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 40,
            left: 30,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
                Provider.of<ProtectorSettingsProvider>(context, listen: false).vibrate();
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),

          // 상단 버튼
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserListScreen()),
                  );
                  Provider.of<ProtectorSettingsProvider>(context, listen: false).vibrate();
                  print("사용자 목록 버튼");
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 170 + protectorSettings.fontSizeOffset * 4,
                      height: 170 + protectorSettings.fontSizeOffset * 4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(0xff80C5A4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // 아이콘과 텍스트가 세로로 정렬되도록
                          crossAxisAlignment: CrossAxisAlignment.center, // 중앙 정렬
                          children: [
                            Container(
                              width: 90 + protectorSettings.fontSizeOffset * 2,
                              height: 90 + protectorSettings.fontSizeOffset * 2,
                              decoration: BoxDecoration(
                                color: Color(0xff80C5A4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.format_list_bulleted,
                                color: Colors.white,
                                size: 55 + protectorSettings.fontSizeOffset / 2,
                              ),
                            ),
                            SizedBox(height: 7),
                            Text(
                              '사용자 목록',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25 + protectorSettings.fontSizeOffset,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 중간 버튼
          Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 170 + protectorSettings.fontSizeOffset * 4,
                    height: 170 + protectorSettings.fontSizeOffset * 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(0xff80C5A4),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => QRScreen()),
                          );
                          Provider.of<ProtectorSettingsProvider>(context, listen: false).vibrate();
                          print("QR 버튼");
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // 아이콘과 텍스트가 세로로 정렬되도록
                          crossAxisAlignment: CrossAxisAlignment.center, // 중앙 정렬
                          children: [
                            Container(
                              width: 90 + protectorSettings.fontSizeOffset * 2,
                              height: 90 + protectorSettings.fontSizeOffset * 2,
                              decoration: BoxDecoration(
                                color: Color(0xff80C5A4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.qr_code_2,
                                color: Colors.white,
                                size: 55 + protectorSettings.fontSizeOffset / 2,
                              ),
                            ),
                            SizedBox(height: 7),
                            Text(
                              'QR 보기',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25 + protectorSettings.fontSizeOffset,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 하단 버튼
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 170 + protectorSettings.fontSizeOffset * 4,
                    height: 170 + protectorSettings.fontSizeOffset * 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(0xff80C5A4),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,


                            //
                            MaterialPageRoute(builder: (context) => //UserSettingScreen()
                            ProtectorSettingScreen()),  //User Protector



                          );
                          Provider.of<ProtectorSettingsProvider>(context, listen: false).vibrate();
                          print("설정 버튼");
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // 아이콘과 텍스트가 세로로 정렬되도록
                          crossAxisAlignment: CrossAxisAlignment.center, // 중앙 정렬
                          children: [
                            Container(
                              width: 90 + protectorSettings.fontSizeOffset * 2,
                              height: 90 + protectorSettings.fontSizeOffset * 2,
                              decoration: BoxDecoration(
                                color: Color(0xff80C5A4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.settings,
                                color: Colors.white,
                                size: 55 + protectorSettings.fontSizeOffset / 2,
                              ),
                            ),
                            SizedBox(height: 7),
                            Text(
                              '설정',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25 + protectorSettings.fontSizeOffset,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
