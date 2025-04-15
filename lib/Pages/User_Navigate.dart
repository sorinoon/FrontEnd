import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../widgets/GlobalMicButton.dart';
import '../widgets/GlobalGoBackButton.dart';
import '../Pages/User_SettingsProvider.dart';

class PageNavigate extends StatefulWidget {
  const PageNavigate({Key? key}) : super(key: key);

  @override
  State<PageNavigate> createState() => _PageNavigateState();
}

class _PageNavigateState extends State<PageNavigate> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setBrightness();
    initializeCamera();
  }

  Future<void> setBrightness() async {
    final lowPowerProvider = Provider.of<UserSettingsProvider>(context, listen: false);
    final brightness = ScreenBrightness();

    if (lowPowerProvider.isLowPowerModeEnabled) {
      await brightness.setApplicationScreenBrightness(0.0);
    }
  }
  Future<void> initializeCamera() async {
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      print("카메라 권한이 거부되었습니다.");
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
        );
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print("카메라 초기화 중 오류 발생: $e");
    }
  }

  @override
  void dispose() {
    _resetBrightness();
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _resetBrightness() async {
    await ScreenBrightness().setApplicationScreenBrightness(1.0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _resetBrightness(); // 앱이 비활성화되면 밝기 복원
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_isCameraInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // ✅ 카메라 배경
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),

          // ✅ ⬅️ 뒤로가기
          GlobalGoBackButton(),

          // ✅ 안내 모드 (중앙 상단)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '안내 모드',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ✅ 통화 종료 버튼 (화면 하단 중앙)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          // ✅ 글로벌 마이크 버튼 (좌측 하단 유지)
          GlobalMicButton(
            onPressed: () {
              print("마이크 클릭됨");
            },
          ),
        ],
      ),
    );
  }
}
