import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

import 'package:shoppingmegamart/utils/toast_messages/cherry_toast/cherry_toast.dart';
import 'package:shoppingmegamart/utils/toast_messages/cherry_toast/arrays.dart' as array;


class ToastUtils {
  ToastUtils._();

  static Color toastBackGroundColor = Color.fromARGB(255, 76, 76, 76);
  static Color appColor =Color.fromARGB(255, 237, 63, 69);

  static mobileToast1500MSCenter({
    required String message,
    required BuildContext context,
  }) {
    MotionToast(
      description: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      primaryColor: toastBackGroundColor,
      constraints: const BoxConstraints(
        minHeight: 50,
        minWidth: 50,
        maxHeight: double.infinity,
        maxWidth: double.infinity,
      ),
      toastDuration: const Duration(milliseconds: 1500),
      toastAlignment: Alignment.center,
      borderRadius: 14,
      displaySideBar: false,
    ).show(context);
  }

  static mobileToast1500MSBottom({
    required String message,
    required BuildContext context,
  }) {
    MotionToast(
      description: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      primaryColor: toastBackGroundColor,
      constraints: const BoxConstraints(
        minHeight: 50,
        minWidth: 50,
        maxHeight: double.infinity,
        maxWidth: double.infinity,
      ),
      toastDuration: const Duration(milliseconds: 1500),
      toastAlignment: Alignment.bottomCenter,
      borderRadius: 14,
      displaySideBar: false,
    ).show(context);
  }

  static webToast3Sec({
    required String message,
    required BuildContext context,
  }) {
    MotionToast(
      description: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      primaryColor: toastBackGroundColor,
      constraints: const BoxConstraints(
        minHeight: 50,
        minWidth: 50,
        maxHeight: double.infinity,
        maxWidth: double.infinity,
      ),
      toastDuration: const Duration(seconds: 3),
      toastAlignment: Alignment.center,
      borderRadius: 14,
      displaySideBar: false,
    ).show(context);
  }

  static webToast1500MS({
    required String message,
    required BuildContext context,
  }) {
    MotionToast(
      description: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      primaryColor: toastBackGroundColor,
      constraints: const BoxConstraints(
        minHeight: 50,
        minWidth: 50,
        maxHeight: double.infinity,
        maxWidth: double.infinity,
      ),
      toastDuration: const Duration(milliseconds: 1500),
      toastAlignment: Alignment.center,
      borderRadius: 14,
      displaySideBar: false,
    ).show(context);
  }

  static webToast1Sec({
    required String message,
    required BuildContext context,
  }) {
    MotionToast(
      description: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      primaryColor: toastBackGroundColor,
      constraints: const BoxConstraints(
        minHeight: 50,
        minWidth: 50,
        maxHeight: double.infinity,
        maxWidth: double.infinity,
      ),
      toastDuration: const Duration(seconds: 1),
      toastAlignment: Alignment.center,
      borderRadius: 14,
      displaySideBar: false,
    ).show(context);
  }

  static webToast500MS({
    required String message,
    required BuildContext context,
  }) {
    MotionToast(
      description: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      primaryColor: toastBackGroundColor,
      constraints: const BoxConstraints(
        minHeight: 50,
        minWidth: 50,
        maxHeight: double.infinity,
        maxWidth: double.infinity,
      ),
      toastDuration: const Duration(milliseconds: 500),
      toastAlignment: Alignment.center,
      borderRadius: 14,
      displaySideBar: false,
    ).show(context);
  }

  // ###################### NEW CHERRY TOAST ADDED ON 6.3.24 ##################//

  static cherryToast1500MS({
    required String msg,
    required BuildContext context,
  }) {
    return CherryToast(
      icon: Icons.message,
      themeColor: appColor,
      backgroundColor: toastBackGroundColor,
      description: Text(
        modifyMsg(msg),
        style: const TextStyle(
          fontFamily: 'RobotoMono',
          color: Colors.white,
        ),
      ),
      toastPosition: array.Position.center,
      toastDuration: const Duration(milliseconds: 1500),
      displayCloseButton: false,
      borderRadius: 14,
      displayIcon: false,
      constraints: const BoxConstraints(
        minHeight: 50,
        minWidth: 50,
        maxHeight: double.infinity,
        maxWidth: double.infinity,
      ),
      disableToastAnimation: true,
    ).show(context);
  }

  static String modifyMsg(String input) {
    if (input.length >= 26) {
      return input;
    } else {
      String padding = '';
      int padLength = ((26 - input.length) / 2).ceil();
      for (int i = 0; i < padLength; i++) {
        padding = '$padding ';
      }
      return '$padding$input$padding';
    }
  }
}
