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
import 'package:minsellprice/colors.dart' show AppColors;
import 'package:minsellprice/screens/tushar_screen/dashboard_screen/dashboard_screen.dart';
import 'package:minsellprice/model/product_list_model.dart';
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/reposotory_services/database/database_constants.dart';
import 'package:minsellprice/reposotory_services/database/database_functions.dart';
import 'package:minsellprice/screens/InAppBrowser.dart';

import 'package:minsellprice/screens/widgets/animated_notification_button.dart';
import 'package:minsellprice/screens/widgets/sample_product_screen.dart';
import 'package:minsellprice/services/extra_functions.dart';
import 'package:minsellprice/size.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';
import 'package:minsellprice/reposotory_services/network_reposotory.dart';
import 'package:minsellprice/model/brand_product_detail_model.dart';
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

  /*API Methods*/
  Future<BrandProductDetailResponse?> fetchBrandProductDetail() async {
    try {
      // Example usage of the new API
      // You can replace these values with actual data from your product
      final response = await NetworkCalls().getBrandProductDetail(
        'Bull Grills', // brandName
        '44000', // brandId
        203034, // productId
      );

      if (response != null) {
        print('Brand product detail fetched successfully');
        print('Product: ${response.productDetail.productName}');
        print('Vendors: ${response.vendorProducts.length}');
        return response;
      } else {
        print('Failed to fetch brand product detail');
        return null;
      }
    } catch (e) {
      print('Error fetching brand product detail: $e');
      return null;
    }
  }

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
        productData = ProductListModel(
          productId: vendorProduct.productId,
          productName: vendorProduct.productName,
          productImage: vendorProduct.productImage ?? '',
          productMpn: vendorProduct.productMpn,
          brandName: vendorProduct.vendorName, // Using vendorName as brandName
          vendorSku: '', // Not available in new model
          weight: '', // Not available in new model
          materialGroup: '', // Not available in new model
          lastGoodReceipt: '', // Not available in new model
          ruleName: '', // Not available in new model
          firstVendorPrice: vendorProduct.vendorpricePrice,
          firstVendorBasePrice: vendorProduct.vendorpricePrice,
          firstVendorPriceShipping: '',
          firstVendorExtraDiscount: '',
          firstVendorName: vendorProduct.vendorName,
          firstVendorUrl: vendorProduct.vendorUrl,
          secondVendorPrice: '',
          secondVendorBasePrice: '',
          secondVendorPriceShipping: '',
          secondVendorExtraDsicount: '',
          secondVendorName: '',
          secondVendorUrl: '',
          thirdVendorName: '',
          thirdVendorUrl: '',
          thirdVendorFinalPrice: '',
          thirdVendorBasePrice: '',
          thirdVendorShipping: '',
          thirdVendorExtraDiscount: '',
          fourthVendorName: '',
          fourthVendorUrl: '',
          fourthVendorFinalPrice: '',
          fourthVendorBasePrice: '',
          fourthVendorShipping: '',
          fourthVendorExtraDiscount: '',
          fifthVendorName: '',
          fifthVendorUrl: '',
          fifthVendorFinalPrice: '',
          fifthVendorBasePrice: '',
          fifthVendorShipping: '',
          fifthVendorExtraDiscount: '',
          vendorProductId: 0, // Not available in new model
          firstVendorProductId: '',
          secondVendorProductId: '',
          thirdVendorProductId: '',
          fourthVendorProductId: '',
          fifthVendorProductId: '',
          competitorId: '',
          vendorPriceFinalPrice: vendorProduct.vendorpricePrice,
          sisterExtraDiscount: '',
          sisterVendorBasePrice: '',
          sisterVendorPriceDate: '',
          sisterVendorFinalPrice: '',
          sisterVendorShipping: '',
          vendorPriceDate: vendorProduct.vendorpriceDate,
          rpSellVariation: '',
          brandId: '',
          gcode: '',
          msrp: '',
          brandKey: '',
          mainImage: vendorProduct.productImage ?? '',
          secondarySku: '',
          vendorName: vendorProduct.vendorName,
          vendorpricePrice: vendorProduct.vendorpricePrice,
          vendorpriceShipping: '',
          extraDiscount: '',
          vendorBaseUrl: '',
          atp: '',
          sales: '',
          sellPrice: '',
          z3Price: '',
          mapPrice: '',
          vk11: '',
          movingAverage: '',
          purchasePrice: '',
          saleAtpRatio: '',
          amountInvested: '',
          rt: '',
          days: '',
          msp: '',
          rp: '',
          rpCriteria: '',
          competitor: '',
          currentDiscount: '',
          gpPercent: '',
          shipping: '',
          currentGp: '',
          adjustedPrice: '',
          firstVendorPercentage: '',
          secondVendorPercentage: '',
          vendorpriceCount: vendorProduct.vendorIdCount.toString(),
          defaultcompetitor: '',
          rpVariation: '',
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
            child: Image.asset(
              'assets/minsellprice_logo.png',
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
              child: Icon(
                Icons.share,
                color: AppColors.primary,
              ),
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 1),
                    Expanded(
                      child: Scrollbar(
                          thickness: 5,
                          trackVisibility: true,
                          thumbVisibility: true,
                          controller: _competitorScrollbar,
                          child: SizedBox()),
                    ),
                  ],
                ),
                //animation(lottieController: _lottieController),
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
