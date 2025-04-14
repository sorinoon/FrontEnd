import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Pages/User_SettingsProvider.dart';
import '../Pages/NOK_SettingsProvider.dart';
import '../Pages/LoginModeProvider.dart';

class GlobalEditButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GlobalEditButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 48,
      right: 43,
      child: GestureDetector(
        onTap: () {
          onPressed();
          final isProtectorMode = Provider.of<LoginModeProvider>(context, listen: false).isProtectorMode;

          if (isProtectorMode) {
            Provider.of<NOKSettingsProvider>(context, listen: false).vibrate();
          } else {
            Provider.of<UserSettingsProvider>(context, listen: false).vibrate();
          }
        },
        child: Container(
          width: 69,
          height: 69,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: const Icon(Icons.edit, size: 36),
        ),
      ),
    );
  }
}
