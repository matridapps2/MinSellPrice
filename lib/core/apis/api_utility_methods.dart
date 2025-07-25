import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minsellprice/core/utils/constants/base_url.dart';
import 'package:minsellprice/core/utils/device_and_resolution_checkers/device_check.dart';
import 'package:minsellprice/core/utils/toast_messages/common_toasts.dart';
import 'package:validators/validators.dart';
import 'package:logger/logger.dart';


void logsChooser(BuildContext c, String uri) {
  DeviceCheck.isDesktop(c) ? Logger().d(uri) : log(uri);
}

Future<http.Response> getM(String u, Map<String, String>? h) async {
  return await http.get(Uri.parse(u), headers: h);
}

Future<http.Response> postM(String u, Object? b, Map<String, String>? h) async {
  return await http.post(Uri.parse(u), body: b, headers: h);
}

Duration timeoutDuration(int sec) {
  return Duration(seconds: sec);
}

FutureOr<http.Response> onTimeEnd() {
  return http.Response('ERR_CONNECTION_TIMED_OUT', 408);
}

String onExceptionFreeResponse({
  required String jsonString,
  required int statusCode,
  required BuildContext context,
}) {
  //------------------------ TOP LEVEL CASES HANDLERS ------------------------//
  log('Status Code >>---> $statusCode');
  // RESPONSE VALUE INDEPENDENT AND STATUS CODE DEPENDENT: TIME OUT CASE
  bool topLevelCase1 = (statusCode == 408);
  // RESPONSE VALUE DEPENDENT: RESPONSE IS IN JSON
  bool topLevelCase2 = (isJSON(jsonString));
  // RESPONSE VALUE DEPENDENT: RESPONSE IS NOT IN JSON
  bool topLevelCase3 = !topLevelCase2;
  String toReturn = '';
  //------------------- CASE #1 ------------- TimeOut ------------------------//
  if (topLevelCase1) {
    // [Error Case 1] : [TimeOut]
    String msg = kTimeOut;
    CommonToasts.centeredMobile(msg: msg, context: context);
    toReturn = kCase01 + msg;
  }
  //------------------- CASE #2 ------------ Valid JSON 200 ------------------//
  else if (topLevelCase2) {
    if (statusCode == 200) {
      // [Success Case 1] : [200 JSON Format Success Response]
      log('RESPONSE >>---> ${jsonDecode(jsonString)}');
      // API SPECIFIC TOAST, CAN'T BE GENERALIZED.
      toReturn = kCase02 + jsonString;
    }
    //----------------- CASE #3 ------------ Valid JSON 201 ------------------//
    else if (statusCode == 201) {
      // [Success Case 2] : [201 JSON Format Success Response]
      log('RESPONSE >>---> ${jsonDecode(jsonString)}');
      // API SPECIFIC TOAST, CAN'T BE GENERALIZED.
      toReturn = kCase03 + jsonString;
    }
    //----------------- CASE #4 ------------ Error Key (Non-200) -------------//
    else if (jsonDecode(jsonString).containsKey(kErrorKey1) ||
        jsonDecode(jsonString).containsKey(kErrorKey2)) {
      // [Error Case 2] : [Contains kErrorKey1 or kErrorKey2]
      log('ERROR RESPONSE >>---> unshipped ${jsonDecode(jsonString)}');
      String msg = '';
      if (jsonDecode(jsonString).containsKey(kErrorKey1)) {
        msg = jsonDecode(jsonString)[kErrorKey1].toString();
      } else if (jsonDecode(jsonString).containsKey(kErrorKey2)) {
        msg = jsonDecode(jsonString)[kErrorKey2].toString();
      }
      CommonToasts.centeredMobile(msg: msg, context: context);
      toReturn = kCase04 + msg;
    }
    //----------------- CASE #5 ------------- Message Key (Non-200) ----------//
    else if (jsonDecode(jsonString).containsKey(kMessageKey1) ||
        jsonDecode(jsonString).containsKey(kMessageKey2)) {
      // [Error Case 3] : [Contains kMessageKey1 or kMessageKey2]
      log('ERROR RESPONSE >>---> 2 ${jsonDecode(jsonString)}');
      String msg = '';
      if (jsonDecode(jsonString).containsKey(kMessageKey1)) {
        msg = jsonDecode(jsonString)[kMessageKey1].toString();
      } else if (jsonDecode(jsonString).containsKey(kMessageKey2)) {
        msg = jsonDecode(jsonString)[kMessageKey2].toString();
      }
      CommonToasts.centeredMobile(msg: msg, context: context);
      toReturn = kCase05 + msg;
    }
    //----------------- CASE #6 --------------- Unknown (Non-200) ------------//
    else {
      // [Error Case 4] : [Unknown Error]
      log('ERROR RESPONSE >>--->3 ${jsonDecode(jsonString)}');
      String msg = kErrorString;
      CommonToasts.centeredMobile(msg: msg, context: context);
      toReturn = kCase06 + msg;
    }
  }
  //------------------- CASE #7 ---------------- Empty Success 200 -----------//
  else if (topLevelCase3) {
    if (jsonString.isEmpty && statusCode == 200) {
      // [Success Case 3] : [Empty Success Response 200]
      log('RESPONSE >>---> $kSuccessCase3');
      // API SPECIFIC TOAST, CAN'T BE GENERALIZED.
      toReturn = kCase07;
    }
    //----------------- CASE #8 ---------------- Empty Success 201 -----------//
    else if (jsonString.isEmpty && statusCode == 201) {
      // [Success Case 4] : [Empty Success Response 201]
      log('RESPONSE >>---> $kSuccessCase4');
      // API SPECIFIC TOAST, CAN'T BE GENERALIZED.
      toReturn = kCase08;
    }
    //----------------- CASE #9 --------- Non-JSON and Non-HTML Success 200 --//
    else if (isNotHTML(jsonString) && statusCode == 200) {
      // [Success Case 5] : [200 Success Response in Non-JSON and Non-HTML]
      log('RESPONSE >>---> $jsonString');
      String msg = jsonString;
      CommonToasts.centeredMobile(msg: msg, context: context);
      toReturn = kCase09 + msg;
    }
    //----------------- CASE #10 -------- Non-JSON and Non-HTML Success 201 --//
    else if (isNotHTML(jsonString) && statusCode == 201) {
      // [Success Case 6] : [201 Success Response in Non-JSON and Non-HTML]
      log('RESPONSE >>---> $jsonString');
      String msg = jsonString;
      CommonToasts.centeredMobile(msg: msg, context: context);
      toReturn = kCase10 + msg;
    }
    //----------------- CASE #11 ------ Non-JSON and Non-HTML Unauthorized ---//
    else if (jsonString == kUnauthorized && statusCode == 401) {
      // [Error Case 5] : [Unauthorized Response in String Format, not in JSON]
      log('ERROR RESPONSE >>--->4 $jsonString');
      String msg = jsonString;
      CommonToasts.centeredMobile(msg: msg, context: context);
      toReturn = kCase11 + msg;
    }
    //----------------- CASE #12 ------------- Unknown Non-JSON --------------//
    else {
      // [Error Case 6] : [Response is not in JSON Format]
      String msg = kNotValidJson;
      CommonToasts.centeredMobile(msg: msg, context: context);
      toReturn = kCase12 + msg;
    }
  }
  return toReturn;
}

String onExceptionResponse({
  required BuildContext context,
  required String exception,
}) {
  //----------------- CASE #13 ----- [Error Case 7] : [Exception Occurred]----//
  logsChooser(context, 'EXCEPTION >>---> $exception');
  String msg = xmlChecker(exception);
  CommonToasts.centeredMobile(msg: msg, context: context);
  return kCase13 + kErException;
}

String xmlChecker(String error) {
  return (error == kXMLError)
      ? kXMLError.replaceAll('.', '') + kNotValidJson.replaceFirst('Error', '')
      : error;
}

bool isNotHTML(String str) {
  final RegExp htmlRegExp = RegExp(
    '<[^>]*>',
    multiLine: true,
    caseSensitive: false,
  );
  return !(htmlRegExp.hasMatch(str));
}