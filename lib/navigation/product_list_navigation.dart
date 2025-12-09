import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:minsellprice/screens/unified_product_list_screen.dart';
import 'package:minsellprice/screens/product_details_screen/product_details_screen.dart';

/// Navigation helper for unified product list screen
class ProductListNavigation {
  /// Navigate to brand product list
  static void navigateToBrandProducts(
    BuildContext context, {
    required String brandId,
    required String brandName,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnifiedProductListScreen(
          type: ProductListType.brand,
          identifier: brandName,
          displayName: brandName,
        ),
      ),
    );
  }

  /// Navigate to category product list
  static void navigateToCategoryProducts(
    BuildContext context, {
    required String categoryPath,
    required String categoryName,
  }) {
    log('Navigate to product list');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnifiedProductListScreen(
          type: ProductListType.category,
          identifier: categoryPath,
          displayName: categoryName,
        ),
      ),
    );
  }

  /// Navigate to search results
  static void navigateToSearchResults(
    BuildContext context, {
    required String searchQuery,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnifiedProductListScreen(
          type: ProductListType.search,
          identifier: searchQuery,
          displayName: 'Search: $searchQuery',
        ),
      ),
    );
  }

  /// Navigate to product details (existing functionality)
  static void navigateToProductDetails(
    BuildContext context, {
    required int productId,
    required String brandName,
    required String productMpn,
    required String productImage,
    required double productPrice,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          productId: productId,
          brandName: brandName,
          productMPN: productMpn,
          productImage: productImage,
          productPrice: productPrice,
        ),
      ),
    );
  }
}
