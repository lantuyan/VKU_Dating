import 'package:flutter/material.dart';

class Utils {



  
  static double responsiveWidth({
    required BuildContext context,
    required dynamic width,
  }) {
    var totalWidth = MediaQuery.of(context).size.width;
    var calculatedWidth = (width / 100) * totalWidth;
    return calculatedWidth;
  }

  static double responsiveHeight({
    required BuildContext context,
    required dynamic height,
  }) {
    var totalHeight = MediaQuery.of(context).size.height;
    var calculatedHeight = (height / 100) * totalHeight;
    return calculatedHeight;
  }

  static unFocus(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static Widget divider({
    Color? color,
    double? height,
    double? thickness,
  }) {
    return Divider(
      thickness: thickness ?? 0.3,
      color: Colors.white,
    );
    
  }
}
 