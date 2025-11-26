import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/base_url.dart';
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/services/category_service.dart';
import 'package:minsellprice/screens/unified_product_list_screen.dart';

/// State class for unified product list
class UnifiedProductListState {
  final List<VendorProduct> products;
  final List<VendorProduct> filteredProducts;
  final List<VendorProduct> searchResults;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSearching;
  final bool isApplyingFilters;
  final bool hasMoreData;
  final bool hasError;
  final String? errorMessage;
  final int currentPage;
  final int totalCount;
  final double maxPrice;
  final RangeValues priceRange;
  final List<String> selectedVendors;
  final int? priceSorting;
  final bool inStockOnly;
  final bool onSaleOnly;
  final Map<String, int> vendorProductCounts;
  final Map<String, String> vendorCodes;

  const UnifiedProductListState({
    this.products = const [],
    this.filteredProducts = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSearching = false,
    this.isApplyingFilters = false,
    this.hasMoreData = true,
    this.hasError = false,
    this.errorMessage,
    this.currentPage = 1,
    this.totalCount = 0,
    this.maxPrice = 1000.0,
    this.priceRange = const RangeValues(0, 1000),
    this.selectedVendors = const [],
    this.priceSorting,
    this.inStockOnly = false,
    this.onSaleOnly = false,
    this.vendorProductCounts = const {},
    this.vendorCodes = const {},
  });

  UnifiedProductListState copyWith({
    List<VendorProduct>? products,
    List<VendorProduct>? filteredProducts,
    List<VendorProduct>? searchResults,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSearching,
    bool? isApplyingFilters,
    bool? hasMoreData,
    bool? hasError,
    String? errorMessage,
    int? currentPage,
    int? totalCount,
    double? maxPrice,
    RangeValues? priceRange,
    List<String>? selectedVendors,
    int? priceSorting,
    bool? inStockOnly,
    bool? onSaleOnly,
    Map<String, int>? vendorProductCounts,
    Map<String, String>? vendorCodes,
  }) {
    return UnifiedProductListState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSearching: isSearching ?? this.isSearching,
      isApplyingFilters: isApplyingFilters ?? this.isApplyingFilters,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      maxPrice: maxPrice ?? this.maxPrice,
      priceRange: priceRange ?? this.priceRange,
      selectedVendors: selectedVendors ?? this.selectedVendors,
      priceSorting: priceSorting ?? this.priceSorting,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      onSaleOnly: onSaleOnly ?? this.onSaleOnly,
      vendorProductCounts: vendorProductCounts ?? this.vendorProductCounts,
      vendorCodes: vendorCodes ?? this.vendorCodes,
    );
  }
}

/// Controller for unified product list screen
class UnifiedProductListController {
  final ProductListType type;
  final String identifier;
  final String displayName;
  final List<Map<String, dynamic>>? initialData;

  // State management
  final ValueNotifier<UnifiedProductListState> stateNotifier =
      ValueNotifier(const UnifiedProductListState());

  // UI controllers
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // API strategy
  late ProductListApiStrategy _apiStrategy;

  // Pagination
  int _currentPage = 1;
  bool _hasUserScrolled = false;
  BuildContext? _context;

  UnifiedProductListController({
    required this.type,
    required this.identifier,
    required this.displayName,
    this.initialData,
  }) {
    _apiStrategy = _createApiStrategy();
  }

  /// Create appropriate API strategy based on type
  ProductListApiStrategy _createApiStrategy() {
    switch (type) {
      case ProductListType.brand:
        return BrandApiStrategy(identifier);
      case ProductListType.category:
        return CategoryApiStrategy(identifier);
      case ProductListType.search:
        return SearchApiStrategy(identifier);
    }
  }

  /// Initialize the controller
  Future<void> initialize(BuildContext context) async {
    _context = context;
    _addScrollListener();

    if (initialData != null) {
      await _processInitialData();
    } else {
      await loadProducts(context);
    }
  }

  /// Update context (useful when screen is rebuilt)
  void updateContext(BuildContext context) {
    _context = context;
  }

  /// Manually trigger load more products (for testing)
  Future<void> triggerLoadMore() async {
    log('Manually triggering load more products');
    await loadMoreProducts();
  }

  /// Process initial data if provided
  Future<void> _processInitialData() async {
    final products =
        initialData!.map((product) => VendorProduct.fromJson(product)).toList();

    _updateState(
      products: products,
      filteredProducts: List.from(products),
      isLoading: false,
    );

    // Ensure vendor data is loaded immediately for filter menu
    await _extractVendorData();
    _calculatePriceRange();
    log('Initial data processed: ${products.length} products, ${stateNotifier.value.vendorProductCounts.length} vendors loaded');
  }

  /// Add scroll listener for pagination
  void _addScrollListener() {
    scrollController.addListener(() {
      final position = scrollController.position;
      final pixels = position.pixels;
      final maxScrollExtent = position.maxScrollExtent;
      final userScrollDirection = position.userScrollDirection;

      // Track if user has scrolled
      if (userScrollDirection != ScrollDirection.idle) {
        _hasUserScrolled = true;
      }

      // Debug scroll information (only when near bottom)
      if (pixels >= maxScrollExtent - 200) {
        log('Scroll near bottom: pixels=$pixels, maxExtent=$maxScrollExtent');
        log('Has scrolled: $_hasUserScrolled, Has more data: ${stateNotifier.value.hasMoreData}, Loading more: ${stateNotifier.value.isLoadingMore}');
      }

      // Check if we should load more products
      // Only load more if no filters are active (filters should handle their own pagination)
      if (_hasUserScrolled &&
          stateNotifier.value.hasMoreData &&
          !stateNotifier.value.isLoadingMore &&
          maxScrollExtent > 0 && // Ensure we have content to scroll
          pixels >= maxScrollExtent - 100 &&
          !isAnyFilterActive()) {
        // Don't load more when filters are active

        log('Scroll detection: Triggering load more products');
        log('Current products: ${stateNotifier.value.products.length}, Total count: ${stateNotifier.value.totalCount}');
        loadMoreProducts();
      } else if (isAnyFilterActive()) {
        log('Scroll detected but filters are active - skipping pagination');
      }
    });
  }

  /// Load products from API
  Future<void> loadProducts(BuildContext context,
      {bool loadMore = false}) async {
    if (!loadMore) {
      _updateState(isLoading: true, hasError: false, errorMessage: null);
    } else {
      _updateState(isLoadingMore: true);
    }

    try {
      final result = await _apiStrategy.fetchProducts(
        page: _currentPage,
        context: context,
      );

      final products = result['products'] as List<VendorProduct>;
      final totalCount = result['totalCount'] as int;
      // Get hasMore from API response if available, otherwise calculate it
      final bool? apiHasMore = result['hasMore'] as bool?;
      final int? currentPageNo = result['currentPage'] as int?;
      final int? totalPages = result['totalPages'] as int?;

      // Determine if there's more data
      bool hasMoreData;
      if (apiHasMore != null) {
        // Use API's has_more field directly (most reliable)
        hasMoreData = apiHasMore;
        log('Using API has_more field: $hasMoreData');
      } else if (currentPageNo != null && totalPages != null && totalPages > 0) {
        // Fallback: check if current page is less than total pages
        hasMoreData = currentPageNo < totalPages;
        log('Using page comparison: currentPage=$currentPageNo, totalPages=$totalPages, hasMore=$hasMoreData');
      } else {
        // Last fallback: use the old calculation method
        final currentProducts = stateNotifier.value.products;
        final newProducts =
            loadMore ? [...currentProducts, ...products] : products;
        hasMoreData = _calculateHasMoreDataFromTotalCount(newProducts.length, totalCount);
        log('Using fallback calculation: loaded=${loadMore ? currentProducts.length + products.length : products.length}, total=$totalCount, hasMore=$hasMoreData');
      }

      // Sync current page with API's returned page number
      if (currentPageNo != null && currentPageNo != _currentPage) {
        log('Page number mismatch: requested $_currentPage, API returned $currentPageNo - syncing');
        _currentPage = currentPageNo;
      }

      // If products list is empty, there's definitely no more data
      if (products.isEmpty) {
        hasMoreData = false;
        log('No products returned - setting hasMoreData to false');
      }

      // If on initial load and we got an invalid page (page_no > total_no_of_pages), reset to page 1
      if (!loadMore && currentPageNo != null && totalPages != null && totalPages > 0 && currentPageNo > totalPages) {
        log('Invalid page detected on initial load: page $currentPageNo > total pages $totalPages - resetting to page 1');
        _currentPage = 1;
        // Retry with page 1
        await loadProducts(context, loadMore: false);
        return;
      }

      if (products.isNotEmpty || loadMore) {
        // If loading more and got empty products, don't update the list
        // but still update the state to reflect no more data
        if (products.isEmpty && loadMore) {
          log('Load more returned empty products - stopping pagination');
          _updateState(
            isLoading: false,
            isLoadingMore: false,
            hasMoreData: false,
            totalCount: totalCount,
          );
          return;
        }

        final currentProducts = stateNotifier.value.products;
        final newProducts =
            loadMore ? [...currentProducts, ...products] : products;

        // Check if filters are active
        final isFiltered = isAnyFilterActive();

        _updateState(
          products: newProducts,
          filteredProducts: isFiltered
              ? stateNotifier.value.filteredProducts
              : List.from(newProducts),
          isLoading: false,
          isLoadingMore: false,
          hasMoreData: hasMoreData,
          totalCount: totalCount,
        );

        if (isFiltered) {
          log('Filters are active - preserving filtered state during pagination');
        }

        if (!loadMore) {
          // Ensure vendor data is loaded immediately for filter menu
          await _extractVendorData();
          _calculatePriceRange();
          log('Vendor data loaded: ${stateNotifier.value.vendorProductCounts.length} vendors available');
        }

        log('Loaded ${products.length} products (${loadMore ? 'load more' : 'initial'})');
        log('Total products: ${newProducts.length}, API Total Count: $totalCount, Has more data: $hasMoreData');
      } else {
        _updateState(
          isLoading: false,
          isLoadingMore: false,
          hasMoreData: false,
          totalCount: totalCount,
        );
      }
    } catch (e) {
      log('Error loading products: $e');
      _updateState(
        isLoading: false,
        isLoadingMore: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Calculate if there's more data to load based on API total count
  bool _calculateHasMoreDataFromTotalCount(int loadedCount, int totalCount) {
    if (totalCount <= 0) return false;

    // If we've loaded fewer products than the total available, there's more data
    return loadedCount < totalCount;
  }

  /// Load more products for pagination
  Future<void> loadMoreProducts([BuildContext? context]) async {
    log('loadMoreProducts called - isLoadingMore: ${stateNotifier.value.isLoadingMore}, hasMoreData: ${stateNotifier.value.hasMoreData}');

    if (stateNotifier.value.isLoadingMore || !stateNotifier.value.hasMoreData) {
      log('Skipping load more - isLoadingMore: ${stateNotifier.value.isLoadingMore}, hasMoreData: ${stateNotifier.value.hasMoreData}');
      return;
    }

    _currentPage++;
    log('Loading page $_currentPage');

    // Use stored context or provided context
    final contextToUse = context ?? _context;
    if (contextToUse != null) {
      await loadProducts(contextToUse, loadMore: true);
    } else {
      log('Error: No context available for loadMoreProducts');
    }
  }

  /// Perform search - searches within already loaded products locally
  Future<void> performSearch(String query, BuildContext context) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    _updateState(isSearching: true);

    try {
      // Search locally within already-loaded products
      final productsToSearch = isAnyFilterActive()
          ? stateNotifier.value.filteredProducts
          : stateNotifier.value.products;

      final queryLower = query.toLowerCase().trim();

      final searchResults = productsToSearch.where((product) {
        // Search in multiple fields (case-insensitive)
        final productMpn = product.productMpn.toLowerCase();
        final productName = product.productName.toLowerCase();
        final brandName = product.brandName.toLowerCase();
        final vendorName = product.vendorName.toLowerCase();

        // Match if query is found in any of these fields
        return productMpn.contains(queryLower) ||
            productName.contains(queryLower) ||
            brandName.contains(queryLower) ||
            vendorName.contains(queryLower);
      }).toList();

      _updateState(
        searchResults: searchResults,
        isSearching: false,
      );

      log('Local search returned ${searchResults.length} results for: "$query" from ${productsToSearch.length} products');

      // Scroll to top to show search results
      _scrollToTop();
    } catch (e) {
      log('Error performing search: $e');
      _updateState(
        searchResults: [],
        isSearching: false,
      );
    }
  }

  /// Clear search results
  void clearSearch() {
    searchController.clear();
    _updateState(searchResults: [], isSearching: false);

    // Scroll to top when clearing search
    _scrollToTop();
  }

  /// Apply filters (following original product_list.dart logic)
  Future<void> applyFilters(
    List<String> vendors,
    int? priceSorting,
    RangeValues priceRange,
    bool inStockOnly,
    bool onSaleOnly,
    BuildContext context,
  ) async {
    log('=== Controller: Applying Filters ===');
    log('Selected vendors: $vendors');
    log('Price sorting: $priceSorting');
    log('Price range: $priceRange');
    log('In stock only: $inStockOnly');
    log('On sale only: $onSaleOnly');
    log('Product list type: $type');
    log('=== End Controller: Applying Filters ===');

    _updateState(isApplyingFilters: true);

    // Add small delay to show loading indicator
    await Future.delayed(const Duration(milliseconds: 300));

    // If vendors are selected, make API call with vendor codes (like original)
    if (vendors.isNotEmpty && type == ProductListType.brand) {
      log('Making API call for vendor filtering with ${vendors.length} vendors');
      await _fetchFilteredProductsFromAPI(vendors, context);
      // After API call, products are already filtered by vendor
      // Apply only price range and sorting filters
      _applyPriceAndSortingFilters(
          priceSorting, priceRange, inStockOnly, onSaleOnly);
    } else {
      log('Using local filtering (no vendor filter or not brand type)');
      // No vendor filter or not brand type - use current products for filtering
      _updateState(
        filteredProducts: List.from(stateNotifier.value.products),
        selectedVendors: vendors,
        priceSorting: priceSorting,
        priceRange: priceRange,
        inStockOnly: inStockOnly,
        onSaleOnly: onSaleOnly,
      );

      // Apply price range and sorting filters
      _applyPriceAndSortingFilters(
          priceSorting, priceRange, inStockOnly, onSaleOnly);
    }

    _updateState(isApplyingFilters: false);

    // Scroll to top after applying filters to show filtered results
    _scrollToTop();
  }

  /// Scroll to top of the list
  void _scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      log('Scrolled to top after applying filters');
    }
  }

  /// Check if vendor data is ready for filter menu
  bool isVendorDataReady() {
    return stateNotifier.value.vendorProductCounts.isNotEmpty;
  }

  /// Force load vendor data if not ready (non-blocking)
  void ensureVendorDataLoaded() {
    if (!isVendorDataReady() && _context != null) {
      log('Vendor data not ready, loading in background...');
      _extractVendorData().then((_) {
        log('Vendor data loaded: ${stateNotifier.value.vendorProductCounts.length} vendors available');
      }).catchError((e) {
        log('Error loading vendor data: $e');
      });
    }
  }

  /// Fetch filtered products from API using vendor codes (like original)
  Future<void> _fetchFilteredProductsFromAPI(
      List<String> selectedVendors, BuildContext context) async {
    try {
      log('=== Fetching Filtered Products from API ===');
      log('Selected vendors: $selectedVendors');
      log('Available vendor codes: ${stateNotifier.value.vendorCodes}');

      // Get vendor codes for selected vendors
      List<String> vendorCodesToSend = [];
      for (String vendorName in selectedVendors) {
        if (stateNotifier.value.vendorCodes.containsKey(vendorName)) {
          vendorCodesToSend.add(stateNotifier.value.vendorCodes[vendorName]!);
          log('Selected vendor: "$vendorName" with code: ${stateNotifier.value.vendorCodes[vendorName]}');
        } else {
          log('⚠️ Vendor code not found for: "$vendorName"');
        }
      }

      if (vendorCodesToSend.isEmpty) {
        log('⚠️ No vendor codes found for selected vendors');
        return;
      }

      // Make API call with vendor codes
      String vendorCodesParam = vendorCodesToSend.join(',');
      log('Making filtered API call with vendor codes: $vendorCodesParam');
      log('API URL: $brandUrl/brands/$identifier?page_no=1&vendor=$vendorCodesParam');

      // Use the API method that supports vendor codes
      final response = await BrandsApi.getProductListByBrandNameWithVendor(
          identifier, 1, vendorCodesParam, context);

      if (response != null) {
        final Map<String, dynamic> decoded = jsonDecode(response);
        final List<dynamic> jsonList = decoded['brand_product'] ?? [];
        final List<VendorProduct> filteredProducts =
            jsonList.map((e) => VendorProduct.fromJson(e)).toList();

        log('Filtered API returned ${filteredProducts.length} products for selected vendors');

        // Log some sample products to verify they're from different vendors
        if (filteredProducts.isNotEmpty) {
          log('Sample filtered products:');
          for (int i = 0; i < filteredProducts.length && i < 3; i++) {
            log('  Product ${i + 1}: ${filteredProducts[i].productName} from ${filteredProducts[i].vendorName}');
          }
        }

        // Update the product list with filtered results
        // For filtered results, disable pagination since we get all results at once
        _updateState(
          products: filteredProducts,
          filteredProducts: List.from(filteredProducts),
          totalCount: filteredProducts.length,
          hasMoreData: false, // Disable pagination for filtered results
        );

        log('Updated products with ${filteredProducts.length} products from API');
      } else {
        log('⚠️ API response is null');
      }
    } catch (e) {
      log('Error fetching filtered products: $e');
    }
  }

  /// Apply price range and sorting filters (like original)
  void _applyPriceAndSortingFilters(int? priceSorting, RangeValues priceRange,
      bool inStockOnly, bool onSaleOnly) {
    List<VendorProduct> filteredProducts =
        List.from(stateNotifier.value.filteredProducts);

    // Apply price range filter
    filteredProducts = filteredProducts.where((product) {
      double? price = _parsePrice(product.vendorpricePrice);
      return price != null &&
          price >= priceRange.start &&
          price <= priceRange.end;
    }).toList();

    log('Price range filtering: ${priceRange.start.toStringAsFixed(2)} - ${priceRange.end.toStringAsFixed(2)}');
    log('Products after price filtering: ${filteredProducts.length}');

    // Apply sorting
    if (priceSorting != null) {
      if (priceSorting == 1) {
        // Price: Low to High
        filteredProducts.sort((a, b) {
          double priceA = _parsePrice(a.vendorpricePrice) ?? 0;
          double priceB = _parsePrice(b.vendorpricePrice) ?? 0;
          return priceA.compareTo(priceB);
        });
        log('Applied sorting: Price Low to High');
      } else if (priceSorting == 2) {
        // Price: High to Low
        filteredProducts.sort((a, b) {
          double priceA = _parsePrice(a.vendorpricePrice) ?? 0;
          double priceB = _parsePrice(b.vendorpricePrice) ?? 0;
          return priceB.compareTo(priceA);
        });
        log('Applied sorting: Price High to Low');
      } else if (priceSorting == 3) {
        // Name: A to Z
        filteredProducts.sort((a, b) => a.productName.compareTo(b.productName));
        log('Applied sorting: Name A to Z');
      } else if (priceSorting == 4) {
        // Name: Z to A
        filteredProducts.sort((a, b) => b.productName.compareTo(a.productName));
        log('Applied sorting: Name Z to A');
      }
    }

    // Update filtered products
    _updateState(filteredProducts: filteredProducts);

    // Log final filter results
    log('=== FILTER RESULTS ===');
    log('Total products after all filters: ${filteredProducts.length}');
    log('Vendor filter active: ${stateNotifier.value.selectedVendors.isNotEmpty}');
    log('Price range: \$${priceRange.start.toStringAsFixed(2)} - \$${priceRange.end.toStringAsFixed(2)}');
    log('Sorting: ${priceSorting != null ? "Active ($priceSorting)" : "None"}');
    log('In stock only: $inStockOnly');
    log('On sale only: $onSaleOnly');
    log('=== END FILTER RESULTS ===');
  }

  /// Clear all filters (like original)
  void clearAllFilters() {
    // Re-enable pagination when filters are cleared
    final hasMoreData = _calculateHasMoreDataFromTotalCount(
        stateNotifier.value.products.length, stateNotifier.value.totalCount);

    _updateState(
      filteredProducts: List.from(stateNotifier.value.products),
      selectedVendors: [],
      priceSorting: null,
      priceRange: RangeValues(0, stateNotifier.value.maxPrice),
      inStockOnly: false,
      onSaleOnly: false,
      hasMoreData: hasMoreData, // Re-enable pagination
    );
    log('Cleared all filters: Showing ${stateNotifier.value.products.length} products, hasMoreData: $hasMoreData');

    // Scroll to top after clearing filters
    _scrollToTop();
  }

  /// Check if any filter is active
  bool isAnyFilterActive() {
    final state = stateNotifier.value;
    bool hasVendorFilter = state.selectedVendors.isNotEmpty;
    bool hasPriceFilter = state.priceRange.end < state.maxPrice;
    bool hasSorting = state.priceSorting != null;
    bool hasOtherFilters = state.inStockOnly || state.onSaleOnly;
    return hasVendorFilter || hasPriceFilter || hasSorting || hasOtherFilters;
  }

  /// Retry loading products
  Future<void> retry(BuildContext context) async {
    _currentPage = 1;
    await loadProducts(context);
  }

  /// Extract vendor data from API response
  Future<void> _extractVendorData() async {
    if (_context == null) {
      log('No context available for vendor data extraction');
      return;
    }

    try {
      // For brand products, fetch vendor data from API
      if (type == ProductListType.brand) {
        await _fetchVendorDataFromBrandAPI();
      } else {
        // For other types, extract from current products
        _extractVendorDataFromProducts();
      }
    } catch (e) {
      log('Error extracting vendor data: $e');
      // Fallback to extracting from products
      _extractVendorDataFromProducts();
    }
  }

  /// Fetch vendor data from brand API
  Future<void> _fetchVendorDataFromBrandAPI() async {
    try {
      log('Fetching vendor data from main brand API: $identifier');
      final response =
          await BrandsApi.getProductListByBrandName(identifier, 1, _context!);

      if (response != null) {
        final Map<String, dynamic> decoded = jsonDecode(response);

        // Parse vendor data from API response
        final List<dynamic> vendorDataList = decoded['vendor_data'] ?? [];
        Map<String, int> vendorCounts = {};
        Map<String, String> vendorCodes = {};

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
            vendorCounts[vendorName] = productCount;
            if (vendorCode.isNotEmpty) {
              vendorCodes[vendorName] = vendorCode;
            }
            log('Added vendor: "$vendorName" with $productCount products (code: $vendorCode)');
          } else {
            log('⚠️ Skipping vendor with empty name: $vendor');
          }
        }

        _updateState(
          vendorProductCounts: vendorCounts,
          vendorCodes: vendorCodes,
        );

        log('Updated state with vendor data: ${vendorCounts.length} vendors');

        log('Fetched vendor data from main brand API: ${vendorCounts.length} vendors');
        log('API vendor names: ${vendorCounts.keys.toList()}');
        log('Complete vendor data map: $vendorCounts');
      } else {
        log('Failed to fetch vendor data from main brand API');
        _extractVendorDataFromProducts();
      }
    } catch (e) {
      log('Error fetching vendor data from main brand API: $e');
      _extractVendorDataFromProducts();
    }
  }

  /// Extract vendor data from current products (fallback)
  void _extractVendorDataFromProducts() {
    final products = stateNotifier.value.products;
    Map<String, int> vendorCounts = {};
    Map<String, String> vendorCodes = {};

    for (var product in products) {
      if (product.vendorName.isNotEmpty) {
        vendorCounts[product.vendorName] =
            (vendorCounts[product.vendorName] ?? 0) + 1;
      }
    }

    _updateState(
      vendorProductCounts: vendorCounts,
      vendorCodes: vendorCodes,
    );

    log('Extracted ${vendorCounts.length} vendors from products');
    log('Vendor data from products: $vendorCounts');
  }

  /// Calculate price range from products
  void _calculatePriceRange() {
    final products = stateNotifier.value.products;
    if (products.isEmpty) return;

    final validPrices = products
        .map((product) => _parsePrice(product.vendorpricePrice))
        .where((price) => price != null)
        .cast<double>()
        .toList();

    if (validPrices.isNotEmpty) {
      final maxPrice = validPrices.reduce((a, b) => a > b ? a : b);
      final roundedMaxPrice = ((maxPrice / 50).ceil() * 50).toDouble();

      _updateState(
        maxPrice: roundedMaxPrice,
        priceRange: RangeValues(0, roundedMaxPrice),
      );

      log('Price range calculated: \$0 - \$${roundedMaxPrice.toStringAsFixed(2)}');
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

  /// Update state with new values
  void _updateState({
    List<VendorProduct>? products,
    List<VendorProduct>? filteredProducts,
    List<VendorProduct>? searchResults,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSearching,
    bool? isApplyingFilters,
    bool? hasMoreData,
    bool? hasError,
    String? errorMessage,
    int? currentPage,
    int? totalCount,
    double? maxPrice,
    RangeValues? priceRange,
    List<String>? selectedVendors,
    int? priceSorting,
    bool? inStockOnly,
    bool? onSaleOnly,
    Map<String, int>? vendorProductCounts,
    Map<String, String>? vendorCodes,
  }) {
    stateNotifier.value = stateNotifier.value.copyWith(
      products: products,
      filteredProducts: filteredProducts,
      searchResults: searchResults,
      isLoading: isLoading,
      isLoadingMore: isLoadingMore,
      isSearching: isSearching,
      isApplyingFilters: isApplyingFilters,
      hasMoreData: hasMoreData,
      hasError: hasError,
      errorMessage: errorMessage,
      currentPage: currentPage,
      totalCount: totalCount,
      maxPrice: maxPrice,
      priceRange: priceRange,
      selectedVendors: selectedVendors,
      priceSorting: priceSorting,
      inStockOnly: inStockOnly,
      onSaleOnly: onSaleOnly,
      vendorProductCounts: vendorProductCounts,
      vendorCodes: vendorCodes,
    );
  }

  /// Dispose resources
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    stateNotifier.dispose();
  }
}

/// Abstract API strategy for different product list sources
abstract class ProductListApiStrategy {
  Future<Map<String, dynamic>> fetchProducts({
    required int page,
    required BuildContext context,
  });

  Future<List<VendorProduct>> searchProducts(
    String query,
    BuildContext context,
  );

  Future<List<VendorProduct>> fetchFilteredProducts({
    required List<String> vendorCodes,
    required int page,
    required BuildContext context,
  });
}

/// Brand API strategy
class BrandApiStrategy implements ProductListApiStrategy {
  final String brandName;

  BrandApiStrategy(this.brandName);

  @override
  Future<Map<String, dynamic>> fetchProducts({
    required int page,
    required BuildContext context,
  }) async {
    final response =
        await BrandsApi.getProductListByBrandName(brandName, page, context);

    if (response != null && response.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(response);
        final List<dynamic> jsonList = decoded['brand_product'] ?? [];
        final List<VendorProduct> products =
            jsonList.map((e) => VendorProduct.fromJson(e)).toList();
        final int totalCount = decoded['productCount'] ?? 0;
        
        // Extract pagination fields from API response
        final bool hasMore = decoded['has_more'] ?? false;
        final int currentPageNo = int.tryParse(decoded['page_no']?.toString() ?? '') ?? page;
        final int totalNoOfPages = int.tryParse(decoded['total_no_of_pages']?.toString() ?? '') ?? 0;

        log('Brand API - Page: $currentPageNo, Products: ${products.length}, Total Count: $totalCount, Total Pages: $totalNoOfPages, Has More: $hasMore');

        // Determine if there's more data based on API response
        // If has_more is false OR current page >= total pages, there's no more data
        final bool hasMoreData = hasMore && (totalNoOfPages == 0 || currentPageNo < totalNoOfPages);

        return {
          'products': products,
          'totalCount': totalCount,
          'hasMore': hasMoreData,
          'currentPage': currentPageNo,
          'totalPages': totalNoOfPages,
        };
      } catch (e) {
        log('Error parsing brand API response: $e');
        return {'products': <VendorProduct>[], 'totalCount': 0, 'hasMore': false};
      }
    }
    return {'products': <VendorProduct>[], 'totalCount': 0, 'hasMore': false};
  }

  @override
  Future<List<VendorProduct>> searchProducts(
    String query,
    BuildContext context,
  ) async {
    final searchData = await BrandsApi.fetchSearchProduct(context, query);

    if (searchData != null) {
      final List<dynamic> jsonList = searchData['brand_product'] ?? [];
      final List<VendorProduct> allResults =
          jsonList.map((e) => VendorProduct.fromJson(e)).toList();

      // Filter by brand
      return allResults.where((product) {
        return product.brandName.toLowerCase() == brandName.toLowerCase();
      }).toList();
    }
    return [];
  }

  @override
  Future<List<VendorProduct>> fetchFilteredProducts({
    required List<String> vendorCodes,
    required int page,
    required BuildContext context,
  }) async {
    final response = await BrandsApi.getProductListByBrandNameWithVendor(
        brandName, page, vendorCodes.join(','), context);

    if (response != null && response.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(response);
        final List<dynamic> jsonList = decoded['brand_product'] ?? [];
        return jsonList.map((e) => VendorProduct.fromJson(e)).toList();
      } catch (e) {
        log('Error parsing filtered API response: $e');
        return [];
      }
    }
    return [];
  }
}

/// Category API strategy
class CategoryApiStrategy implements ProductListApiStrategy {
  final String categoryPath;

  CategoryApiStrategy(this.categoryPath);

  @override
  Future<Map<String, dynamic>> fetchProducts({
    required int page,
    required BuildContext context,
  }) async {
    final products = await CategoryService.fetchCategoryProducts(
      context: context,
      categoryPath: categoryPath,
      pageNumber: page,
    );

    if (products != null) {
      final List<VendorProduct> vendorProducts = products
          .map((e) => _convertCategoryProductToVendorProduct(e))
          .toList();

      // For category products, we don't have total count from API
      // So we'll use the products length as a fallback
      return {
        'products': vendorProducts,
        'totalCount': vendorProducts.length,
      };
    }
    return {'products': <VendorProduct>[], 'totalCount': 0};
  }

  @override
  Future<List<VendorProduct>> searchProducts(
    String query,
    BuildContext context,
  ) async {
    final searchData = await CategoryService.searchCategoryProducts(
      categoryPath: categoryPath,
      searchQuery: query,
      context: context,
    );

    if (searchData != null) {
      return searchData.brandProduct
          .map((e) => _convertCategoryProductToVendorProduct(e.toJson()))
          .toList();
    }
    return [];
  }

  @override
  Future<List<VendorProduct>> fetchFilteredProducts({
    required List<String> vendorCodes,
    required int page,
    required BuildContext context,
  }) async {
    // Category API doesn't support vendor filtering yet
    // Fall back to regular fetch
    final result = await fetchProducts(page: page, context: context);
    return result['products'] as List<VendorProduct>;
  }

  /// Convert CategoryProduct to VendorProduct
  VendorProduct _convertCategoryProductToVendorProduct(
      Map<String, dynamic> categoryProduct) {
    try {
      log('Converting category product: ${categoryProduct['product_name']}');

      // Parse lowest_vendor array if it exists
      List<LowestVendor>? lowestVendorList;
      if (categoryProduct["lowest_vendor"] != null) {
        try {
          final lowestVendorData = categoryProduct["lowest_vendor"];
          if (lowestVendorData is List && lowestVendorData.isNotEmpty) {
            lowestVendorList = lowestVendorData
                .map((x) => LowestVendor.fromJson(x as Map<String, dynamic>))
                .toList();
            log('✅ Parsed ${lowestVendorList.length} vendor(s) from lowest_vendor array');
            for (var vendor in lowestVendorList) {
              log('  - Vendor: ${vendor.vendorName}, Price: ${vendor.vendorpricePrice}, URL: ${vendor.vendorUrl}');
            }
          } else {
            log('⚠️ lowest_vendor exists but is empty or not a list');
          }
        } catch (e) {
          log('❌ Error parsing lowest_vendor: $e');
          log('lowest_vendor data: ${categoryProduct["lowest_vendor"]}');
        }
      } else {
        log('⚠️ No lowest_vendor field found in category product');
      }

      // Extract vendor info - prefer first lowest_vendor if available, otherwise use top-level fields
      String vendorName = '';
      String vendorUrl = '';
      String vendorpricePrice = '0.00';
      String vendorpriceDate = '';

      if (lowestVendorList != null && lowestVendorList.isNotEmpty) {
        // Use data from first lowest vendor (typically the lowest price)
        final firstVendor = lowestVendorList.first;
        vendorName = firstVendor.vendorName.isNotEmpty
            ? firstVendor.vendorName
            : (categoryProduct["vendor_name"]?.toString() ?? '');
        vendorUrl = firstVendor.vendorUrl.isNotEmpty
            ? firstVendor.vendorUrl
            : (categoryProduct["vendor_url"]?.toString() ?? '');
        vendorpricePrice = firstVendor.vendorpricePrice.isNotEmpty
            ? firstVendor.vendorpricePrice
            : (categoryProduct["vendorprice_price"]?.toString() ?? '0.00');
        vendorpriceDate = firstVendor.vendorpriceDate.isNotEmpty
            ? firstVendor.vendorpriceDate
            : (categoryProduct["vendorprice_date"]?.toString() ?? '');
      } else {
        // Fallback to top-level vendor fields
        vendorName = categoryProduct["vendor_name"]?.toString() ?? '';
        vendorUrl = categoryProduct["vendor_url"]?.toString() ?? '';
        vendorpricePrice =
            categoryProduct["vendorprice_price"]?.toString() ?? '0.00';
        vendorpriceDate = categoryProduct["vendorprice_date"]?.toString() ?? '';
      }

      log('Final vendor name: $vendorName');
      log('Final vendor URL: $vendorUrl');
      log('Final vendor price: $vendorpricePrice');

      return VendorProduct(
        productId: categoryProduct["product_id"] ?? 0,
        vendorpricePrice: vendorpricePrice,
        brandName: (categoryProduct["brand_name"]?.toString() ?? ''),
        vendorName: vendorName,
        msrp: (categoryProduct["msrp"]?.toString() ?? '0.00'),
        vendorIdCount: categoryProduct["vendorIdCount"] ?? 0,
        vendorpriceDate: vendorpriceDate,
        vendorUrl: vendorUrl,
        productMpn: (categoryProduct["product_mpn"]?.toString() ?? ''),
        productName: (categoryProduct["product_name"]?.toString() ?? ''),
        productImage: categoryProduct["product_image"]?.toString() ?? '',
        imageName: categoryProduct["image_name"]?.toString() ?? '',
        totalCount: categoryProduct["total_count"] ?? 0,
        lowestVendor: lowestVendorList,
      );
    } catch (e) {
      log('Error converting category product: $e');
      log('Product data: $categoryProduct');

      // Return a safe fallback product
      return VendorProduct(
        productId: 0,
        vendorpricePrice: '0.00',
        brandName: 'Unknown',
        vendorName: 'Unknown',
        msrp: '0.00',
        vendorIdCount: 0,
        vendorpriceDate: '',
        vendorUrl: '',
        productMpn: '',
        productName: 'Unknown Product',
        productImage: '',
        imageName: '',
        totalCount: 0,
        lowestVendor: null,
      );
    }
  }
}

/// Search API strategy
class SearchApiStrategy implements ProductListApiStrategy {
  final String searchQuery;

  SearchApiStrategy(this.searchQuery);

  @override
  Future<Map<String, dynamic>> fetchProducts({
    required int page,
    required BuildContext context,
  }) async {
    final products = await searchProducts(searchQuery, context);
    return {
      'products': products,
      'totalCount': products.length,
    };
  }

  @override
  Future<List<VendorProduct>> searchProducts(
    String query,
    BuildContext context,
  ) async {
    final searchData = await BrandsApi.fetchSearchProduct(context, query);

    if (searchData != null) {
      try {
        final List<dynamic> jsonList = searchData['brand_product'] ?? [];
        return jsonList.map((e) => VendorProduct.fromJson(e)).toList();
      } catch (e) {
        log('Error parsing search API response: $e');
        return [];
      }
    }
    return [];
  }

  @override
  Future<List<VendorProduct>> fetchFilteredProducts({
    required List<String> vendorCodes,
    required int page,
    required BuildContext context,
  }) async {
    // Search API doesn't support vendor filtering yet
    // Fall back to regular search
    return searchProducts(searchQuery, context);
  }
}
