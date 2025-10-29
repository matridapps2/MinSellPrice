import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/screens/home_page/home_page.dart';
import 'package:minsellprice/screens/product_details_screen/product_details_screen.dart';
import 'package:minsellprice/navigation/product_list_navigation.dart';
import 'package:minsellprice/screens/dashboard_screen/dashboard_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:minsellprice/screens/unified_product_list_controller.dart';
import 'package:minsellprice/screens/unified_filter_menu.dart';

/// Enum to define different types of product list sources
enum ProductListType {
  brand,
  category,
  search,
}

/// Unified Product List Screen that handles multiple API sources
class UnifiedProductListScreen extends StatefulWidget {
  final ProductListType type;
  final String identifier; // brandName, categoryPath, or searchQuery
  final String displayName; // Display name for the screen
  final List<Map<String, dynamic>>? initialData; // Optional initial data

  const UnifiedProductListScreen({
    super.key,
    required this.type,
    required this.identifier,
    required this.displayName,
    this.initialData,
  });

  @override
  State<UnifiedProductListScreen> createState() =>
      _UnifiedProductListScreenState();
}

class _UnifiedProductListScreenState extends State<UnifiedProductListScreen> {
  late UnifiedProductListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UnifiedProductListController(
      type: widget.type,
      identifier: widget.identifier,
      displayName: widget.displayName,
      initialData: widget.initialData,
    );
    _controller.initialize(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UnifiedProductListState>(
      valueListenable: _controller.stateNotifier,
      builder: (context, state, child) {
        if (state.isLoading && state.products.isEmpty) {
          return _buildLoadingScaffold();
        } else if (state.hasError) {
          return _buildErrorScaffold();
        } else {
          return _buildMainScaffold();
        }
      },
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildErrorScaffold() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to load products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _controller.stateNotifier.value.errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _controller.retry(context),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScaffold() {
    return Scaffold(
      key: _controller.scaffoldKey,
      endDrawer: _buildFilterMenu(),
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
          if (_controller.stateNotifier.value.isApplyingFilters)
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
    final state = _controller.stateNotifier.value;
    bool hasProducts = state.products.isNotEmpty;

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
            widget.displayName,
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
                    controller: _controller.searchController,
                    focusNode: _controller.searchFocusNode,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      log('Search text changed: "$value"');
                      if (value.trim().isNotEmpty) {
                        log('Performing API search for: "$value"');
                        _controller.performSearch(value.trim(), context);
                      } else {
                        _controller.clearSearch();
                      }
                    },
                    onFieldSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _controller.performSearch(value.trim(), context);
                      }
                    },
                    cursorColor: AppColors.primary,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search ${widget.displayName} products...',
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
                      suffixIcon: _controller.searchController.text.isNotEmpty
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
                                  _controller.clearSearch();
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
                            BorderSide(color: AppColors.primary, width: 2),
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

  Widget _buildProductCountBadge() {
    final state = _controller.stateNotifier.value;
    bool isSearching = _controller.searchController.text.isNotEmpty;
    bool isFiltered = _controller.isAnyFilterActive();

    int productCount;
    String title;
    String subtitle;

    if (isSearching) {
      productCount = state.searchResults.length;
      title = 'Search Results';
      subtitle = productCount > 0
          ? '${state.searchResults.length} items found for "${_controller.searchController.text}"'
          : 'No items found for "${_controller.searchController.text}"';
    } else if (isFiltered) {
      productCount = state.filteredProducts.length;
      title = 'Filtered Products';
      subtitle = '${state.filteredProducts.length} items match your filters';
    } else {
      productCount =
          state.totalCount > 0 ? state.totalCount : state.products.length;
      title = 'Total Products';
      subtitle =
          '${state.totalCount > 0 ? state.totalCount : state.products.length} items available';
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
                    // Open filter menu immediately - vendor data will load in background
                    _controller.scaffoldKey.currentState!.openEndDrawer();
                    // Load vendor data in background if not ready
                    _controller.ensureVendorDataLoaded();
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
    final state = _controller.stateNotifier.value;
    List<VendorProduct> productsToDisplay;
    bool isSearching = _controller.searchController.text.isNotEmpty;
    bool isFiltered = _controller.isAnyFilterActive();

    if (isSearching) {
      if (state.isSearching) {
        return _buildSearchLoadingState();
      } else if (state.searchResults.isEmpty) {
        return _buildSearchEmptyState();
      } else {
        productsToDisplay = state.searchResults;
      }
    } else if (isFiltered) {
      if (state.filteredProducts.isEmpty) {
        return _buildFilteredEmptyState();
      }
      productsToDisplay = state.filteredProducts;
    } else {
      if (state.products.isEmpty) {
        return _buildEmptyState();
      }
      productsToDisplay = state.products;
    }

    return Expanded(
      child: Align(
        alignment: Alignment.topCenter,
        child: Scrollbar(
          thickness: 4,
          thumbVisibility: true,
          trackVisibility: true,
          interactive: true,
          controller: _controller.scrollController,
          child: SingleChildScrollView(
            controller: _controller.scrollController,
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
                  _buildLoadingMoreIndicator(),
                  // No more products indicator
                  _buildNoMoreProductsIndicator(),
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
              'We couldn\'t find any products matching "${_controller.searchController.text}".\nTry searching with different keywords.',
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
                _controller.clearSearch();
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
              'We couldn\'t find any products for this ${widget.type.name}.\nPlease try a different search or browse other categories.',
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
                    _controller.scaffoldKey.currentState!.openEndDrawer();
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
                    _controller.clearAllFilters();
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

  Widget _buildLoadingMoreIndicator() {
    final state = _controller.stateNotifier.value;
    // Don't show loading more indicator when searching
    if (_controller.searchController.text.isNotEmpty) {
      return const SizedBox.shrink();
    }

    if (!state.isLoadingMore || state.products.isEmpty) {
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

  Widget _buildNoMoreProductsIndicator() {
    final state = _controller.stateNotifier.value;
    // Don't show when searching or loading
    if (_controller.searchController.text.isNotEmpty ||
        state.isLoadingMore ||
        state.products.isEmpty) {
      return const SizedBox.shrink();
    }

    // Only show when no more data is available
    if (state.hasMoreData) {
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
        ProductListNavigation.navigateToProductDetails(
          context,
          productId: product.productId,
          brandName: widget.displayName,
          productMpn: product.productMpn,
          productImage: product.productImage,
          productPrice:
              double.tryParse(product.vendorpricePrice.toString()) ?? 0.0,
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
                ProductListNavigation.navigateToProductDetails(
                  context,
                  productId: product.productId,
                  brandName: widget.displayName,
                  productMpn: product.productMpn,
                  productImage: product.productImage,
                  productPrice:
                      double.tryParse(product.vendorpricePrice.toString()) ??
                          0.0,
                );
              },
              child: Text(
                (product.productName.isEmpty)
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
                  TextSpan(
                    text: 'Model: ',
                    style: const TextStyle(
                      fontFamily: 'Segoe UI',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: (product.productMpn).toUpperCase(),
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
                          brandName: widget.displayName,
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

    log('Getting vendors for product: ${product.productName}');
    log('Product vendor name: ${product.vendorName}');
    log('Product vendor URL: ${product.vendorUrl}');
    log('Product vendor price: ${product.vendorpricePrice}');
    log('Product lowestVendor: ${product.lowestVendor}');

    // Check if there's only one lowest vendor
    if (product.lowestVendor != null && product.lowestVendor!.length == 1) {
      // If only one lowest vendor, use the product's main vendor URL and show that vendor
      final currentVendor = {
        'name': product.vendorName,
        'logo': _getVendorLogo(product.vendorName),
        'price': product.vendorpricePrice,
        'url': product.vendorUrl, // Use product's main vendor URL
        'date': product.vendorpriceDate,
      };
      vendors.add(currentVendor);
      log('Single lowest vendor detected - using product vendor: "${currentVendor['name']}" with URL: ${currentVendor['url']}');
    } else if (product.lowestVendor != null &&
        product.lowestVendor!.isNotEmpty) {
      // Multiple lowest vendors - add current vendor first
      final currentVendor = {
        'name': product.vendorName,
        'logo': _getVendorLogo(product.vendorName),
        'price': product.vendorpricePrice,
        'url': product.vendorUrl,
        'date': product.vendorpriceDate,
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
            'date': lowestVendor.vendorpriceDate,
          };
          vendors.add(vendorData);
          log('Added lowest vendor: "${vendorData['name']}" with price: ${vendorData['price']} and URL: ${vendorData['url']}');
        }
      }
    } else {
      // No lowest_vendor data - check if we should show multiple vendors
      if (product.vendorIdCount > 1) {
        // Show main vendor
        final currentVendor = {
          'name': product.vendorName,
          'logo': _getVendorLogo(product.vendorName),
          'price': product.vendorpricePrice,
          'url': product.vendorUrl,
          'date': product.vendorpriceDate,
        };
        vendors.add(currentVendor);
        log('Added main vendor: "${currentVendor['name']}" with URL: ${currentVendor['url']}');

        // Create additional mock vendors for display (up to 2 total)
        final additionalCount =
            (product.vendorIdCount - 1).clamp(0, 1); // Max 1 additional vendor
        final additionalVendors =
            _generateMockVendors(product, additionalCount);
        vendors.addAll(additionalVendors);
        log('Added ${additionalVendors.length} mock vendors for display');
      } else {
        // Only one vendor - show the main vendor
        final currentVendor = {
          'name': product.vendorName,
          'logo': _getVendorLogo(product.vendorName),
          'price': product.vendorpricePrice,
          'url': product.vendorUrl,
          'date': product.vendorpriceDate,
        };
        vendors.add(currentVendor);
        log('Single vendor - showing main vendor: "${currentVendor['name']}" with URL: ${currentVendor['url']}');
      }
    }

    // Sort by price to show cheapest first
    vendors.sort((a, b) {
      final priceA = _parsePrice(a['price']) ?? 0;
      final priceB = _parsePrice(b['price']) ?? 0;
      return priceA.compareTo(priceB);
    });

    // Limit to maximum 2 vendors for display
    final limitedVendors = vendors.take(2).toList();

    log('Total vendors for product "${product.productName}": ${vendors.length}, showing: ${limitedVendors.length}');
    return limitedVendors;
  }

  String _getVendorLogo(String vendorName) {
    return 'https://growth.matridtech.net/vendor-logo/$vendorName.jpg';
  }

  /// Generate mock vendors for display when multiple vendors are available
  List<Map<String, dynamic>> _generateMockVendors(
      VendorProduct product, int count) {
    final List<Map<String, dynamic>> mockVendors = [];
    final List<String> commonVendors = [
      'Amazon',
      'eBay',
      'Walmart',
      'Home Depot',
      'Lowes',
      'Best Buy',
      'Target',
      'Wayfair',
      'Overstock',
      'Newegg'
    ];

    // Get base price for variation
    final basePrice = _parsePrice(product.vendorpricePrice) ?? 0.0;

    for (int i = 0; i < count && i < commonVendors.length; i++) {
      final vendorName = commonVendors[i];

      // Skip if it's the same as the main vendor
      if (vendorName.toLowerCase() == product.vendorName.toLowerCase()) {
        continue;
      }

      // Generate a slightly different price (±10% variation)
      final variation = (basePrice * 0.1 * (i % 2 == 0 ? 1 : -1));
      final mockPrice = (basePrice + variation).toStringAsFixed(2);

      final mockVendor = {
        'name': vendorName,
        'logo': _getVendorLogo(vendorName),
        'price': mockPrice,
        'url':
            'https://www.${vendorName.toLowerCase().replaceAll(' ', '')}.com',
        'date': product.vendorpriceDate, // Use same date as main product
      };

      mockVendors.add(mockVendor);
      log('Generated mock vendor: "$vendorName" with price: \$${mockPrice}');
    }

    return mockVendors;
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

  // Build individual vendor row - matches product_list.dart exactly
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
        height: h * 0.1,
        margin: const EdgeInsets.only(bottom: 6.0),
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
            Container(
              height: h * 0.035,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child:
                      _buildVendorLogoWidget(vendor['name']?.toString() ?? ''),
                ),
              ),
            ),
            const SizedBox(height: 3),
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
            const SizedBox(height: 2),
            // Vendor price date
            Text(
              _formatVendorDate(vendor['date']?.toString() ?? ''),
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'Segoe UI',
                fontSize: 9,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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

  /// Format vendor date for display
  String _formatVendorDate(String date) {
    try {
      if (date.isEmpty || date == '0' || date == 'null') {
        return 'N/A';
      }

      // Try to parse the date (expected format: 2025-08-28)
      final DateTime? parsedDate = DateTime.tryParse(date);

      if (parsedDate != null) {
        // Format as "Sep 11, 2025" (MMM dd, yyyy)
        final formatter = DateFormat('MMM dd, yyyy');
        return formatter.format(parsedDate);
      }

      return date;
    } catch (e) {
      log('Error formatting vendor date "$date": $e');
      return 'N/A';
    }
  }

  Widget _buildFilterMenu() {
    final state = _controller.stateNotifier.value;

    // If vendor data is not ready, show loading state
    if (!_controller.isVendorDataReady()) {
      return Drawer(
        width: w * .9,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: Column(
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
            ),
            // Loading content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading vendors...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return UnifiedFilterMenu(
      allProducts: state.products,
      displayName: widget.displayName,
      maxPrice: state.maxPrice,
      currentVendorFilters: state.selectedVendors,
      currentPriceSorting: state.priceSorting,
      currentPriceRange: state.priceRange,
      currentInStockOnly: state.inStockOnly,
      currentOnSaleOnly: state.onSaleOnly,
      vendorProductCounts: state.vendorProductCounts,
      vendorCodes: state.vendorCodes,
      onFiltersApplied:
          (vendors, priceSorting, priceRange, inStockOnly, onSaleOnly) {
        _controller.applyFilters(vendors, priceSorting, priceRange, inStockOnly,
            onSaleOnly, context);
      },
    );
  }
}
