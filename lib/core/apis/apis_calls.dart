import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:minsellprice/core/utils/constants/base_url.dart';
import 'package:minsellprice/core/utils/toast_messages/common_toasts.dart';
import 'package:minsellprice/model/product_details_model.dart';
import 'package:retry/retry.dart';

import 'api_utility_methods.dart';
import 'api_utility_constants.dart';

class BrandsApi {
  BrandsApi._();

  // static String emailId = '';
  // static String deviceId = '';
  //
  // Future<String> _getEmail() async{
  //   try {
  //     final User? currentUser = FirebaseAuth.instance.currentUser;
  //
  //     if (currentUser != null && currentUser.email != null) {
  //       emailId = currentUser.email!;
  //       log('Email from Firebase Auth: $emailId');
  //       return emailId;
  //     } else {
  //       // No user logged in
  //       emailId = '';
  //       log('No Firebase user found - user not logged in');
  //       return emailId;
  //     }
  //   } catch (e) {
  //     log('Error getting email: $e');
  //     emailId = '';
  //     return emailId;
  //   }
  // }

  static Future<Map<String, List<dynamic>>> fetchAllBrands(
      [BuildContext? context]) async {
    try {
      log('Fetching brands from API');
      final response = await retry(
        () async => await http.get(
          Uri.parse('$brandUrl$kMinSellBrands'),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        },
      );
      log('Fetching brands from API2');
      log('Brand API: $brandUrl/minsell-brand');

      if (response.statusCode == 200) {
        log('Brand API status code: ${response.statusCode}');
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Safely extract lists with null checks
        final homeGardenBrands =
            jsonData["Home & Garden Brands"] as List<dynamic>? ?? [];
        final shoesApparels =
            jsonData["Shoes & Apparels"] as List<dynamic>? ?? [];

        log('Home & Garden Brands count: ${homeGardenBrands.length}');
        log('Shoes & Apparels count: ${shoesApparels.length}');

        return {
          "Home & Garden Brands": homeGardenBrands,
          "Shoes & Apparels": shoesApparels,
        };
      } else {
        log('Error Brand API: ${response.statusCode}');
        throw Exception('Failed to load brands: ${response.statusCode}');
      }
    } catch (e) {
      log("Exception In Brand API: ${e.toString()}");
      if (context != null) {
        onExceptionResponse(context: context, exception: e.toString());
      }
      return {
        "Home & Garden Brands": [],
        "Shoes & Apparels": [],
      };
    }
  }

  static Future<String?> getProductListByBrandName(
      String brandName, int pageNumber, BuildContext context) async {
    try {
      String uri = '$brandUrl/brands/$brandName?page_no=$pageNumber';

      log('Brand Product List API: $uri');
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
      onExceptionResponse(context: context, exception: e.toString());
      return null;
    }
  }

  static Future<String?> getProductListByBrandNameWithVendor(String brandName,
      int pageNumber, String vendorCodes, BuildContext context) async {
    try {
      String uri =
          '$brandUrl/brands/$brandName?page_no=$pageNumber&vendor=$vendorCodes';

      log('Brand Product List with Vendor API: $uri');
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

      log('getProductListByBrandWithVendor Status code - ${response.statusCode}');
      if (response.statusCode == 200) {
        log('getProductListByBrandWithVendor response - ${response.body}');
        return response.body;
      } else {
        log('getProductListByBrandWithVendor failed with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Exception: ${e.toString()}');
      onExceptionResponse(context: context, exception: e.toString());
      return null;
    }
  }

  static Future<String?> getFilterProduct(
      String brandName, int pageNumber, BuildContext context) async {
    const vendorId = 'U25vdyBCcm90aGVycyBhcHBsaWFuY2U=';
    try {
      String uri = '$brandUrl/brands/$brandName?vendor=$vendorId';

      log('Filtered Product List API:');
      log(uri);
      final response = await retry(
        () async => await http.get(Uri.parse(uri)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          CommonToasts.centeredMobile(
              msg: 'Retrying due to: $e', context: context);
        },
      );

      log('Filtered API Status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        log('Filtered API RESPONSE: ${response.body}');
        return response.body;
      } else {
        log('Filtered API RESPONSE: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Exception: ${e.toString()}');
      onExceptionResponse(context: context, exception: e.toString());
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchSearchProduct(
      BuildContext context, String searchQuery) async {
    try {
      // Build the search URL with proper encoding
      final encodedQuery = Uri.encodeComponent(searchQuery.trim());
      String uri = '$brandUrl$kSearchProduct$encodedQuery';

      log('Fetching Search Product API');
      log('Search URL: $uri');

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

      if (response.statusCode == 200) {
        log('Search API status code: ${response.statusCode}');
        log('Search API response: ${response.body}');

        // Parse the JSON response
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        log('Error Search Product API: ${response.statusCode}');
        log('Error response body: ${response.body}');
        return null;
      }
    } catch (e) {
      log("Exception In Search Product API: ${e.toString()}");
      onExceptionResponse(context: context, exception: e.toString());
      return null;
    }
  }

  /// Fetch verified products from API
  static Future<List<Map<String, dynamic>>> fetchVerifiedProducts(
      BuildContext context) async {
    try {
      String uri = 'https://www.minsellprice.com/api/get-verified-products';

      log('Fetching Verified Products API');
      log('Verified Products URL: $uri');

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

      if (response.statusCode == 200) {
        log('Verified Products API status code: ${response.statusCode}');
        log('Verified Products API response length: ${response.body.length}');

        // Parse the JSON response
        final List<dynamic> jsonData = json.decode(response.body);
        final List<Map<String, dynamic>> verifiedProducts =
            jsonData.map((e) => Map<String, dynamic>.from(e)).toList();

        log('Fetched ${verifiedProducts.length} verified products');
        return verifiedProducts;
      } else {
        log('Error Verified Products API: ${response.statusCode}');
        log('Error response body: ${response.body}');
        return [];
      }
    } catch (e) {
      log("Exception In Verified Products API: ${e.toString()}");
      onExceptionResponse(context: context, exception: e.toString());
      return [];
    }
  }

  static Future<ProductDetailsModel> getProductDetails(
      {required String brandName,
      required String productMPN,
      required int productId,
      required BuildContext context}) async {
    log('Single Product API Method');
    log('Parameters - brandName: $brandName, productMPN: $productMPN, productId: $productId');

    try {
      final url =
          '$brandUrl/brands/$brandName/$productMPN?product_id=$productId';

      log('Single Product API: $url');

      final response = await retry(
        () async => await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        },
      );

      log('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        log(response.body);
        final jsonResponse = json.decode(response.body);
        log('Parsed JSON response: $jsonResponse');

        final productDetails = ProductDetailsModel.fromJson(jsonResponse);
        log('Parsed product details - vendorProductData count: ${productDetails.vendorProductData?.length ?? 0}');

        return productDetails;
      } else {
        log('API Error - Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to load product details: ${response.statusCode}');
      }
    } catch (e) {
      log('Error in getProductDetails: $e');
      onExceptionResponse(context: context, exception: e.toString());
      throw Exception('Error fetching product details: $e');
    }
  }

  static Future<String> savePriceAlert(
      {required BuildContext context,
      required String emailId,
      required String price,
      required int productId,
      required String deviceToken}) async {
    try {
      final url =
          '$growthMatridUrl$kSaveProductData$kEmail$emailId&product_id=$productId&price=$price&device_token=$deviceToken';

      log('SavePriceAlert API: $url');
      final response = await retry(
        () async => await http.post(
          Uri.parse(url),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        },
      );
      log('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('API Successfully Run');
        log(response.body);

        return response.body;
      } else {
        log('API Error - Status: ${response.statusCode}, Body: ${response.body}');
        return 'error';
      }
    } catch (e) {
      log('Exception in SavePriceAlert API: ${e.toString()}');
      onExceptionResponse(context: context, exception: e.toString());
      return e.toString();
    }
  }

  static Future<String> fetchSavedProductData({
    required String emailId,
    required BuildContext context,
  }) async {
    try {
      final url = '$growthMatridUrl$kFetchProductData$kEmail$emailId';

      log('GetPriceAlert API: $url');
      final response = await retry(
        () async => await http.post(
          Uri.parse(url),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        },
      );
      log('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('API Successfully Run');
        log(response.body);
        return response.body;
      } else {
        log('API Error - Status: ${response.statusCode}, Body: ${response.body}');
        return 'error';
      }
    } catch (e) {
      log('Exception in GetPriceAlert API: ${e.toString()}');
      onExceptionResponse(context: context, exception: e.toString());
      return e.toString();
    }
  }

  /// Unified method to fetch saved product data using either email or device token
  static Future<String> fetchPriceAlertProduct({
    String? emailId,
    String? deviceToken,
    required BuildContext context,
  }) async {
    try {
      String url;
      String logMessage;

      log('GET ALL NOTIFICATION API');
      if (emailId != null && emailId.isNotEmpty) {
        // LOGIN CASE: Use email
        url = '$growthMatridUrl$kFetchProductData$kEmail$emailId';
        logMessage = 'GetPriceAlert API (Email): $url';
        log('✅ LOGIN CASE: Using email for API call: $emailId');
      } else if (deviceToken != null && deviceToken.isNotEmpty) {
        // LOGGED OUT CASE: Use device token
        url = '$growthMatridUrl$kFetchProductData$kDeviceToken$deviceToken';
        logMessage = 'GetPriceAlert API (Device Token): $url';
        log('✅ LOGGED OUT CASE: Using device token for API call: $deviceToken');
      } else {
        log('❌ No email or device token provided for API call');
        return 'error';
      }

      log(logMessage);
      final response = await retry(
        () async => await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        },
      );
      log('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('API Successfully Run');
        log(response.body);
        return response.body;
      } else {
        log('API Error - Status: ${response.statusCode}, Body: ${response.body}');
        return 'error';
      }
    } catch (e) {
      log('Exception in GetPriceAlert Unified API: ${e.toString()}');
      onExceptionResponse(context: context, exception: e.toString());
      return e.toString();
    }
  }

  static Future<String> deleteSavedPriceAlertProduct({
    required String emailId,
    required String deviceToken,
    required int productId,
    required BuildContext context,
  }) async {
    try {
      String logMessage = '';
      String url;

      log('Delete ProductData API:');
      if (emailId.isNotEmpty) {
        url =
            '$growthMatridUrl$kDeleteProductData$kEmail$emailId&product_id=$productId';
        logMessage = 'GetPriceAlert API (Email): $url';
        log('✅ LOGIN CASE: Using email for API call: $emailId');
      } else if (deviceToken.isNotEmpty) {
        url =
            '$growthMatridUrl$kDeleteProductData$kDeviceToken$deviceToken&product_id=$productId';
        logMessage = 'GetPriceAlert API (Device Token): $url';
        log('✅ LOGGED OUT CASE: Using device token for API call: $deviceToken');
      } else {
        log('❌ No email or device token provided for API call');
        return 'error';
      }

      log('Update Read Status API: $logMessage');

      ///  final url = '$growthMatridUrl$kDeleteProductData$kEmail$emailId&product_id=$productId';

      log('Delete ProductData API: $url');
      final response = await retry(
        () async => await http.post(
          Uri.parse(url),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        },
      );
      log('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('API Successfully Run');
        log(response.body);
        return response.body;
      } else {
        log('API Error - Status: ${response.statusCode}, Body: ${response.body}');
        return 'error';
      }
    } catch (e) {
      log('Exception Delete ProductData API: ${e.toString()}');
      onExceptionResponse(context: context, exception: e.toString());
      return e.toString();
    }
  }

  static Future<String> updateReadStatus({
    required String emailId,
    required String deviceToken,
    required int productId,
    required int isRead,
  }) async {
    try {
      String logMessage = '';
      String url;

      log('UPDATE READ STATUS API:');
      if (emailId.isNotEmpty) {
        url =
            '$growthMatridUrl$kReadProductData$kEmail$emailId&product_id=$productId&is_read=$isRead';
        logMessage = 'GetPriceAlert API (Email): $url';
        log('✅ LOGIN CASE: Using email for API call: $emailId');
      } else if (deviceToken.isNotEmpty) {
        url =
            '$growthMatridUrl$kReadProductData$kDeviceToken$deviceToken&product_id=$productId&is_read=$isRead';
        logMessage = 'GetPriceAlert API (Device Token): $url';
        log('✅ LOGGED OUT CASE: Using device token for API call: $deviceToken');
      } else {
        log('❌ No email or device token provided for API call');
        return 'error';
      }

      log('Update Read Status API: $logMessage');
      final response = await retry(
        () async => await http.post(
          Uri.parse(url),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        },
      );
      log('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('Read status updated successfully');
        log(response.body);
        return response.body;
      } else {
        log('API Error - Status: ${response.statusCode}, Body: ${response.body}');
        return 'error';
      }
    } catch (e) {
      log('Exception Update Read Status API: ${e.toString()}');
      return e.toString();
    }
  }

  static Future<void> updateSentNotificationStatus({
    required String emailId,
    required String deviceID,
    required int productId,
    required int isNotificationSent,
  }) async {
    log('UPDATE NOTIFICATION SENT STATUS API:');
    log('Parameters - emailId: $emailId, productId: $productId, isNotificationSent: $isNotificationSent, deviceID: $deviceID');

    String url =
        '$growthMatridUrl/notification-sent?$kEmail$emailId&product_id=$productId&is_notification_sent=$isNotificationSent&device_token=$deviceID';
    log('URL: $url');

    try {
      final response = await retry(
        () async {
          log('Attempting to update notification sent status...');
          return await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              log('Request timeout after 30 seconds');
              throw TimeoutException(
                  'Request timeout', const Duration(seconds: 30));
            },
          );
        },
        retryIf: (e) {
          log('Retry condition check: ${e.runtimeType}');
          return e is SocketException ||
              e is TimeoutException ||
              e is HttpException ||
              (e is http.ClientException &&
                  e.message.contains('Connection timed out'));
        },
        maxAttempts: 3,
        onRetry: (e) {
          log('Retrying updateSentNotificationStatus due to: ${e.runtimeType} - ${e.toString()}');
        },
      );

      log('API Response Status: ${response.statusCode}');
      log('API Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        log('Notification Sent Status Updated Successfully');
        log('Response body: ${response.body}');
      } else {
        log('API Error - Status: ${response.statusCode}');
        log('Error response body: ${response.body}');

        // Log structured error information
        log('Error Details: {'
            '"statusCode": ${response.statusCode}, '
            '"url": "$url", '
            '"emailId": "$emailId", '
            '"productId": $productId, '
            '"isNotificationSent": $isNotificationSent, '
            '"deviceID": "$deviceID"'
            '}');
      }
    } catch (e) {
      log('Exception Update Sent Notification Status API: ${e.toString()}');
      log('Exception Type: ${e.runtimeType}');

      // Log structured error information for better debugging
      log('Error Details: {'
          '"exception": "${e.toString()}", '
          '"exceptionType": "${e.runtimeType}", '
          '"url": "$url", '
          '"emailId": "$emailId", '
          '"productId": $productId, '
          '"isNotificationSent": $isNotificationSent, '
          '"deviceID": "$deviceID", '
          '"timestamp": "${DateTime.now().toIso8601String()}"'
          '}');

      // Handle specific error types
      if (e is SocketException) {
        log('Network connectivity issue: ${e.message}');
      } else if (e is TimeoutException) {
        log('Request timeout: ${e.message}');
      } else if (e is HttpException) {
        log('HTTP error: ${e.message}');
      } else if (e is http.ClientException) {
        log('Client error: ${e.message}');
      }

      // Re-throw the exception to allow calling code to handle it if needed
      rethrow;
    }
  }

  static Future<String> saveLikedProduct({
    required String emailId,
    required int productId,
    required int status,
  }) async {
    log('Product ID: $productId');
    try {
      final url =
          '$brandUrl$kSaveLikedProduct$kEmail$emailId&product_id=$productId&status=$status';

      log('Saved Liked Product API: $url');
      final response = await retry(
        () async => await http.post(
          Uri.parse(url),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        },
      );
      log('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('Liked Product Updated Successfully');
        log(response.body);
        return response.body;
      } else {
        log('API Error - Status: ${response.statusCode}, Body: ${response.body}');
        return 'error';
      }
    } catch (e) {
      log('Exception Saved Liked Product API: ${e.toString()}');
      return e.toString();
    }
  }

  static Future<String> getLikedProduct({
    required String emailId,
    required BuildContext context,
  }) async {
    try {
      final url = '$brandUrl$kLikedProduct$kEmail$emailId';

      log('Get Liked Product API: $url');
      final response = await retry(
        () async => await http.get(
          Uri.parse(url),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          Fluttertoast.showToast(
            msg: 'Retrying due to: $e',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
          );
        },
      );
      log('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('API Successfully');
        log(response.body);
        return response.body;
      } else {
        log('API Error - Status: ${response.statusCode}, Body: ${response.body}');
        return 'error';
      }
    } catch (e) {
      log('Exception GET Liked Product API: ${e.toString()}');
      return e.toString();
    }
  }

  /// Fetch top categories from API
  static Future<List<Map<String, dynamic>>> fetchTopCategories(
      [BuildContext? context]) async {
    try {
      log('Fetching top categories from API');
      const url = 'https://www.minsellprice.com/api/top-category';

      final response = await retry(
        () async => await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          if (context != null) {
            Fluttertoast.showToast(
              msg: 'Retrying due to: $e',
              gravity: ToastGravity.CENTER,
              toastLength: Toast.LENGTH_LONG,
            );
          }
        },
      );

      log('Top Categories API Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('Top Categories API Response: ${response.body}');
        final List<dynamic> jsonData = json.decode(response.body);

        // Convert to List<Map<String, dynamic>>
        final List<Map<String, dynamic>> categories =
            jsonData.map((item) => item as Map<String, dynamic>).toList();

        log('Top Categories count: ${categories.length}');
        return categories;
      } else {
        log('Error Top Categories API: ${response.statusCode}');
        throw Exception(
            'Failed to load top categories: ${response.statusCode}');
      }
    } catch (e) {
      log("Exception In Top Categories API: ${e.toString()}");
      if (context != null) {
        onExceptionResponse(context: context, exception: e.toString());
      }
      return [];
    }
  }

  /// Fetch subcategories for a specific category
  static Future<List<Map<String, dynamic>>> fetchCategorySubcategories(
      String categoryPath,
      [BuildContext? context]) async {
    try {
      log('Fetching subcategories for category: $categoryPath');
      final url =
          'https://www.minsellprice.com/api/category/$categoryPath/subcategories';

      log('Subcategories API URL: $url');

      final response = await retry(
        () async => await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        onRetry: (e) {
          if (context != null) {
            Fluttertoast.showToast(
              msg: 'Retrying due to: $e',
              gravity: ToastGravity.CENTER,
              toastLength: Toast.LENGTH_LONG,
            );
          }
        },
      );

      log('Subcategories API Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('Subcategories API Response: ${response.body}');
        final dynamic jsonResponse = json.decode(response.body);

        // Log all keys in response for debugging
        if (jsonResponse is Map<String, dynamic>) {
          log('🔍 Subcategories Response keys: ${jsonResponse.keys.toList()}');
        }

        // Handle different response formats
        List<dynamic> subcategoriesData;

        if (jsonResponse is List) {
          // Direct array response
          subcategoriesData = jsonResponse;
        } else if (jsonResponse is Map<String, dynamic>) {
          // Object response with subcategories key - try multiple variations
          subcategoriesData = jsonResponse['sub_category'] ?? // snake_case
              jsonResponse['subcategories'] ?? // camelCase
              jsonResponse['subCategories'] ?? // camelCase variant
              jsonResponse['data'] ??
              jsonResponse['categories'] ??
              [];
        } else {
          log('Unexpected response format');
          return [];
        }

        // Convert to List<Map<String, dynamic>>
        final List<Map<String, dynamic>> subcategories = subcategoriesData
            .map((item) => item as Map<String, dynamic>)
            .toList();

        log('Subcategories count: ${subcategories.length}');

        // Log full response if no subcategories found
        if (subcategories.isEmpty && jsonResponse is Map<String, dynamic>) {
          log('⚠️ No subcategories parsed. Full response: ${response.body}');
        }

        return subcategories;
      } else {
        log('Error Subcategories API: ${response.statusCode}');
        log('Error Response: ${response.body}');

        // Return empty list instead of throwing exception
        // This allows fallback to direct product navigation
        return [];
      }
    } catch (e) {
      log("Exception In Subcategories API: ${e.toString()}");
      if (context != null) {
        onExceptionResponse(context: context, exception: e.toString());
      }
      // Return empty list to allow fallback
      return [];
    }
  }
}
