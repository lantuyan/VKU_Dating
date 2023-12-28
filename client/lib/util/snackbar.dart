import 'package:flutter/material.dart';

class CustomSnackbar {
  static snackbar(String text, BuildContext context) {
    final snackBar = SnackBar(
      content: Text('$text '),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    );
    // ignore: deprecated_member_use
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
