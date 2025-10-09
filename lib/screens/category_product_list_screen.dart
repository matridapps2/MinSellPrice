import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:minsellprice/services/category_service.dart';
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/screens/product_details_screen/product_details_screen.dart';

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
  List<VendorProduct> _products = [];
  bool _hasUserScrolled = false;

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
    super.dispose();
  }

  void _convertProductData() {
    _products = widget.productData
        .map((product) => VendorProduct.fromJson(product))
        .toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
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
    );
  }

  Widget _buildProductCountBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Product Count Badge
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
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
                          'Total Products',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: w * .045,
                            fontFamily: 'Segoe UI',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${_products.length} items available',
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
    );
  }

  Widget _buildProductList() {
    if (_products.isEmpty) {
      return _buildEmptyState();
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
                      _products.length,
                      (index) => _buildProductCard(_products[index]),
                    ),
                  ),
                  // Loading more indicator
                  if (widget.isLoadingMore)
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
                  if (!widget.hasMoreData && _products.isNotEmpty)
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
    // Check if MSRP is null or empty
    bool hasMsrp =
        product.msrp != null && product.msrp != '--' && product.msrp.isNotEmpty;

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
