import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:minsellprice/widgets/product_list_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/screens/categories_provider/product_list_provider.dart';
import 'package:minsellprice/screens/home_page/home_page.dart';
import 'package:minsellprice/screens/product_details_screen/product_details_screen.dart';
import 'package:minsellprice/screens/dashboard_screen/dashboard_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/brand_image.dart';
import 'filter_class.dart';

class ProductList extends StatefulWidget {
  const ProductList({
    super.key,
    required this.brandId,
    required this.brandName,
    required this.dataList,
  });

  final int brandId;
  final String? brandName;
  final List<Map<String, dynamic>> dataList;

  @override
  State<ProductList> createState() => _ProductList();
}

class _ProductList extends State<ProductList> {
  bool _hasUserScrolled = false;
  bool currentInStockOnly = false;
  bool currentOnSaleOnly = false;
  bool hasMoreData = true;
  bool filterSubmitted = true;
  bool _isSearching = false;
  bool _isApplyingFilters = false;

  int? priceSorting;
  int currentApiPage = 1;
  int totalProductCount = 0;

  List<VendorProduct> _searchResults = [];
  List<VendorProduct> allProducts = [];
  List<String> filterVendor = [];
  List<String> uniqueVendors = [];
  List<VendorProduct> brandProducts = [];
  List<VendorProduct> tempProductList = [];

  // Add vendor filtering variables
  Map<String, int> vendorProductCounts = {};
  Map<String, String> vendorCodes = {}; // Store vendor codes for API calls
  bool isVendorFiltered = false;
  RangeValues currentPriceRange = const RangeValues(0, 1000);
  double maxPriceFromAPI = 1000.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();

  final FocusNode _focusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();

  final TextEditingController iconController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool isCartPrice = true;

  @override
  void initState() {
    super.initState();
    _addScrollListener();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ProductProvider>()
          .getProductList(widget.brandName.toString(), context);
    });
  }

  // Store scroll listener reference for proper disposal
  late final VoidCallback _scrollListener;

  void _addScrollListener() {
    _scrollListener = () {
      if (_scrollController.position.userScrollDirection !=
          ScrollDirection.idle) {
        _hasUserScrolled = true; // User scrolled at least once
      }

      // Simplified scroll detection - trigger when near bottom
      final productProvider = context.read<ProductProvider>();
      if (_hasUserScrolled &&
          productProvider.hasMoreData &&
          !productProvider.isLoadingMore &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100) {
        log('Scroll detection: Triggering load more products');
        productProvider.loadMoreProducts(widget.brandName.toString(), context);
      }
    };

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _focusNode.dispose();
    iconController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  /// Perform search using the API with the given query
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
      log('Performing API search for query: "$query" within brand: "${widget.brandName}"');

      final searchData = await BrandsApi.fetchSearchProduct(context, query);

      if (searchData != null) {
        final List<dynamic> jsonList = searchData['brand_product'] ?? [];
        final List<VendorProduct> allResults =
            jsonList.map((e) => VendorProduct.fromJson(e)).toList();

        // Filter out products with invalid or null key values AND filter by current brand
        final List<VendorProduct> validResults = allResults.where((product) {
          // Check if essential fields have valid values
          final productId = product.productId;
          final productMpn = product.productMpn;
          final productName = product.productName;
          final brandName = product.brandName;

          // Product ID should be a valid number greater than 0
          final isValidProductId = productId > 0;

          // Product MPN should not be null, empty, or "0"
          final isValidMpn = productMpn.isNotEmpty && productMpn != "0";

          // Product name should not be null or empty
          final isValidProductName = productName.isNotEmpty;

          // Brand name should not be null, empty, or "0"
          final isValidBrandName = brandName.isNotEmpty && brandName != "0";

          // Check if product belongs to current brand
          final isCurrentBrand =
              brandName.toLowerCase() == widget.brandName?.toLowerCase();

          final isValid = isValidProductId &&
              isValidMpn &&
              isValidProductName &&
              isValidBrandName &&
              isCurrentBrand;

          if (!isValid) {
            if (!isCurrentBrand) {
              log('Filtering out product from different brand: $brandName (current: ${widget.brandName})');
            } else {
              log('Filtering out invalid product: ID=$productId, MPN=$productMpn, Name=$productName, Brand=$brandName');
            }
          }

          return isValid;
        }).toList();

        log('API search returned ${allResults.length} total results, ${validResults.length} valid results for brand "${widget.brandName}" and query: "$query"');

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          // Update local data when ProductProvider data changes
          if (productProvider.allProducts.isNotEmpty && allProducts.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateLocalData(productProvider);
            });
          }
          return _buildScaffold(productProvider);
        },
      ),
    );
  }

  void _updateLocalData(ProductProvider productProvider) async {
    setState(() {
      allProducts = List.from(productProvider.allProducts);
      tempProductList = List.from(allProducts);
      totalProductCount = allProducts.length;
    });

    log('Updated local data: ${allProducts.length} products from ProductProvider');
    log('ProductProvider has ${productProvider.allProducts.length} products');

    // Fetch vendor data from main brand API response
    await _fetchVendorDataFromBrandAPI();

    // Calculate price range from products
    if (allProducts.isNotEmpty) {
      final validPrices = allProducts
          .map((product) => _parsePrice(product.vendorpricePrice))
          .where((price) => price != null)
          .cast<double>()
          .toList();

      if (validPrices.isNotEmpty) {
        final minPrice = validPrices.reduce((a, b) => a < b ? a : b);
        final maxPrice = validPrices.reduce((a, b) => a > b ? a : b);

        setState(() {
          // Round max price up to nearest 50 for better UX
          maxPriceFromAPI = ((maxPrice / 50).ceil() * 50).toDouble();

          // Always set price range to start from 0 and go to max price
          currentPriceRange = RangeValues(0, maxPriceFromAPI);
        });

        log('Price range calculated: \$${minPrice.toStringAsFixed(2)} - \$${maxPriceFromAPI.toStringAsFixed(2)}');
        log('Filter price range set to: \$${currentPriceRange.start.toStringAsFixed(2)} - \$${currentPriceRange.end.toStringAsFixed(2)}');
        log('Valid prices found: ${validPrices.length}/${allProducts.length} products');
      }
    }

    log('Final local data: ${allProducts.length} products, ${vendorProductCounts.length} vendors');
  }

  Future<void> _fetchVendorDataFromBrandAPI() async {
    try {
      log('Fetching vendor data from main brand API: ${widget.brandName}');
      final response = await BrandsApi.getProductListByBrandName(
          widget.brandName.toString(),
          1, // Use page 1 to get vendor data
          context);

      if (response != null) {
        final Map<String, dynamic> decoded = jsonDecode(response);

        // Parse vendor data from API response
        final List<dynamic> vendorDataList = decoded['vendor_data'] ?? [];
        vendorProductCounts.clear();
        vendorCodes.clear();

        for (var vendor in vendorDataList) {
          String vendorName = vendor['vendor_name'] ?? '';
          String vendorCode = vendor['vendor_code'] ?? '';
          // Handle both int and String product_count values
          dynamic productCountRaw = vendor['product_count'];
          int productCount = 0;

          if (productCountRaw is int) {
            productCount = productCountRaw;
          } else if (productCountRaw is String) {
            productCount = int.tryParse(productCountRaw) ?? 0;
          }

          if (vendorName.isNotEmpty) {
            vendorProductCounts[vendorName] = productCount;
            if (vendorCode.isNotEmpty) {
              vendorCodes[vendorName] = vendorCode;
            }
            log('Added vendor: "$vendorName" with $productCount products (code: $vendorCode)');
          } else {
            log('⚠️ Skipping vendor with empty name: $vendor');
          }
        }

        log('Fetched vendor data from main brand API: ${vendorProductCounts.length} vendors');
        log('API vendor names: ${vendorProductCounts.keys.toList()}');
        log('Complete vendor data map: $vendorProductCounts');

        // Debug specific vendor
        if (vendorProductCounts.containsKey('AllSouth Appliance Group, Inc.')) {
          log('✅ AllSouth Appliance Group, Inc. found with ${vendorProductCounts['AllSouth Appliance Group, Inc.']} products');
        } else {
          log('❌ AllSouth Appliance Group, Inc. NOT found in vendor data');
        }

        // Cross-check with actual product data
        if (allProducts.isNotEmpty) {
          Set<String> actualVendorNames =
              allProducts.map((p) => p.vendorName).toSet();
          log('Actual vendor names in products: $actualVendorNames');

          // Find mismatches
          Set<String> apiVendors = vendorProductCounts.keys.toSet();
          Set<String> missingInProducts =
              apiVendors.difference(actualVendorNames);
          Set<String> missingInAPI = actualVendorNames.difference(apiVendors);

          if (missingInProducts.isNotEmpty) {
            log('⚠️ Vendors in API but not in products: $missingInProducts');
          }
          if (missingInAPI.isNotEmpty) {
            log('⚠️ Vendors in products but not in API: $missingInAPI');
          }

          // Keep API data for vendor counts, but validate consistency
          log('Using API vendor data for filtering (${vendorProductCounts.length} vendors)');
          log('API data will be used for vendor counts in filter menu');
        }

        setState(() {
          // Update the UI with vendor data
        });
      } else {
        log('Failed to fetch vendor data from main brand API');
        // Fallback: extract vendor data from products
        _extractVendorDataFromProducts();
      }
    } catch (e) {
      log('Error fetching vendor data from main brand API: $e');
      // Fallback: extract vendor data from products
      _extractVendorDataFromProducts();
    }

    // Final validation
    log('Final vendor data: ${vendorProductCounts.length} vendors');
    if (vendorProductCounts.isNotEmpty) {
      log('Sample vendor: ${vendorProductCounts.keys.first} = ${vendorProductCounts.values.first} products');
    }
  }

  Future<void> _fetchFilteredProducts(List<String> selectedVendors) async {
    try {
      // Get vendor codes for selected vendors
      List<String> vendorCodesToSend = [];
      for (String vendorName in selectedVendors) {
        if (vendorCodes.containsKey(vendorName)) {
          vendorCodesToSend.add(vendorCodes[vendorName]!);
          log('Selected vendor: "$vendorName" with code: ${vendorCodes[vendorName]}');
        }
      }

      if (vendorCodesToSend.isEmpty) {
        log('⚠️ No vendor codes found for selected vendors');
        return;
      }

      // Make API call with vendor codes
      String vendorCodesParam = vendorCodesToSend.join(',');

      log('Making filtered API call with vendor codes: $vendorCodesParam');

      // Use the new API method that supports vendor codes
      final response = await BrandsApi.getProductListByBrandNameWithVendor(
          widget.brandName.toString(), 1, vendorCodesParam, context);

      if (response != null) {
        final Map<String, dynamic> decoded = jsonDecode(response);
        final List<dynamic> jsonList = decoded['brand_product'] ?? [];
        final List<VendorProduct> filteredProducts =
            jsonList.map((e) => VendorProduct.fromJson(e)).toList();

        log('Filtered API returned ${filteredProducts.length} products for selected vendors');

        // Update the product list with filtered results
        setState(() {
          allProducts = filteredProducts;
          tempProductList = List.from(filteredProducts);
          totalProductCount = filteredProducts.length;
        });

        log('Updated tempProductList with ${tempProductList.length} products from API');
      }
    } catch (e) {
      log('Error fetching filtered products: $e');
    }
  }

  void _extractVendorDataFromProducts() {
    vendorProductCounts.clear();
    for (var product in allProducts) {
      if (product.vendorName.isNotEmpty) {
        vendorProductCounts[product.vendorName] =
            (vendorProductCounts[product.vendorName] ?? 0) + 1;
      }
    }
    log('Extracted vendor data from products: ${vendorProductCounts.length} vendors');
    log('Vendor counts from products: $vendorProductCounts');

    // Validate data consistency
    _validateVendorDataConsistency();
  }

  void _validateVendorDataConsistency() {
    if (allProducts.isEmpty) {
      log('⚠️ No products available for vendor validation');
      return;
    }

    Set<String> actualVendors = allProducts.map((p) => p.vendorName).toSet();
    Set<String> vendorDataVendors = vendorProductCounts.keys.toSet();

    log('=== VENDOR DATA VALIDATION ===');
    log('Products loaded: ${allProducts.length}');
    log('Actual vendors in products: ${actualVendors.length}');
    log('Vendor data entries: ${vendorDataVendors.length}');

    if (actualVendors.length != vendorDataVendors.length) {
      log('⚠️ Mismatch: ${actualVendors.length} actual vendors vs ${vendorDataVendors.length} vendor data entries');
    }

    // Check for empty vendor names
    int emptyVendorCount =
        allProducts.where((p) => p.vendorName.isEmpty).length;
    if (emptyVendorCount > 0) {
      log('⚠️ Found $emptyVendorCount products with empty vendor names');
    }

    log('=== END VALIDATION ===');
  }

  void _clearAllFilters() {
    setState(() {
      // Clear vendor filters
      filterVendor.clear();
      isVendorFiltered = false;

      // Clear price filters
      currentPriceRange = RangeValues(0, maxPriceFromAPI);

      // Clear sorting
      priceSorting = null;

      // Clear other filters
      currentInStockOnly = false;
      currentOnSaleOnly = false;

      // Reset product list to show all products
      tempProductList = List.from(allProducts);
      totalProductCount = allProducts.length;
    });

    log('Cleared all filters: Showing ${allProducts.length} products');
  }

  bool _isAnyFilterActive() {
    // Check vendor filters
    bool hasVendorFilter = isVendorFiltered || filterVendor.isNotEmpty;

    // Check price range filter (only if it's not the full range)
    // Since we always start at 0, only check if end is not at max
    bool hasPriceFilter = currentPriceRange.end < maxPriceFromAPI;

    // Check sorting
    bool hasSorting = priceSorting != null;

    // Check other filters
    bool hasOtherFilters = currentInStockOnly || currentOnSaleOnly;

    return hasVendorFilter || hasPriceFilter || hasSorting || hasOtherFilters;
  }

  Widget _buildScaffold(ProductProvider productProvider) {
    if (productProvider.isLoading) {
      return _buildLoadingScaffold();
    } else if (productProvider.hasError) {
      return _buildErrorScaffold(productProvider);
    } else {
      return _buildMainScaffold(productProvider);
    }
  }

  Widget _buildLoadingScaffold() {
    return const ProductListLoadingShimmer(itemCount: 8, isVisible: true);
  }

  Widget _buildErrorScaffold(ProductProvider productProvider) {
    return Scaffold(
      appBar: _buildAppBar(productProvider),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to load products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              productProvider.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => productProvider.retry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ProductProvider productProvider) {
    // Check if there are any products to show search bar
    bool hasProducts = productProvider.allProducts.isNotEmpty;

    return AppBar(
      surfaceTintColor: Colors.white,
      toolbarHeight: .25 * w,
      backgroundColor: Colors.white,
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: SizedBox(
          width: w * .54,
          child: AutoSizeText(
            '${widget.brandName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: w * .06),
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
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
      bottom: hasProducts
          ? PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      log('Search text changed: "$value"');
                      if (value.trim().isNotEmpty) {
                        log('Performing API search for: "$value"');
                        _performApiSearch(value.trim());
                      } else {
                        setState(() {
                          _searchResults.clear();
                          _isSearching = false;
                        });
                        log('Cleared search results');
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
                      hintText:
                          'Search ${widget.brandName} products by name or MPN...',
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
                        child: const Icon(
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
                        borderSide:
                            const BorderSide(color: AppColors.primary, width: 2),
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
            )
          : null,
    );
  }

  Widget _buildMainScaffold(ProductProvider productProvider) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: FilterMenuProductList(
        filterProductDetails: productProvider.allProducts,
        brandName: widget.brandName ?? 'Unknown',
        maxPriceFromAPI: maxPriceFromAPI,
        currentVendorFilters: filterVendor,
        currentPriceSorting: priceSorting,
        currentPriceRange: currentPriceRange,
        currentInStockOnly: currentInStockOnly,
        currentOnSaleOnly: currentOnSaleOnly,
        vendorProductCounts: vendorProductCounts,
        vendorCodes: vendorCodes,
        onFiltersApplied:
            (vendors, priceSorting, priceRange, inStockOnly, onSaleOnly) {
          _applyFilters(vendors, priceSorting, priceRange, inStockOnly,
              onSaleOnly, productProvider.allProducts);
        },
      ),
      appBar: _buildAppBar(productProvider),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 5),
                _buildProductCountBadge(productProvider),
                const SizedBox(height: 5),
                _buildProductList(productProvider),
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

  Widget _buildProductCountBadge(ProductProvider productProvider) {
    bool isSearching = _searchController.text.isNotEmpty;
    bool isFiltered = _isAnyFilterActive();

    int productCount;
    String title;
    String subtitle;

    if (isSearching) {
      productCount = _searchResults.length;
      title = 'Search Results';
      subtitle =
          '${_searchResults.length} items found for "${_searchController.text}"';
    } else if (isFiltered) {
      productCount = tempProductList.length;
      title = 'Filtered Products';
      subtitle = '${tempProductList.length} items match your filters';
    } else {
      productCount = productProvider.totalProductCount;
      title = 'Total Products';
      subtitle = '${productProvider.totalProductCount} items available';
    }

    if (productCount == 0 && !isSearching) return const SizedBox.shrink();

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

  Widget _buildProductList(ProductProvider productProvider) {
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
      if (tempProductList.isEmpty) {
        return _buildFilteredEmptyState();
      }
      productsToDisplay = tempProductList;
    } else {
      if (productProvider.allProducts.isEmpty) {
        return _buildEmptyState();
      }
      productsToDisplay = productProvider.allProducts;
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
                  // Loading indicator inside the scrollable area
                  _buildLoadingMoreIndicator(productProvider),
                  // No more products indicator
                  _buildNoMoreProductsIndicator(productProvider),
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
              'We couldn\'t find any products matching "${_searchController.text}" in ${widget.brandName}.\nTry searching with different keywords.',
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
              'We couldn\'t find any products for this brand.\nPlease try a different search or browse other categories.',
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

  Widget _buildLoadingMoreIndicator(ProductProvider productProvider) {
    // Don't show loading more indicator when searching
    if (_searchController.text.isNotEmpty) {
      return const SizedBox.shrink();
    }

    if (!productProvider.isLoadingMore || productProvider.allProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          // Loading spinner with better design
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 12),
          // Loading text
          Text(
            'Loading more products...',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Segoe UI',
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          // Progress indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMoreProductsIndicator(ProductProvider productProvider) {
    // Don't show when searching or loading
    if (_searchController.text.isNotEmpty ||
        productProvider.isLoadingMore ||
        productProvider.allProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Only show when no more data is available
    if (productProvider.hasMoreData) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          // Divider line
          Container(
            height: 1,
            width: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          // No more products text
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
    );
  }

  Widget _buildProductCard(VendorProduct product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
    );
  }

  Widget _buildProductImage(VendorProduct product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              productId: product.productId,
              brandName: widget.brandName ?? 'Unknown Brand',
              productMPN: product.productMpn,
              productImage: product.productImage,
              productPrice: product.vendorpricePrice,
            ),
          ),
        );
      },
      child: Container(
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
      ),
    );
  }

  Widget _buildProductDetails(VendorProduct product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand name with logo below product image
          Row(
            children: [
              // Brand logo using BrandImageWidget
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(right: 8),
                child: BrandImageWidget(brand: {
                  'brand_name': product.brandName,
                  'brand_key':
                      product.brandName.toLowerCase().replaceAll(' ', '-'),
                  'brand_id': product.productId, // Using productId as fallback
                }, width: 80, height: 80),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Product name
          SizedBox(
            height: w * .25,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(
                      productId: product.productId,
                      brandName: widget.brandName ?? 'Unknown Brand',
                      productMPN: product.productMpn,
                      productImage: product.productImage,
                      productPrice: product.vendorpricePrice,
                    ),
                  ),
                );
              },
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
          ),
          const SizedBox(height: 0),
          // Model number
          SizedBox(
            height: h * .05, // Reduced height to make room for vendor info
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Model: ',
                    style: TextStyle(
                      fontFamily: 'Segoe UI',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: product.productMpn.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Segoe UI',
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 10), // Reduced spacing
          _buildPriceSection(product),
        ],
      ),
    );
  }

  Widget _buildPriceSection(VendorProduct product) {
    // Use actual vendor data from the product's lowest_vendor array
    final vendors = _getVendorsFromProduct(product);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show up to 2 vendors side by side
          if (vendors.isNotEmpty)
            Row(
              children: [
                // First vendor
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.0),
                    child: _buildVendorRow(vendors.first),
                  ),
                ),
                // Second vendor if available
                if (vendors.length > 1)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0),
                      child: _buildVendorRow(vendors[1]),
                    ),
                  ),
              ],
            ),

          // Show "Show Prices (Total Vendor Count)"
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    // Handle show prices action
                    log('Show prices tapped for ${vendors.length} vendors');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          productId: product.productId,
                          brandName: widget.brandName ?? 'Unknown Brand',
                          productMPN: product.productMpn,
                          productImage: product.productImage,
                          productPrice: product.vendorpricePrice,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Show Prices (${product.vendorIdCount})',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  // Get vendor data from product's lowest_vendor array
  List<Map<String, dynamic>> _getVendorsFromProduct(VendorProduct product) {
    List<Map<String, dynamic>> vendors = [];

    // Check if there's only one lowest vendor
    if (product.lowestVendor != null && product.lowestVendor!.length == 1) {
      // If only one lowest vendor, use the product's main vendor URL and show that vendor
      final currentVendor = {
        'name': product.vendorName,
        'logo': _getVendorLogo(product.vendorName),
        'price': product.vendorpricePrice,
        'url': product.vendorUrl, // Use product's main vendor URL
      };
      vendors.add(currentVendor);
      log('Single lowest vendor detected - using product vendor: "${currentVendor['name']}" with URL: ${currentVendor['url']}');
    } else if (product.lowestVendor != null && product.lowestVendor!.isNotEmpty) {
      // Multiple lowest vendors - add current vendor first
      final currentVendor = {
        'name': product.vendorName,
        'logo': _getVendorLogo(product.vendorName),
        'price': product.vendorpricePrice,
        'url': product.vendorUrl,
      };
      vendors.add(currentVendor);
      log('Added current vendor: "${currentVendor['name']}" with logo: ${currentVendor['logo']}');

      // Then add vendors from lowest_vendor array
      for (var lowestVendor in product.lowestVendor!) {
        // Skip if it's the same as current vendor
        if (lowestVendor.vendorName != product.vendorName) {
          final vendorData = {
            'name': lowestVendor.vendorName,
            'logo': _getVendorLogo(lowestVendor.vendorName),
            'price': lowestVendor.vendorpricePrice,
            'url': lowestVendor.vendorUrl,
          };
          vendors.add(vendorData);
          log('Added lowest vendor: "${vendorData['name']}" with price: ${vendorData['price']} and URL: ${vendorData['url']}');
        }
      }
    }
    else {
      log('No lowest_vendor data');
    }

    // Sort by price to show cheapest first
    vendors.sort((a, b) {
      final priceA = _parsePrice(a['price']) ?? 0;
      final priceB = _parsePrice(b['price']) ?? 0;
      return priceA.compareTo(priceB);
    });

    log('Total vendors for product "${product.productName}": ${vendors.length}');
    return vendors;
  }

  // Generate mock vendor data for demonstration when lowest_vendor is not available
  List<Map<String, dynamic>> _getMockVendorsForProduct(VendorProduct product) {
    final basePrice = _parsePrice(product.vendorpricePrice) ?? 100.0;

    // Create a list of common vendor names and logos that match your image
    final vendorData = [
      {
        'name': '24hr supply',
        'logo': 'https://picsum.photos/40/30?random=1',
      },
      {
        'name': 'AF SUPPLY',
        'logo': 'https://picsum.photos/40/30?random=2',
      },
      {
        'name': 'supplyonline.com',
        'logo': 'https://picsum.photos/40/30?random=3',
      },
      {
        'name': '(LEE)',
        'logo': 'https://picsum.photos/40/30?random=4',
      },
    ];

    List<Map<String, dynamic>> vendors = [];

    // Add 1-2 more vendors with slightly different prices
    final otherVendors =
        vendorData.where((v) => v['name'] != product.vendorName).toList();
    final random = DateTime.now().millisecondsSinceEpoch % otherVendors.length;

    for (int i = 0; i < 2 && i < otherVendors.length; i++) {
      final vendorIndex = (random + i) % otherVendors.length;
      final vendor = otherVendors[vendorIndex];

      // Generate a price variation (±2-5%)
      final priceVariation = 0.95 + (i * 0.03); // 95%, 98%, 101%
      final vendorPrice = (basePrice * priceVariation).toStringAsFixed(2);

      final additionalVendor = {
        'name': vendor['name'],
        'logo': vendor['logo'],
        'price': vendorPrice,
        'url': 'https://example.com', // Mock URL for additional vendors
      };
      vendors.add(additionalVendor);
      log('Added mock vendor: ${additionalVendor['name']} with logo: ${additionalVendor['logo']}');
    }

    return vendors;
  }

  String _getVendorLogo(String vendorName) {
    return 'https://growth.matridtech.net/vendor-logo/$vendorName.jpg';
  }

  Widget _buildVendorLogoWidget(String vendorName) {
    String logoPath =
        'https://growth.matridtech.net/vendor-logo/$vendorName.jpg';

    return Image.network(
      logoPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            vendorName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
          ),
        );
      },
    );
  }

  Widget _buildVendorRow(Map<String, dynamic> vendor) {
    log('Building vendor row for: "${vendor['name']}" with logo: ${vendor['logo']} and URL: ${vendor['url']}');
    return GestureDetector(
      onTap: () async {
        // Handle vendor URL tap using url_launcher
        if (vendor['url'] != null &&
            vendor['url'].isNotEmpty &&
            vendor['url'] != 'https://example.com') {
          try {
            log('Opening vendor URL: ${vendor['url']} for vendor: ${vendor['name']}');
            final Uri url = Uri.parse(vendor['url']);
            if (await canLaunchUrl(url)) {
              await launchUrl(
                url,
                mode:
                    LaunchMode.externalApplication, // Opens in external browser
              );
            } else {
              throw 'Could not launch $url';
            }
          } catch (e) {
            log('Error opening vendor URL: $e');
            // Fallback: show a snackbar or dialog
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Unable to open vendor website: ${vendor['name']}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          log('Vendor ${vendor['name']} has no valid URL or is mock data');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No website available for ${vendor['name']}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      },
      child: Container(
        height: h * 0.07,
        margin: const EdgeInsets.only(bottom: 4.0),
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Vendor logo - using same pattern as product details screen
            SizedBox(
              height: h * 0.03,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child:
                      _buildVendorLogoWidget(vendor['name']?.toString() ?? ''),
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Vendor price
            Text(
              '\$${_formatPrice(vendor['price'])}',
              style: const TextStyle(
                color: Colors.blue,
                fontFamily: 'Segoe UI',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // _isLoading
  //           ? Scaffold(
  //               appBar: AppBar(
  //                 backgroundColor: Colors.white,
  //                 surfaceTintColor: Colors.transparent,
  //                 elevation: 0,
  //                 toolbarHeight: 80,
  //                 automaticallyImplyLeading: false,
  //                 centerTitle: false,
  //                 title: Visibility(
  //                   visible: !_isLoading,
  //                   child: Padding(
  //                     padding: const EdgeInsets.symmetric(horizontal: 2.0),
  //                     child: SizedBox(
  //                       width: w * .54,
  //                       child: AutoSizeText(
  //                         '${widget.brandName}',
  //                         maxLines: 1,
  //                         overflow: TextOverflow.ellipsis,
  //                         style: TextStyle(fontSize: w * .04),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 actions: [
  //                   Visibility(
  //                     visible: !_isLoading,
  //                     child: GestureDetector(
  //                       onTap: () {
  //                         log('Working');
  //                         Navigator.of(context).pushReplacement(
  //                           MaterialPageRoute(
  //                               builder: (context) => const HomePage()),
  //                         );
  //                       },
  //                       child: Container(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Image.asset(
  //                           'assets/minsellprice_app_icon.png',
  //                           height: .23 * w,
  //                           fit: BoxFit.contain,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               body: Center(
  //                 child: StylishLoader(
  //                   type: LoaderType.wave,
  //                   size: 80.0,
  //                   primaryColor: AppColors.primary,
  //                   text: "Loading ${widget.brandName} products...",
  //                   textStyle: const TextStyle(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w500,
  //                     color: AppColors.primary,
  //                   ),
  //                 ),
  //               ))
  //           : _isError
  //               ? Scaffold(
  //                   appBar: AppBar(
  //                     surfaceTintColor: Colors.white,
  //                     toolbarHeight: .18 * w,
  //                     backgroundColor: Colors.white,
  //                     centerTitle: false,
  //                     title: Padding(
  //                       padding: const EdgeInsets.symmetric(horizontal: 2.0),
  //                       child: SizedBox(
  //                         width: w * .54,
  //                         child: AutoSizeText(
  //                           '${widget.brandName}',
  //                           maxLines: 1,
  //                           overflow: TextOverflow.ellipsis,
  //                           style: TextStyle(fontSize: w * .06),
  //                         ),
  //                       ),
  //                     ),
  //                     actions: [
  //                       GestureDetector(
  //                         onTap: () {
  //                           log('Working');
  //                           Navigator.of(context).pushReplacement(
  //                             MaterialPageRoute(
  //                                 builder: (context) => const HomePage()),
  //                           );
  //                         },
  //                         child: Container(
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: Image.asset(
  //                             'assets/minsellprice_app_icon.png',
  //                             height: .23 * w,
  //                             fit: BoxFit.contain,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   body: Center(
  //                     child: RichText(
  //                       textAlign: TextAlign.center,
  //                       text: TextSpan(
  //                           text: 'No Product(s) found.\n',
  //                           style: TextStyle(
  //                               fontSize: .06 * w,
  //                               fontFamily: 'Futura BdCn BT Bold',
  //                               fontWeight: FontWeight.w300,
  //                               color: Colors.black),
  //                           children: [
  //                             TextSpan(
  //                               text: 'Return Back',
  //                               recognizer: TapGestureRecognizer()
  //                                 ..onTap = () => Navigator.pop(context),
  //                               style: TextStyle(
  //                                   fontSize: .06 * w,
  //                                   fontFamily: 'Futura BdCn BT Bold',
  //                                   fontWeight: FontWeight.w300,
  //                                   color: AppColors.primary),
  //                             )
  //                           ]),
  //                     ),
  //                   ),
  //                 )
  //               : Scaffold(
  //                   key: _scaffoldKey,
  //                   appBar: AppBar(
  //                     surfaceTintColor: Colors.white,
  //                     toolbarHeight: .18 * w,
  //                     backgroundColor: Colors.white,
  //                     centerTitle: false,
  //                     title: Padding(
  //                       padding: const EdgeInsets.symmetric(horizontal: 2.0),
  //                       child: SizedBox(
  //                         width: w * .54,
  //                         child: AutoSizeText(
  //                           '${widget.brandName}',
  //                           maxLines: 1,
  //                           overflow: TextOverflow.ellipsis,
  //                           style: TextStyle(fontSize: w * .06),
  //                         ),
  //                       ),
  //                     ),
  //                     actions: [
  //                       GestureDetector(
  //                         onTap: () {
  //                           log('Working');
  //                           Navigator.of(context).pushReplacement(
  //                             MaterialPageRoute(
  //                                 builder: (context) => const HomePage()),
  //                           );
  //                         },
  //                         child: Container(
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: Image.asset(
  //                             'assets/minsellprice_app_icon.png',
  //                             height: .23 * w,
  //                             fit: BoxFit.contain,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   body: Stack(
  //                     children: [
  //                       SafeArea(
  //                         bottom: true,
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             const SizedBox(height: 5),
  //                             Visibility(
  //                               visible: totalProductCount > 0,
  //                               child: Container(
  //                                 margin: const EdgeInsets.symmetric(
  //                                     horizontal: 16, vertical: 8),
  //                                 child: Row(
  //                                   children: [
  //                                     // Filters Icon Button
  //                                     // Container(
  //                                     //   decoration: BoxDecoration(
  //                                     //     color: AppColors.primary,
  //                                     //     borderRadius:
  //                                     //         BorderRadius.circular(12),
  //                                     //     boxShadow: [
  //                                     //       BoxShadow(
  //                                     //         color: AppColors.primary
  //                                     //             .withOpacity(0.3),
  //                                     //         spreadRadius: 1,
  //                                     //         blurRadius: 4,
  //                                     //         offset: const Offset(0, 2),
  //                                     //       ),
  //                                     //     ],
  //                                     //   ),
  //                                     //   child: Material(
  //                                     //     color: Colors.transparent,
  //                                     //     child: InkWell(
  //                                     //       borderRadius:
  //                                     //           BorderRadius.circular(12),
  //                                     //       onTap: () {
  //                                     //         // _scaffoldKey.currentState!
  //                                     //         //     .openEndDrawer();
  //                                     //       },
  //                                     //       child: Container(
  //                                     //         padding: const EdgeInsets.all(12),
  //                                     //         // child: Icon(
  //                                     //         //   Icons.filter_alt,
  //                                     //         //   color: Colors.white,
  //                                     //         //   size: w * .05,
  //                                     //         // ),
  //                                     //       ),
  //                                     //     ),
  //                                     //   ),
  //                                     // ),
  //                                     const SizedBox(width: 12),
  //                                     // Product Count Badge
  //                                     Expanded(
  //                                       child: Container(
  //                                         padding: const EdgeInsets.symmetric(
  //                                             horizontal: 16, vertical: 10),
  //                                         decoration: BoxDecoration(
  //                                           color: Colors.grey[50],
  //                                           borderRadius:
  //                                               BorderRadius.circular(12),
  //                                           border: Border.all(
  //                                             color: Colors.grey[200]!,
  //                                             width: 1,
  //                                           ),
  //                                         ),
  //                                         child: Row(
  //                                           children: [
  //                                             Container(
  //                                               padding:
  //                                                   const EdgeInsets.all(6),
  //                                               decoration: BoxDecoration(
  //                                                 color: AppColors.primary
  //                                                     .withOpacity(0.1),
  //                                                 borderRadius:
  //                                                     BorderRadius.circular(8),
  //                                               ),
  //                                               child: Icon(
  //                                                 Icons.shopping_bag_outlined,
  //                                                 color: AppColors.primary,
  //                                                 size: w * .06,
  //                                               ),
  //                                             ),
  //                                             const SizedBox(width: 12),
  //                                             Expanded(
  //                                               child: Column(
  //                                                 crossAxisAlignment:
  //                                                     CrossAxisAlignment.start,
  //                                                 children: [
  //                                                   Text(
  //                                                     'Total Products',
  //                                                     style: TextStyle(
  //                                                       color: Colors.grey[600],
  //                                                       fontSize: w * .045,
  //                                                       fontFamily: 'Segoe UI',
  //                                                       fontWeight:
  //                                                           FontWeight.w500,
  //                                                     ),
  //                                                   ),
  //                                                   Text(
  //                                                     '$totalProductCount items available',
  //                                                     style: TextStyle(
  //                                                       color:
  //                                                           AppColors.primary,
  //                                                       fontSize: w * .039,
  //                                                       fontFamily: 'Segoe UI',
  //                                                       fontWeight:
  //                                                           FontWeight.bold,
  //                                                     ),
  //                                                   ),
  //                                                 ],
  //                                               ),
  //                                             ),
  //                                           ],
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                             const SizedBox(height: 5),
  //                             allProducts.isEmpty
  //                                 ? Flexible(
  //                                     child: Container(
  //                                       width: w,
  //                                       height: h / 1.1,
  //                                       padding: const EdgeInsets.symmetric(
  //                                           horizontal: 20),
  //                                       child: Column(
  //                                         mainAxisAlignment:
  //                                             MainAxisAlignment.center,
  //                                         children: [
  //                                           // Illustration/Icon
  //                                           Container(
  //                                             width: w * 0.3,
  //                                             height: w * 0.3,
  //                                             decoration: BoxDecoration(
  //                                               color: AppColors.background,
  //                                               shape: BoxShape.circle,
  //                                               boxShadow: [
  //                                                 BoxShadow(
  //                                                   color: Colors.grey
  //                                                       .withOpacity(0.1),
  //                                                   spreadRadius: 2,
  //                                                   blurRadius: 10,
  //                                                   offset: const Offset(0, 4),
  //                                                 ),
  //                                               ],
  //                                             ),
  //                                             child: Icon(
  //                                               Icons.search_off_rounded,
  //                                               size: w * 0.15,
  //                                               color: AppColors.primary
  //                                                   .withOpacity(0.7),
  //                                             ),
  //                                           ),
  //                                           SizedBox(height: h * 0.03),
  //
  //                                           // Main Title
  //                                           Text(
  //                                             'No Products Found',
  //                                             style: TextStyle(
  //                                               fontSize: w * 0.06,
  //                                               fontFamily:
  //                                                   'Futura BdCn BT Bold',
  //                                               fontWeight: FontWeight.w600,
  //                                               color: AppColors.text,
  //                                             ),
  //                                             textAlign: TextAlign.center,
  //                                           ),
  //                                           SizedBox(height: h * 0.015),
  //
  //                                           // Subtitle
  //                                           Text(
  //                                             'We couldn\'t find any products for this brand.\nPlease try a different search or browse other categories.',
  //                                             style: TextStyle(
  //                                               fontSize: w * 0.035,
  //                                               fontFamily:
  //                                                   'Futura BdCn BT Bold',
  //                                               fontWeight: FontWeight.w300,
  //                                               color: Colors.grey[600],
  //                                               height: 1.4,
  //                                             ),
  //                                             textAlign: TextAlign.center,
  //                                           ),
  //                                           SizedBox(height: h * 0.04),
  //
  //                                           // Action Button
  //                                           GestureDetector(
  //                                             onTap: () =>
  //                                                 Navigator.pop(context),
  //                                             child: Container(
  //                                               padding: EdgeInsets.symmetric(
  //                                                 horizontal: w * 0.06,
  //                                                 vertical: h * 0.018,
  //                                               ),
  //                                               decoration: BoxDecoration(
  //                                                 color: AppColors.primary,
  //                                                 borderRadius:
  //                                                     BorderRadius.circular(25),
  //                                                 boxShadow: [
  //                                                   BoxShadow(
  //                                                     color: AppColors.primary
  //                                                         .withOpacity(0.3),
  //                                                     spreadRadius: 1,
  //                                                     blurRadius: 8,
  //                                                     offset:
  //                                                         const Offset(0, 2),
  //                                                   ),
  //                                                 ],
  //                                               ),
  //                                               child: Row(
  //                                                 mainAxisSize:
  //                                                     MainAxisSize.min,
  //                                                 children: [
  //                                                   Icon(
  //                                                     Icons
  //                                                         .arrow_back_ios_rounded,
  //                                                     size: w * 0.035,
  //                                                     color: Colors.white,
  //                                                   ),
  //                                                   SizedBox(width: w * 0.015),
  //                                                   Text(
  //                                                     'Go Back',
  //                                                     style: TextStyle(
  //                                                       fontSize: w * 0.035,
  //                                                       fontFamily:
  //                                                           'Futura BdCn BT Bold',
  //                                                       fontWeight:
  //                                                           FontWeight.w500,
  //                                                       color: Colors.white,
  //                                                     ),
  //                                                   ),
  //                                                 ],
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                   )
  //                                 : allProducts.isNotEmpty
  //                                     ? Expanded(
  //                                         child: Align(
  //                                           alignment: Alignment.topCenter,
  //                                           child: Scrollbar(
  //                                             thickness: 4,
  //                                             thumbVisibility: true,
  //                                             trackVisibility: true,
  //                                             interactive: true,
  //                                             controller: _scrollController,
  //                                             child: NotificationListener<
  //                                                 ScrollNotification>(
  //                                               onNotification: (notification) {
  //                                                 if (notification
  //                                                         is ScrollUpdateNotification &&
  //                                                     notification
  //                                                             .metrics.axis ==
  //                                                         Axis.vertical) {
  //                                                   final bool isUserDrag =
  //                                                       notification
  //                                                               .dragDetails !=
  //                                                           null;
  //
  //                                                   // Check if user has seen the last product
  //                                                   if (notification
  //                                                           .metrics.pixels >=
  //                                                       notification.metrics
  //                                                               .maxScrollExtent -
  //                                                           20) {
  //                                                     _hasUserSeenLastProduct =
  //                                                         true;
  //                                                   }
  //
  //                                                   if (isUserDrag &&
  //                                                       _isUserActivelyScrolling &&
  //                                                       _hasUserSeenLastProduct &&
  //                                                       hasMoreData &&
  //                                                       !_isLoadingMore &&
  //                                                       notification.metrics
  //                                                               .pixels >=
  //                                                           notification.metrics
  //                                                                   .maxScrollExtent -
  //                                                               10) {
  //                                                     // Very strict threshold
  //                                                     log('NotificationListener: User at very bottom and has seen last product - triggering API call');
  //                                                     _loadMoreProducts();
  //                                                   }
  //                                                 }
  //                                                 return false; // allow other listeners to receive notifications
  //                                               },
  //                                               child: SingleChildScrollView(
  //                                                 controller: _scrollController,
  //                                                 child: Padding(
  //                                                   padding: const EdgeInsets
  //                                                       .symmetric(
  //                                                       horizontal: 10.0),
  //                                                   child: Wrap(
  //                                                     runSpacing: 10,
  //                                                     children: List.generate(
  //                                                       allProducts.length,
  //                                                       (index) => Padding(
  //                                                         padding:
  //                                                             const EdgeInsets
  //                                                                 .symmetric(
  //                                                                 horizontal:
  //                                                                     4.0),
  //                                                         child:
  //                                                             GestureDetector(
  //                                                           onTap: () {
  //                                                             Navigator.push(
  //                                                               context,
  //                                                               MaterialPageRoute(
  //                                                                   builder: (context) => ProductDetailsScreen(
  //                                                                       productId:
  //                                                                           allProducts[index]
  //                                                                               .productId,
  //                                                                       brandName:
  //                                                                           widget.brandName ??
  //                                                                               'Unknown Brand',
  //                                                                       productMPN:
  //                                                                           allProducts[index]
  //                                                                               .productMpn,
  //                                                                       productImage:
  //                                                                           allProducts[index]
  //                                                                               .productImage,
  //                                                                       productPrice:
  //                                                                           allProducts[index].vendorpricePrice)),
  //                                                             );
  //                                                           },
  //                                                           child: Container(
  //                                                             width: w * .45,
  //                                                             // height: h * .48,
  //                                                             decoration:
  //                                                                 BoxDecoration(
  //                                                               color: Colors
  //                                                                   .white,
  //                                                               borderRadius:
  //                                                                   BorderRadius
  //                                                                       .circular(
  //                                                                           16),
  //                                                               boxShadow: [
  //                                                                 BoxShadow(
  //                                                                   color: Colors
  //                                                                       .grey
  //                                                                       .withOpacity(
  //                                                                           0.1),
  //                                                                   spreadRadius:
  //                                                                       2,
  //                                                                   blurRadius:
  //                                                                       8,
  //                                                                   offset:
  //                                                                       const Offset(
  //                                                                           0,
  //                                                                           4),
  //                                                                 ),
  //                                                               ],
  //                                                             ),
  //                                                             child: Column(
  //                                                               crossAxisAlignment:
  //                                                                   CrossAxisAlignment
  //                                                                       .start,
  //                                                               children: [
  //                                                                 Container(
  //                                                                   width: double
  //                                                                       .infinity,
  //                                                                   height:
  //                                                                       w * .45,
  //                                                                   decoration:
  //                                                                       const BoxDecoration(
  //                                                                     borderRadius:
  //                                                                         BorderRadius
  //                                                                             .only(
  //                                                                       topLeft:
  //                                                                           Radius.circular(16),
  //                                                                       topRight:
  //                                                                           Radius.circular(16),
  //                                                                     ),
  //                                                                   ),
  //                                                                   child:
  //                                                                       ClipRRect(
  //                                                                     borderRadius:
  //                                                                         const BorderRadius
  //                                                                             .only(
  //                                                                       topLeft:
  //                                                                           Radius.circular(0),
  //                                                                       topRight:
  //                                                                           Radius.circular(0),
  //                                                                     ),
  //                                                                     child: Image
  //                                                                         .network(
  //                                                                       _getProperImageUrl(
  //                                                                           allProducts[index].productImage),
  //                                                                       fit: BoxFit
  //                                                                           .contain,
  //                                                                       // Memory-efficient image loading
  //                                                                       cacheWidth: (w *
  //                                                                               .45 *
  //                                                                               MediaQuery.of(context).devicePixelRatio)
  //                                                                           .round(),
  //                                                                       cacheHeight: (w *
  //                                                                               .45 *
  //                                                                               MediaQuery.of(context).devicePixelRatio)
  //                                                                           .round(),
  //                                                                       errorBuilder: (context,
  //                                                                           error,
  //                                                                           stackTrace) {
  //                                                                         return Container(
  //                                                                           color:
  //                                                                               Colors.grey[200],
  //                                                                           child:
  //                                                                               Icon(
  //                                                                             Icons.image_not_supported_outlined,
  //                                                                             size: w * .08,
  //                                                                             color: Colors.grey[400],
  //                                                                           ),
  //                                                                         );
  //                                                                       },
  //                                                                     ),
  //                                                                   ),
  //                                                                 ),
  //
  //                                                                 // Product Details
  //                                                                 Padding(
  //                                                                   padding:
  //                                                                       const EdgeInsets
  //                                                                           .all(
  //                                                                           16),
  //                                                                   child:
  //                                                                       Column(
  //                                                                     crossAxisAlignment:
  //                                                                         CrossAxisAlignment
  //                                                                             .start,
  //                                                                     children: [
  //                                                                       // Product Name
  //                                                                       SizedBox(
  //                                                                         height:
  //                                                                             w * .25,
  //                                                                         child:
  //                                                                             Text(
  //                                                                           allProducts[index].productName.isEmpty
  //                                                                               ? 'Product Name Not Available'
  //                                                                               : allProducts[index].productName,
  //                                                                           maxLines:
  //                                                                               4,
  //                                                                           overflow:
  //                                                                               TextOverflow.ellipsis,
  //                                                                           style:
  //                                                                               TextStyle(
  //                                                                             color: Colors.grey[800],
  //                                                                             fontFamily: 'Segoe UI',
  //                                                                             fontSize: 18,
  //                                                                             height: 1.2,
  //                                                                             fontWeight: FontWeight.w600,
  //                                                                           ),
  //                                                                         ),
  //                                                                       ),
  //                                                                       const SizedBox(
  //                                                                           height:
  //                                                                               0),
  //                                                                       // MPN
  //                                                                       SizedBox(
  //                                                                         height:
  //                                                                             h * .06,
  //                                                                         child:
  //                                                                             Text(
  //                                                                           'MPN: #${allProducts[index].productMpn}',
  //                                                                           style:
  //                                                                               const TextStyle(
  //                                                                             fontFamily: 'Segoe UI',
  //                                                                             fontSize: 16,
  //                                                                           ),
  //                                                                           overflow:
  //                                                                               TextOverflow.ellipsis,
  //                                                                           maxLines:
  //                                                                               2,
  //                                                                         ),
  //                                                                       ),
  //                                                                       const SizedBox(
  //                                                                           height:
  //                                                                               13),
  //                                                                       // Price Section
  //                                                                       Container(
  //                                                                         //height: h * .09,
  //                                                                         decoration:
  //                                                                             BoxDecoration(
  //                                                                           borderRadius:
  //                                                                               BorderRadius.circular(10),
  //                                                                         ),
  //                                                                         child:
  //                                                                             Column(
  //                                                                           crossAxisAlignment:
  //                                                                               CrossAxisAlignment.start,
  //                                                                           children: [
  //                                                                             // Price Row
  //                                                                             Row(
  //                                                                               mainAxisAlignment: MainAxisAlignment.start,
  //                                                                               children: [
  //                                                                                 Text(
  //                                                                                   '\$${allProducts[index].vendorpricePrice}',
  //                                                                                   style: const TextStyle(
  //                                                                                     color: Colors.black,
  //                                                                                     fontFamily: 'Segoe UI',
  //                                                                                     fontSize: 20,
  //                                                                                     fontWeight: FontWeight.bold,
  //                                                                                   ),
  //                                                                                 ),
  //                                                                               ],
  //                                                                             ),
  //                                                                             const SizedBox(height: 10),
  //                                                                             // Vendor Count Row
  //                                                                             Row(
  //                                                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                                                                               children: [
  //                                                                                 Container(
  //                                                                                   padding: EdgeInsets.symmetric(
  //                                                                                     horizontal: w * .02,
  //                                                                                     vertical: w * .015,
  //                                                                                   ),
  //                                                                                   decoration: BoxDecoration(
  //                                                                                     gradient: LinearGradient(
  //                                                                                       colors: [
  //                                                                                         AppColors.primary,
  //                                                                                         AppColors.primary.withOpacity(0.8),
  //                                                                                       ],
  //                                                                                     ),
  //                                                                                     borderRadius: BorderRadius.circular(8),
  //                                                                                     boxShadow: [
  //                                                                                       BoxShadow(
  //                                                                                         color: AppColors.primary.withOpacity(0.3),
  //                                                                                         spreadRadius: 1,
  //                                                                                         blurRadius: 3,
  //                                                                                         offset: const Offset(0, 1),
  //                                                                                       ),
  //                                                                                     ],
  //                                                                                   ),
  //                                                                                   child: Row(
  //                                                                                     mainAxisSize: MainAxisSize.min,
  //                                                                                     children: [
  //                                                                                       Icon(
  //                                                                                         Icons.storefront_outlined,
  //                                                                                         color: Colors.white,
  //                                                                                         size: 18,
  //                                                                                       ),
  //                                                                                       const SizedBox(width: 2),
  //                                                                                       Text(
  //                                                                                         '${allProducts[index].vendorIdCount}',
  //                                                                                         style: TextStyle(
  //                                                                                           color: Colors.white,
  //                                                                                           fontSize: 19,
  //                                                                                           fontWeight: FontWeight.w500,
  //                                                                                         ),
  //                                                                                       ),
  //                                                                                       const SizedBox(width: 2),
  //                                                                                       Text(
  //                                                                                         'vendors',
  //                                                                                         style: TextStyle(
  //                                                                                           color: Colors.white.withOpacity(0.9),
  //                                                                                           fontSize: 20,
  //                                                                                           fontWeight: FontWeight.w500,
  //                                                                                         ),
  //                                                                                         maxLines: 1,
  //                                                                                         overflow: TextOverflow.ellipsis,
  //                                                                                       ),
  //                                                                                     ],
  //                                                                                   ),
  //                                                                                 ),
  //                                                                               ],
  //                                                                             ),
  //                                                                           ],
  //                                                                         ),
  //                                                                       ),
  //                                                                     ],
  //                                                                   ),
  //                                                                 ),
  //                                                               ],
  //                                                             ),
  //                                                           ),
  //                                                         ),
  //                                                       ),
  //                                                     ),
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       )
  //                                     : const SizedBox(),
  //                             const SizedBox(height: 10),
  //                             // Loading indicator for more products
  //                             if (_isLoadingMore && allProducts.isNotEmpty)
  //                               Container(
  //                                 width: double.infinity,
  //                                 padding:
  //                                     const EdgeInsets.symmetric(vertical: 20),
  //                                 child: const Center(
  //                                   child: Column(
  //                                     children: [
  //                                       CircularProgressIndicator(
  //                                         valueColor:
  //                                             AlwaysStoppedAnimation<Color>(
  //                                                 AppColors.primary),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ),
  //                             // Show scroll progress indicator - removed due to linter issues
  //                             // Show "No more products" message when all products are loaded
  //                           ],
  //                         ),
  //                       ),
  //                       Positioned(
  //                         left: 0,
  //                         right: 0,
  //                         bottom: 0,
  //                         child: Builder(
  //                           builder: (BuildContext context) {
  //                             final MediaQueryData mediaQuery =
  //                                 MediaQuery.of(context);
  //                             final double bottomPadding =
  //                                 mediaQuery.padding.bottom;
  //                             if (bottomPadding > 0) {
  //                               return Container(
  //                                 height: bottomPadding,
  //                                 color: Colors.blueGrey,
  //                               );
  //                             } else {
  //                               return const SizedBox.shrink();
  //                             }
  //                           },
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ));

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

  /// Parse price consistently for filtering and display
  double? _parsePrice(String price) {
    try {
      if (price.isEmpty) return null;

      // Remove any existing formatting and parse the number
      final cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
      final double? priceValue = double.tryParse(cleanPrice);

      // Validate price is positive and reasonable
      if (priceValue == null || priceValue < 0 || priceValue > 1000000) {
        return null;
      }

      return priceValue;
    } catch (e) {
      log('Error parsing price "$price": $e');
      return null;
    }
  }

  /// Format price with comma separators for thousands
  String _formatPrice(String price) {
    try {
      final double? priceValue = _parsePrice(price);

      if (priceValue == null) {
        return price; // Return original if parsing fails
      }

      // Format with commas for thousands
      final formatter = NumberFormat('#,###.##');
      return formatter.format(priceValue);
    } catch (e) {
      log('Error formatting price: $e');
      return price; // Return original if formatting fails
    }
  }

  void _applyFilters(
      List<String> vendors,
      int? priceSorting,
      RangeValues priceRange,
      bool inStockOnly,
      bool onSaleOnly,
      List<VendorProduct> productProviderProducts) async {
    // Show loading state
    setState(() {
      _isApplyingFilters = true;
      filterVendor = vendors;
      this.priceSorting = priceSorting;
      currentPriceRange = priceRange;
      currentInStockOnly = inStockOnly;
      currentOnSaleOnly = onSaleOnly;
      isVendorFiltered = vendors.isNotEmpty;
    });

    // Add small delay to show loading indicator
    await Future.delayed(const Duration(milliseconds: 300));

    // If vendors are selected, make API call with vendor codes
    if (vendors.isNotEmpty) {
      await _fetchFilteredProducts(vendors);
      // After API call, products are already filtered by vendor
      // Apply only price range and sorting filters
      _applyPriceAndSortingFilters();
    } else {
      // No vendor filter - use ProductProvider data for filtering
      setState(() {
        List<VendorProduct> productsToFilter = productProviderProducts;
        tempProductList = List.from(productsToFilter);
        log('No vendor filter applied, showing all ${productsToFilter.length} products');
      });

      // Apply price range and sorting filters
      _applyPriceAndSortingFilters();
    }

    // Hide loading state
    setState(() {
      _isApplyingFilters = false;
    });
  }

  void _applyPriceAndSortingFilters() {
    setState(() {
      // Apply price range filter
      tempProductList = tempProductList.where((product) {
        double? price = _parsePrice(product.vendorpricePrice);
        return price != null &&
            price >= currentPriceRange.start &&
            price <= currentPriceRange.end;
      }).toList();

      log('Price range filtering: ${currentPriceRange.start.toStringAsFixed(2)} - ${currentPriceRange.end.toStringAsFixed(2)}');
      log('Products after price filtering: ${tempProductList.length}');

      // Apply sorting
      if (priceSorting != null) {
        if (priceSorting == 1) {
          // Price: Low to High
          tempProductList.sort((a, b) {
            double priceA = _parsePrice(a.vendorpricePrice) ?? 0;
            double priceB = _parsePrice(b.vendorpricePrice) ?? 0;
            return priceA.compareTo(priceB);
          });
          log('Applied sorting: Price Low to High');
        } else if (priceSorting == 2) {
          // Price: High to Low
          tempProductList.sort((a, b) {
            double priceA = _parsePrice(a.vendorpricePrice) ?? 0;
            double priceB = _parsePrice(b.vendorpricePrice) ?? 0;
            return priceB.compareTo(priceA);
          });
          log('Applied sorting: Price High to Low');
        } else if (priceSorting == 3) {
          // Name: A to Z
          tempProductList
              .sort((a, b) => (a.productName).compareTo(b.productName));
          log('Applied sorting: Name A to Z');
        } else if (priceSorting == 4) {
          // Name: Z to A
          tempProductList
              .sort((a, b) => (b.productName).compareTo(a.productName));
          log('Applied sorting: Name Z to A');
        }
      }

      // Update total product count for filtered results
      totalProductCount = tempProductList.length;

      // Log final filter results
      log('=== FILTER RESULTS ===');
      log('Total products after all filters: ${tempProductList.length}');
      log('Vendor filter active: ${filterVendor.isNotEmpty}');
      log('Price range: \$${currentPriceRange.start.toStringAsFixed(2)} - \$${currentPriceRange.end.toStringAsFixed(2)}');
      log('Sorting: ${priceSorting != null ? "Active ($priceSorting)" : "None"}');
      log('In stock only: $currentInStockOnly');
      log('On sale only: $currentOnSaleOnly');
      log('=== END FILTER RESULTS ===');
    });
  }
}
