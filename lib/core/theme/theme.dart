import 'package:employee_scheduler/core/theme/app_palette.dart';
import 'package:flutter/material.dart';

class AppTheme{
  static final _border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AppPallete.borderColor,
          width: 3,
        )
      );
  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.all(27),
      enabledBorder: _border,
      focusedBorder: _border,
    ),
  );
}