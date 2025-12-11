import 'dart:developer';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

class NotificationPermissionService {

  static final NotificationPermissionService _instance = NotificationPermissionService._internal();

  factory NotificationPermissionService() => _instance;

  NotificationPermissionService._internal();

  static const String _permissionRequestedKey = 'notification_permission_requested';

  Future<bool> hasPermissionBeenRequested() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionRequestedKey) ?? false;
  }

  Future<bool> isPermissionGranted() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    }
    return true;
  }

  Future<void> markPermissionAsRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionRequestedKey, true);
  }

  Future<bool> requestNotificationPermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        log('Notification permission status: $status');
        return status.isGranted;
      }
      return true;
    } catch (e) {
      log('Error requesting notification permission: $e');
      return false;
    }
  }

  Future<bool> checkAndRequestPermission() async {
    try {
      log('Checking notification permission...');

      // Check current permission status first
      final currentStatus = await Permission.notification.status;
      log('Current notification permission status: $currentStatus');

      final hasBeenRequested = await hasPermissionBeenRequested();
      log('Has permission been requested before: $hasBeenRequested');

      if (hasBeenRequested) {
        log('Permission was requested before, checking current status');
        return await isPermissionGranted();
      }

      // Check if we're on Android 13+ where POST_NOTIFICATIONS is required
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        log('Android SDK version: $sdkInt');

        if (sdkInt >= 33) {
          log('Android 13+ detected, requesting POST_NOTIFICATIONS permission');
          final granted = await requestNotificationPermission();
          await markPermissionAsRequested();
          return granted;
        } else {
          log('Android version < 13, notification permission not required');
          await markPermissionAsRequested();
          return true;
        }
      }

      await markPermissionAsRequested();
      return true;
    } catch (e) {
      log('Error in checkAndRequestPermission: $e');
      return false;
    }
  }

  // Reset permission status for testing
  Future<void> resetPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_permissionRequestedKey);
    log('Permission status reset for testing');
  }
}
