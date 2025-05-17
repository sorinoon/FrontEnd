import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../Pages/User_SettingsProvider.dart';
import '../Pages/CAM_Analyze.dart';
import '../Pages/User_Home.dart';
import '../Pages/User_Navigate.dart';
import '../Pages/User_Setting.dart';
import '../Pages/User_NOKConnect.dart';
import '../Pages/User_NOKList.dart';

class GlobalMicButton extends StatefulWidget {
  final VoidCallback onPressed;

  const GlobalMicButton({super.key, required this.onPressed});

  @override
  State<GlobalMicButton> createState() => _GlobalMicButtonState();
}

class _GlobalMicButtonState extends State<GlobalMicButton> {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('🔄 음성인식 상태: $status');
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) => print('음성인식 오류: $error'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        localeId: 'ko_KR', // 한국어 인식
        onResult: (result) {
          final command = result.recognizedWords;
          print('음성 명령: $command');

          // 화면 전환 로직
          if (command.contains('설정')) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => UserSettingScreen()));
          } else if (command.contains('안내')) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => PageNavigate()));
          } else if (command.contains('인식')) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CameraAnalyzeScreen()));
          } else if (command.contains('홈') || command.contains('메인')) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => UserHomeScreen()));
          } else if (command.contains('등록')) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => NOKConnectScreen()));
          } else if (command.contains('목록')) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProtectorListScreen()));
          }else if (command.contains('뒤로') || command.contains('이전')) {
            Navigator.pop(context);
          } else {
            print('알 수 없는 명령: $command');
          }
        },
      );
    } else {
      print('음성 인식을 사용할 수 없습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 24,
      child: GestureDetector(
        onTap: () {
          widget.onPressed();
          Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
          _startListening(); // 음성 인식 시작
        },
        child: Container(
          width: 110,
          height: 110,
          child: Image.asset(
            'assets/images/micBtn.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
