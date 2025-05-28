import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Pages/User_SettingsProvider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:latlong2/latlong.dart';
import '../widgets/TmapMicButton.dart';
import '../widgets/GlobalGoBackButton.dart';
import '../Pages/User_Home.dart';
import '../Pages/User_Navigate.dart';

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

  String? _routeTimeText;
  List<LatLng> _routePoints = [];

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
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

  Future<void> _searchRoute() async {
    final start = _startController.text.trim();
    final end = _endController.text.trim();

    if (start.isEmpty || end.isEmpty) {
      await _speak("출발지와 도착지를 모두 입력하세요");
      return;
    }

    final startCoord = await _getCoordinates(start);
    final endCoord = await _getCoordinates(end);

    if (startCoord == null || endCoord == null) {
      await _speak("좌표 변환에 실패했습니다");
      return;
    }

    await _speak("경로를 탐색 중입니다");
    await Future.delayed(Duration(seconds: 3));

    try {
      await platform.invokeMethod('drawRoute', {
        'startLat': startCoord['lat'],
        'startLon': startCoord['lon'],
        'endLat': endCoord['lat'],
        'endLon': endCoord['lon'],
      });

      final response = await http.post(
        Uri.parse(
          'https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1',
        ),
        headers: {'Content-Type': 'application/json', 'appKey': _appKey},
        body: jsonEncode({
          "startX": startCoord['lon'],
          "startY": startCoord['lat'],
          "endX": endCoord['lon'],
          "endY": endCoord['lat'],
          "reqCoordType": "WGS84GEO",
          "resCoordType": "WGS84GEO",
        }),
      );

      final data = jsonDecode(response.body);
      final features = data['features'];
      _routePoints.clear();

      for (var f in features) {
        final geometry = f['geometry'];
        if (geometry['type'] == 'Point') {
          final coords = geometry['coordinates'];
          _routePoints.add(LatLng(coords[1], coords[0]));
        }
      }
    } catch (e) {
      print('❌ 네이티브 호출 오류: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) async {
      if (call.method == "routeResult") {
        final result = call.arguments.toString();
        setState(() {
          _routeTimeText = result;
        });
        await _speak(result);
      }
    });
  }

  void updateInputField(String field, String value) async {
    if (field.contains("출발")) {
      _startController.text = value;
      await _speak("$value 를 출발지로 설정했습니다");
    } else if (field.contains("도착")) {
      _endController.text = value;
      await _speak("$value 를 도착지로 설정했습니다");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final UserSettings = Provider.of<UserSettingsProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 17.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 6 - UserSettings.fontSizeOffset*0.8),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  _speak("Tmap 경로 안내");
                                  Provider.of<UserSettingsProvider>(
                                      context, listen: false).vibrate();
                                },
                                child: Text(
                                  'Tmap 경로 안내',
                                  style: TextStyle(
                                    fontSize: 25 + UserSettings.fontSizeOffset,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 450,
                              child: AndroidView(
                                viewType: 'TMapNativeView',
                                layoutDirection: TextDirection.ltr,
                                creationParams: {},
                                creationParamsCodec:
                                const StandardMessageCodec(),
                              ),
                            ),
                            TextField(
                              controller: _startController,
                              onChanged: (_) {
                                if (_routeTimeText != null) {
                                  setState(() {
                                    _routeTimeText = null;
                                  });
                                }
                              },
                              decoration: const InputDecoration(
                                labelText: '출발지 입력',
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextField(
                              controller: _endController,
                              onChanged: (_) {
                                if (_routeTimeText != null) {
                                  setState(() {
                                    _routeTimeText = null;
                                  });
                                }
                              },
                              decoration: const InputDecoration(
                                labelText: '도착지 입력',
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Provider.of<UserSettingsProvider>(
                                  context,
                                  listen: false,
                                ).vibrate();
                                if (_routeTimeText == null) {
                                  _searchRoute();
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                          PageNavigate(route: _routePoints),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(
                                    color: Color(0xffF8CB38),
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Text(
                                _routeTimeText == null ? '경로 탐색' : '안내 시작',
                                style: TextStyle(
                                  fontSize: 20 + UserSettings.fontSizeOffset,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (_routeTimeText != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                child: Center(
                                  child: Text(
                                    _routeTimeText!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          GlobalGoBackButton(targetPage: UserHomeScreen()),
          if (!isKeyboardVisible) TmapMicButton(
            onPressed: () {},
            customCommandHandler: (command, tts, context) async {
              final state =
              context.findAncestorStateOfType<_UserMapPageState>();

              if (command.contains("출발지")) {
                final place = command.replaceAll("출발지", "").trim();
                state?.updateInputField("출발", place);
                return true;
              }else if (command.contains("최준희와 아이들") || command.contains("최준희")) {
                await tts.speak("그거 아시나요? 최준희와 아이들 팀의 최준희는 팀장을 하기 싫어했습니다. 하지만 즐기고 있다는 것이 정설입니다");
              }else if (command.contains("도착지")) {
                final place = command.replaceAll("도착지", "").trim();
                state?.updateInputField("도착", place);
                return true;
              } else if (command.contains("경로 탐색") || command.contains("탐색")) {
                if (state != null) {
                  await tts.speak("경로를 탐색할게요");
                  state._searchRoute();
                  return true;
                }
              } else if (command.contains("소리 눈") || command.contains("소리눈") ||
                  command.contains("우리는") || command.contains("우리눈") || command.contains("우리 눈") || command.contains("소리는")) {
                await tts.speak(
                    "지금은 출발지와 목적지 설정 페이지입니다. "
                        "출발지 한성대입구역. 이라고 말하여 출발지를 설정하고, "
                        "도착지 길흥역. 이라고 말하여 도착지를 설정합니다. "
                        "경로 탐색. 이라고 말하여 경로 탐색을 시작합니다."
                        "안내 시작. 이라고 말하여 탐색한 경로를 토대로 도보 안내를 시작합니다."
                );
                return true;
              } else if (command.contains("홈") || command.contains("메인")) {
                await tts.speak("메인 홈으로 이동할게요");
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => UserHomeScreen()),
                  );
                }
                return true;
              } else if (command.contains("뒤로") || command.contains("이전")) {
                await tts.speak("이전 페이지로 이동할게요");
                if (context.mounted) Navigator.pop(context);
                return true;
              } else if (command.contains("음성 명령어") || command.contains("명령어")) {
                await tts.speak("지금 사용할 수 있는 명령어는 출발지 한성대입구역. 도착지 한성대. 경로 탐색. 안내 시작. 홈 또는 메인. 이전. 이 있습니다");
              }
              else if (command.contains("안내 시작") || command.contains("시작"))
              { if (state != null) {
                await tts.speak("소리눈 네비게이션이 안내를 시작합니다");
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PageNavigate(route: state._routePoints),
                    ),
                  );
                }
                return true;
              }
              }
              return false;
            },
          ),
        ],
      ),
    );
  }
}
