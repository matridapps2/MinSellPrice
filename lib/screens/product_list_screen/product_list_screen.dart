// import 'dart:developer';
// import 'dart:convert';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart';
// import 'package:minsellprice/animation/custom_loader.dart';
// import 'package:minsellprice/app.dart';
// import 'package:minsellprice/colors.dart';
// import 'package:minsellprice/model/product_list_model_new.dart';
// import 'package:minsellprice/reposotory_services/network_reposotory.dart';
// import 'package:minsellprice/screens/InAppBrowser.dart';
// import 'package:minsellprice/screens/ai_price_engine/ai_pricie_engine_screen.dart';
// import 'package:minsellprice/screens/product_list_screen/utils/product_list_screen_api_handler.dart';
// import 'package:minsellprice/screens/widgets/custom_view_button.dart';
// import 'package:minsellprice/screens/widgets/product_screen_2.dart';
// import 'package:minsellprice/services/extra_functions.dart';
// import 'package:minsellprice/size.dart';
// import 'package:sqflite/sqflite.dart';
//
// class ProductListScreen extends StatefulWidget {
//   const ProductListScreen({
//     super.key,
//     required this.titleValue,
//     required this.title,
//     required this.database,
//     required this.dataList,
//     required this.isBrands,
//     required this.isCategory,
//     this.categoryId,
//     this.imageUrl,
//     this.searchProduct,
//     this.productMpn,
//   });
//
//   final String? categoryId, imageUrl, productMpn;
//   final String titleValue, title;
//   final Database database;
//   final List<Map<String, dynamic>> dataList;
//   final bool isBrands, isCategory;
//   final bool? searchProduct;
//
//   @override
//   State<ProductListScreen> createState() => _ProductListScreenState();
// }
//
// class _ProductListScreenState extends State<ProductListScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   final ScrollController _scrollController = ScrollController();
//
//   final FocusNode _focusNode = FocusNode();
//
//   final TextEditingController iconController = TextEditingController();
//   final TextEditingController _searchController = TextEditingController();
//
//   int? priceSorting;
//   int currentPage = 0;
//   int itemsPerPage = 20;
//   int endIndex = 0;
//   int startIndex = 0;
//
//   bool filterSubmitted = true;
//   bool _isLoading = false;
//   bool _isError = false;
//   bool _isEnabled = false;
//
//   List<String> filterVendor = [];
//   List<String> uniqueVendors = [];
//   List<VendorProduct> productList = [];
//   List<VendorProduct> tempProductList = [];
//   List<VendorProduct> finalList = [];
//
//   // Map<String, GetOtherSeller> getOtherSeller = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _initCall();
//   }
//
//   void _initCall() async {
//     _searchController.text = widget.titleValue;
//     _focusNode.addListener(() {
//       setState(() => _isEnabled = _focusNode.hasFocus);
//     });
//     await _getProductList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         _focusNode.unfocus();
//       },
//       child: SafeArea(
//         child: _isLoading
//             ? Scaffold(
//                 appBar: AppBar(
//                   surfaceTintColor: Colors.white,
//                   toolbarHeight: .18 * w,
//                   backgroundColor: Colors.white,
//                   centerTitle: widget.imageUrl == null,
//                   title: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 2.0),
//                     child: widget.imageUrl != null
//                         ? CachedNetworkImage(
//                             imageUrl: widget.imageUrl!,
//                             width: .2 * w,
//                             height: .15 * w,
//                           )
//                         : SizedBox(
//                             width: w * .5,
//                             child: AutoSizeText(
//                               '${widget.title.split(':')[0]}: ${_searchController.text}',
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(fontSize: w * .04),
//                             ),
//                           ),
//                   ),
//                   actions: [
//                     Image.asset(
//                       'assets/shoppingmegamart_app_icon.png',
//                       height: .23 * w,
//                       fit: BoxFit.fill,
//                     ),
//                   ],
//                 ),
//                 body: const Align(
//                   alignment: Alignment.center,
//                   child: CustomLoader(),
//                 ),
//               )
//             : _isError
//                 ? Scaffold(
//                     appBar: AppBar(
//                       surfaceTintColor: Colors.white,
//                       toolbarHeight: .18 * w,
//                       backgroundColor: Colors.white,
//                       centerTitle: widget.imageUrl == null,
//                       title: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 2.0),
//                         child: widget.imageUrl != null
//                             ? CachedNetworkImage(
//                                 imageUrl: widget.imageUrl!,
//                                 width: .2 * w,
//                                 height: .15 * w,
//                               )
//                             : SizedBox(
//                                 width: w * .5,
//                                 child: AutoSizeText(
//                                   '${widget.title.split(':')[0]}: ${_searchController.text}',
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: TextStyle(fontSize: w * .04),
//                                 ),
//                               ),
//                       ),
//                       actions: [
//                         Image.asset(
//                           'assets/shoppingmegamart_app_icon.png',
//                           height: .23 * w,
//                           fit: BoxFit.fill,
//                         ),
//                       ],
//                     ),
//                     body: Center(
//                       child: RichText(
//                         textAlign: TextAlign.center,
//                         text: TextSpan(
//                             text: 'No Product(s) found.\n',
//                             style: TextStyle(
//                                 fontSize: .06 * w,
//                                 fontFamily: 'Futura BdCn BT Bold',
//                                 fontWeight: FontWeight.w300,
//                                 color: Colors.black),
//                             children: [
//                               TextSpan(
//                                 text: 'Return Back',
//                                 recognizer: TapGestureRecognizer()
//                                   ..onTap = () => Navigator.pop(context),
//                                 style: TextStyle(
//                                     fontSize: .06 * w,
//                                     fontFamily: 'Futura BdCn BT Bold',
//                                     fontWeight: FontWeight.w300,
//                                     color: Colors.red),
//                               )
//                             ]),
//                       ),
//                     ),
//                   )
//                 : Scaffold(
//                     key: _scaffoldKey,
//                     endDrawer: FilterMenu(
//                       uniqueVendors: uniqueVendors,
//                       priceSorting: priceSorting,
//                       priceSelection: (int? value) {
//                         setState(() {
//                           priceSorting = value;
//                         });
//                       },
//                       vendorSelection: (List<String> value) {
//                         setState(() {
//                           filterVendor = value;
//                         });
//                       },
//                       filterVendors: filterVendor,
//                       submitAction: () {
//                         sortingOfList(mainList: productList);
//
//                         Fluttertoast.showToast(msg: 'Filter Submitted');
//                       },
//                       clearAction: () {
//                         setState(() {
//                           sortingOfList(mainList: productList);
//                         });
//                       },
//                     ),
//                     appBar: AppBar(
//                       surfaceTintColor: Colors.white,
//                       toolbarHeight: .18 * w,
//                       backgroundColor: Colors.white,
//                       centerTitle: widget.imageUrl == null,
//                       title: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 2.0),
//                         child: widget.imageUrl != null
//                             ? CachedNetworkImage(
//                                 imageUrl: widget.imageUrl!,
//                                 width: .2 * w,
//                                 height: .15 * w,
//                               )
//                             : SizedBox(
//                                 width: w * .54,
//                                 child: widget.searchProduct == true
//                                     ? SizedBox(
//                                         height: 40,
//                                         child: TextFormField(
//                                           controller: _searchController,
//                                           focusNode: _focusNode,
//                                           textInputAction:
//                                               TextInputAction.search,
//                                           onFieldSubmitted: (value) async {
//                                             if (value.length > 3) {
//                                               await _getProductList();
//                                             }
//                                           },
//                                           cursorColor: AppColors.primary,
//                                           decoration: InputDecoration(
//                                             suffixIcon: _isEnabled == false
//                                                 ? const SizedBox.shrink()
//                                                 : InkWell(
//                                                     splashColor: AppColors.primary
//                                                         .withOpacity(.3),
//                                                     onTap: () async {
//                                                       setState(() {
//                                                         _isLoading = true;
//                                                       });
//                                                       await _getProductList();
//                                                       setState(() {
//                                                         _isLoading = false;
//                                                       });
//                                                     },
//                                                     child: Icon(
//                                                       Icons.search,
//                                                       color: AppColors.primary,
//                                                       size: 30,
//                                                     ),
//                                                   ),
//                                             prefixText: 'Looking for: ',
//                                             prefixStyle:
//                                                 TextStyle(fontSize: w * .04),
//                                             contentPadding:
//                                                 const EdgeInsets.symmetric(
//                                               horizontal: 10.0,
//                                             ),
//                                             suffixIconColor: AppColors.primary,
//                                             focusedBorder: OutlineInputBorder(
//                                               borderSide: BorderSide(
//                                                   color: AppColors.primary),
//                                               borderRadius:
//                                                   const BorderRadius.only(
//                                                 topLeft: Radius.circular(5),
//                                                 topRight: Radius.circular(5),
//                                                 bottomRight: Radius.circular(5),
//                                               ),
//                                             ),
//                                             enabledBorder: InputBorder.none,
//                                             disabledBorder: InputBorder.none,
//                                           ),
//                                         ),
//                                       )
//                                     : AutoSizeText(
//                                         widget.title,
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                         style: TextStyle(fontSize: w * .04),
//                                       ),
//                               ),
//                       ),
//                       actions: [
//                         Image.asset(
//                           'assets/shoppingmegamart_app_icon.png',
//                           fit: BoxFit.fill,
//                         ),
//                       ],
//                     ),
//                     body: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         verticalSpace(verticalSpace: 5),
//                         Row(
//                           mainAxisSize: MainAxisSize.max,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             InkWell(
//                               onTap: () {
//                                 _scaffoldKey.currentState!.openEndDrawer();
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 16.0),
//                                 child: Row(
//                                   children: [
//                                     const Icon(Icons.filter_list_alt),
//                                     AutoSizeText(
//                                       'Filters',
//                                       style: TextStyle(
//                                         fontSize: .04 * w,
//                                         fontFamily: 'Futura BdCn BT Bold',
//                                         fontWeight: FontWeight.w300,
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 16.0),
//                               child: AutoSizeText(
//                                 '${tempProductList.length} Product(s)',
//                                 style: TextStyle(
//                                   fontSize: .06 * w,
//                                   fontFamily: 'Futura BdCn BT Bold',
//                                   fontWeight: FontWeight.w300,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         verticalSpace(verticalSpace: 5),
//                         productList.isEmpty
//                             ? SizedBox(
//                                 width: w,
//                                 height: h * .6,
//                                 child: Center(
//                                   child: RichText(
//                                     textAlign: TextAlign.center,
//                                     text: TextSpan(
//                                         text: 'No Product(s) found.\n',
//                                         style: TextStyle(
//                                             fontSize: .06 * w,
//                                             fontFamily: 'Futura BdCn BT Bold',
//                                             fontWeight: FontWeight.w300,
//                                             color: Colors.black),
//                                         children: [
//                                           TextSpan(
//                                             text: 'Return Back',
//                                             recognizer: TapGestureRecognizer()
//                                               ..onTap =
//                                                   () => Navigator.pop(context),
//                                             style: TextStyle(
//                                                 fontSize: .06 * w,
//                                                 fontFamily:
//                                                     'Futura BdCn BT Bold',
//                                                 fontWeight: FontWeight.w300,
//                                                 color: Colors.red),
//                                           )
//                                         ]),
//                                   ),
//                                 ),
//                               )
//                             : Flexible(
//                                 child: Align(
//                                   alignment: Alignment.topCenter,
//                                   child: Scrollbar(
//                                     thickness: 4,
//                                     thumbVisibility: true,
//                                     trackVisibility: true,
//                                     interactive: true,
//                                     controller: _scrollController,
//                                     child: SingleChildScrollView(
//                                       controller: _scrollController,
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 10.0),
//                                         child: Wrap(
//                                           runSpacing: 10,
//                                           children: List.generate(
//                                             finalList.length,
//                                             (index) => Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 4.0),
//                                               child: GestureDetector(
//                                                 onTap: () {
//                                                   Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           SafeArea(
//                                                         child: Scaffold(
//                                                           body:
//                                                               CurrentProductScreen(
//                                                             data: finalList[
//                                                                 index],
//                                                             vendorId: AppInfo
//                                                                 .kVendorId,
//                                                             database:
//                                                                 widget.database,
//                                                             likedValue: 0,
//                                                             notifiedValue: 0,
//                                                             databaseData:
//                                                                 widget.dataList,
//                                                             vendorShortname: '',
//                                                             sisterVendorShortName:
//                                                                 '',
//                                                             // getOtherSeller: getOtherSeller,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   );
//                                                 },
//                                                 child: Card(
//                                                   shape:
//                                                       const RoundedRectangleBorder(
//                                                     side: BorderSide(
//                                                       color: Colors.grey,
//                                                     ),
//                                                   ),
//                                                   child: Container(
//                                                     width: w * .42,
//                                                     color: Colors.white,
//                                                     child: Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         verticalSpace(
//                                                             verticalSpace: 5),
//                                                         Center(
//                                                           child:
//                                                               CachedNetworkImage(
//                                                             imageUrl: finalList[
//                                                                     index]
//                                                                 .productImage,
//                                                             height: w * .3,
//                                                             errorWidget:
//                                                                 (context, _,
//                                                                     c) {
//                                                               return CachedNetworkImage(
//                                                                   imageUrl:
//                                                                       'https://t3.ftcdn.net/jpg/04/34/72/82/360_F_434728286_OWQQvAFoXZLdGHlObozsolNeuSxhpr84.jpg');
//                                                             },
//                                                           ),
//                                                         ),
//                                                         verticalSpace(
//                                                             verticalSpace: 2),
//                                                         Container(
//                                                           constraints:
//                                                               BoxConstraints(
//                                                                   minHeight:
//                                                                       w * .2,
//                                                                   maxHeight:
//                                                                       w * .21),
//                                                           child: Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .only(
//                                                                     left: 8,
//                                                                     right: 10.0,
//                                                                     top: 8),
//                                                             child: Text(
//                                                               finalList[index]
//                                                                   .productName,
//                                                               maxLines: 3,
//                                                               overflow:
//                                                                   TextOverflow
//                                                                       .ellipsis,
//                                                               style: TextStyle(
//                                                                   color: '#222223'
//                                                                       .toColor(),
//                                                                   fontFamily:
//                                                                       'Myriad Arabic',
//                                                                   fontSize:
//                                                                       w * .06,
//                                                                   height: 1,
//                                                                   wordSpacing:
//                                                                       0,
//                                                                   letterSpacing:
//                                                                       0,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w900),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .symmetric(
//                                                                   horizontal:
//                                                                       8.0,
//                                                                   vertical: 3),
//                                                           child: AutoSizeText(
//                                                             'MPN# ${finalList[index].productMpn}',
//                                                             maxLines: 1,
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .ellipsis,
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .black,
//                                                                 fontFamily:
//                                                                     'Segoe UI',
//                                                                 fontSize:
//                                                                     w * .04,
//                                                                 wordSpacing: 0,
//                                                                 letterSpacing:
//                                                                     0,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w500
//
//                                                                 // fontWeight: FontWeight.w900
//                                                                 ),
//                                                           ),
//                                                         ),
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .symmetric(
//                                                                   horizontal:
//                                                                       8.0,
//                                                                   vertical: 5),
//                                                           child: Row(
//                                                             children: [
//                                                               Icon(
//                                                                 Icons.check,
//                                                                 color: '#3b8039'
//                                                                     .toColor(),
//                                                                 size: 23,
//                                                               ),
//                                                               horizontalSpace(
//                                                                   horizontalSpace:
//                                                                       8),
//                                                               Text(
//                                                                 'In Stock',
//                                                                 maxLines: 3,
//                                                                 overflow:
//                                                                     TextOverflow
//                                                                         .ellipsis,
//                                                                 style: TextStyle(
//                                                                     color: '#3b8039'
//                                                                         .toColor(),
//                                                                     fontFamily:
//                                                                         'Segoe UI Bold',
//                                                                     fontSize: w *
//                                                                         .043,
//                                                                     wordSpacing:
//                                                                         2,
//                                                                     letterSpacing:
//                                                                         0,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .normal
//
//                                                                     // fontWeight: FontWeight.w900
//                                                                     ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .symmetric(
//                                                                   horizontal:
//                                                                       8.0,
//                                                                   vertical: 5),
//                                                           child: RichText(
//                                                             text: TextSpan(
//                                                               text:
//                                                                   // finalList[
//                                                                   //         index]
//                                                                   //     .firstVendorPrice == '--' ? getOtherSeller.containsKey('${finalList[index].productId}') ? getOtherSeller['${finalList[index].productId}']!.firstVendorpricePrice: '--' :
//                                                                   finalList[
//                                                                           index]
//                                                                       .firstVendorPrice,
//                                                               style: TextStyle(
//                                                                 color: '#e3121b'
//                                                                     .toColor(),
//                                                                 fontFamily:
//                                                                     'MyriadPro-BoldCond',
//                                                                 fontSize:
//                                                                     w * .08,
//                                                                 wordSpacing: .1,
//                                                                 letterSpacing:
//                                                                     0,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .bold,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .symmetric(
//                                                             horizontal: 8.0,
//                                                           ),
//                                                           child: SizedBox(
//                                                             width: w * .46,
//                                                             child: FittedBox(
//                                                               child: Row(
//                                                                 children: [
//                                                                   Icon(
//                                                                     Icons
//                                                                         .local_shipping,
//                                                                     color: '#0678cb'
//                                                                         .toColor(),
//                                                                   ),
//                                                                   horizontalSpace(
//                                                                       horizontalSpace:
//                                                                           3),
//                                                                   AutoSizeText(
//                                                                     finalList[index].firstVendorPriceShipping ==
//                                                                                 '--' ||
//                                                                             finalList[index].firstVendorPriceShipping ==
//                                                                                 '\$0.00'
//                                                                         ? ' Free Shipping'
//                                                                         : 'Shipping(${finalList[index].firstVendorPriceShipping})',
//                                                                     maxLines: 3,
//                                                                     overflow:
//                                                                         TextOverflow
//                                                                             .ellipsis,
//                                                                     style: TextStyle(
//                                                                         color: finalList[index].firstVendorPriceShipping == '--' || finalList[index].firstVendorPriceShipping == '\$0.00'
//                                                                             ? '#3b8039'
//                                                                                 .toColor()
//                                                                             : '#0678cb'
//                                                                                 .toColor(),
//                                                                         fontFamily:
//                                                                             'Segoe UI Bold',
//                                                                         fontSize: w *
//                                                                             .042,
//                                                                         wordSpacing:
//                                                                             2,
//                                                                         letterSpacing:
//                                                                             .4,
//                                                                         fontWeight:
//                                                                             FontWeight.normal
//
//                                                                         // fontWeight: FontWeight.w900
//                                                                         ),
//                                                                   )
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         verticalSpace(
//                                                             verticalSpace: 11),
//                                                         /*                  Center(
//                                                                       child:
//                                                                           CachedNetworkImage(
//                                                                         imageUrl:
//                                                                             '${AppInfo.kBaseUrl(stagingSelector: 0)}vendor-logo/${finalList[index].firstVendorName}.jpg',
//                                                                         height:
//                                                                             h * 0.045,
//                                                                         fit: BoxFit
//                                                                             .fill,
//                                                                         errorWidget: (_,
//                                                                                 c,
//                                                                                 e) =>
//                                                                             SizedBox(
//                                                                           child:
//                                                                               Container(
//                                                                             width: w *
//                                                                                 .42,
//                                                                             padding:
//                                                                                 const EdgeInsets
//                                                                                     .all(
//                                                                                     2),
//                                                                             color: Colors
//                                                                                 .black,
//                                                                             child:
//                                                                                 Center(
//                                                                               child:
//                                                                                   AutoSizeText(
//                                                                                 finalList[index]
//                                                                                     .firstVendorName,
//                                                                                 maxLines:
//                                                                                     1,
//                                                                                 textAlign:
//                                                                                     TextAlign.center,
//                                                                                 style:
//                                                                                     GoogleFonts.albertSans(
//                                                                                   color:
//                                                                                       Colors.white,
//                                                                                   fontSize:
//                                                                                       w * .055,
//                                                                                   letterSpacing:
//                                                                                       0,
//                                                                                   fontWeight:
//                                                                                       FontWeight.bold,
//                                                                                   // fontFamily: 'JT Marnie Light',
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                     verticalSpace(
//                                                                         verticalSpace:
//                                                                             5),*/
//                                                         Center(
//                                                           child: InkWell(
//                                                             onTap: () async =>
//                                                                 await MyInAppBrowser()
//                                                                     .openUrlRequest(
//                                                               urlRequest:
//                                                                   URLRequest(
//                                                                 url: WebUri(
//                                                                   // finalList[index].firstVendorUrl == '--' ? getOtherSeller.containsKey('${finalList[index].productId}') ? getOtherSeller['${finalList[index].productId}']!.firstVendorUrl : '--' :
//                                                                   finalList[index]
//                                                                           .firstVendorUrl +
//                                                                       '?utm_source=shoppingmegamart.com&utm_medium=mobile-app',
//                                                                 ),
//                                                               ),
//                                                               options:
//                                                                   InAppBrowserClassOptions(
//                                                                 crossPlatform:
//                                                                     InAppBrowserOptions(
//                                                                   toolbarTopBackgroundColor:
//                                                                       const Color
//                                                                           .fromARGB(
//                                                                           255,
//                                                                           237,
//                                                                           63,
//                                                                           69),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             child: BuyAtButton(
//                                                                 imageUrl:
//                                                                     // finalList[index].firstVendorName == '--' ? getOtherSeller.containsKey('${finalList[index].productId}') ? getOtherSeller['${finalList[index].productId}']!.firstVendorName : '--' :
//                                                                     finalList[
//                                                                             index]
//                                                                         .firstVendorName)
//                                                             /*Container(
//                                                                           width:
//                                                                               w * .42,
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             border:
//                                                                                 Border
//                                                                                     .all(
//                                                                               color: Colors
//                                                                                   .blue,
//                                                                               width:
//                                                                                   3,
//                                                                             ),
//                                                                             borderRadius:
//                                                                                 BorderRadius
//                                                                                     .circular(
//                                                                               3,
//                                                                             ),
//                                                                           ),
//                                                                           child:
//                                                                               Padding(
//                                                                             padding: const EdgeInsets
//                                                                                 .symmetric(
//                                                                                 vertical:
//                                                                                     10.0),
//                                                                             child:
//                                                                                 Row(
//                                                                               mainAxisAlignment:
//                                                                                   MainAxisAlignment.center,
//                                                                               crossAxisAlignment:
//                                                                                   CrossAxisAlignment.center,
//                                                                               children: [
//                                                                                 Image
//                                                                                     .asset(
//                                                                                   'assets/images/world-wide-web.png',
//                                                                                   color:
//                                                                                       '#0678cb'.toColor(),
//                                                                                   height:
//                                                                                       20,
//                                                                                   width:
//                                                                                       20,
//                                                                                   // weight: 10,
//                                                                                 ),
//                                                                                 horizontalSpace(
//                                                                                     horizontalSpace: 15),
//                                                                                 AutoSizeText(
//                                                                                   'Visit'.toUpperCase(),
//                                                                                   style:
//                                                                                       TextStyle(
//                                                                                     color: '#0678cb'.toColor(),
//                                                                                     fontFamily: 'MyriadPro-BoldCond',
//                                                                                     fontSize: w * .043,
//                                                                                     wordSpacing: .1,
//                                                                                     letterSpacing: 0,
//                                                                                     fontWeight: FontWeight.bold,
//                                                                                   ),
//                                                                                 )
//                                                                               ],
//                                                                             ),
//                                                                           ),
//                                                                         )*/
//                                                             ,
//                                                           ),
//                                                         ),
//                                                         verticalSpace(
//                                                             verticalSpace: 15)
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                         verticalSpace(verticalSpace: 5),
//                         tempProductList.length > itemsPerPage
//                             ? Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 mainAxisSize: MainAxisSize.max,
//                                 children: <Widget>[
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 8.0),
//                                     child: ElevatedButton(
//                                       style: ButtonStyle(
//                                         minimumSize: MaterialStateProperty
//                                             .resolveWith<Size>(
//                                                 (states) => Size(w * .3, 40)),
//                                         maximumSize: MaterialStateProperty
//                                             .resolveWith<Size>(
//                                                 (states) => Size(w * .3, 50)),
//                                         backgroundColor: MaterialStateProperty
//                                             .resolveWith<Color>(
//                                           (Set<MaterialState> states) {
//                                             return currentPage == 0
//                                                 ? Colors.grey
//                                                 : '#d90310'.toColor();
//                                           },
//                                         ),
//                                         shape: MaterialStateProperty
//                                             .resolveWith<OutlinedBorder>(
//                                           (states) => RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(
//                                               10,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       onPressed: currentPage == 0
//                                           ? null
//                                           : () {
//                                               setState(() {
//                                                 currentPage--;
//                                                 startIndex =
//                                                     currentPage * itemsPerPage;
//                                                 endIndex = (startIndex +
//                                                             itemsPerPage >
//                                                         tempProductList.length)
//                                                     ? tempProductList.length
//                                                     : startIndex + itemsPerPage;
//                                                 finalList =
//                                                     tempProductList.sublist(
//                                                         startIndex, endIndex);
//                                               });
//                                             },
//                                       child: Text(
//                                         'Previous ($currentPage)',
//                                         maxLines: 1,
//                                         style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: w * .03),
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 8.0),
//                                     child: ElevatedButton(
//                                       style: ButtonStyle(
//                                         minimumSize: MaterialStateProperty
//                                             .resolveWith<Size>(
//                                                 (states) => Size(w * .3, 40)),
//                                         maximumSize: MaterialStateProperty
//                                             .resolveWith<Size>(
//                                                 (states) => Size(w * .3, 50)),
//                                         backgroundColor: MaterialStateProperty
//                                             .resolveWith<Color>(
//                                           (Set<MaterialState> states) {
//                                             return endIndex ==
//                                                     tempProductList.length
//                                                 ? Colors.grey
//                                                 : '#d90310'.toColor();
//                                           },
//                                         ),
//                                         shape: MaterialStateProperty
//                                             .resolveWith<OutlinedBorder>(
//                                           (states) => RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(
//                                               10,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       onPressed: endIndex ==
//                                               tempProductList.length
//                                           ? null
//                                           : () {
//                                               _scrollController.animateTo(0,
//                                                   duration: const Duration(
//                                                       milliseconds: 500),
//                                                   curve: Curves.linear);
//                                               setState(() {
//                                                 currentPage++;
//                                                 startIndex =
//                                                     currentPage * itemsPerPage;
//                                                 endIndex = (startIndex +
//                                                             itemsPerPage >
//                                                         tempProductList.length)
//                                                     ? tempProductList.length
//                                                     : startIndex + itemsPerPage;
//                                                 finalList =
//                                                     tempProductList.sublist(
//                                                         startIndex, endIndex);
//                                               });
//                                             },
//                                       child: Text(
//                                         'Next(${currentPage + 1})',
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             : const SizedBox(),
//                         verticalSpace(verticalSpace: 5),
//                       ],
//                     ),
//                   ),
//       ),
//     );
//   }
//
//   Future<void> _getProductList() async {
//     if (mounted) {
//       setState(() => _isLoading = true);
//     }
//     try {
//       var response = await ProductListScreenApiHandler.getProductList(
//         productMpn: widget.productMpn ?? '',
//         productName: _searchController.text,
//         isBrands: widget.isBrands,
//         isCategory: widget.isCategory,
//         searchProduct: widget.searchProduct == true,
//         titleValue: widget.titleValue,
//       );
//
//       if (response == null) {
//         setState(() {
//           _isError = true;
//           _isLoading = false;
//         });
//       } else {
//         productList = response.vendorProducts;
//         // getOtherSeller = response.getOtherSeller;
//
//         List<VendorProduct> list =
//             productList.where((e) => e.firstVendorPrice == '--').toList();
//
//         // for (VendorProduct x in list) {
//         //   if (getOtherSeller.containsKey(x.productId)) {
//         //     if (getOtherSeller[x.productId]!.firstVendorpricePrice == '--') {
//         //       productList.removeWhere((e) => e.productId == x.productId);
//         //     }
//         //   }
//         // }
//
//         tempProductList = productList;
//         startIndex = currentPage * itemsPerPage;
//         endIndex = (startIndex + itemsPerPage > tempProductList.length)
//             ? tempProductList.length
//             : startIndex + itemsPerPage;
//         finalList = tempProductList.sublist(startIndex, endIndex);
//         uniqueVendors = getUniqueBrands(
//           productList,
//         );
//         uniqueVendors =
//             uniqueVendors.where((element1) => element1 != '--').toList();
//
//         List<String> tempList = [];
//
//         for (final vendor in uniqueVendors) {
//           tempList.add(
//               '$vendor Total Product(s): ${productList.where((element) => element.firstVendorName == vendor).toList().length} ');
//         }
//         uniqueVendors.clear();
//         uniqueVendors = tempList;
//         filterVendor = [];
//         priceSorting = null;
//         _isLoading = false;
//         setState(() {});
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _isError = true;
//       });
//       log('Error in fetching Product list: $e');
//     }
//   }
//
//   void sortingOfList(
//       {required List< /*ProductListModel*/ VendorProduct> mainList}) {
//     setState(() {
//       if (filterVendor.isNotEmpty) {
//         tempProductList = mainList.where((product) {
//           return filterVendor.contains(product.firstVendorName);
//         }).toList();
//       } else {
//         tempProductList = mainList;
//       }
//
//       if (priceSorting != null) {
//         if (priceSorting == 1) {
//           tempProductList.sort((a, b) =>
//               extractDoubleFromString(a.firstVendorPrice)
//                   .compareTo(extractDoubleFromString(b.firstVendorPrice)));
//         } else {
//           tempProductList.sort((a, b) =>
//               extractDoubleFromString(b.firstVendorPrice)
//                   .compareTo(extractDoubleFromString(a.firstVendorPrice)));
//         }
//       } else if (priceSorting == null && filterVendor.isNotEmpty) {
//         tempProductList.clear();
//         tempProductList = mainList.where((product) {
//           return filterVendor.contains(product.firstVendorName);
//         }).toList();
//       } else if (filterVendor.isEmpty && priceSorting == null) {
//         tempProductList = mainList;
//       }
//
//       currentPage = 0;
//       startIndex = currentPage * itemsPerPage;
//       endIndex = (startIndex + itemsPerPage > tempProductList.length)
//           ? tempProductList.length
//           : startIndex + itemsPerPage;
//       finalList = tempProductList.sublist(startIndex, endIndex);
//     });
//   }
//
//   showBottomModalDialog({
//     required BuildContext context,
//     required List<Widget> children,
//   }) {
//     showCupertinoModalPopup(
//         barrierDismissible: false,
//         context: context,
//         builder: (BuildContext modalContext) => Container(
//             height: h * 0.90,
//             decoration: const BoxDecoration(
//               borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
//             ),
//             child: Material(
//                 borderRadius:
//                     const BorderRadius.vertical(top: Radius.circular(25.0)),
//                 child: Column(
//                     mainAxisSize: MainAxisSize.max, children: children))));
//   }
// }
//
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
//                             // _discountEnabled =
//                             // !_discountEnabled;
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
//                                         text:
//                                             '\n${widget.uniqueVendors[index].split('Total')[1].trimLeft().split(':')[0]}: ',
//                                         style: const TextStyle(
//                                           color: Colors.blue,
//                                           fontWeight: FontWeight.normal,
//                                         ),
//                                       ),
//                                       TextSpan(
//                                         text: widget.uniqueVendors[index]
//                                             .split(':')[1]
//                                             .trimLeft(),
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
