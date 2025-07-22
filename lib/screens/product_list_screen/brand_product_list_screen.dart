import 'dart:developer';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:minsellprice/colors.dart' show AppColors;
import 'package:minsellprice/screens/tushar_screen/model/product_list_model_new.dart';
import 'package:minsellprice/reposotory_services/network_reposotory.dart';
import 'package:minsellprice/screens/tushar_screen/product_list_screen/product_details_screen.dart';
import 'package:minsellprice/screens/widgets/custom_loader.dart';
import 'package:minsellprice/screens/tushar_screen/service_new/filter_preferences_db.dart';
import 'package:minsellprice/size.dart';
import 'package:sqflite/sqflite.dart';

class BrandProductListScreen extends StatefulWidget {
  const BrandProductListScreen({
    super.key,
    required this.brandId,
    required this.brandName,
    this.database,
    required this.dataList,
  });

  final int brandId;
  final String? brandName;
  final Database? database;
  final List<Map<String, dynamic>> dataList;

  @override
  State<BrandProductListScreen> createState() => _BrandProductListScreen();
}

class _BrandProductListScreen extends State<BrandProductListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();

  final FocusNode _focusNode = FocusNode();

  final TextEditingController iconController = TextEditingController();

  int? priceSorting;
  int currentPage = 0;
  int itemsPerPage = 20;
  int endIndex = 0;
  int startIndex = 0;

  bool filterSubmitted = true;
  bool _isLoading = false;
  bool _isError = false;

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

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() async {
    log('Brand Name: ${widget.brandName}');
    await _fetchBrandProducts().whenComplete(() async {
      await _loadFilterPreferences();
    });
  }

  Future<void> _loadFilterPreferences() async {
    try {
      final prefs = await FilterPreferencesDB.getFilterPreferences(
          widget.brandName ?? 'Unknown');

      if (prefs != null) {
        setState(() {
          filterVendor = prefs['selectedVendors'] ?? [];
          priceSorting = prefs['priceSorting'];
          // Use saved max price but ensure it doesn't exceed API max
          double savedMaxPrice = prefs['maxPrice'] ?? maxPriceFromAPI;
          currentPriceRange = RangeValues(
            prefs['minPrice'] ?? 0,
            savedMaxPrice,
          );
          currentInStockOnly = prefs['inStockOnly'] ?? false;
          currentOnSaleOnly = prefs['onSaleOnly'] ?? false;
        });
        log('Loaded filter preferences for ${widget.brandName}');
      }
    } catch (e) {
      log('Error loading filter preferences: $e');
    }
  }

  Future<void> _fetchBrandProducts() async {
    setState(() => _isLoading = true);
    try {
      final allProductsResponse = await NetworkCalls()
          .getProductListByBrandName(
              widget.brandName.toString(), currentPage + 1);
      final Map<String, dynamic> decoded =
          jsonDecode(allProductsResponse ?? '{}');

      final List<dynamic> jsonList = decoded['brand_product'] ?? [];
      final List<VendorProduct> fetchedProducts =
          jsonList.map((e) => VendorProduct.fromJson(e)).toList();

      // List<String> uniqueVendorsLocal = getUniqueBrands(fetchedProducts);
      // uniqueVendorsLocal =
      //     uniqueVendorsLocal.where((element1) => element1 != '--').toList();
      // List<String> tempList = [];
      // for (final vendor in uniqueVendorsLocal) {
      //   tempList.add(
      //       '$vendor Total Product(s): ${fetchedProducts.where((element) => element.vendorName == vendor).toList().length} ');
      // }

      int start = currentPage * itemsPerPage;
      int end = (start + itemsPerPage > fetchedProducts.length)
          ? fetchedProducts.length
          : start + itemsPerPage;

      double calculatedMaxPrice = 1000.0;
      if (fetchedProducts.isNotEmpty) {
        final validPrices = fetchedProducts
            .map((product) => double.tryParse(product.vendorpricePrice ?? '0'))
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
        brandProducts = fetchedProducts;
      //  uniqueVendors = tempList;
        tempProductList = fetchedProducts;
        maxPriceFromAPI = calculatedMaxPrice;

        if (currentPriceRange.end == 1000.0) {
          currentPriceRange = RangeValues(0, maxPriceFromAPI);
        }

        startIndex = start;
        endIndex = end;
        finalList = tempProductList.sublist(startIndex, endIndex);
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: SafeArea(
        child: _isLoading
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
                        style: TextStyle(fontSize: w * .04),
                      ),
                    ),
                  ),
                  actions: [
                    Image.asset(
                      'assets/minsellprice_app_icon.png',
                      height: .23 * w,
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
                body: Align(
                  alignment: Alignment.center,
                  child: CustomLoader(
                      vendorName: '',
                      imageString:
                          'https://www.minsellprice.com/Brand-logo-images/${widget.brandName.toString().replaceAll(' ', '-').toLowerCase()}.png',
                      isAssetImage: true),
                ),
              )
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
                        Image.asset(
                          'assets/minsellprice_app_icon.png',
                          height: .23 * w,
                          fit: BoxFit.fill,
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
                    endDrawer: FilterMenu(
                      filterProductDetails: brandProducts,
                      brandName: widget.brandName ?? 'Unknown',
                      maxPriceFromAPI: maxPriceFromAPI,
                      currentVendorFilters: filterVendor,
                      currentPriceSorting: priceSorting,
                      currentPriceRange: currentPriceRange,
                      currentInStockOnly: currentInStockOnly,
                      currentOnSaleOnly: currentOnSaleOnly,
                      onFiltersApplied: (vendors, priceSorting, priceRange,
                          inStockOnly, onSaleOnly) {
                        _applyFilters(vendors, priceSorting, priceRange,
                            inStockOnly, onSaleOnly);
                      },
                    ),
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
                        Image.asset(
                          'assets/minsellprice_app_icon.png',
                          fit: BoxFit.fill,
                        ),
                      ],
                    ),
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                _scaffoldKey.currentState!.openEndDrawer();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.filter_list_alt),
                                    AutoSizeText(
                                      'Filters',
                                      style: TextStyle(
                                        fontSize: .04 * w,
                                        fontFamily: 'Futura BdCn BT Bold',
                                        fontWeight: FontWeight.w300,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: AutoSizeText(
                                '${tempProductList.length} Product(s)',
                                style: TextStyle(
                                  fontSize: .06 * w,
                                  fontFamily: 'Futura BdCn BT Bold',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        tempProductList.isEmpty
                            ? SizedBox(
                                width: w,
                                height: h * .6,
                                child: Center(
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
                                              ..onTap =
                                                  () => Navigator.pop(context),
                                            style: TextStyle(
                                                fontSize: .06 * w,
                                                fontFamily:
                                                    'Futura BdCn BT Bold',
                                                fontWeight: FontWeight.w300,
                                                color: AppColors.primary),
                                          )
                                        ]),
                                  ),
                                ),
                              )
                            : Flexible(
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Wrap(
                                          runSpacing: 10,
                                          children: List.generate(
                                            finalList.length,
                                            (index) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => ProductDetailsScreen(
                                                            productId:
                                                                finalList[index]
                                                                    .productId,
                                                            brandName: widget
                                                                    .brandName ??
                                                                'Unknown Brand',
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
                                                child: Card(
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    side: BorderSide(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  child: Container(
                                                    width: w * .42,
                                                    color: Colors.white,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                            height: 5),
                                                        Center(
                                                            child:
                                                                Image.network(
                                                          '${finalList[index].productImage}',
                                                          height: w * .3,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Image.asset(
                                                              'assets/no_image/no_image.jpg',
                                                              height: w * .3,
                                                              fit: BoxFit.cover,
                                                            );
                                                          },
                                                        )),
                                                        const SizedBox(
                                                            height: 2),
                                                        Container(
                                                          constraints:
                                                              BoxConstraints(
                                                                  minHeight:
                                                                      w * .15,
                                                                  maxHeight:
                                                                      w * .15),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8,
                                                                    right: 10.0,
                                                                    top: 8),
                                                            child: Text(
                                                              finalList[index]
                                                                      .productName
                                                                      .isEmpty
                                                                  ? '--'
                                                                  : finalList[
                                                                          index]
                                                                      .productName,
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                 // color: '#222223'.toColor(),
                                                                  fontFamily:
                                                                      'Myriad Arabic',
                                                                  fontSize:
                                                                      w * .06,
                                                                  height: 1,
                                                                  wordSpacing:
                                                                      0,
                                                                  letterSpacing:
                                                                      0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      8.0,
                                                                  vertical: 8),
                                                          child: AutoSizeText(
                                                            'MPN# ${finalList[index].productMpn}',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'Segoe UI',
                                                                fontSize:
                                                                    w * .04,
                                                                wordSpacing: 0,
                                                                letterSpacing:
                                                                    0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500

                                                                // fontWeight: FontWeight.w900
                                                                ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      8.0,
                                                                  vertical: 5),
                                                          child: RichText(
                                                            text: TextSpan(
                                                              text:
                                                                  '\$${finalList[index].vendorpricePrice}',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black87,
                                                                fontFamily:
                                                                    'MyriadPro-BoldCond',
                                                                fontSize:
                                                                    w * .08,
                                                                wordSpacing: .1,
                                                                letterSpacing:
                                                                    0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      8.0,
                                                                  vertical: 8),
                                                          child: Text(
                                                            'Show Prices (${finalList[index].vendorIdCount})',
                                                            style: TextStyle(
                                                              fontSize: 22,
                                                              color:
                                                                  Colors.blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        // Center(
                                                        //   child: InkWell(
                                                        //     onTap: () async =>
                                                        //         await MyInAppBrowser().openUrlRequest(
                                                        //       urlRequest: URLRequest(
                                                        //         url: WebUri(finalList[index].vendorUrl + '?utm_source=minsellprice..com&utm_medium=mobile-app',),
                                                        //       ),
                                                        //       options:
                                                        //           InAppBrowserClassOptions(
                                                        //         crossPlatform:
                                                        //             InAppBrowserOptions(
                                                        //           toolbarTopBackgroundColor:
                                                        //                AppColors.primary,
                                                        //         ),
                                                        //       ),
                                                        //     ),
                                                        //     child: BuyAtButton(
                                                        //         imageUrl: finalList[index].vendorName),
                                                        //   ),
                                                        // ),
                                                        const SizedBox(
                                                            height: 15)
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
                              ),
                        const SizedBox(height: 5),
                        tempProductList.length > itemsPerPage
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        minimumSize: MaterialStateProperty
                                            .resolveWith<Size>(
                                                (states) => Size(w * .3, 40)),
                                        maximumSize: MaterialStateProperty
                                            .resolveWith<Size>(
                                                (states) => Size(w * .3, 50)),
                                        backgroundColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            return currentPage == 0
                                                ? Colors.grey
                                                : AppColors.primary;
                                          },
                                        ),
                                        shape: MaterialStateProperty
                                            .resolveWith<OutlinedBorder>(
                                          (states) => RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      onPressed: currentPage == 0
                                          ? null
                                          : () {
                                              setState(() {
                                                currentPage--;
                                                startIndex =
                                                    currentPage * itemsPerPage;
                                                endIndex = (startIndex +
                                                            itemsPerPage >
                                                        tempProductList.length)
                                                    ? tempProductList.length
                                                    : startIndex + itemsPerPage;
                                                finalList =
                                                    tempProductList.sublist(
                                                        startIndex, endIndex);
                                              });
                                            },
                                      child: Text(
                                        'Previous ($currentPage)',
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: w * .03),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        minimumSize: MaterialStateProperty
                                            .resolveWith<Size>(
                                                (states) => Size(w * .3, 40)),
                                        maximumSize: MaterialStateProperty
                                            .resolveWith<Size>(
                                                (states) => Size(w * .3, 50)),
                                        backgroundColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            return endIndex ==
                                                    tempProductList.length
                                                ? Colors.grey
                                                : AppColors.primary;
                                          },
                                        ),
                                        shape: MaterialStateProperty
                                            .resolveWith<OutlinedBorder>(
                                          (states) => RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      onPressed: endIndex ==
                                              tempProductList.length
                                          ? null
                                          : () {
                                              _scrollController.animateTo(0,
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.linear);
                                              setState(() {
                                                currentPage++;
                                                startIndex =
                                                    currentPage * itemsPerPage;
                                                endIndex = (startIndex +
                                                            itemsPerPage >
                                                        tempProductList.length)
                                                    ? tempProductList.length
                                                    : startIndex + itemsPerPage;
                                                finalList =
                                                    tempProductList.sublist(
                                                        startIndex, endIndex);
                                              });
                                            },
                                      child: Text(
                                        'Next(${currentPage + 1})',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
      ),
    );
  }

  // void sortingOfList({required List<VendorProduct> mainList}) {
  //   setState(() {
  //     if (filterVendor.isNotEmpty) {
  //       tempProductList = mainList.where((product) {
  //         return filterVendor.contains(product.firstVendorName);
  //       }).toList();
  //     } else {
  //       tempProductList = mainList;
  //     }
  //
  //     if (priceSorting != null) {
  //       if (priceSorting == 1) {
  //         tempProductList.sort((a, b) =>
  //             extractDoubleFromString(a.firstVendorPrice)
  //                 .compareTo(extractDoubleFromString(b.firstVendorPrice)));
  //       } else {
  //         tempProductList.sort((a, b) =>
  //             extractDoubleFromString(b.firstVendorPrice)
  //                 .compareTo(extractDoubleFromString(a.firstVendorPrice)));
  //       }
  //     } else if (priceSorting == null && filterVendor.isNotEmpty) {
  //       tempProductList.clear();
  //       tempProductList = mainList.where((product) {
  //         return filterVendor.contains(product.firstVendorName);
  //       }).toList();
  //     } else if (filterVendor.isEmpty && priceSorting == null) {
  //       tempProductList = mainList;
  //     }
  //
  //     currentPage = 0;
  //     startIndex = currentPage * itemsPerPage;
  //     endIndex = (startIndex + itemsPerPage > tempProductList.length)
  //         ? tempProductList.length
  //         : startIndex + itemsPerPage;
  //     finalList = tempProductList.sublist(startIndex, endIndex);
  //   });
  // }

  showBottomModalDialog({
    required BuildContext context,
    required List<Widget> children,
  }) {
    showCupertinoModalPopup(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext modalContext) => Container(
            height: h * 0.90,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            child: Material(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25.0)),
                child: Column(
                    mainAxisSize: MainAxisSize.max, children: children))));
  }

  void _applyFilters(List<String> vendors, int? priceSorting,
      RangeValues priceRange, bool inStockOnly, bool onSaleOnly) {
    setState(() {
      filterVendor = vendors;
      this.priceSorting = priceSorting;
      currentPriceRange = priceRange;
      currentInStockOnly = inStockOnly;
      currentOnSaleOnly = onSaleOnly;

      if (filterVendor.isNotEmpty) {
        tempProductList = brandProducts.where((product) {
          return filterVendor.contains(product.vendorName);
        }).toList();
      } else {
        tempProductList = List.from(brandProducts);
      }

      tempProductList = tempProductList.where((product) {
        double? price = double.tryParse(product.vendorpricePrice ?? '0');
        return price != null &&
            price >= priceRange.start &&
            price <= priceRange.end;
      }).toList();

      if (priceSorting != null) {
        if (priceSorting == 1) {
          tempProductList.sort((a, b) {
            double priceA = double.tryParse(a.vendorpricePrice ?? '0') ?? 0;
            double priceB = double.tryParse(b.vendorpricePrice ?? '0') ?? 0;
            return priceA.compareTo(priceB);
          });
        } else if (priceSorting == 2) {
          tempProductList.sort((a, b) {
            double priceA = double.tryParse(a.vendorpricePrice ?? '0') ?? 0;
            double priceB = double.tryParse(b.vendorpricePrice ?? '0') ?? 0;
            return priceB.compareTo(priceA);
          });
        } else if (priceSorting == 3) {
          tempProductList.sort(
              (a, b) => (a.productName ?? '').compareTo(b.productName ?? ''));
        } else if (priceSorting == 4) {
          tempProductList.sort(
              (a, b) => (b.productName ?? '').compareTo(a.productName ?? ''));
        }
      }

      currentPage = 0;
      startIndex = currentPage * itemsPerPage;
      endIndex = (startIndex + itemsPerPage > tempProductList.length)
          ? tempProductList.length
          : startIndex + itemsPerPage;
      finalList = tempProductList.sublist(startIndex, endIndex);
    });
    _saveFilterPreferences();
  }

  Future<void> _saveFilterPreferences() async {
    try {
      await FilterPreferencesDB.saveFilterPreferences(
        brandName: widget.brandName ?? 'Unknown',
        selectedVendors: filterVendor,
        priceSorting: priceSorting,
        minPrice: currentPriceRange.start,
        maxPrice: currentPriceRange.end,
        inStockOnly: currentInStockOnly,
        onSaleOnly: currentOnSaleOnly,
      );
      log('Saved filter preferences for ${widget.brandName}');
    } catch (e) {
      log('Error saving filter preferences: $e');
    }
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
                    child: Container(
                      constraints: BoxConstraints(maxHeight: h * .25),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _getUniqueVendorsFromProducts().length,
                        itemBuilder: (context, index) {
                          final vendor = _getUniqueVendorsFromProducts()[index];
                          final productCount =
                              _getProductCountForVendor(vendor);
                          return CheckboxListTile(
                            dense: true,
                            activeColor: AppColors.primary,
                            title: Text(
                              vendor,
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              '$productCount products',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            value: tempFilterVendor.contains(vendor),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  tempFilterVendor.add(vendor);
                                } else {
                                  tempFilterVendor.remove(vendor);
                                }
                              });
                            },
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
