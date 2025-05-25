import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class UserMapPage extends StatefulWidget {
  const UserMapPage({super.key});

  @override
  State<UserMapPage> createState() => _UserMapPageState();
}

class _UserMapPageState extends State<UserMapPage> {
  static const platform = MethodChannel('tmap_channel');

  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final String _appKey = 'huZN3mGcZh2sdd283mTHF8D4AVCBYOVB6v6umT6T'; // ← 실제 API 키로 변경

  String? _resultText;

  Future<Map<String, double>?> _getCoordinates(String address) async {
    final encoded = Uri.encodeComponent(address);
    final url = Uri.parse(
        'https://apis.openapi.sk.com/tmap/pois?version=1&searchKeyword=$encoded&resCoordType=WGS84GEO&reqCoordType=WGS84GEO');

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
      final result = await platform.invokeMethod('drawRoute', {
        'startLat': startCoord['lat'],
        'startLon': startCoord['lon'],
        'endLat': endCoord['lat'],
        'endLon': endCoord['lon'],
      });

      setState(() {
        _resultText = result; // 네이티브에서 전달받은 시간/거리 정보
      });
    } catch (e) {
      print('❌ 네이티브 호출 오류: $e');
    }
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
                if (_resultText != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(_resultText!),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
