import 'dart:async';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/core/utils/toast_messages/common_toasts.dart';
import 'package:minsellprice/screens/categories_provider/categories_provider_file.dart';
import 'package:minsellprice/navigation/product_list_navigation.dart';
import 'package:minsellprice/screens/product_details_screen/product_details_screen.dart';
import 'package:minsellprice/screens/search_screen/unified_search_screen.dart';
import 'package:minsellprice/widgets/category_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/brand_image.dart';
import '../../widgets/product_list.dart';
import '../../model/product_list_model_new.dart';

class DashboardScreenWidget extends StatefulWidget {
  const DashboardScreenWidget({super.key});

  @override
  State<DashboardScreenWidget> createState() => _DashboardScreenWidgetState();
}

class _DashboardScreenWidgetState extends State<DashboardScreenWidget>
    with KeepAliveParentDataMixin {
  List<Map<String, dynamic>> databaseData = [];

  final _brandSearchController = TextEditingController();
  final _productSearchController = TextEditingController();

  final FocusNode _brandSearchFocusNode = FocusNode();
  final FocusNode _productSearchFocusNode = FocusNode();

  final _scrollController = ScrollController();

  /// Visibility states for expanded sections - dynamic based on category titles
  Map<String, bool> _expandedSections = {};

  /// Home slider products deals from API
  List<Map<String, dynamic>> _homeSliderDeals = [];
  bool _isHomeSliderDealsLoading = true;
  String? _homeSliderDealsError;

  /// Home box products deals from API
  List<Map<String, dynamic>> _homeBoxDeals = [];
  bool _isHomeBoxDealsLoading = true;
  String? _homeBoxDealsError;

  /// Price section spacing constant - used in all product card methods
  static const double _priceSectionSpacing = 12.0;

  @override
  void initState() {
    super.initState();
    // Unfocus search fields after widget tree is built
    // Execute callback after current frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _brandSearchFocusNode.unfocus();
      _productSearchFocusNode.unfocus();
    });
    // Initialize API calls
    _initCall();
  }

  // Initialize all API calls
  void _initCall() async {
    await _fetchHomeSliderProductsDeals();
    await _fetchHomeBoxProductsDeals();
  }

  /// Fetch home slider products deals from API
  Future<void> _fetchHomeSliderProductsDeals() async {
    try {
      setState(() {
        _isHomeSliderDealsLoading = true;
        _homeSliderDealsError = null;
      });

      final deals = await BrandsApi.fetchHomeSliderProductsDeals(context);

      if (mounted) {
        setState(() {
          _homeSliderDeals = deals;
          _isHomeSliderDealsLoading = false;
        });
        log('Home slider products deals loaded: ${_homeSliderDeals.length}');
      }
    } catch (e) {
      log('Error fetching home slider products deals: $e');
      if (mounted) {
        setState(() {
          _isHomeSliderDealsLoading = false;
          _homeSliderDealsError = 'Failed to load deals';
        });
      }
    }
  }

  /// Fetch home box products deals from API
  Future<void> _fetchHomeBoxProductsDeals() async {
    try {
      setState(() {
        _isHomeBoxDealsLoading = true;
        _homeBoxDealsError = null;
      });

      final deals = await BrandsApi.fetchHomeBoxProductsDeals(context);

      if (mounted) {
        setState(() {
          _homeBoxDeals = deals;
          _isHomeBoxDealsLoading = false;
        });
        log('Home box products deals loaded: ${_homeBoxDeals.length}');
      }
    } catch (e) {
      log('Error fetching home box products deals: $e');
      if (mounted) {
        setState(() {
          _isHomeBoxDealsLoading = false;
          _homeBoxDealsError = 'Failed to load deals';
        });
      }
    }
  }

  /// Check if Home Box Products section has data
  bool _hasHomeBoxProductsData() {
    if (_isHomeBoxDealsLoading) return false;
    return _homeBoxDeals.isNotEmpty;
  }

  /// Check if all APIs are loaded
  bool _areAllApisLoaded(BrandsProvider brandsProvider) {
    // Home slider deals API check
    if (_isHomeSliderDealsLoading) return false;

    // Home box deals API check
    if (_isHomeBoxDealsLoading) return false;

    // Brands API check (loading or initial state)
    if (brandsProvider.state == BrandsState.loading ||
        brandsProvider.state == BrandsState.initial) {
      return false;
    }

    return true; // All APIs loaded
  }

  /// Navigate to product details from product data
  void _navigateToProductDetailsFromData(Map<String, dynamic> product) {
    final productId = product['product_id'] ?? 0;
    final brandName = product['brand_name']?.toString() ?? '';
    final productMpn = product['product_mpn']?.toString() ?? '';
    final productImage = product['product_image']?.toString() ?? '';
    final firstVendorPrice = product['firstVendorPrice']?.toString() ?? '0.00';
    final price = double.tryParse(firstVendorPrice) ?? 0.0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          productId: productId,
          brandName: brandName,
          productMPN: productMpn,
          productImage: productImage,
          productPrice: price,
        ),
      ),
    );
  }

  /// Navigate to product details from VendorProduct
  void _navigateToProductDetailsFromVendorProduct(VendorProduct product) {
    final price = double.tryParse(product.firstVendorPrice.toString()) ?? 0.0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          productId: product.productId,
          brandName: product.brandName,
          productMPN: product.productMpn,
          productImage: product.productImage,
          productPrice: price,
        ),
      ),
    );
  }

  /// Convert List<Map<String, dynamic>> to List<VendorProduct>
  /// Uses the VendorProduct.fromJson factory method from the model class
  List<VendorProduct> _convertMapToVendorProducts(
      List<Map<String, dynamic>> products) {
    return products
        .map((productMap) => VendorProduct.fromJson(productMap))
        .toList();
  }

  @override
  void dispose() {
    _brandSearchController.dispose();
    _productSearchController.dispose();
    _brandSearchFocusNode.dispose();
    _productSearchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to BrandsProvider for state changes
    return Consumer<BrandsProvider>(
      builder: (context, brandsProvider, child) {
        // Show shimmer while APIs are loading
        if (!_areAllApisLoaded(brandsProvider)) {
          return const DashboardFullShimmer();
        }

        // Show actual dashboard content when all APIs loaded
        return Container(
          color: const Color.fromARGB(255, 245, 245, 245),
          width: w,
          child: Column(
            children: [
              /// TEXT FIELD CONTROLLER
              Container(
                padding: const EdgeInsets.only(top: 1, bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.grey[50]!],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Enhanced Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _productSearchController,
                          focusNode: _productSearchFocusNode,
                          textInputAction: TextInputAction.search,
                          cursorColor: AppColors.primary,
                          onTap: () {
                            _productSearchFocusNode.unfocus();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UnifiedSearchScreen(
                                  initialSearchType: SearchType.product,
                                ),
                              ),
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: w * .035,
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.search,
                                color: AppColors.primary,
                                size: w * .06,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 1, bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.grey[50]!],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Enhanced Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _brandSearchController,
                          focusNode: _brandSearchFocusNode,
                          textInputAction: TextInputAction.search,
                          cursorColor: AppColors.primary,
                          onTap: () {
                            _brandSearchFocusNode.unfocus();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UnifiedSearchScreen(
                                  initialSearchType: SearchType.brand,
                                ),
                              ),
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Search brands...',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: w * .035,
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.search,
                                color: AppColors.primary,
                                size: w * .06,
                              ),
                            ),
                            // suffixIcon: Container(
                            //   margin: const EdgeInsets.all(8),
                            //   child: Icon(
                            //     Icons.mic,
                            //     color: Colors.grey[600],
                            //     size: w * .06,
                            //   ),
                            // ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// ALL BRANDS AND PRODUCT SLIDER
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thickness: 4,
                  thumbVisibility: true,
                  trackVisibility: true,
                  interactive: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const SizedBox(height: 20),

                        // Dynamic Slider Sections - iterate through API data
                        if (_isHomeSliderDealsLoading)
                          ...List.generate(
                              3, (index) => const ProductSectionShimmer())
                        else
                          ..._homeSliderDeals.asMap().entries.map((entry) {
                            final index = entry.key;
                            final deal = entry.value;
                            return Column(
                              children: [
                                _buildDynamicSliderSection(deal),
                                if (index < _homeSliderDeals.length - 1)
                                  const SizedBox(height: 25),
                              ],
                            );
                          }).toList(),

                        const SizedBox(height: 25),
                        // Home Box Products Deals Section
                        _buildHomeBoxProductsDealsSection(),
                        if (_hasHomeBoxProductsData())
                          const SizedBox(height: 25),

                        _buildBrandsSections(brandsProvider),
                        const SizedBox(height: 45),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build API Product Card (for products from API)
  Widget _buildApiProductCard(Map<String, dynamic> product) {
    final brand = product['brand_name']?.toString() ?? '';
    final model = product['product_mpn']?.toString() ?? '';
    final name = product['product_name']?.toString() ?? '';
    final image = product['product_image']?.toString() ?? '';
    final msrp = double.tryParse(product['msrp']?.toString() ?? '0') ?? 0.0;
    final firstVendorPrice =
        double.tryParse(product['firstVendorPrice']?.toString() ?? '0') ?? 0.0;
    final discountPercent =
        double.tryParse(product['discount_percent']?.toString() ?? '0') ?? 0.0;

    // Hide MSRP and discount when discount is 0% (or effectively 0%)
    // Use epsilon for floating point comparison
    const double discountEpsilon =
        0.1; // 0.1% discount threshold - hide if discount is less than 0.1%

    final discountIsZero = discountPercent.abs() < discountEpsilon;

    // Hide if discount is 0% or effectively 0%
    final shouldShowMsrpAndDiscount = !discountIsZero;

    return GestureDetector(
      onTap: () => _navigateToProductDetailsFromData(product),
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 180,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: image.isEmpty || image.contains('no_image')
                    ? Container(
                        color: Colors.grey[100],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No image available',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: _getProperImageUrl(image),
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[50],
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[100],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No image available',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),

            // Brand Logo
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8, bottom: 4),
              child: SizedBox(
                height: 60,
                width: 90,
                child: BrandImageWidget(
                  brand: {
                    'brand_name': brand,
                    'brand_key': product['brand_key']?.toString() ?? brand,
                    'brand_id': product['brand_id'] ?? 0,
                  },
                  width: 80,
                  height: 40,
                ),
              ),
            ),

            const SizedBox(height: 10),
            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Model Number
                    if (model.isNotEmpty)
                      Text(
                        model,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (model.isNotEmpty) const SizedBox(height: 6),

                    // Product Name
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontFamily: 'Segoe UI',
                        // fontWeight: Segoe UI,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: _priceSectionSpacing),

                    // Price Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Current Price (discounted) - on the left
                        Text(
                          '\$${_formatPrice(firstVendorPrice.toString())}',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Original Price (strikethrough) - on the right, only show if discounted and not same as current price
                        if (discountPercent > 0 &&
                            msrp > 0 &&
                            shouldShowMsrpAndDiscount)
                          Text(
                            '\$${_formatPrice(msrp.toString())}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    // Discount Badge - only show if there's a discount and not same as MSRP
                    if (discountPercent > 0 && shouldShowMsrpAndDiscount) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(4),
                          border:
                              Border.all(color: Colors.green[200]!, width: 1),
                        ),
                        child: Text(
                          '${discountPercent.toStringAsFixed(0)}% OFF',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Expanded API Product Grid View
  Widget _buildExpandedApiProductGrid(List<Map<String, dynamic>> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.47,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildApiProductCardGrid(product);
      },
    );
  }

  /// Build API Product Card for Grid View
  Widget _buildApiProductCardGrid(Map<String, dynamic> product) {
    final brand = product['brand_name']?.toString() ?? '';
    final model = product['product_mpn']?.toString() ?? '';
    final name = product['product_name']?.toString() ?? '';
    final image = product['product_image']?.toString() ?? '';
    final msrp = double.tryParse(product['msrp']?.toString() ?? '0') ?? 0.0;
    final firstVendorPrice =
        double.tryParse(product['firstVendorPrice']?.toString() ?? '0') ?? 0.0;
    final discountPercent =
        double.tryParse(product['discount_percent']?.toString() ?? '0') ?? 0.0;

    // Hide MSRP and discount when discount is 0% (or effectively 0%)
    // Use epsilon for floating point comparison
    const double discountEpsilon =
        0.1; // 0.1% discount threshold - hide if discount is less than 0.1%

    final discountIsZero = discountPercent.abs() < discountEpsilon;

    // Hide if discount is 0% or effectively 0%
    final shouldShowMsrpAndDiscount = !discountIsZero;

    return GestureDetector(
      onTap: () => _navigateToProductDetailsFromData(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 120,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: image.isEmpty || image.contains('no_image')
                    ? Container(
                        color: Colors.grey[100],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No image',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: _getProperImageUrl(image),
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[50],
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[100],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No image',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),

            // Brand Logo
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4, bottom: 2),
              child: SizedBox(
                height: 60,
                width: 90,
                child: BrandImageWidget(
                  brand: {
                    'brand_name': brand,
                    'brand_key': product['brand_key']?.toString() ?? brand,
                    'brand_id': product['brand_id'] ?? 0,
                  },
                  width: 70,
                  height: 30,
                ),
              ),
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Model Number
                    if (model.isNotEmpty)
                      Text(
                        model,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (model.isNotEmpty) const SizedBox(height: 2),

                    // Product Name - Constrained to show 2 lines completely
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(height: _priceSectionSpacing),

                    // Price Section - Fixed at bottom
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Current Price (discounted) - on the left
                        Flexible(
                          child: Text(
                            '\$${_formatPrice(firstVendorPrice.toString())}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Original Price (strikethrough) - on the right, only show if discounted and not same as current price
                        if (discountPercent > 0 &&
                            msrp > 0 &&
                            shouldShowMsrpAndDiscount)
                          Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: Text(
                              '\$${_formatPrice(msrp.toString())}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                      ],
                    ),
                    // Discount Badge - only show if there's a discount and not same as MSRP
                    if (discountPercent > 0 && shouldShowMsrpAndDiscount) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green[50], // 232 245 233 100
                          borderRadius: BorderRadius.circular(4),
                          border:
                              Border.all(color: Colors.green[200]!, width: 1),
                        ),
                        child: Text(
                          // 165 214 167 100
                          '${discountPercent.toStringAsFixed(0)}% OFF',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Generic Dynamic Section Builder - uses HomePageCategoryTitle from API
  Widget _buildDynamicSliderSection(Map<String, dynamic> deal) {
    // Get category title and products directly from API deal
    final categoryTitle = deal['HomePageCategoryTitle']?.toString() ?? '';
    final productData = deal['product_data'] as List<dynamic>? ?? [];
    final products =
        productData.map((product) => product as Map<String, dynamic>).toList();

    // Show shimmer when loading
    if (_isHomeSliderDealsLoading) {
      return const ProductSectionShimmer();
    }

    // Hide section when no products or when no category title
    if (products.isEmpty || categoryTitle.isEmpty) {
      return const SizedBox.shrink();
    }

    // Initialize expanded state for this category if not exists
    if (!_expandedSections.containsKey(categoryTitle)) {
      _expandedSections[categoryTitle] = false;
    }

    final isExpanded = _expandedSections[categoryTitle] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        categoryTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black12,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedSections[categoryTitle] = !isExpanded;
                  });
                },
                child: Text(
                  isExpanded ? 'Show Less' : 'View All Deals',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Products - Show horizontal scroll or grid based on visibility
          if (!isExpanded)
            SizedBox(
              height: 410,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildApiProductCard(product);
                },
              ),
            )
          else
            ProductListWidget(
              products: _convertMapToVendorProducts(products),
              onProductTap: (product) {
                _navigateToProductDetailsFromVendorProduct(product);
              },
            ),
        ],
      ),
    );
  }

  /// Home Box Products Deals Section Widget
  Widget _buildHomeBoxProductsDealsSection() {
    // Show shimmer when loading
    if (_isHomeBoxDealsLoading) {
      return Column(
        children: List.generate(2, (index) {
          return Column(
            children: [
              const HomeBoxDealsGridShimmer(),
              if (index < 1) const SizedBox(height: 25),
            ],
          );
        }),
      );
    }

    // Hide section when no deals
    if (_homeBoxDeals.isEmpty) {
      return const SizedBox.shrink();
    }

    // Display all home box deals sections
    return Column(
      children: _homeBoxDeals.asMap().entries.map((entry) {
        final index = entry.key;
        final deal = entry.value;
        final categoryTitle = deal['HomePageCategoryTitle']?.toString() ?? '';
        final productData = deal['product_data'] as List<dynamic>? ?? [];
        final sectionRoute = deal['SectionRoute']?.toString() ?? '';
        final viewAllCategoryId = deal['ViewAllPageCategoryID'] ?? 0;

        // Convert product data to List<Map<String, dynamic>>
        final products = productData
            .map((product) => product as Map<String, dynamic>)
            .toList();

        // Skip if no products or no title
        if (products.isEmpty || categoryTitle.isEmpty) {
          return const SizedBox.shrink();
        }

        // Show first 4 products in 2x2 grid
        final displayProducts = products.take(4).toList();

        return Column(
          children: [
            _buildHomeBoxDealSection(
              categoryTitle: categoryTitle,
              products: displayProducts,
              sectionRoute: sectionRoute,
              viewAllCategoryId: viewAllCategoryId,
              totalProducts: products.length,
            ),
            if (index < _homeBoxDeals.length - 1) const SizedBox(height: 25),
          ],
        );
      }).toList(),
    );
  }

  /// Build individual home box deal section
  Widget _buildHomeBoxDealSection({
    required String categoryTitle,
    required List<Map<String, dynamic>> products,
    required String sectionRoute,
    required int viewAllCategoryId,
    required int totalProducts,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        categoryTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black12,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Products Grid (2x2)
          // GridView.builder(
          //   padding: const EdgeInsets.only(bottom: 20),
          //   shrinkWrap: true,
          //   physics: const NeverScrollableScrollPhysics(),
          //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: 2,
          //     mainAxisSpacing: 16,
          //     crossAxisSpacing: 16,
          //     childAspectRatio: 0.56,
          //   ),
          //   itemCount: products.length,
          //   itemBuilder: (context, index) {
          //     final product = products[index];
          //     return
          //   },
          // ),

          ProductListWidget(
            products: _convertMapToVendorProducts(products),
            onProductTap: (product) {
              _navigateToProductDetailsFromVendorProduct(product);
            },
          ),

          // View All Deals Link
          const SizedBox(height: 0),
          Center(
            child: GestureDetector(
              onTap: () {
                // Navigate to view all products page using section route
                if (sectionRoute.isNotEmpty) {
                  ProductListNavigation.navigateToCategoryProducts(
                    context,
                    categoryPath: sectionRoute,
                    categoryName: categoryTitle,
                  );
                } else {
                  log('View All Deals tapped for: $categoryTitle - No route available');
                }
              },
              child: const Text(
                'View All Deals',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Home Box Product Card (2x2 grid style)
  Widget _buildHomeBoxProductCard(Map<String, dynamic> product) {
    log('HomeBox Product Keys: ${product.keys.toList()}');
    log('HomeBox Product Data: $product');

    final brand = product['brand_name']?.toString() ?? '';
    final model = product['product_mpn']?.toString() ?? '';
    final name = product['product_name']?.toString() ?? '';

    // Try multiple possible field names for image
    final image = (product['product_image']?.toString() ??
            product['image']?.toString() ??
            product['productImage']?.toString() ??
            '')
        .trim();

    final msrp = double.tryParse(product['msrp']?.toString() ?? '0') ?? 0.0;
    final firstVendorPrice =
        double.tryParse(product['firstVendorPrice']?.toString() ?? '0') ?? 0.0;
    final discountPercent =
        double.tryParse(product['discount_percent']?.toString() ?? '0') ?? 0.0;

    // Hide MSRP and discount when discount is 0% (or effectively 0%)
    // Use epsilon for floating point comparison
    const double discountEpsilon =
        0.1; // 0.1% discount threshold - hide if discount is less than 0.1%

    final discountIsZero = discountPercent.abs() < discountEpsilon;

    // Hide if discount is 0% or effectively 0%
    final shouldShowMsrpAndDiscount = !discountIsZero;

    // Debug: Log image URL for troubleshooting
    log('HomeBox Product - Image field value: $image');
    log('HomeBox Product - Image isEmpty: ${image.isEmpty}');
    log('HomeBox Product - Image contains no_image: ${image.contains('no_image')}');
    if (image.isNotEmpty && !image.contains('no_image')) {
      log('HomeBox Product Image URL: $image');
      log('Processed Image URL: ${_getProperImageUrl(image)}');
    }

    return GestureDetector(
      onTap: () => _navigateToProductDetailsFromData(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image
            Container(
              height: 120,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: image.isEmpty ||
                        image.contains('no_image') ||
                        image.toLowerCase() == 'null'
                    ? Container(
                        color: Colors.grey[100],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No image',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          final processedUrl = _getProperImageUrl(image);
                          log('Attempting to load image from: $processedUrl');

                          return CachedNetworkImage(
                            imageUrl: processedUrl,
                            fit: BoxFit.contain,
                            httpHeaders: const {
                              'Accept': 'image/*',
                            },
                            placeholder: (context, url) {
                              log('Loading placeholder for: $url');
                              return Container(
                                color: Colors.grey[50],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorWidget: (context, url, error) {
                              // Log detailed error for debugging
                              log('Image load error for URL: $url');
                              log('Error type: ${error.runtimeType}');
                              log('Error details: $error');
                              log('Original image value: $image');

                              // Try to show the original URL if processed one fails
                              if (url != image && image.isNotEmpty) {
                                log('Retrying with original URL: $image');
                                return CachedNetworkImage(
                                  imageUrl: image,
                                  fit: BoxFit.contain,
                                  errorWidget: (context, url2, error2) {
                                    log('Original URL also failed: $url2, Error: $error2');
                                    return Container(
                                      color: Colors.grey[100],
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 40,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'No image',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }

                              return Container(
                                color: Colors.grey[100],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'No image',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),

            // Brand Logo
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4, bottom: 2),
              child: SizedBox(
                height: 28,
                width: 65,
                child: BrandImageWidget(
                  brand: {
                    'brand_name': brand,
                    'brand_key': product['brand_key']?.toString() ?? brand,
                    'brand_id': product['brand_id'] ?? 0,
                  },
                  width: 65,
                  height: 28,
                ),
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Model Number
                  if (model.isNotEmpty) ...[
                    Text(
                      model,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                  ],

                  // Product Name
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: _priceSectionSpacing),

                  // Price Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Current Price (discounted) - on the left
                      Text(
                        '\$${_formatPrice(firstVendorPrice.toString())}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Original Price (strikethrough) - on the right, only show if discounted and not same as current price
                      if (discountPercent > 0 &&
                          msrp > 0 &&
                          shouldShowMsrpAndDiscount)
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Text(
                            '\$${_formatPrice(msrp.toString())}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Discount Badge - only show if there's a discount and not same as MSRP
                  if (discountPercent > 0 && shouldShowMsrpAndDiscount) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green[200]!, width: 1),
                      ),
                      child: Text(
                        '${discountPercent.toStringAsFixed(0)}% OFF',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Open vendor website
  void _openVendorWebsite(Map<String, dynamic> vendor) async {
    final vendorUrl = vendor['url']?.toString() ?? '';
    final vendorName = vendor['name']?.toString() ?? '';

    log('Opening vendor website for: $vendorName');
    log('Vendor URL: $vendorUrl');

    if (vendorUrl.isNotEmpty && vendorUrl != 'https://example.com') {
      try {
        final Uri url = Uri.parse(vendorUrl);

        // Check if we can launch the URL
        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication, // Opens in external browser
          );
          log('Successfully opened vendor website: $vendorUrl');
        } else {
          throw 'Could not launch $vendorUrl';
        }
      } catch (e) {
        log('Error opening vendor URL: $e');
        // Show error message to user
        if (mounted) {
          CommonToasts.centeredMobile(
              msg: 'Unable to open $vendorName website', context: context);

          /*ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to open $vendorName website'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );*/
        }
      }
    } else {
      log('Invalid or empty vendor URL for: $vendorName');
      // Show message for invalid URL
      if (mounted) {
        CommonToasts.centeredMobile(
            msg: 'No website available for $vendorName', context: context);

        /* ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No website available for $vendorName'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );*/
      }
    }
  }

  /// Get proper image URL
  String _getProperImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'https://www.minsellprice.com/assets/no_image/no_image.jpg';
    }

    // Trim whitespace
    String trimmedUrl = imageUrl.trim();

    // Check for null string
    if (trimmedUrl.toLowerCase() == 'null' || trimmedUrl.isEmpty) {
      return 'https://www.minsellprice.com/assets/no_image/no_image.jpg';
    }

    if (trimmedUrl.startsWith('//')) {
      return 'https:$trimmedUrl';
    }

    if (!trimmedUrl.startsWith('http://') &&
        !trimmedUrl.startsWith('https://')) {
      return 'https://$trimmedUrl';
    }

    return trimmedUrl;
  }

  /// Format price with 2 decimal places (no comma separators)
  String _formatPrice(String price) {
    try {
      final double? priceValue =
          double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), ''));

      if (priceValue == null) {
        return price;
      }

      // Format with 2 decimal places, no comma separators (e.g., 14.00, 4544.00)
      return priceValue.toStringAsFixed(2);
    } catch (e) {
      return price;
    }
  }

  Widget _buildBrandsSections(BrandsProvider brandsProvider) {
    log('_buildBrandsSections called with state: ${brandsProvider.state}');
    log('Brands count: ${brandsProvider.homeGardenBrands.length}');
    log('Shoes & Apparels count: ${brandsProvider.shoesApparels.length}');

    if (brandsProvider.state == BrandsState.loading ||
        brandsProvider.state == BrandsState.initial) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerDesign(isDone: false),
          SizedBox(height: 25),
          ShimmerDesign(isDone: false),
        ],
      );
    } else if (brandsProvider.state == BrandsState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to load brands',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              brandsProvider.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => brandsProvider.retry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brands Section
          Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Brands',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${brandsProvider.homeGardenBrands.length} brands available',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _brandsGrid(brandsProvider.homeGardenBrands),
          //    const SizedBox(height: 30),
          // Shoes & Apparels Section
          //     if(brandsProvider.shoesApparels.isNotEmpty)
          Visibility(
            visible: brandsProvider.shoesApparels.isNotEmpty,
            child: Container(
              margin: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Shoes & Apparels',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${brandsProvider.shoesApparels.length} brands available',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Visibility(
              visible: brandsProvider.shoesApparels.isNotEmpty,
              child: _brandsGrid(brandsProvider.shoesApparels)),
        ],
      );
    }
  }

  Widget _brandsGrid(List<Map<String, dynamic>> brands) {
    if (brands.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No brands available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Brands will appear here once loaded',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85, // Slightly taller for better logo display
        ),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final brand = brands[index];
          return GestureDetector(
            onTap: () {
              ProductListNavigation.navigateToBrandProducts(
                context,
                brandId: brand['brand_id'].toString(),
                brandName: brand['brand_name'],
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BrandImageWidget(
                              brand: brand,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  brand['brand_name'].toString().trim(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Segoe UI',
                                    letterSpacing: 0.3,
                                  ),
                                  // maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  @override
  void detach() {
    // TODO: implement detach
  }

  @override
  // TODO: implement keptAlive
  bool get keptAlive => true;
}
