import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProtectorSettingsProvider with ChangeNotifier {
  double _fontSizeOffset = 0; // 글자 크기 오프셋
  bool _isFontSizeIncreased = false; // 글자 크기 키우기 토글 상태
  bool _isVibrationEnabled = false; // 진동 모드 상태

  double get fontSizeOffset => _fontSizeOffset;
  bool get isFontSizeIncreased => _isFontSizeIncreased;
  bool get isVibrationEnabled => _isVibrationEnabled;

  void toggleFontSize(bool isIncreased) {
    _isFontSizeIncreased = isIncreased;
    _fontSizeOffset = isIncreased ? 5 : 0; // 글자 크기 조정
    notifyListeners();
  }

  void toggleVibration(bool isEnabled) {
    _isVibrationEnabled = isEnabled;
    notifyListeners();
  }

  void vibrate() {
    if (_isVibrationEnabled) {
      HapticFeedback.mediumImpact();
      print('진동 보호자');
    }
  }

}
