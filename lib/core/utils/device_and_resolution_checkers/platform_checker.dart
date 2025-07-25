import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformChecker {
  PlatformChecker._();

  static bool isAndroid(BuildContext context) {
    return defaultTargetPlatform == TargetPlatform.android;
  }

  static bool isiOS(BuildContext context) {
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool isWeb(BuildContext context) {
    return kIsWeb;
  }
}
