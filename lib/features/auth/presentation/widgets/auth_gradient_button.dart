import 'package:flutter/material.dart';

class AuthGradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  const AuthGradientButton({super.key,required this.onPressed, required String text, required bool isLoading});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, 
      child: Text('Continue'),
    );
  }
}