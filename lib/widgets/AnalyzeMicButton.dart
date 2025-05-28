import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lottie/lottie.dart';
import '../Pages/CAM_Analyze.dart';
import '../Pages/User_Home.dart';
import '../Pages/User_SettingsProvider.dart';

class AnalyzeMicButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Future<void> Function(int mode)? onSend;

  const AnalyzeMicButton({super.key, required this.onPressed, this.onSend});

  @override
  State<AnalyzeMicButton> createState() => _AnalyzeMicButtonState();
}

class _AnalyzeMicButtonState extends State<AnalyzeMicButton> {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isProcessing = false;
  final Queue<String> _commandQueue = Queue();
  String _lastCommand = '';
  bool _showVoice = false;
  bool _showVoiceOut = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts()
      ..setLanguage("ko-KR")
      ..setSpeechRate(0.8)
      ..awaitSpeakCompletion(true);
  }

  Future<void> _speak(String text) async {
    await _speech.stop();
    await _tts.speak(text);
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (!available) {
      await _speak("음성 인식을 사용할 수 없습니다");
      return;
    }

    setState(() => _showVoice = true);
    _speech.listen(
      localeId: 'ko_KR',
      partialResults: false,
      onResult: (result) async {
        final command = result.recognizedWords.trim().toLowerCase();
        if (command.isNotEmpty && command != _lastCommand) {
          _lastCommand = command;
          _commandQueue.add(command);
          await _processCommand(command);
        }
      },
    );
  }

  Future<void> _processCommand(String command) async {
    final state = context.findAncestorStateOfType<CameraAnalyzeState>();
    if (state != null) {
      if (command.contains('요약')) {
        await _speak("요약을 시작할게요");
        state.captureAndSendScreen(0); //요약 모드
      } else if (command.contains('전송')) {
        await _speak("분석을 시작할게요");
        state.captureAndSendScreen(1); //정리 모드
      }
    // if (command.contains('전송') && widget.onSend != null && state != null) {
    //   await _speak("분석을 시작할게요");
    //   await widget.onSend!();
    } else if (command.contains('명령어') ||
        command.contains("음성 명령어")) {
      await _speak("지금 사용할 수 있는 명령어는 전송. 입니다.");
    } else if (command.contains('설명') ||
        command.contains("소리 눈") ||
        command.contains("소리눈") ||
        command.contains("우리는") ||
        command.contains("우리눈") ||
        command.contains("우리 눈")) {
      await _speak(
          "지금은 문서나 라벨을 인식하는 페이지입니다. 전송. 이라고 말하면 화면에 보이는 문서 또는 라벨의 문자를 캡처하여 요약해드려요.");
    } else if (command.contains('홈') || command.contains('메인')) {
      await _speak("메인 화면으로 이동할게요");
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserHomeScreen()),
        );
      }
    } else if (command.contains('뒤로') || command.contains('이전')) {
      await _speak("이전 화면으로 돌아갈게요");
      if (context.mounted) Navigator.pop(context);
    } else {
      final replies = [
        "다시 말씀해 주세요.",
        "잘 못 들었어요.",
        "명령을 인식하지 못했어요.",
      ];
      await _speak(replies[Random().nextInt(replies.length)]);
    }

    setState(() {
      _showVoice = false;
      _showVoiceOut = true;
    });
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
                _lastCommand = '';
                _showVoiceOut = false;

                setState(() {
                  _showVoice = true;
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
    _speech.stop();
    _tts.stop();
    _commandQueue.clear();
    super.dispose();
  }
}
