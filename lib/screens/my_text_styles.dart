import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoppingmegamart/size.dart';

class MyTextStyle {
  MyTextStyle._();

  // final size = ScreenUtils.init(context: context)

  static TextStyle titleStyle() {
    return const TextStyle(
      letterSpacing: 1,
      wordSpacing: 1,
      fontSize: 23,
      color: Colors.black,
      fontWeight: FontWeight.w800,
    );
  }

  static TextStyle customTitleStyle() {
    return GoogleFonts.montserrat(
      letterSpacing: 1,
      wordSpacing: 2,
      fontSize: 24,
      color: Colors.black,
      fontWeight: FontWeight.w800,
    );
  }

  static TextStyle subTitleStyle() => GoogleFonts.montserrat(
        letterSpacing: 1,
        wordSpacing: 2,
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.w800,
      );

  // static TextStyle questionTextStyle() => TextStyle(
  //     letterSpacing: 1,
  //     wordSpacing: 2,
  //     fontSize: 20,
  //     color: myAppColor[10],
  //     fontWeight: FontWeight.w900,
  //     fontStyle: FontStyle.italic,
  //     decoration: TextDecoration.underline);

  static TextStyle resultTitleStyle() => const TextStyle(
        letterSpacing: 1,
        wordSpacing: 1,
        fontSize: 19,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      );

  static TextStyle simpleStyle() => const TextStyle(
        // letterSpacing: 1,
        wordSpacing: 2,
        fontSize: 8,
        fontWeight: FontWeight.w500,
        color: Colors.black,
        // fontWeight: FontWeight.w700,
      );

  static TextStyle simpleStyle2() => TextStyle(
        // letterSpacing: 1,
        wordSpacing: 2,
        fontSize: 0.035 * w,
        fontWeight: FontWeight.w500,
        color: Colors.black,
        // fontWeight: FontWeight.w700,
      );

  static TextStyle simpleUnderlineStyle() => const TextStyle(
        letterSpacing: .5,
        wordSpacing: 1,
        fontSize: 12,
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        decoration: TextDecoration.underline,
      );

  static TextStyle simpleBoldStyle() => const TextStyle(
        letterSpacing: .5,
        wordSpacing: 1,
        fontSize: 13,
        color: Colors.black,
        fontWeight: FontWeight.w900,
      );

  // static TextStyle urlStyle() => TextStyle(
  //   fontSize: 12.5,
  //   color: myAppColor[10],
  //   fontWeight: FontWeight.bold,
  // );
  static TextStyle customProductUrlStyle() => GoogleFonts.montserrat(
        fontSize: 0.043 * w,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      );

  static TextStyle customAmazonTitleStyle() => const TextStyle(
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      );

  // static TextStyle customAmazonBigTitleStyle() => TextStyle(
  //   fontSize: 28,
  //   color: myAppColor[10],
  //   fontWeight: FontWeight.bold,
  // );

  static TextStyle customAmazonSubtitleStyle() => const TextStyle(
        fontSize: 12,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      );

  static TextStyle nextBtnStyle() => const TextStyle(
        color: Colors.black,
        fontSize: 15,
      );

  static TextStyle simpleDateStyle() => const TextStyle(
        fontSize: 10,
        color: Colors.black,
      );

  static TextStyle customProductListNameStyle() => GoogleFonts.montserrat(
        letterSpacing: .4,
        wordSpacing: 1,
        fontSize: 0.045 * w,
        color: Colors.black,
        fontWeight: FontWeight.w800,
      );

  static TextStyle customProductListNameStyle1() => GoogleFonts.montserrat(
        letterSpacing: .4,
        wordSpacing: 1,
        fontSize: 0.035 * w,
        color: Colors.black,
        fontWeight: FontWeight.w800,
      );

  static TextStyle customProductSubtitleStyle() => const TextStyle(
        fontSize: 12,
        color: Colors.black,
      );
}
