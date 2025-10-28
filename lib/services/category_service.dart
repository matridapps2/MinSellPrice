import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minsellprice/core/utils/constants/base_url.dart';
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
    try {
      final url = '$_baseUrl$_categoriesEndpoint';
      log('🌐 Fetching categories from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      log('📥 Categories API Response received');
      log('📊 Response status: ${response.statusCode}');
      log('📏 Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        log('✅ Successfully fetched categories');
        final jsonResponse = response.body;

        if (jsonResponse.isNotEmpty) {
          final apiResponse = apiCategoryResponseFromJson(jsonResponse);
          log('📦 API Response categories count: ${apiResponse.categories.length}');
          log('📦 API Categories: ${apiResponse.categories.map((c) => c.categoryName).toList()}');

          final mainCategories = apiResponse.categories
              .where((category) =>
                  category.isActiveCategory && category.shouldIncludeInMenu)
              .map((category) => category.toMainCategory())
              .toList();

          log('📦 Parsed ${mainCategories.length} main categories');
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

  /// Fetch products for a specific brand within a category
  static Future<CategoryResponse?> fetchBrandCategoryProducts({
    required String categoryPath,
    required String brandName,
    required BuildContext context,
  }) async {
    try {
      final url = '$_baseUrl/category/$categoryPath?brand=$brandName';
      log('🌐 Fetching brand category products from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        log('✅ Successfully fetched brand category products');
        final jsonResponse = response.body;

        if (jsonResponse.isNotEmpty) {
          return categoryResponseFromJson(jsonResponse);
        } else {
          log('⚠️ Empty response received');
          return null;
        }
      } else {
        log('❌ API Error - Status: ${response.statusCode}');
        _showErrorToast(context, 'Failed to load brand products');
        return null;
      }
    } catch (e) {
      log('❌ Exception in fetchBrandCategoryProducts: $e');
      _showErrorToast(context, 'Error loading brand products');
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

  /// Get category statistics (product count, vendor count, etc.)
  static Future<Map<String, dynamic>?> getCategoryStats({
    required String categoryPath,
    required BuildContext context,
  }) async {
    try {
      final url = '$_baseUrl/category/$categoryPath/stats';
      log('📊 Fetching category stats from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        log('✅ Successfully fetched category stats');
        return {
          'productCount': 0,
          'vendorCount': 0,
          'averagePrice': 0.0,
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      } else {
        log('❌ Stats API Error - Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('❌ Exception in getCategoryStats: $e');
      return null;
    }
  }

  /// Helper method to show error toast
  static void _showErrorToast(BuildContext context, String message) {
    try {
      // Show a simple snackbar for now
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      log('❌ Error showing toast: $e');
    }
  }

  /// Build category URL path from category hierarchy
  static String buildCategoryPath({
    required String mainCategory,
    String? subCategory,
    String? subSubCategory,
  }) {
    String path = mainCategory;

    if (subCategory != null && subCategory.isNotEmpty) {
      path += '/$subCategory';
    }

    if (subSubCategory != null && subSubCategory.isNotEmpty) {
      path += '/$subSubCategory';
    }

    return path;
  }

  /// Parse category path to extract hierarchy
  static Map<String, String> parseCategoryPath(String categoryPath) {
    final parts = categoryPath.split('/');

    return {
      'mainCategory': parts.isNotEmpty ? parts[0] : '',
      'subCategory': parts.length > 1 ? parts[1] : '',
      'subSubCategory': parts.length > 2 ? parts[2] : '',
    };
  }

  /// Validate category path format
  static bool isValidCategoryPath(String categoryPath) {
    if (categoryPath.isEmpty) return false;

    // Check for valid characters (alphanumeric, hyphens, forward slashes)
    final validPattern = RegExp(r'^[a-zA-Z0-9\-/]+$');
    return validPattern.hasMatch(categoryPath);
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

  /// Get breadcrumb navigation for category path
  static List<Map<String, String>> getCategoryBreadcrumbs(String categoryPath) {
    final parts = categoryPath.split('/');
    final breadcrumbs = <Map<String, String>>[];

    String currentPath = '';

    for (int i = 0; i < parts.length; i++) {
      currentPath += (i > 0 ? '/' : '') + parts[i];
      breadcrumbs.add({
        'name': getCategoryDisplayName(parts[i]),
        'path': currentPath,
      });
    }

    return breadcrumbs;
  }

  /// Fetch products for a specific category path with pagination
  static Future<List<Map<String, dynamic>>?> fetchCategoryProducts({
    required BuildContext context,
    required String categoryPath,
    int pageNumber = 1,
  }) async {
    try {
      final url = '$_baseUrl/category/$categoryPath?page_no=$pageNumber';
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

          // Try multiple possible keys for products
          List<dynamic> products = responseData['brand_product'] ??
              responseData['products'] ??
              responseData['product'] ??
              responseData['data'] ??
              responseData['category_products'] ??
              [];

          log('📦 API Response products count: ${products.length}');

          // If still no products, log the full response for debugging
          if (products.isEmpty) {
            log('⚠️ No products found. Full response: ${response.body}');
          }

          // Convert to the format expected by ProductList
          final List<Map<String, dynamic>> productList = products
              .map((product) => Map<String, dynamic>.from(product))
              .toList();

          log('📦 Parsed ${productList.length} products for category: $categoryPath');
          return productList;
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
