import 'dart:developer';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:minsellprice/colors.dart' show AppColors;
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/reposotory_services/network_reposotory.dart';
import 'package:minsellprice/screens/InAppBrowser.dart';
import 'package:minsellprice/screens/tushar_screen/product_details_screen.dart';
import 'package:minsellprice/screens/widgets/custom_loader.dart';
import 'package:minsellprice/screens/widgets/custom_view_button.dart';
import 'package:minsellprice/services/extra_functions.dart';
import 'package:minsellprice/size.dart';
import 'package:sqflite/sqflite.dart';

class BrandProductListScreen extends StatefulWidget {
  const BrandProductListScreen({
    super.key,
    required this.brandId,
    required this.brandName,
    required this.database,
    required this.dataList,
  });

  final int brandId;
  final String? brandName;
  final Database database;
  final List<Map<String, dynamic>> dataList;

  @override
  State<BrandProductListScreen> createState() => _BrandProductListScreen();
}

class _BrandProductListScreen extends State<BrandProductListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();

  final FocusNode _focusNode = FocusNode();

  final TextEditingController iconController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() async {
    log('Brand Name: ${widget.brandName}');
    await _fetchBrandProducts();
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

      List<String> uniqueVendorsLocal = getUniqueBrands(fetchedProducts);
      uniqueVendorsLocal =
          uniqueVendorsLocal.where((element1) => element1 != '--').toList();
      List<String> tempList = [];
      for (final vendor in uniqueVendorsLocal) {
        tempList.add(
            '$vendor Total Product(s): ${fetchedProducts.where((element) => element.vendorName == vendor).toList().length} ');
      }

      int start = currentPage * itemsPerPage;
      int end = (start + itemsPerPage > fetchedProducts.length)
          ? fetchedProducts.length
          : start + itemsPerPage;

      setState(() {
        brandProducts = fetchedProducts;
        uniqueVendors = tempList;
        tempProductList = fetchedProducts;
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
                    // endDrawer: FilterMenu(
                    //   uniqueVendors: uniqueVendors,
                    //   priceSorting: priceSorting,
                    //   priceSelection: (int? value) {
                    //     setState(() {
                    //       priceSorting = value;
                    //     });
                    //   },
                    //   vendorSelection: (List<String> value) {
                    //     setState(() {
                    //       filterVendor = value;
                    //     });
                    //   },
                    //   filterVendors: filterVendor,
                    //   // submitAction: () {
                    //   //   sortingOfList(mainList: brandProducts);
                    //   //
                    //   //   Fluttertoast.showToast(msg: 'Filter Submitted');
                    //   // },
                    //   // clearAction: () {
                    //   //   setState(() {
                    //   //     sortingOfList(mainList: brandProducts);
                    //   //   });
                    //   // },
                    // ),
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
                                                        builder: (context) =>
                                                            ProductDetailsScreen(
                                                              productId:
                                                                  finalList[
                                                                          index]
                                                                      .productId,
                                                              brandName: widget
                                                                      .brandName ??
                                                                  'Unknown Brand',
                                                              productMPN:
                                                                  finalList[
                                                                          index]
                                                                      .productMpn,
                                                              productImage:
                                                                  finalList[
                                                                          index]
                                                                      .productImage,
                                                            )),
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
                                                                  .productName,
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  color: '#222223'
                                                                      .toColor(),
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
                                                                  vertical: 3),
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
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.check,
                                                                color: '#3b8039'
                                                                    .toColor(),
                                                                size: 23,
                                                              ),
                                                              const SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                'In Stock',
                                                                maxLines: 3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                    color: '#3b8039'
                                                                        .toColor(),
                                                                    fontFamily:
                                                                        'Segoe UI Bold',
                                                                    fontSize: w *
                                                                        .043,
                                                                    wordSpacing:
                                                                        2,
                                                                    letterSpacing:
                                                                        0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal

                                                                    // fontWeight: FontWeight.w900
                                                                    ),
                                                              ),
                                                            ],
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
                                                            horizontal: 8.0,
                                                          ),
                                                          child: SizedBox(
                                                            width: w * .46,
                                                            child: FittedBox(
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .local_shipping,
                                                                    color: '#0678cb'
                                                                        .toColor(),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 3),
                                                                  AutoSizeText(
                                                                    finalList[index].vendorpricePrice ==
                                                                                '--' ||
                                                                            finalList[index].vendorpricePrice ==
                                                                                '\$0.00'
                                                                        ? ' Free Shipping'
                                                                        : 'Shipping(${finalList[index].vendorpricePrice})',
                                                                    maxLines: 3,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        color: finalList[index].vendorpricePrice == '--' || finalList[index].vendorpricePrice == '\$0.00'
                                                                            ? '#3b8039'
                                                                                .toColor()
                                                                            : '#0678cb'
                                                                                .toColor(),
                                                                        fontFamily:
                                                                            'Segoe UI Bold',
                                                                        fontSize: w *
                                                                            .042,
                                                                        wordSpacing:
                                                                            2,
                                                                        letterSpacing:
                                                                            .4,
                                                                        fontWeight:
                                                                            FontWeight.normal

                                                                        // fontWeight: FontWeight.w900
                                                                        ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 11),
                                                        Center(
                                                          child: InkWell(
                                                            onTap: () async =>
                                                                await MyInAppBrowser()
                                                                    .openUrlRequest(
                                                              urlRequest:
                                                                  URLRequest(
                                                                url: WebUri(
                                                                  // finalList[index].firstVendorUrl == '--' ? getOtherSeller.containsKey('${finalList[index].productId}') ? getOtherSeller['${finalList[index].productId}']!.firstVendorUrl : '--' :
                                                                  finalList[index]
                                                                          .vendorUrl +
                                                                      '?utm_source=shoppingmegamart.com&utm_medium=mobile-app',
                                                                ),
                                                              ),
                                                              options:
                                                                  InAppBrowserClassOptions(
                                                                crossPlatform:
                                                                    InAppBrowserOptions(
                                                                  toolbarTopBackgroundColor:
                                                                       AppColors.primary,
                                                                ),
                                                              ),
                                                            ),
                                                            child: BuyAtButton(
                                                                imageUrl: finalList[
                                                                        index]
                                                                    .vendorName),
                                                          ),
                                                        ),
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
                                                : '#d90310'.toColor();
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
                                                : '#d90310'.toColor();
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
}

// class FilterMenu extends StatefulWidget {
//   const FilterMenu({
//     super.key,
//     required this.uniqueVendors,
//     this.priceSorting,
//     required this.priceSelection,
//     required this.vendorSelection,
//     required this.filterVendors,
//     required this.submitAction,
//     required this.clearAction,
//   });
//
//   final List<String> uniqueVendors, filterVendors;
//   final ValueChanged<List<String>> vendorSelection;
//   final VoidCallback submitAction, clearAction;
//   final ValueChanged<int?> priceSelection;
//   final int? priceSorting;
//
//   @override
//   State<FilterMenu> createState() => _FilterMenuState();
// }
//
// class _FilterMenuState extends State<FilterMenu> {
//   int? tempPriceSorting;
//   List<String> filterVendor = [];
//
//   @override
//   void initState() {
//     // TODO: implement initState
//
//     setState(() {
//       filterVendor = widget.filterVendors;
//       tempPriceSorting = widget.priceSorting;
//     });
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       width: w * .9,
//       backgroundColor: Colors.white,
//       surfaceTintColor: Colors.white,
//
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           AppBar(
//             elevation: 10,
//             leading: InkWell(
//               onTap: () => Navigator.pop(context),
//               child: Icon(
//                 Icons.arrow_back_ios,
//                 color: AppColors.primary,
//               ),
//             ),
//             surfaceTintColor: Colors.white,
//             toolbarHeight: .14 * w,
//             backgroundColor: Colors.white,
//             centerTitle: false,
//             title: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 2.0),
//               child: SizedBox(
//                 width: w * .5,
//                 child: AutoSizeText(
//                   'Filters',
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(fontSize: w * .04),
//                 ),
//               ),
//             ),
//             automaticallyImplyLeading: false,
//             actions: const [SizedBox()],
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
//             child: Text(
//               'First Lowest Vendors',
//               style: TextStyle(
//                 fontSize: .06 * w,
//                 fontFamily: 'Futura BdCn BT Bold',
//                 fontWeight: FontWeight.w300,
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.only(left: 8),
//             constraints: BoxConstraints(maxHeight: h * .48),
//             child: Scrollbar(
//               trackVisibility: true,
//               thumbVisibility: true,
//               thickness: 4,
//               interactive: true,
//               controller: _scrollController,
//               child: SingleChildScrollView(
//                 controller: _scrollController,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: List.generate(
//                     widget.uniqueVendors.length,
//                     (index) => Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: OutlinedButton(
//                         style: ButtonStyle(
//                           padding: MaterialStateProperty.resolveWith((states) {
//                             return const EdgeInsets.all(4);
//                           }),
//                           shape: MaterialStateProperty.resolveWith(
//                             (states) {
//                               return const RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(5),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             filterVendor.contains(widget.uniqueVendors[index]
//                                     .split('Total')[0]
//                                     .trimRight())
//                                 ? filterVendor.remove(widget
//                                     .uniqueVendors[index]
//                                     .split('Total')[0]
//                                     .trimRight())
//                                 : filterVendor.add(widget.uniqueVendors[index]
//                                     .split('Total')[0]
//                                     .trimRight());
//                           });
//                         },
//                         child: SizedBox(
//                           width: w * .8,
//                           child: Row(
//                             children: [
//                               Checkbox(
//                                   value: filterVendor.contains(widget
//                                       .uniqueVendors[index]
//                                       .split('Total')[0]
//                                       .trimRight()),
//                                   onChanged: (values) {
//                                     setState(() {
//                                       filterVendor.contains(widget
//                                               .uniqueVendors[index]
//                                               .split('Total')[0]
//                                               .trimRight())
//                                           ? filterVendor.remove(widget
//                                               .uniqueVendors[index]
//                                               .split('Total')[0]
//                                               .trimRight())
//                                           : filterVendor.add(widget
//                                               .uniqueVendors[index]
//                                               .split('Total')[0]
//                                               .trimRight());
//                                       // _discountEnabled =
//                                       // !_discountEnabled;
//                                     });
//                                   }),
//                               RichText(
//                                 text: TextSpan(
//                                     text: widget.uniqueVendors[index]
//                                         .split('Total')[0],
//                                     style: const TextStyle(
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold),
//                                     children: [
//                                       TextSpan(
//                                         text: widget.uniqueVendors[index]
//                                                     .split('Total')
//                                                     .length >
//                                                 1
//                                             ? '\n${widget.uniqueVendors[index].split('Total')[1].trimLeft().split(':')[0]}: '
//                                             : '',
//                                         style: const TextStyle(
//                                           color: Colors.blue,
//                                           fontWeight: FontWeight.normal,
//                                         ),
//                                       ),
//                                       TextSpan(
//                                         text: widget.uniqueVendors[index]
//                                                     .split(':')
//                                                     .length >
//                                                 1
//                                             ? widget.uniqueVendors[index]
//                                                 .split(':')[1]
//                                                 .trimLeft()
//                                             : '',
//                                         style: const TextStyle(
//                                           color: Colors.blue,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ]),
//                                 // t: const TextStyle(color: Colors.black),
//                               ),
//                               const Spacer(),
//                               CachedNetworkImage(
//                                 imageUrl:
//                                     '${AppInfo.kBaseUrl(stagingSelector: 0)}vendor-logo/${widget.uniqueVendors[index].split('Total')[0].trimRight()}.jpg',
//                                 width: w * .2,
//                                 height: w * .05,
//                                 errorWidget: (_, c, e) => SizedBox(
//                                   child: Container(
//                                     width: w * .3,
//                                     height: w * .1,
//                                     padding: const EdgeInsets.all(2),
//                                     decoration: BoxDecoration(
//                                         color: Colors.black,
//                                         borderRadius: BorderRadius.circular(6)),
//                                     child: Center(
//                                       child: AutoSizeText(
//                                         widget.uniqueVendors[index]
//                                             .split('Total')[0],
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: w * .03,
//                                           letterSpacing: 0,
//                                           // fontFamily: 'JT Marnie Light',
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           verticalSpace(verticalSpace: 10),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
//             child: Text(
//               'Price',
//               style: TextStyle(
//                 fontSize: .06 * w,
//                 fontFamily: 'Futura BdCn BT Bold',
//                 fontWeight: FontWeight.w300,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: OutlinedButton(
//               style: ButtonStyle(
//                 padding: MaterialStateProperty.resolveWith((states) {
//                   return const EdgeInsets.all(4);
//                 }),
//                 shape: MaterialStateProperty.resolveWith(
//                   (states) {
//                     return const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(
//                         Radius.circular(5),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               onPressed: () {
//                 setState(() {
//                   tempPriceSorting != null
//                       ? tempPriceSorting != 1
//                           ? tempPriceSorting = 1
//                           : tempPriceSorting = null
//                       : tempPriceSorting = 1;
//                   // _discountEnabled =
//                   // !_discountEnabled;
//                 });
//               },
//               child: SizedBox(
//                 width: w * .8,
//                 child: Row(
//                   children: [
//                     Checkbox(
//                         value: tempPriceSorting == 1,
//                         onChanged: (values) {
//                           setState(() {
//                             tempPriceSorting != null
//                                 ? tempPriceSorting != 1
//                                     ? tempPriceSorting = 1
//                                     : tempPriceSorting = null
//                                 : tempPriceSorting = 1;
//                             // _discountEnabled =
//                             // !_discountEnabled;
//                           });
//                         }),
//                     const Text(
//                       'Price: Low To High',
//                       style: TextStyle(color: Colors.black),
//                     ),
//                     const Spacer(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           verticalSpace(verticalSpace: 10),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: OutlinedButton(
//               style: ButtonStyle(
//                 padding: MaterialStateProperty.resolveWith((states) {
//                   return const EdgeInsets.all(4);
//                 }),
//                 shape: MaterialStateProperty.resolveWith(
//                   (states) {
//                     return const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(
//                         Radius.circular(5),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               onPressed: () {
//                 setState(() {
//                   tempPriceSorting != null
//                       ? tempPriceSorting != 2
//                           ? tempPriceSorting = 2
//                           : tempPriceSorting = null
//                       : tempPriceSorting = 2;
//                   // _discountEnabled =
//                   // !_discountEnabled;
//                 });
//               },
//               child: SizedBox(
//                 width: w * .8,
//                 child: Row(
//                   children: [
//                     Checkbox(
//                         value: tempPriceSorting == 2,
//                         onChanged: (values) {
//                           setState(() {
//                             tempPriceSorting != null
//                                 ? tempPriceSorting != 2
//                                     ? tempPriceSorting = 2
//                                     : tempPriceSorting = null
//                                 : tempPriceSorting = 2;
//                             // _discountEnabled =
//                             // !_discountEnabled;
//                           });
//                         }),
//                     const Text(
//                       'Price: High To Low',
//                       style: TextStyle(color: Colors.black),
//                     ),
//                     const Spacer(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const Spacer(),
//           Row(
//             children: [
//               horizontalSpace(horizontalSpace: 6),
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * .28,
//                 height: 40,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       widget.vendorSelection(filterVendor);
//                       widget.priceSelection(tempPriceSorting);
//                       widget.submitAction();
//                     });
//                     Navigator.pop(context);
//                   },
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all(Colors.blue),
//                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(25.0),
//                       ),
//                     ),
//                   ),
//                   child: const Text(
//                     'Submit',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               const Spacer(),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 6.0),
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width * .28,
//                   height: 40,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       filterVendor = [];
//                       tempPriceSorting = null;
//                       widget.priceSelection(null);
//                       widget.vendorSelection([]);
//                       widget.clearAction();
//                       setState(() {});
//                       Navigator.pop(context);
//                     },
//                     style: ButtonStyle(
//                       backgroundColor: MaterialStateProperty.all(AppColors.primary),
//                       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25.0),
//                         ),
//                       ),
//                     ),
//                     child: const Text(
//                       'Clear',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           verticalSpace(verticalSpace: 10),
//         ],
//       ),
//       //elevation: 20.0,
//       //semanticLabel: 'endDrawer',
//     );
//   }
//
//   final _scrollController = ScrollController();
// }
