import 'dart:convert';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/screens/home_page/home_page.dart';
import 'package:minsellprice/screens/product_details_screen/product_details_screen.dart';
import 'package:minsellprice/widgets/stylish_loader.dart';

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
  bool _isUserActivelyScrolling = false; // Track if user is actively scrolling
  bool _hasUserSeenLastProduct =
      false; // Track if user has seen the last product
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();

  final FocusNode _focusNode = FocusNode();

  final TextEditingController iconController = TextEditingController();

  int? priceSorting;
  int currentApiPage = 1;
  int totalProductCount = 0;

  bool currentInStockOnly = false;
  bool currentOnSaleOnly = false;
  bool hasMoreData = true;
  bool filterSubmitted = true;
  bool _isLoading = false;
  bool _isError = false;
  bool _isLoadingMore =
      false; // Flag to prevent multiple simultaneous load more calls
  DateTime? _lastLoadMoreTime; // Track when we last loaded more products

  // Unlimited product storage (no memory limits)
  List<VendorProduct> allProducts = [];
  List<String> filterVendor = [];
  List<String> uniqueVendors = [];
  List<VendorProduct> brandProducts = [];
  List<VendorProduct> tempProductList = [];

  RangeValues currentPriceRange = const RangeValues(0, 1000);

  double maxPriceFromAPI = 1000.0;

  @override
  void initState() {
    super.initState();
    _initCall();
    _addScrollListener();
  }

  // Store scroll listener reference for proper disposal
  late final VoidCallback _scrollListener;

  void _addScrollListener() {
    _scrollListener = () {
      if (_scrollController.position.userScrollDirection !=
          ScrollDirection.idle) {
        _hasUserScrolled = true; // User scrolled at least once
        _isUserActivelyScrolling = true; // User is actively scrolling

        // Reset active scrolling flag after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          _isUserActivelyScrolling = false;
        });
      }

      // Check if user has seen the last product
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 20) {
        _hasUserSeenLastProduct = true;
        log('Scroll detection: User has seen last product');
      }

      // Only trigger API call when user is at the VERY bottom AND has seen the last product
      if (_hasUserScrolled &&
          _isUserActivelyScrolling &&
          _hasUserSeenLastProduct &&
          hasMoreData &&
          !_isLoadingMore &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 10) {
        // Very strict threshold
        log('Scroll detection: User at very bottom and has seen last product - triggering API call');
        _loadMoreProducts();
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

    super.dispose();
  }

  void _initCall() async {
    log('Brand Name: ${widget.brandName}');
    await _fetchBrandProducts().whenComplete(() async {});
  }

  Future<void> _fetchBrandProducts() async {
    setState(() => _isLoading = true);
    try {
      final allProductsResponse = await BrandsApi.getProductListByBrandName(
          widget.brandName.toString(), currentApiPage, context);

      final Map<String, dynamic> decoded =
          jsonDecode(allProductsResponse ?? '{}');

      final List<dynamic> jsonList = decoded['brand_product'] ?? [];
      final List<VendorProduct> fetchedProducts =
          jsonList.map((e) => VendorProduct.fromJson(e)).toList();

      // Get total product count from API response
      totalProductCount = decoded['productCount'] ?? 0;
      // totalPages = (totalProductCount / itemsPerPage).ceil(); // Removed as per edit

      log('Total products from API: $totalProductCount');
      log('Total pages calculated: 0'); // Modified as per edit

      // Add fetched products to allProducts list
      allProducts.addAll(fetchedProducts);

      // Check if we have more data to load
      hasMoreData =
          allProducts.length < totalProductCount && fetchedProducts.isNotEmpty;

      // If no more products were fetched, we're done
      if (fetchedProducts.isEmpty) {
        hasMoreData = false;
      }

      log('_fetchBrandProducts: Initial load - products: ${fetchedProducts.length}, total: $totalProductCount, hasMoreData: $hasMoreData');

      double calculatedMaxPrice = 1000.0;
      if (allProducts.isNotEmpty) {
        final validPrices = allProducts
            .map((product) => double.tryParse(product.vendorpricePrice))
            .where((price) => price != null && price > 0)
            .cast<double>()
            .toList();

        if (validPrices.isNotEmpty) {
          calculatedMaxPrice = validPrices.reduce((a, b) => a > b ? a : b);
          calculatedMaxPrice =
              ((calculatedMaxPrice / 50).ceil() * 50).toDouble();
        }
      }

      setState(() {
        brandProducts = List.from(allProducts);
        tempProductList = List.from(allProducts);
        maxPriceFromAPI = calculatedMaxPrice;

        if (currentPriceRange.end == 1000.0) {
          currentPriceRange = RangeValues(0, maxPriceFromAPI);
        }

        filterVendor = [];
        priceSorting = null;
        _isLoading = false;
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
      log('Error in fetching Brand Product list: $e');
    }
  }

  Future<void> _loadMoreProducts() async {
    if (!hasMoreData || _isLoadingMore) {
      log('_loadMoreProducts: Skipping - hasMoreData: $hasMoreData, _isLoadingMore: $_isLoadingMore');
      return;
    }

    // Additional safety check: ensure we haven't already loaded all products
    if (allProducts.length >= totalProductCount) {
      log('_loadMoreProducts: All products already loaded - current: ${allProducts.length}, total: $totalProductCount');
      hasMoreData = false;
      return;
    }

    // More strict rate limiting to prevent API spam
    final now = DateTime.now();
    if (_lastLoadMoreTime != null &&
        now.difference(_lastLoadMoreTime!) <
            const Duration(milliseconds: 1000)) {
      // Increased to 1 second
      log('_loadMoreProducts: Rate limiting - waiting for cooldown');
      return;
    }

    // Additional check: ensure user is actually at the bottom
    if (!_isUserActivelyScrolling) {
      log('_loadMoreProducts: Skipping - user not actively scrolling');
      return;
    }

    // Additional check: ensure user has seen the last product
    if (!_hasUserSeenLastProduct) {
      log('_loadMoreProducts: Skipping - user has not seen the last product yet');
      return;
    }

    log('_loadMoreProducts: Starting to load more products - current count: ${allProducts.length}, total available: $totalProductCount, page: $currentApiPage');
    setState(() => _isLoadingMore = true);

    try {
      currentApiPage++;
      log('Loading page $currentApiPage');

      final allProductsResponse = await BrandsApi.getProductListByBrandName(
          widget.brandName.toString(), currentApiPage, context);
      final Map<String, dynamic> decoded =
          jsonDecode(allProductsResponse ?? '{}');

      final List<dynamic> jsonList = decoded['brand_product'] ?? [];
      final List<VendorProduct> fetchedProducts =
          jsonList.map((e) => VendorProduct.fromJson(e)).toList();

      // Add new products to the list
      allProducts.addAll(fetchedProducts);

      // Check if we have more data to load
      hasMoreData =
          allProducts.length < totalProductCount && fetchedProducts.isNotEmpty;

      // If no more products were fetched, we're done
      if (fetchedProducts.isEmpty) {
        hasMoreData = false;
        log('_loadMoreProducts: No more products fetched, setting hasMoreData to false');
      }

      // Additional check: if we received fewer products than expected, we might be at the last page
      if (fetchedProducts.length < 100 && hasMoreData) {
        log('_loadMoreProducts: Received ${fetchedProducts.length} products (less than 100), might be at last page');

        // If we received very few products, we're likely at the last page
        if (fetchedProducts.length < 50) {
          hasMoreData = false;
          log('_loadMoreProducts: Set hasMoreData to false - likely at last page');
        }
      }

      log('_loadMoreProducts: Loaded ${fetchedProducts.length} new products. Total now: ${allProducts.length}, hasMoreData: $hasMoreData, totalProductCount: $totalProductCount');

      // Reset cooldown after successful load
      _lastLoadMoreTime = DateTime.now();

      // Single setState call to update everything at once
      setState(() {
        brandProducts = List.from(allProducts);
        tempProductList = List.from(allProducts);
        _isLoadingMore = false;
      });

      // Reset the "seen last product" flag since new products were loaded
      _hasUserSeenLastProduct = false;
      log('_loadMoreProducts: Reset _hasUserSeenLastProduct flag');

      // Simple scroll position maintenance - no complex animations
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && mounted) {
          // Just maintain the user's current view position
          // No jumping or complex calculations
          log('Products loaded - maintaining scroll position');
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      log('Error loading more products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _focusNode.unfocus();
        },
        child: _isLoading
            ? Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  toolbarHeight: 80,
                  automaticallyImplyLeading: false,
                  centerTitle: false,
                  title: Visibility(
                    visible: !_isLoading,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: SizedBox(
                        width: w * .54,
                        child: AutoSizeText(
                          '${widget.brandName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: w * .04),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    Visibility(
                      visible: !_isLoading,
                      child: GestureDetector(
                        onTap: () {
                          log('Working');
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => const HomePage()),
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
                    ),
                  ],
                ),
                body: Center(
                  child: StylishLoader(
                    type: LoaderType.wave,
                    size: 80.0,
                    primaryColor: AppColors.primary,
                    text: "Loading ${widget.brandName} products...",
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ))
            : _isError
                ? Scaffold(
                    appBar: AppBar(
                      surfaceTintColor: Colors.white,
                      toolbarHeight: .18 * w,
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
                            log('Working');
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()),
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
                    ),
                    body: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: 'No Product(s) found.\n',
                            style: TextStyle(
                                fontSize: .06 * w,
                                fontFamily: 'Futura BdCn BT Bold',
                                fontWeight: FontWeight.w300,
                                color: Colors.black),
                            children: [
                              TextSpan(
                                text: 'Return Back',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.pop(context),
                                style: TextStyle(
                                    fontSize: .06 * w,
                                    fontFamily: 'Futura BdCn BT Bold',
                                    fontWeight: FontWeight.w300,
                                    color: AppColors.primary),
                              )
                            ]),
                      ),
                    ),
                  )
                : Scaffold(
                    key: _scaffoldKey,
                    appBar: AppBar(
                      surfaceTintColor: Colors.white,
                      toolbarHeight: .18 * w,
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
                            log('Working');
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()),
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
                    ),
                    body: Stack(
                      children: [
                        SafeArea(
                          bottom: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Visibility(
                                visible: totalProductCount > 0,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Row(
                                    children: [
                                      // Filters Icon Button
                                      // Container(
                                      //   decoration: BoxDecoration(
                                      //     color: AppColors.primary,
                                      //     borderRadius:
                                      //         BorderRadius.circular(12),
                                      //     boxShadow: [
                                      //       BoxShadow(
                                      //         color: AppColors.primary
                                      //             .withOpacity(0.3),
                                      //         spreadRadius: 1,
                                      //         blurRadius: 4,
                                      //         offset: const Offset(0, 2),
                                      //       ),
                                      //     ],
                                      //   ),
                                      //   child: Material(
                                      //     color: Colors.transparent,
                                      //     child: InkWell(
                                      //       borderRadius:
                                      //           BorderRadius.circular(12),
                                      //       onTap: () {
                                      //         // _scaffoldKey.currentState!
                                      //         //     .openEndDrawer();
                                      //       },
                                      //       child: Container(
                                      //         padding: const EdgeInsets.all(12),
                                      //         // child: Icon(
                                      //         //   Icons.filter_alt,
                                      //         //   color: Colors.white,
                                      //         //   size: w * .05,
                                      //         // ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      const SizedBox(width: 12),
                                      // Product Count Badge
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.grey[200]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Total Products',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: w * .045,
                                                        fontFamily: 'Segoe UI',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      '$totalProductCount items available',
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.primary,
                                                        fontSize: w * .039,
                                                        fontFamily: 'Segoe UI',
                                                        fontWeight:
                                                            FontWeight.bold,
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
                              ),
                              const SizedBox(height: 5),
                              allProducts.isEmpty
                                  ? Flexible(
                                      child: Container(
                                        width: w,
                                        height: h / 1.1,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Illustration/Icon
                                            Container(
                                              width: w * 0.3,
                                              height: w * 0.3,
                                              decoration: BoxDecoration(
                                                color: AppColors.background,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.1),
                                                    spreadRadius: 2,
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.search_off_rounded,
                                                size: w * 0.15,
                                                color: AppColors.primary
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                            SizedBox(height: h * 0.03),

                                            // Main Title
                                            Text(
                                              'No Products Found',
                                              style: TextStyle(
                                                fontSize: w * 0.06,
                                                fontFamily:
                                                    'Futura BdCn BT Bold',
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.text,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: h * 0.015),

                                            // Subtitle
                                            Text(
                                              'We couldn\'t find any products for this brand.\nPlease try a different search or browse other categories.',
                                              style: TextStyle(
                                                fontSize: w * 0.035,
                                                fontFamily:
                                                    'Futura BdCn BT Bold',
                                                fontWeight: FontWeight.w300,
                                                color: Colors.grey[600],
                                                height: 1.4,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: h * 0.04),

                                            // Action Button
                                            GestureDetector(
                                              onTap: () =>
                                                  Navigator.pop(context),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: w * 0.06,
                                                  vertical: h * 0.018,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.primary
                                                          .withOpacity(0.3),
                                                      spreadRadius: 1,
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .arrow_back_ios_rounded,
                                                      size: w * 0.035,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: w * 0.015),
                                                    Text(
                                                      'Go Back',
                                                      style: TextStyle(
                                                        fontSize: w * 0.035,
                                                        fontFamily:
                                                            'Futura BdCn BT Bold',
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                    )
                                  : allProducts.isNotEmpty
                                      ? Expanded(
                                          child: Align(
                                            alignment: Alignment.topCenter,
                                            child: Scrollbar(
                                              thickness: 4,
                                              thumbVisibility: true,
                                              trackVisibility: true,
                                              interactive: true,
                                              controller: _scrollController,
                                              child: NotificationListener<
                                                  ScrollNotification>(
                                                onNotification: (notification) {
                                                  if (notification
                                                          is ScrollUpdateNotification &&
                                                      notification
                                                              .metrics.axis ==
                                                          Axis.vertical) {
                                                    final bool isUserDrag =
                                                        notification
                                                                .dragDetails !=
                                                            null;

                                                    // Check if user has seen the last product
                                                    if (notification
                                                            .metrics.pixels >=
                                                        notification.metrics
                                                                .maxScrollExtent -
                                                            20) {
                                                      _hasUserSeenLastProduct =
                                                          true;
                                                    }

                                                    if (isUserDrag &&
                                                        _isUserActivelyScrolling &&
                                                        _hasUserSeenLastProduct &&
                                                        hasMoreData &&
                                                        !_isLoadingMore &&
                                                        notification.metrics
                                                                .pixels >=
                                                            notification.metrics
                                                                    .maxScrollExtent -
                                                                10) {
                                                      // Very strict threshold
                                                      log('NotificationListener: User at very bottom and has seen last product - triggering API call');
                                                      _loadMoreProducts();
                                                    }
                                                  }
                                                  return false; // allow other listeners to receive notifications
                                                },
                                                child: SingleChildScrollView(
                                                  controller: _scrollController,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10.0),
                                                    child: Wrap(
                                                      runSpacing: 10,
                                                      children: List.generate(
                                                        allProducts.length,
                                                        (index) => Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4.0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => ProductDetailsScreen(
                                                                        productId:
                                                                            allProducts[index]
                                                                                .productId,
                                                                        brandName:
                                                                            widget.brandName ??
                                                                                'Unknown Brand',
                                                                        productMPN:
                                                                            allProducts[index]
                                                                                .productMpn,
                                                                        productImage:
                                                                            allProducts[index]
                                                                                .productImage,
                                                                        productPrice:
                                                                            allProducts[index].vendorpricePrice)),
                                                              );
                                                            },
                                                            child: Container(
                                                              width: w * .45,
                                                              // height: h * .48,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.1),
                                                                    spreadRadius:
                                                                        2,
                                                                    blurRadius:
                                                                        8,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            4),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    width: double
                                                                        .infinity,
                                                                    height:
                                                                        w * .45,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        topLeft:
                                                                            Radius.circular(16),
                                                                        topRight:
                                                                            Radius.circular(16),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .only(
                                                                        topLeft:
                                                                            Radius.circular(0),
                                                                        topRight:
                                                                            Radius.circular(0),
                                                                      ),
                                                                      child: Image
                                                                          .network(
                                                                        _getProperImageUrl(
                                                                            allProducts[index].productImage),
                                                                        fit: BoxFit
                                                                            .contain,
                                                                        // Memory-efficient image loading
                                                                        cacheWidth: (w *
                                                                                .45 *
                                                                                MediaQuery.of(context).devicePixelRatio)
                                                                            .round(),
                                                                        cacheHeight: (w *
                                                                                .45 *
                                                                                MediaQuery.of(context).devicePixelRatio)
                                                                            .round(),
                                                                        errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) {
                                                                          return Container(
                                                                            color:
                                                                                Colors.grey[200],
                                                                            child:
                                                                                Icon(
                                                                              Icons.image_not_supported_outlined,
                                                                              size: w * .08,
                                                                              color: Colors.grey[400],
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),

                                                                  // Product Details
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            16),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        // Product Name
                                                                        SizedBox(
                                                                          height:
                                                                              w * .25,
                                                                          child:
                                                                              Text(
                                                                            allProducts[index].productName.isEmpty
                                                                                ? 'Product Name Not Available'
                                                                                : allProducts[index].productName,
                                                                            maxLines:
                                                                                4,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.grey[800],
                                                                              fontFamily: 'Segoe UI',
                                                                              fontSize: 18,
                                                                              height: 1.2,
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                0),
                                                                        // MPN
                                                                        SizedBox(
                                                                          height:
                                                                              h * .06,
                                                                          child:
                                                                              Text(
                                                                            'MPN: #${allProducts[index].productMpn}',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontFamily: 'Segoe UI',
                                                                              fontSize: 16,
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            maxLines:
                                                                                2,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                13),
                                                                        // Price Section
                                                                        Container(
                                                                          //height: h * .09,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                          ),
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              // Price Row
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    '\$${allProducts[index].vendorpricePrice}',
                                                                                    style: const TextStyle(
                                                                                      color: Colors.black,
                                                                                      fontFamily: 'Segoe UI',
                                                                                      fontSize: 20,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              const SizedBox(height: 10),
                                                                              // Vendor Count Row
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                                                        Icon(
                                                                                          Icons.storefront_outlined,
                                                                                          color: Colors.white,
                                                                                          size: 18,
                                                                                        ),
                                                                                        const SizedBox(width: 2),
                                                                                        Text(
                                                                                          '${allProducts[index].vendorIdCount}',
                                                                                          style: TextStyle(
                                                                                            color: Colors.white,
                                                                                            fontSize: 19,
                                                                                            fontWeight: FontWeight.w500,
                                                                                          ),
                                                                                        ),
                                                                                        const SizedBox(width: 2),
                                                                                        Text(
                                                                                          'vendors',
                                                                                          style: TextStyle(
                                                                                            color: Colors.white.withOpacity(0.9),
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
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                              const SizedBox(height: 10),
                              // Loading indicator for more products
                              if (_isLoadingMore && allProducts.isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: const Center(
                                    child: Column(
                                      children: [
                                        CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              // Show scroll progress indicator - removed due to linter issues
                              // Show "No more products" message when all products are loaded
                            ],
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Builder(
                            builder: (BuildContext context) {
                              final MediaQueryData mediaQuery =
                                  MediaQuery.of(context);
                              final double bottomPadding =
                                  mediaQuery.padding.bottom;
                              if (bottomPadding > 0) {
                                return Container(
                                  height: bottomPadding,
                                  color: Colors.blueGrey,
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ));
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
}
