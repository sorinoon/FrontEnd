import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReturnPopup extends StatefulWidget {
  final VoidCallback onTap;

  const ReturnPopup({super.key, required this.onTap});

  @override
  State<ReturnPopup> createState() => _ReturnPopupState();
}

class _ReturnPopupState extends State<ReturnPopup> {
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _autoCloseTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _autoCloseTimer?.cancel();
        Navigator.of(context).pop(); // 팝업 닫기
        widget.onTap(); // 원하는 동작 실행
      },
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: CupertinoPopupSurface(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: 360,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "길찾기로 돌아가기",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "화면을 터치하여 경로 안내 페이지로 이동합니다.",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "15초간 화면 터치를 안할 시 이어서 안내합니다.",
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
