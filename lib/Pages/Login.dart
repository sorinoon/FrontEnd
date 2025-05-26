import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import '../Pages/User_Navigate.dart';
import '../Pages/User_Home.dart';
import '../Pages/User_Welcome.dart';
import '../Pages/NOK_Home.dart';
import '../Pages/NOK_SettingsProvider.dart';
import '../Pages/User_SettingsProvider.dart';
import '../Pages/LoginModeProvider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isToggled = false;
  late final WebViewController _webViewController;
  bool _isCodeHandled = false;
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (!_isCodeHandled && request.url.contains("code=")) {
              _isCodeHandled = true;
              final Uri uri = Uri.parse(request.url);
              final String? code = uri.queryParameters['code'];
              if (code != null) {
                _sendCodeToServer(code);
              }
              Navigator.of(context).pop();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _speakWelcome();
  }

  Future<void> _speakWelcome() async {
    await tts.setLanguage("ko-KR");
    await tts.setSpeechRate(0.5);
  }

  Future<void> _sendCodeToServer(String code) async {
    try {
      final response = await http.get(
        Uri.parse('http://223.194.130.247:8080/callback?code=$code'),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final responseData = json.decode(response.body);
        await Future.delayed(Duration(milliseconds: 100));

        final token = responseData['jwt'];
        if (token != null) {
          await prefs.setString('jwt_token', token);
        }
        if (responseData['email'] != null) {
          await prefs.setString('email', responseData['email']);
        }

        final loginMode = Provider.of<LoginModeProvider>(context, listen: false);
        if (loginMode.isProtectorMode) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NOKHomeScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WelcomeScreen()));
        }
      } else {
        print("로그인 실패: ${response.statusCode}");
      }
    } catch (error) {
      print("서버 요청 중 오류 발생: $error");
    }
  }

  void _signInWithKakao() {
    _isCodeHandled = false;
    final loginUrl = Uri.parse('http://10.0.2.2:8080/login/page?ts=${DateTime.now().millisecondsSinceEpoch}');

    final webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (!_isCodeHandled && request.url.contains("code=")) {
              _isCodeHandled = true;
              final Uri uri = Uri.parse(request.url);
              final String? code = uri.queryParameters['code'];
              if (code != null) {
                _sendCodeToServer(code);
              }
              Navigator.of(context).pop();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(loginUrl);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: SafeArea(child: WebViewWidget(controller: webViewController)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final protectorSettings = Provider.of<NOKSettingsProvider>(context);
    final userSettings = Provider.of<UserSettingsProvider>(context);
    final loginMode = Provider.of<LoginModeProvider>(context);

    double fontSizeOffset = loginMode.isProtectorMode
        ? protectorSettings.fontSizeOffset
        : userSettings.fontSizeOffset;

    void vibrate() {
      loginMode.isProtectorMode ? protectorSettings.vibrate() : userSettings.vibrate();
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/background_image.jpg', fit: BoxFit.cover),
          ),
          Positioned(
            top: 210 - fontSizeOffset * 4,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      image: DecorationImage(
                        image: AssetImage(
                          loginMode.isProtectorMode
                              ? 'assets/images/logo_g.png'
                              : 'assets/images/logo_y.png',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 3),
                  /*Text(
                    '소리눈',
                    style: TextStyle(
                      fontSize: 40 + fontSizeOffset,
                      fontWeight: FontWeight.bold,
                      color: loginMode.isProtectorMode ? Color(0xff80C5A4) : Color(0xffF8CB38),
                    ),
                  ),*/
                ],
              ),
            ),
          ),
          // 카카오 로그인 버튼
          Positioned(
            top: 550,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 308 + fontSizeOffset * 10,
                height: 57 + fontSizeOffset * 2,
                decoration: BoxDecoration(
                  color: Color(0xFFFFE726),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Color(0xffe2e2e2), width: 1),
                ),
                child: TextButton(
                  onPressed: () {
                    if (loginMode.isProtectorMode) {
                      final provider = Provider.of<NOKSettingsProvider>(context, listen: false);
                      provider.vibrate();
                      _signInWithKakao();
                    } else {
                      final provider = Provider.of<UserSettingsProvider>(context, listen: false);
                      provider.vibrate();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WelcomeScreen()),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/kakao_logo.jpg', width: 46, height: 37),
                      SizedBox(width: 2),
                      Text(
                        '카카오로 3초만에 시작하기',
                        style: TextStyle(
                          color: Color(0xff4D3033),
                          fontWeight: FontWeight.bold,
                          fontSize: 18 + fontSizeOffset/2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 테스트에서 로그인 하지 않으면 홈으로 들어갈 방법이 없어 임시로 둠.. 최종에서는 positioned 묶음 그대로 지우면 됨
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 307 + fontSizeOffset * 10,
                height: 57 + fontSizeOffset * 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: TextButton(
                  onPressed: () {
                    if (loginMode.isProtectorMode) {
                      final provider = Provider.of<NOKSettingsProvider>(context, listen: false);
                      provider.vibrate();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NOKHomeScreen()),
                      );
                    } else {
                      final provider = Provider.of<UserSettingsProvider>(context, listen: false);
                      provider.vibrate();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserHomeScreen()),
                      );
                    }
                  },
                  child: Text(
                    '홈화면 이동 테스트용',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18 + fontSizeOffset,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 630,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoSwitch(
                    value: loginMode.isProtectorMode,
                    onChanged: (bool value) {
                      loginMode.toggleMode(value);
                      vibrate();
                    },
                    activeTrackColor: Color(0xff80C5A4),
                    inactiveTrackColor: Color(0xffF8CB38),
                    thumbColor: CupertinoColors.white,
                  ),
                  SizedBox(width: 5),
                  Text(
                    loginMode.isProtectorMode ? '보호자로 로그인' : '사용자로 로그인',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18 + fontSizeOffset,
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