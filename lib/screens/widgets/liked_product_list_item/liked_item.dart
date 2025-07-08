// import 'dart:convert';
//
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:minsellprice/app.dart';
// import 'package:minsellprice/model/product_list_model.dart';
// import 'package:minsellprice/screens/InAppBrowser.dart';
// import 'package:minsellprice/screens/widgets/custom_view_button.dart';
// import 'package:minsellprice/screens/widgets/liked_product_list_item/unlike_button.dart';
// import 'package:minsellprice/services/extra_functions.dart';
// import 'package:minsellprice/size.dart';
// import 'package:sqflite/sqlite_api.dart';
//
// class GridTilesProducts extends StatefulWidget {
//   final ProductListModel model;
//
//   final int vendorId, likedValue, notifiedValue;
//   final Database database;
//   final String vendorShortName, sisterVendorShortName;
//   final VoidCallback futureBuilderTriggerMethod;
//
//   const GridTilesProducts({
//     Key? key,
//     required this.model,
//     required this.vendorId,
//     required this.likedValue,
//     required this.notifiedValue,
//     required this.database,
//     required this.futureBuilderTriggerMethod,
//     required this.vendorShortName,
//     required this.sisterVendorShortName,
//   }) : super(key: key);
//
//   @override
//   State<GridTilesProducts> createState() => _GridTilesProductsState();
// }
//
// class _GridTilesProductsState extends State<GridTilesProducts> {
//   @override
//   Widget build(BuildContext context) {
//     if (widget.model == null) {
//       return const SizedBox();
//     }
//
//     return InkWell(
//       onTap: () async {
//         if (widget.model != null && context.mounted) {
//           // await Navigator.of(context)
//           //     .push(
//           //       MaterialPageRoute(
//           //         builder: (context) => PopScope(
//           //           canPop: true,
//           //           child: Scaffold(
//           //           //   body: CurrentProductScreen(
//           //           //     prevData: widget.model,
//           //           //     vendorId: widget.vendorId,
//           //           //     database: widget.database,
//           //           //     likedValue: widget.likedValue,
//           //           //     notifiedValue: widget.notifiedValue,
//           //           //     databaseData: const [],
//           //           //     vendorShortname: widget.vendorShortName,
//           //           //     sisterVendorShortName: widget.sisterVendorShortName,
//           //           //   ),
//           //           // ),
//           //         ),
//           //       ),
//           //     )
//           //     .whenComplete(() => widget.futureBuilderTriggerMethod());
//         }
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 4.0),
//         child: Stack(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 // Navigator.push(
//                 //   context,
//                   // MaterialPageRoute(
//                   //   builder: (context) => SafeArea(
//                   //     child: Scaffold(
//                   //       body: CurrentProductScreen(
//                   //         prevData: widget.model,
//                   //         vendorId: AppInfo.kVendorId,
//                   //         database: widget.database,
//                   //         likedValue: widget.likedValue,
//                   //         notifiedValue: widget.notifiedValue,
//                   //         databaseData: const [],
//                   //         vendorShortname: '',
//                   //         sisterVendorShortName: '',
//                   //       ),
//                   //     ),
//                   //   ),
//                   // ),
//                 // );
//               },
//               child: Card(
//                 shape: const RoundedRectangleBorder(
//                   side: BorderSide(
//                     color: Colors.grey,
//                   ),
//                 ),
//                 child: Container(
//                   width: w * .44,
//                   color: Colors.white,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(width: 5),
//                       Center(
//                         child: CachedNetworkImage(
//                           imageUrl: widget.model.productImage ?? '',
//                           height: w * .3,
//                           errorWidget: (context, _, c) {
//                             return CachedNetworkImage(
//                                 imageUrl:
//                                     'https://t3.ftcdn.net/jpg/04/34/72/82/360_F_434728286_OWQQvAFoXZLdGHlObozsolNeuSxhpr84.jpg');
//                           },
//                         ),
//                       ),
//                       SizedBox(width: 2),
//                       Container(
//                         constraints: BoxConstraints(
//                             minHeight: w * .2, maxHeight: w * .21),
//                         child: Padding(
//                           padding: const EdgeInsets.only(
//                               left: 8, right: 10.0, top: 8),
//                           child: Text(
//                             widget.model.productName,
//                             maxLines: 3,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                                 color: '#222223'.toColor(),
//                                 fontFamily: 'Myriad Arabic',
//                                 fontSize: w * .06,
//                                 height: 1,
//                                 wordSpacing: 0,
//                                 letterSpacing: 0,
//                                 fontWeight: FontWeight.w900),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 3),
//                         child: AutoSizeText(
//                           'MPN# ${widget.model.productMpn}',
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontFamily: 'Segoe UI',
//                               fontSize: w * .04,
//                               wordSpacing: 0,
//                               letterSpacing: 0,
//                               fontWeight: FontWeight.w500
//
//                               // fontWeight: FontWeight.w900
//                               ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 5),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.check,
//                               color: '#3b8039'.toColor(),
//                               size: 23,
//                             ),
//                             horizontalSpace(horizontalSpace: 8),
//                             Text(
//                               'In Stock',
//                               maxLines: 3,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                   color: '#3b8039'.toColor(),
//                                   fontFamily: 'Segoe UI Bold',
//                                   fontSize: w * .043,
//                                   wordSpacing: 2,
//                                   letterSpacing: 0,
//                                   fontWeight: FontWeight.normal
//
//                                   // fontWeight: FontWeight.w900
//                                   ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 5),
//                         child: RichText(
//                           text: TextSpan(
//                             text: keepSingleDollarSign(
//                                 widget.model.firstVendorPrice),
//                             style: TextStyle(
//                               color: '#e3121b'.toColor(),
//                               fontFamily: 'MyriadPro-BoldCond',
//                               fontSize: w * .08,
//                               wordSpacing: .1,
//                               letterSpacing: 0,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8.0,
//                         ),
//                         child: SizedBox(
//                           width: w * .46,
//                           child: FittedBox(
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.local_shipping,
//                                   color: '#0678cb'.toColor(),
//                                 ),
//                                 horizontalSpace(horizontalSpace: 3),
//                                 AutoSizeText(
//                                   widget.model.firstVendorPriceShipping ==
//                                               '--' ||
//                                           widget.model
//                                                   .firstVendorPriceShipping ==
//                                               '\$0.00'
//                                       ? ' Free Shipping'
//                                       : 'Shipping(${keepSingleDollarSign(widget.model.firstVendorPriceShipping)})',
//                                   maxLines: 3,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: TextStyle(
//                                       color: widget.model
//                                                       .firstVendorPriceShipping ==
//                                                   '--' ||
//                                               widget.model
//                                                       .firstVendorPriceShipping ==
//                                                   '\$0.00'
//                                           ? '#3b8039'.toColor()
//                                           : '#0678cb'.toColor(),
//                                       fontFamily: 'Segoe UI Bold',
//                                       fontSize: w * .042,
//                                       wordSpacing: 2,
//                                       letterSpacing: .4,
//                                       fontWeight: FontWeight.normal
//
//                                       // fontWeight: FontWeight.w900
//                                       ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 11),
//                       /*                  Center(
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
//                       Center(
//                         child: InkWell(
//                           onTap: () async =>
//                               await MyInAppBrowser().openUrlRequest(
//                             urlRequest: URLRequest(
//                               url: WebUri(
//                                 widget.model.firstVendorUrl +
//                                     '?utm_source=shoppingmegamart.com&utm_medium=mobile-app',
//                               ),
//                             ),
//                             options: InAppBrowserClassOptions(
//                               crossPlatform: InAppBrowserOptions(
//                                 toolbarTopBackgroundColor: Colors.blue,
//                               ),
//                             ),
//                           ),
//                           child: BuyAtButton(
//                               imageUrl: widget.model.firstVendorName)
//                           /*Container(
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
//                           ,
//                         ),
//                       ),
//                       SizedBox(width: 15)
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Align(
//               alignment: Alignment.topRight,
//               // child: UnlikeButton(
//               //   database: widget.database,
//               //   callback: widget.futureBuilderTriggerMethod,
//               //   vendorId: widget.vendorId,
//               //   productId: widget.model.productId,
//               //   isNotified: widget.notifiedValue,
//               //   productData: jsonEncode(
//               //     widget.model.toJson(),
//               //   ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
