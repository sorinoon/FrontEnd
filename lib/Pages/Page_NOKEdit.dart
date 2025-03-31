import 'package:flutter/material.dart';

class PageNokEdit extends StatelessWidget {
  const PageNokEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("보호자 수정/삭제")),
      body: const Center(
        child: Text("보호자 수정 및 삭제 페이지"),
      ),
    );
  }
}