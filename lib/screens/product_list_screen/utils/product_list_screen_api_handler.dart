import 'dart:developer';

import 'package:shoppingmegamart/app.dart';
import 'package:shoppingmegamart/model/product_list_model_new.dart';
import 'package:shoppingmegamart/reposotory_services/network_reposotory.dart';

class ProductListScreenApiHandler {
  ProductListScreenApiHandler._();

  static Future<ProductListModelNew?> getProductList({
    required String productMpn,
    required String productName,
    required bool isBrands,
    required bool isCategory,
    required bool searchProduct,
    required String titleValue,
  }) async {
    ProductListModelNew? toReturn;

    if (AppInfo.kIsStaging) {
      /// TODO: ADD HANDLING FOR STAGING API
      // var response = isBrands
      //     ? await NetworkCalls().getProductListByBrandId(
      //         brandId: titleValue.toLowerCase(),
      //         vendorId: AppInfo.kVendorId.toString(),
      //         date: dateFormat
      //             .format(DateTime.now().subtract(const Duration(days: 1)))
      //             .replaceAll('/', '-'),
      //       )
      //     : isCategory
      //         ? await NetworkCalls().getProductListByCategoryId(
      //             categoryId: titleValue,
      //           )
      //         : searchProduct
      //             ? await NetworkCalls().getProductListBySearch(
      //                 afSku: '',
      //                 vendorId: AppInfo.kVendorId.toString(),
      //                 hpSku: '',
      //                 productMpn: productMpn,
      //                 productName: productName,
      //               )
      //             : await NetworkCalls().getFeaturedProduct(
      //                 vendorId: AppInfo.kVendorId.toString(),
      //               );
      //
      // toReturn = response.map((productModel) {
      //   return VendorProduct(
      //     vendorpriceDate: productModel.vendorPriceDate,
      //     rpVariationSellPrice: productModel.rpSellVariation,
      //     productId: productModel.productId,
      //     vendorProductId: productModel.vendorProductId,
      //     productMpn: productModel.productMpn,
      //     brandId: productModel.brandId,
      //     productName: productModel.productName,
      //     productImage: productModel.productImage,
      //     gcode: productModel.gcode,
      //     msrp: productModel.msrp,
      //     brandName: productModel.brandName,
      //     brandKey: productModel.brandKey,
      //     mainImage: productModel.mainImage,
      //     vendorUrl: productModel.vendorUrl,
      //     vendorSku: productModel.vendorSku,
      //     materialGroup: productModel.materialGroup,
      //     secondarySku: productModel.secondarySku,
      //     vendorName: productModel.vendorName,
      //     vendorpricePrice: productModel.vendorpricePrice,
      //     vendorPriceFinalPrice: productModel.vendorPriceFinalPrice,
      //     vendorpriceShipping: productModel.vendorpriceShipping,
      //     extraDiscount: productModel.extraDiscount,
      //     atp: productModel.atp,
      //     sales: productModel.sales,
      //     sellPrice: productModel.sellPrice,
      //     z3Price: productModel.z3Price,
      //     mapPrice: productModel.mapPrice,
      //     vk11: productModel.vk11,
      //     movingAverage: productModel.movingAverage,
      //     purchasePrice: productModel.purchasePrice,
      //     saleAtpRatio: productModel.saleAtpRatio,
      //     amountInvested: productModel.amountInvested,
      //     lastGoodReceipt: productModel.lastGoodReceipt,
      //     weight: productModel.weight,
      //     days: productModel.days,
      //     rt: productModel.rt,
      //     msp: productModel.msp,
      //     rp: productModel.rp,
      //     rpCriteria: productModel.rpCriteria,
      //     currentDiscount: productModel.currentDiscount,
      //     gpPercent: productModel.gpPercent,
      //     shipping: productModel.shipping,
      //     ruleName: productModel.ruleName,
      //     currentGp: productModel.currentGp,
      //     adjustedPrice: productModel.adjustedPrice,
      //     firstVendorPercentage: productModel.firstVendorPercentage,
      //     secondVendorPercentage: productModel.secondVendorPercentage,
      //     firstVendorPrice: productModel.firstVendorPrice,
      //     firstVendorBasePrice: productModel.firstVendorBasePrice,
      //     firstVendorPriceShipping: productModel.firstVendorPriceShipping,
      //     firstVendorExtraDiscount: productModel.firstVendorExtraDiscount,
      //     firstVendorName: productModel.firstVendorName,
      //     firstVendorUrl: productModel.firstVendorUrl,
      //     secondVendorPrice: productModel.secondVendorPrice,
      //     secondVendorBasePrice: productModel.secondVendorBasePrice,
      //     secondVendorPriceShipping: productModel.secondVendorPriceShipping,
      //     secondVendorExtraDiscount: productModel.secondVendorExtraDsicount,
      //     secondVendorName: productModel.secondVendorName,
      //     secondVendorUrl: productModel.secondVendorUrl,
      //     vendorpriceCount: productModel.vendorpriceCount,
      //     thirdVendorName: productModel.thirdVendorName,
      //     thirdVendorUrl: productModel.thirdVendorUrl,
      //     thirdVendorPrice: productModel.thirdVendorFinalPrice,
      //     thirdVendorBasePrice: productModel.thirdVendorBasePrice,
      //     thirdVendorPriceShipping: productModel.thirdVendorShipping,
      //     thirdVendorExtraDiscount: productModel.thirdVendorExtraDiscount,
      //     fourthVendorName: productModel.fourthVendorName,
      //     fourthVendorUrl: productModel.fourthVendorUrl,
      //     fourthVendorPrice: productModel.fourthVendorFinalPrice,
      //     fourthVendorBasePrice: productModel.fourthVendorBasePrice,
      //     fourthVendorPriceShipping: productModel.fourthVendorShipping,
      //     fourthVendorExtraDiscount: productModel.fourthVendorExtraDiscount,
      //     fifthVendorName: productModel.fifthVendorName,
      //     fifthVendorUrl: productModel.fifthVendorUrl,
      //     fifthVendorPrice: productModel.fifthVendorFinalPrice,
      //     fifthVendorBasePrice: productModel.fifthVendorBasePrice,
      //     fifthVendorPriceShipping: productModel.fifthVendorShipping,
      //     fifthVendorExtraDiscount: productModel.fifthVendorExtraDiscount,
      //     rpVariation: productModel.rpVariation,
      //     firstVendorProductId: productModel.firstVendorProductId,
      //     secondVendorProductId: productModel.secondVendorProductId,
      //     thirdVendorProductId: productModel.thirdVendorProductId,
      //     fourthVendorProductId: productModel.fourthVendorProductId,
      //     fifthVendorProductId: productModel.fifthVendorProductId,
      //     competitorId: productModel.competitorId,
      //     vendorBaseUrl: productModel.vendorBaseUrl,
      //     competitor: productModel.competitor,
      //     defaultcompetitor: productModel.defaultcompetitor,
      //     sisterVendorFinalPrice: productModel.sisterVendorFinalPrice,
      //     sisterVendorBasePrice: productModel.sisterVendorBasePrice,
      //     sisterExtraDiscount: productModel.sisterExtraDiscount,
      //     sisterVendorShipping: productModel.sisterVendorShipping,
      //     sisterVendorPriceDate: productModel.sisterVendorPriceDate,
      //     productImage2: '--',
      //     isSimilarProductGcode: '--',
      //     websitePrice: '--',
      //     z1Price: '--',
      //     z2Price: '--',
      //     z4Price: '--',
      //     z5Price: '--',
      //     z6Price: '--',
      //     achievedGp: '--',
      //     assumedMapPrice: '--',
      //     source: '--',
      //     vendorPricingId: 0,
      //     competitorCount: '--',
      //     rpCoupon: '--',
      //     noticeRecommendedCoupon: '--',
      //     rpCompertitorVendor: 0,
      //     firstVendorSource: '--',
      //     secondVendorSource: '--',
      //     thirdVendorSource: '--',
      //     fourthVendorSource: '--',
      //     fifthVendorSource: '--',
      //     vendorpriceIsbackorder: '--',
      //     vendorpriceDeliveryDate: '--',
      //     deliveryText: '--',
      //     firstVendorDeliveryDate: '--',
      //     firstVendorIsBackorder: '--',
      //     firstVendorDeliveryTextGmc: '--',
      //     firstVendorDeliveryTextWebsite: '--',
      //     secondVendorDeliveryDate: '--',
      //     secondVendorIsBackorder: '--',
      //     secondVendorDeliveryTextGmc: '--',
      //     secondVendorDeliveryTextWebsite: '--',
      //     thirdVendorDeliveryDate: '--',
      //     thirdVendorIsBackorder: '--',
      //     thirdVendorDeliveryTextGmc: '--',
      //     thirdVendorDeliveryTextWebsite: '--',
      //     fourthVendorDeliveryDate: '--',
      //     fourthVendorIsBackorder: '--',
      //     fourthVendorDeliveryTextGmc: '--',
      //     fourthVendorDeliveryTextWebsite: '--',
      //     fifthVendorDeliveryDate: '--',
      //     fifthVendorIsBackorder: '--',
      //     fifthVendorDeliveryTextGmc: '--',
      //     fifthVendorDeliveryTextWebsite: '--',
      //     directVendor: '--',
      //     competeByPercentage: '--',
      //     competeByValue: '--',
      //     competeByWhicheverLower: '--',
      //     competeByWhicheverHigher: '--',
      //     webSaleQty: '--',
      //     productClicks: '--',
      //     productCost: '--',
      //     screenPageViews: '--',
      //     averageEngagementTime: '--',
      //     vendorpriceStockText: '--',
      //     firstVendorStockTextWebsite: '--',
      //     firstVendorPriceDate: '--',
      //     firstVendorStock: '--',
      //     secondVendorStockTextWebsite: '--',
      //     secondVendorPriceDate: '--',
      //     secondVendorStock: '--',
      //     thirdVendorStockTextWebsite: '--',
      //     thirdVendorPriceDate: '--',
      //     thirdVendorStock: '--',
      //     fourthVendorStockTextWebsite: '--',
      //     fourthVendorPriceDate: '--',
      //     fourthVendorStock: '--',
      //     fifthVendorStockTextWebsite: '--',
      //     fifthVendorPriceDate: '--',
      //     fifthVendorStock: '--',
      //     promotionalMessage: '--',
      //     promotionalCode: '--',
      //     promotionalDiscount: '--',
      //   );
      // }).toList();
    } else {
      try {
        var response = await NetworkCalls().getProductListBySearch(
          afSku: '',
          vendorId: AppInfo.kVendorId.toString(),
          hpSku: '',
          productMpn: productMpn,
          productName: productName,
        );
        toReturn = response;
      } catch (e, s) {
       log('error in ProductListScreenApiHandler getProductList: $e');
       log('stack trace - $s');
      }
    }
    return toReturn;
  }
}
