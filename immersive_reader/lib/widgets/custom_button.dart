// lib/widgets/custom_button.dart

import 'package:flutter/material.dart';
import 'package:immersive_reader/styles/styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,  // Use backgroundColor instead of primary
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        textStyle: const TextStyle(fontSize: 18.0),
      ),
      child: Text(text, style: bodyTextStyle),  // Use global text style
    );
  }
}
