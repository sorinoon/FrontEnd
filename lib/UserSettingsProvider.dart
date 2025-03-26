import 'package:flutter/material.dart';

class UserSettingsProvider with ChangeNotifier {
  double _fontSizeOffset = 0; // 글자 크기 오프셋
  bool _isFontSizeIncreased = false; // 토글 상태

  double get fontSizeOffset => _fontSizeOffset;
  bool get isFontSizeIncreased => _isFontSizeIncreased;

  void toggleFontSize(bool isIncreased) {
    _isFontSizeIncreased = isIncreased;
    _fontSizeOffset = isIncreased ? 5 : 0; // 글자 크기 조정
    notifyListeners(); // 상태 변경 알림
  }
}