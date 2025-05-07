import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../widgets/GlobalMicButton.dart';
import '../widgets/GlobalGoBackButton.dart';
import '../Pages/User_SettingsProvider.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _callProtector() async {
    // 추후에 사용자 목록 DB 연동 필요
    final List<String> contactNotes = [
      '010-1234-5678',
      '010-1234-1234',
      '010-5678-1234',
      '010-5678-5678',
    ];

    final String phoneNumber = contactNotes[0]; // 가장 상단 번호
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('전화 앱을 실행할 수 없습니다.');
    }
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
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // ✅ 통화 버튼 (화면 하단 중앙)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: GestureDetector(
                  onTap: () {
                    print("통화 버튼 클릭됨");
                    _callProtector();         // 전화 기능 호출
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.call,
                      color: Color(0xff24bd24),
                      size: 45,
                    ),
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
