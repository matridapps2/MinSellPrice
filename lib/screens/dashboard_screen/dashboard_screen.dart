import 'dart:async';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/core/utils/toast_messages/common_toasts.dart';
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/screens/categories_provider/categories_provider_file.dart';
import 'package:minsellprice/screens/category_subcategories_screen.dart';
import 'package:minsellprice/navigation/product_list_navigation.dart';
import 'package:minsellprice/screens/product_details_screen/product_details_screen.dart';
import 'package:minsellprice/screens/search_screen/brand_search_screen.dart';
import 'package:minsellprice/screens/search_screen/product_search_screen.dart';
import 'package:minsellprice/widgets/category_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Top categories from API
  List<Map<String, dynamic>> _topCategories = [];
  bool _isCategoriesLoading = true;
  String? _categoriesError;

  // Verified products from API
  List<VendorProduct> _verifiedProducts = [];
  bool _isVerifiedProductsLoading = true;
  String? _verifiedProductsError;

  // Visibility states for expanded sections
  bool _showAllKitchenDeals = false;
  bool _showAllOutdoorDeals = false;
  bool _showAllFaucetDeals = false;
  bool _showAllSinkDeals = false;

  // Home slider products deals from API
  List<Map<String, dynamic>> _homeSliderDeals = [];
  bool _isHomeSliderDealsLoading = true;
  String? _homeSliderDealsError;

  // Home box products deals from API
  List<Map<String, dynamic>> _homeBoxDeals = [];
  bool _isHomeBoxDealsLoading = true;
  String? _homeBoxDealsError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _brandSearchFocusNode.unfocus();
      _productSearchFocusNode.unfocus();
    });
    _initCall();
  }

  void _initCall() async {
    await _fetchTopCategories();
    await _fetchVerifiedProducts();
    await _fetchHomeSliderProductsDeals();
    await _fetchHomeBoxProductsDeals();
  }

  /// Fetch top categories from API
  Future<void> _fetchTopCategories() async {
    try {
      setState(() {
        _isCategoriesLoading = true;
        _categoriesError = null;
      });

      final categories = await BrandsApi.fetchTopCategories(context);

      if (mounted) {
        setState(() {
          _topCategories = categories;
          _isCategoriesLoading = false;
        });
        log('Top categories loaded: ${_topCategories.length}');
      }
    } catch (e) {
      log('Error fetching top categories: $e');
      if (mounted) {
        setState(() {
          _isCategoriesLoading = false;
          _categoriesError = 'Failed to load categories';
        });
      }
    }
  }

  /// Fetch verified products from API
  Future<void> _fetchVerifiedProducts() async {
    try {
      setState(() {
        _isVerifiedProductsLoading = true;
        _verifiedProductsError = null;
      });

      final verifiedProductsData =
          await BrandsApi.fetchVerifiedProducts(context);

      if (mounted) {
        // Convert to VendorProduct objects
        final List<VendorProduct> products =
            verifiedProductsData.map((productData) {
          // Convert lowest_vendor array
          List<LowestVendor>? lowestVendors;
          if (productData['lowest_vendor'] != null) {
            lowestVendors = (productData['lowest_vendor'] as List)
                .map((vendor) => LowestVendor.fromJson(vendor))
                .toList();
          }

          return VendorProduct(
            productId: productData['product_id'] ?? 0,
            vendorpricePrice:
                productData['vendorprice_price']?.toString() ?? '0.00',
            brandName: productData['brand_name']?.toString() ?? '',
            vendorName: productData['vendor_name']?.toString() ?? '',
            msrp: productData['msrp']?.toString() ?? '0.00',
            vendorIdCount: 1,
            // Default since API doesn't provide this
            vendorpriceDate: '',
            // API doesn't provide main vendor date
            vendorUrl: productData['vendor_url']?.toString() ?? '',
            productMpn: productData['product_mpn']?.toString() ?? '',
            productName: productData['product_name']?.toString() ?? '',
            productImage: productData['product_image']?.toString() ?? '',
            imageName: '',
            // API doesn't provide this
            totalCount: 0,
            // API doesn't provide this
            lowestVendor: lowestVendors,
          );
        }).toList();

        setState(() {
          _verifiedProducts = products;
          _isVerifiedProductsLoading = false;
        });
        log('Verified products loaded: ${_verifiedProducts.length}');
      }
    } catch (e) {
      log('Error fetching verified products: $e');
      if (mounted) {
        setState(() {
          _isVerifiedProductsLoading = false;
          _verifiedProductsError = 'Failed to load verified products';
        });
      }
    }
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

  /// Get products for a specific category from home slider deals
  List<Map<String, dynamic>> _getProductsForCategory(String categoryTitle) {
    if (_homeSliderDeals.isEmpty) {
      log('Home slider deals is empty');
      return [];
    }

    // Log all available categories for debugging
    log('🔍 Searching for category: $categoryTitle');
    log('📋 Available categories:');
    for (var deal in _homeSliderDeals) {
      final title = deal['HomePageCategoryTitle']?.toString() ?? '';
      final route = deal['SectionRoute']?.toString() ?? '';
      log('  - Title: "$title" | Route: "$route"');
    }

    // Map of search terms to possible category title variations
    final categoryMapping = {
      'Ranges, Cooktops, Microwaves': [
        'ranges',
        'cooktops',
        'microwaves',
        'range',
        'cooktop',
        'microwave',
      ],
      'Outdoor Kitchen': [
        'outdoor',
        'kitchen',
        'grill',
        'outdoor kitchen',
        'outdoor kitchen deals',
      ],
      'Kitchen Faucet': [
        'faucet',
        'kitchen faucet',
        'faucets',
        'kitchen faucets',
      ],
      'Kitchen Sinks': [
        'sink',
        'sinks',
        'kitchen sink',
        'kitchen sinks',
      ],
    };

    // Get search terms for the category
    final searchTerms = categoryMapping[categoryTitle] ??
        categoryTitle
            .toLowerCase()
            .split(' ')
            .where((t) => t.length > 2)
            .toList();
    final searchPattern = categoryTitle.toLowerCase();

    for (var deal in _homeSliderDeals) {
      final title = deal['HomePageCategoryTitle']?.toString() ?? '';
      final route = deal['SectionRoute']?.toString() ?? '';
      final titleLower = title.toLowerCase();
      final routeLower = route.toLowerCase();

      // Try exact match in title
      if (titleLower.contains(searchPattern)) {
        log('✅ Found exact category match: "$title" for search: "$categoryTitle"');
        final productData = deal['product_data'] as List<dynamic>? ?? [];
        log('📦 Found ${productData.length} products for category: $title');
        return productData
            .map((product) => product as Map<String, dynamic>)
            .toList();
      }

      // Try matching with route
      if (routeLower.contains(searchPattern) ||
          searchPattern.contains(routeLower)) {
        log('✅ Found route match: "$route" for search: "$categoryTitle"');
        final productData = deal['product_data'] as List<dynamic>? ?? [];
        log('📦 Found ${productData.length} products for category: $title');
        return productData
            .map((product) => product as Map<String, dynamic>)
            .toList();
      }

      // Try matching with search terms
      bool matches = false;
      for (var term in searchTerms) {
        if (titleLower.contains(term) || routeLower.contains(term)) {
          matches = true;
          break;
        }
      }

      if (matches) {
        log('✅ Found category match: "$title" (route: "$route") for search: "$categoryTitle"');
        final productData = deal['product_data'] as List<dynamic>? ?? [];
        log('📦 Found ${productData.length} products for category: $title');
        return productData
            .map((product) => product as Map<String, dynamic>)
            .toList();
      }
    }

    log('⚠️ No category match found for: "$categoryTitle"');
    return [];
  }

  /// Get category title for a specific category
  String? _getCategoryTitle(String categoryTitle) {
    if (_homeSliderDeals.isEmpty) return null;

    // Map of search terms to possible category title variations
    final categoryMapping = {
      'Ranges, Cooktops, Microwaves': [
        'ranges',
        'cooktops',
        'microwaves',
        'range',
        'cooktop',
        'microwave',
      ],
      'Outdoor Kitchen': [
        'outdoor',
        'kitchen',
        'grill',
        'outdoor kitchen',
        'outdoor kitchen deals',
      ],
      'Kitchen Faucet': [
        'faucet',
        'kitchen faucet',
        'faucets',
        'kitchen faucets',
      ],
      'Kitchen Sinks': [
        'sink',
        'sinks',
        'kitchen sink',
        'kitchen sinks',
      ],
    };

    // Get search terms for the category
    final searchTerms = categoryMapping[categoryTitle] ??
        categoryTitle
            .toLowerCase()
            .split(' ')
            .where((t) => t.length > 2)
            .toList();
    final searchPattern = categoryTitle.toLowerCase();

    for (var deal in _homeSliderDeals) {
      final title = deal['HomePageCategoryTitle']?.toString() ?? '';
      final route = deal['SectionRoute']?.toString() ?? '';
      final titleLower = title.toLowerCase();
      final routeLower = route.toLowerCase();

      // Try exact match in title
      if (titleLower.contains(searchPattern)) {
        return title;
      }

      // Try matching with route
      if (routeLower.contains(searchPattern) ||
          searchPattern.contains(routeLower)) {
        return title;
      }

      // Try matching with search terms
      bool matches = false;
      for (var term in searchTerms) {
        if (titleLower.contains(term) || routeLower.contains(term)) {
          matches = true;
          break;
        }
      }

      if (matches) {
        return title;
      }
    }
    return null;
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
                            builder: (context) => const ProductSearchScreen(),
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

          // WorkManager Status Widget
          // const WorkManagerStatusWidget(),

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
                            builder: (context) => const BrandSearchScreen(),
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

          /// ALL BRANDS
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
                    const SizedBox(height: 15),

                    // Top Categories Slider
                    /*   _buildCategoriesSlider(),
                    const SizedBox(height: 25),*/

                    // Kitchen Appliances Horizontal Section
                    _buildKitchenAppliancesSection(),
                    const SizedBox(height: 25),

                    // Outdoor Kitchen Deals Horizontal Section
                    _buildOutdoorKitchenSection(),
                    const SizedBox(height: 25),

                    // Kitchen Faucet Deals Section
                    _buildKitchenFaucetDealsSection(),
                    const SizedBox(height: 25),

                    // Kitchen Sinks Sale Section
                    _buildKitchenSinksSaleSection(),
                    const SizedBox(height: 25),

                    // Home Box Products Deals Section
                    _buildHomeBoxProductsDealsSection(),
                    const SizedBox(height: 25),

                    // Home Repairs Section
                    _buildHomeRepairsSection(),
                    const SizedBox(height: 25),

                    // Top Deals Across the Web Section
                    /* _buildVerifiedProductsSection(),
                    const SizedBox(height: 25),*/

                    // Promotional Slider
                    // _buildPromotionalSlider(),
                    // const SizedBox(height: 25),

                    Consumer<BrandsProvider>(
                      builder: (context, brandsProvider, child) {
                        return _buildBrandsSections(brandsProvider);
                      },
                    ),
                    const SizedBox(height: 45),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Top Categories Slider Widget
  Widget _buildCategoriesSlider() {
    if (_isCategoriesLoading) {
      return const CategoryShimmer();
    }

    if (_categoriesError != null || _topCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Section Header
          Row(
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
              const Text(
                'Shop by Category',
                style: TextStyle(
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
            ],
          ),
          const SizedBox(height: 20),

          // Enhanced Slider Container with modern styling
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  spreadRadius: 0,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Swiper(
                itemCount: _topCategories.length,
                autoplay: true,
                autoplayDelay: 4000,
                duration: 600,
                viewportFraction: 0.92,
                scale: 0.90,
                pagination: SwiperPagination(
                  alignment: Alignment.bottomCenter,
                  margin: const EdgeInsets.only(bottom: 16),
                  builder: DotSwiperPaginationBuilder(
                    color: Colors.white.withOpacity(0.4),
                    activeColor: AppColors.primary,
                    size: 10,
                    activeSize: 12,
                    space: 8,
                  ),
                ),
                itemBuilder: (context, index) {
                  final category = _topCategories[index];
                  return _buildCategorySlideItem(category);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Individual Category Slide Item
  Widget _buildCategorySlideItem(Map<String, dynamic> category) {
    final categoryName = category['category_name'] ?? 'Category';
    final categoryUrl = category['category_url'] ?? '';
    final categoryImage = category['category_image'] ?? '';

    return GestureDetector(
      onTap: () => _handleCategoryTap(categoryName, categoryUrl),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image with better fit
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[100]!,
                      Colors.grey[200]!,
                    ],
                  ),
                ),
                child: categoryImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: categoryImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.grey[100]!,
                                Colors.grey[200]!,
                              ],
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withOpacity(0.1),
                                AppColors.primary.withOpacity(0.05),
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.category_outlined,
                                  size: 56,
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  categoryName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.primary.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.category_outlined,
                                size: 56,
                                color: AppColors.primary.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                categoryName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              // Enhanced Gradient Overlay for better text visibility
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.75),
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.0, 0.4, 0.7, 0.9, 1.0],
                  ),
                ),
              ),

              // Decorative Top Accent
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.8),
                        AppColors.primary.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Category Content at Bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Category Name with enhanced styling
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              categoryName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black87,
                                    offset: Offset(0, 2),
                                    blurRadius: 8,
                                  ),
                                  Shadow(
                                    color: Colors.black54,
                                    offset: Offset(0, 1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Explore Button Style Text
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Explore Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Shimmer effect overlay (optional)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _handleCategoryTap(categoryName, categoryUrl),
                    splashColor: Colors.white.withOpacity(0.2),
                    highlightColor: Colors.white.withOpacity(0.1),
                    child: Container(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle category tap navigation
  Future<void> _handleCategoryTap(
      String categoryName, String categoryUrl) async {
    log('Category tapped: $categoryName');
    if (categoryUrl.isEmpty) return;

    // Remove leading slash if present
    String cleanUrl =
        categoryUrl.startsWith('/') ? categoryUrl.substring(1) : categoryUrl;

    // Remove 'category/' prefix if present to avoid duplication
    if (cleanUrl.startsWith('category/')) {
      cleanUrl = cleanUrl.substring(9); // Remove 'category/'
    }

    // Extract only the last segment of the path
    final pathSegments = cleanUrl.split('/');
    cleanUrl = pathSegments.last;

    log('Original path from API: $categoryUrl');
    log('Clean category path: $cleanUrl');

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Small delay to ensure dialog is shown
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      // Try to fetch subcategories
      final subcategories = await BrandsApi.fetchCategorySubcategories(
        cleanUrl,
        context,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        log('✅ Loading dialog closed');
      }

      // Small delay before navigation
      await Future.delayed(const Duration(milliseconds: 100));

      if (subcategories.isNotEmpty) {
        // Navigate to subcategories screen
        log('✅ Found ${subcategories.length} subcategories, navigating to subcategories screen');
        if (context.mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategorySubcategoriesScreen(
                categoryName: categoryName,
                categoryPath: cleanUrl,
                subcategories: subcategories,
              ),
            ),
          );
        }
      } else {
        // No subcategories found - show message, don't navigate
        log('⚠️ No subcategories found for category: $categoryName');
        log('Category path: $cleanUrl');
        log('❌ NOT navigating to products - subcategories should exist');

        // Show error message to user
        if (context.mounted) {
          CommonToasts.centeredMobile(
            msg: 'No subcategories available for $categoryName',
            context: context,
          );
        }
      }
    } catch (e) {
      log('❌ Error loading subcategories: $e');
      // Close loading dialog on error
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        log('✅ Loading dialog closed (error case)');

        // Small delay before showing error
        await Future.delayed(const Duration(milliseconds: 100));

        // Show error message to user
        if (context.mounted) {
          CommonToasts.centeredMobile(
            msg: 'Failed to load $categoryName',
            context: context,
          );
        }
        log('❌ Error displayed to user, NOT navigating to products');
      }
    }
  }

  /// Kitchen Appliances Horizontal Section Widget
  Widget _buildKitchenAppliancesSection() {
    // Get products from API - try multiple search patterns
    List<Map<String, dynamic>> products = [];
    String? categoryTitle;

    // Try different search patterns
    final searchPatterns = [
      'Ranges, Cooktops, Microwaves',
      'Ranges',
      'Cooktops',
      'Microwaves',
    ];

    for (var pattern in searchPatterns) {
      products = _getProductsForCategory(pattern);
      categoryTitle = _getCategoryTitle(pattern);
      if (products.isNotEmpty && categoryTitle != null) {
        break;
      }
    }

    // Show shimmer when loading
    if (_isHomeSliderDealsLoading) {
      return const ProductSectionShimmer();
    }

    // Hide section when no products or when no category title
    if (products.isEmpty || categoryTitle == null) {
      return const SizedBox.shrink();
    }

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
                    _showAllKitchenDeals = !_showAllKitchenDeals;
                  });
                },
                child: Text(
                  _showAllKitchenDeals ? 'Show Less' : 'View All Deals',
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
          if (!_showAllKitchenDeals)
            SizedBox(
              height: 380,
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
            // Expanded Grid View
            _buildExpandedApiProductGrid(products),
        ],
      ),
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
                height: 40,
                width: 80,
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
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

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
                        // Original Price (strikethrough) - on the right, only show if discounted
                        if (discountPercent > 0 && msrp > 0)
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
                    // Discount Badge - only show if there's a discount
                    if (discountPercent > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red[200]!, width: 1),
                        ),
                        child: Text(
                          '${discountPercent.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Colors.green,
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.70,
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
              height: 90,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
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
              padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
              child: SizedBox(
                height: 30,
                width: 70,
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
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
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

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
                        // Original Price (strikethrough) - on the right, only show if discounted
                        if (discountPercent > 0 && msrp > 0)
                          Flexible(
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
                    // Discount Badge - only show if there's a discount
                    if (discountPercent > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red[200]!, width: 1),
                        ),
                        child: Text(
                          '${discountPercent.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Colors.green,
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

  /// Build Static Product Card
  Widget _buildStaticProductCard(Map<String, dynamic> product) {
    final brand = product['brand'] ?? '';
    final model = product['model'] ?? '';
    final name = product['name'] ?? '';
    final image = product['image'] ?? '';
    final originalPrice = product['originalPrice'] ?? 0.0;
    final discountedPrice = product['discountedPrice'] ?? 0.0;
    final discountPercent = product['discountPercent'] ?? 0;

    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: image.isNotEmpty && image.contains('no_image')
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
                      imageUrl: image,
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
              height: 40,
              width: 80,
              child: BrandImageWidget(
                brand: {
                  'brand_name': brand,
                  'brand_key': brand,
                  'brand_id': 0,
                },
                width: 80,
                height: 40,
              ),
            ),
          ),

          // Product Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Model Number
                  Text(
                    model,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Product Name
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Price Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Original Price (strikethrough) - only show if discounted
                      if (discountPercent > 0) ...[
                        Text(
                          '\$${_formatPrice(originalPrice.toString())}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Current Price
                      Text(
                        '\$${_formatPrice(discountedPrice.toString())}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Discount Badge - only show if there's a discount
                  if (discountPercent > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red[200]!, width: 1),
                      ),
                      child: Text(
                        '$discountPercent% OFF',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
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
    );
  }

  /// Outdoor Kitchen Deals Horizontal Section Widget
  Widget _buildOutdoorKitchenSection() {
    // Get products from API - search for outdoor kitchen related categories
    final products = _getProductsForCategory('Outdoor Kitchen');
    final categoryTitle = _getCategoryTitle('Outdoor Kitchen');

    // Show shimmer when loading (Outdoor Kitchen uses height 400)
    if (_isHomeSliderDealsLoading) {
      return const ProductSectionShimmer(height: 400);
    }

    // Hide section when no products or when no category title
    if (products.isEmpty || categoryTitle == null) {
      return const SizedBox.shrink();
    }

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
                    _showAllOutdoorDeals = !_showAllOutdoorDeals;
                  });
                },
                child: Text(
                  _showAllOutdoorDeals ? 'Show Less' : 'View All Deals',
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
          if (!_showAllOutdoorDeals)
            SizedBox(
              height: 400,
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
            // Expanded Grid View
            _buildExpandedApiProductGrid(products),
        ],
      ),
    );
  }

  /// Kitchen Faucet Deals Section Widget
  Widget _buildKitchenFaucetDealsSection() {
    // Get products from API - search for kitchen faucet related categories
    final products = _getProductsForCategory('Kitchen Faucet');
    final categoryTitle = _getCategoryTitle('Kitchen Faucet');

    // Show shimmer when loading
    if (_isHomeSliderDealsLoading) {
      return const ProductSectionShimmer();
    }

    // Hide section when no products or when no category title
    if (products.isEmpty || categoryTitle == null) {
      return const SizedBox.shrink();
    }

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
                    _showAllFaucetDeals = !_showAllFaucetDeals;
                  });
                },
                child: Text(
                  _showAllFaucetDeals ? 'Show Less' : 'View All Deals',
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
          if (!_showAllFaucetDeals)
            SizedBox(
              height: 380,
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
            // Expanded Grid View
            _buildExpandedApiProductGrid(products),
        ],
      ),
    );
  }

  /// Kitchen Sinks Sale Section Widget
  Widget _buildKitchenSinksSaleSection() {
    // Get products from API - search for kitchen sinks related categories
    final products = _getProductsForCategory('Kitchen Sinks');
    final categoryTitle = _getCategoryTitle('Kitchen Sinks');

    // Show shimmer when loading
    if (_isHomeSliderDealsLoading) {
      return const ProductSectionShimmer();
    }

    // Hide section when no products or when no category title
    if (products.isEmpty || categoryTitle == null) {
      return const SizedBox.shrink();
    }

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
                    _showAllSinkDeals = !_showAllSinkDeals;
                  });
                },
                child: Text(
                  _showAllSinkDeals ? 'Show Less' : 'View All Deals',
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
          if (!_showAllSinkDeals)
            SizedBox(
              height: 380,
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
            // Expanded Grid View
            _buildExpandedApiProductGrid(products),
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
          // const SizedBox(height: 20),

          // Products Grid (2x2)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildHomeBoxProductCard(product);
            },
          ),

          // View All Deals Link
          // const SizedBox(height: 16),
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
    // Debug: Log all product keys to see available fields
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                    Flexible(
                      child: Text(
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
                    ),
                    const SizedBox(height: 10),

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
                        // Original Price (strikethrough) - on the right, only show if discounted
                        if (discountPercent > 0 && msrp > 0)
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
                    // Discount Badge - only show if there's a discount
                    if (discountPercent > 0) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Home Repairs Section Widget
  Widget _buildHomeRepairsSection() {
    // Static home repairs category data
    final List<Map<String, dynamic>> homeRepairsCategories = [
      {
        'icon': '🧹',
        'label': 'Cleaning Tools',
      },
      {
        'icon': '📦',
        'label': 'Home Storage',
      },
      {
        'icon': '🖼',
        'label': 'Home Decor',
      },
      {
        'icon': '🛏️',
        'label': 'Bedding',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Home Repairs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Categories Horizontal Scroll
          SizedBox(
            height: 180, // Increased height to accommodate larger cards
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: homeRepairsCategories.length,
              itemBuilder: (context, index) {
                final category = homeRepairsCategories[index];
                return _buildHomeRepairCategoryCard(category);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build Expanded Product Grid View
  Widget _buildExpandedProductGrid(List<Map<String, dynamic>> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.70,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildStaticProductCardGrid(product);
      },
    );
  }

  /// Build Static Product Card for Grid View
  Widget _buildStaticProductCardGrid(Map<String, dynamic> product) {
    final brand = product['brand'] ?? '';
    final model = product['model'] ?? '';
    final name = product['name'] ?? '';
    final image = product['image'] ?? '';
    final originalPrice = product['originalPrice'] ?? 0.0;
    final discountedPrice = product['discountedPrice'] ?? 0.0;
    final discountPercent = product['discountPercent'] ?? 0;

    return Container(
      //  height: 1000,
      //     margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            height: 100,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: image.isNotEmpty && image.contains('no_image')
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
                            'No image available',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: image,
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
                              'No image available',
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
            padding: const EdgeInsets.only(left: 8, top: 6, bottom: 4),
            child: SizedBox(
              height: 35,
              width: 70,
              child: BrandImageWidget(
                brand: {
                  'brand_name': brand,
                  'brand_key': brand,
                  'brand_id': 0,
                },
                width: 70,
                height: 35,
              ),
            ),
          ),

          // Product Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Model Number
                  Text(
                    model,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Product Name
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Price Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Original Price (strikethrough) - only show if discounted
                      if (discountPercent > 0) ...[
                        Text(
                          '\$${_formatPrice(originalPrice.toString())}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      // Current Price
                      Text(
                        '\$${_formatPrice(discountedPrice.toString())}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  // Discount Badge - only show if there's a discount
                  if (discountPercent > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red[200]!, width: 1),
                      ),
                      child: Text(
                        '$discountPercent% OFF',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Home Repair Category Card
  Widget _buildHomeRepairCategoryCard(Map<String, dynamic> category) {
    final icon = category['icon'] ?? '📦';
    final label = category['label'] ?? 'Category';

    return Container(
      width: 140,
      height: 180, // Match parent SizedBox height
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Emoji Icon
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 45),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Label
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Deals Across the Web Section Widget
  // Widget _buildVerifiedProductsSection() {
  //   if (_isVerifiedProductsLoading) {
  //     return Container(
  //       margin: const EdgeInsets.symmetric(horizontal: 16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Section Header
  //           Row(
  //             children: [
  //               Container(
  //                 width: 4,
  //                 height: 24,
  //                 decoration: BoxDecoration(
  //                   color: AppColors.primary,
  //                   borderRadius: BorderRadius.circular(2),
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               const Text(
  //                 'The Best Online Savings This Week',
  //                 style: TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.black87,
  //                   letterSpacing: 0.5,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           Container(
  //             height: 220,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(16),
  //               color: Colors.grey[200],
  //             ),
  //             child: const Center(
  //               child: CircularProgressIndicator(
  //                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  //
  //   if (_verifiedProductsError != null || _verifiedProducts.isEmpty) {
  //     return const SizedBox.shrink();
  //   }
  //
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Section Header
  //         Row(
  //           children: [
  //             Container(
  //               width: 4,
  //               height: 24,
  //               decoration: BoxDecoration(
  //                 color: AppColors.primary,
  //                 borderRadius: BorderRadius.circular(2),
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             const Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   const Text(
  //                     'The Best Online Savings This Week',
  //                     style: TextStyle(
  //                       fontSize: 20,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.black87,
  //                       letterSpacing: 0.5,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //
  //         // Products Horizontal Scroll
  //         SizedBox(
  //           height: 360,
  //           child: ListView.builder(
  //             scrollDirection: Axis.horizontal,
  //             padding: const EdgeInsets.symmetric(horizontal: 8),
  //             itemCount: _verifiedProducts.length,
  //             itemBuilder: (context, index) {
  //               final product = _verifiedProducts[index];
  //               return _buildVerifiedProductCard(product);
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  /// Build Individual Verified Product Card
  Widget _buildVerifiedProductCard(VendorProduct product) {
    // Get vendor data from product's lowest_vendor array
    final vendors = _getVendorsFromVerifiedProduct(product);

    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image
          GestureDetector(
            onTap: () => _navigateToProductDetails(product),
            child: Container(
              height: 140,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: _getProperImageUrl(product.productImage),
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
                    color: Colors.grey[50],
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Brand Logo using existing BrandImageWidget - Clickable
          GestureDetector(
            onTap: () => _navigateToProductDetails(product),
            child: Container(
              height: 55,
              width: 55,
              margin: const EdgeInsets.only(bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BrandImageWidget(
                  brand: {
                    'brand_name': product.brandName,
                    'brand_key': product.brandName,
                    // Let BrandImageWidget handle the processing
                    'brand_id': product.productId,
                    // Using productId as fallback
                  },
                  width: 55,
                  height: 55,
                ),
              ),
            ),
          ),

          // Product Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Product Name
                  GestureDetector(
                    onTap: () => _navigateToProductDetails(product),
                    child: Text(
                      product.productName.isEmpty
                          ? 'Product Name Not Available'
                          : product.productName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Model Number
                  if (product.productMpn.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          'Model: ',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          //textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          product.productMpn.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          //textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                  const Spacer(),

                  // Vendor Prices (side by side)
                  if (vendors.isNotEmpty)
                    Row(
                      children: [
                        // First vendor
                        Expanded(
                          child: _buildVendorPriceWidget(vendors.first),
                        ),
                        // Second vendor if available
                        if (vendors.length > 1) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildVendorPriceWidget(vendors[1]),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to product details
  void _navigateToProductDetails(VendorProduct product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          productId: product.productId,
          brandName: product.brandName,
          productMPN: product.productMpn,
          productImage: product.productImage,
          productPrice: double.tryParse(product.vendorpricePrice) ?? 0.0,
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

  /// Format price with comma separators
  String _formatPrice(String price) {
    try {
      final double? priceValue =
          double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), ''));

      if (priceValue == null) {
        return price;
      }

      final formatter = NumberFormat('#,###.##');
      return formatter.format(priceValue);
    } catch (e) {
      return price;
    }
  }

  /// Build vendor price widget for verified products
  Widget _buildVendorPriceWidget(Map<String, dynamic> vendor) {
    return GestureDetector(
      onTap: () => _openVendorWebsite(vendor),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, width: 0.5),
        ),
        child: Column(
          children: [
            // Vendor logo
            SizedBox(
              height: 30,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: _getVendorLogoUrl(vendor['name']?.toString() ?? ''),
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  padding: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  child: Text(
                    vendor['name']?.toString() ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  padding: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  child: Text(
                    vendor['name']?.toString() ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Price
            Text(
              '\$${_formatPrice(vendor['price']?.toString() ?? '0')}',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Get vendors from verified product
  List<Map<String, dynamic>> _getVendorsFromVerifiedProduct(
      VendorProduct product) {
    List<Map<String, dynamic>> vendors = [];

    // Add main vendor
    vendors.add({
      'name': product.vendorName,
      'price': product.vendorpricePrice,
      'url': product.vendorUrl,
    });

    // Add vendors from lowest_vendor array
    if (product.lowestVendor != null && product.lowestVendor!.isNotEmpty) {
      for (var lowestVendor in product.lowestVendor!) {
        // Skip if it's the same as main vendor
        if (lowestVendor.vendorName != product.vendorName) {
          vendors.add({
            'name': lowestVendor.vendorName,
            'price': lowestVendor.vendorpricePrice,
            'url': lowestVendor.vendorUrl,
          });
        }
      }
    }

    // Sort by price to show cheapest first
    vendors.sort((a, b) {
      final priceA = double.tryParse(
              a['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ??
                  '0') ??
          0;
      final priceB = double.tryParse(
              b['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ??
                  '0') ??
          0;
      return priceA.compareTo(priceB);
    });

    // Return maximum 2 vendors
    return vendors.take(2).toList();
  }

  /// Get vendor logo URL
  String _getVendorLogoUrl(String vendorName) {
    return 'https://growth.matridtech.net/vendor-logo/$vendorName.jpg';
  }

  Widget _buildBrandsSections(BrandsProvider brandsProvider) {
    log('_buildBrandsSections called with state: ${brandsProvider.state}');
    log('Home & Garden count: ${brandsProvider.homeGardenBrands.length}');
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
          // Home & Garden Section
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
                        'Home & Garden',
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

class BrandImageWidget extends StatefulWidget {
  final Map<String, dynamic> brand;
  final double? width;
  final double? height;

  const BrandImageWidget({
    super.key,
    required this.brand,
    this.width,
    this.height,
  });

  @override
  State<BrandImageWidget> createState() => _BrandImageWidgetState();
}

class _BrandImageWidgetState extends State<BrandImageWidget> {
  late String _imageUrl1;
  late String _imageUrl2;
  late String _currentUrl;
  int _attempt = 0;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall() async {
    await _initializeImageUrls();
  }

  Future<void> _initializeImageUrls() async {
    log('Get Image From Site');
    log('width: ${widget.width}');
    log('height: ${widget.height}');
    try {
      String brandName = widget.brand['brand_name']?.toString() ?? '';
      String brandKey = widget.brand['brand_key']?.toString() ?? '';
      int brandId = widget.brand['brand_id'] ?? 0;

      // Clean and process brand names more thoroughly
      String processedBrandName = brandName
          .trim()
          .replaceAll(RegExp(r'[^\w\s-]'),
              '') // Remove special characters except hyphens
          .replaceAll(
              RegExp(r'\s+'), '-') // Replace multiple spaces with single hyphen
          .replaceAll(
              RegExp(r'-+'), '-') // Replace multiple hyphens with single hyphen
          .replaceAll(RegExp(r'^-|-$'), '') // Remove leading/trailing hyphens
          .toLowerCase();

      String processedBrandKey = brandKey
          .trim()
          .replaceAll(RegExp(r'[^\w\s-]'),
              '') // Remove special characters except hyphens
          .replaceAll(
              RegExp(r'\s+'), '-') // Replace multiple spaces with single hyphen
          .replaceAll(
              RegExp(r'-+'), '-') // Replace multiple hyphens with single hyphen
          .replaceAll(RegExp(r'^-|-$'), '') // Remove leading/trailing hyphens
          .toLowerCase();

      _imageUrl1 =
          'https://www.minsellprice.com/Brand-logo-images/$processedBrandName.png';
      _imageUrl2 =
          'https://growth.matridtech.net/brand-logo/brands/$processedBrandKey.png';

      _currentUrl = _imageUrl1;

      log(
        'BrandImageWidget [ID:$brandId] - Brand: "$brandName", Key: "$brandKey"',
      );
      log(
        'BrandImageWidget [ID:$brandId] - Processed Brand Name: "$processedBrandName"',
      );
      log('BrandImageWidget [ID:$brandId] - URL 1: $_imageUrl1');
      log('BrandImageWidget [ID:$brandId] - URL 2: $_imageUrl2');
      log('BrandImageWidget [ID:$brandId] - Full brand data: ${widget.brand}');
    } catch (e) {
      log('Error initializing image URLs: $e');
      _currentUrl = '';
    }
  }

  void _onImageError() {
    setState(() {
      if (_attempt == 0) {
        // First failure: try second URL (growth.matridtech.net)
        _currentUrl = _imageUrl2;
        log('First URL failed, trying alternative URL: $_imageUrl2');
        _attempt++;
      } else {
        // Second failure: show placeholder
        _currentUrl = '';
        log('Both image URLs failed, showing placeholder');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // color: Colors.white,
      ),
      child: _currentUrl.isEmpty
          ? _buildPlaceholderWidget()
          : CachedNetworkImage(
              key: ValueKey(_currentUrl),
              // Force rebuild when URL changes
              imageUrl: _currentUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => _buildLoadingWidget(),
              errorWidget: (context, url, error) {
                log('Image load error for URL: $url, Error: $error');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _onImageError();
                  }
                });
                return _buildErrorWidget();
              },
            ),
    );
  }

  Widget _buildPlaceholderWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[100]!, Colors.grey[200]!],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.image, color: Colors.grey[400], size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[50]!, Colors.grey[100]!],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 33,
            height: 33,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withOpacity(0.7),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red[50]!, Colors.red[100]!],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.red[400],
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Image Error',
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
