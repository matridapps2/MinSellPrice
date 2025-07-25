import 'package:flutter/material.dart';
import 'package:minsellprice/core/utils/device_and_resolution_checkers/platform_checker.dart';

class DeviceCheck {
  DeviceCheck._();

  static bool isDesktop(BuildContext c) {
    return PlatformChecker.isWeb(c) &&
        !(PlatformChecker.isAndroid(c) || PlatformChecker.isiOS(c));
  }

  static bool isDesktopUpToFHD(BuildContext c, Size size) {
    bool isUpToFHD = size.width <= 1600;
    return PlatformChecker.isWeb(c) &&
        !(PlatformChecker.isAndroid(c) || PlatformChecker.isiOS(c)) &&
        isUpToFHD;
  }

  static bool isDesktopAboveFHD(BuildContext c, Size size) {
    bool isAboveFHD = size.width > 1600;
    return PlatformChecker.isWeb(c) &&
        !(PlatformChecker.isAndroid(c) || PlatformChecker.isiOS(c)) &&
        isAboveFHD;
  }

  static bool isMobileBrowser(BuildContext c) {
    return PlatformChecker.isWeb(c) &&
        (PlatformChecker.isAndroid(c) || PlatformChecker.isiOS(c));
  }

  static bool isMobileApp(BuildContext c) {
    return !(PlatformChecker.isWeb(c)) &&
        (PlatformChecker.isAndroid(c) || PlatformChecker.isiOS(c));
  }
}
