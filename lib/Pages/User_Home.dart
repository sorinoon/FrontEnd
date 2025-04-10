import 'package:flutter/material.dart';
import 'package:sorinoon/Pages/CAM_Analyze.dart';
import 'package:sorinoon/Pages/CAM_QR.dart';
import 'package:sorinoon/Pages/User_Navigate.dart';
import '../Pages/User_Setting.dart';
import '../widgets/GlobalMicButton.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

          // 버튼들 정렬 - 중앙 기준으로 자연스럽게
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(height: 110), // 상단 여백

              _buildMenuButton(
                icon: Icons.receipt_long,
                label: '인식 모드',
                onPressed: () {
                  // TODO: 인식 모드 페이지
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CameraAnalyzeScreen()),
                    );
                },
              ),
              const SizedBox(height: 80),
              _buildMenuButton(
                icon: Icons.settings,
                label: '설정',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserSettingScreen()),
                  );
                },
              ),
              const SizedBox(height: 80),
              _buildMenuButton(
                icon: Icons.navigation,
                label: '안내 모드',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageNavigate()),
                  );
                },
              ),

              const SizedBox(height: 120), // 하단 마이크 여백
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
  }) {
    return Center(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 170,
          height: 170,
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
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xffF8CB38),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 55,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25,
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
