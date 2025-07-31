import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:minsellprice/core/utils/constants/base_url.dart';
import 'package:minsellprice/model/product_details_model.dart';
import 'package:retry/retry.dart';

import 'api_utility_methods.dart';

class BrandsApi {
  BrandsApi._();

  static Future<Map<String, List<dynamic>>> fetchAllBrands(
      [BuildContext? context]) async {
    try {
      log('Fetching brands from API');
      final response = await http.get(
        Uri.parse('$brandUrl/minsell-brand'),
      );
      log('Fetching brands from API2');
      log('Brand API: $brandUrl/minsell-brand');

      if (response.statusCode == 200) {
        log('Brand API status code: ${response.statusCode}');
        final Map<String, dynamic> jsonData = json.decode(response.body);

        final homeGardenBrands =
            jsonData["Home & Garden Brands"] as List<dynamic>;
        final shoesApparels = jsonData["Shoes & Apparels"] as List<dynamic>;

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
      onExceptionResponse(
          context: context,
          exception: e.toString()
      );
      return null;
    }
  }

  static Future<ProductDetailsModel> getProductDetails(
      {required String brandName,
      required String productMPN,
      required int productId,
      required BuildContext context}) async {
    log('Product API running');
    log('Parameters - brandName: $brandName, productMPN: $productMPN, productId: $productId');

    try {
      final cleanBrandName = brandName.toLowerCase().replaceAll(' ', '-');
      final url =
          '$brandUrl/brands/$cleanBrandName/$productMPN?product_id=$productId';

      log('Single Product API: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      log('API Response Status: ${response.statusCode}');
      log('API Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        log('Successfully API run: ${response.body}');
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
}
