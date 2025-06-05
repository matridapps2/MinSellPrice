import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  PermissionStatus status = await Permission.notification.request();
  if (status.isGranted) {
    // Permission is granted
    Fluttertoast.showToast(msg: 'Permission Granted');
  } else if (status.isDenied) {
    // Permission is denied
    FirebaseMessaging.instance.requestPermission();
  } else if (status.isPermanentlyDenied) {
    // Permission is permanently denied, show the user a dialog to go to app settings
    FirebaseMessaging.instance.requestPermission();
    // Fluttertoast.showToast(
    //     msg:
    //         'Permission Permanently Denied. Go to App settings and allow the permission.');
  }
}
