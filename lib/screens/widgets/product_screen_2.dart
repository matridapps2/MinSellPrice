import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:minsellprice/app.dart';
import 'package:minsellprice/dashboard_screen.dart';
import 'package:minsellprice/model/product_list_model.dart';
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/reposotory_services/database/database_constants.dart';
import 'package:minsellprice/reposotory_services/database/database_functions.dart';
import 'package:minsellprice/screens/InAppBrowser.dart';
import 'package:minsellprice/screens/ai_price_engine/ai_pricie_engine_screen.dart';
import 'package:minsellprice/screens/sample_product.dart';
import 'package:minsellprice/screens/widgets/animated_notification_button.dart';
import 'package:minsellprice/services/extra_functions.dart';
import 'package:minsellprice/size.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';
import 'sample_product_screen.dart';

class CurrentProductScreen extends StatefulWidget {
  final VendorProduct? data;
  final ProductListModel? prevData;
  final int vendorId, notifiedValue, likedValue;
  final Database database;
  final List<Map<String, dynamic>> databaseData;
  final String vendorShortname, sisterVendorShortName;

  // final Map<String, GetOtherSeller>? getOtherSeller;

  const CurrentProductScreen({
    super.key,
    // this.fromSearchScreen,
    this.data,
    this.prevData,
    required this.vendorId,
    required this.database,
    required this.likedValue,
    required this.notifiedValue,
    required this.databaseData,
    required this.vendorShortname,
    required this.sisterVendorShortName,
    // this.getOtherSeller,
  });

  @override
  State<CurrentProductScreen> createState() => _CurrentProductScreenState();
}

class _CurrentProductScreenState extends State<CurrentProductScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool _changeLikeIcon = false;

  late final AnimationController _lottieController;
  int widgetNumber = 1;

  int _notifiedValue = 0;

  final _competitorScrollbar = ScrollController();

  void checkForLikedAndNotifiedValue() {
    if (widget.data == null) return;

    final uniqueId1 = int.parse('${widget.vendorId}${widget.data!.productId}');

    if (widget.databaseData.isEmpty) return;

    for (Map<String, dynamic> element in widget.databaseData) {
      if (element[uniqueId] == uniqueId1) {
        if (mounted) {
          setState(() {
            _notifiedValue = element[isNotifiedKey] ?? 0;
            isLiked = element[isLikedKey] ?? 0;
            _changeLikeIcon = isLiked != 0;
          });
        }
        break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _lottieController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _notifiedValue = widget.notifiedValue;
        isLiked = widget.likedValue;
        _changeLikeIcon = isLiked != 0;
      });
    }

    // Move checkForLikedAndNotifiedValue after the state initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        checkForLikedAndNotifiedValue();
      }
    });
  }

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

  Row sideMenu(
      {required BuildContext context, required ProductListModel data}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: () async {
            setState(() {
              if (isLiked == 0) {
                isLiked = 1;
              } else {
                isLiked = 0;
              }
            });

            setState(() {
              _changeLikeIcon = !_changeLikeIcon;
            });
            if (_changeLikeIcon == true) {
              _lottieController
                  .forward()
                  .whenComplete(() => _lottieController.reset());
            } else {}
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              _changeLikeIcon == true ? Icons.favorite : Icons.favorite_border,
            ),
          ),
        ),
        InkWell(
          onTap: () {},
          child: const Icon(
            Icons.send,
          ),
        ),
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              isScrollControlled: true,
              builder: (BuildContext context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AutoSizeText(
                            'Additional Information'.toUpperCase(),
                            style: GoogleFonts.openSans(
                              fontSize: 0.045 * w,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(
                                context,
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.close,
                                size: 35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 8,
                        ),
                        child: SizedBox(
                          width: w,
                          child: RichText(
                            text: TextSpan(
                              text: 'Brand: ',
                              style: GoogleFonts.openSans(
                                fontSize: 0.04 * w,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: data.brandName,
                                  style: GoogleFonts.openSans(
                                      fontSize: 0.04 * w,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 8,
                        ),
                        child: SizedBox(
                          width: w,
                          child: RichText(
                            text: TextSpan(
                              text: 'Vendor SKU: ',
                              style: GoogleFonts.openSans(
                                fontSize: 0.04 * w,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: data.vendorSku,
                                  style: GoogleFonts.openSans(
                                      fontSize: 0.04 * w,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 8,
                        ),
                        child: SizedBox(
                          width: w,
                          child: RichText(
                            text: TextSpan(
                              text: 'Product MPN: ',
                              style: GoogleFonts.openSans(
                                fontSize: 0.04 * w,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: data.productMpn,
                                  style: GoogleFonts.openSans(
                                      fontSize: 0.04 * w,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 8,
                        ),
                        child: SizedBox(
                          width: w,
                          child: RichText(
                            text: TextSpan(
                              text: 'Product Weight(LBS.): ',
                              style: GoogleFonts.openSans(
                                fontSize: 0.04 * w,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: data.weight,
                                  style: GoogleFonts.openSans(
                                      fontSize: 0.04 * w,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 8,
                        ),
                        child: SizedBox(
                          width: w,
                          child: RichText(
                            text: TextSpan(
                              text: 'Last Good Receipt: ',
                              style: GoogleFonts.openSans(
                                fontSize: 0.04 * w,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: data.lastGoodReceipt,
                                  style: GoogleFonts.openSans(
                                      fontSize: 0.04 * w,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 8,
                        ),
                        child: SizedBox(
                          width: w,
                          child: RichText(
                            text: TextSpan(
                              text: 'Applied Rule: ',
                              style: GoogleFonts.openSans(
                                fontSize: 0.04 * w,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: data.ruleName,
                                  style: GoogleFonts.openSans(
                                      fontSize: 0.04 * w,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 8,
                        ),
                        child: SizedBox(
                          width: w,
                          child: RichText(
                            text: TextSpan(
                              text: 'Applied Rule: ',
                              style: GoogleFonts.openSans(
                                fontSize: 0.04 * w,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: data.ruleName,
                                  style: GoogleFonts.openSans(
                                      fontSize: 0.04 * w,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            child: Icon(
              Icons.info_outline,
            ),
          ),
        ),
        AnimatedNotificationButton(
          productName: data.productName,
          vendorIdProductId: data.vendorProductId,
          isLiked: isLiked,
          productSKU: data.productId,
          database: widget.database,
          vendorId: widget.vendorId,
          notifiedIntValue: _notifiedValue,
          productData: jsonEncode(data.toJson()),
        ),
      ],
    );
  }

  int isLiked = 0;

  /*Sharing Methods*/

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Handle both VendorProduct and ProductListModel types
    ProductListModel? productData;
    if (widget.data != null) {
      // Convert VendorProduct to ProductListModel

      try {
        final vendorProduct = widget.data!;
        log('image url ' + vendorProduct.productImage);
        productData = ProductListModel(
          productId: vendorProduct.productId,
          productName: vendorProduct.productName,
          productImage: vendorProduct.productImage,
          productMpn: vendorProduct.productMpn,
          brandName: vendorProduct.brandName,
          vendorSku: vendorProduct.vendorSku,
          weight: vendorProduct.weight,
          materialGroup: vendorProduct.materialGroup,
          lastGoodReceipt: vendorProduct.lastGoodReceipt,
          ruleName: vendorProduct.ruleName,
          firstVendorPrice: vendorProduct.firstVendorPrice,
          firstVendorBasePrice: vendorProduct.firstVendorBasePrice,
          firstVendorPriceShipping: vendorProduct.firstVendorPriceShipping,
          firstVendorExtraDiscount: vendorProduct.firstVendorExtraDiscount,
          firstVendorName: vendorProduct.firstVendorName,
          firstVendorUrl: vendorProduct.firstVendorUrl,
          secondVendorPrice: vendorProduct.secondVendorPrice,
          secondVendorBasePrice: vendorProduct.secondVendorBasePrice,
          secondVendorPriceShipping: vendorProduct.secondVendorPriceShipping,
          secondVendorExtraDsicount: vendorProduct.secondVendorExtraDiscount,
          secondVendorName: vendorProduct.secondVendorName,
          secondVendorUrl: vendorProduct.secondVendorUrl,
          thirdVendorName: vendorProduct.thirdVendorName,
          thirdVendorUrl: vendorProduct.thirdVendorUrl,
          thirdVendorFinalPrice: vendorProduct.thirdVendorPrice,
          thirdVendorBasePrice: vendorProduct.thirdVendorBasePrice,
          thirdVendorShipping: vendorProduct.thirdVendorPriceShipping,
          thirdVendorExtraDiscount: vendorProduct.thirdVendorExtraDiscount,
          fourthVendorName: vendorProduct.fourthVendorName,
          fourthVendorUrl: vendorProduct.fourthVendorUrl,
          fourthVendorFinalPrice: vendorProduct.fourthVendorPrice,
          fourthVendorBasePrice: vendorProduct.fourthVendorBasePrice,
          fourthVendorShipping: vendorProduct.fourthVendorPriceShipping,
          fourthVendorExtraDiscount: vendorProduct.fourthVendorExtraDiscount,
          fifthVendorName: vendorProduct.fifthVendorName,
          fifthVendorUrl: vendorProduct.fifthVendorUrl,
          fifthVendorFinalPrice: vendorProduct.fifthVendorPrice,
          fifthVendorBasePrice: vendorProduct.fifthVendorBasePrice,
          fifthVendorShipping: vendorProduct.fifthVendorPriceShipping,
          fifthVendorExtraDiscount: vendorProduct.fifthVendorExtraDiscount,
          vendorProductId: vendorProduct.vendorProductId,
          firstVendorProductId: vendorProduct.firstVendorProductId,
          secondVendorProductId: vendorProduct.secondVendorProductId,
          thirdVendorProductId: vendorProduct.thirdVendorProductId,
          fourthVendorProductId: vendorProduct.fourthVendorProductId,
          fifthVendorProductId: vendorProduct.fifthVendorProductId,
          competitorId: vendorProduct.competitorId ?? '',
          vendorPriceFinalPrice: vendorProduct.vendorPriceFinalPrice,
          sisterExtraDiscount: vendorProduct.sisterExtraDiscount ?? '',
          sisterVendorBasePrice: vendorProduct.sisterVendorBasePrice ?? '',
          sisterVendorPriceDate: vendorProduct.sisterVendorPriceDate ?? '',
          sisterVendorFinalPrice: vendorProduct.sisterVendorFinalPrice ?? '',
          sisterVendorShipping: vendorProduct.sisterVendorShipping ?? '',
          vendorPriceDate: vendorProduct.vendorpriceDate,
          rpSellVariation: vendorProduct.rpVariationSellPrice,
          brandId: vendorProduct.brandId,
          gcode: vendorProduct.gcode,
          msrp: vendorProduct.msrp,
          brandKey: vendorProduct.brandKey,
          mainImage: vendorProduct.mainImage,
          secondarySku: vendorProduct.secondarySku,
          vendorName: vendorProduct.vendorName,
          vendorpricePrice: vendorProduct.vendorpricePrice,
          vendorpriceShipping: vendorProduct.vendorpriceShipping,
          extraDiscount: vendorProduct.extraDiscount,
          vendorBaseUrl: vendorProduct.vendorBaseUrl ?? '',
          atp: vendorProduct.atp,
          sales: vendorProduct.sales,
          sellPrice: vendorProduct.sellPrice,
          z3Price: vendorProduct.z3Price,
          mapPrice: vendorProduct.mapPrice,
          vk11: vendorProduct.vk11,
          movingAverage: vendorProduct.movingAverage,
          purchasePrice: vendorProduct.purchasePrice,
          saleAtpRatio: vendorProduct.saleAtpRatio,
          amountInvested: vendorProduct.amountInvested,
          rt: vendorProduct.rt,
          days: vendorProduct.days,
          msp: vendorProduct.msp,
          rp: vendorProduct.rp,
          rpCriteria: vendorProduct.rpCriteria,
          competitor: vendorProduct.competitor ?? '',
          currentDiscount: vendorProduct.currentDiscount,
          gpPercent: vendorProduct.gpPercent,
          shipping: vendorProduct.shipping,
          currentGp: vendorProduct.currentGp,
          adjustedPrice: vendorProduct.adjustedPrice,
          firstVendorPercentage: vendorProduct.firstVendorPercentage,
          secondVendorPercentage: vendorProduct.secondVendorPercentage,
          vendorpriceCount: vendorProduct.vendorpriceCount,
          defaultcompetitor: vendorProduct.defaultcompetitor ?? '',
          rpVariation: vendorProduct.rpVariation,
          vendorUrl: vendorProduct.vendorUrl,
        );
      } catch (e) {
        print('Error converting VendorProduct to ProductListModel: $e');
        productData = null;
      }
    } else if (widget.prevData != null) {
      try {
        final vendorProduct = widget.prevData!;
        productData = ProductListModel(
          productId: vendorProduct.productId,
          productName: vendorProduct.productName,
          productImage: vendorProduct.productImage,
          productMpn: vendorProduct.productMpn,
          brandName: vendorProduct.brandName,
          vendorSku: vendorProduct.vendorSku,
          weight: vendorProduct.weight,
          materialGroup: vendorProduct.materialGroup,
          lastGoodReceipt: vendorProduct.lastGoodReceipt,
          ruleName: vendorProduct.ruleName,
          firstVendorPrice: vendorProduct.firstVendorPrice,
          firstVendorBasePrice: vendorProduct.firstVendorBasePrice,
          firstVendorPriceShipping: vendorProduct.firstVendorPriceShipping,
          firstVendorExtraDiscount: vendorProduct.firstVendorExtraDiscount,
          firstVendorName: vendorProduct.firstVendorName,
          firstVendorUrl: vendorProduct.firstVendorUrl,
          secondVendorPrice: vendorProduct.secondVendorPrice,
          secondVendorBasePrice: vendorProduct.secondVendorBasePrice,
          secondVendorPriceShipping: vendorProduct.secondVendorPriceShipping,
          secondVendorExtraDsicount: vendorProduct.secondVendorExtraDsicount,
          secondVendorName: vendorProduct.secondVendorName,
          secondVendorUrl: vendorProduct.secondVendorUrl,
          thirdVendorName: vendorProduct.thirdVendorName,
          thirdVendorUrl: vendorProduct.thirdVendorUrl,
          thirdVendorFinalPrice: vendorProduct.thirdVendorFinalPrice,
          thirdVendorBasePrice: vendorProduct.thirdVendorBasePrice,
          thirdVendorShipping: vendorProduct.thirdVendorShipping,
          thirdVendorExtraDiscount: vendorProduct.thirdVendorExtraDiscount,
          fourthVendorName: vendorProduct.fourthVendorName,
          fourthVendorUrl: vendorProduct.fourthVendorUrl,
          fourthVendorFinalPrice: vendorProduct.fourthVendorFinalPrice,
          fourthVendorBasePrice: vendorProduct.fourthVendorBasePrice,
          fourthVendorShipping: vendorProduct.fourthVendorShipping,
          fourthVendorExtraDiscount: vendorProduct.fourthVendorExtraDiscount,
          fifthVendorName: vendorProduct.fifthVendorName,
          fifthVendorUrl: vendorProduct.fifthVendorUrl,
          fifthVendorFinalPrice: vendorProduct.fifthVendorFinalPrice,
          fifthVendorBasePrice: vendorProduct.fifthVendorBasePrice,
          fifthVendorShipping: vendorProduct.fifthVendorShipping,
          fifthVendorExtraDiscount: vendorProduct.fifthVendorExtraDiscount,
          vendorProductId: vendorProduct.vendorProductId,
          firstVendorProductId: vendorProduct.firstVendorProductId,
          secondVendorProductId: vendorProduct.secondVendorProductId,
          thirdVendorProductId: vendorProduct.thirdVendorProductId,
          fourthVendorProductId: vendorProduct.fourthVendorProductId,
          fifthVendorProductId: vendorProduct.fifthVendorProductId,
          competitorId: vendorProduct.competitorId,
          vendorPriceFinalPrice: vendorProduct.vendorPriceFinalPrice,
          sisterExtraDiscount: vendorProduct.sisterExtraDiscount ?? '',
          sisterVendorBasePrice: vendorProduct.sisterVendorBasePrice ?? '',
          sisterVendorPriceDate: vendorProduct.sisterVendorPriceDate ?? '',
          sisterVendorFinalPrice: vendorProduct.sisterVendorFinalPrice ?? '',
          sisterVendorShipping: vendorProduct.sisterVendorShipping ?? '',
          vendorPriceDate: vendorProduct.vendorPriceDate,
          rpSellVariation: vendorProduct.rpSellVariation,
          brandId: vendorProduct.brandId,
          gcode: vendorProduct.gcode,
          msrp: vendorProduct.msrp,
          brandKey: vendorProduct.brandKey,
          mainImage: vendorProduct.mainImage,
          secondarySku: vendorProduct.secondarySku,
          vendorName: vendorProduct.vendorName,
          vendorpricePrice: vendorProduct.vendorpricePrice,
          vendorpriceShipping: vendorProduct.vendorpriceShipping,
          extraDiscount: vendorProduct.extraDiscount,
          vendorBaseUrl: vendorProduct.vendorBaseUrl ?? '',
          atp: vendorProduct.atp,
          sales: vendorProduct.sales,
          sellPrice: vendorProduct.sellPrice,
          z3Price: vendorProduct.z3Price,
          mapPrice: vendorProduct.mapPrice,
          vk11: vendorProduct.vk11,
          movingAverage: vendorProduct.movingAverage,
          purchasePrice: vendorProduct.purchasePrice,
          saleAtpRatio: vendorProduct.saleAtpRatio,
          amountInvested: vendorProduct.amountInvested,
          rt: vendorProduct.rt,
          days: vendorProduct.days,
          msp: vendorProduct.msp,
          rp: vendorProduct.rp,
          rpCriteria: vendorProduct.rpCriteria,
          competitor: vendorProduct.competitor ?? '',
          currentDiscount: vendorProduct.currentDiscount,
          gpPercent: vendorProduct.gpPercent,
          shipping: vendorProduct.shipping,
          currentGp: vendorProduct.currentGp,
          adjustedPrice: vendorProduct.adjustedPrice,
          firstVendorPercentage: vendorProduct.firstVendorPercentage,
          secondVendorPercentage: vendorProduct.secondVendorPercentage,
          vendorpriceCount: vendorProduct.vendorpriceCount,
          defaultcompetitor: vendorProduct.defaultcompetitor ?? '',
          rpVariation: vendorProduct.rpVariation,
          vendorUrl: vendorProduct.vendorUrl,
        );
      } catch (e) {
        print('Error converting VendorProduct to ProductListModel: $e');
        productData = null;
      }
    } else {
      productData = null;
    }

    if (productData == null) {
      return const Scaffold(
        body: Center(
          child: Text('No product data available'),
        ),
      );
    }

    final pId = productData.productId.toString();
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        toolbarHeight: .16 * w,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DashboardScreen()));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: const Color.fromARGB(255, 237, 63, 69),
            child: Image.asset(
              'assets/shopping_mega_mart_logo.png',
              height: .2 * w,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _changeLikeIcon == true ? Icons.favorite : Icons.favorite_border,
              color: _changeLikeIcon == true ? Colors.red : Colors.black,
            ),
            onPressed: () async {
              setState(() {
                if (isLiked == 0) {
                  isLiked = 1;
                } else {
                  isLiked = 0;
                }
                _changeLikeIcon = !_changeLikeIcon;
              });

              if (_changeLikeIcon == true) {
                _lottieController
                    .forward()
                    .whenComplete(() => _lottieController.reset());
              }

              try {
                await DatabaseHelper().addAndUpdateProduct(
                  db: widget.database,
                  vendorId:
                      int.parse('${widget.vendorId}${productData!.productId}'),
                  productSku: productData.productId,
                  isLiked: isLiked,
                  isNotified: _notifiedValue,
                  productData:
                      keepSingleDollarSign(jsonEncode(productData.toJson())),
                );
              } catch (e) {
                log(e.toString());
              }
              await DatabaseHelper().showAllProducts(db: widget.database);
            },
          ),
          GestureDetector(
            onTap: () {
              share(controller: screenshotController);
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.share),
            ),
          ),
        ],
      ),
      body: Screenshot(
        controller: screenshotController,
        child: SafeArea(
          top: true,
          child: Container(
            color: '#f0f1f1'.toColor(),
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      color: Colors.white.withOpacity(.4),
                      width: w,
                      child: Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: SizedBox(
                                  child: Center(
                                    child: CachedNetworkImage(
                                      imageUrl: productData.productImage,
                                      height: h * .3,
                                      placeholder: (context, url) => Center(
                                        child: Lottie.asset(
                                          'assets/lottie_animations/loading_bar.json',
                                          repeat: true,
                                          animate: true,
                                          width: 45,
                                          height: 45,
                                          frameRate: FrameRate(60),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Center(
                                        child: Image.asset(
                                          'assets/No_Image_Available.jpg',
                                          height: h * .3,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  left: 8,
                                  right: 2,
                                ),
                                child: Text(
                                  productData.productName,
                                  maxLines: 4,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: w * .035,
                                    wordSpacing: 0,
                                    letterSpacing: 0,
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 3),
                                child: InkWell(
                                  onTap: () async {
                                    await copyData(
                                      data: productData!.productMpn,
                                    );
                                  },
                                  child: AutoSizeText(
                                    'MPN# ${productData.productMpn}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontFamily: 'Segoe UI',
                                        fontSize: w * .035,
                                        wordSpacing: 0,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w500

                                        // fontWeight: FontWeight.w900
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              /*  SizedBox(
                                width: w,
                                child: FittedBox(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [

                                      Container(
                                        width: w * .5,
                                        decoration:
                                            const BoxDecoration(),
                                        padding:
                                            const EdgeInsets.all(4),
                                        child: Column(
                                          mainAxisSize:
                                              MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                text: 'SKU: ',
                                                style: GoogleFonts
                                                    .openSans(
                                                        color: Colors
                                                            .black),
                                                children: [
                                                  TextSpan(
                                                    text: widget
                                                        .data.vendorSku,
                                                    style: GoogleFonts
                                                        .openSans(
                                                            color: Colors
                                                                .black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                  const TextSpan(
                                                      text: '\nMPN: '),
                                                  TextSpan(
                                                    text: widget.data
                                                        .productMpn,
                                                    style: GoogleFonts
                                                        .openSans(
                                                            color: Colors
                                                                .black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                  const TextSpan(
                                                      text:
                                                          '\nWEIGHT(LBS): '),
                                                  TextSpan(
                                                    text: widget
                                                        .data.weight,
                                                    style: GoogleFonts
                                                        .openSans(
                                                            color: Colors
                                                                .black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                  const TextSpan(
                                                      text:
                                                          '\nMATERIAL GROUP: '),
                                                  TextSpan(
                                                    text: widget.data
                                                        .materialGroup,
                                                    style: GoogleFonts
                                                        .openSans(
                                                            color: Colors
                                                                .black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                elevation: 10,
                                                shape:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                              10.0),
                                                ),
                                                isScrollControlled:
                                                    true,
                                                builder: (BuildContext
                                                    context) {
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize
                                                            .min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(
                                                                8.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize
                                                                  .max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            AutoSizeText(
                                                              'Additional Information'
                                                                  .toUpperCase(),
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                fontSize:
                                                                    0.045 *
                                                                        w,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap:
                                                                  () {
                                                                Navigator
                                                                    .pop(
                                                                  context,
                                                                );
                                                              },
                                                              child:
                                                                  const Padding(
                                                                padding:
                                                                    EdgeInsets.all(4.0),
                                                                child:
                                                                    Icon(
                                                                  Icons
                                                                      .close,
                                                                  size:
                                                                      35,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Card(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            vertical:
                                                                16.0,
                                                            horizontal:
                                                                8,
                                                          ),
                                                          child:
                                                              SizedBox(
                                                            width: w,
                                                            child:
                                                                RichText(
                                                              text:
                                                                  TextSpan(
                                                                text:
                                                                    'Brand: ',
                                                                style: GoogleFonts
                                                                    .openSans(
                                                                  fontSize:
                                                                      0.04 * w,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                  color:
                                                                      Colors.black,
                                                                ),
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        widget.data!.brandName,
                                                                    style: GoogleFonts.openSans(
                                                                        fontSize: 0.04 * w,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Colors.green),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Card(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            vertical:
                                                                16.0,
                                                            horizontal:
                                                                8,
                                                          ),
                                                          child:
                                                              SizedBox(
                                                            width: w,
                                                            child:
                                                                RichText(
                                                              text:
                                                                  TextSpan(
                                                                text:
                                                                    'Vendor SKU: ',
                                                                style: GoogleFonts
                                                                    .openSans(
                                                                  fontSize:
                                                                      0.04 * w,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                  color:
                                                                      Colors.black,
                                                                ),
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        widget.data!.vendorSku,
                                                                    style: GoogleFonts.openSans(
                                                                        fontSize: 0.04 * w,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Colors.green),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      Card(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            vertical:
                                                                16.0,
                                                            horizontal:
                                                                8,
                                                          ),
                                                          child:
                                                              SizedBox(
                                                            width: w,
                                                            child:
                                                                RichText(
                                                              text:
                                                                  TextSpan(
                                                                text:
                                                                    'Product MPN: ',
                                                                style: GoogleFonts
                                                                    .openSans(
                                                                  fontSize:
                                                                      0.04 * w,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                  color:
                                                                      Colors.black,
                                                                ),
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        widget.data!.productMpn,
                                                                    style: GoogleFonts.openSans(
                                                                        fontSize: 0.04 * w,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Colors.green),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Card(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            vertical:
                                                                16.0,
                                                            horizontal:
                                                                8,
                                                          ),
                                                          child:
                                                              SizedBox(
                                                            width: w,
                                                            child:
                                                                RichText(
                                                              text:
                                                                  TextSpan(
                                                                text:
                                                                    'Product Weight(LBS.): ',
                                                                style: GoogleFonts
                                                                    .openSans(
                                                                  fontSize:
                                                                      0.04 * w,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                  color:
                                                                      Colors.black,
                                                                ),
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        widget.data!.weight,
                                                                    style: GoogleFonts.openSans(
                                                                        fontSize: 0.04 * w,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Colors.green),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),


                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Padding(
                                              padding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 8,
                                              ),
                                              child: Icon(
                                                Icons.info_outline,
                                              ),
                                            ),
                                          ),
                                          */
                              /*AnimatedNotificationButton(
                                            productName:
                                                widget.data!.productName,
                                            vendorIdProductId: widget
                                                .data.vendorProductId,
                                            isLiked: isLiked,
                                            productSKU:
                                                widget.data!.productId,
                                            database: widget.database,
                                            vendorId: widget.vendorId,
                                            notifiedIntValue:
                                                _notifiedValue,
                                            productData: jsonEncode(
                                                widget.data!.toJson()),
                                          ),*/ /*
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),*/
                            ],
                          ),
                        ),
                      ),
                    ),
                    verticalSpace(verticalSpace: 1),
                    Expanded(
                      child: Scrollbar(
                          thickness: 5,
                          trackVisibility: true,
                          thumbVisibility: true,
                          controller: _competitorScrollbar,
                          child: CompetitorClass(
                            firstVendorPrice: productData.firstVendorPrice,
                            firstVendorBasePrice:
                                productData.firstVendorBasePrice,
                            firstVendorPriceShipping:
                                productData.firstVendorPriceShipping,
                            firstVendorExtraDiscount:
                                productData.firstVendorExtraDiscount,
                            firstVendorName: productData.firstVendorName,
                            firstVendorUrl: productData.firstVendorUrl,
                            secondVendorPrice: productData.secondVendorPrice,
                            secondVendorBasePrice:
                                productData.secondVendorBasePrice,
                            secondVendorPriceShipping:
                                productData.secondVendorPriceShipping,
                            secondVendorExtraDsicount:
                                productData.secondVendorExtraDsicount,
                            secondVendorName: productData.secondVendorName,
                            secondVendorUrl: productData.secondVendorUrl,
                            thirdVendorName: productData.thirdVendorName,
                            thirdVendorUrl: productData.thirdVendorUrl,
                            thirdVendorFinalPrice:
                                productData.thirdVendorFinalPrice,
                            thirdVendorBasePrice:
                                productData.thirdVendorBasePrice,
                            thirdVendorShipping:
                                productData.thirdVendorShipping,
                            thirdVendorExtraDiscount:
                                productData.thirdVendorExtraDiscount,
                            fourthVendorName: productData.fourthVendorName,
                            fourthVendorUrl: productData.fourthVendorUrl,
                            fourthVendorFinalPrice:
                                productData.fourthVendorFinalPrice,
                            fourthVendorBasePrice:
                                productData.fourthVendorBasePrice,
                            fourthVendorShipping:
                                productData.fourthVendorShipping,
                            fourthVendorExtraDiscount:
                                productData.fourthVendorExtraDiscount,
                            fifthVendorName: productData.fifthVendorName,
                            fifthVendorUrl: productData.fifthVendorUrl,
                            fifthVendorFinalPrice:
                                productData.fifthVendorFinalPrice,
                            fifthVendorBasePrice:
                                productData.fifthVendorBasePrice,
                            fifthVendorShipping:
                                productData.fifthVendorShipping,
                            fifthVendorExtraDiscount:
                                productData.fifthVendorExtraDiscount,
                            scrollController: _competitorScrollbar,
                            firstVendorProductId:
                                productData.firstVendorProductId,
                            secondVendorProductId:
                                productData.secondVendorProductId,
                            thirdVendorProductId:
                                productData.thirdVendorProductId,
                            fourthVendorProductId:
                                productData.fourthVendorProductId,
                            fifthVendorProductId:
                                productData.fifthVendorProductId,
                            competitorId: productData.competitorId,
                            vendorpriceFinalprice:
                                productData.vendorPriceFinalPrice,
                          )),
                    ),
                  ],
                ),
                animation(lottieController: _lottieController),
                // Positioned(top: h *.45,child:
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getVendorWidget(String vendorKey, Map<String, dynamic> data) {
    List<String> vendorNames = ['First', 'Second', 'Third', 'Fourth', 'Fifth']
        .map((vendor) => '${vendor}VendorName')
        .toList();

    if (vendorNames.any((name) => data[name] == vendorKey)) {
      return const Text('--\n--');
    } else {
      String vendorFinalPrice = data['${vendorKey}VendorPrice'];
      String vendorBasePrice = data['${vendorKey}VendorBasePrice'];
      String vendorShipping = data['${vendorKey}VendorPriceShipping'];

      return RichText(
        text: TextSpan(
          text: '$vendorFinalPrice\n',
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
                text: '$vendorBasePrice + $vendorShipping',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _lottieController.dispose();
    _competitorScrollbar.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class CompetitorClass extends StatelessWidget {
  const CompetitorClass({
    super.key,
    required this.firstVendorPrice,
    required this.firstVendorBasePrice,
    required this.firstVendorPriceShipping,
    required this.firstVendorExtraDiscount,
    required this.firstVendorName,
    required this.firstVendorUrl,
    required this.secondVendorPrice,
    required this.secondVendorBasePrice,
    required this.secondVendorPriceShipping,
    required this.secondVendorExtraDsicount,
    required this.secondVendorName,
    required this.secondVendorUrl,
    required this.thirdVendorName,
    required this.thirdVendorUrl,
    required this.thirdVendorFinalPrice,
    required this.thirdVendorBasePrice,
    required this.thirdVendorShipping,
    required this.thirdVendorExtraDiscount,
    required this.fourthVendorName,
    required this.fourthVendorUrl,
    required this.fourthVendorFinalPrice,
    required this.fourthVendorBasePrice,
    required this.fourthVendorShipping,
    required this.fourthVendorExtraDiscount,
    required this.fifthVendorName,
    required this.fifthVendorUrl,
    required this.fifthVendorFinalPrice,
    required this.fifthVendorBasePrice,
    required this.fifthVendorShipping,
    required this.fifthVendorExtraDiscount,
    required this.scrollController,
    required this.firstVendorProductId,
    required this.secondVendorProductId,
    required this.thirdVendorProductId,
    required this.fourthVendorProductId,
    required this.fifthVendorProductId,
    required this.competitorId,
    required this.vendorpriceFinalprice,
  });

  final ScrollController scrollController;
  final String competitorId;
  final String vendorpriceFinalprice;
  final String firstVendorPrice;
  final String firstVendorBasePrice;
  final String firstVendorPriceShipping;
  final String firstVendorExtraDiscount;
  final String firstVendorName;
  final String firstVendorProductId;
  final String firstVendorUrl;
  final String secondVendorPrice;
  final String secondVendorBasePrice;
  final String secondVendorPriceShipping;
  final String secondVendorExtraDsicount;
  final String secondVendorName;
  final String secondVendorProductId;
  final String secondVendorUrl;

  /*Third Competitor Detail*/

  final String thirdVendorName,
      thirdVendorUrl,
      thirdVendorFinalPrice,
      thirdVendorBasePrice,
      thirdVendorShipping,
      thirdVendorProductId,
      thirdVendorExtraDiscount;

/*Fourth Competitor Detail*/

  final String fourthVendorName,
      fourthVendorUrl,
      fourthVendorFinalPrice,
      fourthVendorBasePrice,
      fourthVendorShipping,
      fourthVendorProductId,
      fourthVendorExtraDiscount;

/*Fifth Competitor Detail*/

  final String fifthVendorName,
      fifthVendorUrl,
      fifthVendorFinalPrice,
      fifthVendorBasePrice,
      fifthVendorShipping,
      fifthVendorProductId,
      fifthVendorExtraDiscount;

  @override
  Widget build(BuildContext context) {
    final totalCompetitors = totalNumberOfCompetitors(
      firstVendorPrice: firstVendorPrice,
      secondVendorPrice: secondVendorPrice,
      thirdVendorPrice: thirdVendorFinalPrice,
      fourthVendorPrice: fourthVendorFinalPrice,
      fifthVendorPrice: fifthVendorFinalPrice,
    );

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*Experiment Widget*/
          verticalSpace(verticalSpace: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: SizedBox(
              width: w,
              child: AutoSizeText(
                totalCompetitors == 0
                    ? 'Not Available'
                    : 'Available at $totalCompetitors store',
                style: GoogleFonts.montserrat(
                  fontSize: 0.06 * w,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (totalCompetitors > 0) ...[
            CompetitorTile(
                activeIndex: 0,
                vendorImage: firstVendorName,
                vendorFinalPrice: firstVendorPrice,
                vendorBasePrice: firstVendorBasePrice,
                vendorShipping: keepSingleDollarSign(firstVendorPriceShipping
                                    .contains('--')
                                ? firstVendorPriceShipping.replaceAll('\$', '')
                                : firstVendorPriceShipping)
                            .replaceAll('\$', '') ==
                        '0.00'
                    ? 'Free Shipping'
                    : keepSingleDollarSign(
                        firstVendorPriceShipping.contains('--')
                            ? firstVendorPriceShipping.replaceAll('\$', '')
                            : firstVendorPriceShipping),
                vendorDiscount: firstVendorExtraDiscount == '0.0' ||
                        firstVendorExtraDiscount == '--'
                    ? ''
                    : firstVendorExtraDiscount,
                vendorProductUrl: firstVendorUrl),
            CompetitorTile(
                activeIndex: 1,
                vendorImage: secondVendorName,
                vendorFinalPrice: keepSingleDollarSign(
                    '${secondVendorPrice.contains('--') ? secondVendorPrice.replaceAll('\$', '') : secondVendorPrice}\n'),
                vendorBasePrice: keepSingleDollarSign(
                    secondVendorBasePrice.contains('--')
                        ? secondVendorBasePrice.replaceAll('\$', '')
                        : secondVendorBasePrice),
                vendorShipping: keepSingleDollarSign(secondVendorPriceShipping
                                    .contains('--')
                                ? secondVendorPriceShipping.replaceAll('\$', '')
                                : secondVendorPriceShipping)
                            .replaceAll('\$', '') ==
                        '0.00'
                    ? 'Free Shipping'
                    : keepSingleDollarSign(
                        secondVendorPriceShipping.contains('--')
                            ? secondVendorPriceShipping.replaceAll('\$', '')
                            : secondVendorPriceShipping),
                vendorDiscount: secondVendorExtraDsicount,
                vendorProductUrl: secondVendorUrl),
            CompetitorTile(
                activeIndex: 2,
                vendorImage: thirdVendorName,
                vendorFinalPrice: keepSingleDollarSign(
                    '${thirdVendorFinalPrice.contains('--') ? thirdVendorFinalPrice.replaceAll('\$', '') : thirdVendorFinalPrice}\n'),
                vendorBasePrice: keepSingleDollarSign(
                    thirdVendorBasePrice.contains('--')
                        ? thirdVendorBasePrice.replaceAll('\$', '')
                        : thirdVendorBasePrice),
                vendorShipping: keepSingleDollarSign(
                                thirdVendorShipping.contains('--')
                                    ? thirdVendorShipping.replaceAll('\$', '')
                                    : thirdVendorShipping)
                            .replaceAll('\$', '') ==
                        '0.00'
                    ? 'Free Shipping'
                    : keepSingleDollarSign(thirdVendorShipping.contains('--')
                        ? thirdVendorShipping.replaceAll('\$', '')
                        : thirdVendorShipping),
                vendorDiscount: thirdVendorExtraDiscount,
                vendorProductUrl: thirdVendorUrl),
            CompetitorTile(
              activeIndex: 3,
              vendorImage: fourthVendorName,
              vendorFinalPrice: keepSingleDollarSign(
                  '${fourthVendorFinalPrice.contains('--') ? fourthVendorFinalPrice.replaceAll('\$', '') : fourthVendorFinalPrice}\n'),
              vendorBasePrice: keepSingleDollarSign(
                  fourthVendorBasePrice.contains('--')
                      ? fourthVendorBasePrice.replaceAll('\$', '')
                      : fourthVendorBasePrice),
              vendorShipping: keepSingleDollarSign(
                              fourthVendorShipping.contains('--')
                                  ? fourthVendorShipping.replaceAll('\$', '')
                                  : fourthVendorShipping)
                          .replaceAll('\$', '') ==
                      '0.00'
                  ? 'Free Shipping'
                  : keepSingleDollarSign(fourthVendorShipping.contains('--')
                      ? fourthVendorShipping.replaceAll('\$', '')
                      : fourthVendorShipping),
              vendorDiscount: fourthVendorExtraDiscount,
              vendorProductUrl: fourthVendorUrl,
            ),
            CompetitorTile(
              activeIndex: 4,
              vendorImage: fifthVendorName,
              vendorFinalPrice: keepSingleDollarSign(
                  '${fifthVendorFinalPrice.contains('--') ? fifthVendorFinalPrice.replaceAll('\$', '') : fifthVendorFinalPrice}\n'),
              vendorBasePrice: keepSingleDollarSign(
                  fifthVendorBasePrice.contains('--')
                      ? fifthVendorBasePrice.replaceAll('\$', '')
                      : fifthVendorBasePrice),
              vendorShipping: keepSingleDollarSign(
                              fifthVendorShipping.contains('--')
                                  ? fifthVendorShipping.replaceAll('\$', '')
                                  : fifthVendorShipping)
                          .replaceAll('\$', '') ==
                      '0.00'
                  ? 'Free Shipping'
                  : keepSingleDollarSign(fifthVendorShipping.contains('--')
                      ? fifthVendorShipping.replaceAll('\$', '')
                      : fifthVendorShipping),
              vendorDiscount: fifthVendorExtraDiscount,
              vendorProductUrl: fifthVendorUrl,
            ),
          ],
        ],
      ),
    );
  }
}

class CompetitorTile extends StatelessWidget {
  final int activeIndex;
  final String vendorImage,
      vendorFinalPrice,
      vendorBasePrice,
      vendorShipping,
      vendorDiscount,
      vendorProductUrl;

  const CompetitorTile({
    super.key,
    required this.activeIndex,
    required this.vendorImage,
    required this.vendorFinalPrice,
    required this.vendorBasePrice,
    required this.vendorShipping,
    required this.vendorDiscount,
    required this.vendorProductUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 28.0,
      ),
      child: SizedBox(
        height: w * .38,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Center(
              child: SizedBox(
                height: w * .33,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.zero,
                  child: Container(
                    width: w,
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey,
                        width: .3,
                      ),
                    ),
                    child: Column(
                      // textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: w,
                          height: 55,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 3),
                                  child: SizedBox(
                                    width: w * .28,
                                    child: AutoSizeText(
                                      keepSingleDollarSign(vendorFinalPrice),
                                      maxLines: 1,
                                      style: GoogleFonts.albertSans(
                                        color: Colors.black,
                                        fontSize: w * .09,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.bold,
                                        // fontFamily: 'JT Marnie Light',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 12,
                                child: Row(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl:
                                          '${AppInfo.kBaseUrl(stagingSelector: 0)}vendor-logo/$vendorImage.jpg',
                                      width: w * .25,
                                      fit: BoxFit.fill,
                                      errorWidget: (_, c, e) => Container(
                                        width: w * .2,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: AutoSizeText(
                                            vendorImage == '--'
                                                ? 'N/A'
                                                : vendorImage,
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.albertSans(
                                              color: Colors.black,
                                              fontSize: w * .035,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    horizontalSpace(horizontalSpace: 10),
                                    CircleAvatar(
                                      radius: 21,
                                      backgroundColor:
                                          Colors.black.withOpacity(.6),
                                      child: const CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.white,
                                        child: Center(
                                          child: Icon(
                                            Icons.keyboard_arrow_down,
                                          ),
                                        ),
                                      ),
                                    ),
                                    horizontalSpace(horizontalSpace: 10),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        verticalSpace(verticalSpace: 5),
                        SizedBox(
                          width: w,
                          height: 50,
                          child: Stack(
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Positioned(
                                left: 14,
                                child: SizedBox(
                                  height: 48,
                                  width: w * .4,
                                  child: (vendorShipping.contains('--') ||
                                              vendorShipping == '\$0.00' ||
                                              vendorShipping.replaceAll(
                                                      '\$', '') ==
                                                  'Free Shipping') &&
                                          (vendorDiscount.contains('0.00') ||
                                              vendorDiscount.contains('--'))
                                      ? Row(
                                          children: [
                                            const Icon(
                                              Icons.local_shipping_outlined,
                                              color: Colors.green,
                                            ),
                                            horizontalSpace(horizontalSpace: 6),
                                            AutoSizeText(
                                              (vendorShipping.contains('--') ||
                                                      vendorShipping.replaceAll(
                                                              '\$', '') ==
                                                          '+ 0.00'
                                                  ? 'Free Shipping'
                                                  : vendorShipping),
                                              style: GoogleFonts.aBeeZee(
                                                color: Colors.green,
                                                fontSize: w * .04,
                                                letterSpacing: 0,
                                                fontWeight: FontWeight.normal,
                                                // fontFamily: 'JT Marnie Light',
                                              ),
                                            ),
                                          ],
                                        )
                                      : Align(
                                          alignment: Alignment.centerLeft,
                                          child: RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                              text: vendorBasePrice,
                                              style: GoogleFonts.albertSans(
                                                color: Colors.black,
                                                fontSize: w * .04,
                                                letterSpacing: 0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              children: [
                                                const TextSpan(text: ' + 🚚 '),
                                                TextSpan(
                                                  text:
                                                      vendorShipping.replaceAll(
                                                          'Free Shipping',
                                                          '\$0.00'),
                                                  style: GoogleFonts.albertSans(
                                                    color: Colors.grey,
                                                    fontSize: w * .04,
                                                    letterSpacing: 0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                returnDiscountTextSpan(
                                                  basePrice: vendorBasePrice,
                                                  discountPercent:
                                                      vendorDiscount,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                right: 16,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: InkWell(
                                    splashColor: Colors.blue,
                                    onTap: () async {
                                      await MyInAppBrowser().openUrlRequest(
                                        urlRequest: URLRequest(
                                          url: WebUri(
                                            vendorProductUrl +
                                                '?utm_source=minsellprice.com&utm_medium=mobile-app',
                                          ),
                                        ),
                                        options: InAppBrowserClassOptions(
                                          crossPlatform: InAppBrowserOptions(
                                            toolbarTopBackgroundColor:
                                                Colors.blue,
                                          ),
                                        ),
                                      );
                                      log('Opening Pansgear URL: ${vendorProductUrl}?utm_source=shoppingmegamart.com&utm_medium=mobile-app');
                                    },
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          side: const BorderSide(
                                              width: 1, color: Colors.grey)),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0,
                                            vertical: 8.0,
                                          ),
                                          child: Row(
                                            children: [
                                              AutoSizeText(
                                                'Visit',
                                                style: GoogleFonts.aBeeZee(
                                                  color: Colors.black,
                                                  fontSize: w * .04,
                                                  letterSpacing: 0,
                                                  fontWeight: FontWeight.normal,
                                                  // fontFamily: 'JT Marnie Light',
                                                ),
                                              ),
                                              horizontalSpace(
                                                  horizontalSpace: 10),
                                              Transform.rotate(
                                                angle: 24,
                                                child: const Icon(
                                                  Icons.arrow_forward,
                                                  color: Colors.blue,
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
                            ],
                          ),
                        ),
                        verticalSpace(verticalSpace: 5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            activeIndex == 0
                ? Positioned(
                    top: 0,
                    child: Container(
                      width: w * .32,
                      decoration: BoxDecoration(
                        color: '#ff6501'.toColor(),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2.0, horizontal: 2.0),
                        child: Center(
                          child: AutoSizeText(
                            'Lowest total price',
                            maxLines: 1,
                            style: GoogleFonts.aBeeZee(
                                color: Colors.white,
                                fontSize: w * .018,
                                fontWeight: FontWeight.w200),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  TextSpan returnDiscountTextSpan(
      {required String basePrice, required String discountPercent}) {
    try {
      final basePriceValue = double.parse(basePrice.replaceAll('\$', ''));
      final discountValueValue = double.parse(discountPercent);

      return discountValueValue != 0.00
          ? TextSpan(
              text:
                  '\n-$discountPercent% (\$${returnDiscountPrice(mainPrice: basePrice, discountPercentage: discountPercent)})',
              style: GoogleFonts.albertSans(
                color: Colors.orange,
                fontSize: w * .04,
                letterSpacing: 0,
                fontWeight: FontWeight.normal,
              ),
            )
          : const TextSpan();
    } catch (e) {
      return const TextSpan();
    }
  }
}
