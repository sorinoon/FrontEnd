import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'ProtectorSettingsProvider.dart';
import 'userList.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool isExpanded = false; // 박스 확장 여부를 관리하는 상태
  late final WebViewController _webViewController;

  List<Map<String, String>> locationList = [
    {'start': '서울특별시 성북구 동소문로 지하102 (성신여대입구역)', 'end': '서울특별시 성북구 삼선교로16길 116 (한성대학교)'},
  ];
  // List<Map<String, String>> locationList = [
  //   {'start': '37.5822, 127.0020', 'end': '37.5885, 127.0065'}, // 위도, 경도
  // ];

  @override
  void initState() {
    super.initState();

    // WebViewController 초기화
    final PlatformWebViewControllerCreationParams params =
    const PlatformWebViewControllerCreationParams();
    _webViewController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/kakaomap.html'); // HTML 파일 로드
  }

  @override
  Widget build(BuildContext context) {
    final protectorSettings = Provider.of<ProtectorSettingsProvider>(context);

    String startLocation = locationList[0]['start']!;
    String endLocation = locationList[0]['end']!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Color(0xff80C5A4),
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
                  MaterialPageRoute(builder: (context) => UserListScreen()),
                );
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),

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
                            startLocation,
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
                            endLocation,
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