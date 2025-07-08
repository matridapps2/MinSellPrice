// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:delayed_display/delayed_display.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:minsellprice/app.dart';
// import 'package:minsellprice/model/product_list_model.dart';
// import 'package:minsellprice/screens/sample_product.dart';
// import 'package:minsellprice/size.dart';
//
// import 'InAppBrowser.dart';
// import 'my_text_styles.dart';
//
// const Duration _kExpand = Duration(milliseconds: 200);
//
// class CustomProductCard extends StatefulWidget {
//   const CustomProductCard(
//       {Key? key,
//       required this.data,
//       required bool showPrice,
//       required bool showAllCompetitors,
//       required bool showRT})
//       : _showPrice = showPrice,
//         _showAllComp = showAllCompetitors,
//         _showRT = showRT,
//         super(key: key);
//   final ProductListModel data;
//   final bool _showPrice, _showAllComp, _showRT;
//
//   @override
//   State<CustomProductCard> createState() => _CustomProductCardState();
// }
//
// class _CustomProductCardState extends State<CustomProductCard>
//     with TickerProviderStateMixin {
//   final bool _isExpanded = false;
//   static final Animatable<double> _halfTween =
//       Tween<double>(begin: 0.0, end: 0.5);
//   static final Animatable<double> _easeInTween =
//       CurveTween(curve: Curves.easeIn);
//   late AnimationController _finalPriceController, _finalPriceSlideController;
//   late Animation<Offset> _titleAnimation,
//       _titleAnimation2,
//       _finalPriceSlideAnimation;
//   late Animation<double> _finalPriceAnimation;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//
//     _finalPriceController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 3),
//     )..addListener(() {
//         setState(() {});
//       });
//     _finalPriceSlideController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 3),
//     )..addListener(() {
//         setState(() {});
//       });
//     _finalPriceAnimation = Tween<double>(begin: 0, end: 1).animate(
//         CurvedAnimation(
//             parent: _finalPriceController, curve: Curves.easeOutSine));
//     _finalPriceSlideAnimation =
//         Tween<Offset>(begin: const Offset(0, .1), end: const Offset(0, -0.03))
//             .animate(CurvedAnimation(
//                 parent: _finalPriceSlideController, curve: Curves.easeOutSine));
//     _finalPriceController.forward();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 5,
//       child: AnimatedContainer(
//         // height: _height,
//         decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
//         duration: _kExpand,
//         child: Padding(
//           padding: const EdgeInsets.all(4.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(
//                 height: 5,
//               ),
//               AutoSizeText(
//                 widget.data.productName ?? '',
//                 maxLines: 3,
//                 textAlign: TextAlign.start,
//                 style: MyTextStyle.customProductListNameStyle1(),
//               ),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   _buildLeadingImage(item: widget.data.productImage),
//                   Expanded(
//                     child: Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(top: 5.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8.0,
//                                 ),
//                                 child: Image.asset(
//                                   widget.data.vendorName
//                                           .toLowerCase()
//                                           .contains('af')
//                                       ? 'assets/af-supply.png'
//                                       : 'assets/home-perfect.png',
//                                   width: 0.3 * w,
//                                   height: 0.07 * w,
//                                   fit: BoxFit.fill,
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 5,
//                         ),
//                         Row(
//                           mainAxisSize: MainAxisSize.max,
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             FadeTransition(
//                               opacity: _finalPriceAnimation,
//                               child: SlideTransition(
//                                 position: _finalPriceSlideAnimation,
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8.0),
//                                   child: Tooltip(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey,
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     textAlign: TextAlign.center,
//                                     richMessage: TextSpan(
//                                       text: 'Final Price\n',
//                                       style: GoogleFonts.montserrat(
//                                         fontSize: 0.035 * w,
//                                         color: Colors.blue,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       children: [
//                                         TextSpan(
//                                           text: 'Base Price + Shipping\n',
//                                           style: GoogleFonts.montserrat(
//                                             fontSize: 0.035 * w,
//                                             color: Colors.black,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         TextSpan(
//                                           text: '- Discount',
//                                           style: GoogleFonts.montserrat(
//                                             fontSize: 0.035 * w,
//                                             color: Colors.black,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     triggerMode: TooltipTriggerMode.tap,
//                                     child: RichText(
//                                       text: TextSpan(
//                                         text:
//                                             '\$${widget.data.vendorPriceFinalPrice}\n',
//                                         style: GoogleFonts.montserrat(
//                                           fontSize: 0.04 * w,
//                                           color: Colors.blue,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         children: [
//                                           TextSpan(
//                                             text:
//                                                 '\$${widget.data.vendorpricePrice}',
//                                             style: GoogleFonts.montserrat(
//                                               fontSize: 0.035 * w,
//                                               color: Colors.black,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                             children: [
//                                               TextSpan(
//                                                 text:
//                                                     ' + \$${widget.data.vendorpriceShipping}',
//                                                 style: GoogleFonts.montserrat(
//                                                   fontSize: 0.035 * w,
//                                                   color: Colors.black,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                               TextSpan(
//                                                 text: widget.data
//                                                             .extraDiscount ==
//                                                         '0.00'
//                                                     ? ''
//                                                     : ' - \$${widget.data.extraDiscount}',
//                                                 style: GoogleFonts.montserrat(
//                                                   fontSize: 0.035 * w,
//                                                   color: Colors.black,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ],
//                                           )
//                                         ],
//                                       ),
//                                       textAlign:
//                                           widget.data.extraDiscount == '0.00'
//                                               ? TextAlign.center
//                                               : TextAlign.start,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   // _icon(context: context)
//                 ],
//               ),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   Padding(
//                       padding: const EdgeInsets.only(left: 4, right: 4.0),
//                       child: RichText(
//                         text: TextSpan(
//                           text: widget.data.brandName.toUpperCase(),
//                           style: GoogleFonts.montserrat(
//                             fontSize: 0.04 * w,
//                             color: Colors.green,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       )
//
//                       // AutoSizeText(
//                       //   'Brand Name:  ${widget.data.brandName}',
//                       //   style: MyTextStyle.customProductUrlStyle(),
//                       // ),
//                       ),
//                   Container(
//                     width: 2,
//                     height: 15,
//                     color: Colors.black,
//                   ),
//                   Flexible(
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 4, right: 4.0),
//                       child: RichText(
//                         maxLines: 1,
//                         softWrap: true,
//                         text: TextSpan(
//                           text: widget.data.vendorSku.isEmpty
//                               ? widget.data.secondarySku
//                               : widget.data.vendorSku,
//                           style: GoogleFonts.montserrat(
//                             fontSize: 0.04 * w,
//                             color: Colors.green,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 15,
//               ),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         width: .2 * w,
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4.0),
//                             child: Text(
//                               'ATP',
//                               style: GoogleFonts.montserrat(
//                                 fontSize: 0.04 * w,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Card(
//                         color: Colors.green,
//                         child: SizedBox(
//                           width: .2 * w,
//                           child: Center(
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 8.0),
//                               child: Text(
//                                 widget.data.atp.isEmpty ||
//                                         widget.data.atp.contains('null')
//                                     ? '0'
//                                     : widget.data.atp,
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 0.045 * w,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         width: .2 * w,
//                         child: Center(
//                             child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                           child: Text(
//                             'Sales',
//                             style: GoogleFonts.montserrat(
//                               fontSize: 0.04 * w,
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         )),
//                       ),
//                       Card(
//                         color: double.parse(widget.data.sales.isEmpty
//                                     ? '0.0'
//                                     : widget.data.sales) >
//                                 0
//                             ? Colors.green
//                             : Colors.red,
//                         child: SizedBox(
//                           width: .2 * w,
//                           child: Center(
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 8.0),
//                               child: Text(
//                                 widget.data.sales.isEmpty
//                                     ? '0'
//                                     : double.parse(widget.data.sales)
//                                         .toInt()
//                                         .toString(),
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 0.045 * w,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         width: .2 * w,
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4.0),
//                             child: AutoSizeText(
//                               'Sales-ATP',
//                               maxLines: 1,
//                               style: GoogleFonts.montserrat(
//                                 fontSize: 0.04 * w,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Card(
//                         color: returnSales2AtpColor(
//                             ratioValue: widget.data.saleAtpRatio.isEmpty
//                                 ? '0.0'
//                                 : widget.data.saleAtpRatio),
//                         child: SizedBox(
//                           width: .2 * w,
//                           child: Center(
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 8.0),
//                               child: Text(
//                                 widget.data.saleAtpRatio.isEmpty
//                                     ? '0'
//                                     : widget.data.saleAtpRatio,
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 0.045 * w,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         width: .2 * w,
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4.0),
//                             child: Text(
//                               'Age',
//                               style: GoogleFonts.montserrat(
//                                 fontSize: 0.04 * w,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Card(
//                         color: returnAgeColor(
//                             daysValue: widget.data.days.isEmpty
//                                 ? '0'
//                                 : widget.data.days),
//                         child: SizedBox(
//                           width: .2 * w,
//                           child: Center(
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 8.0),
//                               // padding: EdgeInsets.all(8.0),
//                               child: Text(
//                                 widget.data.days.isEmpty
//                                     ? '0'
//                                     : widget.data.days,
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 0.045 * w,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         width: .2 * w,
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4.0),
//                             child: AutoSizeText(
//                               'Current Dis',
//                               maxLines: 1,
//                               style: GoogleFonts.montserrat(
//                                 fontSize: 0.04 * w,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 5,
//                       ),
//                       Card(
//                         color: widget.data.currentDiscount.isEmpty ||
//                                 widget.data.currentDiscount.contains('null')
//                             ? Colors.red
//                             : Colors.green,
//                         child: SizedBox(
//                           width: .2 * w,
//                           height: .1 * w,
//                           child: Center(
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 8.0),
//                               child: AutoSizeText(
//                                 '${widget.data.currentDiscount.isEmpty || widget.data.currentDiscount.contains('null') ? '0' : widget.data.currentDiscount}%',
//                                 maxLines: 1,
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 0.045 * w,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         width: .2 * w,
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4.0),
//                             child: AutoSizeText(
//                               'MSRP',
//                               maxLines: 1,
//                               style: GoogleFonts.montserrat(
//                                 fontSize: 0.04 * w,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Card(
//                         color: widget.data.msrp.isEmpty
//                             ? Colors.red
//                             : Colors.green,
//                         child: SizedBox(
//                           width: .2 * w,
//                           height: .1 * w,
//                           child: Center(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   vertical: 8.0, horizontal: 4),
//                               child: AutoSizeText(
//                                 '\$${widget.data.msrp.isEmpty ? '0' : widget.data.msrp}',
//                                 maxLines: 1,
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 0.045 * w,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         width: .2 * w,
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4.0),
//                             child: Text(
//                               'MAP',
//                               style: GoogleFonts.montserrat(
//                                 fontSize: 0.04 * w,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Card(
//                         color: widget.data.mapPrice == '0.00'
//                             ? Colors.red
//                             : double.parse(widget.data.mapPrice.isEmpty
//                                         ? '0.0'
//                                         : widget.data.mapPrice) >
//                                     double.parse(
//                                         widget.data.vendorPriceFinalPrice)
//                                 ? Colors.orangeAccent
//                                 : Colors.red,
//                         child: SizedBox(
//                           width: .2 * w,
//                           height: .1 * w,
//                           child: Center(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   vertical: 8.0, horizontal: 2),
//                               child: AutoSizeText(
//                                 '\$${widget.data.mapPrice.isEmpty ? '0' : widget.data.mapPrice}',
//                                 maxLines: 1,
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 0.045 * w,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         width: .2 * w,
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4.0),
//                             child: Text(
//                               'MSP',
//                               style: GoogleFonts.montserrat(
//                                 fontSize: 0.04 * w,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Card(
//                         color: widget.data.msp.isEmpty
//                             ? Colors.red
//                             : double.parse(widget.data.msp.isEmpty
//                                         ? '0'
//                                         : widget.data.msp
//                                             .replaceAll(',', '')) >=
//                                     double.parse(widget
//                                         .data.vendorPriceFinalPrice
//                                         .replaceAll(',', ''))
//                                 ? Colors.red
//                                 : Colors.green,
//                         child: SizedBox(
//                           width: .2 * w,
//                           height: .1 * w,
//                           child: Center(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   vertical: 8.0, horizontal: 2),
//                               // padding: EdgeInsets.all(8.0),
//                               child: AutoSizeText(
//                                 '\$${widget.data.msp.isEmpty ? '0' : widget.data.msp}',
//                                 maxLines: 1,
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 0.045 * w,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 5,
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(
//                     top: 10.0, bottom: 2, left: 8, right: 8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     AutoSizeText(
//                       'Lowest ',
//                       style: MyTextStyle.customProductUrlStyle(),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(2.0),
//                       child: Image.network(
//                         '${AppInfo.kBaseUrl(stagingSelector: 0)}vendor-logo/${widget.data.firstVendorName}.jpg',
//                         errorBuilder: (_, c, cv) => Text(
//                           widget.data.firstVendorName,
//                           style: GoogleFonts.montserrat(
//                             fontSize: 0.035 * w,
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         width: 0.23 * w,
//                         height: 0.09 * w,
//                         fit: BoxFit.fill,
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     RichText(
//                       text: TextSpan(
//                         text: '\$${widget.data.firstVendorPrice}\n',
//                         style: GoogleFonts.montserrat(
//                           fontSize: 0.043 * w,
//                           color: Colors.red,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         children: [
//                           TextSpan(
//                             text: '\$${widget.data.firstVendorBasePrice}',
//                             style: GoogleFonts.montserrat(
//                               fontSize: 0.035 * w,
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             children: [
//                               TextSpan(
//                                 text:
//                                     ' + \$${widget.data.firstVendorPriceShipping}',
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 0.035 * w,
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               TextSpan(
//                                 text: widget.data.firstVendorExtraDiscount ==
//                                         '0.00'
//                                     ? ''
//                                     : '\n - ${widget.data.firstVendorExtraDiscount}% (\$${returnDiscountPrice(discountPercentage: widget.data.firstVendorExtraDiscount, mainPrice: widget.data.firstVendorBasePrice.isEmpty ? widget.data.firstVendorPrice.isEmpty ? '0.0' : widget.data.firstVendorPrice : widget.data.firstVendorBasePrice)})',
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 0.035 * w,
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     // AutoSizeText(
//                     //   '\$ ${widget.data.firstVendorPrice}',
//                     //   style: GoogleFonts.montserrat(
//                     //       fontSize: .045 * w, fontWeight: FontWeight.bold),
//                     // ),
//                     Padding(
//                       padding: const EdgeInsets.only(right: 10.0),
//                       child: GestureDetector(
//                         onTap: () async =>
//                             await MyInAppBrowser().openUrlRequest(
//                           urlRequest: URLRequest(
//                               url: WebUri(widget.data.firstVendorUrl +
//                                   '?utm_source=shoppingmegamart.com&utm_medium=mobile-app')),
//                           options: InAppBrowserClassOptions(
//                             crossPlatform: InAppBrowserOptions(
//                               toolbarTopBackgroundColor: Colors.blue,
//                             ),
//                           ),
//                         ),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               color: Colors.grey,
//                             ),
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(.03 * w),
//                             ),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: .04 * w, vertical: .03 * w),
//                             child: Row(
//                               children: [
//                                 // AutoSizeText(
//                                 //   'To Shop',
//                                 //   style: MyTextStyle.simpleStyle(),
//                                 // ),
//                                 // SizedBox(
//                                 //   width: 0.01 * w,
//                                 // ),
//                                 Transform.rotate(
//                                   angle: 120,
//                                   child: const Icon(
//                                     Icons.arrow_upward,
//                                     color: Colors.blue,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(
//                     top: 10.0, bottom: 2, left: 8, right: 8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     AutoSizeText(
//                       '2nd Lowest ',
//                       style: MyTextStyle.customProductUrlStyle(),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(2.0),
//                       child: Image.network(
//                         '${AppInfo.kBaseUrl(stagingSelector: 0)}vendor-logo/${widget.data.secondVendorName}.jpg',
//                         errorBuilder: (_, c, cv) => Text(
//                           widget.data.secondVendorName,
//                           style: GoogleFonts.montserrat(
//                             fontSize: 0.035 * w,
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         width: 0.23 * w,
//                         height: 0.09 * w,
//                         fit: BoxFit.fill,
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     RichText(
//                       text: TextSpan(
//                         text: '\$${widget.data.secondVendorPrice}\n',
//                         style: GoogleFonts.montserrat(
//                           fontSize: 0.043 * w,
//                           color: Colors.red,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         children: [
//                           TextSpan(
//                             text: '\$${widget.data.secondVendorBasePrice}',
//                             style: GoogleFonts.montserrat(
//                               fontSize: 0.035 * w,
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             children: [
//                               TextSpan(
//                                 text:
//                                     ' + \$${widget.data.firstVendorPriceShipping}',
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 0.035 * w,
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               TextSpan(
//                                 text: widget.data.firstVendorExtraDiscount ==
//                                         '0.00'
//                                     ? ''
//                                     : '\n - ${widget.data.firstVendorExtraDiscount}% (\$${returnDiscountPrice(discountPercentage: widget.data.firstVendorExtraDiscount, mainPrice: widget.data.firstVendorBasePrice.isEmpty ? widget.data.firstVendorPrice.isEmpty ? '0.0' : widget.data.firstVendorPrice : widget.data.firstVendorBasePrice)})',
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 0.035 * w,
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(right: 10.0),
//                       child: GestureDetector(
//                         onTap: () async =>
//                             await MyInAppBrowser().openUrlRequest(
//                           urlRequest: URLRequest(
//                               url: WebUri(widget.data.secondVendorUrl +
//                                   '?utm_source=shoppingmegamart.com&utm_medium=mobile-app')),
//                           options: InAppBrowserClassOptions(
//                             crossPlatform: InAppBrowserOptions(
//                               toolbarTopBackgroundColor: Colors.blue,
//                             ),
//                           ),
//                         ),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               color: Colors.grey,
//                             ),
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(.03 * w),
//                             ),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: .04 * w, vertical: .03 * w),
//                             child: Row(
//                               children: [
//                                 // AutoSizeText(
//                                 //   'To Shop',
//                                 //   style: MyTextStyle.simpleStyle(),
//                                 // ),
//                                 // SizedBox(
//                                 //   width: 0.01 * w,
//                                 // ),
//                                 Transform.rotate(
//                                   angle: 120,
//                                   child: const Icon(
//                                     Icons.arrow_upward,
//                                     color: Colors.blue,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Visibility(
//                 visible: widget._showAllComp == true &&
//                     (widget.data.vendorName.toLowerCase() !=
//                             widget.data.firstVendorName.toLowerCase() &&
//                         widget.data.vendorName.toLowerCase() !=
//                             widget.data.secondVendorName.toLowerCase()),
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           top: 10.0, bottom: 2, left: 8, right: 8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           AutoSizeText(
//                             '3rd Lowest ',
//                             style: MyTextStyle.customProductUrlStyle(),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(2.0),
//                             child: Image.network(
//                               '${AppInfo.kBaseUrl(stagingSelector: 0)}vendor-logo/${widget.data.vendorName}.jpg',
//                               errorBuilder: (_, c, cv) => Text(
//                                 widget.data.vendorName,
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 0.035 * w,
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               width: 0.23 * w,
//                               height: 0.09 * w,
//                               fit: BoxFit.fill,
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           RichText(
//                             text: TextSpan(
//                               text: '\$${widget.data.vendorPriceFinalPrice}\n',
//                               style: GoogleFonts.montserrat(
//                                 fontSize: 0.043 * w,
//                                 color: Colors.red,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               children: [
//                                 TextSpan(
//                                   text: widget.data.extraDiscount == '0.00'
//                                       ? '\$${widget.data.vendorpricePrice}'
//                                       : '\$${widget.data.sisterVendorBasePrice}',
//                                   style: GoogleFonts.montserrat(
//                                     fontSize: 0.035 * w,
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   children: [
//                                     TextSpan(
//                                       text:
//                                           ' + \$${widget.data.vendorpriceShipping}',
//                                       style: GoogleFonts.montserrat(
//                                         fontSize: 0.035 * w,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     TextSpan(
//                                       text: widget.data.extraDiscount == '0.00'
//                                           ? ''
//                                           : '\n - ${widget.data.extraDiscount}% (\$${returnDiscountPrice(discountPercentage: widget.data.extraDiscount, mainPrice: widget.data.sisterVendorBasePrice!.isEmpty ? widget.data.sisterVendorFinalPrice!.isEmpty ? '0.0' : widget.data.sisterVendorFinalPrice! : widget.data.sisterVendorBasePrice!)})',
//                                       style: GoogleFonts.montserrat(
//                                         fontSize: 0.035 * w,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                               ],
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           // AutoSizeText(
//                           //   '\$ ${widget.data.firstVendorPrice}',
//                           //   style: GoogleFonts.montserrat(
//                           //       fontSize: .045 * w, fontWeight: FontWeight.bold),
//                           // ),
//                           Padding(
//                             padding: const EdgeInsets.only(right: 10.0),
//                             child: GestureDetector(
//                               onTap: () async =>
//                                   await MyInAppBrowser().openUrlRequest(
//                                 urlRequest: URLRequest(
//                                   url: WebUri(
//                                     widget.data.vendorUrl +
//                                         '?utm_source=shoppingmegamart.com&utm_medium=mobile-app',
//                                   ),
//                                 ),
//                                 options: InAppBrowserClassOptions(
//                                   crossPlatform: InAppBrowserOptions(
//                                     toolbarTopBackgroundColor: Colors.blue,
//                                   ),
//                                 ),
//                               ),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     color: Colors.grey,
//                                   ),
//                                   borderRadius: BorderRadius.all(
//                                     Radius.circular(.03 * w),
//                                   ),
//                                 ),
//                                 child: Padding(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: .04 * w,
//                                     vertical: .03 * w,
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       // AutoSizeText(
//                                       //   'To Shop',
//                                       //   style: MyTextStyle.simpleStyle(),
//                                       // ),
//                                       // SizedBox(
//                                       //   width: 0.01 * w,
//                                       // ),
//                                       Transform.rotate(
//                                         angle: 120,
//                                         child: const Icon(
//                                           Icons.arrow_upward,
//                                           color: Colors.blue,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     DelayedDisplay(
//                       slidingBeginOffset: const Offset(0.0, -0.35),
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                             top: 10.0, bottom: 2, left: 8, right: 8.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             AutoSizeText(
//                               '4th Lowest ',
//                               style: MyTextStyle.customProductUrlStyle(),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(2.0),
//                               child: CachedNetworkImage(
//                                 imageUrl:
//                                     '${AppInfo.kBaseUrl(stagingSelector: 0)}vendor-logo/${widget.data.fourthVendorName}.jpg',
//                                 errorWidget: (_, c, cv) => Center(
//                                   child: AutoSizeText(
//                                     maxLines: 1,
//                                     widget.data.fourthVendorName,
//                                     style: GoogleFonts.montserrat(
//                                       fontSize: 0.035 * w,
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                                 width: 0.3 * w,
//                                 height: 0.07 * w,
//                                 fit: BoxFit.fill,
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                     DelayedDisplay(
//                       slidingBeginOffset: const Offset(0.0, -0.35),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Tooltip(
//                               decoration: BoxDecoration(
//                                   color: Colors.grey,
//                                   borderRadius: BorderRadius.circular(10)),
//                               textAlign: TextAlign.center,
//                               richMessage: TextSpan(
//                                 text: 'Final Price\n',
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 0.035 * w,
//                                   color: Colors.blue,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 children: [
//                                   TextSpan(
//                                     text: 'Base Price + Shipping\n',
//                                     style: GoogleFonts.montserrat(
//                                       fontSize: 0.035 * w,
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   TextSpan(
//                                     text: '- Discount',
//                                     style: GoogleFonts.montserrat(
//                                       fontSize: 0.035 * w,
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               triggerMode: TooltipTriggerMode.tap,
//                               child: RichText(
//                                 text: TextSpan(
//                                   text:
//                                       '\$${widget.data.fourthVendorFinalPrice}\n',
//                                   style: GoogleFonts.montserrat(
//                                     fontSize: 0.04 * w,
//                                     color: Colors.red,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   children: [
//                                     TextSpan(
//                                       text:
//                                           '\$${widget.data.fourthVendorBasePrice}',
//                                       style: GoogleFonts.montserrat(
//                                         fontSize: 0.035 * w,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       children: [
//                                         TextSpan(
//                                           text:
//                                               ' + \$${widget.data.fourthVendorShipping}',
//                                           style: GoogleFonts.montserrat(
//                                             fontSize: 0.035 * w,
//                                             color: Colors.black,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         TextSpan(
//                                           text: widget.data
//                                                       .fourthVendorExtraDiscount ==
//                                                   '0.00'
//                                               ? ''
//                                               : '\n - ${widget.data.fourthVendorExtraDiscount}% (\$${returnDiscountPrice(discountPercentage: widget.data.fourthVendorExtraDiscount, mainPrice: widget.data.fourthVendorBasePrice.isEmpty ? '0.0' : widget.data.fourthVendorBasePrice)})',
//                                           style: GoogleFonts.montserrat(
//                                             fontSize: 0.035 * w,
//                                             color: Colors.black,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(right: 10.0),
//                               child: GestureDetector(
//                                 onTap: () async =>
//                                     await MyInAppBrowser().openUrlRequest(
//                                   urlRequest: URLRequest(
//                                       url: WebUri(widget.data.secondVendorUrl +
//                                           '?utm_source=shoppingmegamart.com&utm_medium=mobile-app')),
//                                   options: InAppBrowserClassOptions(
//                                     crossPlatform: InAppBrowserOptions(
//                                       toolbarTopBackgroundColor: Colors.blue,
//                                     ),
//                                   ),
//                                 ),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: Colors.grey,
//                                     ),
//                                     borderRadius: BorderRadius.all(
//                                       Radius.circular(.03 * w),
//                                     ),
//                                   ),
//                                   child: Padding(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: .03 * w,
//                                       vertical: .02 * w,
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         // AutoSizeText(
//                                         //   'To Shop',
//                                         //   style: MyTextStyle.simpleStyle(),
//                                         // ),
//                                         // SizedBox(
//                                         //   width: 0.01 * w,
//                                         // ),
//                                         Transform.rotate(
//                                           angle: 120,
//                                           child: const Icon(
//                                             Icons.arrow_upward,
//                                             color: Colors.blue,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     DelayedDisplay(
//                       slidingBeginOffset: const Offset(0.0, -0.35),
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                             top: 2.0, bottom: 2, left: 8, right: 8.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             AutoSizeText(
//                               '5th Lowest ',
//                               style: MyTextStyle.customProductUrlStyle(),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(2.0),
//                               child: CachedNetworkImage(
//                                 imageUrl:
//                                     '${AppInfo.kBaseUrl(stagingSelector: 0)}vendor-logo/${widget.data.fifthVendorName}.jpg',
//                                 errorWidget: (_, c, cv) => Center(
//                                   child: AutoSizeText(
//                                     widget.data.fifthVendorName,
//                                     maxLines: 1,
//                                     style: GoogleFonts.montserrat(
//                                       fontSize: 0.035 * w,
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                                 width: 0.3 * w,
//                                 height: 0.07 * w,
//                                 fit: BoxFit.fill,
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                     DelayedDisplay(
//                       slidingBeginOffset: const Offset(0.0, -0.35),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Tooltip(
//                               decoration: BoxDecoration(
//                                   color: Colors.grey,
//                                   borderRadius: BorderRadius.circular(10)),
//                               textAlign: TextAlign.center,
//                               richMessage: TextSpan(
//                                 text: 'Final Price\n',
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 0.035 * w,
//                                   color: Colors.blue,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 children: [
//                                   TextSpan(
//                                     text: 'Base Price + Shipping\n',
//                                     style: GoogleFonts.montserrat(
//                                       fontSize: 0.035 * w,
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   TextSpan(
//                                     text: '- Discount',
//                                     style: GoogleFonts.montserrat(
//                                       fontSize: 0.035 * w,
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               triggerMode: TooltipTriggerMode.tap,
//                               child: RichText(
//                                 text: TextSpan(
//                                   text:
//                                       '\$${widget.data.fifthVendorFinalPrice}\n',
//                                   style: GoogleFonts.montserrat(
//                                     fontSize: 0.04 * w,
//                                     color: Colors.red,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   children: [
//                                     TextSpan(
//                                       text:
//                                           '\$${widget.data.fifthVendorBasePrice}',
//                                       style: GoogleFonts.montserrat(
//                                         fontSize: 0.035 * w,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       children: [
//                                         TextSpan(
//                                           text:
//                                               ' + \$${widget.data.fifthVendorShipping}',
//                                           style: GoogleFonts.montserrat(
//                                             fontSize: 0.035 * w,
//                                             color: Colors.black,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         TextSpan(
//                                           text: widget.data
//                                                       .fifthVendorExtraDiscount ==
//                                                   '0.00'
//                                               ? ''
//                                               : '\n - ${widget.data.fifthVendorExtraDiscount}% (\$${returnDiscountPrice(discountPercentage: widget.data.fifthVendorExtraDiscount, mainPrice: widget.data.fifthVendorBasePrice.isEmpty ? '0.0' : widget.data.fifthVendorBasePrice)})',
//                                           style: GoogleFonts.montserrat(
//                                             fontSize: 0.035 * w,
//                                             color: Colors.black,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(right: 10.0),
//                               child: GestureDetector(
//                                 onTap: () async =>
//                                     await MyInAppBrowser().openUrlRequest(
//                                   urlRequest: URLRequest(
//                                       url: WebUri(widget.data.secondVendorUrl +
//                                           '?utm_source=shoppingmegamart.com&utm_medium=mobile-app')),
//                                   options: InAppBrowserClassOptions(
//                                     crossPlatform: InAppBrowserOptions(
//                                       toolbarTopBackgroundColor: Colors.blue,
//                                     ),
//                                   ),
//                                 ),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: Colors.grey,
//                                     ),
//                                     borderRadius: BorderRadius.all(
//                                       Radius.circular(.03 * w),
//                                     ),
//                                   ),
//                                   child: Padding(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: .03 * w,
//                                       vertical: .02 * w,
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         // AutoSizeText(
//                                         //   'To Shop',
//                                         //   style: MyTextStyle.simpleStyle(),
//                                         // ),
//                                         // SizedBox(
//                                         //   width: 0.01 * w,
//                                         // ),
//                                         Transform.rotate(
//                                           angle: 120,
//                                           child: const Icon(
//                                             Icons.arrow_upward,
//                                             color: Colors.blue,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               widget._showPrice == false
//                   ? Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Visibility(
//                           visible: widget._showRT,
//                           child: Padding(
//                             padding: const EdgeInsets.only(
//                                 bottom: 2, left: 8, right: 8.0),
//                             child: AutoSizeText(
//                               'Recommendation',
//                               style: MyTextStyle.customProductUrlStyle(),
//                             ),
//                           ),
//                         ),
//                         Visibility(
//                           visible: widget._showRT,
//                           child: const SizedBox(
//                             height: 2,
//                           ),
//                         ),
//                         Visibility(
//                           visible: widget._showRT,
//                           child: SizedBox(
//                             width: w,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 8.0),
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Tooltip(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey,
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     textAlign: TextAlign.center,
//                                     richMessage: TextSpan(
//                                         text: 'RT\n',
//                                         style: GoogleFonts.montserrat(
//                                           fontSize: 0.035 * w,
//                                           color: Colors.blue,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         children: [
//                                           TextSpan(
//                                             text: 'RP + Shipping',
//                                             style: GoogleFonts.montserrat(
//                                               fontSize: 0.035 * w,
//                                               color: Colors.black,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           )
//                                         ]),
//                                     triggerMode: TooltipTriggerMode.tap,
//                                     child: RichText(
//                                       text: TextSpan(
//                                         text: '\$${widget.data.rp}\n',
//                                         style: GoogleFonts.montserrat(
//                                           fontSize: 0.0353 * w,
//                                           color: Colors.green,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         children: [
//                                           TextSpan(
//                                             text: '\$${widget.data.rp}',
//                                             style: GoogleFonts.montserrat(
//                                               fontSize: 0.035 * w,
//                                               color: Colors.black,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                             children: [
//                                               TextSpan(
//                                                 text: widget.data
//                                                             .vendorpriceShipping ==
//                                                         '0.00'
//                                                     ? ' + Free Shipping'
//                                                     : ' + \$${widget.data.vendorpriceShipping}',
//                                                 style: GoogleFonts.montserrat(
//                                                   fontSize: 0.035 * w,
//                                                   color: Colors.black,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ],
//                                           )
//                                         ],
//                                       ),
//                                       textAlign: TextAlign.start,
//                                     ),
//                                   ),
//                                   Tooltip(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey,
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     textAlign: TextAlign.center,
//                                     richMessage: TextSpan(
//                                         text: 'Variation\n',
//                                         style: GoogleFonts.montserrat(
//                                           fontSize: 0.035 * w,
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         children: [
//                                           TextSpan(
//                                             text: 'Criteria',
//                                             style: GoogleFonts.montserrat(
//                                               fontSize: 0.035 * w,
//                                               color: Colors.black,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           )
//                                         ]),
//                                     triggerMode: TooltipTriggerMode.tap,
//                                     child: RichText(
//                                       text: TextSpan(
//                                         text: '${widget.data.rpVariation}\n',
//                                         style: GoogleFonts.montserrat(
//                                           fontSize: 0.0353 * w,
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         children: [
//                                           TextSpan(
//                                             text: widget.data.rpCriteria,
//                                             style: GoogleFonts.montserrat(
//                                               fontSize: 0.035 * w,
//                                               color: Colors.black,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       textAlign: TextAlign.end,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         Visibility(
//                           visible: widget._showRT,
//                           child: const SizedBox(
//                             height: 10,
//                           ),
//                         ),
//                         Visibility(
//                           visible: widget._showRT,
//                           child: SizedBox(
//                             width: w,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 8.0),
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Tooltip(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey,
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     textAlign: TextAlign.center,
//                                     richMessage: TextSpan(
//                                         text: 'RT\n',
//                                         style: GoogleFonts.montserrat(
//                                           fontSize: 0.035 * w,
//                                           color: Colors.blue,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         children: [
//                                           TextSpan(
//                                             text: 'RP + Shipping',
//                                             style: GoogleFonts.montserrat(
//                                               fontSize: 0.035 * w,
//                                               color: Colors.black,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           )
//                                         ]),
//                                     triggerMode: TooltipTriggerMode.tap,
//                                     child: RichText(
//                                       text: TextSpan(
//                                         text: '\$${widget.data.rt}\n',
//                                         style: GoogleFonts.montserrat(
//                                           fontSize: 0.0353 * w,
//                                           color: Colors.green,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         children: [
//                                           TextSpan(
//                                             text: '\$${widget.data.rp}',
//                                             style: GoogleFonts.montserrat(
//                                               fontSize: 0.035 * w,
//                                               color: Colors.black,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                             children: [
//                                               TextSpan(
//                                                 text: widget.data
//                                                             .vendorpriceShipping ==
//                                                         '0.00'
//                                                     ? ' + Free Shipping'
//                                                     : ' + \$${widget.data.vendorpriceShipping}',
//                                                 style: GoogleFonts.montserrat(
//                                                   fontSize: 0.035 * w,
//                                                   color: Colors.black,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ],
//                                           )
//                                         ],
//                                       ),
//                                       textAlign: TextAlign.start,
//                                     ),
//                                   ),
//                                   Tooltip(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey,
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     textAlign: TextAlign.center,
//                                     richMessage: TextSpan(
//                                         text: 'Variation\n',
//                                         style: GoogleFonts.montserrat(
//                                           fontSize: 0.035 * w,
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         children: [
//                                           TextSpan(
//                                             text: 'Criteria',
//                                             style: GoogleFonts.montserrat(
//                                               fontSize: 0.035 * w,
//                                               color: Colors.black,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           )
//                                         ]),
//                                     triggerMode: TooltipTriggerMode.tap,
//                                     child: RichText(
//                                       text: TextSpan(
//                                         text: '${widget.data.rpVariation}\n',
//                                         style: GoogleFonts.montserrat(
//                                           fontSize: 0.0353 * w,
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         children: [
//                                           TextSpan(
//                                             text: widget.data.rpCriteria,
//                                             style: GoogleFonts.montserrat(
//                                               fontSize: 0.035 * w,
//                                               color: Colors.black,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       textAlign: TextAlign.end,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     )
//                   : SizedBox(
//                       width: w,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const DelayedDisplay(
//                             slidingBeginOffset: Offset(0.0, -0.35),
//                             child: Padding(
//                               padding: EdgeInsets.only(
//                                   top: 10.0, bottom: 2, left: 8, right: 8.0),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   // AutoSizeText(
//                                   //   widget.vendorId == AppInfo.kVendorId
//                                   //       ? 'AF Supply Pricing'
//                                   //       : 'HP Pricing',
//                                   //   style: MyTextStyle
//                                   //       .customProductUrlStyle(),
//                                   // ),
//                                   // Padding(
//                                   //   padding: const EdgeInsets.all(2.0),
//                                   //   child: Image.asset(
//                                   //     widget.vendorId == AppInfo.kVendorId
//                                   //         ? 'assets/af-supply.png'
//                                   //         : 'assets/home-perfect.png',
//                                   //     width: 0.3 * w,
//                                   //     height: 0.07 * w,
//                                   //     fit: BoxFit.fill,
//                                   //   ),
//                                   // )
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Row(
//                             mainAxisSize: MainAxisSize.max,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 8.0),
//                                 child: Tooltip(
//                                   decoration: BoxDecoration(
//                                       color: Colors.grey,
//                                       borderRadius: BorderRadius.circular(10)),
//                                   textAlign: TextAlign.center,
//                                   richMessage: TextSpan(
//                                     text: 'Final Price\n',
//                                     style: GoogleFonts.montserrat(
//                                       fontSize: 0.035 * w,
//                                       color: Colors.blue,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                     children: [
//                                       TextSpan(
//                                         text: 'Base Price + Shipping\n',
//                                         style: GoogleFonts.montserrat(
//                                           fontSize: 0.035 * w,
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       TextSpan(
//                                         text: '- Discount',
//                                         style: GoogleFonts.montserrat(
//                                           fontSize: 0.035 * w,
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   triggerMode: TooltipTriggerMode.tap,
//                                   child: RichText(
//                                     text: TextSpan(
//                                       text:
//                                           '\$${widget.data.vendorPriceFinalPrice}\n',
//                                       style: GoogleFonts.montserrat(
//                                         fontSize: 0.04 * w,
//                                         color: Colors.blue,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       children: [
//                                         TextSpan(
//                                           text:
//                                               '\$${widget.data.vendorpricePrice}',
//                                           style: GoogleFonts.montserrat(
//                                             fontSize: 0.035 * w,
//                                             color: Colors.black,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                           children: [
//                                             TextSpan(
//                                               text:
//                                                   ' + \$${widget.data.vendorpriceShipping}',
//                                               style: GoogleFonts.montserrat(
//                                                 fontSize: 0.035 * w,
//                                                 color: Colors.black,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             TextSpan(
//                                               text:
//                                                   ' - \$${widget.data.extraDiscount}',
//                                               style: GoogleFonts.montserrat(
//                                                 fontSize: 0.035 * w,
//                                                 color: Colors.black,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ],
//                                         )
//                                       ],
//                                     ),
//                                     textAlign: TextAlign.start,
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(right: 16.0),
//                                 child: GestureDetector(
//                                   onTap: () async =>
//                                       await MyInAppBrowser().openUrlRequest(
//                                     urlRequest: URLRequest(
//                                         url: WebUri(widget.data.vendorUrl +
//                                             '?utm_source=shoppingmegamart.com&utm_medium=mobile-app')),
//                                     options: InAppBrowserClassOptions(
//                                       crossPlatform: InAppBrowserOptions(
//                                         toolbarTopBackgroundColor: Colors.blue,
//                                       ),
//                                     ),
//                                   ),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                         color: Colors.grey,
//                                       ),
//                                       borderRadius: BorderRadius.all(
//                                         Radius.circular(.03 * w),
//                                       ),
//                                     ),
//                                     child: Padding(
//                                       padding: EdgeInsets.symmetric(
//                                         horizontal: .03 * w,
//                                         vertical: .02 * w,
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           // AutoSizeText(
//                                           //   'To Shop',
//                                           //   style: MyTextStyle.simpleStyle(),
//                                           // ),
//                                           // SizedBox(
//                                           //   width: 0.01 * w,
//                                           // ),
//                                           Transform.rotate(
//                                             angle: 120,
//                                             child: const Icon(
//                                               Icons.arrow_upward,
//                                               color: Colors.blue,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           // DelayedDisplay(
//                           //   slidingBeginOffset: const Offset(0.0, -0.35),
//                           //   child: Padding(
//                           //     padding: const EdgeInsets.only(
//                           //         top: 10.0,
//                           //         bottom: 2,
//                           //         left: 8,
//                           //         right: 8.0),
//                           //     child: Row(
//                           //       mainAxisAlignment:
//                           //       MainAxisAlignment.spaceBetween,
//                           //       children: [
//                           //         AutoSizeText(
//                           //           widget.vendorId == AppInfo.kVendorId
//                           //               ? 'HP Pricing'
//                           //               : 'AF Supply Pricing',
//                           //           style: MyTextStyle
//                           //               .customProductUrlStyle(),
//                           //         ),
//                           //         Padding(
//                           //           padding: const EdgeInsets.all(2.0),
//                           //           child: Image.asset(
//                           //             widget.vendorId == AppInfo.kVendorId
//                           //                 ? 'assets/home-perfect.png'
//                           //                 : 'assets/af-supply.png',
//                           //             width: 0.3 * w,
//                           //             height: 0.07 * w,
//                           //             fit: BoxFit.fill,
//                           //           ),
//                           //         )
//                           //       ],
//                           //     ),
//                           //   ),
//                           // ),
//                           Row(
//                             mainAxisSize: MainAxisSize.max,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 8.0),
//                                 child: Tooltip(
//                                   decoration: BoxDecoration(
//                                       color: Colors.grey,
//                                       borderRadius: BorderRadius.circular(10)),
//                                   textAlign: TextAlign.center,
//                                   richMessage: TextSpan(
//                                     text: 'Final Price\n',
//                                     style: GoogleFonts.montserrat(
//                                       fontSize: 0.035 * w,
//                                       color: Colors.blue,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                     children: [
//                                       TextSpan(
//                                         text: 'Base Price + Shipping\n',
//                                         style: GoogleFonts.montserrat(
//                                           fontSize: 0.035 * w,
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       TextSpan(
//                                         text: '- Discount',
//                                         style: GoogleFonts.montserrat(
//                                           fontSize: 0.035 * w,
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   triggerMode: TooltipTriggerMode.tap,
//                                   child: RichText(
//                                     text: TextSpan(
//                                       text:
//                                           '\$${widget.data.sisterVendorFinalPrice}\n',
//                                       style: GoogleFonts.montserrat(
//                                         fontSize: 0.04 * w,
//                                         color: Colors.blue,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       children: [
//                                         TextSpan(
//                                           text:
//                                               '\$${widget.data.sisterVendorBasePrice}',
//                                           style: GoogleFonts.montserrat(
//                                             fontSize: 0.035 * w,
//                                             color: Colors.black,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                           children: [
//                                             TextSpan(
//                                               text:
//                                                   ' + \$${widget.data.sisterVendorShipping}',
//                                               style: GoogleFonts.montserrat(
//                                                 fontSize: 0.035 * w,
//                                                 color: Colors.black,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             TextSpan(
//                                               text:
//                                                   ' - \$${widget.data.sisterExtraDiscount}',
//                                               style: GoogleFonts.montserrat(
//                                                 fontSize: 0.035 * w,
//                                                 color: Colors.black,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ],
//                                         )
//                                       ],
//                                     ),
//                                     textAlign: TextAlign.start,
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(right: 16.0),
//                                 child: GestureDetector(
//                                   onTap: () async =>
//                                       await MyInAppBrowser().openUrlRequest(
//                                     urlRequest: URLRequest(
//                                         url: WebUri(widget.data.vendorBaseUrl! +
//                                             '?utm_source=shoppingmegamart.com&utm_medium=mobile-app')),
//                                     options: InAppBrowserClassOptions(
//                                       crossPlatform: InAppBrowserOptions(
//                                         toolbarTopBackgroundColor: Colors.blue,
//                                       ),
//                                     ),
//                                   ),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                         color: Colors.grey,
//                                       ),
//                                       borderRadius: BorderRadius.all(
//                                         Radius.circular(.03 * w),
//                                       ),
//                                     ),
//                                     child: Padding(
//                                       padding: EdgeInsets.symmetric(
//                                         horizontal: .03 * w,
//                                         vertical: .02 * w,
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           // AutoSizeText(
//                                           //   'To Shop',
//                                           //   style: MyTextStyle.simpleStyle(),
//                                           // ),
//                                           // SizedBox(
//                                           //   width: 0.01 * w,
//                                           // ),
//                                           Transform.rotate(
//                                             angle: 120,
//                                             child: const Icon(
//                                               Icons.arrow_upward,
//                                               color: Colors.blue,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//               const SizedBox(
//                 height: 4,
//               ),
//               /*Vendor Section*/
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget? _buildTrailingIcon(BuildContext context) {
//     return buildIcon();
//   }
//
//   CachedNetworkImage _buildLeadingImage({required String item}) {
//     return CachedNetworkImage(
//       imageUrl: item.isEmpty
//           ? 'https://t4.ftcdn.net/jpg/02/35/35/39/360_F_235353990_f0UX1nFRDaaxHH48CU0UQ32rYxvOrPbM.jpg'
//           : item,
//       width: 100,
//       placeholder: (context, _) => const Center(
//         child: CircularProgressIndicator(),
//       ),
//       height: 100,
//       fit: BoxFit.cover,
//     );
//   }
//
//   late Animation<double> _iconTurns;
//
//   // initState((){
//   //   _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
//   //
//   //   });
//
//   buildIcon() => RotationTransition(
//         turns: _iconTurns,
//         child: Container(
//           height: 0.11 * w,
//           width: 0.11 * w,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(color: Colors.grey),
//           ),
//           child: const Center(
//             child: Icon(
//               Icons.keyboard_arrow_down_sharp,
//             ),
//           ),
//         ),
//       );
// }
//
// double returnDiscountPercentage(
//     {required double basePrice, required double discountPrice}) {
//   double x = 0.0;
//   try {
//     x = (discountPrice / basePrice) * 100;
//   } catch (e) {
//     x = 0.0;
//   }
//
//   return double.parse(x.toStringAsFixed(2));
// }
//
// Color returnSales2AtpColor({required String ratioValue}) {
//   final double convertedValue =
//       double.parse(ratioValue.isEmpty ? '0.0' : ratioValue);
//
//   if (convertedValue >= 0 && convertedValue < 0.5) {
//     return Colors.red;
//   } else if (convertedValue >= 0.5 && convertedValue < 1) {
//     return Colors.orange;
//   } else if (convertedValue >= 1 && convertedValue < 3) {
//     return Colors.lightGreen;
//   } else {
//     return Colors.green;
//   }
// }
//
// Color returnAgeColor({required String daysValue}) {
//   final int convertedValue =
//       int.parse(daysValue.replaceAll(',', '').replaceAll('.', ''));
//
//   if (convertedValue >= 0 && convertedValue < 165) {
//     return Colors.green;
//   } else if (convertedValue >= 165 && convertedValue < 365) {
//     return Colors.lightGreen;
//   } else if (convertedValue >= 365 && convertedValue < 730) {
//     return Colors.orange;
//   } else {
//     return Colors.red;
//   }
// }
