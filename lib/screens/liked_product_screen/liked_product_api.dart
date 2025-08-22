import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/constants.dart';
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/screens/loging_page/loging_page.dart';
import 'package:minsellprice/screens/product_details_screen/product_details_screen.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/screens/register_page/register_page.dart';
import 'package:minsellprice/service_new/filter_preferences_db.dart';
import 'package:minsellprice/widgets/stylish_loader.dart';

class LikedProductScreen extends StatefulWidget {
  const LikedProductScreen({
    super.key,
  });

  @override
  State<LikedProductScreen> createState() => _LikedProductScreen();
}

class _LikedProductScreen extends State<LikedProductScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();

  final FocusNode _focusNode = FocusNode();

  final TextEditingController iconController = TextEditingController();

  int? priceSorting;
  int currentPage = 0;
  int itemsPerPage = 20;
  int endIndex = 0;
  int startIndex = 0;

  // New variables for API pagination
  int totalProductCount = 0;
  int totalPages = 0;
  int currentApiPage = 1;

  bool hasMoreData = true;
  bool filterSubmitted = true;
  bool _isLoading = false;
  bool _isError = false;
  bool isLoggedIn = false;
  bool _isCheckingAuth = true; // Track if we're still checking auth state
  bool _hasInitialDataLoaded = false; // Track if initial data has been loaded
  Set<int> _unlikingProducts = {}; // Track products being unliked

  List<String> filterVendor = [];
  List<VendorProduct> allProducts = [];
  List<VendorProduct> tempProductList = [];
  List<VendorProduct> finalList = [];

  RangeValues currentPriceRange = const RangeValues(0, 1000);
  bool currentInStockOnly = false;
  bool currentOnSaleOnly = false;
  double maxPriceFromAPI = 1000.0;

  String emailId = '';

  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    // Check current Firebase Auth state immediately
    _checkCurrentAuthState();

    // Listen to Firebase Auth state changes
    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        if (user != null && user.email != null) {
          setState(() {
            isLoggedIn = true;
            emailId = user.email!;
            _isCheckingAuth = false;
          });
          log('Liked User Logged ? $emailId');
          // Only fetch products if this is a new login (not the initial check)
          if (!_hasInitialDataLoaded) {
            _fetchBrandProducts(user.email!);
            _hasInitialDataLoaded = true;
          }
        } else {
          setState(() {
            isLoggedIn = false;
            emailId = '';
            _isCheckingAuth = false;
            _hasInitialDataLoaded = false; // Reset flag when user logs out
          });
          log('Liked User NOT Logged ? $emailId');
        }
      }
    });
  }

  /// Check current Firebase Auth state immediately without waiting for listener
  void _checkCurrentAuthState() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.email != null) {
      setState(() {
        isLoggedIn = true;
        emailId = currentUser.email!;
        _isCheckingAuth = false;
      });
      log('Initial auth check - User already logged in: $emailId');
      _fetchBrandProducts(currentUser.email!);
      _hasInitialDataLoaded = true; // Mark that initial data has been loaded
    } else {
      setState(() {
        isLoggedIn = false;
        emailId = '';
        _isCheckingAuth = false;
        _isLoading = false; // Ensure loading is false
        _isError = false;
      });
      log('Initial auth check - No user logged in');
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchBrandProducts(String emailId) async {
    setState(() {
      _isLoading = true;
      allProducts = [];
      tempProductList = [];
      finalList = [];
    });

    try {
      final allProductsResponse =
          await BrandsApi.getLikedProduct(emailId: emailId, context: context);
      final Map<String, dynamic> decoded =
          jsonDecode(allProductsResponse ?? '{}');

      final List<dynamic> jsonList = decoded['brand_product'] ?? [];
      final List<VendorProduct> fetchedProducts =
          jsonList.map((e) => VendorProduct.fromJson(e)).toList();

      // Get total product count from API response
      totalProductCount = decoded['productCount'] ?? 0;
      totalPages = (totalProductCount / itemsPerPage).ceil();

      log('Total products from API: $totalProductCount');
      log('Total pages calculated: $totalPages');

      // Add fetched products to allProducts list
      allProducts.addAll(fetchedProducts);

      // Check if we have more data to load
      hasMoreData = allProducts.length < totalProductCount;

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
        tempProductList = List.from(allProducts);
        maxPriceFromAPI = calculatedMaxPrice;

        if (currentPriceRange.end == 1000.0) {
          currentPriceRange = RangeValues(0, maxPriceFromAPI);
        }

        // Calculate current page display
        _updateCurrentPageDisplay();

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

  void _updateCurrentPageDisplay() {
    startIndex = currentPage * itemsPerPage;
    endIndex = (startIndex + itemsPerPage > tempProductList.length)
        ? tempProductList.length
        : startIndex + itemsPerPage;
    finalList = tempProductList.sublist(startIndex, endIndex);
  }

  /// Unlike a product by calling the saveLikedProduct API with status=0
  Future<void> _unlikeProduct(int productId) async {
    try {
      if (emailId.isEmpty) {
        log('No email ID available for unlike operation');
        return;
      }

      // Add to unliking set to show loading state
      setState(() {
        _unlikingProducts.add(productId);
      });

      log('Unliking product: $productId for user: $emailId');

      // Call the saveLikedProduct API with status=0 to unlike
      final apiResponse = await BrandsApi.saveLikedProduct(
        emailId: emailId,
        productId: productId,
        status: 0, // 0 = unlike
      );

      if (apiResponse != 'error' && apiResponse.isNotEmpty) {
        try {
          final jsonResponse = json.decode(apiResponse);
          if (jsonResponse['success'] == 1) {
            log('Product successfully unliked: $productId');

            // Remove the product from the local list
            setState(() {
              tempProductList
                  .removeWhere((product) => product.productId == productId);
              _updateCurrentPageDisplay();
            });
            // Refresh the product list to get updated count
            await _fetchBrandProducts(emailId);
          } else {
            log('API returned success: 0 for unlike operation');
            _showErrorSnackBar('Failed to remove product from favorites');
          }
        } catch (e) {
          log('Error parsing API response: $e');
          _showErrorSnackBar('Error processing server response');
        }
      } else {
        log('API call failed for unlike operation');
        _showErrorSnackBar('Failed to remove product from favorites');
      }
    } catch (e) {
      log('Error in _unlikeProduct: $e');
      _showErrorSnackBar('Error removing product from favorites');
    } finally {
      // Remove from unliking set to hide loading state
      if (mounted) {
        setState(() {
          _unlikingProducts.remove(productId);
        });
      }
    }
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _focusNode.unfocus();
        },
        child: _isCheckingAuth
            ? Scaffold(
                appBar: AppBar(),
                body: const Center(
                  child: StylishLoader(
                    type: LoaderType.wave,
                    size: 80.0,
                    primaryColor: AppColors.primary,
                    text: "Checking authentication...",
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ))
            : _isLoading
                ? Scaffold(
                    appBar: AppBar(),
                    body: const Center(
                      child: StylishLoader(
                        type: LoaderType.wave,
                        size: 80.0,
                        primaryColor: AppColors.primary,
                        text: "Loading products...",
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ))
                : _isError
                    ? Scaffold(
                        appBar: AppBar(),
                        body: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: 'API IS NOT WORKING\n',
                                style: TextStyle(
                                    fontSize: .06 * w,
                                    fontFamily: 'Futura BdCn BT Bold',
                                    fontWeight: FontWeight.w300,
                                    color: Colors.red),
                                children: [
                                  TextSpan(
                                    text: 'Return Back',
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
                    : !isLoggedIn
                        ? Constants.noLoginDesign(context, 'liked product')
                        : Scaffold(
                            key: _scaffoldKey,
                            body: Stack(
                              children: [
                                SafeArea(
                                  bottom: true,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.primary
                                                          .withOpacity(0.3),
                                                      spreadRadius: 1,
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    onTap: () {
                                                      _scaffoldKey.currentState!
                                                          .openEndDrawer();
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color: Colors.grey[200]!,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .primary
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Icon(
                                                          Icons
                                                              .shopping_bag_outlined,
                                                          color:
                                                              AppColors.primary,
                                                          size: w * .06,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Total Products',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[600],
                                                                fontSize:
                                                                    w * .045,
                                                                fontFamily:
                                                                    'Segoe UI',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            Text(
                                                              '$totalProductCount items available',
                                                              style: TextStyle(
                                                                color: AppColors
                                                                    .primary,
                                                                fontSize:
                                                                    w * .039,
                                                                fontFamily:
                                                                    'Segoe UI',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
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
                                      totalProductCount == 0
                                          ? const Flexible(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'No favourites yet!',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontFamily: 'Segoe UI',
                                                        fontSize: 21,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(height: 6),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12.0),
                                                    child: Text(
                                                      'Tap the heart icon on products you love to add them here',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontFamily: 'Segoe UI',
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : totalProductCount > 0
                                              ? Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Scrollbar(
                                                      thickness: 4,
                                                      thumbVisibility: true,
                                                      trackVisibility: true,
                                                      interactive: true,
                                                      controller:
                                                          _scrollController,
                                                      child:
                                                          SingleChildScrollView(
                                                        controller:
                                                            _scrollController,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10.0),
                                                          child: Wrap(
                                                            runSpacing: 10,
                                                            children:
                                                                List.generate(
                                                              finalList.length,
                                                              (index) =>
                                                                  Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4.0),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => ProductDetailsScreen(
                                                                              productId: finalList[index].productId,
                                                                              brandName: finalList[index].brandName,
                                                                              productMPN: finalList[index].productMpn,
                                                                              productImage: finalList[index].productImage,
                                                                              productPrice: finalList[index].vendorpricePrice)),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width:
                                                                        w * .45,
                                                                    // height: h * .48,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              16),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0.1),
                                                                          spreadRadius:
                                                                              2,
                                                                          blurRadius:
                                                                              8,
                                                                          offset: const Offset(
                                                                              0,
                                                                              4),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              double.infinity,
                                                                          height:
                                                                              w * .45,
                                                                          decoration:
                                                                              const BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.only(
                                                                              topLeft: Radius.circular(16),
                                                                              topRight: Radius.circular(16),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              ClipRRect(
                                                                            borderRadius:
                                                                                const BorderRadius.only(
                                                                              topLeft: Radius.circular(0),
                                                                              topRight: Radius.circular(0),
                                                                            ),
                                                                            child:
                                                                                Image.network(
                                                                              _getProperImageUrl(finalList[index].productImage),
                                                                              fit: BoxFit.contain,
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

                                                                        // Product Details
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              16),
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(12.0),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      finalList[index].productName,
                                                                                      style: const TextStyle(
                                                                                        fontSize: 18,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        color: Colors.black87,
                                                                                      ),
                                                                                      maxLines: 2,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                    const SizedBox(height: 4),
                                                                                    Text(
                                                                                      finalList[index].brandName,
                                                                                      style: TextStyle(
                                                                                        fontSize: 16,
                                                                                        color: Colors.grey[600],
                                                                                        fontWeight: FontWeight.w500,
                                                                                      ),
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                    SizedBox(height: 20),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Expanded(
                                                                                          child: Text(
                                                                                            finalList[index].vendorpricePrice,
                                                                                            style: const TextStyle(
                                                                                              fontSize: 16,
                                                                                              fontWeight: FontWeight.bold,
                                                                                              color: Colors.green,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        GestureDetector(
                                                                                          onTap: _unlikingProducts.contains(finalList[index].productId)
                                                                                              ? null // Disable tap when loading
                                                                                              : () async {
                                                                                                  await _unlikeProduct(finalList[index].productId);
                                                                                                },
                                                                                          child: Container(
                                                                                            padding: const EdgeInsets.all(3),
                                                                                            decoration: BoxDecoration(
                                                                                              color: _unlikingProducts.contains(finalList[index].productId) ? Colors.grey.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                                                                              borderRadius: BorderRadius.circular(20),
                                                                                            ),
                                                                                            child: _unlikingProducts.contains(finalList[index].productId)
                                                                                                ? SizedBox(
                                                                                                    width: 20,
                                                                                                    height: 20,
                                                                                                    child: CircularProgressIndicator(
                                                                                                      strokeWidth: 2,
                                                                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                                                                                    ),
                                                                                                  )
                                                                                                : const Icon(
                                                                                                    Icons.favorite,
                                                                                                    color: Colors.red,
                                                                                                    size: 20,
                                                                                                  ),
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
                                                )
                                              : const SizedBox(),
                                      //const SizedBox(height: 10),
                                      // Loading indicator for more products
                                      if (_isLoading && allProducts.isNotEmpty)
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          AppColors.primary),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  'Loading more products...',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: w * .035,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      // Pagination section - only show if there are multiple pages
                                      if (totalProductCount > itemsPerPage)
                                        Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.1),
                                                spreadRadius: 1,
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              // Page Counter
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.pageview,
                                                      size: 18,
                                                      color: AppColors.primary,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Page ${currentPage + 1} of $totalPages',
                                                      style: TextStyle(
                                                        fontSize: w * .04,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            AppColors.primary,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              // Navigation Buttons
                                              Row(
                                                children: [
                                                  // Previous Button
                                                  Expanded(
                                                    child: Container(
                                                      height: 48,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 8),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              currentPage == 0
                                                                  ? Colors
                                                                      .grey[200]
                                                                  : Colors
                                                                      .white,
                                                          foregroundColor:
                                                              currentPage == 0
                                                                  ? Colors
                                                                      .grey[500]
                                                                  : AppColors
                                                                      .primary,
                                                          side: BorderSide(
                                                            color: currentPage ==
                                                                    0
                                                                ? Colors
                                                                    .grey[300]!
                                                                : AppColors
                                                                    .primary,
                                                            width: 1.5,
                                                          ),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          elevation:
                                                              currentPage == 0
                                                                  ? 0
                                                                  : 2,
                                                        ),
                                                        onPressed:
                                                            currentPage == 0
                                                                ? null
                                                                : () {
                                                                    setState(
                                                                        () {
                                                                      currentPage--;
                                                                      _updateCurrentPageDisplay();
                                                                    });
                                                                  },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .arrow_back_ios,
                                                              size: 16,
                                                              color: currentPage ==
                                                                      0
                                                                  ? Colors
                                                                      .grey[500]
                                                                  : AppColors
                                                                      .primary,
                                                            ),
                                                            const SizedBox(
                                                                width: 6),
                                                            Text(
                                                              'Previous',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    w * .035,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Next Button
                                                  Expanded(
                                                    child: Container(
                                                      height: 48,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 8),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              (currentPage +
                                                                          1) >=
                                                                      totalPages
                                                                  ? Colors
                                                                      .grey[200]
                                                                  : AppColors
                                                                      .primary,
                                                          foregroundColor:
                                                              (currentPage +
                                                                          1) >=
                                                                      totalPages
                                                                  ? Colors
                                                                      .grey[500]
                                                                  : Colors
                                                                      .white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          elevation:
                                                              (currentPage +
                                                                          1) >=
                                                                      totalPages
                                                                  ? 0
                                                                  : 3,
                                                        ),
                                                        onPressed:
                                                            (currentPage + 1) >=
                                                                    totalPages
                                                                ? null
                                                                : () async {
                                                                    _scrollController.animateTo(
                                                                        0,
                                                                        duration: const Duration(
                                                                            milliseconds:
                                                                                500),
                                                                        curve: Curves
                                                                            .easeInOut);

                                                                    setState(
                                                                        () {
                                                                      currentPage++;
                                                                      _updateCurrentPageDisplay();
                                                                    });
                                                                  },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              'Next',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    w * .035,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 6),
                                                            Icon(
                                                              Icons
                                                                  .arrow_forward_ios,
                                                              size: 16,
                                                              color: (currentPage +
                                                                          1) >=
                                                                      totalPages
                                                                  ? Colors
                                                                      .grey[500]
                                                                  : Colors
                                                                      .white,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
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

class FilterMenu extends StatefulWidget {
  final List<VendorProduct> filterProductDetails;
  final String brandName;
  final double maxPriceFromAPI;
  final Function(
      List<String> vendors,
      int? priceSorting,
      RangeValues priceRange,
      bool inStockOnly,
      bool onSaleOnly)? onFiltersApplied;

  final List<String> currentVendorFilters;
  final int? currentPriceSorting;
  final RangeValues currentPriceRange;
  final bool currentInStockOnly;
  final bool currentOnSaleOnly;

  const FilterMenu({
    super.key,
    required this.filterProductDetails,
    required this.brandName,
    required this.maxPriceFromAPI,
    this.onFiltersApplied,
    this.currentVendorFilters = const [],
    this.currentPriceSorting,
    this.currentPriceRange =
        const RangeValues(0, 1000), // Will be updated dynamically
    this.currentInStockOnly = false,
    this.currentOnSaleOnly = false,
  });

  @override
  State<FilterMenu> createState() => _FilterMenuState();
}

class _FilterMenuState extends State<FilterMenu> {
  int? tempPriceSorting;
  List<String> tempFilterVendor = [];
  RangeValues priceRange = const RangeValues(0, 1000);
  bool showInStockOnly = false;
  bool showOnSaleOnly = false;

  @override
  void initState() {
    super.initState();

    tempPriceSorting = widget.currentPriceSorting;
    tempFilterVendor = List.from(widget.currentVendorFilters);
    priceRange = widget.currentPriceRange;
    showInStockOnly = widget.currentInStockOnly;
    showOnSaleOnly = widget.currentOnSaleOnly;

    if (priceRange.end > widget.maxPriceFromAPI) {
      priceRange = RangeValues(priceRange.start, widget.maxPriceFromAPI);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: w * .9,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            actionsPadding: EdgeInsets.only(right: 15),
            actions: [
              TextButton(
                onPressed: () async {
                  setState(() {
                    tempPriceSorting = null;
                    tempFilterVendor.clear();
                    priceRange = RangeValues(0, widget.maxPriceFromAPI);
                    showInStockOnly = false;
                    showOnSaleOnly = false;
                  });

                  try {
                    await FilterPreferencesDB.clearFilterPreferences(
                        widget.brandName);
                  } catch (e) {
                    log('Error clearing filter preferences: $e');
                  }
                },
                child: Text(
                  'Reset',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: w * .05),
                ),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Price Range'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          RangeSlider(
                            values: priceRange,
                            min: 0,
                            max: widget.maxPriceFromAPI,
                            divisions: (widget.maxPriceFromAPI / 50)
                                .round()
                                .clamp(10, 40),
                            activeColor: AppColors.primary,
                            labels: RangeLabels(
                              '\$${priceRange.start.round()}',
                              '\$${priceRange.end.round()}',
                            ),
                            onChanged: (values) {
                              setState(() {
                                priceRange = values;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('\$${priceRange.start.round()}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                              Text('\$${priceRange.end.round()}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sort By Section
                  _buildSectionTitle('Sort By'),
                  Card(
                    child: Column(
                      children: [
                        _buildSortOption('Price: Low to High', 1),
                        const Divider(height: 1),
                        _buildSortOption('Price: High to Low', 2),
                        const Divider(height: 1),
                        _buildSortOption('Name: A to Z', 3),
                        const Divider(height: 1),
                        _buildSortOption('Name: Z to A', 4),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Vendor Section
                  _buildSectionTitle('Vendors'),
                  Card(
                    child: Column(
                      children: List.generate(
                        _getUniqueVendorsFromProducts().length,
                        (index) {
                          final vendor = _getUniqueVendorsFromProducts()[index];
                          final productCount =
                              _getProductCountForVendor(vendor);
                          final isSelected = tempFilterVendor.contains(vendor);
                          return Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            child: CheckboxListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 2),
                              activeColor: AppColors.primary,
                              title: Text(
                                vendor,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                '$productCount products',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.8)
                                      : Colors.grey,
                                ),
                              ),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    tempFilterVendor.add(vendor);
                                  } else {
                                    tempFilterVendor.remove(vendor);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _applyFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: w * .045,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, int value) {
    return RadioListTile<int>(
      dense: true,
      activeColor: AppColors.primary,
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      groupValue: tempPriceSorting,
      onChanged: (int? newValue) {
        setState(() {
          tempPriceSorting = newValue;
        });
      },
    );
  }

  List<String> _getUniqueVendorsFromProducts() {
    if (widget.filterProductDetails.isEmpty) return [];

    Set<String> uniqueVendors = {};
    for (var product in widget.filterProductDetails) {
      if (product.vendorName.isNotEmpty) {
        uniqueVendors.add(product.vendorName);
      }
    }

    List<String> vendorList = uniqueVendors.toList();
    vendorList.sort();
    return vendorList;
  }

  int _getProductCountForVendor(String vendorName) {
    return widget.filterProductDetails
        .where((product) => product.vendorName == vendorName)
        .length;
  }

  void _applyFilters() {
    if (widget.onFiltersApplied != null) {
      widget.onFiltersApplied!(
        tempFilterVendor,
        tempPriceSorting,
        priceRange,
        showInStockOnly,
        showOnSaleOnly,
      );
    }

    Fluttertoast.showToast(
      msg: "Filters applied successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
