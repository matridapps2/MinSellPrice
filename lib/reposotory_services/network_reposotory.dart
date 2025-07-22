import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:minsellprice/app.dart';
import 'package:minsellprice/screens/tushar_screen/model/product_list_model_new.dart';
import 'package:retry/retry.dart';

class NetworkCalls {


  Future<Map<String, dynamic>> getBrandPriceAnalysis(
      {required int vendorId, required String date}) async {
    print('Brand Url>>>>>'
        '${AppInfo.kBaseUrl(stagingSelector: 1)}api/dashboard-price-analysis-by-brand/$vendorId/$date');
    final response = await retry(
        () async => await http.post(
              Uri.parse(
                  '${AppInfo.kBaseUrl(stagingSelector: 1)}api/dashboard-price-analysis-by-brand/$vendorId/$date'),
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying Brand Url due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        });

    //
    return jsonDecode(response.body);
  }


  Future<ProductListModelNew?> getProductListBySearch({
    required String afSku,
    required String vendorId,
    required String hpSku,
    required String productMpn,
    required String productName,
  }) async {
    String uri =
        '${AppInfo.kBaseUrl(stagingSelector: 1)}api/search/$vendorId?afsku=$afSku&hpsku=$hpSku&productname=$productName';
    '//&productmpn=$productMpn';
    log('GET PRODUCT LIST BY SEARCH b - $uri');

    ProductListModelNew? toReturn;
    try {
      final response = await retry(
        () async => await http.get(Uri.parse(uri)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        },
      );

      log('getProductListBySearch Status code - ${response.statusCode}');
      if (response.statusCode == 200) {
        toReturn = productListModelNewFromJson(response.body);
        log('getProductListBySearch response - ${response.body}');
      } else {
        toReturn = null;
      }
    } catch (e, s) {
      log('error in getProductListBySearch: $e');
      log('stack trace getProductListBySearch: $s');
    }
    return toReturn;
  }

  Future<String?> getProductListByBrandName(
      String brandName, int pageNumber) async {
    try {
      String uri =
          'https://www.minsellprice.com/api/brands/$brandName?page_no=$pageNumber';

      log('Brand Product API: $uri');
      final response = await retry(
        () async => await http.get(Uri.parse(uri)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        },
      );

      log('getProductListByBrandID Status code - ${response.statusCode}');
      if (response.statusCode == 200) {
        log('getProductListByBrandID response - ${response.body}');
        return response.body;
      } else {
        log('getProductListByBrandID failed with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Exception: ${e.toString()}');
      return null;
    }
  }
}
