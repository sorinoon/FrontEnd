import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'NOK_SettingsProvider.dart';
import 'NOK_Userlist.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/GlobalGoBackButton.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool isExpanded = false; // 박스 확장 여부를 관리하는 상태
  late final WebViewController _webViewController;
  String? latitude;
  String? longitude;

  List<Map<String, String>> locationList = [
    {
      'start': '37.5822,127.0020', // 성신여대입구역 좌표
      'end': '37.5885,127.0065'    // 한성대학교 좌표
    },
  ];

  @override
  void initState() {
    super.initState();

    // WebViewController 초기화
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/kakaomap.html'); // HTML 파일 로드
    //..loadRequest(Uri.parse('http://localhost:8080/map')); // Spring Boot 서버 URL

    // 현재 위치 가져오기
    getGeoData();
  }

  Future<void> getGeoData() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          throw Exception('위치 권한 필요');
        }
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
      });

      // WebView에 JavaScript로 위치 데이터 전달
      _webViewController.runJavaScript('''
        updateLocation(${position.latitude}, ${position.longitude});
      ''');
    } catch (e) {
      print('위치 정보를 가져오는 데 실패했습니다: $e');
    }
    _sendRouteCoordinates();
  }

  void _sendRouteCoordinates() {
    final start = locationList[0]['start']!.split(',');
    final end = locationList[0]['end']!.split(',');

    _webViewController.runJavaScript('''
      updateRoute(
        ${double.parse(start[0])}, ${double.parse(start[1])},
        ${double.parse(end[0])}, ${double.parse(end[1])}
      );
    ''');
  }

  @override
  Widget build(BuildContext context) {
    final protectorSettings = Provider.of<NOKSettingsProvider>(context);

    final start = locationList[0]['start']!;
    final end = locationList[0]['end']!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Color(0xff80C5A4),
            ),
          ),

          GlobalGoBackButton(),

          // 카카오 지도 표시
          Positioned.fill(
            top: isExpanded ? 210 : 170,
            child: WebViewWidget(controller: _webViewController),
          ),

          // 위치 정보 박스
          Positioned(
            top: 90,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded; // 클릭 시 박스 확장/축소 상태 변경
                });
                Provider.of<NOKSettingsProvider>(context, listen: false).vibrate();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300), // 애니메이션 효과 추가
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: isExpanded ? 20 : 15),
                decoration: BoxDecoration(
                  color: Color(0xffF9F9F9),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff2f2f2f).withValues(alpha: 0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 시작 위치와 끝 위치 간격 유지
                      children: [
                        Expanded(
                          child: Text(
                            start,
                            style: TextStyle(
                              fontSize: 17 + protectorSettings.fontSizeOffset,
                            ),
                            overflow:
                            isExpanded ? TextOverflow.visible : TextOverflow.ellipsis, // 확장 여부에 따라 처리
                            maxLines: isExpanded ? null : 1, // 확장 시 줄 제한 해제
                            softWrap: true, // 줄바꿈 활성화
                          ),
                        ),
                        Icon(Icons.arrow_right_alt, size: 25),
                        Expanded(
                          child: Text(
                            end,
                            style: TextStyle(
                              fontSize: 17 + protectorSettings.fontSizeOffset,
                            ),
                            overflow:
                            isExpanded ? TextOverflow.visible : TextOverflow.ellipsis, // 확장 여부에 따라 처리
                            maxLines: isExpanded ? null : 1, // 확장 시 줄 제한 해제
                            softWrap: true, // 줄바꿈 활성화
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}