import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../Pages/User_SettingsProvider.dart';
import '../widgets/GlobalGoBackButtonWhite.dart';
import '../widgets/GlobalMicButton.dart';
import 'package:http/http.dart' as http;

class PageNavigate extends StatefulWidget {
  final List<LatLng> route;

  const PageNavigate({Key? key, required this.route}) : super(key: key);

  @override
  State<PageNavigate> createState() => _PageNavigateState();
}

class _PageNavigateState extends State<PageNavigate> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  WebSocketChannel? _channel;
  Timer? _sendTimer;
  CameraImage? latestFrame;

  String _yoloResultText = '감지 대기 중...';
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  StreamSubscription<Position>? _positionStream;
  final Distance _distance = Distance();
  int _lastGuidedIndex = -1;

  bool _hasDeviated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAll();
  }

  Future<void> _initAll() async {
    await _setBrightness();
    await _initializeCamera();
    await _initializeWebSocket();
    await _initializeLocationTracking();
  }

  Future<void> _setBrightness() async {
    final settings = Provider.of<UserSettingsProvider>(context, listen: false);
    final brightness = ScreenBrightness();

    if (settings.isLowPowerModeEnabled) {
      await brightness.setApplicationScreenBrightness(0.0);
    }
  }

  Future<void> _resetBrightness() async {
    await ScreenBrightness().setApplicationScreenBrightness(1.0);
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;

    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![0], ResolutionPreset.low);
      await _cameraController!.initialize();

      setState(() {
        _isCameraInitialized = true;
      });

      _cameraController!.startImageStream((CameraImage image) {
        latestFrame = image;
      });
    }
  }

  Future<void> _initializeWebSocket() async {
    _flutterTts.setLanguage("ko-KR");
    _flutterTts.setSpeechRate(0.5);

    _channel = WebSocketChannel.connect(
      Uri.parse('ws://223.194.138.73:8000/ws/detect/'),
    );

    _channel!.stream.listen((message) async {
      final data = jsonDecode(message);
      final warning = data['warning'];

      if (warning != null && warning.isNotEmpty && !_isSpeaking) {
        _isSpeaking = true;
        await _flutterTts.speak(warning);
        _flutterTts.setCompletionHandler(() {
          _isSpeaking = false;
        });
      }
    });

    _sendTimer = Timer.periodic(Duration(milliseconds: 300), (_) async {
      if (latestFrame == null) return;
      final image = latestFrame!;
      latestFrame = null;

      try {
        final width = image.width;
        final height = image.height;
        final bytes = image.planes[0].bytes;

        final grayscale = img.Image(width: width, height: height);
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            final index = y * width + x;
            final value = bytes[index];
            grayscale.setPixel(x, y, img.ColorRgb8(value, value, value));
          }
        }

        final jpeg = img.encodeJpg(grayscale);
        final base64Image = base64Encode(jpeg);

        if (_channel != null && _channel!.closeCode == null) {
          _channel!.sink.add(jsonEncode({'image': base64Image}));
        }
      } catch (e) {
        print("프레임 전송 실패: $e");
      }
    });
  }

  Future<void> _initializeLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) return;
    }

    _positionStream = Geolocator.getPositionStream().listen((Position position) {
      _checkGuidance(position);
    });
  }

  Future<void> _recalculateRoute(Position userPosition) async {
    // 도착지 다시 설정 (기존 목적지 유지한다고 가정)
    final dest = widget.route.last; // 원래 목적지

    final response = await http.post(
      Uri.parse('https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1'),
      headers: {'Content-Type': 'application/json', 'appKey': 'huZN3mGcZh2sdd283mTHF8D4AVCBYOVB6v6umT6T'},
      body: jsonEncode({
        "startX": userPosition.longitude,
        "startY": userPosition.latitude,
        "endX": dest.longitude,
        "endY": dest.latitude,
        "reqCoordType": "WGS84GEO",
        "resCoordType": "WGS84GEO",
      }),
    );

    final data = jsonDecode(response.body);
    final features = data['features'];
    final newRoute = <LatLng>[];

    for (var f in features) {
      final geometry = f['geometry'];
      if (geometry['type'] == 'Point') {
        final coords = geometry['coordinates'];
        newRoute.add(LatLng(coords[1], coords[0]));
      }
    }

    setState(() {
      widget.route.clear();
      widget.route.addAll(newRoute);
      _lastGuidedIndex = -1;
      _hasDeviated = false;
    });

    await _flutterTts.speak("새로운 경로로 안내를 시작합니다.");
  }


  void _checkGuidance(Position position) async {
    for (int i = _lastGuidedIndex + 1; i < widget.route.length; i++) {
      final userPos = LatLng(position.latitude, position.longitude);
      bool isOnRoute = widget.route.any((point) {
        final dist = _distance(userPos, point);
        return dist < 25.0; // 25m 이내면 경로 위
      });

      if (!isOnRoute && !_hasDeviated) {
        _hasDeviated = true;
        if (!_isSpeaking) {
          _isSpeaking = true;
          await _flutterTts.speak("경로를 이탈했습니다. 재탐색이 필요합니다");
          _flutterTts.setCompletionHandler(() {
            _isSpeaking = false;
          });
        }
        _recalculateRoute(position);
      }
      final routePos = widget.route[i];

      final distanceToPoint = _distance(userPos, routePos);

      if (distanceToPoint < 15.0) {
        _lastGuidedIndex = i;

        if (i < widget.route.length - 1) {
          final current = widget.route[i];
          final next = widget.route[i + 1];

          final bearing = _distance.bearing(current, next);
          String direction;

          if (bearing > 45 && bearing < 135) {
            direction = "오른쪽으로 이동하세요";
          } else if (bearing > -135 && bearing < -45) {
            direction = "왼쪽으로 이동하세요";
          } else {
            direction = "직진하세요";
          }

          if (!_isSpeaking) {
            _isSpeaking = true;
            await _flutterTts.speak(direction);
            _flutterTts.setCompletionHandler(() {
              _isSpeaking = false;
            });
          }
        } else {
          await _flutterTts.speak("목적지에 도착했습니다");
          _positionStream?.cancel();
        }
        break;
      }
    }
  }

  void _callProtector() async {
    final phoneUri = Uri(scheme: 'tel', path: '010-1234-5678');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('전화 앱 실행 실패');
    }
  }

  @override
  void dispose() {
    _resetBrightness();
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _channel?.sink.close();
    _sendTimer?.cancel();
    _flutterTts.stop();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _resetBrightness();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_isCameraInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(child: CameraPreview(_cameraController!)),
          GlobalGoBackButtonWhite(),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '안내 모드',
                  style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _yoloResultText,
                style: TextStyle(fontSize: 18, color: Colors.white, backgroundColor: Colors.black54),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: GestureDetector(
                  onTap: _callProtector,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: Icon(Icons.call, color: Color(0xff24bd24), size: 45),
                  ),
                ),
              ),
            ),
          ),
          GlobalMicButton(onPressed: () {
            print("마이크 클릭됨");
          }),
        ],
      ),
    );
  }
}