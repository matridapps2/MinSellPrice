import 'package:flutter/material.dart';

class WebResponsiveCheck {
  WebResponsiveCheck._();

  static bool isSmallScreen(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return size.width <= 800;
  }

  static bool isMediumScreen(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return size.width > 800 && size.width <= 1200;
  }

  static bool isLargeScreen(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return size.width > 1200 && size.width <= 1600;
  }
}
