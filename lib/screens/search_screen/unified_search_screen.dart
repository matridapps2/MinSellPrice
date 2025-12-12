import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/navigation/product_list_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/brand_image.dart';

/// Unified search screen that handles both brand and product searches
class UnifiedSearchScreen extends StatefulWidget {
  final SearchType initialSearchType;

  const UnifiedSearchScreen({
    super.key,
    this.initialSearchType = SearchType.product,
  });

  @override
  State<UnifiedSearchScreen> createState() => _UnifiedSearchScreenState();
}

enum SearchType {
  brand,
  product,
}

class _UnifiedSearchScreenState extends State<UnifiedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  static const int _maxRecentSearches = 8;
  static const String _recentBrandSearchesKey = 'recent_brand_searches';
  static const String _recentProductSearchesKey = 'recent_product_searches';

  SearchType _currentSearchType = SearchType.product;
  bool _isSearching = false;
  String _currentSearchQuery = '';

  // Brand search data
  List<Map<String, dynamic>> _allBrands = [];
  List<Map<String, dynamic>> _brandSearchResults = [];
  List<Map<String, dynamic>> _recentBrandSearches = [];

  // Product search data
  List<Map<String, dynamic>> _productSearchResults = [];
  List<Map<String, dynamic>> _recentProductSearches = [];

  @override
  void initState() {
    super.initState();
    _currentSearchType = widget.initialSearchType;
    _loadRecentSearches();
    if (_currentSearchType == SearchType.brand) {
      _loadAllBrands();
    }
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

  /// Load recent searches based on current search type
  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load brand recent searches
      final recentBrandSearchesJson =
          prefs.getStringList(_recentBrandSearchesKey) ?? [];
      setState(() {
        _recentBrandSearches = recentBrandSearchesJson
            .map((json) => Map<String, dynamic>.from(jsonDecode(json)))
            .toList();
      });

      // Load product recent searches
      final recentProductSearchesJson =
          prefs.getStringList(_recentProductSearchesKey) ?? [];
      setState(() {
        _recentProductSearches = recentProductSearchesJson
            .map((json) => Map<String, dynamic>.from(jsonDecode(json)))
            .toList();
      });

      log('Loaded ${_recentBrandSearches.length} brand searches and ${_recentProductSearches.length} product searches');
    } catch (e) {
      log('Error loading recent searches: $e');
    }
  }

  /// Add brand to recent searches
  Future<void> _addBrandToRecentSearches(Map<String, dynamic> brand) async {
    try {
      _recentBrandSearches
          .removeWhere((item) => item['brand_id'] == brand['brand_id']);
      _recentBrandSearches.insert(0, brand);

      if (_recentBrandSearches.length > _maxRecentSearches) {
        _recentBrandSearches =
            _recentBrandSearches.take(_maxRecentSearches).toList();
      }

      final prefs = await SharedPreferences.getInstance();
      final recentSearchesJson =
          _recentBrandSearches.map((brand) => jsonEncode(brand)).toList();
      await prefs.setStringList(_recentBrandSearchesKey, recentSearchesJson);

      setState(() {});
      log('Added brand to recent searches: ${brand['brand_name']}');
    } catch (e) {
      log('Error saving brand recent search: $e');
    }
  }

  /// Add product to recent searches
  Future<void> _addProductToRecentSearches(Map<String, dynamic> product) async {
    try {
      _recentProductSearches
          .removeWhere((item) => item['product_id'] == product['product_id']);
      _recentProductSearches.insert(0, product);

      if (_recentProductSearches.length > _maxRecentSearches) {
        _recentProductSearches =
            _recentProductSearches.take(_maxRecentSearches).toList();
      }

      final prefs = await SharedPreferences.getInstance();
      final recentSearchesJson =
          _recentProductSearches.map((product) => jsonEncode(product)).toList();
      await prefs.setStringList(_recentProductSearchesKey, recentSearchesJson);

      setState(() {});
      log('Added product to recent searches: ${product['product_name']}');
    } catch (e) {
      log('Error saving product recent search: $e');
    }
  }

  /// Clear recent searches based on current search type
  Future<void> _clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentSearchType == SearchType.brand) {
        await prefs.remove(_recentBrandSearchesKey);
        setState(() {
          _recentBrandSearches.clear();
        });
        log('Cleared brand recent searches');
      } else {
        await prefs.remove(_recentProductSearchesKey);
        setState(() {
          _recentProductSearches.clear();
        });
        log('Cleared product recent searches');
      }
    } catch (e) {
      log('Error clearing recent searches: $e');
    }
  }

  /// Load all brands from API
  Future<void> _loadAllBrands() async {
    try {
      log('Loading brands using centralized API method');
      final brandsData = await BrandsApi.fetchAllBrands(context);

      final homeGardenBrands = (brandsData["All Brand"] ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

      setState(() {
        _allBrands = [...homeGardenBrands];
      });

      log('Loaded ${_allBrands.length} brands from centralized API');
    } catch (e) {
      log('Exception loading brands from centralized API: ${e.toString()}');
    }
  }

  /// Perform brand search
  Future<void> _performBrandSearch(String query) async {
    if (query.length < 3) {
      if (mounted) {
        setState(() {
          _brandSearchResults = [];
          _isSearching = false;
        });
      }
      return;
    }

    _currentSearchQuery = query;

    setState(() {
      _isSearching = true;
    });

    try {
      final results = _allBrands
          .where((brand) {
            final brandName =
                brand['brand_name']?.toString().toLowerCase() ?? '';
            return brandName.contains(query.toLowerCase());
          })
          .take(5)
          .toList();

      log('Brand search query: "$query"');
      log('Found ${results.length} brand results');

      if (mounted && _currentSearchQuery == query) {
        setState(() {
          _brandSearchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted && _currentSearchQuery == query) {
        setState(() {
          _brandSearchResults = [];
          _isSearching = false;
        });
      }
      log('Error searching brands: $e');
    }
  }

  /// Perform product search using API
  Future<void> _performProductSearch(String query) async {
    if (query.length < 3) {
      if (mounted) {
        setState(() {
          _productSearchResults = [];
          _isSearching = false;
        });
      }
      return;
    }

    _currentSearchQuery = query;

    setState(() {
      _isSearching = true;
    });

    try {
      log('Performing product API search for query: "$query"');

      final searchData = await BrandsApi.fetchSearchProduct(context, query);

      if (searchData != null) {
        final List<dynamic> jsonList = searchData['brand_product'] ?? [];
        final List<Map<String, dynamic>> allResults =
            jsonList.map((e) => Map<String, dynamic>.from(e)).toList();

        // Filter out products with invalid or null key values
        final List<Map<String, dynamic>> validResults =
            allResults.where((product) {
          final productId = product['product_id'];
          final productMpn = product['product_mpn'];
          final productName = product['product_name'];
          final brandName = product['brand_name'];

          final isValidProductId =
              productId != null && (productId is int && productId > 0) ||
                  (productId is String &&
                      int.tryParse(productId) != null &&
                      int.parse(productId) > 0);

          final isValidMpn = productMpn != null &&
              productMpn.toString().trim().isNotEmpty &&
              productMpn.toString() != "0";

          final isValidProductName =
              productName != null && productName.toString().trim().isNotEmpty;

          final isValidBrandName = brandName != null &&
              brandName.toString().trim().isNotEmpty &&
              brandName.toString() != "0";

          return isValidProductId &&
              isValidMpn &&
              isValidProductName &&
              isValidBrandName;
        }).toList();

        log('Product API search returned ${allResults.length} total results, ${validResults.length} valid results');

        if (mounted && _currentSearchQuery == query) {
          setState(() {
            _productSearchResults = validResults;
            _isSearching = false;
          });
        }
      } else {
        log('No product results found for query: "$query"');
        if (mounted && _currentSearchQuery == query) {
          setState(() {
            _productSearchResults = [];
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      log('Error performing product API search: $e');
      if (mounted && _currentSearchQuery == query) {
        setState(() {
          _productSearchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  /// Navigate to brand product list
  void _navigateToBrandProductList(Map<String, dynamic> brand) {
    _addBrandToRecentSearches(brand);

    ProductListNavigation.navigateToBrandProducts(
      context,
      brandId: brand['brand_id'].toString(),
      brandName: brand['brand_name'] ?? '',
    );
  }

  /// Navigate to product details
  void _navigateToProductDetails(Map<String, dynamic> product) {
    try {
      log('Navigating to product details for: ${product['product_name']}');

      final productId = product['product_id'];
      final productMpn = product['product_mpn'];
      final productName = product['product_name'];
      final brandName = product['brand_name'];

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
        log('Cannot navigate: Invalid product data');
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

      _addProductToRecentSearches(product);

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

  /// Switch search type and load data if needed
  void _switchSearchType(SearchType type) {
    if (_currentSearchType == type) return;

    setState(() {
      _currentSearchType = type;
      _searchController.clear();
      _brandSearchResults.clear();
      _productSearchResults.clear();
      _isSearching = false;
    });

    if (type == SearchType.brand && _allBrands.isEmpty) {
      _loadAllBrands();
    }
  }

  /// Build recent searches widget
  Widget _buildRecentSearches() {
    final recentSearches = _currentSearchType == SearchType.brand
        ? _recentBrandSearches
        : _recentProductSearches;

    if (recentSearches.isEmpty) {
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
            itemCount: recentSearches.length,
            itemBuilder: (context, index) {
              final item = recentSearches[index];
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
                    onTap: () {
                      if (_currentSearchType == SearchType.brand) {
                        _navigateToBrandProductList(item);
                      } else {
                        _navigateToProductDetails(item);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Image
                          Container(
                            width: 60,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[100],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _currentSearchType == SearchType.brand
                                  ? BrandImageWidget(
                                      key: ValueKey(
                                          'recent_brand_${item['brand_id']}_$index'),
                                      brand: item,
                                      width: 60,
                                      height: 50,
                                    )
                                  : item['product_image'] != null
                                      ? Image.network(
                                          item['product_image'],
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
                                            borderRadius:
                                                BorderRadius.circular(8),
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
                          // Name
                          Text(
                            _currentSearchType == SearchType.brand
                                ? item['brand_name']?.toString() ?? ''
                                : item['product_name']?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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

  /// Build search results
  Widget _buildSearchResults() {
    if (_currentSearchType == SearchType.brand) {
      return _buildBrandSearchResults();
    } else {
      return _buildProductSearchResults();
    }
  }

  /// Build brand search results
  Widget _buildBrandSearchResults() {
    if (_brandSearchResults.isEmpty) {
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
              'No brands found',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _brandSearchResults.length,
      itemBuilder: (context, index) {
        final brand = _brandSearchResults[index];
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
              onTap: () => _navigateToBrandProductList(brand),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50],
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BrandImageWidget(
                          key: ValueKey('brand_${brand['brand_id']}_$index'),
                          brand: brand,
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            brand['brand_name']?.toString() ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'View products',
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
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
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
    );
  }

  /// Build product search results
  Widget _buildProductSearchResults() {
    if (_productSearchResults.isEmpty) {
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
              'Try searching with different keywords',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _productSearchResults.length,
      itemBuilder: (context, index) {
        final product = _productSearchResults[index];
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
              onTap: () => _navigateToProductDetails(product),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50],
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: product['product_image'] != null
                            ? Image.network(
                                product['product_image'],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[400],
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
                                  borderRadius: BorderRadius.circular(12),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['product_name']?.toString() ?? '',
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
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Fixed Header with Search Type Tabs and Search Bar
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
                         Expanded(
                          child: Text(
                           _currentSearchType == SearchType.brand
                             ? 'Search Brands'
                             : 'Search Products',

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
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
                          _currentSearchQuery = '';
                          setState(() {
                            if (_currentSearchType == SearchType.brand) {
                              _brandSearchResults.clear();
                            } else {
                              _productSearchResults.clear();
                            }
                            _isSearching = false;
                          });
                        } else if (trimmedValue.length >= 3) {
                          if (_currentSearchType == SearchType.brand) {
                            _performBrandSearch(trimmedValue);
                          } else {
                            _performProductSearch(trimmedValue);
                          }
                        } else {
                          _currentSearchQuery = '';
                          setState(() {
                            if (_currentSearchType == SearchType.brand) {
                              _brandSearchResults.clear();
                            } else {
                              _productSearchResults.clear();
                            }
                            _isSearching = false;
                          });
                        }
                      },
                      onFieldSubmitted: (value) {
                        if (value.trim().isNotEmpty &&
                            value.trim().length >= 3) {
                          if (_currentSearchType == SearchType.brand) {
                            _performBrandSearch(value.trim());
                          } else {
                            _performProductSearch(value.trim());
                          }
                        }
                      },
                      cursorColor: AppColors.primary,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: _currentSearchType == SearchType.brand
                            ? 'What brand are you looking for?'
                            : 'Search by product name, MPN, or brand...',
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
                                      if (_currentSearchType ==
                                          SearchType.brand) {
                                        _brandSearchResults.clear();
                                      } else {
                                        _productSearchResults.clear();
                                      }
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
                          'Searching...',
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
                } else {
                  return _buildSearchResults();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
