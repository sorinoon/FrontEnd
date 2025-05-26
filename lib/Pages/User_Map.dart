import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class UserMapPage extends StatefulWidget {
  const UserMapPage({super.key});

  @override
  State<UserMapPage> createState() => _UserMapPageState();
}

class _UserMapPageState extends State<UserMapPage> {
  static const platform = MethodChannel('tmap_channel');

  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final String _appKey = 'huZN3mGcZh2sdd283mTHF8D4AVCBYOVB6v6umT6T';

  final FlutterTts flutterTts = FlutterTts();

  String? _routeTimeText; // 도보 예상 시간 저장용

  Future<void> _speak(String? text) async {
    if (text != null && text.isNotEmpty) {
      await flutterTts.speak(text);
    }
  }

  Future<Map<String, double>?> _getCoordinates(String address) async {
    final encoded = Uri.encodeComponent(address);
    final url = Uri.parse(
      'https://apis.openapi.sk.com/tmap/pois?version=1&searchKeyword=$encoded&resCoordType=WGS84GEO&reqCoordType=WGS84GEO',
    );

    final response = await http.get(url, headers: {'appKey': _appKey});
    final data = jsonDecode(response.body);
    final pois = data['searchPoiInfo']?['pois']?['poi'];

    if (pois != null && pois.isNotEmpty) {
      final poi = pois[0];
      return {
        'lat': double.parse(poi['frontLat']),
        'lon': double.parse(poi['frontLon']),
      };
    }
    return null;
  }

  Future<void> _onSearchPressed() async {
    final start = _startController.text.trim();
    final end = _endController.text.trim();

    if (start.isEmpty || end.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('출발지와 도착지를 모두 입력하세요')),
      );
      return;
    }

    final startCoord = await _getCoordinates(start);
    final endCoord = await _getCoordinates(end);

    if (startCoord == null || endCoord == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('좌표 변환 실패')),
      );
      return;
    }

    try {
      await platform.invokeMethod('drawRoute', {
        'startLat': startCoord['lat'],
        'startLon': startCoord['lon'],
        'endLat': endCoord['lat'],
        'endLon': endCoord['lon'],
      });
    } catch (e) {
      print('❌ 네이티브 호출 오류: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) async {
      if (call.method == "routeResult") {
        final result = call.arguments.toString(); // 예: "도보 예상 시간: 92분"
        setState(() {
          _routeTimeText = result;
        });
        await _speak(result); // 음성 출력
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tmap 경로 안내')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: AndroidView(
              viewType: 'TMapNativeView',
              layoutDirection: TextDirection.ltr,
              creationParams: {},
              creationParamsCodec: const StandardMessageCodec(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                TextField(
                  controller: _startController,
                  decoration: const InputDecoration(labelText: '출발지 입력'),
                ),
                TextField(
                  controller: _endController,
                  decoration: const InputDecoration(labelText: '도착지 입력'),
                ),
                ElevatedButton(
                  onPressed: _onSearchPressed,
                  child: const Text('경로 요청'),
                ),
                if (_routeTimeText != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _routeTimeText!,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
