import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import '../Pages/User_SettingsProvider.dart';

class TmapMicButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Future<bool> Function(String command, FlutterTts tts, BuildContext context)? customCommandHandler;

  const TmapMicButton({
    super.key,
    required this.onPressed,
    this.customCommandHandler,
  });

  @override
  State<TmapMicButton> createState() => _TmapMicButtonState();
}

class _TmapMicButtonState extends State<TmapMicButton> {
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

    print("⚙️ 처리 중 (TmapMicButton): $command");

    bool handled = false;

    if (widget.customCommandHandler != null) {
      handled = await widget.customCommandHandler!(command, _flutterTts, context);
    }

    if (!handled) {
      final fallback = [
        "무슨 말씀인지 다시 한번 말씀해 주세요",
        "죄송해요. 이해하지 못했어요",
        "한 번 더 말씀해 주시겠어요?",
      ];
      await _speak(fallback[Random().nextInt(fallback.length)]);
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
    _speech.stop();
    _flutterTts.stop();
    _commandQueue.clear();
    _shouldContinueListening = false;
    _isListening = false;
    _isProcessing = false;
    super.dispose();
  }
}
