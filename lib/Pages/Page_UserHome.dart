import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/GlobalMicButton.dart';
import '../widgets/GlobalGoBackButton.dart';
import '../Pages/Page_CameraAnalyze.dart';
import '../Pages/Page_Navigate.dart';
import '../Pages/Page_Setting.dart';
import '../Pages/UserSettingsProvider.dart';

class U_HomePage extends StatelessWidget {
  const U_HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserSettings = Provider.of<UserSettingsProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image.jpg',
              fit: BoxFit.cover,
            ),
          ),
          GlobalGoBackButton(

          ),

          // 버튼들 정렬 - 중앙 기준으로 자연스럽게
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: 100 - UserSettings.fontSizeOffset * 4), // 상단 여백

              _buildMenuButton(
                icon: Icons.receipt_long,
                label: '인식 모드',
                onPressed: () {
                  // TODO: 인식 모드 페이지
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Page_CameraAnalyze()),
                    );
                    Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                },
                userSettings: UserSettings,
              ),
              SizedBox(height: 70- UserSettings.fontSizeOffset * 4),
              _buildMenuButton(
                icon: Icons.settings,
                label: '설정',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageSetting()),
                  );
                  Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                },
                userSettings: UserSettings,
              ),
              SizedBox(height: 70- UserSettings.fontSizeOffset * 4),
              _buildMenuButton(
                icon: Icons.navigation,
                label: '안내 모드',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageNavigate()),
                  );
                  Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                },
                userSettings: UserSettings,
              ),

              const SizedBox(height: 80), // 하단 마이크 여백
            ],
          ),

          // 글로벌 마이크 버튼
          GlobalMicButton(
            onPressed: () {
              print("마이크 클릭됨");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required UserSettingsProvider userSettings,
  }) {
    return Center(
      child: GestureDetector(
        onTap: () {
          userSettings.vibrate();
          onPressed();
        },
        child: Container(
          width: 170 + userSettings.fontSizeOffset * 4,
          height: 170 + userSettings.fontSizeOffset * 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(0xffF8CB38),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90 + userSettings.fontSizeOffset * 2,
                height: 90 + userSettings.fontSizeOffset * 2,
                decoration: const BoxDecoration(
                  color: Color(0xffF8CB38),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 55 + userSettings.fontSizeOffset / 2,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25 + userSettings.fontSizeOffset * 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
