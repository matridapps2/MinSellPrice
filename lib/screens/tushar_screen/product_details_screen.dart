import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minsellprice/app.dart';
import 'package:minsellprice/colors.dart' show AppColors;
import 'package:minsellprice/dashboard_screen.dart';
import 'package:minsellprice/model/product_list_model_new.dart'
    show ProductListModelNew, VendorProduct;
import 'package:minsellprice/reposotory_services/network_reposotory.dart'
    show NetworkCalls;
import 'package:minsellprice/screens/tushar_screen/comparison_screen.dart';
import 'package:minsellprice/screens/tushar_screen/model/product_details_model.dart';
import 'package:minsellprice/services/comparison_db.dart';
import 'package:minsellprice/services/extra_functions.dart'
    show ColorExtension, getUniqueBrands;
import 'package:minsellprice/services/liked_preference_db.dart';
import 'package:minsellprice/size.dart';

import 'model/brand_product_details_api_model.dart' as brand_api;

class ProductDetailsScreen extends StatefulWidget {
  final int productId;
  final String brandName;
  final String productMPN;
  final productImage;
  final productPrice;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.brandName,
    required this.productMPN,
    required this.productImage,
    required this.productPrice,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  ProductDetailsModel? productDetails;
  bool isLoading = true;
  String? errorMessage;
  List<String> filterVendor = [];
  List<String> uniqueVendors = [];
  List<VendorProduct> brandProducts = [];
  List<VendorProduct> tempProductList = [];
  List<VendorProduct> finalList = [];
  List<ProductListModelNew> brandDetails = [];
  final ScrollController _scrollController = ScrollController();
  String loadingMessage = '';
  List<brand_api.VendorProductData> vendorProductData = [];

  // Liked state variable
  bool isLiked = false;
  bool isInComparison = false;
  int comparisonCount = 0;
  int vendorId = AppInfo.kVendorId;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall() async {
    await _fetchProductDetails();
    await _fetchBrandProducts();
    await _checkIfLiked(); // Check liked status after vendor data is fetched
    await _checkIfInComparison(); // Check comparison status
  }

  Future<void> _checkIfLiked() async {
    try {
      // Get vendor_product_id from API response
      int? actualVendorProductId;
      if (vendorProductData.isNotEmpty) {
        final currentProduct = vendorProductData.firstWhere(
          (product) => product.productId == widget.productId,
          orElse: () => vendorProductData.first,
        );
        actualVendorProductId = currentProduct.vendorProductId;
      }

      // If we don't have the vendor_product_id from API, create a fallback
      actualVendorProductId ??= int.parse('$vendorId${widget.productId}');

      // Check if product is liked using the new database
      final isProductLiked = await LikedPreferencesDB.isProductLiked(
        vendorProductId: actualVendorProductId,
      );

      if (mounted) {
        setState(() {
          isLiked = isProductLiked;
        });
      }

      log('Product liked status: $isLiked for vendor_product_id: $actualVendorProductId');
    } catch (e) {
      log('Error checking if product is liked: $e');
    }
  }

  Future<void> _checkIfInComparison() async {
    try {
      // Get vendor_product_id from API response
      int? actualVendorProductId;
      if (vendorProductData.isNotEmpty) {
        final currentProduct = vendorProductData.firstWhere(
          (product) => product.productId == widget.productId,
          orElse: () => vendorProductData.first,
        );
        actualVendorProductId = currentProduct.vendorProductId;
      }

      // If we don't have the vendor_product_id from API, create a fallback
      actualVendorProductId ??= int.parse('$vendorId${widget.productId}');

      // Check if product is in comparison using the new database
      final isProductInComparison = await ComparisonDB.isInComparison(
        vendorProductId: actualVendorProductId,
      );

      // Get current comparison count
      final currentComparisonCount = await ComparisonDB.getComparisonCount();

      if (mounted) {
        setState(() {
          isInComparison = isProductInComparison;
          comparisonCount = currentComparisonCount;
        });
      }

      log('Product comparison status: $isInComparison for vendor_product_id: $actualVendorProductId');
      log('Total products in comparison: $comparisonCount');
    } catch (e) {
      log('Error checking if product is in comparison: $e');
    }
  }

  Future<void> _toggleComparison() async {
    try {
      // Get vendor_product_id from API response
      int? actualVendorProductId;
      if (vendorProductData.isNotEmpty) {
        final currentProduct = vendorProductData.firstWhere(
          (product) => product.productId == widget.productId,
          orElse: () => vendorProductData.first,
        );
        actualVendorProductId = currentProduct.vendorProductId;
      }

      // If we don't have the vendor_product_id from API, create a fallback
      actualVendorProductId ??= int.parse('$vendorId${widget.productId}');

      // Toggle comparison status using the new database
      final nowInComparison = await ComparisonDB.toggleComparison(
        productId: widget.productId,
        vendorProductId: actualVendorProductId,
        productName: productDetails?.data?.productName ?? 'Unknown Product',
        productImage: widget.productImage?.toString() ?? '',
        brandName: widget.brandName,
        productMpn: widget.productMPN,
        productPrice: widget.productPrice?.toString() ?? '0',
      );

      // Update UI state
      if (mounted) {
        setState(() {
          isInComparison = nowInComparison;
        });
      }

      // Refresh comparison count after toggle
      await _checkIfInComparison();

      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isInComparison
                    ? Icons.compare_arrows
                    : Icons.compare_arrows_outlined,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(isInComparison
                  ? 'Added to comparison!'
                  : 'Removed from comparison!'),
            ],
          ),
          backgroundColor: isInComparison ? Colors.orange : Colors.grey,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      log('Product ${isInComparison ? 'added to' : 'removed from'} comparison with vendor_product_id: $actualVendorProductId');
    } catch (e) {
      log('Error toggling comparison state: $e');

      // Show appropriate error message
      String errorMessage = 'Error updating comparison status';
      if (e.toString().contains('Maximum')) {
        errorMessage = 'Maximum 4 products can be compared at once';
      } else if (e.toString().contains('already in comparison')) {
        errorMessage = 'Product is already in comparison';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _toggleLiked() async {
    try {
      // Get vendor_product_id from API response
      int? actualVendorProductId;
      if (vendorProductData.isNotEmpty) {
        final currentProduct = vendorProductData.firstWhere(
          (product) => product.productId == widget.productId,
          orElse: () => vendorProductData.first,
        );
        actualVendorProductId = currentProduct.vendorProductId;
      }

      // If we don't have the vendor_product_id from API, create a fallback
      actualVendorProductId ??= int.parse('$vendorId${widget.productId}');

      // Toggle like status using the new database
      final nowLiked = await LikedPreferencesDB.toggleLikeProduct(
        productId: widget.productId,
        vendorProductId: actualVendorProductId,
        productName: productDetails?.data?.productName ?? 'Unknown Product',
        productImage: widget.productImage?.toString() ?? '',
        brandName: widget.brandName,
        productMpn: widget.productMPN,
        productPrice: widget.productPrice?.toString() ?? '0',
      );

      // Update UI state
      if (mounted) {
        setState(() {
          isLiked = nowLiked;
        });
      }

      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(isLiked ? 'Added to favorites!' : 'Removed from favorites!'),
            ],
          ),
          backgroundColor: isLiked ? Colors.red : Colors.grey,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      log('Product ${isLiked ? 'added to' : 'removed from'} favorites with vendor_product_id: $actualVendorProductId');
    } catch (e) {
      log('Error toggling liked state: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favorite status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchProductDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final details = await ProductDetailsApiService.getProductDetails(
        brandName: widget.brandName,
        productMPN: widget.productMPN,
        productId: widget.productId,
      );

      if (mounted) {
        setState(() {
          productDetails = details;
        });
        // Debug: Print the fetched data
        log('Single API Data is');
        log('${productDetails?.toJson()}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchBrandProducts() async {
    log('_fetchBrandProducts method is running');
    try {
      List<VendorProduct> allFetchedProducts = [];
      int pageNumber = 1;
      int maxPages = 5;
      int targetProducts = 20;

      while (pageNumber <= maxPages &&
          allFetchedProducts.length < targetProducts) {
        log('Fetching page $pageNumber');

        if (mounted) {
          setState(() {
            loadingMessage = 'Loading products... ';
          });
        }

        final allProductsResponse = await NetworkCalls()
            .getProductListByBrandName(widget.brandName.toString(), pageNumber);
        final Map<String, dynamic> decoded =
            jsonDecode(allProductsResponse ?? '{}');

        final List<dynamic> jsonList = decoded['brand_product'] ?? [];

        if (jsonList.isEmpty) {
          log('No more products found on page $pageNumber');
          break;
        }

        final List<VendorProduct> fetchedProducts =
            jsonList.map((e) => VendorProduct.fromJson(e)).toList();

        allFetchedProducts.addAll(fetchedProducts);
        log('Page $pageNumber: ${fetchedProducts.length} products, Total: ${allFetchedProducts.length}');
        if (pageNumber < maxPages &&
            allFetchedProducts.length < targetProducts) {
          await Future.delayed(const Duration(milliseconds: 100));
        }

        pageNumber++;
      }
      final List<VendorProduct> filteredProducts = allFetchedProducts
          .where((product) => product.productId != widget.productId)
          .toList();

      final List<VendorProduct> limitedProducts = filteredProducts.length > 20
          ? filteredProducts.take(20).toList()
          : filteredProducts;

      List<String> uniqueVendorsLocal = getUniqueBrands(limitedProducts);
      uniqueVendorsLocal =
          uniqueVendorsLocal.where((element1) => element1 != '--').toList();
      List<String> tempList = [];
      for (final vendor in uniqueVendorsLocal) {
        tempList.add(
            '$vendor Total Product(s): ${limitedProducts.where((element) => element.vendorName == vendor).toList().length} ');
      }

      if (mounted) {
        setState(() {
          brandProducts = limitedProducts;
          uniqueVendors = tempList;
          tempProductList = limitedProducts;
          finalList = limitedProducts;
          filterVendor = [];
          loadingMessage = 'Loading complete!';
          isLoading = false;
        });
      }

      log('Total Products fetched from all pages: ${allFetchedProducts.length}');
      log('Products after filtering current product: ${filteredProducts.length}');
      log('Final products to show: ${limitedProducts.length}');
      log('FinalList length: ${finalList.length}');
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      log('Error in fetching Brand Product list: $e');
    }
  }

  Future<void> _refreshProductDetails() async {
    await _fetchProductDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.brandName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actionsPadding: EdgeInsets.only(right: 15),
        actions: const [
          Icon(
            Icons.shopping_cart,
            size: 35,
            color: AppColors.primary,
          )
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshProductDetails,
            child: _buildBody(),
          ),
          // Floating Comparison Bar
          if (comparisonCount > 0) _buildFloatingComparisonBar(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              loadingMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading product details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchProductDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (productDetails?.data == null) {
      return const Center(
        child: Text('No product details available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImages(),
          const SizedBox(height: 16),
          _buildProductHeader(),
          const SizedBox(height: 16),
          _buildProductActionsBar(),
          const SizedBox(height: 16),
          _buildProductDetails(),
          const SizedBox(height: 16),
          _buildPriceAndRating(),
          const SizedBox(height: 16),
          _buildSubscribeButton(),
          const SizedBox(height: 24),
          _buildSpecifications(),
          const SizedBox(height: 16),
          _buyAtName(),
          const SizedBox(height: 16),
          _buyAtDesign(),
          const SizedBox(height: 24),
          _buildShippingInfo(),
          const SizedBox(height: 16),
          _buildMoreName(),
          const SizedBox(height: 16),
          _buildMoreDesign(),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    final data = productDetails!.data!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data.productName ?? 'Product Name Not Available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProductImages() {
    final apiImages = productDetails!.data!.images;
    final productName = productDetails!.data!.productName ?? '';
    final fallbackImage = widget.productImage;

    if (apiImages != null && apiImages.isNotEmpty) {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: apiImages.length,
          itemBuilder: (context, index) {
            return Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      apiImages[index],
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    if (fallbackImage != null && fallbackImage.toString().isNotEmpty) {
      return Stack(
        alignment: Alignment.bottomLeft,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              fallbackImage,
              width: double.infinity,
              height: w * .5,
              fit: BoxFit.fitHeight,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetails() {
    final data = productDetails!.data!;
    final brandData = {
      'brand_name': data.brandName ?? widget.brandName,
      'brand_key': (data.brandName ?? widget.brandName)
          .toString()
          .replaceAll(' ', '-')
          .toLowerCase(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrandImageWidget(brand: brandData, width: w * 0.3)
        // CachedNetworkImage(
        //   imageUrl:
        //       'https://www.minsellprice.com/Brand-logo-images/${data.brandName.toString().replaceAll(' ', '-').toLowerCase()}.png',
        //   width: 150,
        //   placeholder: (context, url) =>
        //       const Center(child: CircularProgressIndicator()),
        //   errorWidget: (context, url, error) => Image.asset(
        //     'assets/images/no_image.png',
        //     width: 150,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildPriceAndRating() {
    final data = widget.productPrice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${data ?? '--'}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...List.generate(
                4,
                (index) =>
                    const Icon(Icons.star, color: Colors.amber, size: 20)),
            const Icon(Icons.star_border, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              '(1 Reviews)', // You can use data.reviewCount if available
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubscribeButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            spreadRadius: 2,
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Subscribed to ${widget.brandName} notifications!'),
                  ],
                ),
                backgroundColor: AppColors.primary,
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Get Price Alerts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Subscribe for price drops',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecifications() {
    final List<Map<String, String>> specifications = [
      {'label': 'Brand', 'value': widget.brandName},
      {'label': 'Model', 'value': widget.productMPN},
      {'label': 'Material', 'value': 'Stainless Steel'},
      {'label': 'Dimensions', 'value': '24" W x 18" D x 36" H'},
      {'label': 'Weight', 'value': '45 lbs'},
      {'label': 'Color', 'value': 'Matte Black'},
      {'label': 'Warranty', 'value': '2 Year Limited'},
      {'label': 'Country of Origin', 'value': 'USA'},
      {'label': 'Certifications', 'value': 'UL Listed, CSA Approved'},
      {'label': 'Features', 'value': 'Smart Controls, LED Display'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Product Specifications',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.list_alt,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Technical Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              /// Creates a fixed-length scrollable linear array of list "items" separated
              /// by list item "separators".
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: specifications.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Colors.grey,
                ),
                itemBuilder: (context, index) {
                  final spec = specifications[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            spec['label']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Text(
                            spec['value']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductActionsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.share,
            label: 'Share',
            color: Colors.blue,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.share, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Product shared successfully!'),
                    ],
                  ),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _buildActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: 'Favorite',
            color: Colors.red,
            onTap: _toggleLiked,
          ),
          // Compare Button
          _buildActionButton(
            icon: isInComparison
                ? Icons.compare_arrows
                : Icons.compare_arrows_outlined,
            label: 'Compare',
            color: Colors.orange,
            onTap: _toggleComparison,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.local_shipping,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Shipping & Returns',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          color: Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Free Shipping',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'FREE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'On orders over \$75. Delivery in 3-5 business days.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // Delivery Options
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildShippingOption(
                      Icons.flash_on,
                      'Express Delivery',
                      '1-2 business days',
                      '\$15.99',
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildShippingOption(
                      Icons.schedule,
                      'Standard Delivery',
                      '3-5 business days',
                      'FREE',
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildShippingOption(
                      Icons.store,
                      'Store Pickup',
                      'Ready in 2 hours',
                      'FREE',
                      Colors.purple,
                    ),
                  ],
                ),
              ),

              // Returns Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.assignment_return,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Easy Returns',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• 30-day return policy\n• Free return shipping\n• Full refund or exchange\n• No restocking fees',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShippingOption(
      IconData icon, String title, String subtitle, String price, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: price == 'FREE' ? Colors.green : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMoreName() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'More From ${widget.brandName}',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMoreDesign() {
    log('_buildMoreDesign method is running');
    log('finalList length: ${finalList.length}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: Row(
            children: finalList.map((product) {
              return Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.productImage ?? '',
                              height: 80,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset('assets/no_image/no_image.jpg',
                                      height: 80, fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ...List.generate(
                                  4,
                                  (index) => const Icon(Icons.star,
                                      color: Colors.amber, size: 14)),
                              const Icon(Icons.star_border,
                                  color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '(1)',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${product.vendorpricePrice}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buyAtName() {
    return Text(
      'Buy At:',
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget _buyAtDesign() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: Row(
            children: vendorProductData.map((product) {
              return Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 80,
                              width: double.infinity,
                              color: Colors.white,
                              child: _buildVendorLogo(product.vendorName ?? ''),
                            ),
                          ),
                          Divider(
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              children: [
                                Text(
                                  '\$${product.vendorpricePrice ?? '--'}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '+',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.local_shipping,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '\$${product.vendorpriceShipping ?? '--'}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${product.vendorpriceDate ?? '--'}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorLogo(String vendorName) {
    String logoPath;

    switch (vendorName.toLowerCase()) {
      case 'home depot':
        logoPath = 'assets/vendor_logos/home_depot.png';
        break;
      case 'amazon.com':
      case 'amazon':
        logoPath = 'assets/vendor_logos/amazon.png';
        break;
      case 'lowe\'s':
      case 'lowes':
        logoPath = 'assets/vendor_logos/lowes.png';
        break;
      case 'wayfair':
        logoPath = 'assets/vendor_logos/wayfair.png';
        break;
      case 'houzz':
        logoPath = 'assets/vendor_logos/houzz.png';
        break;
      case 'home essentials direct':
        logoPath = 'assets/vendor_logos/home_essentials_direct.png';
        break;
      case 'gosupps.com':
        logoPath = 'assets/vendor_logos/gosupps.png';
        break;
      case 'supply online':
        logoPath = 'assets/vendor_logos/supply_online.png';
        break;
      case 'wwcsupply.com':
        logoPath = 'assets/vendor_logos/wwcsupply.png';
        break;
      default:
        // For unknown vendors, try to create a logo URL or use a default
        logoPath = 'assets/vendor_logos/default_vendor.png';
        break;
    }

    return Image.asset(
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
    );
  }

  Widget _buildFloatingComparisonBar() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange,
              Colors.orange.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ComparisonScreen(),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.compare_arrows,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Compare Products',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$comparisonCount product${comparisonCount > 1 ? 's' : ''} ready to compare',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    comparisonCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
