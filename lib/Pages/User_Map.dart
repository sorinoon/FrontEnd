import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'User_Navigate.dart';

class UserMapPage extends StatefulWidget {
  const UserMapPage({Key? key}) : super(key: key);

  @override
  State<UserMapPage> createState() => _UserMapPageState();
}

class _UserMapPageState extends State<UserMapPage> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  String? _timeText;
  String? _distanceText;

  final String _appKey = 'huZN3mGcZh2sdd283mTHF8D4AVCBYOVB6v6umT6T';

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _onSearchPressed() async {
    final start = _startController.text;
    final end = _endController.text;

    if (start.isEmpty || end.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("출발지와 도착지를 모두 입력하세요.")),
      );
      return;
    }

    // 1. 주소 → 좌표 변환
    final startCoord = await _getCoordinates(start);
    final endCoord = await _getCoordinates(end);

    if (startCoord == null || endCoord == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("주소를 좌표로 변환할 수 없습니다.")),
      );
      return;
    }

    // 2. 도보 경로 요청
    final route = await _getPedestrianRoute(startCoord, endCoord);
    if (route != null) {
      setState(() {
        _timeText = "${route['time']}분";
        _distanceText = "${route['distance']}km";
      });

      // ✅ 지도 페이지 열기
      _openMapInWebView(
        startCoord['lon']!,
        startCoord['lat']!,
        endCoord['lon']!,
        endCoord['lat']!,
      );
    }
  }

  void _openMapInWebView(double startX, double startY, double endX, double endY) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/tmap_map.html')
      ..runJavaScript(
          "initMap($startX, $startY, $endX, $endY);"); // ✅ JS 함수 호출

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Stack(
            children: [
              WebViewWidget(controller: controller), // ✅ WebView 표시
              // ✅ 5초 후 자동 이동
              Positioned.fill(
                child: FutureBuilder(
                  future: Future.delayed(Duration(seconds: 5)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const PageNavigate()),
                        );
                      });
                    }
                    return const SizedBox.shrink();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }



  Future<Map<String, double>?> _getCoordinates(String address) async {
    final encodedKeyword = Uri.encodeComponent(address);
    final url = Uri.parse(
        'https://apis.openapi.sk.com/tmap/pois?version=1&searchKeyword=$encodedKeyword&resCoordType=WGS84GEO&reqCoordType=WGS84GEO');

    final response = await http.get(
      url,
      headers: {'appKey': _appKey},
    );

    print("🔍 API URL: $url");
    print("📦 응답: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final pois = data['searchPoiInfo']?['pois']?['poi'];

      if (pois != null && pois.isNotEmpty) {
        final first = pois[0];
        return {
          'lat': double.parse(first['frontLat']),
          'lon': double.parse(first['frontLon']),
        };
      }
    }
    return null;
  }


  Future<Map<String, dynamic>?> _getPedestrianRoute(
      Map<String, double> start, Map<String, double> end) async {
    final url = Uri.parse(
        'https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1');

    final body = {
      "startX": start['lon'].toString(),
      "startY": start['lat'].toString(),
      "endX": end['lon'].toString(),
      "endY": end['lat'].toString(),
      "reqCoordType": "WGS84GEO",
      "resCoordType": "WGS84GEO",
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'appKey': _appKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prop = data['features'][0]['properties'];
      final timeMin = (prop['totalTime'] / 60).round();
      final distanceKm = (prop['totalDistance'] / 1000).toStringAsFixed(2);

      return {
        'time': timeMin,
        'distance': distanceKm,
      };
    } else {
      print("경로 요청 실패: ${response.statusCode}");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("길찾기 설정")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _startController,
              decoration: InputDecoration(
                labelText: "출발지",
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _endController,
              decoration: InputDecoration(
                labelText: "도착지",
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _onSearchPressed,
              icon: Icon(Icons.search),
              label: Text("경로 검색"),
            ),
            SizedBox(height: 20),
            if (_timeText != null && _distanceText != null)
              Column(
                children: [
                  Text("예상 소요 시간: $_timeText", style: TextStyle(fontSize: 18)),
                  Text("예상 거리: $_distanceText", style: TextStyle(fontSize: 18)),
                ],
              )
          ],
        ),
      ),
    );
  }
}
