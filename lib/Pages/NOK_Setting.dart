import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Pages/Shared_Preferences.dart' as MyPrefs;

import 'dart:convert';

import '../widgets/GlobalGoBackButton.dart';
import '../Pages/NOK_SettingsProvider.dart';
import '../Pages/Login.dart';
import '../Pages/Shared_Preferences.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NOKSettingScreen extends StatefulWidget {
  const NOKSettingScreen({super.key});

  @override
  _NOKSettingScreen createState() => _NOKSettingScreen();
}

class _NOKSettingScreen extends State<NOKSettingScreen> {
  String _userEmail = '로딩 중...';

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  Future<void> _fetchUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      print('📦 SharedPreferences에서 꺼낸 토큰: $token');

      if (token == null) {
        setState(() {
          _userEmail = '토큰 없음';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/user/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('📨 /user/me 응답: ${response.body}');
        final data = json.decode(response.body);
        setState(() {
          _userEmail = data['email'] ?? '이메일 없음';
        });
        print('✅ 이메일 불러오기 성공: $_userEmail');
      } else {
        setState(() {
          _userEmail = '이메일 불러오기 실패';
        });
      }
    } catch (e) {
      print('❌ 이메일 불러오기 예외: $e');
      setState(() {
        _userEmail = '이메일 불러오기 실패';
      });
    }
  }
  Future<void> _logoutKakao() async {
    try {
      await UserApi.instance.logout();
      print('✅ 카카오 로그아웃 성공');
    } catch (e) {
      print('⚠️ 카카오 로그아웃 실패 (무시해도 됨): $e');
    }
  }

  Future<void> _logoutAndRedirectToLogin() async {
    await _logoutKakao(); // 실패해도 괜찮음
    await WebViewCookieManager().clearCookies(); // ✅ WebView 쿠키 초기화
    await MyPrefs.TokenManager.deleteToken(); // ✅ JWT 삭제

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }


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
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '설정',
                style: TextStyle(
                  fontSize: 25 + protectorSettings.fontSizeOffset,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("카카오계정", style: TextStyle(fontSize: 20 + protectorSettings.fontSizeOffset)),
                      Expanded(
                        child: Text(
                          _userEmail,
                          style: TextStyle(
                            fontSize: 14 + protectorSettings.fontSizeOffset,
                            color: const Color(0xff8F8996),
                          ),
                          overflow: TextOverflow.visible,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 40, color: Color(0xff5B5B5B)),
                  _buildSwitchTile(
                    '진동 모드',
                    '버튼 터치 시 진동 피드백을 제공합니다.',
                    protectorSettings.isVibrationEnabled,
                        (value) {
                      protectorSettings.toggleVibration(value);
                      protectorSettings.vibrate();
                    },
                  ),
                  _buildSwitchTile(
                    '글자 크기 키우기',
                    '저시력 사용자를 위해\n글자 크기를 최대로 키웁니다.',
                    protectorSettings.isFontSizeIncreased,
                        (value) {
                      protectorSettings.toggleFontSize(value);
                      protectorSettings.vibrate();
                    },
                  ),
                  const Divider(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _logoutAndRedirectToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        '로그아웃',
                        style: TextStyle(fontSize: 16 + protectorSettings.fontSizeOffset),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool initialValue, ValueChanged<bool> onChanged) {
    final protectorSettings = Provider.of<NOKSettingsProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 20 + protectorSettings.fontSizeOffset)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14 + protectorSettings.fontSizeOffset, color: const Color(0xff8F8996))),
                ],
              ),
            ),
            CupertinoSwitch(
              value: initialValue,
              onChanged: onChanged,
              activeTrackColor: const Color(0xff80C5A4),
              inactiveTrackColor: const Color(0xffE7E7E8),
              thumbColor: CupertinoColors.white,
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
