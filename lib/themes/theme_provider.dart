import 'package:flutter/material.dart';
import 'light_mode.dart';
import 'dark_mode.dart';

class ThemeProvider extends ChangeNotifier {
  //initially light mode
  ThemeData _themeData = lightMode;

  // get current theme
  ThemeData get themeData => _themeData;

  //is currently dark mode
  bool get isDarkMode => _themeData == darkMode;

  // set theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  // toggle theme
  // timestamp 3:19 if this doesn't work
  void toggleTheme() {
    if (isDarkMode) {
      themeData = lightMode;
    } else {
      themeData = darkMode;
    }
  }
}
