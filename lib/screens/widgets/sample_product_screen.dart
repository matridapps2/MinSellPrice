import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shoppingmegamart/bloc/product_list_by_id_bloc/product_list_by_id_bloc.dart';
import 'package:shoppingmegamart/model/product_list_model.dart';
import 'package:shoppingmegamart/reposotory_services/database/database_constants.dart';
import 'package:shoppingmegamart/reposotory_services/database/database_functions.dart';
import 'package:shoppingmegamart/screens/custom_expandable_widget.dart';
import 'package:shoppingmegamart/screens/widgets/custom_loader.dart';
import 'package:shoppingmegamart/size.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import 'product_screen_2.dart';

Color fromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

class ContentScreen extends StatefulWidget {
  const ContentScreen(
      {super.key,
        this.fromSearchScreen,
        required this.vendorName,
        required this.vendorImage,
        required this.vendorId,
        required this.date,
        required this.loadingData,
        required this.database,
        this.id,
        this.brandKey,
        this.loadingString,
        required this.isVendorPriceAnalysis,
        required this.isVendorTable,
        this.afSku,
        this.aiValue,
        this.hpSku,
        this.productMpn,
        this.productName});

  // final ProductListModel dataModel;
  final String vendorName, vendorImage, vendorId, date, loadingData;
  final String? id,
      brandKey,
      loadingString,
      afSku,
      hpSku,
      productMpn,
      productName;
  final bool isVendorPriceAnalysis, isVendorTable;
  final Database database;
  final bool? fromSearchScreen;
  final Map<String, String>? aiValue;

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final SwiperController _controller = SwiperController();

  String _vendorShortName = '';
  String _sisterVendorShortName = '';

  @override
  void initState() {
    // context.read<DatabaseBloc>().add(DatabaseInitEvent());
    getData();
    context.read<ProductListByIdBloc>().add(
      ProductListByIdLoadingEvent(
          vendorId: widget.vendorId,
          featuredProducts: false,
          date: widget.date,
          dataId: widget.id ?? '',
          brandKey: widget.isVendorPriceAnalysis == true
              ? widget.vendorName
              .toLowerCase()
              .replaceAll(' ', '_')
              .replaceAll('-', '_')
              .replaceAll('%', '')
              : widget.brandKey,
          productName: widget.productName,
          productMpn: widget.productMpn,
          fromSearchScreen: widget.fromSearchScreen ?? false,
          brandProductsEnabled: false,
          aiEngineData: widget.aiValue,
          isCategory: false),
    );
    super.initState();
  }

  // Database? database;
  List<Map<String, dynamic>> databaseData = [];

  void getData() async {
    List<Map<String, dynamic>> temp =
    await DatabaseHelper().getData(db: widget.database);

    final loginData =
    await DatabaseHelper().getUserInformation(db: widget.database);
    setState(() {
      databaseData = temp;
      _vendorShortName = loginData[vendor_short_nameKey];
      _sisterVendorShortName = loginData[sister_vendor_short_nameKey];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<ProductListByIdBloc, ProductListByIdState>(
          builder: (context, state) {
            return state is ProductListByIdLoading
                ? Center(
              child: CustomLoader(
                vendorName: widget.loadingData,
                imageString: widget.vendorImage,
                isAssetImage: widget.isVendorTable,
                loaderString: widget.loadingString,
              ),
            )
                : state is ProductListByIdErrorState
                ? Center(
              child: AutoSizeText(state.errorMessage.toString()),
            )
                : state is ProductListByIdLoadedState
                ? Swiper(
                controller: _controller,
                // allowImplicitScrolling: true,
                // curve: Curves.elasticInOut,
                axisDirection: AxisDirection.right,
                loop: false,
                scrollDirection: Axis.vertical,
                itemCount: state.productList.length,
                viewportFraction: 1,
                itemBuilder: (context, index) =>
                /*CustomProductCard2(data: state.productList[index], showAllCompetitors: true, showRT: false, showPrice: false, vendorId: int.parse(widget.vendorId),)*/
                SizedBox(
                  width: w,
                  height: h,
                  child: CurrentProductScreen(
                    prevData: state.productList[index],
                    vendorId: int.parse(widget.vendorId),
                    database: widget.database,
                    likedValue: 0,
                    notifiedValue: 0,
                    databaseData: databaseData,
                    vendorShortname: _vendorShortName,
                    sisterVendorShortName:
                    _sisterVendorShortName,
                  ),
                )
              //   (
              //   state: state,
              //   index: index,
              //   vendorId: int.parse(widget.vendorId),
              // ),
            )
                : const SizedBox();
          },
        ),
      ),
    );
  }
}

class ContentScreenMain extends StatefulWidget {
  const ContentScreenMain(
      {super.key,
        required this.state,
        required this.index,
        required this.vendorId});

  final ProductListByIdLoadedState state;

  final int index, vendorId;

  @override
  State<ContentScreenMain> createState() => _ContentScreenMainState();
}

class _ContentScreenMainState extends State<ContentScreenMain>
    with TickerProviderStateMixin {
  bool _priceFlipped = false;
  final controller = FlipCardController();

  bool _allCompetitorFlipped = false;

  @override
  void initState() {
    setState(() {
      widget.state.productList[widget.index].rt == '--'
          ? _priceFlipped = true
          : _allCompetitorFlipped = false;
    });
    _lottieController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    super.initState();
  }

  Container _buildProductWidget(ProductListByIdLoadedState state, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
            colors: index % 2 == 0
                ? [
              fromHex('#fde7e7'),
              fromHex('#e2e7ed'),
              fromHex('#d5dde3'),
            ]
                : [
              fromHex('#e9dbdc'),
              fromHex('#dce8f0'),
              fromHex('#f4e4e5'),
            ],
            transform: const GradientRotation(.3)),
      ),

      // color:
      // // Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0)
      // index % 2 == 0 ? Colors.grey : Colors.white,
      height: h,
      child: Stack(
        children: [
          /*Main Widget*/

          CustomProductCard(
            showPrice: _priceFlipped,
            data: state.productList[index],
            showAllCompetitors: _allCompetitorFlipped,
            showRT: !_allCompetitorFlipped,
            // vendorId: widget.vendorId,
          ),
          /*Side Menu*/
          buildSideMenu(data: state.productList[index]),

          /*Marquee Text Here*/
          // Positioned(
          //   bottom: 1,
          //   left: 15,
          //   right: w * .2,
          //   child: Card(
          //     elevation: 4,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     color: Colors.white.withOpacity(.3),
          //     shadowColor: Colors.white.withOpacity(.5),
          //     child: Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 5.0),
          //       child: SizedBox(
          //         width: w * .9,
          //         height: 30,
          //         child: Marquee(
          //           text: 'Some Recommended Text Here. ',
          //           style: GoogleFonts.montserrat(
          //             fontSize: 0.03 * w,
          //             color: Colors.black,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          animation(lottieController: _lottieController),
        ],
      ),
    );
  }

  Column buildATP(ProductListByIdLoadedState state, int index) {
    return Column(
      children: [
        Center(
          child: Card(
            elevation: 4,
            child: Container(
              width: w * .5,
              decoration:
              BoxDecoration(border: Border.all(color: Colors.black)),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ATP',
                        style: GoogleFonts.montserrat(
                          fontSize: 0.04 * w,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: w * .05,
                      ),
                      Text(
                        'Sales',
                        style: GoogleFonts.montserrat(
                          fontSize: 0.04 * w,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: w * .01,
                  ),
                  Text(
                    'Sales to ATP Ratio',
                    style: GoogleFonts.montserrat(
                      fontSize: 0.04 * w,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: w * .01,
                  ),
                  Text(
                    'Age',
                    style: GoogleFonts.montserrat(
                      fontSize: 0.04 * w,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: w * .03,
        ),
        Center(
          child: Card(
            elevation: 4,
            child: Container(
              width: w * .5,
              decoration:
              BoxDecoration(border: Border.all(color: Colors.black)),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AutoSizeText(
                        state.productList[index].atp.isEmpty
                            ? '0'
                            : state.productList[index].atp,
                        style: GoogleFonts.montserrat(
                          fontSize: 0.04 * w,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: w * .04,
                      ),
                      AutoSizeText(
                        state.productList[index].sales,
                        style: GoogleFonts.montserrat(
                          fontSize: 0.04 * w,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: w * .01,
                  ),
                  Container(
                    width: w * .3,
                    color: Colors.red,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: AutoSizeText(
                          state.productList[index].saleAtpRatio,
                          style: GoogleFonts.montserrat(
                            fontSize: 0.04 * w,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: w * .01,
                  ),
                  AutoSizeText(
                    '${state.productList[index].days} Days',
                    style: GoogleFonts.montserrat(
                      fontSize: 0.04 * w,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Align buildSideMenu({required ProductListModel data}) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        child: Card(
          elevation: 4,
          color: Colors.white.withOpacity(.3),
          shadowColor: Colors.white.withOpacity(.5),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: SizedBox(
            width: w,
            // height: h * .,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(
                      Icons.arrow_back,
                    ),
                  ),
                ),
                SizedBox(
                  width: w * .7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _changeLikeIcon = !_changeLikeIcon;
                          });
                          if (_changeLikeIcon == true) {
                            _lottieController
                                .forward()
                                .whenComplete(() => _lottieController.reset());
                          }
                        },
                        child: Icon(
                          _changeLikeIcon == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // share(controller: screenshotController);
                        },
                        child: const Icon(
                          Icons.send,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _allCompetitorFlipped = false;
                            _priceFlipped = true;
                          });

                          setState(() {});
                        },
                        child: AutoSizeText(
                          'Price',
                          style: GoogleFonts.montserrat(
                            fontSize: 0.035 * w,
                            color: _priceFlipped == true
                                ? Colors.blue
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (data.fourthVendorFinalPrice != '') {
                              _allCompetitorFlipped = true;
                              _priceFlipped = false;
                            }
                            // _rtFlipped = !_allCompetitorFlipped;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AutoSizeText(
                            'Comp',
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: GoogleFonts.montserrat(
                              fontSize: 0.035 * w,
                              color: _allCompetitorFlipped == true
                                  ? Colors.blue
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (data.rt != '--') {
                            setState(() {
                              _allCompetitorFlipped = false;
                              _priceFlipped = false;
                            });
                          } else {
                            setState(() {
                              _priceFlipped = true;
                            });
                          }
                        },
                        child: AutoSizeText(
                          'RP',
                          style: GoogleFonts.montserrat(
                            fontSize: 0.04 * w,
                            color: _allCompetitorFlipped == false &&
                                _priceFlipped == false &&
                                data.rt != '--'
                                ? Colors.blue
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  bool _changeLikeIcon = false;

  late final AnimationController _lottieController;

  // Widget _mspWidget({
  //   required String discountPercentage,
  //   required String msrp,
  //   required sellingPrice,
  //   required String z3Price,
  //   required String map,
  //   required String msp,
  // }) {
  //   return Center(
  //     child: Column(
  //       children: [
  //         Card(
  //           elevation: 4,
  //           child: Container(
  //             width: w * .5,
  //             decoration:
  //                 BoxDecoration(border: Border.all(color: Colors.black)),
  //             padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Center(
  //                   child: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Text(
  //                         'Disc%',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.black,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                       SizedBox(
  //                         width: w * .05,
  //                       ),
  //                       Text(
  //                         'MSRP',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.black,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   width: w * .5,
  //                   child: const Divider(
  //                     thickness: 1.5,
  //                     color: Colors.grey,
  //                   ),
  //                 ),
  //                 Center(
  //                   child: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Text(
  //                         'Sell Price',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.black,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                       SizedBox(
  //                         width: w * .05,
  //                       ),
  //                       Text(
  //                         'Z3 Price',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.black,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   width: w * .5,
  //                   child: const Divider(
  //                     thickness: 1.5,
  //                     color: Colors.grey,
  //                   ),
  //                 ),
  //                 Center(
  //                   child: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Text(
  //                         'MAP',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.black,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                       SizedBox(
  //                         width: w * .05,
  //                       ),
  //                       Text(
  //                         'MSP',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.black,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         SizedBox(
  //           height: w * .02,
  //         ),
  //         Card(
  //           elevation: 4,
  //           child: Container(
  //             width: w * .5,
  //             decoration:
  //                 BoxDecoration(border: Border.all(color: Colors.black)),
  //             padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Center(
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         '${discountPercentage.isEmpty ? '0' : discountPercentage}%',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.black,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                       SizedBox(
  //                         width: w * .05,
  //                       ),
  //                       Text(
  //                         '\$$msrp',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.black,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   width: w * .5,
  //                   child: const Divider(
  //                     thickness: 1.5,
  //                     color: Colors.grey,
  //                   ),
  //                 ),
  //                 Center(
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         '\$$sellingPrice',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.black,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                       SizedBox(
  //                         width: w * .05,
  //                       ),
  //                       Text(
  //                         '\$$z3Price',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.red,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   width: w * .5,
  //                   child: const Divider(
  //                     thickness: 1.5,
  //                     color: Colors.grey,
  //                   ),
  //                 ),
  //                 Center(
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         '\$$map',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.red,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                       SizedBox(
  //                         width: w * .05,
  //                       ),
  //                       Text(
  //                         '\$$msp',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.red,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _priceWidget({
  //   required String mainVendorPrice,
  //   required String mainVendorFinalPrice,
  //   required String mainVendorShipping,
  //   required String mainDiscountPercent,
  //   required String secondVendorPrice,
  //   required String secondVendorFinalPrice,
  //   required String secondVendorShipping,
  //   required String secondVendorDiscount,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Center(
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Column(
  //             children: [
  //               Card(
  //                 elevation: 4,
  //                 child: Container(
  //                   width: w * .42,
  //                   decoration:
  //                       BoxDecoration(border: Border.all(color: Colors.black)),
  //                   padding:
  //                       const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Center(
  //                         child: AutoSizeText(
  //                           '${widget.vendorId == 10024 ? 'HP ' : 'AF '}Final Price',
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.blue,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //
  //                       Center(
  //                         child: Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             AutoSizeText(
  //                               'Price',
  //                               style: GoogleFonts.montserrat(
  //                                 fontSize: 0.04 * w,
  //                                 color: Colors.black,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                             AutoSizeText(
  //                               ' + Shipping',
  //                               style: GoogleFonts.montserrat(
  //                                 fontSize: 0.04 * w,
  //                                 color: Colors.black,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       // SizedBox(
  //                       //   width: w * .5,
  //                       //   child: const Divider(thickness: 1.5,color: Colors.grey,),
  //                       // ),
  //                       Center(
  //                         child: AutoSizeText(
  //                           'Coupon %',
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.black,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               SizedBox(
  //                 height: w * .02,
  //               ),
  //               Card(
  //                 elevation: 4,
  //                 child: Container(
  //                   width: w * .42,
  //                   decoration:
  //                       BoxDecoration(border: Border.all(color: Colors.black)),
  //                   padding:
  //                       const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Center(
  //                         child: AutoSizeText(
  //                           mainVendorFinalPrice,
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.blue,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                       Center(
  //                         child: AutoSizeText(
  //                           '\$$mainVendorPrice +\$$mainVendorShipping',
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.black,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                       Center(
  //                         child: AutoSizeText(
  //                           '$mainDiscountPercent%',
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.black,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(width: .03 * w),
  //           Column(
  //             children: [
  //               Card(
  //                 elevation: 4,
  //                 child: Container(
  //                   width: w * .45,
  //                   decoration:
  //                       BoxDecoration(border: Border.all(color: Colors.black)),
  //                   padding:
  //                       const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Center(
  //                         child: AutoSizeText(
  //                           '${widget.vendorId == 10024 ? 'AF ' : 'HP '}Final Price',
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.blue,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                       Center(
  //                         child: Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             AutoSizeText(
  //                               'Price',
  //                               style: GoogleFonts.montserrat(
  //                                 fontSize: 0.04 * w,
  //                                 color: Colors.black,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                             AutoSizeText(
  //                               ' + Shipping',
  //                               style: GoogleFonts.montserrat(
  //                                 fontSize: 0.04 * w,
  //                                 color: Colors.black,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       Center(
  //                         child: AutoSizeText(
  //                           'Coupon %',
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.black,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               SizedBox(
  //                 height: w * .02,
  //               ),
  //               Card(
  //                 elevation: 4,
  //                 child: Container(
  //                   width: w * .45,
  //                   decoration:
  //                       BoxDecoration(border: Border.all(color: Colors.black)),
  //                   padding:
  //                       const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Center(
  //                         child: AutoSizeText(
  //                           '\$$secondVendorFinalPrice',
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.blue,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                       Center(
  //                         child: AutoSizeText(
  //                           '\$$secondVendorPrice + \$$secondVendorShipping',
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.black,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                       Center(
  //                         child: AutoSizeText(
  //                           '$secondVendorDiscount%',
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.black,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _competitorWidget({required ProductListModel item}) {
  //   return Column(
  //     children: [
  //       Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Center(
  //             child: Card(
  //               elevation: 4,
  //               child: Container(
  //                 width: w * .6,
  //                 decoration:
  //                     BoxDecoration(border: Border.all(color: Colors.black)),
  //                 padding:
  //                     const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Center(
  //                       child: AutoSizeText(
  //                         'Competitor Final Price',
  //                         maxLines: 1,
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.blue,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       height: w * .01,
  //                     ),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                       children: [
  //                         AutoSizeText(
  //                           'Price + Shipping',
  //                           maxLines: 1,
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.black,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                         AutoSizeText(
  //                           'Coupon %',
  //                           maxLines: 1,
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.black,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //           SizedBox(
  //             height: w * .001,
  //           ),
  //           Center(
  //             child: Card(
  //               elevation: 4,
  //               child: Container(
  //                 width: w * .6,
  //                 decoration:
  //                     BoxDecoration(border: Border.all(color: Colors.black)),
  //                 padding:
  //                     const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     CachedNetworkImage(
  //                       width: w * .5,
  //                       height: h * .04,
  //                       imageUrl:
  //                           '${AppInfo.kBaseUrl(stagingSelector: 0)}vendor-logo/${item.firstVendorName}.jpg',
  //                       errorWidget: (context, reason, _) {
  //                         return AutoSizeText(
  //                           item.firstVendorName.isEmpty
  //                               ? '----'
  //                               : item.firstVendorName,
  //                           textAlign: TextAlign.center,
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.black,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                     RichText(
  //                       textAlign: TextAlign.center,
  //                       text: TextSpan(
  //                         text:
  //                             '\$${item.firstVendorPrice.isEmpty ? ' --' : item.firstVendorPrice}\n',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.blue,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                         children: [
  //                           TextSpan(
  //                             text:
  //                                 '\$${item.firstVendorBasePrice.isEmpty ? ' --' : item.firstVendorBasePrice} + \$${item.firstVendorPriceShipping.isEmpty ? ' --' : item.firstVendorPriceShipping}    ${item.firstVendorExtraDiscount.isEmpty ? '--' : item.firstVendorExtraDiscount} %',
  //                             style: GoogleFonts.montserrat(
  //                               fontSize: 0.04 * w,
  //                               color: Colors.black,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //           SizedBox(
  //             height: w * .001,
  //           ),
  //           Center(
  //             child: Card(
  //               elevation: 4,
  //               child: Container(
  //                 width: w * .6,
  //                 decoration:
  //                     BoxDecoration(border: Border.all(color: Colors.black)),
  //                 padding:
  //                     const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     CachedNetworkImage(
  //                       width: w * .5,
  //                       height: h * .04,
  //                       imageUrl:
  //                           '${AppInfo.kBaseUrl(stagingSelector: 0)}vendor-logo/${item.secondVendorName}.jpg',
  //                       errorWidget: (context, reason, _) {
  //                         return AutoSizeText(
  //                           item.secondVendorName.isEmpty
  //                               ? '----'
  //                               : item.secondVendorName,
  //                           textAlign: TextAlign.center,
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.black,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                     RichText(
  //                       textAlign: TextAlign.center,
  //                       text: TextSpan(
  //                         text:
  //                             '\$${item.secondVendorPrice.isEmpty ? ' --' : item.secondVendorPrice}\n',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.blue,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                         children: [
  //                           TextSpan(
  //                             text:
  //                                 '\$${item.secondVendorBasePrice.isEmpty ? ' --' : item.secondVendorBasePrice} + \$${item.secondVendorPriceShipping.isEmpty ? ' --' : item.secondVendorPriceShipping}    ${item.secondVendorExtraDsicount.isEmpty ? '--' : item.secondVendorExtraDsicount} %',
  //                             style: GoogleFonts.montserrat(
  //                               fontSize: 0.04 * w,
  //                               color: Colors.black,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //           SizedBox(
  //             height: w * .001,
  //           ),
  //           Center(
  //             child: Card(
  //               elevation: 4,
  //               child: Container(
  //                 width: w * .6,
  //                 decoration:
  //                     BoxDecoration(border: Border.all(color: Colors.black)),
  //                 padding:
  //                     const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     CachedNetworkImage(
  //                       width: w * .5,
  //                       height: h * .04,
  //                       imageUrl:
  //                           '${AppInfo.kBaseUrl(stagingSelector: 0)}vendor-logo/${item.thirdVendorName}.jpg',
  //                       errorWidget: (context, reason, _) {
  //                         return AutoSizeText(
  //                           item.thirdVendorName.isEmpty
  //                               ? '----'
  //                               : item.thirdVendorName,
  //                           textAlign: TextAlign.center,
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.black,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                     RichText(
  //                       textAlign: TextAlign.center,
  //                       text: TextSpan(
  //                         text:
  //                             '\$${item.thirdVendorFinalPrice.isEmpty ? ' --' : item.thirdVendorFinalPrice}\n',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.blue,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                         children: [
  //                           TextSpan(
  //                             text:
  //                                 '\$${item.thirdVendorBasePrice.isEmpty ? ' --' : item.thirdVendorBasePrice} + \$${item.thirdVendorShipping.isEmpty ? ' --' : item.thirdVendorShipping}    ${item.thirdVendorExtraDiscount.isEmpty ? '--' : item.thirdVendorExtraDiscount} %',
  //                             style: GoogleFonts.montserrat(
  //                               fontSize: 0.04 * w,
  //                               color: Colors.black,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //           SizedBox(
  //             height: w * .001,
  //           ),
  //           Center(
  //             child: Card(
  //               elevation: 4,
  //               child: Container(
  //                 width: w * .6,
  //                 decoration:
  //                     BoxDecoration(border: Border.all(color: Colors.black)),
  //                 padding:
  //                     const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     CachedNetworkImage(
  //                       width: w * .5,
  //                       height: h * .04,
  //                       imageUrl:
  //                           '${AppInfo.kBaseUrl(stagingSelector: 0)}vendor-logo/${item.fourthVendorName}.jpg',
  //                       errorWidget: (context, reason, _) {
  //                         return AutoSizeText(
  //                           item.fourthVendorName.isEmpty
  //                               ? '----'
  //                               : item.fifthVendorName,
  //                           textAlign: TextAlign.center,
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.black,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                     RichText(
  //                       textAlign: TextAlign.center,
  //                       text: TextSpan(
  //                         text:
  //                             '\$${item.fourthVendorFinalPrice.isEmpty ? ' --' : item.fourthVendorFinalPrice}\n',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.blue,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                         children: [
  //                           TextSpan(
  //                             text:
  //                                 '\$${item.fourthVendorBasePrice.isEmpty ? ' --' : item.fourthVendorBasePrice} + \$${item.fourthVendorShipping.isEmpty ? ' --' : item.fourthVendorShipping}    ${item.fourthVendorExtraDiscount.isEmpty ? '--' : item.fourthVendorExtraDiscount} %',
  //                             style: GoogleFonts.montserrat(
  //                               fontSize: 0.04 * w,
  //                               color: Colors.black,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //           SizedBox(
  //             height: w * .001,
  //           ),
  //           Center(
  //             child: Card(
  //               elevation: 4,
  //               child: Container(
  //                 width: w * .6,
  //                 decoration:
  //                     BoxDecoration(border: Border.all(color: Colors.black)),
  //                 padding:
  //                     const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     CachedNetworkImage(
  //                       width: w * .5,
  //                       height: h * .04,
  //                       imageUrl:
  //                           '${AppInfo.kBaseUrl(stagingSelector: 0)}vendor-logo/${item.fifthVendorName}.jpg',
  //                       errorWidget: (context, reason, _) {
  //                         return AutoSizeText(
  //                           item.fifthVendorName.isEmpty
  //                               ? '----'
  //                               : item.fifthVendorName,
  //                           textAlign: TextAlign.center,
  //                           style: GoogleFonts.montserrat(
  //                             fontSize: 0.04 * w,
  //                             color: Colors.black,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                     RichText(
  //                       textAlign: TextAlign.center,
  //                       text: TextSpan(
  //                         text:
  //                             '\$${item.fifthVendorFinalPrice.isEmpty ? ' --' : item.fifthVendorFinalPrice}\n',
  //                         style: GoogleFonts.montserrat(
  //                           fontSize: 0.04 * w,
  //                           color: Colors.blue,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                         children: [
  //                           TextSpan(
  //                             text:
  //                                 '\$${item.fifthVendorBasePrice.isEmpty ? ' --' : item.fifthVendorBasePrice} + \$${item.fifthVendorShipping.isEmpty ? ' --' : item.fifthVendorShipping}    ${item.fifthVendorExtraDiscount.isEmpty ? '--' : item.fifthVendorExtraDiscount} %',
  //                             style: GoogleFonts.montserrat(
  //                               fontSize: 0.04 * w,
  //                               color: Colors.black,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  /*Sharing Methods*/
  Future<void> share({required ScreenshotController controller}) async {
    await controller.capture().then((image) async {
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/image.png').create();
        await imagePath.writeAsBytes(image);

        ///
        await Share.shareXFiles([XFile(imagePath.path)]);
      }
    });
  }

  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return _buildProductWidget(widget.state, widget.index);
  }
}

String returnVariation(
    {required String rp,
      required String vendorPrice,
      required String shipping}) {
  try {
    final double rpPrice = double.parse(rp);
    final double vendorPriceFinal = double.parse(vendorPrice);
// final double shippingPrice = double.parse(shipping);
    double variation = ((rpPrice) - vendorPriceFinal) /
        ((rpPrice + vendorPriceFinal) / 2) *
        100;

    return '${variation.roundToDouble()} %';
  } catch (e) {
    return '--';
  }
}

Widget animation({required AnimationController lottieController}) {
  Animation<double> sizeAnimation =
  Tween<double>(begin: 0, end: 300).animate(lottieController);

  return AnimatedBuilder(
    animation: lottieController,
    builder: (BuildContext context, Widget? child) {
      return Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: sizeAnimation.value,
          height: sizeAnimation.value,
          child: LottieBuilder.asset(
            'assets/lottie_animations/animation/like.json',
            frameRate: FrameRate(120),
            controller: lottieController,
            repeat: false,
          ),
        ),
      );
    },
  );
}
