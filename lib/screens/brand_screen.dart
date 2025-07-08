// import 'dart:convert';
//
// // import 'dart:math';
//
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lottie/lottie.dart';
// import 'package:minsellprice/app.dart';
// import 'package:minsellprice/bloc/all_brand_bloc/all_brand_bloc.dart';
// import 'package:minsellprice/screens/widgets/sample_product_screen.dart';
// import 'package:minsellprice/services/extra_functions.dart';
// import 'package:minsellprice/size.dart';
// import 'package:minsellprice/utils/common_methods.dart';
// import 'package:sqflite/sqflite.dart';
//
// class BrandScreen extends StatefulWidget {
//   const BrandScreen({
//     super.key,
//     required this.vendorId,
//     required this.date,
//     required this.database,
//   });
//
//   final String vendorId, date;
//   final Database database;
//
//   @override
//   State<BrandScreen> createState() => _BrandScreenState();
// }
//
// class _BrandScreenState extends State<BrandScreen> {
//   @override
//   void initState() {
//     // context.read<AllBrandBloc>().add(
//     //     AllBrandLoadingEvent(date: widget.date, vendorId: widget.vendorId));
//     // controller.addListener(queryListener);
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     controller.removeListener(queryListener);
//     controller.dispose();
//     super.dispose();
//   }
//
//   List<AllBrandModel> allItems = [];
//   List<AllBrandModel> searchItems = [];
//
//   final SearchController controller = SearchController();
//
//   void queryListener() {
//     search(query: controller.text);
//   }
//
//   void search({required String query}) {
//     setState(() {
//       if (query.isEmpty) {
//         searchItems = allItems;
//       } else {
//         searchItems = allItems
//             .where(
//               (element) => element.key.toString().toLowerCase().contains(
//                     query.toLowerCase(),
//                   ),
//             )
//             .toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           elevation: 5,
//           surfaceTintColor:
//               MaterialStateColor.resolveWith((states) => Colors.white),
//           title: AutoSizeText(
//             'Brands',
//             style: GoogleFonts.openSans(
//               fontSize: w * .05,
//               fontWeight: FontWeight.w900,
//               color: Colors.black,
//             ),
//           ),
//         ),
//         body: BlocListener<AllBrandBloc, AllBrandState>(
//           listener: (BuildContext context, AllBrandState state) {
//             state is AllBrandLoadedState
//                 ? setState(() {
//                     state.data.forEach((key, value) {
//                       try {
//                         final lower1 =
//                             quoteKeysAndStrings((value)["lower more than 15%"]);
//                         final lower2 = (value)["total_products"];
//                         final lower3 = (value)["Image"];
//                         final lower4 = (value)["key"];
//                         final lower10 = (value)["brand_id"];
//                         final lower5 = (value)["lower upto 5%"];
//                         final lower6 =
//                             quoteKeysAndStrings((value)["higher upto 5%"]);
//                         final lower7 = quoteKeysAndStrings(
//                             (value)["higher from 5% - 15%"]);
//                         final lower9 =
//                             quoteKeysAndStrings((value)["lower from 5% - 15%"]);
//                         final lower8 = quoteKeysAndStrings(
//                             (value)["higher more than 15%"]);
//
//                         final item = AllBrandModel(
//                             lowerMoreThan15: HigherFrom515.fromJson(lower1),
//                             totalProducts: lower2,
//                             image: lower3,
//                             key: lower4,
//                             lowerFrom515: HigherFrom515.fromJson(lower9),
//                             lowerUpto5: HigherFrom515.fromJson(lower5),
//                             higherUpto5: HigherFrom515.fromJson(lower6),
//                             higherFrom515: HigherFrom515.fromJson(lower7),
//                             higherMoreThan15: HigherFrom515.fromJson(lower8),
//                             brandId: lower10);
//                         allItems.add(item);
//                       } catch (e) {
//                         print(e);
//                       }
//                     });
//
//                     searchItems = allItems;
//                     // log(jsonEncode(searchItems));
//                   })
//                 : null;
//           },
//           child: BlocBuilder<AllBrandBloc, AllBrandState>(
//             builder: (context, state) {
//               return state is AllBrandLoadedState
//                   ? SizedBox(
//                       height: h,
//                       child: Column(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(4.0),
//                             child: SearchBar(
//                               hintText: 'Search...',
//                               controller: controller,
//                               trailing: [
//                                 IconButton(
//                                   onPressed: queryListener,
//                                   icon: const Icon(Icons.search),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           Flexible(
//                             child: CustomScrollView(
//                               slivers: [
//                                 SliverAnimatedList(
//                                   itemBuilder: (context, index, animation) {
//                                     return Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 4.0),
//                                       child: Card(
//                                         elevation: 10,
//                                         child: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             GestureDetector(
//                                               onTap: () async {
//                                                 await Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         ContentScreen(
//                                                       vendorName: '',
//                                                       vendorImage:
//                                                           '${CommonMethods.removeLastSlash(AppInfo.kBaseUrl(stagingSelector: 1))}${searchItems[index].image}',
//                                                       vendorId: widget.vendorId,
//                                                       date: widget.date,
//                                                       loadingData: '',
//                                                       database: widget.database,
//                                                       isVendorPriceAnalysis:
//                                                           false,
//                                                       isVendorTable: false,
//                                                       brandKey:
//                                                           searchItems[index]
//                                                               .key,
//                                                     ),
//                                                   ),
//                                                 );
//                                               },
//                                               child: Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                   horizontal: 10.0,
//                                                   vertical: 10,
//                                                 ),
//                                                 child: Center(
//                                                   child: CachedNetworkImage(
//                                                     imageUrl:
//                                                         '${CommonMethods.removeLastSlash(AppInfo.kBaseUrl(stagingSelector: 1))}${searchItems[index].image}',
//                                                     height: w * 0.3,
//                                                     placeholder:
//                                                         (context, url) =>
//                                                             Center(
//                                                       child: Lottie.asset(
//                                                         'assets/lottie_animations/loading_bar.json',
//                                                         repeat: true,
//                                                         animate: true,
//                                                         width: 50,
//                                                         height: 50,
//                                                         frameRate: FrameRate(
//                                                           60,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     // fit: BoxFit.fill,
//                                                     errorWidget: (_, c, e) =>
//                                                         SizedBox(
//                                                       width: w * .3,
//                                                       child: Center(
//                                                         child: AutoSizeText(
//                                                           searchItems[index]
//                                                               .key
//                                                               .toString()
//                                                               .toUpperCase(),
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                   fontSize:
//                                                                       w * .05),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     // height: w * 0.5,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                             AutoSizeText(
//                                               'Total Products: ${searchItems[index].totalProducts}',
//                                               style: GoogleFonts.openSans(
//                                                 fontSize: w * 0.04,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 8.0,
//                                                       vertical: 4),
//                                               child: Table(
//                                                 border: TableBorder.symmetric(
//                                                   inside: const BorderSide(
//                                                     width: 2,
//                                                     color: Colors.black,
//                                                   ),
//                                                   outside: const BorderSide(
//                                                     width: 2,
//                                                     color: Colors.black,
//                                                   ),
//                                                 ),
//                                                 children: [
//                                                   TableRow(children: [
//                                                     Padding(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               8.0),
//                                                       child: SizedBox(
//                                                         width: w * .1,
//                                                         height: w * .1,
//                                                         child: Center(
//                                                           child: AutoSizeText(
//                                                             '',
//                                                             textAlign: TextAlign
//                                                                 .center,
//                                                             style: GoogleFonts
//                                                                 .openSans(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     Padding(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               8.0),
//                                                       child: SizedBox(
//                                                         width: w * .1,
//                                                         height: w * .1,
//                                                         child: Center(
//                                                           child: AutoSizeText(
//                                                             'Mapped',
//                                                             textAlign: TextAlign
//                                                                 .center,
//                                                             style: GoogleFonts
//                                                                 .openSans(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     Padding(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               8.0),
//                                                       child: SizedBox(
//                                                         width: w * .1,
//                                                         height: w * .1,
//                                                         child: AutoSizeText(
//                                                           'Map Exempt',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     Padding(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               8.0),
//                                                       child: SizedBox(
//                                                         width: w * .1,
//                                                         height: w * .1,
//                                                         child: Center(
//                                                           child: AutoSizeText(
//                                                             'Reviewed',
//                                                             textAlign: TextAlign
//                                                                 .center,
//                                                             style: GoogleFonts
//                                                                 .openSans(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ]),
//                                                   TableRow(children: [
//                                                     Container(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       color: Colors.red,
//                                                       child: Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(2.0),
//                                                         child: AutoSizeText(
//                                                           'Lower more\nthan 15%',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       child: Center(
//                                                         child: AutoSizeText(
//                                                           '${searchItems[index].lowerMoreThan15.mapCount}',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       child: Center(
//                                                         child: AutoSizeText(
//                                                           '${searchItems[index].lowerMoreThan15.nonmapCount}',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       child: Center(
//                                                         child: AutoSizeText(
//                                                           '${searchItems[index].lowerMoreThan15.reviewedCount}',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ]),
//                                                   TableRow(children: [
//                                                     Container(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       color: Colors.orange,
//                                                       child: Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(2.0),
//                                                         child: AutoSizeText(
//                                                           'Lower from\n5% - 15%',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       child: Center(
//                                                         child: AutoSizeText(
//                                                           // '',
//                                                           '${searchItems[index].lowerFrom515.mapCount}',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       child: Center(
//                                                         child: AutoSizeText(
//                                                           '${searchItems[index].lowerFrom515.nonmapCount}',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       child: Center(
//                                                         child: AutoSizeText(
//                                                           '${searchItems[index].lowerFrom515.reviewedCount}',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ]),
//                                                   TableRow(
//                                                     children: [
//                                                       Container(
//                                                         width: w * .1,
//                                                         height: w * .1,
//                                                         color:
//                                                             Colors.lightGreen,
//                                                         child: Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .all(2.0),
//                                                           child: AutoSizeText(
//                                                             'Lower upto\n 5%',
//                                                             textAlign: TextAlign
//                                                                 .center,
//                                                             style: GoogleFonts
//                                                                 .openSans(
//                                                               fontSize:
//                                                                   w * 0.032,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       SizedBox(
//                                                         width: w * .1,
//                                                         height: w * .1,
//                                                         child: Center(
//                                                           child: AutoSizeText(
//                                                             '${searchItems[index].lowerUpto5.mapCount}',
//                                                             textAlign: TextAlign
//                                                                 .center,
//                                                             style: GoogleFonts
//                                                                 .openSans(
//                                                               fontSize:
//                                                                   w * 0.032,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                               color:
//                                                                   Colors.black,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       SizedBox(
//                                                         width: w * .1,
//                                                         height: w * .1,
//                                                         child: Center(
//                                                           child: AutoSizeText(
//                                                             '${searchItems[index].lowerUpto5.nonmapCount}',
//                                                             textAlign: TextAlign
//                                                                 .center,
//                                                             style: GoogleFonts
//                                                                 .openSans(
//                                                               fontSize:
//                                                                   w * 0.032,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                               color:
//                                                                   Colors.black,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       SizedBox(
//                                                         width: w * .1,
//                                                         height: w * .1,
//                                                         child: Center(
//                                                           child: AutoSizeText(
//                                                             '${searchItems[index].lowerUpto5.reviewedCount}',
//                                                             textAlign: TextAlign
//                                                                 .center,
//                                                             style: GoogleFonts
//                                                                 .openSans(
//                                                               fontSize:
//                                                                   w * 0.032,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                               color:
//                                                                   Colors.black,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   TableRow(children: [
//                                                     Container(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       color: Colors.lightGreen,
//                                                       child: Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(2.0),
//                                                         child: AutoSizeText(
//                                                           'Higher upto 5%',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       child: Center(
//                                                         child: AutoSizeText(
//                                                           '${searchItems[index].higherUpto5.mapCount}',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       child: Center(
//                                                         child: AutoSizeText(
//                                                           '${searchItems[index].higherUpto5.nonmapCount}',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       child: Center(
//                                                         child: AutoSizeText(
//                                                           '${searchItems[index].higherUpto5.reviewedCount}',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ]),
//                                                   TableRow(children: [
//                                                     Container(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       color: Colors.orange,
//                                                       child: Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(2.0),
//                                                         child: AutoSizeText(
//                                                           'Higher from\n5% - 15%',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       child: Center(
//                                                         child: AutoSizeText(
//                                                           '${searchItems[index].higherFrom515.mapCount}',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       child: Center(
//                                                         child: AutoSizeText(
//                                                           '${searchItems[index].higherFrom515.nonmapCount}',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       child: Center(
//                                                         child: AutoSizeText(
//                                                           '${searchItems[index].higherFrom515.reviewedCount}',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ]),
//                                                   TableRow(children: [
//                                                     Container(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       color: Colors.red,
//                                                       child: Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(2.0),
//                                                         child: AutoSizeText(
//                                                           'Higher more\nthan 15%',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       child: Center(
//                                                         child: AutoSizeText(
//                                                           '${searchItems[index].higherMoreThan15.mapCount}',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       child: Center(
//                                                         child: AutoSizeText(
//                                                           '${searchItems[index].higherMoreThan15.nonmapCount}',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: w * .1,
//                                                       height: w * .1,
//                                                       child: Center(
//                                                         child: AutoSizeText(
//                                                           '${searchItems[index].higherMoreThan15.reviewedCount}',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                           style: GoogleFonts
//                                                               .openSans(
//                                                             fontSize: w * 0.032,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ]),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   initialItemCount: searchItems.length,
//                                 )
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   : state is AllBrandErrorState
//                       ? Center(
//                           child: AutoSizeText(
//                             state.errorMessage,
//                             textAlign: TextAlign.center,
//                             style: GoogleFonts.openSans(
//                                 fontWeight: FontWeight.bold, fontSize: w * .05),
//                           ),
//                         )
//                       : Center(
//                           child: Lottie.asset(
//                             'assets/lottie_animations/loading_bar.json',
//                             repeat: true,
//                             animate: true,
//                             width: 80,
//                             height: 80,
//                             frameRate: FrameRate(
//                               60,
//                             ),
//                           ),
//                         );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class AllBrandModel {
//   final brandId;
//   final HigherFrom515 lowerMoreThan15;
//   final totalProducts;
//   final image;
//   final key;
//   final HigherFrom515 lowerFrom515;
//   final HigherFrom515 lowerUpto5;
//   final HigherFrom515 higherUpto5;
//   final HigherFrom515 higherFrom515;
//   final HigherFrom515 higherMoreThan15;
//
//   AllBrandModel({
//     required this.brandId,
//     required this.lowerMoreThan15,
//     required this.totalProducts,
//     required this.image,
//     required this.key,
//     required this.lowerFrom515,
//     required this.lowerUpto5,
//     required this.higherUpto5,
//     required this.higherFrom515,
//     required this.higherMoreThan15,
//   });
//
//   factory AllBrandModel.fromRawJson(String str) =>
//       AllBrandModel.fromJson(json.decode(str));
//
//   String toRawJson() => json.encode(toJson());
//
//   factory AllBrandModel.fromJson(Map<String, dynamic> json) => AllBrandModel(
//         lowerMoreThan15: HigherFrom515.fromJson(json["lower more than 15%"]),
//         totalProducts: json["total_products"],
//         brandId: json["brand_id"],
//         image: json["Image"],
//         key: json["key"],
//         lowerFrom515: HigherFrom515.fromJson(json["lower from 5% - 15%"]),
//         lowerUpto5: HigherFrom515.fromJson(json["lower upto 5%"]),
//         higherUpto5: HigherFrom515.fromJson(json["higher upto 5%"]),
//         higherFrom515: HigherFrom515.fromJson(json["higher from 5% - 15%"]),
//         higherMoreThan15: HigherFrom515.fromJson(json["higher more than 15%"]),
//       );
//
//   Map<String, dynamic> toJson() => {
//         "lower more than 15%": lowerMoreThan15.toJson(),
//         "total_products": totalProducts,
//         "Image": image,
//         "key": key,
//         "lower from 5% - 15%": lowerFrom515.toJson(),
//         "lower upto 5%": lowerUpto5.toJson(),
//         "higher upto 5%": higherUpto5.toJson(),
//         "higher from 5% - 15%": higherFrom515.toJson(),
//         "higher more than 15%": higherMoreThan15.toJson(),
//       };
// }
//
// class HigherFrom515 {
//   final mapCount;
//   final nonmapCount;
//   final reviewedCount;
//
//   HigherFrom515({
//     required this.mapCount,
//     required this.nonmapCount,
//     required this.reviewedCount,
//   });
//
//   factory HigherFrom515.fromRawJson(String str) =>
//       HigherFrom515.fromJson(json.decode(str));
//
//   String toRawJson() => json.encode(toJson());
//
//   factory HigherFrom515.fromJson(Map<String, dynamic> json) => HigherFrom515(
//         mapCount: json["map_count"],
//         nonmapCount: json["nonmap_count"],
//         reviewedCount: json["reviewed_count"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "map_count": mapCount,
//         "nonmap_count": nonmapCount,
//         "reviewed_count": reviewedCount,
//       };
// }
