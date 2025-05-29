import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Pages/User_Map.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../Pages/User_SettingsProvider.dart';
import '../Pages/CAM_Analyze.dart';
import '../Pages/User_Home.dart';
import '../Pages/User_Setting.dart';
import '../Pages/User_NOKConnect.dart';
import '../Pages/User_NOKList.dart';
import 'package:lottie/lottie.dart';
import '../Pages/CAM_QR.dart';

class GlobalMicButton extends StatefulWidget {
  final VoidCallback onPressed;

  const GlobalMicButton({super.key, required this.onPressed});

  @override
  State<GlobalMicButton> createState() => _GlobalMicButtonState();
}

class _GlobalMicButtonState extends State<GlobalMicButton> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _isProcessing = false;
  bool _showVoice = false;
  bool _showVoiceOut = false;
  final Queue<String> _commandQueue = Queue();
  bool _shouldContinueListening = true;
  String _lastCommand = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();

    _flutterTts.setLanguage("ko-KR");
    _flutterTts.setSpeechRate(0.8);
    _flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _speak(String text) async {
    print("🗣️ 말하기: $text");
    await _speech.stop();
    await _flutterTts.speak(text);
  }

  Future<void> _startListening() async {
    if (!_shouldContinueListening) return;

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) => print('❌ 음성인식 오류: $error'),
    );

    if (available) {
      if (mounted) setState(() => _isListening = true);

      _speech.listen(
        localeId: 'ko_KR',
        partialResults: false,
        onResult: (result) {
          final command = result.recognizedWords.trim().toLowerCase();
          print("🎧 최종 명령어: $command");

          if (command.isNotEmpty && command != _lastCommand) {
            _lastCommand = command;
            _commandQueue.add(command);
            _processNextCommand();
          }
        },
      );
    } else {
      _speak("음성 인식을 사용할 수 없습니다");
    }
  }

  Future<void> _processNextCommand() async {
    if (_isProcessing || _commandQueue.isEmpty) return;

    _isProcessing = true;
    final command = _commandQueue.removeFirst();

    await _speech.stop();
    _isListening = false;
    _shouldContinueListening = false;

    print("⚙️ 처리 중: $command");

    Future<void> navigate(Widget page, String message) async {
      if (!mounted) return;
      await _speak(message);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    }

    if (command.contains('설정')) {
      await navigate(UserSettingScreen(), "설정 페이지로 이동할게요");
    } else if (command.contains('안내')) {
      await navigate(UserMapPage(), "소리눈 네비게이션으로 이동할게요");
    } else if (command.contains('인식')) {
      await navigate(CameraAnalyzeScreen(), "소리눈 문서 인식으로 이동할게요");
    } else if (command.contains('홈') || command.contains('메인')) {
      await navigate(UserHomeScreen(), "메인 홈으로 이동할게요");
    } else if (command.contains('등록')) {
      await navigate(NOKConnectScreen(), "보호자 등록 페이지로 이동할게요");
    } else if (command.contains('목록')) {
      await navigate(ProtectorListScreen(), "보호자 목록 페이지로 이동할게요");
    } else if (command.contains('카메라') || (command.contains('QR'))) {
      await navigate(CAMQRScreen(), "보호자 QR 등록 페이지로 이동할게요");
    }else if (command.contains('뒤로') || command.contains('이전')) {
      await _speak("이전 페이지로 이동할게요");
      if (mounted) Navigator.pop(context);
    } else if (command.contains("소리 눈") || command.contains("소리눈") || command.contains("우리는") || command.contains("우리눈") || command.contains("우리 눈")){
      await _speak("소리눈 어플리케이션에서는 설정, 안내, 인식, 홈, 등록, 목록 같은 음성 명령어로 각각의 페이지로 이동할 수 있습니다."
          "이전 이라고 말하면 이전 페이지로 돌아갈 수 있고, 고마워, 됐어, 종료라고 말하면 음성 안내가 종료됩니다."
          "지금 어떤 페이지에 있는지 헷갈리신다면 언제든지 소리눈이라고 불러주세요."
          "현재 페이지가 무엇인지와 함께, 사용할 수 있는 음성 명령어를 친절하게 안내해드립니다.");
    } else if (command.contains('음성 명령어') || command.contains('명령어')) {
      await _speak("지금 사용할 수 있는 명령어는 설정. 안내. 인식. 홈. 등록. 목록. 소리눈. 이전, 명령어. 음성 명령어가 있습니다");
    } else if (command.contains('고마워') ||
        command.contains('됐어') ||
        command.contains('종료')) {
      await _speak("언제든 다시 불러주세요");
    } else if (command.contains('전송')) {
      // final isInAnalyzeScreen =
      //     context.widget.runtimeType == CameraAnalyzeScreen;
      //
      // if (isInAnalyzeScreen) {
      //   final state = context.findAncestorStateOfType<CameraAnalyzeState>();
      //   if (state != null) {
      //     state.captureAndSendScreen();
      //   } else {
      //     final unknowns = [
      //       "죄송해요. 다시 말씀해 주시겠어요?",
      //       "잘 못 들었어요. 한 번 더 말씀해 주세요.",
      //       "말씀을 놓쳤어요. 다시 한 번 부탁드릴게요.",
      //     ];
      //     await _speak(unknowns[Random().nextInt(unknowns.length)]);
      //     _shouldContinueListening = true;
      //   }
      // }
    }

    _isProcessing = false;

    if (_commandQueue.isNotEmpty) {
      _processNextCommand();
    } else if (_shouldContinueListening &&
        mounted &&
        ModalRoute.of(context)?.isCurrent == true) {
      await Future.delayed(const Duration(milliseconds: 300));
      _startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (_showVoice)
            Positioned(
              bottom: -70,
              left: -22,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 1000),
                child: AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 1000),
                  child: Lottie.asset('assets/lottie/Voice.json', width: 200),
                ),
              ),
            ),
          if (_showVoiceOut)
            Positioned(
              bottom: -70,
              left: -22,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: Lottie.asset('assets/lottie/VoiceOut.json', width: 200),
              ),
            ),
          Positioned(
            bottom: -26,
            left: 24,
            child: GestureDetector(
              onTap: () async {
                widget.onPressed();
                Provider.of<UserSettingsProvider>(
                  context,
                  listen: false,
                ).vibrate();
                _shouldContinueListening = true;
                _lastCommand = '';

                setState(() {
                  _showVoice = true;
                  _showVoiceOut = false;
                });

                await _speak("부르셨나요?");
                await Future.delayed(const Duration(milliseconds: 100));
                await _startListening();

                await Future.delayed(const Duration(milliseconds: 5000));
                if (mounted) {
                  setState(() {
                    _showVoice = false;
                    _showVoiceOut = true;
                  });
                }
              },
              child: SizedBox(
                width: 110,
                height: 110,
                child: Image.asset(
                  'assets/images/micBtn.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print("🧹 dispose() 호출됨: 리스닝 중단 및 초기화");
    _speech.stop();
    _flutterTts.stop();
    _commandQueue.clear();
    _shouldContinueListening = false;
    _isListening = false;
    _isProcessing = false;
    super.dispose();
  }
}