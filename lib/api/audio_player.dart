import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

final AudioPlayer _audioPlayer = AudioPlayer(); // 클래스 밖에 선언해도 OK

void connectWebSocket() {
  try {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://223.194.139.101:8000/ws/yolo/'),
    );

    _channel!.stream.listen(
          (message) async {
        final data = jsonDecode(message);

        // 안내 문구 출력
        if (data['warning'] != null) {
          setState(() {
            _yoloResultText = data['warning'];
          });
        }

        // 👉 base64 mp3가 오면 재생 처리
        if (data['tts_audio'] != null) {
          final base64Audio = data['tts_audio'];
          await _playBase64Mp3(base64Audio);
        }

      },
      onError: (error) {
        print('WebSocket 오류: $error');
      },
      onDone: () {
        print('WebSocket 연결 종료됨');
      },
    );
  } catch (e) {
    print('WebSocket 연결 중 오류 발생: $e');
  }
}

// ✅ base64 mp3 디코딩 후 재생 함수
Future<void> _playBase64Mp3(String base64Audio) async {
  try {
    // 1. base64 → bytes
    Uint8List bytes = base64Decode(base64Audio);

    // 2. 임시 파일로 저장
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/tts_audio.mp3');
    await file.writeAsBytes(bytes);

    // 3. 재생
    await _audioPlayer.setFilePath(file.path);
    await _audioPlayer.play();
  } catch (e) {
    print('오디오 재생 오류: $e');
  }
}
