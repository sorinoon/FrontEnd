import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sorinoon/Pages/Page_Navigate.dart';
import 'package:sorinoon/Pages/Page_UserHome.dart';
import 'package:sorinoon/Pages/Page_Welcome.dart';
import '../Pages/home_protector.dart';
import 'package:provider/provider.dart';
import 'ProtectorSettingsProvider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

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
    // WebViewController 초기화
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // URL 변경 감지
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

  // Spring Boot 서버에 인증 코드 전달
  Future<void> _sendCodeToServer(String code) async {
    try {
      final response = await http.get(
        Uri.parse('http://<YOUR_SERVER_IP>:8080/callback?code=$code'),   // spring boot 서버 필요
      );

      if (response.statusCode == 200) {
        print("로그인 성공! 응답: ${response.body}");
        // TODO: 로그인 성공 후 사용자 정보 처리 및 화면 이동
      } else {
        print("로그인 실패: ${response.statusCode}");
      }
    } catch (error) {
      print("서버 요청 중 오류 발생: $error");
    }
  }

  // 카카오 로그인 버튼 클릭 시 WebView로 로그인 페이지 열기
  void _signInWithKakao() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("카카오 로그인"),
          ),
          body: WebViewWidget(

            //Todo 백엔드 스프링부트 서버
            controller: _webViewController..loadRequest(Uri.parse('http://<YOUR_SERVER_IP>:8080/login/page')),     // spring boot 서버 필요

          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final protectorSettings = Provider.of<ProtectorSettingsProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // 배경
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // 로고 및 이름
          Positioned(
            top: 230 - protectorSettings.fontSizeOffset * 4,
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
                      color: isToggled ? Color(0xff80C5A4) : Color(0xffF8CB38), // 네모 박스 색상
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image, // 로고 대체
                        color: Colors.white,
                        size: 40 + protectorSettings.fontSizeOffset,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  // 앱 이름
                  Text(
                    '소리눈',
                    style: TextStyle(
                      fontSize: 40 + protectorSettings.fontSizeOffset,
                      fontWeight: FontWeight.bold,
                      color: isToggled ? Color(0xff80C5A4) : Color(0xffF8CB38),
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
                SizedBox(height: 450 - protectorSettings.fontSizeOffset * 5), // 로고와 버튼 간격 조정
                Container(
                  width: 307 + protectorSettings.fontSizeOffset * 10,
                  height: 57 + protectorSettings.fontSizeOffset * 2,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFE726),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all( // 테두리
                      color: Color(0xffe2e2e2),
                      width: 1,
                    ),
                  ),
                  child: TextButton(
                    onPressed:() {
                      final provider = Provider.of<ProtectorSettingsProvider>(context, listen: false);
                      provider.vibrate();

                      if (isToggled) {
                        // 보호자용 페이지로 이동
                            _signInWithKakao();// 카카오 로그인 버튼 클릭 시 처리
                      } else {
                        // 사용자용 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WelcomePage()),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center, // 이미지와 텍스트가 중앙에 오도록
                      children: [
                        Image.asset(
                          'assets/images/kakao_logo.jpg',
                          width: 46,
                          height: 37,
                        ),
                        SizedBox(width: 2),
                        Text(
                          '카카오로 3초만에 시작하기',
                          style: TextStyle(
                            color: Color(0xff4D3033),
                            fontWeight: FontWeight.bold,
                            fontSize: 18 + protectorSettings.fontSizeOffset,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20), // 버튼 간 간격 조정
                Container(
                  width: 307 + protectorSettings.fontSizeOffset * 10,
                  height: 57 + protectorSettings.fontSizeOffset * 2,
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    borderRadius:
                    BorderRadius.circular(50), // 둥근 모서리 적용
                    border:
                    Border.all(color: Colors.black, width: 1), // 테두리 적용
                  ),
                  child: TextButton(
                    onPressed: () {
                      final provider = Provider.of<ProtectorSettingsProvider>(context, listen: false);
                      provider.vibrate();

                      if (isToggled) {
                        // 보호자용 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      } else {
                        // 사용자용 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => U_HomePage()),
                        );
                      }

                      print("둘러보기 버튼");
                    },
                    child:
                    Text(
                      '어플 둘러보기',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18 + protectorSettings.fontSizeOffset,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),

          Positioned(
            top: 800,
            left: 0,
            right: 0,
            child: Center( // 중앙 정렬
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // CupertinoSwitch 토글
                  CupertinoSwitch(
                    value: isToggled,
                    onChanged: (bool value) {
                      setState(() {
                        isToggled = value;
                      });
                      Provider.of<ProtectorSettingsProvider>(context, listen: false).vibrate();
                    },
                    activeTrackColor: Color(0xff80C5A4), // 활성화된 트랙 색상
                    inactiveTrackColor: Color(0xffF8CB38), // 비활성화된 트랙 색상
                    thumbColor: CupertinoColors.white, // 원 색상
                  ),
                  SizedBox(width: 5),

                  // 텍스트
                  Text(
                    isToggled ? '보호자로 로그인' : '사용자로 로그인',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18 + protectorSettings.fontSizeOffset,
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