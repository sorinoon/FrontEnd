import 'package:flutter/material.dart';

class LoginModeProvider with ChangeNotifier {
  bool _isProtectorMode = false; // 기본값: 사용자 모드

  bool get isProtectorMode => _isProtectorMode;

  void toggleMode(bool value) {
    _isProtectorMode = value;
    notifyListeners();
  }
}