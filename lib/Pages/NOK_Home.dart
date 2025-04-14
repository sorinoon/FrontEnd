import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/GlobalGoBackButton.dart';
import 'NOK_SettingsProvider.dart';
import 'Login.dart';
import 'NOK_Userlist.dart';
import 'NOK_Setting.dart';
import 'NOK_QR.dart';
import 'setting_user.dart';

class NOKHomeScreen extends StatelessWidget {
  const NOKHomeScreen({super.key});

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

          // 버튼들 정렬 - 중앙 기준으로 자연스럽게
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: 100 - protectorSettings.fontSizeOffset * 4), // 상단 여백

              _buildMenuButton(
                icon: Icons.format_list_bulleted,
                label: '사용자 목록',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserListScreen()),
                  );
                  Provider.of<NOKSettingsProvider>(context, listen: false).vibrate();
                },
                protectorSettings: protectorSettings,
              ),
              SizedBox(height: 70- protectorSettings.fontSizeOffset * 4),
              _buildMenuButton(
                icon: Icons.qr_code_2,
                label: 'QR 버튼',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRScreen()),
                  );
                  Provider.of<NOKSettingsProvider>(context, listen: false).vibrate();
                },
                protectorSettings: protectorSettings,
              ),
              SizedBox(height: 70- protectorSettings.fontSizeOffset * 4),
              _buildMenuButton(
                icon: Icons.settings,
                label: '설정',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NOKSettingScreen()),
                  );
                  Provider.of<NOKSettingsProvider>(context, listen: false).vibrate();
                },
                protectorSettings: protectorSettings,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required NOKSettingsProvider protectorSettings,
  }) {
    return Center(
      child: GestureDetector(
        onTap: () {
          protectorSettings.vibrate();
          onPressed();
        },
        child: Container(
          width: 170 + protectorSettings.fontSizeOffset * 4,
          height: 170 + protectorSettings.fontSizeOffset * 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(0xff80C5A4),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90 + protectorSettings.fontSizeOffset * 2,
                height: 90 + protectorSettings.fontSizeOffset * 2,
                decoration: const BoxDecoration(
                  color: Color(0xff80C5A4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 55 + protectorSettings.fontSizeOffset / 2,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25 + protectorSettings.fontSizeOffset * 1.5,
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