import 'package:flutter/material.dart';
import 'package:minsellprice/utils/toast_messages/toast_utils.dart';

class CommonToasts {
  CommonToasts._();

  static centeredMobile({
    required String msg,
    required BuildContext context,
  }) {
    return ToastUtils.cherryToast1500MS(msg: msg, context: context);
  }

  static bottomMobile({
    required String message,
    required BuildContext context,
  }) {
    return ToastUtils.mobileToast1500MSBottom(
        message: message, context: context);
  }
}
