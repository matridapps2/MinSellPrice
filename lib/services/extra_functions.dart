import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/size.dart';
import 'package:palette_generator/palette_generator.dart';

import '../model/vendor_dashboard_model.dart';

///Color primaryColor = '#d90310'.toColor();
Color searchBoxColor = '#f0eded'.toColor();
final remoteConfig = FirebaseRemoteConfig.instance;
double extractDoubleFromString(String input) {
  // Remove non-numeric characters except for '.' and '-'.
  final cleanedInput = input.replaceAll(RegExp(r'[^0-9.-]'), '');

  // Parse the cleaned string to a double.
  try {
    return double.parse(cleanedInput);
  } catch (e) {
    // Handle parsing errors (e.g., invalid input).
    print('Error parsing double: $e');
    return 0.0; // Return null or handle the error as needed.
  }
}

List<String> getUniqueBrands(List< /*ProductListModel*/ VendorProduct> brands) {
  List<String> uniqueBrands = [];
  List<String> temp = [];

  for (var brand in brands) {
    temp.add(brand.vendorName ?? '');
  }
  uniqueBrands = Set<String>.from(temp).toList();
  return uniqueBrands;
}

Future<void> copyData({required String data}) async {
  await Clipboard.setData(
    ClipboardData(
      text: data,
    ),
  ).then((value) => Fluttertoast.showToast(msg: 'Data Copy'));
}

Future<void> setupRemoteConfig() async {
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));

  await remoteConfig.fetchAndActivate();
}

Future<PaletteGenerator> updatePaletteGenerator(
    {required String imageUrl}) async {
  final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(
    CachedNetworkImageProvider(imageUrl),
  );
  return paletteGenerator;
}

int totalNumberOfCompetitors({
  required String firstVendorPrice,
  required String secondVendorPrice,
  required String thirdVendorPrice,
  required String fourthVendorPrice,
  required String fifthVendorPrice,
}) {
  int first = firstVendorPrice.contains('--') ? 0 : 1;
  int second = secondVendorPrice.contains('--') ? 0 : 1;
  int third = thirdVendorPrice.contains('--') ? 0 : 1;
  int fourth = fourthVendorPrice.contains('--') ? 0 : 1;
  int fifth = fifthVendorPrice.contains('--') ? 0 : 1;
  return first + second + third + fourth + fifth;
}

Future<bool> showExitPopup({required BuildContext context}) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Do you want to exit?",
                    style: GoogleFonts.openSans(
                        color: Colors.black, fontSize: 18)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          exit(0);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white),
                        child: Text("Yes",
                            style: GoogleFonts.openSans(
                                color: Colors.black, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: Text("No",
                          style: GoogleFonts.openSans(
                              color: Colors.black, fontSize: 16)),
                    ))
                  ],
                )
              ],
            ),
          ),
        );
      });
}

String returnRaiseOrLowerString(
    {required String finalPrice, required String rp}) {
  try {
    final finalPRICE = double.parse(finalPrice);
    final rP = double.parse(rp);

    return finalPRICE > rP ? "REDUCE" : 'RAISE';
  } catch (e) {
    return 'RAISE';
  }
}

extension StringExtension on String {
  Map<String, dynamic> toMapConversion() {
    String formattedString = replaceAllMapped(
            RegExp(r'(\w+):'), (match) => '"${match.group(1)}":')
        .replaceAllMapped(RegExp(r':(\w+)'), (match) => ':"${match.group(1)}"')
        .replaceAll('{', '{"')
        .replaceAll(',', ',"')
        .replaceAll(':', '":')
        .replaceAll(' ', '')
        .replaceAll('""', '"')
        .replaceAll(':"', ':');
    return jsonDecode(formattedString);
  }
}

String daysToYearsDays(int days) {
  int years = days ~/ 365;
  int remainingDays = days % 365;

  return '$years Year(s) and $remainingDays Days';
}

double percentageDifference(String currentValue, String recommendedValue) {
  try {
    double currentVal = double.parse(currentValue);
    double recommendedVal = double.parse(recommendedValue);

    if (currentVal == 0) {
      return ((recommendedVal - currentVal) / 1) * 100;
    }
    return ((recommendedVal - currentVal) / currentVal) * 100;
  } catch (e) {
    return 0.0;
  }
}

String getLabelName({required int index}) {
  return index == 0
      ? 'Very Low <15%'.toUpperCase()
      : index == 1
          ? 'Low 5%-15%'.toUpperCase()
          : index == 2
              ? 'Moderate(Low) Upto 5%'.toUpperCase()
              : index == 3
                  ? 'Moderate(High) Upto 5%'.toUpperCase()
                  : index == 4
                      ? 'High 5%-15%'.toUpperCase()
                      : 'Very High >15%';
}

Color returnColorAccordingToValues(
    {required int value, required List<int> orderedList}) {
  int index = orderedList.indexOf(value);

  if (value == 0) {
    return Colors.grey.withOpacity(.6);
  } else {
    switch (index) {
      case 0:
        return Colors.redAccent.withOpacity(.8);
      case 1:
        return Colors.redAccent.withOpacity(.6);
      case 2:
        return Colors.redAccent.withOpacity(.5);
      case 3:
        return Colors.redAccent.withOpacity(.4);
      case 4:
        return Colors.redAccent.withOpacity(.3);
      case 5:
        return Colors.redAccent.withOpacity(.2);
      default:
        return Colors.grey.withOpacity(.6);
    }
  }
}

List<int> returnListInDescOrder({required List<int> unorderedList}) {
  unorderedList.sort((a, b) => b.compareTo(a));
  if (kDebugMode) {
    print(unorderedList);
  }
  return unorderedList;
}

double returnHeightAccordingToValues(
    {required int value, required List<int> orderedList}) {
  int index = orderedList.indexOf(value);

  if (value == 0) {
    return .16 * w;
  } else {
    switch (index) {
      case 0:
        return .16 * w;
      case 1:
        return .16 * w;
      case 2:
        return .16 * w;
      case 3:
        return .16 * w;
      case 4:
        return .16 * w;
      case 5:
        return .16 * w;
      default:
        return .16 * w;
    }
  }
}

int totalProductCount(
    {required int l15,
    required int l515,
    required int l5,
    required int h15,
    required int h515,
    required int h5}) {
  return l5 + l515 + l15 + h5 + h515 + h15;
}

extension ColorExtension on String {
  Color toColor() {
    var hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

final dateFormat = DateFormat("yyyy/MM/dd");

bool checkUpdateDate(List<Today> brands) {
  var now = DateTime.now();
  var formatter = DateFormat('MM-dd-yyyy');
  var today = formatter.format(now);

  for (var brand in brands) {
    for (var history in brand.history) {
      if (history.updateDate == today) {
        return true;
      }
    }
  }
  return false;
}

String returnAppBarTitle({required int index}) {
  switch (index) {
    case 0:
      return "Home";
    case 1:
      return "Liked Products";

    case 2:
      return "Search";
    default:
      return "Untitled";
  }
}

const Map<String, dynamic> defaultMapData = {
  "brand_name": "",
  "brand_key": "",
  "main_image": null,
  "product_id": 0,
  "product_mpn": "",
  "brand_id": 0,
  "product_name": "",
  "product_image": "",
  "gcode": "",
  "msrp": "",
  "isSimilarProductGcode": null,
  "vendor_product_id": 0,
  "vendor_sku": "",
  "secondary_sku": "",
  "atp": null,
  "sales": "",
  "sell_price": "",
  "z3_price": "",
  "map_price": "",
  "vk11": "",
  "moving_average": "",
  "purchase_price": "",
  "sale_atp_ratio": "",
  "amount_invested": "",
  "last_good_receipt": "",
  "weight": "",
  "days": null,
  "msp": "",
  "current_discount": "",
  "gp_percent": "",
  "shipping": "",
  "rule_name": "",
  "current_gp": "",
  "adjusted_price": "",
  "material_group": "",
  "rt": "",
  "rp": "",
  "rp_criteria": "",
  "rp_variation": "",
  "rp_variation_sell_price": "",
  "achieved_gp": "",
  "vendorprice_price": "",
  "vendorprice_finalprice": "",
  "vendorprice_shipping": "",
  "ExtraDiscount": "",
  "vendorprice_date": "",
  "source": "",
  "vendor_pricing_id": null,
  "competitor_count": null,
  "vendorprice_count": null,
  "FirstVendorName": "",
  "FirstVendorBasePrice": "",
  "FirstVendorPrice": "",
  "FirstVendorPriceShipping": "",
  "FirstVendorExtraDiscount": "",
  "FirstVendorUrl": "",
  "SecondVendorName": "",
  "SecondVendorBasePrice": "",
  "SecondVendorPrice": "",
  "SecondVendorPriceShipping": "",
  "SecondVendorExtraDiscount": "",
  "SecondVendorUrl": "",
  "ThirdVendorName": "",
  "ThirdVendorBasePrice": "",
  "ThirdVendorPrice": "",
  "ThirdVendorPriceShipping": "",
  "ThirdVendorExtraDiscount": "",
  "ThirdVendorUrl": "",
  "FourthVendorName": "",
  "FourthVendorBasePrice": "",
  "FourthVendorPrice": "",
  "FourthVendorPriceShipping": "",
  "FourthVendorExtraDiscount": "",
  "FourthVendorUrl": "",
  "FifthVendorName": "",
  "FifthVendorBasePrice": "",
  "FifthVendorPrice": "",
  "FifthVendorPriceShipping": "",
  "FifthVendorExtraDiscount": "",
  "FifthVendorUrl": "",
  "first_vendor_product_id": null,
  "second_vendor_product_id": null,
  "third_vendor_product_id": null,
  "fourth_vendor_product_id": null,
  "fifth_vendor_product_id": null,
  "vendor_name": "",
  "vendor_url": "",
  "FirstVendorPercentage": "",
  "SecondVendorPercentage": ""
};

Map<String, dynamic> quoteKeysAndStrings(Map<String, dynamic> data) {
  final Map<String, dynamic> result = {};
  data.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      result["\"$key\""] = quoteKeysAndStrings(value);
    } else if (value is String) {
      result["\"$key\""] = "\"$value\"";
    } else {
      result[key] = value;
    }
  });
  return result;
}

String keepSingleDollarSign(String input) {
  // Count the occurrences of '$' in the input string
  int dollarSignCount = input.split('\$').length - 1;

  // If there's only one '$', return the original input
  if (dollarSignCount == 1) {
    return input;
  }

  // Otherwise, replace all but the first '$' with an empty string
  return input.replaceAll(RegExp(r'\$+'), '\$');
}

String capitalize(String text) {
  return text.split(' ').map((word) {
    if (word.isNotEmpty) {
      return word[0].toUpperCase() + word.substring(1);
    }
    return '';
  }).join(' ');
}

List<String> filterStrings(List<String> stringValues, List<bool> boolValues) {
  List<String> result = [];
  for (int i = 0; i < stringValues.length; i++) {
    if (boolValues[i]) {
      result.add(stringValues[i]);
    }
  }
  return result;
}

int getIndexInOtherList(String selectedItem, List<String> otherList) {
  return otherList.indexOf(selectedItem);
}

bool isItemPresentInOtherList(
    int index, List<String> currentList, List<String> otherList) {
  if (index >= 0 && index < currentList.length) {
    String currentItem = currentList[index];
    return otherList.contains(currentItem);
  }
  return false; // Return false if index is out of range or currentList is empty
}

// List<int> getBrandIds(
//     List<AllBrandModel> allItems, List<String> selectedHistory) {
//   List<int> result = [];
//   for (var item in allItems) {
//     if (selectedHistory.contains(item.key.toLowerCase())) {
//       result.add(item.brandId);
//     }
//   }
//   return result;
// }

Color returnMainVendorPriceColor(
    {required String rpVendorProductId,
    required List<VendorModel> allCompetitor,
    required String mainVendorProductFinalPrice}) {
  Color color = Colors.black;

  for (VendorModel element in allCompetitor) {
    if (element.vendorProductId == rpVendorProductId) {
      parseDouble(mainVendorProductFinalPrice) <
              parseDouble(element.vendorFinalPrice)
          ? color = Colors.green
          : parseDouble(mainVendorProductFinalPrice) >
                  parseDouble(element.vendorFinalPrice)
              ? color = Colors.red
              : color = Colors.black;
      break;
    }
  }

  return color;
}

double parseDouble(String str) {
  try {
    // Remove the dollar sign if it exists
    str = str.replaceAll('\$', '');
    return double.parse(str);
  } catch (e) {
    return 0.0;
  }
}

class VendorModel {
  final String vendorProductId, vendorFinalPrice;

  VendorModel({
    required this.vendorProductId,
    required this.vendorFinalPrice,
  });
}

int? returnIndex(
    {required String rpVendorProductId,
    required List<VendorModel> allCompetitor,
    required String mainVendorProductFinalPrice}) {
  int? index;

  for (VendorModel element in allCompetitor) {
    if (element.vendorProductId == rpVendorProductId) {
      index = allCompetitor.indexOf(element);
      break;
    }
  }

  return index;
}
