import 'package:ally_4_u_client/util/color.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ThemeData light = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: primaryColor,
  fontFamily: 'Poppins',
  appBarTheme: AppBarTheme(
    color: primaryColor,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
  ),
);

ThemeData dark = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xffff3a5a),
  appBarTheme: const AppBarTheme(backgroundColor: Color(0xffff3a5a)),
  scaffoldBackgroundColor: const Color(0xff1f1f1f),
  fontFamily: 'Poppins',
);

class ThemeNotifier extends ChangeNotifier {
  final String key = "theme";
  SharedPreferences? _preferences;
  bool darkTheme = true;

  // ignore: unused_element
  bool get _darkTheme => darkTheme;

  ThemeNotifier() {
    darkTheme = true;
    loadPreferences();
  }

  toggleTheme() {
    darkTheme = !darkTheme;
    saveToPref();
    notifyListeners();
  }

  _initPrefes() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  loadPreferences() async {
    await _initPrefes();
    darkTheme = _preferences?.getBool(key) ?? true;
    notifyListeners();
  }

  saveToPref() async {
    await _initPrefes();
    _preferences?.setBool(key, darkTheme);
  }
}
