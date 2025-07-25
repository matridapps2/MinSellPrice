import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:minsellprice/InAppBrowser.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/app.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/model/product_details_model.dart';
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/screens/comparison_screen/comparison_screen.dart';
import 'package:minsellprice/screens/dashboard_screen/dashboard_screen.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/service_new/comparison_db.dart';
import 'package:minsellprice/service_new/liked_preference_db.dart';
import 'package:minsellprice/services/notification_service.dart';

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
  List<VendorProductData> vendorProductData = [];

  bool isLiked = false;
  bool isInComparison = false;
  int comparisonCount = 0;
  int vendorId = AppInfo.kVendorId;

  // Price alert state variables
  bool _isSubscribedToPriceAlert = false;
  bool _isLoadingPriceAlert = false;
  double _priceThreshold = 0;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall() async {
    log('_initCall started');
    await _fetchProductDetails();
    await _fetchBrandProducts();
    await _checkIfLiked();
    await _checkIfInComparison();
    await _checkPriceAlertStatus();
  }

  Future<void> _checkIfLiked() async {
    try {
      int? actualVendorProductId;
      if (vendorProductData.isNotEmpty) {
        final currentProduct = vendorProductData.firstWhere(
          (product) => product.productId == widget.productId,
          orElse: () => vendorProductData.first,
        );
        actualVendorProductId = currentProduct.vendorProductId;
      }

      actualVendorProductId ??= int.parse('$vendorId${widget.productId}');

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

  Future<void> _checkPriceAlertStatus() async {
    try {
      // Get the real current price from API data
      double currentPrice = widget.productPrice;

      // If we have vendor product data, use the first vendor's price as current price
      if (vendorProductData.isNotEmpty) {
        final firstVendor = vendorProductData.first;
        if (firstVendor.vendorpricePrice != null &&
            firstVendor.vendorpricePrice!.isNotEmpty) {
          currentPrice = double.tryParse(firstVendor.vendorpricePrice!) ??
              widget.productPrice;
        }
      }

      // Initialize price threshold (10% below current real price)
      _priceThreshold = (currentPrice * 0.9);

      // Check if user is already subscribed to price alerts for this product
      final isSubscribed = await NotificationService()
          .isSubscribedToProduct(widget.productId.toString());

      if (mounted) {
        setState(() {
          _isSubscribedToPriceAlert = isSubscribed;
        });
      }
    } catch (e) {
      log('Error checking price alert status: $e');
    }
  }

  Future<void> _showPriceThresholdDialog() async {
    double threshold = _priceThreshold;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Price Alert'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Get notified when ${widget.brandName} drops below:'),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price Threshold',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  threshold = double.tryParse(value) ?? _priceThreshold;
                },
                controller: TextEditingController(
                  text: threshold.toStringAsFixed(2),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _subscribeToPriceAlert(threshold);
              },
              child: const Text('Set Alert'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _subscribeToPriceAlert(double threshold) async {
    setState(() {
      _isLoadingPriceAlert = true;
    });

    try {
      // Get the real current price from API data
      double currentPrice = widget.productPrice;

      // If we have vendor product data, use the first vendor's price as current price
      if (vendorProductData.isNotEmpty) {
        final firstVendor = vendorProductData.first;
        if (firstVendor.vendorpricePrice != null &&
            firstVendor.vendorpricePrice!.isNotEmpty) {
          currentPrice = double.tryParse(firstVendor.vendorpricePrice!) ??
              widget.productPrice;
        }
      }

      final success = await NotificationService().subscribeToPriceAlert(
        productId: widget.productId.toString(),
        priceThreshold: threshold,
        currentPrice: currentPrice,
        // Pass real current price
        productName: widget.brandName,
        productImage: widget.productImage?.toString() ?? '',
        productMpn: widget.productMPN,
      );

      if (success) {
        setState(() {
          _isSubscribedToPriceAlert = true;
          _priceThreshold = threshold;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Price alert set for \$${threshold.toStringAsFixed(2)}'),
                ],
              ),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to set price alert. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log('Error subscribing to price alert: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error setting price alert. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPriceAlert = false;
        });
      }
    }
  }

  Future<void> _unsubscribeFromPriceAlert() async {
    setState(() {
      _isLoadingPriceAlert = true;
    });

    try {
      final success = await NotificationService().unsubscribeFromPriceAlert(
        productId: widget.productId.toString(),
      );

      if (success) {
        setState(() {
          _isSubscribedToPriceAlert = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Price alert removed'),
                ],
              ),
              backgroundColor: Colors.grey,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to remove price alert. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log('Error unsubscribing from price alert: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error removing price alert. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPriceAlert = false;
        });
      }
    }
  }

  Future<void> _checkIfInComparison() async {
    try {
      int? actualVendorProductId;
      if (vendorProductData.isNotEmpty) {
        final currentProduct = vendorProductData.firstWhere(
          (product) => product.productId == widget.productId,
          orElse: () => vendorProductData.first,
        );
        actualVendorProductId = currentProduct.vendorProductId;
      }

      actualVendorProductId ??= int.parse('$vendorId${widget.productId}');

      final isProductInComparison = await ComparisonDB.isInComparison(
        vendorProductId: actualVendorProductId,
      );

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
      int? actualVendorProductId;
      if (vendorProductData.isNotEmpty) {
        final currentProduct = vendorProductData.firstWhere(
          (product) => product.productId == widget.productId,
          orElse: () => vendorProductData.first,
        );
        actualVendorProductId = currentProduct.vendorProductId;
      }

      actualVendorProductId ??= int.parse('$vendorId${widget.productId}');

      final nowInComparison = await ComparisonDB.toggleComparison(
        productId: widget.productId,
        vendorProductId: actualVendorProductId,
        productName: productDetails?.data?.productName ?? 'Unknown Product',
        productImage: widget.productImage?.toString() ?? '',
        brandName: widget.brandName,
        productMpn: widget.productMPN,
        productPrice: widget.productPrice?.toString() ?? '0',
      );

      if (mounted) {
        setState(() {
          isInComparison = nowInComparison;
        });
      }

      await _checkIfInComparison();

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
      int? actualVendorProductId;
      if (vendorProductData.isNotEmpty) {
        final currentProduct = vendorProductData.firstWhere(
          (product) => product.productId == widget.productId,
          orElse: () => vendorProductData.first,
        );
        actualVendorProductId = currentProduct.vendorProductId;
      }

      actualVendorProductId ??= int.parse('$vendorId${widget.productId}');

      final nowLiked = await LikedPreferencesDB.toggleLikeProduct(
        productId: widget.productId,
        vendorProductId: actualVendorProductId,
        productName: productDetails?.data?.productName ?? 'Unknown Product',
        productImage: widget.productImage?.toString() ?? '',
        brandName: widget.brandName,
        productMpn: widget.productMPN,
        productPrice: widget.productPrice?.toString() ?? '0',
      );

      if (mounted) {
        setState(() {
          isLiked = nowLiked;
        });
      }

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

      final details = await BrandsApi.getProductDetails(
          brandName: widget.brandName,
          productMPN: widget.productMPN,
          productId: widget.productId,
          context: context);

      if (mounted) {
        setState(() {
          productDetails = details;
          vendorProductData = details.vendorProductData ?? [];
        });
        log('Single API Data is');
        log('${productDetails?.toJson()}');
        log('Vendor Product Data count: ${vendorProductData.length}');
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

        final allProductsResponse = await BrandsApi.getProductListByBrandName(
            widget.brandName.toString(), pageNumber, context);
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

      // List<String> uniqueVendorsLocal = getUniqueBrands(limitedProducts);
      // uniqueVendorsLocal =
      //     uniqueVendorsLocal.where((element1) => element1 != '--').toList();
      // List<String> tempList = [];
      // for (final vendor in uniqueVendorsLocal) {
      //   tempList.add(
      //       '$vendor Total Product(s): ${limitedProducts.where((element) => element.vendorName == vendor).toList().length} ');
      // }

      if (mounted) {
        setState(() {
          brandProducts = limitedProducts;
          // uniqueVendors = tempList;
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
      bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom != 0.0
          ? const SizedBox()
          : Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
            ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshProductDetails,
            child: _buildBody(),
          ),
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
          _buyAtName(),
          const SizedBox(height: 16),
          _buyAtDesign(),
          const SizedBox(height: 24),
          // const SizedBox(height: 16),
          // _buildProductDetails(),
          // const SizedBox(height: 16),
          // _buildPriceAndRating(),
          const SizedBox(height: 16),
          _buildSubscribeButton(),
          const SizedBox(height: 24),
          _buildSpecifications(),
          const SizedBox(height: 16),
          _buildProductActionsBar(),
          //_buildShippingInfo(),
          //  const SizedBox(height: 16),
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(data.productName ?? 'Product Name Not Available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 0),
        Container(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Row(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Brand: ${data.brandName ?? widget.brandName}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'ID: #${data.productSku ?? widget.productMPN}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Spacer(),
            Column(
              children: [
                _buildProductDetails(),
              ],
            )
          ]),
        ),
      ],
    );
  }

  Widget _buildProductImages() {
    final apiImages = productDetails!.data!.images;
    final fallbackImage = widget.productImage;

    if (apiImages != null && apiImages.isNotEmpty) {
      return Column(
        children: [
          // Main image carousel
          Container(
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: PageView.builder(
              itemCount: apiImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Main product image
                        Image.network(
                          apiImages[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Image not available',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // Zoom button overlay
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                _showImageFullScreen(apiImages[index]);
                              },
                            ),
                          ),
                        ),
                        // Image counter overlay
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${index + 1}/${apiImages.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Image indicators
          if (apiImages.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                apiImages.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == 0 ? AppColors.primary : Colors.grey[300],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          // Thumbnail strip
          if (apiImages.length > 1)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: apiImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: index == 0
                                ? AppColors.primary
                                : Colors.grey[300]!,
                            width: index == 0 ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.network(
                          apiImages[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey[400],
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    }

    if (fallbackImage != null && fallbackImage.toString().isNotEmpty) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.network(
                fallbackImage,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Image not available',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Zoom button overlay
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      _showImageFullScreen(fallbackImage);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No image available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Product image will appear here',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageFullScreen(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Image not available',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
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
          onTap: _isLoadingPriceAlert
              ? null
              : (_isSubscribedToPriceAlert
                  ? _unsubscribeFromPriceAlert
                  : _showPriceThresholdDialog),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoadingPriceAlert)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isSubscribedToPriceAlert
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isSubscribedToPriceAlert
                          ? 'Price Alert Active'
                          : 'Get Price Alerts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isSubscribedToPriceAlert
                          ? 'Alert set for \$${_priceThreshold.toStringAsFixed(2)}'
                          : 'Subscribe for price drops',
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
                  child: Icon(
                    _isSubscribedToPriceAlert ? Icons.remove : Icons.add,
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
          // _buildActionButton(
          //   icon: Icons.share,
          //   label: 'Share',
          //   color: Colors.blue,
          //   onTap: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(
          //         content: Row(
          //           children: [
          //             Icon(Icons.share, color: Colors.white),
          //             SizedBox(width: 8),
          //             Text('Product shared successfully!'),
          //           ],
          //         ),
          //         backgroundColor: Colors.blue,
          //         duration: Duration(seconds: 1),
          //         behavior: SnackBarBehavior.floating,
          //       ),
          //     );
          //   },
          // ),
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
                              fit: BoxFit.fill,
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
    return Row(
      children: [
        Text(
          'Buy At:',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buyAtDesign() {
    log('_buyAtDesign called with ${vendorProductData.length} vendor products');

    if (vendorProductData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No vendor data available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Vendor pricing information will appear here when available.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: Row(
            children: vendorProductData.map((product) {
              log('Rendering vendor: ${product.vendorName} with price: ${product.vendorpricePrice}');
              return Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () async {
                      log('Selected vendor: ${product.vendorName}');
                      await MyInAppBrowser().openUrlRequest(
                        urlRequest: URLRequest(
                          url: WebUri(
                            '${product.vendorUrl}',
                          ),
                        ),
                      );
                      log('vendor URL: ${product.vendorUrl}');
                    },
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
                                  Icons.local_shipping_outlined,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: _buildShippingText(
                                      product.vendorpriceShipping),
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

  Widget _buildShippingText(String? shippingValue) {
    bool isFree = false;
    if (shippingValue != null) {
      final doubleValue = double.tryParse(shippingValue);
      isFree = doubleValue == 0.0;
    }

    if (isFree) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'FREE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      );
    } else {
      return Text(
        '\$${shippingValue ?? '--'}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _buildVendorLogo(String vendorName) {
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
