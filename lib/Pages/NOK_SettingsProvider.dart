import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NOKSettingsProvider with ChangeNotifier {
  double _fontSizeOffset = 0;
  bool _isFontSizeIncreased = false;
  bool _isVibrationEnabled = false;

  // ✅ 사용자 메모 상태 관리
  final List<String> _userNotes = [
    '사용자 특징 또는 메모',
    '사용자 특징 또는 메모',
    '사용자 특징 또는 메모',
    '사용자 특징 또는 메모',
  ];

  double get fontSizeOffset => _fontSizeOffset;
  bool get isFontSizeIncreased => _isFontSizeIncreased;
  bool get isVibrationEnabled => _isVibrationEnabled;

  // ✅ 메모 getter
  List<String> get userNotes => _userNotes;

  // ✅ 메모 업데이트 함수
  void updateNoteAt(int index, String newNote) {
    if (index >= 0 && index < _userNotes.length) {
      _userNotes[index] = newNote;
      notifyListeners();
    }
  }

  void toggleFontSize(bool isIncreased) {
    _isFontSizeIncreased = isIncreased;
    _fontSizeOffset = isIncreased ? 5 : 0;
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
