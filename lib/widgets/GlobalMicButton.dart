import 'package:flutter/material.dart';

class GlobalMicButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GlobalMicButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 24,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 110,
          height: 110,
          child: Image.asset(
            'assets/images/micBtn.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
