import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:minsellprice/services/category_service.dart';
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/screens/product_details_screen/product_details_screen.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';

/// Wrapper for ProductList that handles category-specific API calls with pagination
class CategoryProductList extends StatefulWidget {
  final String categoryPath;
  final String categoryName;

  const CategoryProductList({
    super.key,
    required this.categoryPath,
    required this.categoryName,
  });

  @override
  State<CategoryProductList> createState() => _CategoryProductListState();
}

class _CategoryProductListState extends State<CategoryProductList> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _productData = [];
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  int _totalProductCount = 0;
  DateTime? _lastLoadMoreTime;

  @override
  void initState() {
    super.initState();
    _loadCategoryProducts();
  }

  Future<void> _loadCategoryProducts({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
          _currentPage = 1;
        });
      } else {
        setState(() {
          _isLoadingMore = true;
        });
      }

      log('🌐 Loading products for category: ${widget.categoryName}');
      log('📂 Category path: ${widget.categoryPath}');
      log('📄 Page: $_currentPage');

      // Fetch products from category API with pagination
      final products = await CategoryService.fetchCategoryProducts(
        context: context,
        categoryPath: widget.categoryPath,
        pageNumber: _currentPage,
      );

      if (products != null && products.isNotEmpty) {
        setState(() {
          if (loadMore) {
            _productData.addAll(products);
            // Use same logic as ProductProvider
            _hasMoreData =
                _productData.length < _totalProductCount && products.isNotEmpty;

            if (products.isEmpty) {
              _hasMoreData = false;
            }

            // Additional check for small batches
            if (products.length < 100 && _hasMoreData) {
              if (products.length < 50) {
                _hasMoreData = false;
              }
            }
          } else {
            _productData = products;
            // For first load, we need to get total count from API response
            // For now, assume there are more if we got a full page
            _hasMoreData = products.length >= 100;
          }
          _isLoading = false;
          _isLoadingMore = false;
        });
        log('✅ Loaded ${products.length} products for ${widget.categoryName} (Page $_currentPage)');
        log('📦 Total products: ${_productData.length}');
        log('🔄 Has more data: $_hasMoreData');
      } else {
        setState(() {
          if (loadMore) {
            _hasMoreData = false;
            _isLoadingMore = false;
            log('🏁 Reached end of products - no more data available');
          } else {
            _errorMessage = 'No products found for this category';
            _isLoading = false;
          }
        });
        log('⚠️ No more products found for ${widget.categoryName}');
      }
    } catch (e) {
      log('❌ Error loading category products: $e');
      setState(() {
        _errorMessage = 'Failed to load products: $e';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _loadMoreProducts() {
    if (!_hasMoreData || _isLoadingMore) return;

    final now = DateTime.now();
    if (_lastLoadMoreTime != null &&
        now.difference(_lastLoadMoreTime!) <
            const Duration(milliseconds: 1000)) {
      return;
    }

    log('🔄 _loadMoreProducts called - isLoadingMore: $_isLoadingMore, hasMoreData: $_hasMoreData, currentPage: $_currentPage');

    _isLoadingMore = true;
    _lastLoadMoreTime = now;

    try {
      _currentPage++;
      log('📄 Loading page $_currentPage...');
      _loadCategoryProducts(loadMore: true);
    } catch (e) {
      log('❌ Error in _loadMoreProducts: $e');
      _isLoadingMore = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.categoryName),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.categoryName),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCategoryProducts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Use custom ProductList without Brand API and search bar
    return CategoryProductListWidget(
      categoryName: widget.categoryName,
      productData: _productData,
      hasMoreData: _hasMoreData,
      isLoadingMore: _isLoadingMore,
      onLoadMore: _loadMoreProducts,
    );
  }
}

/// Custom ProductList widget for categories without Brand API and search bar
class CategoryProductListWidget extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> productData;
  final bool hasMoreData;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  const CategoryProductListWidget({
    super.key,
    required this.categoryName,
    required this.productData,
    required this.hasMoreData,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  @override
  State<CategoryProductListWidget> createState() =>
      _CategoryProductListWidgetState();
}

class _CategoryProductListWidgetState extends State<CategoryProductListWidget> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<VendorProduct> _products = [];
  List<VendorProduct> _allProducts = [];
  List<VendorProduct> _filteredProducts = [];
  List<VendorProduct> _searchResults = [];

  bool _hasUserScrolled = false;
  bool _isSearching = false;
  bool _isApplyingFilters = false;

  // Filter state
  List<String> _selectedVendors = [];
  int? _priceSorting;
  RangeValues _priceRange = const RangeValues(0, 1000);
  double _maxPrice = 1000.0;
  bool _inStockOnly = false;
  bool _onSaleOnly = false;

  // Vendor data
  Map<String, int> _vendorProductCounts = {};

  @override
  void initState() {
    super.initState();
    _convertProductData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(CategoryProductListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productData != widget.productData) {
      _convertProductData();
      log('🔄 Updated product data - now have ${_products.length} products');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _convertProductData() {
    _products = widget.productData
        .map((product) => VendorProduct.fromJson(product))
        .toList();
    _allProducts = List.from(_products);
    _filteredProducts = List.from(_products);
    _extractVendorData();
    _calculatePriceRange();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection !=
        ScrollDirection.idle) {
      _hasUserScrolled = true; // User scrolled at least once
    }

    // Simplified scroll detection - trigger when near bottom (same as ProductProvider)
    if (_hasUserScrolled &&
        widget.hasMoreData &&
        !widget.isLoadingMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100) {
      log('Scroll detection: Triggering load more products');
      widget.onLoadMore();
    }
  }

  /// Extract vendor data from products
  void _extractVendorData() {
    _vendorProductCounts.clear();
    for (var product in _allProducts) {
      if (product.vendorName.isNotEmpty) {
        _vendorProductCounts[product.vendorName] =
            (_vendorProductCounts[product.vendorName] ?? 0) + 1;
      }
    }
    log('Extracted ${_vendorProductCounts.length} vendors from products');
  }

  /// Calculate price range from products
  void _calculatePriceRange() {
    if (_allProducts.isEmpty) return;

    final validPrices = _allProducts
        .map((product) => _parsePrice(product.vendorpricePrice))
        .where((price) => price != null)
        .cast<double>()
        .toList();

    if (validPrices.isNotEmpty) {
      final maxPrice = validPrices.reduce((a, b) => a > b ? a : b);

      setState(() {
        _maxPrice = ((maxPrice / 50).ceil() * 50).toDouble();
        _priceRange = RangeValues(0, _maxPrice);
      });

      log('Price range: \$0 - \$${_maxPrice.toStringAsFixed(2)}');
    }
  }

  /// Parse price from string
  double? _parsePrice(String price) {
    try {
      if (price.isEmpty) return null;
      final cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
      final double? priceValue = double.tryParse(cleanPrice);
      if (priceValue == null || priceValue < 0 || priceValue > 1000000) {
        return null;
      }
      return priceValue;
    } catch (e) {
      log('Error parsing price "$price": $e');
      return null;
    }
  }

  /// Perform search using the API
  Future<void> _performApiSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
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
        final List<VendorProduct> allResults =
            jsonList.map((e) => VendorProduct.fromJson(e)).toList();

        // Filter valid results
        final List<VendorProduct> validResults = allResults.where((product) {
          final isValidProductId = product.productId > 0;
          final isValidMpn =
              product.productMpn.isNotEmpty && product.productMpn != "0";
          final isValidProductName = product.productName.isNotEmpty;
          final isValidBrandName =
              product.brandName.isNotEmpty && product.brandName != "0";

          return isValidProductId &&
              isValidMpn &&
              isValidProductName &&
              isValidBrandName;
        }).toList();

        log('API search returned ${validResults.length} valid results');

        if (mounted) {
          setState(() {
            _searchResults = validResults;
            _isSearching = false;
          });
        }
      } else {
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

  /// Apply filters to products
  void _applyFilters(
    List<String> vendors,
    int? priceSorting,
    RangeValues priceRange,
    bool inStockOnly,
    bool onSaleOnly,
  ) async {
    // Show loading state
    setState(() {
      _isApplyingFilters = true;
    });

    // Add small delay to show loading indicator
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _selectedVendors = vendors;
      _priceSorting = priceSorting;
      _priceRange = priceRange;
      _inStockOnly = inStockOnly;
      _onSaleOnly = onSaleOnly;

      // Start with all products
      _filteredProducts = List.from(_allProducts);

      // Apply vendor filter
      if (vendors.isNotEmpty) {
        _filteredProducts = _filteredProducts
            .where((product) => vendors.contains(product.vendorName))
            .toList();
        log('After vendor filter: ${_filteredProducts.length} products');
      }

      // Apply price range filter
      _filteredProducts = _filteredProducts.where((product) {
        double? price = _parsePrice(product.vendorpricePrice);
        return price != null &&
            price >= priceRange.start &&
            price <= priceRange.end;
      }).toList();
      log('After price filter: ${_filteredProducts.length} products');

      // Apply sorting
      if (priceSorting != null) {
        if (priceSorting == 1) {
          // Price: Low to High
          _filteredProducts.sort((a, b) {
            double priceA = _parsePrice(a.vendorpricePrice) ?? 0;
            double priceB = _parsePrice(b.vendorpricePrice) ?? 0;
            return priceA.compareTo(priceB);
          });
          log('Applied sorting: Price Low to High');
        } else if (priceSorting == 2) {
          // Price: High to Low
          _filteredProducts.sort((a, b) {
            double priceA = _parsePrice(a.vendorpricePrice) ?? 0;
            double priceB = _parsePrice(b.vendorpricePrice) ?? 0;
            return priceB.compareTo(priceA);
          });
          log('Applied sorting: Price High to Low');
        } else if (priceSorting == 3) {
          // Name: A to Z
          _filteredProducts
              .sort((a, b) => a.productName.compareTo(b.productName));
          log('Applied sorting: Name A to Z');
        } else if (priceSorting == 4) {
          // Name: Z to A
          _filteredProducts
              .sort((a, b) => b.productName.compareTo(a.productName));
          log('Applied sorting: Name Z to A');
        }
      }

      log('Final filtered products: ${_filteredProducts.length}');

      // Hide loading state
      _isApplyingFilters = false;
    });
  }

  /// Clear all filters
  void _clearAllFilters() {
    setState(() {
      _selectedVendors.clear();
      _priceSorting = null;
      _priceRange = RangeValues(0, _maxPrice);
      _inStockOnly = false;
      _onSaleOnly = false;
      _filteredProducts = List.from(_allProducts);
    });
    log('Cleared all filters');
  }

  /// Check if any filter is active
  bool _isAnyFilterActive() {
    bool hasVendorFilter = _selectedVendors.isNotEmpty;
    bool hasPriceFilter = _priceRange.end < _maxPrice;
    bool hasSorting = _priceSorting != null;
    bool hasOtherFilters = _inStockOnly || _onSaleOnly;
    return hasVendorFilter || hasPriceFilter || hasSorting || hasOtherFilters;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: CategoryFilterMenu(
        allProducts: _allProducts,
        categoryName: widget.categoryName,
        maxPrice: _maxPrice,
        currentVendorFilters: _selectedVendors,
        currentPriceSorting: _priceSorting,
        currentPriceRange: _priceRange,
        currentInStockOnly: _inStockOnly,
        currentOnSaleOnly: _onSaleOnly,
        vendorProductCounts: _vendorProductCounts,
        onFiltersApplied: _applyFilters,
      ),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 5),
                _buildProductCountBadge(),
                const SizedBox(height: 5),
                _buildProductList(),
                const SizedBox(height: 10),
              ],
            ),
          ),
          // Loading overlay when applying filters
          if (_isApplyingFilters)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Applying Filters...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      surfaceTintColor: Colors.white,
      toolbarHeight: .25 * w,
      backgroundColor: Colors.white,
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: SizedBox(
          width: w * .54,
          child: Text(
            widget.categoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: w * .06),
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/minsellprice_app_icon.png',
              height: .23 * w,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                if (value.trim().isNotEmpty) {
                  _performApiSearch(value.trim());
                } else {
                  setState(() {
                    _searchResults.clear();
                    _isSearching = false;
                  });
                }
              },
              onFieldSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _performApiSearch(value.trim());
                }
              },
              cursorColor: AppColors.primary,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search ${widget.categoryName} products...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 20,
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
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
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
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(25),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCountBadge() {
    bool isSearching = _searchController.text.isNotEmpty;
    bool isFiltered = _isAnyFilterActive();

    String title;
    String subtitle;

    if (isSearching) {
      title = 'Search Results';
      subtitle =
          '${_searchResults.length} items found for "${_searchController.text}"';
    } else if (isFiltered) {
      title = 'Filtered Products';
      subtitle = '${_filteredProducts.length} items match your filters';
    } else {
      title = 'Total Products';
      subtitle = '${_products.length} items available';
    }

    return Visibility(
      visible: !isSearching,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Filters Icon Button
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    _scaffoldKey.currentState!.openEndDrawer();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.filter_alt,
                      color: Colors.white,
                      size: w * .05,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Product Count Badge
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isFiltered
                      ? AppColors.primary.withOpacity(0.05)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isFiltered
                          ? AppColors.primary.withOpacity(0.2)
                          : Colors.grey[200]!,
                      width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isFiltered
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isFiltered
                            ? Icons.filter_list
                            : Icons.shopping_bag_outlined,
                        color: AppColors.primary,
                        size: w * .06,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: isFiltered
                                  ? AppColors.primary
                                  : Colors.grey[600],
                              fontSize: w * .045,
                              fontFamily: 'Segoe UI',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: w * .039,
                              fontFamily: 'Segoe UI',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    // Determine which products to display
    List<VendorProduct> productsToDisplay;
    bool isSearching = _searchController.text.isNotEmpty;
    bool isFiltered = _isAnyFilterActive();

    if (isSearching) {
      if (_isSearching) {
        return _buildSearchLoadingState();
      } else if (_searchResults.isEmpty) {
        return _buildSearchEmptyState();
      } else {
        productsToDisplay = _searchResults;
      }
    } else if (isFiltered) {
      if (_filteredProducts.isEmpty) {
        return _buildFilteredEmptyState();
      }
      productsToDisplay = _filteredProducts;
    } else {
      if (_products.isEmpty) {
        return _buildEmptyState();
      }
      productsToDisplay = _products;
    }

    return Expanded(
      child: Align(
        alignment: Alignment.topCenter,
        child: Scrollbar(
          thickness: 4,
          thumbVisibility: true,
          trackVisibility: true,
          interactive: true,
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  Wrap(
                    runSpacing: 10,
                    children: List.generate(
                      productsToDisplay.length,
                      (index) => _buildProductCard(productsToDisplay[index]),
                    ),
                  ),
                  // Loading more indicator (only when not searching/filtering)
                  if (!isSearching && !isFiltered && widget.isLoadingMore)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ),
                  // No more products indicator
                  if (!isSearching &&
                      !isFiltered &&
                      !widget.hasMoreData &&
                      _products.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      child: Column(
                        children: [
                          Container(
                            height: 1,
                            width: 60,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'You\'ve reached the end!',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Segoe UI',
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No more products to load',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Segoe UI',
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchLoadingState() {
    return Flexible(
      child: Container(
        width: w,
        height: h / 1.1,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Searching products...',
              style: TextStyle(
                fontSize: w * 0.05,
                fontFamily: 'Futura BdCn BT Bold',
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Flexible(
      child: Container(
        width: w,
        height: h / 1.1,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: w * 0.3,
              height: w * 0.3,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: w * 0.15,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
            SizedBox(height: h * 0.03),
            Text(
              'No Search Results Found',
              style: TextStyle(
                fontSize: w * 0.06,
                fontFamily: 'Futura BdCn BT Bold',
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: h * 0.015),
            Text(
              'We couldn\'t find any products matching "${_searchController.text}".\nTry searching with different keywords.',
              style: TextStyle(
                fontSize: w * 0.035,
                fontFamily: 'Futura BdCn BT Bold',
                fontWeight: FontWeight.w300,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: h * 0.04),
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _searchResults.clear();
                  _isSearching = false;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.06,
                  vertical: h * 0.018,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.clear_rounded,
                      size: w * 0.035,
                      color: Colors.white,
                    ),
                    SizedBox(width: w * 0.015),
                    Text(
                      'Clear Search',
                      style: TextStyle(
                        fontSize: w * 0.035,
                        fontFamily: 'Futura BdCn BT Bold',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredEmptyState() {
    return Flexible(
      child: Container(
        width: w,
        height: h / 1.1,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: w * 0.3,
              height: w * 0.3,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.filter_list_off_rounded,
                size: w * 0.15,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
            SizedBox(height: h * 0.03),
            Text(
              'No Products Match Your Filters',
              style: TextStyle(
                fontSize: w * 0.06,
                fontFamily: 'Futura BdCn BT Bold',
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: h * 0.015),
            Text(
              'Try adjusting your filters or clear them to see all products.',
              style: TextStyle(
                fontSize: w * 0.035,
                fontFamily: 'Futura BdCn BT Bold',
                fontWeight: FontWeight.w300,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: h * 0.04),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState!.openEndDrawer();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.06,
                      vertical: h * 0.018,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_alt,
                          size: w * 0.035,
                          color: Colors.white,
                        ),
                        SizedBox(width: w * 0.015),
                        Text(
                          'Adjust Filters',
                          style: TextStyle(
                            fontSize: w * 0.035,
                            fontFamily: 'Futura BdCn BT Bold',
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: w * 0.03),
                GestureDetector(
                  onTap: () {
                    _clearAllFilters();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.06,
                      vertical: h * 0.018,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.clear_all,
                          size: w * 0.035,
                          color: Colors.white,
                        ),
                        SizedBox(width: w * 0.015),
                        Text(
                          'Clear Filters',
                          style: TextStyle(
                            fontSize: w * 0.035,
                            fontFamily: 'Futura BdCn BT Bold',
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Flexible(
      child: Container(
        width: w,
        height: h / 1.1,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: w * 0.3,
              height: w * 0.3,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: w * 0.15,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
            SizedBox(height: h * 0.03),
            Text(
              'No Products Found',
              style: TextStyle(
                fontSize: w * 0.06,
                fontFamily: 'Futura BdCn BT Bold',
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: h * 0.015),
            Text(
              'We couldn\'t find any products for this category.\nPlease try a different category.',
              style: TextStyle(
                fontSize: w * 0.035,
                fontFamily: 'Futura BdCn BT Bold',
                fontWeight: FontWeight.w300,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: h * 0.04),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.06,
                  vertical: h * 0.018,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_rounded,
                      size: w * 0.035,
                      color: Colors.white,
                    ),
                    SizedBox(width: w * 0.015),
                    Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: w * 0.035,
                        fontFamily: 'Futura BdCn BT Bold',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(VendorProduct product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                productId: product.productId,
                brandName: widget.categoryName,
                productMPN: product.productMpn,
                productImage: product.productImage,
                productPrice: product.vendorpricePrice,
              ),
            ),
          );
        },
        child: Container(
          width: w * .45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(product),
              _buildProductDetails(product),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(VendorProduct product) {
    return Container(
      width: double.infinity,
      height: w * .45,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
        child: Image.network(
          _getProperImageUrl(product.productImage),
          fit: BoxFit.contain,
          cacheWidth:
              (w * .45 * MediaQuery.of(context).devicePixelRatio).round(),
          cacheHeight:
              (w * .45 * MediaQuery.of(context).devicePixelRatio).round(),
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Icon(
                Icons.image_not_supported_outlined,
                size: w * .08,
                color: Colors.grey[400],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductDetails(VendorProduct product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: w * .25,
            child: Text(
              product.productName.isEmpty
                  ? 'Product Name Not Available'
                  : product.productName,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[800],
                fontFamily: 'Segoe UI',
                fontSize: 18,
                height: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 0),
          SizedBox(
            height: h * .06,
            child: Text(
              'MPN: #${product.productMpn}',
              style: const TextStyle(
                fontFamily: 'Segoe UI',
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 13),
          _buildPriceSection(product),
        ],
      ),
    );
  }

  Widget _buildPriceSection(VendorProduct product) {
    // Check if MSRP is empty or '--'
    bool hasMsrp = product.msrp != '--' && product.msrp.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show MSRP with strikethrough if it exists
          if (hasMsrp) ...[
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '\$${_formatPrice(product.msrp)}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'Segoe UI',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.lineThrough,
                            decorationThickness: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 0.0, top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Add to Cart Price:',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Segoe UI',
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
          ],

          // Show vendor price
          Padding(
            padding: const EdgeInsets.only(right: 10.0, top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '\$${_formatPrice(product.vendorpricePrice)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Segoe UI',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * .02,
                  vertical: w * .015,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${product.vendorIdCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      product.vendorIdCount == 1 ? 'vendor' : 'vendors',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getProperImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'https://www.minsellprice.com/assets/no_image/no_image.jpg';
    }

    if (imageUrl.startsWith('//')) {
      return 'https:$imageUrl';
    }

    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      return 'https://$imageUrl';
    }
    return imageUrl;
  }

  String _formatPrice(String price) {
    try {
      final double? priceValue = double.tryParse(price);
      if (priceValue == null) {
        return price;
      }
      // Format with commas for thousands
      final formatter = NumberFormat('#,###.##');
      return formatter.format(priceValue);
    } catch (e) {
      return price;
    }
  }
}

/* CATEGORY FILTER MENU */

class CategoryFilterMenu extends StatefulWidget {
  final List<VendorProduct> allProducts;
  final String categoryName;
  final double maxPrice;
  final Function(
      List<String> vendors,
      int? priceSorting,
      RangeValues priceRange,
      bool inStockOnly,
      bool onSaleOnly)? onFiltersApplied;

  final List<String> currentVendorFilters;
  final int? currentPriceSorting;
  final RangeValues currentPriceRange;
  final bool currentInStockOnly;
  final bool currentOnSaleOnly;
  final Map<String, int> vendorProductCounts;

  const CategoryFilterMenu({
    super.key,
    required this.allProducts,
    required this.categoryName,
    required this.maxPrice,
    this.onFiltersApplied,
    this.currentVendorFilters = const [],
    this.currentPriceSorting,
    this.currentPriceRange = const RangeValues(0, 1000),
    this.currentInStockOnly = false,
    this.currentOnSaleOnly = false,
    this.vendorProductCounts = const {},
  });

  @override
  State<CategoryFilterMenu> createState() => _CategoryFilterMenuState();
}

class _CategoryFilterMenuState extends State<CategoryFilterMenu> {
  int? tempPriceSorting;
  List<String> tempFilterVendor = [];
  RangeValues priceRange = const RangeValues(0, 1000);
  bool showInStockOnly = false;
  bool showOnSaleOnly = false;

  @override
  void initState() {
    super.initState();

    tempPriceSorting = widget.currentPriceSorting;
    tempFilterVendor = List.from(widget.currentVendorFilters);
    priceRange = widget.currentPriceRange;
    showInStockOnly = widget.currentInStockOnly;
    showOnSaleOnly = widget.currentOnSaleOnly;

    // Ensure price range starts from 0
    if (priceRange.start > 0) {
      priceRange = RangeValues(0, priceRange.end);
    }

    if (priceRange.end > widget.maxPrice) {
      priceRange = RangeValues(priceRange.start, widget.maxPrice);
    }

    log('CategoryFilterMenu initialized with ${widget.vendorProductCounts.length} vendors');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: w * .9,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          AppBar(
            elevation: 2,
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_ios, color: AppColors.primary),
            ),
            surfaceTintColor: Colors.white,
            toolbarHeight: .14 * w,
            backgroundColor: Colors.white,
            centerTitle: false,
            title: Text(
              'Filters',
              style: TextStyle(
                fontSize: w * .05,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            automaticallyImplyLeading: false,
            actionsPadding: const EdgeInsets.only(right: 15),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    tempPriceSorting = null;
                    tempFilterVendor.clear();
                    priceRange = RangeValues(0, widget.maxPrice);
                    showInStockOnly = false;
                    showOnSaleOnly = false;
                  });
                  log('Reset filters: Price range reset to 0 - ${widget.maxPrice}');
                },
                child: Text(
                  'Reset',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: w * .05),
                ),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Price Range'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          RangeSlider(
                            values: priceRange,
                            min: 0,
                            max: widget.maxPrice,
                            divisions:
                                (widget.maxPrice / 50).round().clamp(10, 40),
                            activeColor: AppColors.primary,
                            labels: RangeLabels(
                              '\$${NumberFormat('#,###').format(priceRange.start.round())}',
                              '\$${NumberFormat('#,###').format(priceRange.end.round())}',
                            ),
                            onChanged: (values) {
                              setState(() {
                                priceRange = values;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${NumberFormat('#,###').format(priceRange.start.round())}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '\$${NumberFormat('#,###').format(priceRange.end.round())}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sort By Section
                  _buildSectionTitle('Sort By'),
                  Card(
                    child: Column(
                      children: [
                        _buildSortOption('Price: Low to High', 1),
                        const Divider(height: 1),
                        _buildSortOption('Price: High to Low', 2),
                        const Divider(height: 1),
                        _buildSortOption('Name: A to Z', 3),
                        const Divider(height: 1),
                        _buildSortOption('Name: Z to A', 4),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Vendor Section
                  _buildSectionTitle('Vendors'),
                  Card(
                    child: Column(
                      children: List.generate(
                        _getUniqueVendors().length,
                        (index) {
                          final vendor = _getUniqueVendors()[index];
                          final productCount =
                              _getProductCountForVendor(vendor);
                          final isSelected = tempFilterVendor.contains(vendor);
                          return Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            child: CheckboxListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 2),
                              activeColor: AppColors.primary,
                              title: Text(
                                vendor.isNotEmpty ? vendor : 'Unknown Vendor',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                productCount > 0
                                    ? '$productCount ${productCount == 1 ? 'product' : 'products'}'
                                    : 'No products',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.8)
                                      : Colors.grey,
                                  fontWeight: isSelected
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    tempFilterVendor.add(vendor);
                                  } else {
                                    tempFilterVendor.remove(vendor);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _applyFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: w * .045,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, int value) {
    return RadioListTile<int>(
      dense: true,
      activeColor: AppColors.primary,
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      groupValue: tempPriceSorting,
      onChanged: (int? newValue) {
        setState(() {
          tempPriceSorting = newValue;
        });
      },
    );
  }

  List<String> _getUniqueVendors() {
    if (widget.vendorProductCounts.isEmpty) {
      return [];
    }

    List<String> vendorList = widget.vendorProductCounts.keys.toList();
    vendorList.sort();

    log('CategoryFilterMenu: Displaying ${vendorList.length} vendors');
    return vendorList;
  }

  int _getProductCountForVendor(String vendorName) {
    return widget.vendorProductCounts[vendorName] ?? 0;
  }

  void _applyFilters() {
    if (widget.onFiltersApplied != null) {
      widget.onFiltersApplied!(
        tempFilterVendor,
        tempPriceSorting,
        priceRange,
        showInStockOnly,
        showOnSaleOnly,
      );
    }
  }
}
