import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minsellprice/core/utils/constants/base_url.dart';
import 'package:minsellprice/core/utils/toast_messages/common_toasts.dart';
import 'package:minsellprice/model/category_model.dart';
import 'package:minsellprice/model/api_category_model.dart';

/// Service class for handling category-related API calls
class CategoryService {
  static const String _baseUrl = brandUrl;
  static const String _categoriesEndpoint = '/categories';

  /// Fetch all categories from the API
  static Future<List<MainCategory>?> fetchCategories({
    required BuildContext context,
  }) async {
    String ceche = '123224';
    try {
      final url = '$_baseUrl$_categoriesEndpoint?cache=$ceche';
      log('🌐 Fetching categories from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      log('Categories API Response received');
      log('Response status: ${response.statusCode}');
      log('Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        log('Successfully fetched categories');
        final jsonResponse = response.body;

        if (jsonResponse.isNotEmpty) {
          final apiResponse = apiCategoryResponseFromJson(jsonResponse);
          log('📦 API Response categories count: ${apiResponse.categories.length}');
          log('📦 API Categories: ${apiResponse.categories.map((c) => c.categoryName).toList()}');

          // Log filtering details for debugging
          for (var category in apiResponse.categories) {
            log('🔍 Category: ${category.categoryName}'
                ' | isActive: ${category.isActiveCategory}'
                ' | includeMenu: ${category.includeMenu}'
                ' | shouldInclude: ${category.shouldIncludeInMenu}');
          }

          final mainCategories = apiResponse.categories
              .where((category) =>
                  category.isActiveCategory && category.shouldIncludeInMenu)
              .map((category) => category.toMainCategory())
              .toList();

          log('📦 Parsed ${mainCategories.length} main categories (filtered from ${apiResponse.categories.length})');
          log('📦 Displayed categories: ${mainCategories.map((c) => c.name).toList()}');
          return mainCategories;
        } else {
          log('⚠️ Empty response received');
          return null;
        }
      } else {
        log('❌ API Error - Status: ${response.statusCode}');
        log('❌ Response body: ${response.body}');
        _showErrorToast(context, 'Failed to load categories');
        return null;
      }
    } catch (e) {
      log('❌ Exception in fetchCategories: $e');
      _showErrorToast(context, 'Error loading categories');
      return null;
    }
  }

  /// Search products within a category
  static Future<CategoryResponse?> searchCategoryProducts({
    required String categoryPath,
    required String searchQuery,
    required BuildContext context,
  }) async {
    try {
      final url = '$_baseUrl/category/$categoryPath?search=$searchQuery';
      log('🔍 Searching category products from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        log('✅ Successfully searched category products');
        final jsonResponse = response.body;

        if (jsonResponse.isNotEmpty) {
          return categoryResponseFromJson(jsonResponse);
        } else {
          log('⚠️ No search results found');
          return null;
        }
      } else {
        log('❌ Search API Error - Status: ${response.statusCode}');
        _showErrorToast(context, 'Search failed');
        return null;
      }
    } catch (e) {
      log('❌ Exception in searchCategoryProducts: $e');
      _showErrorToast(context, 'Search error');
      return null;
    }
  }

  /// Helper method to show error toast
  static void _showErrorToast(BuildContext context, String message) {
    try {
      // Show a simple snackbar for now
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(message),
      //     backgroundColor: Colors.red,
      //     duration: const Duration(seconds: 3),
      //   ),
      CommonToasts.centeredMobile(msg: message, context: context);
    } catch (e) {
      log('❌ Error showing toast: $e');
    }
  }

  /// Get category display name from path
  static String getCategoryDisplayName(String categoryPath) {
    final parts = categoryPath.split('/');
    final lastPart = parts.last;

    // Convert kebab-case to Title Case
    return lastPart
        .split('-')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  /// Fetch products for a specific category path with pagination
  /// Returns a Map containing 'products' list, 'productCount', and 'brands' from API
  static Future<Map<String, dynamic>?> fetchCategoryProducts({
    required BuildContext context,
    required String categoryPath,
    int pageNumber = 1,
    List<String>? brandKeys, // Optional list of brand_keys for filtering
  }) async {
    try {
      String ceche = '243322';
      String url =
          '$_baseUrl/category/$categoryPath?page_no=$pageNumber&ceche=$ceche';

      // Add brand parameters if provided (API expects brand[] format for array)
      if (brandKeys != null && brandKeys.isNotEmpty) {
        // Add multiple brand[] parameters for each selected brand
        for (final brandKey in brandKeys) {
          if (brandKey.isNotEmpty) {
            final encodedBrand = Uri.encodeComponent(brandKey);
            url += '&brand[]=$encodedBrand';
          }
        }
        log('🏷️ Adding brand filters to URL: ${brandKeys.length} brands selected');
        log('🏷️ Brand keys: $brandKeys');
      } else {
        log('ℹ️ No brand filter - showing all brands in category');
      }

      log('🌐 Fetching category products from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      log('📥 Category products API Response received');
      log('📊 Response status: ${response.statusCode}');
      log('📏 Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        log('✅ Successfully fetched category products');
        final jsonResponse = response.body;

        if (jsonResponse.isNotEmpty) {
          final Map<String, dynamic> responseData = jsonDecode(jsonResponse);

          // Log all keys in response for debugging
          log('🔍 API Response keys: ${responseData.keys.toList()}');

          // Extract productCount from API response (accurate total count)
          int productCount = 0;
          if (responseData.containsKey('productCount')) {
            final productCountValue = responseData['productCount'];
            if (productCountValue is int) {
              productCount = productCountValue;
            } else if (productCountValue is String) {
              productCount = int.tryParse(productCountValue) ?? 0;
            }
            log('📊 API productCount: $productCount');
          }

          // Extract brandRecord from API response
          List<Map<String, dynamic>> brands = [];
          if (responseData.containsKey('brandRecord') &&
              responseData['brandRecord'] is List) {
            brands = (responseData['brandRecord'] as List)
                .map((brand) => Map<String, dynamic>.from(brand))
                .toList();
            log('🏷️ API brandRecord count: ${brands.length}');
          }

          // Try multiple possible keys for products
          List<dynamic> products = responseData['brand_product'] ??
              responseData['products'] ??
              responseData['product'] ??
              responseData['data'] ??
              responseData['category_products'] ??
              [];

          log('📦 API Response products array length: ${products.length}');
          log('📦 API productCount (total): $productCount');

          // If still no products, log the full response for debugging
          if (products.isEmpty) {
            log('⚠️ No products found. Full response: ${response.body}');
          }

          // Convert to the format expected by ProductList
          final List<Map<String, dynamic>> productList = products
              .map((product) => Map<String, dynamic>.from(product))
              .toList();

          log('📦 Parsed ${productList.length} products for category: $categoryPath');
          if (brandKeys != null && brandKeys.isNotEmpty) {
            log('✅ Brand filters applied: $brandKeys - Found ${productList.length} products');
          }

          // Return products, productCount, and brands
          return {
            'products': productList,
            'productCount': productCount,
            'brands': brands,
          };
        } else {
          log('⚠️ Empty response received for category: $categoryPath');
          return null;
        }
      } else {
        log('❌ API Error - Status: ${response.statusCode}');
        log('❌ Response body: ${response.body}');
        _showErrorToast(context, 'Failed to load category products');
        return null;
      }
    } catch (e) {
      log('❌ Exception in fetchCategoryProducts: $e');
      _showErrorToast(context, 'Error loading category products');
      return null;
    }
  }
}
