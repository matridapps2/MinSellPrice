import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/screens/product_details_screen/product_details_screen.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/service_new/filter_preferences_db.dart';
import 'package:minsellprice/widgets/stylish_loader.dart';

class LikedProductScreen extends StatefulWidget {
  const LikedProductScreen({
    super.key,});

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
  List<VendorProduct> allProducts = [];
  bool hasMoreData = true;

  bool filterSubmitted = true;
  bool _isLoading = false;
  bool _isError = false;
  bool isLoggedIn = false;

  List<String> filterVendor = [];
  List<String> uniqueVendors = [];
  List<VendorProduct> brandProducts = [];
  List<VendorProduct> tempProductList = [];
  List<VendorProduct> finalList = [];
  List<ProductListModelNew> brandDetails = [];

  RangeValues currentPriceRange = const RangeValues(0, 1000);
  bool currentInStockOnly = false;
  bool currentOnSaleOnly = false;
  double maxPriceFromAPI = 1000.0;

  String emailId = '';

  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
  //  _initCall();
    // Listen to Firebase Auth state changes
    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (mounted) {
            if (user != null && user.email != null) {
              setState(() {
                 isLoggedIn = true;
                emailId = user.email!;
              });
              log('Liked User Logged ? $emailId');
              _fetchBrandProducts(emailId);
            } else {
              setState(() {
                isLoggedIn = false;
                emailId = '';
              });
            }
          }
        });
  }


  void _initCall() async {
    await _fetchBrandProducts(emailId).whenComplete(() async {});
  }

  Future<void> _fetchBrandProducts(String emailId) async {
    setState(() => _isLoading = true);
    try {
      final allProductsResponse = await BrandsApi.getLikedProduct(
         emailId: emailId, context: context );
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
        brandProducts = List.from(allProducts);
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _focusNode.unfocus();
        },
        child: _isLoading
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
            )
        )
            : _isError
            ? Scaffold(
          appBar: AppBar(),
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
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  onTap: () {
                                    _scaffoldKey.currentState!
                                        .openEndDrawer();
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
                    totalProductCount == 0
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
                        : totalProductCount > 0
                        ? Expanded(
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
                              padding: const EdgeInsets
                                  .symmetric(
                                  horizontal: 10.0),
                              child: Wrap(
                                runSpacing: 10,
                                children: List.generate(
                                  finalList.length,
                                      (index) => Padding(
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        4.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ProductDetailsScreen(
                                                  productId:
                                                  finalList[index]
                                                      .productId,
                                                  brandName: 'Unknown Brand',
                                                  productMPN:
                                                  finalList[index]
                                                      .productMpn,
                                                  productImage:
                                                  finalList[index]
                                                      .productImage,
                                                  productPrice:
                                                  finalList[index]
                                                      .vendorpricePrice)),
                                        );
                                      },
                                      child: Container(
                                        width: w * .45,
                                        // height: h * .48,
                                        decoration:
                                        BoxDecoration(
                                          color:
                                          Colors.white,
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
                                              blurRadius: 8,
                                              offset:
                                              const Offset(
                                                  0, 4),
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
                                                  topLeft: Radius
                                                      .circular(
                                                      16),
                                                  topRight:
                                                  Radius.circular(
                                                      16),
                                                ),
                                              ),
                                              child:
                                              ClipRRect(
                                                borderRadius:
                                                const BorderRadius
                                                    .only(
                                                  topLeft: Radius
                                                      .circular(
                                                      0),
                                                  topRight:
                                                  Radius.circular(
                                                      0),
                                                ),
                                                child: Image
                                                    .network(
                                                  _getProperImageUrl(
                                                      finalList[index]
                                                          .productImage),
                                                  fit: BoxFit
                                                      .contain,
                                                  errorBuilder: (context,
                                                      error,
                                                      stackTrace) {
                                                    return Container(
                                                      color:
                                                      Colors.grey[200],
                                                      child:
                                                      Icon(
                                                        Icons.image_not_supported_outlined,
                                                        size:
                                                        w * .08,
                                                        color:
                                                        Colors.grey[400],
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
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
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
                                                         mainAxisAlignment:
                                                         MainAxisAlignment.spaceBetween,
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
                                                             onTap: () async {

                                                             },
                                                             child: Container(
                                                               padding: const EdgeInsets.all(3),
                                                               decoration: BoxDecoration(
                                                                 color:
                                                                 Colors.red.withOpacity(0.1),
                                                                 borderRadius:
                                                                 BorderRadius.circular(20),
                                                               ),
                                                               child: const Icon(
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
                    const SizedBox(height: 10),
                    // Loading indicator for more products
                    if (_isLoading && allProducts.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding:
                        const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                valueColor:
                                AlwaysStoppedAnimation<Color>(
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[100]!,
                            Colors.grey[200]!,
                          ],
                        ),
                        border: Border(
                          top: BorderSide(
                              color: Colors.grey[300]!, width: 1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, -1),
                          ),
                        ],
                      ),
                      child: totalProductCount > itemsPerPage
                          ? Column(
                        children: [
                          // Page Counter
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Page ${currentPage + 1} of $totalPages',
                                  style: TextStyle(
                                    fontSize: w * .039,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[800],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets
                                      .symmetric(
                                      horizontal: 8,
                                      vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(
                                        12),
                                  ),
                                  child: Text(
                                    '$totalPages total',
                                    style: TextStyle(
                                      fontSize: w * .039,
                                      fontWeight:
                                      FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Navigation Buttons
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              // Previous Button
                              Expanded(
                                child: Container(
                                  height: 50,
                                  margin: const EdgeInsets.only(
                                      right: 8),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                      MaterialStateProperty
                                          .resolveWith<
                                          Color>(
                                            (Set<MaterialState>
                                        states) {
                                          if (states.contains(
                                              MaterialState
                                                  .pressed)) {
                                            return AppColors
                                                .primary
                                                .withOpacity(
                                                0.8);
                                          }
                                          return currentPage ==
                                              0
                                              ? Colors
                                              .grey[300]!
                                              : Colors.white;
                                        },
                                      ),
                                      foregroundColor:
                                      MaterialStateProperty
                                          .resolveWith<
                                          Color>(
                                            (Set<MaterialState>
                                        states) {
                                          return currentPage ==
                                              0
                                              ? Colors
                                              .grey[500]!
                                              : AppColors
                                              .primary;
                                        },
                                      ),
                                      side:
                                      MaterialStateProperty
                                          .resolveWith<
                                          BorderSide>(
                                            (Set<MaterialState>
                                        states) {
                                          return currentPage ==
                                              0
                                              ? BorderSide(
                                              color: Colors
                                                  .grey[
                                              300]!)
                                              : BorderSide(
                                              color: AppColors
                                                  .primary,
                                              width: 2);
                                        },
                                      ),
                                      shape: MaterialStateProperty
                                          .resolveWith<
                                          OutlinedBorder>(
                                            (states) =>
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(12),
                                            ),
                                      ),
                                      elevation:
                                      MaterialStateProperty
                                          .resolveWith<
                                          double>(
                                            (Set<MaterialState>
                                        states) {
                                          if (states.contains(
                                              MaterialState
                                                  .pressed)) {
                                            return 2;
                                          }
                                          return currentPage ==
                                              0
                                              ? 0
                                              : 3;
                                        },
                                      ),
                                      shadowColor:
                                      MaterialStateProperty
                                          .all(AppColors
                                          .primary
                                          .withOpacity(
                                          0.3)),
                                    ),
                                    onPressed: currentPage == 0
                                        ? null
                                        : () {
                                      setState(() {
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
                                          Icons.arrow_back_ios,
                                          size: 18,
                                          color: currentPage ==
                                              0
                                              ? Colors.grey[500]
                                              : AppColors
                                              .primary,
                                        ),
                                        const SizedBox(
                                            width: 6),
                                        Text(
                                          'Previous',
                                          style: TextStyle(
                                            fontSize: w * .035,
                                            fontWeight:
                                            FontWeight.w700,
                                            letterSpacing: 0.5,
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
                                  height: 50,
                                  margin: const EdgeInsets.only(
                                      left: 8),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                      MaterialStateProperty
                                          .resolveWith<
                                          Color>(
                                            (Set<MaterialState>
                                        states) {
                                          if (states.contains(
                                              MaterialState
                                                  .pressed)) {
                                            return AppColors
                                                .primary
                                                .withOpacity(
                                                0.8);
                                          }
                                          return (currentPage +
                                              1) >=
                                              totalPages
                                              ? Colors
                                              .grey[300]!
                                              : Colors.white;
                                        },
                                      ),
                                      foregroundColor:
                                      MaterialStateProperty
                                          .resolveWith<
                                          Color>(
                                            (Set<MaterialState>
                                        states) {
                                          return (currentPage +
                                              1) >=
                                              totalPages
                                              ? Colors
                                              .grey[500]!
                                              : AppColors
                                              .primary;
                                        },
                                      ),
                                      side:
                                      MaterialStateProperty
                                          .resolveWith<
                                          BorderSide>(
                                            (Set<MaterialState>
                                        states) {
                                          return (currentPage +
                                              1) >=
                                              totalPages
                                              ? BorderSide(
                                              color: Colors
                                                  .grey[
                                              300]!)
                                              : BorderSide(
                                              color: AppColors
                                                  .primary,
                                              width: 2);
                                        },
                                      ),
                                      shape: MaterialStateProperty
                                          .resolveWith<
                                          OutlinedBorder>(
                                            (states) =>
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(12),
                                            ),
                                      ),
                                      elevation:
                                      MaterialStateProperty
                                          .resolveWith<
                                          double>(
                                            (Set<MaterialState>
                                        states) {
                                          if (states.contains(
                                              MaterialState
                                                  .pressed)) {
                                            return 2;
                                          }
                                          return (currentPage +
                                              1) >=
                                              totalPages
                                              ? 0
                                              : 3;
                                        },
                                      ),
                                      shadowColor:
                                      MaterialStateProperty
                                          .all(AppColors
                                          .primary
                                          .withOpacity(
                                          0.3)),
                                    ),
                                    onPressed:
                                    (currentPage + 1) >=
                                        totalPages
                                        ? null
                                        : () async {
                                      _scrollController.animateTo(0,
                                          duration: const Duration(
                                              milliseconds:
                                              500),
                                          curve: Curves
                                              .easeInOut);

                                      // Check if we need to load more data
                                      if ((currentPage +
                                          1) *
                                          itemsPerPage >=
                                          allProducts
                                              .length &&
                                          hasMoreData) {
                                       // await _loadMoreProducts();
                                      }

                                      setState(() {
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
                                            fontSize: w * .035,
                                            fontWeight:
                                            FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(
                                            width: 6),
                                        Icon(
                                          Icons
                                              .arrow_forward_ios,
                                          size: 18,
                                          color: (currentPage +
                                              1) >=
                                              totalPages
                                              ? Colors.grey[500]
                                              : AppColors
                                              .primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                          : const SizedBox(),
                    ),
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
        )
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
