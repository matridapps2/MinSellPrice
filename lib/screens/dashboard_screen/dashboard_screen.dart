import 'dart:async';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
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
            vendorIdCount: 1, // Default since API doesn't provide this
            vendorpriceDate: '', // API doesn't provide main vendor date
            vendorUrl: productData['vendor_url']?.toString() ?? '',
            productMpn: productData['product_mpn']?.toString() ?? '',
            productName: productData['product_name']?.toString() ?? '',
            productImage: productData['product_image']?.toString() ?? '',
            imageName: '', // API doesn't provide this
            totalCount: 0, // API doesn't provide this
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
                          borderSide: BorderSide(
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
                          borderSide: BorderSide(
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
                    _buildCategoriesSlider(),
                    const SizedBox(height: 25),

                    // Top Deals Across the Web Section
                    _buildVerifiedProductsSection(),
                    const SizedBox(height: 25),

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
                  'Shop by Category',
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
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[200],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_categoriesError != null || _topCategories.isEmpty) {
      return const SizedBox.shrink();
    }

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
                'Shop by Category',
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

          // Slider Container
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Swiper(
                itemCount: _topCategories.length,
                autoplay: true,
                autoplayDelay: 3500,
                duration: 800,
                viewportFraction: 0.95,
                scale: 0.92,
                pagination: SwiperPagination(
                  alignment: Alignment.bottomCenter,
                  builder: DotSwiperPaginationBuilder(
                    color: Colors.white.withOpacity(0.5),
                    activeColor: AppColors.primary,
                    size: 8,
                    activeSize: 10,
                    space: 6,
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
      onTap: () async {
        log('Category tapped: $categoryName');
        if (categoryUrl.isNotEmpty) {
          // Remove leading slash if present
          String cleanUrl = categoryUrl.startsWith('/')
              ? categoryUrl.substring(1)
              : categoryUrl;

          // Remove 'category/' prefix if present to avoid duplication
          if (cleanUrl.startsWith('category/')) {
            cleanUrl = cleanUrl.substring(9); // Remove 'category/'
          }

          // Extract only the last segment of the path
          // Example: "cooking/range-hoods" -> "range-hoods"
          final pathSegments = cleanUrl.split('/');
          cleanUrl = pathSegments.last;

          log('Original path from API: $categoryUrl');
          log('Clean category path: $cleanUrl');

          // Show loading indicator and store the context
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
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        const Text('Loading...'),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('No subcategories available for $categoryName'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 3),
                  ),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to load $categoryName'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
              log('❌ Error displayed to user, NOT navigating to products');
            }
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            CachedNetworkImage(
              imageUrl: categoryImage,
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                color: Colors.grey[100],
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[100],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category,
                      size: 48,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      categoryName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Gradient Overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),

            // Category Name at Bottom
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Explore now',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      shadows: const [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tap Effect
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  log('Category slide tapped: $categoryName');
                  if (categoryUrl.isNotEmpty) {
                    String cleanUrl = categoryUrl.startsWith('/')
                        ? categoryUrl.substring(1)
                        : categoryUrl;

                    // Remove 'category/' prefix if present to avoid duplication
                    if (cleanUrl.startsWith('category/')) {
                      cleanUrl = cleanUrl.substring(9); // Remove 'category/'
                    }

                    // Extract only the last segment of the path
                    // Example: "cooking/range-hoods" -> "range-hoods"
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
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary),
                                  ),
                                  SizedBox(height: 16),
                                  Text('Loading...'),
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
                      final subcategories =
                          await BrandsApi.fetchCategorySubcategories(
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'No subcategories available for $categoryName'),
                              backgroundColor: Colors.orange,
                              duration: const Duration(seconds: 3),
                            ),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to load $categoryName'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                        log('❌ Error displayed to user, NOT navigating to products');
                      }
                    }
                  }
                },
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Deals Across the Web Section Widget
  Widget _buildVerifiedProductsSection() {
    if (_isVerifiedProductsLoading) {
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
                  'The Best Online Savings This Week',
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
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[200],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_verifiedProductsError != null || _verifiedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'The Best Online Savings This Week',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Products Horizontal Scroll
          SizedBox(
            height: 360,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _verifiedProducts.length,
              itemBuilder: (context, index) {
                final product = _verifiedProducts[index];
                return _buildVerifiedProductCard(product);
              },
            ),
          ),
        ],
      ),
    );
  }

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
                    'brand_key': product
                        .brandName, // Let BrandImageWidget handle the processing
                    'brand_id':
                        product.productId, // Using productId as fallback
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to open $vendorName website'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } else {
      log('Invalid or empty vendor URL for: $vendorName');
      // Show message for invalid URL
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No website available for $vendorName'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Get proper image URL
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
            Container(
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
            Icon(Icons.error_outline, size: 64, color: Colors.red),
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
              key: ValueKey(_currentUrl), // Force rebuild when URL changes
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
