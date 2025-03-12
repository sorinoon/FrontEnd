import 'package:flutter/material.dart';
import 'setting_user.dart';

class RegisterScreen extends StatelessWidget {
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
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '보호자 등록',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}