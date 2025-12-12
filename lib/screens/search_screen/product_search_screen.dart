import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/navigation/product_list_navigation.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  static const int _maxRecentSearches = 8;

  bool _isSearching = false;

  static const String _recentSearchesKey = 'recent_searches';

  List<Map<String, dynamic>> _allProduct = [];
  List<Map<String, dynamic>> _recentSearches = [];
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    // Add listener to update UI when text changes
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentSearchesJson = prefs.getStringList(_recentSearchesKey) ?? [];

      setState(() {
        _recentSearches = recentSearchesJson
            .map((json) => Map<String, dynamic>.from(jsonDecode(json)))
            .toList();
      });

      log('Loaded ${_recentSearches.length} recent searches');
    } catch (e) {
      log('Error loading recent searches: $e');
    }
  }

  Future<void> _addToRecentSearches(Map<String, dynamic> product) async {
    try {
      _recentSearches
          .removeWhere((item) => item['brand_id'] == product['brand_id']);

      // Add to beginning
      _recentSearches.insert(0, product);

      // Keep only the most recent searches
      if (_recentSearches.length > _maxRecentSearches) {
        _recentSearches = _recentSearches.take(_maxRecentSearches).toList();
      }

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final recentSearchesJson =
          _recentSearches.map((product) => jsonEncode(product)).toList();
      await prefs.setStringList(_recentSearchesKey, recentSearchesJson);

      setState(() {});
      log('Added product to recent searches: ${product['brand_name']}');
    } catch (e) {
      log('Error saving recent search: $e');
    }
  }

  // Clear all recent searches
  Future<void> _clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);

      setState(() {
        _recentSearches.clear();
      });

      log('Cleared all recent searches');
    } catch (e) {
      log('Error clearing recent searches: $e');
    }
  }

  Future<void> _loadSearchProduct(String query) async {
    try {
      log('Loading Searched Product API method');
      // Load initial data with empty search to get all products
      final searchData = await BrandsApi.fetchSearchProduct(context, query);

      if (searchData != null) {
        final List<dynamic> jsonList = searchData['brand_product'] ?? [];
        final List<Map<String, dynamic>> allProducts =
            jsonList.map((e) => Map<String, dynamic>.from(e)).toList();

        // Filter out products with invalid or null key values
        final List<Map<String, dynamic>> validProducts =
            allProducts.where((product) {
          // Check if essential fields have valid values
          final productId = product['product_id'];
          final productMpn = product['product_mpn'];
          final productName = product['product_name'];
          final brandName = product['brand_name'];

          // Product ID should be a valid number greater than 0
          final isValidProductId =
              productId != null && (productId is int && productId > 0) ||
                  (productId is String &&
                      int.tryParse(productId) != null &&
                      int.parse(productId) > 0);

          // Product MPN should not be null, empty, or "0"
          final isValidMpn = productMpn != null &&
              productMpn.toString().trim().isNotEmpty &&
              productMpn.toString() != "0";

          // Product name should not be null or empty
          final isValidProductName =
              productName != null && productName.toString().trim().isNotEmpty;

          // Brand name should not be null, empty, or "0"
          final isValidBrandName = brandName != null &&
              brandName.toString().trim().isNotEmpty &&
              brandName.toString() != "0";

          final isValid = isValidProductId &&
              isValidMpn &&
              isValidProductName &&
              isValidBrandName;

          if (!isValid) {
            log('Filtering out invalid product during initial load: ID=$productId, MPN=$productMpn, Name=$productName, Brand=$brandName');
          }

          return isValid;
        }).toList();

        setState(() {
          _allProduct = validProducts;
        });

        log('Loaded ${allProducts.length} total products, ${validProducts.length} valid products from centralized API');

        if (_allProduct.isNotEmpty) {
          log('Sample valid product data: ${_allProduct.first}');
        }
      } else {
        log('No data received from search API');
        setState(() {
          _allProduct = [];
        });
      }
    } catch (e) {
      log('Exception loading products from centralized API: ${e.toString()}');
      setState(() {
        _allProduct = [];
      });
    }
  }

  /// Perform search using the API with the given query
  /// This method searches by product MPN, name, brand name, or any other relevant field
  Future<void> _performApiSearch(String query) async {
    // Only perform search if query has at least 3 characters
    if (query.length < 3) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
      return;
    }

    if (query.trim().isEmpty) {
      // If query is empty, load all products
      await _loadSearchProduct(query);
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      log('Performing API search for query: "$query"');

      final searchData = await BrandsApi.fetchSearchProduct(context, query);

      if (searchData != null) {
        final List<dynamic> jsonList = searchData['brand_product'] ?? [];
        final List<Map<String, dynamic>> allResults =
            jsonList.map((e) => Map<String, dynamic>.from(e)).toList();

        // Filter out products with invalid or null key values
        final List<Map<String, dynamic>> validResults =
            allResults.where((product) {
          // Check if essential fields have valid values
          final productId = product['product_id'];
          final productMpn = product['product_mpn'];
          final productName = product['product_name'];
          final brandName = product['brand_name'];

          // Product ID should be a valid number greater than 0
          final isValidProductId =
              productId != null && (productId is int && productId > 0) ||
                  (productId is String &&
                      int.tryParse(productId) != null &&
                      int.parse(productId) > 0);

          // Product MPN should not be null, empty, or "0"
          final isValidMpn = productMpn != null &&
              productMpn.toString().trim().isNotEmpty &&
              productMpn.toString() != "0";

          // Product name should not be null or empty
          final isValidProductName =
              productName != null && productName.toString().trim().isNotEmpty;

          // Brand name should not be null, empty, or "0"
          final isValidBrandName = brandName != null &&
              brandName.toString().trim().isNotEmpty &&
              brandName.toString() != "0";

          final isValid = isValidProductId &&
              isValidMpn &&
              isValidProductName &&
              isValidBrandName;

          if (!isValid) {
            log('Filtering out invalid product: ID=$productId, MPN=$productMpn, Name=$productName, Brand=$brandName');
          }

          return isValid;
        }).toList();

        log('API search returned ${allResults.length} total results, ${validResults.length} valid results for query: "$query"');

        if (mounted) {
          setState(() {
            _searchResults = validResults;
            _isSearching = false;
          });
        }
      } else {
        log('No results found for query: "$query"');
        if (mounted) {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      log('Error performing API search: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  /// Perform local search on already loaded data
  /// This method searches through the cached data for quick results
  Future<void> _performLocalSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = _allProduct
          .where((product) {
            // Search by multiple fields: product name, MPN, brand name
            final productName =
                product['product_name']?.toString().toLowerCase() ?? '';
            final productMpn =
                product['product_mpn']?.toString().toLowerCase() ?? '';
            final brandName =
                product['brand_name']?.toString().toLowerCase() ?? '';
            final queryLower = query.toLowerCase();

            return productName.contains(queryLower) ||
                productMpn.contains(queryLower) ||
                brandName.contains(queryLower);
          })
          .take(10) // Limit results for better performance
          .toList();

      log('Local search query: "$query"');
      log('Found ${results.length} results');

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      log('Error in local search: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  /// Navigate to product details screen
  void _navigateToProductDetails(Map<String, dynamic> product) {
    try {
      log('Navigating to product details for: ${product['product_name']}');
      log('Product data: $product');

      // Validate product data before navigation
      final productId = product['product_id'];
      final productMpn = product['product_mpn'];
      final productName = product['product_name'];
      final brandName = product['brand_name'];

      // Check if essential fields have valid values
      final isValidProductId =
          productId != null && (productId is int && productId > 0) ||
              (productId is String &&
                  int.tryParse(productId) != null &&
                  int.parse(productId) > 0);

      final isValidMpn = productMpn != null &&
          productMpn.toString().trim().isNotEmpty &&
          productMpn.toString() != "--";

      final isValidProductName =
          productName != null && productName.toString().trim().isNotEmpty;

      final isValidBrandName = brandName != null &&
          brandName.toString().trim().isNotEmpty &&
          brandName.toString() != " ";

      if (!isValidProductId ||
          !isValidMpn ||
          !isValidProductName ||
          !isValidBrandName) {
        log('Cannot navigate: Invalid product data - ID: $productId, MPN: $productMpn, Name: $productName, Brand: $brandName');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cannot open product details: Invalid product data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Add to recent searches
      _addToRecentSearches(product);

      // Navigate to product details screen
      ProductListNavigation.navigateToProductDetails(
        context,
        productId: int.tryParse(productId.toString()) ?? 0,
        brandName: brandName.toString(),
        productMpn: productMpn.toString(),
        productImage: product['product_image'] ?? '',
        productPrice: double.tryParse(
                product['vendorprice_price']?.toString() ?? '0.00') ??
            0.0,
      );
    } catch (e) {
      log('Error navigating to product details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error navigating to product details: $e',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _searchAndNavigate(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      // Perform API search for the query
      //await _performApiSearch(query);

      if (_searchResults.isNotEmpty) {
        // Navigate to the first result
        _navigateToProductDetails(_searchResults.first);
      } else {
        // Try local search as fallback
        await _performLocalSearch(query);

        if (_searchResults.isNotEmpty) {
          _navigateToProductDetails(_searchResults.first);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No products found with this search term',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      log('Error searching: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error searching: $e',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: _clearRecentSearches,
                icon: const Icon(Icons.clear_all, size: 16, color: Colors.red),
                label: const Text(
                  'Clear All',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final product = _recentSearches[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12.0),
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => _navigateToProductDetails(product),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Product Image
                          Container(
                            width: 60,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[100],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: product['product_image'] != null
                                  ? Image.network(
                                      product['product_image'],
                                      width: 60,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 60,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey[400],
                                            size: 20,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 60,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[400],
                                        size: 20,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          // Product Name
                          Expanded(
                            child: Text(
                              product['product_name']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Fixed Header with Search
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Discover Products',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ),
                  // Search Bar
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      enabled: true,
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        log('Search text changed: "$value"');
                        final trimmedValue = value.trim();
                        if (trimmedValue.isEmpty) {
                          setState(() {
                            _searchResults.clear();
                            _isSearching = false;
                          });
                          log('Cleared search results');
                        } else if (trimmedValue.length >= 3) {
                          log('Performing API search for: "$trimmedValue"');
                          _performApiSearch(trimmedValue);
                        } else {
                          // Clear results if less than 3 characters
                          setState(() {
                            _searchResults.clear();
                            _isSearching = false;
                          });
                          log('Search query too short (${trimmedValue.length} characters), cleared results');
                        }
                      },
                      onFieldSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          _searchAndNavigate(value.trim());
                        }
                      },
                      cursorColor: AppColors.primary,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by product name, MPN, or brand...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: _searchController.text.length >= 3
                            ? null
                            : Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.search_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? Container(
                                margin: const EdgeInsets.all(8),
                                child: IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.grey[600],
                                      size: 16,
                                    ),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchResults.clear();
                                      _isSearching = false;
                                    });
                                  },
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 18.0,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Scrollable Content
          Expanded(
            child: Builder(
              builder: (context) {
                log('Building search results - Text: "${_searchController.text}", Results: ${_searchResults.length}, Searching: $_isSearching');
                if (_isSearching) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Searching products...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (_searchController.text.isEmpty) {
                  // Show recent searches when no search is active
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildRecentSearches(),
                      ],
                    ),
                  );
                } else if (_searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No valid products found',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Some products were filtered out due to invalid data\nTry searching with different keywords',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final product = _searchResults[index];
                            log('ListView.builder - Index $index: "${product['product_name']}" - MPN: "${product['product_mpn']}" - Brand: ${product['brand_name']}');
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    _navigateToProductDetails(product);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.grey[50],
                                            border: Border.all(
                                              color: Colors.grey[200]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: product['product_image'] !=
                                                    null
                                                ? Image.network(
                                                    product['product_image'],
                                                    width: 70,
                                                    height: 70,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        width: 70,
                                                        height: 70,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          color:
                                                              Colors.grey[400],
                                                          size: 24,
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Container(
                                                    width: 70,
                                                    height: 70,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.grey[400],
                                                      size: 24,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product['product_name']
                                                        ?.toString() ??
                                                    '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${product['brand_name'] ?? ''} • ${product['product_mpn'] ?? ''}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: AppColors.primary,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
