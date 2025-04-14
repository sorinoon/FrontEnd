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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isToggled = false;
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (url.contains("code=")) {
              final Uri uri = Uri.parse(url);
              final String? code = uri.queryParameters['code'];
              if (code != null) {
                _sendCodeToServer(code);
              }
            }
          },
        ),
      );
  }

  Future<void> _sendCodeToServer(String code) async {
    try {
      final response = await http.get(
        Uri.parse('http://<YOUR_SERVER_IP>:8080/callback?code=$code'),
      );

      if (response.statusCode == 200) {
        print("로그인 성공! 응답: ${response.body}");
        // 로그인 성공 후 화면 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NOKHomeScreen()),
        );
      } else {
        print("로그인 실패: ${response.statusCode}");
      }
    } catch (error) {
      print("서버 요청 중 오류 발생: $error");
    }
  }

  void _signInWithKakao() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text("카카오 로그인")),
          body: WebViewWidget(
            controller: _webViewController
              ..loadRequest(Uri.parse('http://<YOUR_SERVER_IP>:8080/login/page')),
          ),
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
      if (loginMode.isProtectorMode) {
        protectorSettings.vibrate();
      } else {
        userSettings.vibrate();
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/background_image.jpg', fit: BoxFit.cover),
          ),
          Positioned(
            top: 230 - fontSizeOffset * 4,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: loginMode.isProtectorMode ? Color(0xff80C5A4) : Color(0xffF8CB38), // 네모 박스 색상
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image, // 로고 대체
                        color: Colors.white,
                        size: 40 + fontSizeOffset,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '소리눈',
                    style: TextStyle(
                      fontSize: 40 + fontSizeOffset,
                      fontWeight: FontWeight.bold,
                      color: loginMode.isProtectorMode ? Color(0xff80C5A4) : Color(0xffF8CB38),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 450 - fontSizeOffset * 5), // 로고와 버튼 간격 조정
                Container(
                  width: 307 + fontSizeOffset * 10,
                  height: 57 + fontSizeOffset * 2,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFE726),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Color(0xffe2e2e2), width: 1),
                  ),
                  child: TextButton(
                    onPressed:() {
                      if (loginMode.isProtectorMode) {
                        final provider = Provider.of<NOKSettingsProvider>(context, listen: false);
                        provider.vibrate();
                        // 보호자용 페이지로 이동
                            _signInWithKakao();// 카카오 로그인 버튼 클릭 시 처리
                      } else {
                        final provider = Provider.of<UserSettingsProvider>(context, listen: false);
                        provider.vibrate();
                        // 사용자용 페이지로 이동
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
                            fontSize: 18 + fontSizeOffset,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 307 + fontSizeOffset * 10,
                  height: 57 + fontSizeOffset * 2,
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: TextButton(
                    onPressed: () {
                      if (loginMode.isProtectorMode) {
                        final provider = Provider.of<NOKSettingsProvider>(context, listen: false);
                        provider.vibrate();
                        // 보호자용 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NOKHomeScreen()),
                        );
                      } else {
                        final provider = Provider.of<UserSettingsProvider>(context, listen: false);
                        provider.vibrate();
                        // 사용자용 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserHomeScreen()),
                        );
                      }

                      print("둘러보기 버튼");
                    },
                    child: Text(
                      '어플 둘러보기',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18 + fontSizeOffset,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 800,
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
