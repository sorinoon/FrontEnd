import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lottie/lottie.dart';
import '../Pages/User_SettingsProvider.dart';

class SettingMicButton extends StatefulWidget {
  final VoidCallback onPressed;

  const SettingMicButton({super.key, required this.onPressed});

  @override
  State<SettingMicButton> createState() => _SettingMicButtonState();
}

class _SettingMicButtonState extends State<SettingMicButton> {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
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
    final settings = Provider.of<UserSettingsProvider>(context, listen: false);

    if (command.contains("진동")) {
      settings.toggleVibration(!settings.isVibrationEnabled);
      await _speak("진동 모드를 ${settings.isVibrationEnabled ? '켜' : '꺼'}겠습니다");
    } else if (command.contains("저전력")) {
      settings.toggleLowPowerMode(!settings.isLowPowerModeEnabled);
      await _speak("저전력 모드를 ${settings.isLowPowerModeEnabled ? '켜' : '꺼'}겠습니다");
    } else if (command.contains("글자")) {
      settings.toggleFontSize(!settings.isFontSizeIncreased);
      await _speak("글자 크기를 ${settings.isFontSizeIncreased ? '크게' : '작게'} 설정했습니다");
    } else if (command.contains("소리 눈") || command.contains("소리눈") || command.contains("우리는")) {
      await _speak("이 페이지는 진동 모드, 저전력 모드, 글자 크기 설정이 가능합니다. 각 기능명을 말하면 토글할 수 있습니다.");
    } else if (command.contains("명령어")) {
      await _speak("사용 가능한 명령어는 진동 모드, 저전력 모드, 글자 크기 키우기, 소리눈, 명령어 입니다.");
    } else {
      await _speak("죄송해요. 무슨 말인지 이해하지 못했어요.");
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
              child: Lottie.asset('assets/lottie/Voice.json', width: 200),
            ),
          if (_showVoiceOut)
            Positioned(
              bottom: -70,
              left: -22,
              child: Lottie.asset('assets/lottie/VoiceOut.json', width: 200),
            ),
          Positioned(
            bottom: -26,
            left: 24,
            child: GestureDetector(
              onTap: () async {
                widget.onPressed();
                Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
                _lastCommand = '';
                _showVoiceOut = false;
                await _speak("부르셨나요?");
                await _startListening();
              },
              child: SizedBox(
                width: 110,
                height: 110,
                child: Image.asset('assets/images/micBtn.png', fit: BoxFit.contain),
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
    super.dispose();
  }
}
