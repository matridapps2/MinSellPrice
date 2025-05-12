import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shoppingmegamart/app.dart';
import 'package:shoppingmegamart/model/competitor_model.dart';
import 'package:shoppingmegamart/model/discount_model.dart';
import 'package:shoppingmegamart/model/price_change_model.dart';
import 'package:shoppingmegamart/model/product_list_model.dart';
import 'package:shoppingmegamart/model/product_list_model_new.dart';
import 'package:shoppingmegamart/model/vendor_dashboard_model.dart';
import 'package:shoppingmegamart/model/vendor_price_analysis.dart';
import 'package:retry/retry.dart';

class NetworkCalls {
  Future<List<CompetitorModel>> getComeptitorsModel(
      {required int vendorId, required String date}) async {
    final response = await retry(
        () async => await http.post(
              Uri.parse(
                  '${AppInfo.kBaseUrl(stagingSelector: 1)}api/dashboard-stats-test/$vendorId/$date'),
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        });

    //

    return competitorModelFromJson(response.body);
  }

  Future<VendorPriceAnalyisModel> getVendorPriceAnalysis(
      {required int vendorId, required String date}) async {
    final response = await retry(
        () async => await http.post(
              Uri.parse(
                  '${AppInfo.kBaseUrl(stagingSelector: 1)}api/dashboard-price-analysis/$vendorId/$date'),
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        });

    //
    return vendorPriceAnalyisModelFromJson(response.body);
  }

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

  Future<List<ProductListModel>> getProductListById({
    required String vendorId,
    required String date,
    required String dataId,
  }) async {
    print(
        '${AppInfo.kBaseUrl(stagingSelector: 1)}api/Vendor-Products-api/$vendorId/$date?data-id=$dataId');

    final response = await retry(
        () async => await http.get(
              Uri.parse(
                  '${AppInfo.kBaseUrl(stagingSelector: 1)}api/Vendor-Products-api/$vendorId/$date?data-id=$dataId'),
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        });
    //
    return productListModelFromJson(response.body);
  }

  Future<List<ProductListModel>> getProductListByBrandId({
    required String brandId,
    required String vendorId,
    required String date,
  }) async {
    print(
        'Brand URl >>>>> ${AppInfo.kBaseUrl(stagingSelector: 1)}api/brand-api/$brandId/$vendorId/$date');

    final response = await retry(
        () async => await http.get(
              Uri.parse(
                  '${AppInfo.kBaseUrl(stagingSelector: 1)}api/brand-api/$brandId/$vendorId/$date'),
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        });
    //
    return productListModelFromJson(response.body);
  }

  Future<List<ProductListModel>> getProductListByCategoryId({
    required String categoryId,
  }) async {
    final response = await retry(
        () async => await http.get(
              Uri.parse(
                  '${AppInfo.kBaseUrl(stagingSelector: 2)}api/is_featured_category_Products_api/${AppInfo.kVendorId}/$categoryId'),
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        });
    //
    return productListModelFromJson(response.body);
  }

  Future<List<ProductListModel>> getProductListByAiEngine(
      {required String vendorId, required Map<String, String> body}) async {
    print(
        '${AppInfo.kBaseUrl(stagingSelector: 1)}api/ai-price-engine-api/$vendorId');

    final response = await retry(
        () async => await http.post(
              Uri.parse(
                  '${AppInfo.kBaseUrl(stagingSelector: 1)}api/ai-price-engine-api/$vendorId'),
              body: body,
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        });
    //
    return productListModelFromJson(response.body);
  }

  // Future<List<ProductListModel>> getProductListBySearch({
  //   required String afSku,
  //   required String vendorId,
  //   required String hpSku,
  //   required String productMpn,
  //   required String productName,
  // }) async {
  //
  //   print( '${AppInfo.kBaseUrl(stagingSelector: 1)}api/search/$vendorId?afsku=$afSku&hpsku=$hpSku&productname=$productName&productmpn=$productMpn');
  //   final response = await retry(
  //       () async => await http.post(
  //             Uri.parse(
  //                 '${AppInfo.kBaseUrl(stagingSelector: 1)}api/search/$vendorId?afsku=$afSku&hpsku=$hpSku&productname=$productName&productmpn=$productMpn'),
  //           ),
  //       retryIf: (e) => e is SocketException || e is TimeoutException,
  //       onRetry: (e) {
  //         Fluttertoast.showToast(
  //           msg: 'Retrying due to: $e',
  //           gravity: ToastGravity.CENTER,
  //           toastLength: Toast.LENGTH_LONG,
  //         );
  //       });
  //   return productListModelFromJson(response.body);
  // }

  Future<ProductListModelNew?> getProductListBySearch({
    required String afSku,
    required String vendorId,
    required String hpSku,
    required String productMpn,
    required String productName,
  }) async {
    String uri =
        '${AppInfo.kBaseUrl(stagingSelector: 1)}api/search/$vendorId?afsku=$afSku&hpsku=$hpSku&productname=$productName&productmpn=$productMpn';
    log('GET PRODUCT LIST BY SEARCH - $uri');

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
        log('getProductListBySearch vendorProducts Empty - ${toReturn.vendorProducts.isEmpty}');
      } else {
        toReturn = null;
      }
    } catch (e, s) {
      log('error in getProductListBySearch: $e');
      log('stack trace getProductListBySearch: $s');
    }
    return toReturn;
  }

  Future<List<ProductListModel>> getFeaturedProduct({
    required String vendorId,
  }) async {
    final apiUrl =
        '${AppInfo.kBaseUrl(stagingSelector: 1)}api/is_featured_collection_api/$vendorId';
    print('Featured Products API URL: $apiUrl');

    final response = await retry(
        () async => await http.get(
              Uri.parse(apiUrl),
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        });

    print('Featured Products API Response Status Code: ${response.statusCode}');
    print('Featured Products API Response Body: ${response.body}');

    return productListModelFromJson(response.body);
  }

  Future<List<Discount>> returnDiscountTableData({
    required String vendorId,
    required String date,
    // required String dataId,
  }) async {
    final response = await retry(
        () async => await http.post(
              Uri.parse(
                  '${AppInfo.kBaseUrl(stagingSelector: 1)}api/dashboard-discount-analysis/$vendorId/$date'),
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        });

    return discountListModelFromJson(response.body);
  }

  Future<List<ProductListModel>> getProductListByDiscountId({
    required String vendorId,
    required String date,
    required String dataId,
  }) async {
    log('brand url>>>>>> '
        '${AppInfo.kBaseUrl(stagingSelector: 1)}is_featured_collection_api/10024');
    final response = await retry(
        () async => await http.get(
              Uri.parse(
                  '${AppInfo.kBaseUrl(stagingSelector: 1)}api/is_featured_collection_api/10024'),
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        });

    return productListModelFromJson(response.body);
  }

  Future<String> loginToSystem({required String loginDataAsMap}) async {
    final map = jsonDecode(loginDataAsMap);
    String email = map['email'];
    String password = map['password'];
    print(
        '${AppInfo.kBaseUrl(stagingSelector: 1)}api/login-api?email=$email&password=$password');
    final response = await retry(
        () async => await http.post(
            Uri.parse(
              '${AppInfo.kBaseUrl(stagingSelector: 1)}api/login-api?email=$email&password=$password',
            ),
            headers: {'Content-Type': 'application/json'}),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        });

    return response.body;
  }

  Future<VendorDashboardModel> getVendorDetails(
      {required String vendorId, required String date}) async {
    final response = await retry(
        () async => await http.post(
              Uri.parse(
                  '${AppInfo.kBaseUrl(stagingSelector: 1)}api/dashboard-all-count/$vendorId/$date'),
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        });

    // log('${AppInfo.kBaseUrl(stagingSelector: 1)}api/dashboard-all-count/$vendorId/$date');

    //
    return VendorDashboardModel.fromJson(jsonDecode(response.body));
  }

  Future<PriceChangeModel> getPriceChangeDetails(
      {required String vendorId, required String date}) async {
    final response = await retry(
        () async => await http.get(
              Uri.parse(
                  '${AppInfo.kBaseUrl(stagingSelector: 1)}api/PriceChange/$vendorId/$date'),
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        });

    //
    return priceChangeModelFromJson(response.body);
  }

  Future<String> returnAllBrandData(
      {required String vendorId, required String date}) async {
    print(
        '${AppInfo.kBaseUrl(stagingSelector: 1)}api/all-brands/$vendorId/$date?');
    final response = await retry(
        () async => await http.get(
              Uri.parse(
                  '${AppInfo.kBaseUrl(stagingSelector: 1)}api/all-brands/$vendorId/$date?'),
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        });
    // print(response.body);
    return response.body;
  }

  Future<List<dynamic>> returnFeaturedCategory() async {
    /*${AppInfo.kBaseUrl(stagingSelector: 2)}api/is_featured_category_collection_api/${AppInfo.kVendorId}*/

    final response = await retry(
        () async => await http.get(
              Uri.parse(
                  '${AppInfo.kBaseUrl(stagingSelector: 2)}api/is_featured_category_collection_api/${AppInfo.kVendorId}'),
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        });

    return jsonDecode(response.body);
  }

  Future<List<dynamic>> returnFeaturedBrands() async {
    /*${AppInfo.kBaseUrl(stagingSelector: 2)}api/is_featured_category_collection_api/${AppInfo.kVendorId}*/

    final response = await retry(
        () async => await http.get(
              Uri.parse(
                  '${AppInfo.kBaseUrl(stagingSelector: 2)}api/is_featured_brands_collection_api/${AppInfo.kVendorId}'),
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        });

    return jsonDecode(response.body);
  }
}
