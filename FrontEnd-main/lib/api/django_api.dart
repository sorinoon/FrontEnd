class DjangoAPI {
  final String baseUrl = 'http://222.232.154.128:8000';
  WebSocketChannel? _channel;

  // WebSocket 연결 및 수신
  void connectWebSocket(Function(Map<String, dynamic>) onMessage) {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://222.232.154.128:8000/ws/yolo/detect/'),
      );

      _channel!.stream.listen(
            (message) {
          final data = jsonDecode(message);
          onMessage(data); // 콜백으로 외부에서 결과 처리 가능
        },
        onError: (error) {
          print('WebSocket 오류: $error');
        },
        onDone: () {
          print('WebSocket 연결 종료');
        },
      );
    } catch (e) {
      print('WebSocket 연결 중 오류 발생: $e');
    }
  }

  // WebSocket 연결 종료
  void disconnectWebSocket() {
    if (_channel != null) {
      _channel?.sink.close(status.goingAway);
      print('WebSocket 연결 종료');
    }
  }

  // Django로 이미지 전송
  Future<void> detectObjects(String imagePath) async {
    try {
      var uri = Uri.parse('$baseUrl/api/yolo/detect/');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('image', imagePath));

      var response = await request.send();
      if (response.statusCode == 202) {
        print('YOLO 감지 요청 성공');
      } else {
        print('YOLO 감지 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('YOLO 감지 중 오류: $e');
    }
  }
}
