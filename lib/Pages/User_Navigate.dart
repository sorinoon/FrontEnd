import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image/image.dart' as img;
import 'dart:async';

class PageNavigate extends StatefulWidget {
  const PageNavigate({Key? key}) : super(key: key);

  @override
  State<PageNavigate> createState() => _PageNavigateState();
}

class _PageNavigateState extends State<PageNavigate> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  WebSocketChannel? _channel;
  String _yoloResultText = '감지 대기 중...';

  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCameraAndWebSocket();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _channel?.sink.close();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initializeCameraAndWebSocket() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      print("카메라 권한이 거부되었습니다.");
      return;
    }

    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![0], ResolutionPreset.low);
      await _cameraController!.initialize();

      setState(() {
        _isCameraInitialized = true;
      });

      _flutterTts.setLanguage("ko-KR");
      _flutterTts.setSpeechRate(0.5);

      _channel = WebSocketChannel.connect(
        Uri.parse('ws://172.30.1.55:8000/ws/detect/'),
      );

      // _channel!.stream.listen((message) async {
      //   final data = jsonDecode(message);
      //   final warning = data['warning'];
      //
      //   if (warning != null && warning.isNotEmpty) {
      //     setState(() {
      //       _yoloResultText = warning;
      //     });
      //
      //     if (!_isSpeaking) {
      //       _isSpeaking = true;
      //       await _flutterTts.speak(warning);
      //       _flutterTts.setCompletionHandler(() {
      //         _isSpeaking = false;
      //       });
      //     }
      //   }
      // });
      _channel!.stream.listen((message) async {
        final data = jsonDecode(message);
        final emergencyWarning = data['emergency_warning'];
        final warning = data['warning'];

        if (emergencyWarning != null && emergencyWarning.isNotEmpty) {
          setState(() {
            _yoloResultText = emergencyWarning;
          });

          // 현재 음성 출력 중이더라도 강제 중단하고 emergency 우선 처리
          await _flutterTts.stop();
          _isSpeaking = true;

          await _flutterTts.speak(emergencyWarning);
          _flutterTts.setCompletionHandler(() {
            _isSpeaking = false;
          });

        } else if (warning != null && warning.isNotEmpty) {
          setState(() {
            _yoloResultText = warning;
          });

          if (!_isSpeaking) {
            _isSpeaking = true;
            await _flutterTts.speak(warning);
            _flutterTts.setCompletionHandler(() {
              _isSpeaking = false;
            });
          }
        }
      });
      _startStream();
    }
  }

  // ✅ 이미지 → base64 JPEG 변환 후 WebSocket 전송
  // void _startVideoStream() {
  //   _cameraController!.startImageStream((CameraImage image) async {
  //     try {
  //       final width = image.width;
  //       final height = image.height;
  //       final bytes = image.planes[0].bytes;
  //
  //       final grayscale = img.Image(width: width, height: height);  // ✅ 생성자 변경됨
  //
  //       for (int y = 0; y < height; y++) {
  //         for (int x = 0; x < width; x++) {
  //           final pixelIndex = y * width + x;
  //           final pixelValue = bytes[pixelIndex];
  //           grayscale.setPixel(x, y, img.ColorRgb8(pixelValue, pixelValue, pixelValue));  // ✅ RGB로 픽셀 설정
  //         }
  //       }
  //
  //
  //       final jpeg = img.encodeJpg(grayscale);
  //       final base64Image = base64Encode(jpeg);
  //
  //       _channel?.sink.add(jsonEncode({'image': base64Image}));
  //     } catch (e) {
  //       print('이미지 스트림 처리 중 오류: $e');
  //     }
  //   });
  // }
  CameraImage? latestFrame;

  void _startStream() {
    _cameraController!.startImageStream((CameraImage image) {
      latestFrame = image; // 최신 프레임 덮어쓰기
    });

    Timer.periodic(Duration(milliseconds: 33), (_) async {
      if (latestFrame == null) return;

      final image = latestFrame!;
      latestFrame = null;  // 다음 프레임 받을 준비

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

        _channel?.sink.add(jsonEncode({'image': base64Image}));
      } catch (e) {
        print("프레임 전송 실패: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_isCameraInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(child: CameraPreview(_cameraController!)),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '안내 모드',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
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
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
