import 'dart:convert';

ProductListModelNew productListModelNewFromJson(String str) {
  return ProductListModelNew.fromJson(json.decode(str));
}

String productListModelNewToJson(ProductListModelNew data) {
  return json.encode(data.toJson());
}

//****************************************************************************//
///                  MODEL MADE USING RESPONSE OF LIVE API                   ///
//****************************************************************************//

class ProductListModelNew {
  List<VendorProduct> vendorProducts;
  // String getOtherSeller;

  ProductListModelNew({
    required this.vendorProducts,
    // required this.getOtherSeller,
  });

  factory ProductListModelNew.fromJson(Map<String, dynamic> json) {
    return ProductListModelNew(
      vendorProducts: List<VendorProduct>.from(json["vendor_products"].map((x) {
        return VendorProduct.fromJson(x);
      })),
      // getOtherSeller: Map.from(json["getOtherSeller"]).map((k, v) {
      //   return MapEntry<String, GetOtherSeller>(k, GetOtherSeller.fromJson(v));
      // }),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "vendor_products": List<dynamic>.from(vendorProducts.map((x) {
        return x.toJson();
      })),
      // "getOtherSeller": Map.from(getOtherSeller).map((k, v) {
      //   return MapEntry<String, dynamic>(k, v.toJson());
      // }),
    };
  }
}

class GetOtherSeller {
  int firstProductId;
  int firstVendorProductId;
  String firstVendorName;
  String firstVendorpricePrice;
  String firstVendorpriceFinalprice;
  String? firstVendorpriceShipping;
  String firstVendorpriceExtraDiscount;
  String firstVendorUrl;
  String firstSource;
  String firstVendorpriceDeliveryDate;
  String firstVendorpriceIsbackorder;
  String firstDeliveryText;
  String firstVendorpriceStockText;
  String firstVendorpriceDate;
  String firstVendorpriceStock;
  int? secondProductId;
  int? secondVendorProductId;
  String? secondVendorName;
  String? secondVendorpricePrice;
  String? secondVendorpriceFinalprice;
  String? secondVendorpriceShipping;
  String? secondVendorpriceExtraDiscount;
  String? secondVendorUrl;
  String? secondSource;
  String? secondVendorpriceDeliveryDate;
  String? secondVendorpriceIsbackorder;
  String secondDeliveryText;
  String secondVendorpriceStockText;
  String? secondVendorpriceDate;
  String secondVendorpriceStock;
  int? thirdProductId;
  int? thirdVendorProductId;
  String? thirdVendorName;
  String? thirdVendorpricePrice;
  String? thirdVendorpriceFinalprice;
  String? thirdVendorpriceShipping;
  String? thirdVendorpriceExtraDiscount;
  String? thirdVendorUrl;
  String? thirdSource;
  String? thirdVendorpriceDeliveryDate;
  String? thirdVendorpriceIsbackorder;
  String thirdDeliveryText;
  String thirdVendorpriceStockText;
  String? thirdVendorpriceDate;
  String thirdVendorpriceStock;
  int? fourthProductId;
  int? fourthVendorProductId;
  String? fourthVendorName;
  String? fourthVendorpricePrice;
  String? fourthVendorpriceFinalprice;
  String? fourthVendorpriceShipping;
  String? fourthVendorpriceExtraDiscount;
  String? fourthVendorUrl;
  String? fourthSource;
  String? fourthVendorpriceDeliveryDate;
  String? fourthVendorpriceIsbackorder;
  String fourthDeliveryText;
  String fourthVendorpriceStockText;
  String? fourthVendorpriceDate;
  String fourthVendorpriceStock;
  int? fifthProductId;
  int? fifthVendorProductId;
  String? fifthVendorName;
  String? fifthVendorpricePrice;
  String? fifthVendorpriceFinalprice;
  String? fifthVendorpriceShipping;
  String? fifthVendorpriceExtraDiscount;
  String? fifthVendorUrl;
  String? fifthSource;
  String? fifthVendorpriceDeliveryDate;
  String? fifthVendorpriceIsbackorder;
  String fifthDeliveryText;
  String fifthVendorpriceStockText;
  String? fifthVendorpriceDate;
  String fifthVendorpriceStock;

  GetOtherSeller({
    required this.firstProductId,
    required this.firstVendorProductId,
    required this.firstVendorName,
    required this.firstVendorpricePrice,
    required this.firstVendorpriceFinalprice,
    required this.firstVendorpriceShipping,
    required this.firstVendorpriceExtraDiscount,
    required this.firstVendorUrl,
    required this.firstSource,
    required this.firstVendorpriceDeliveryDate,
    required this.firstVendorpriceIsbackorder,
    required this.firstDeliveryText,
    required this.firstVendorpriceStockText,
    required this.firstVendorpriceDate,
    required this.firstVendorpriceStock,
    required this.secondProductId,
    required this.secondVendorProductId,
    required this.secondVendorName,
    required this.secondVendorpricePrice,
    required this.secondVendorpriceFinalprice,
    required this.secondVendorpriceShipping,
    required this.secondVendorpriceExtraDiscount,
    required this.secondVendorUrl,
    required this.secondSource,
    required this.secondVendorpriceDeliveryDate,
    required this.secondVendorpriceIsbackorder,
    required this.secondDeliveryText,
    required this.secondVendorpriceStockText,
    required this.secondVendorpriceDate,
    required this.secondVendorpriceStock,
    required this.thirdProductId,
    required this.thirdVendorProductId,
    required this.thirdVendorName,
    required this.thirdVendorpricePrice,
    required this.thirdVendorpriceFinalprice,
    required this.thirdVendorpriceShipping,
    required this.thirdVendorpriceExtraDiscount,
    required this.thirdVendorUrl,
    required this.thirdSource,
    required this.thirdVendorpriceDeliveryDate,
    required this.thirdVendorpriceIsbackorder,
    required this.thirdDeliveryText,
    required this.thirdVendorpriceStockText,
    required this.thirdVendorpriceDate,
    required this.thirdVendorpriceStock,
    required this.fourthProductId,
    required this.fourthVendorProductId,
    required this.fourthVendorName,
    required this.fourthVendorpricePrice,
    required this.fourthVendorpriceFinalprice,
    required this.fourthVendorpriceShipping,
    required this.fourthVendorpriceExtraDiscount,
    required this.fourthVendorUrl,
    required this.fourthSource,
    required this.fourthVendorpriceDeliveryDate,
    required this.fourthVendorpriceIsbackorder,
    required this.fourthDeliveryText,
    required this.fourthVendorpriceStockText,
    required this.fourthVendorpriceDate,
    required this.fourthVendorpriceStock,
    required this.fifthProductId,
    required this.fifthVendorProductId,
    required this.fifthVendorName,
    required this.fifthVendorpricePrice,
    required this.fifthVendorpriceFinalprice,
    required this.fifthVendorpriceShipping,
    required this.fifthVendorpriceExtraDiscount,
    required this.fifthVendorUrl,
    required this.fifthSource,
    required this.fifthVendorpriceDeliveryDate,
    required this.fifthVendorpriceIsbackorder,
    required this.fifthDeliveryText,
    required this.fifthVendorpriceStockText,
    required this.fifthVendorpriceDate,
    required this.fifthVendorpriceStock,
  });

  factory GetOtherSeller.fromJson(Map<String, dynamic> json) => GetOtherSeller(
        firstProductId: json["first_product_id"] ?? 0,
        firstVendorProductId: json["first_vendor_product_id"] ?? 0,
        firstVendorName: json["first_vendor_name"] ?? '--',
        firstVendorpricePrice: json["first_vendorprice_price"] ?? '0.0',
        firstVendorpriceFinalprice:
            json["first_vendorprice_finalprice"] ?? '--',
        firstVendorpriceShipping: json["first_vendorprice_shipping"] ?? '--',
        firstVendorpriceExtraDiscount:
            json["first_vendorprice_extra_discount"] ?? '--',
        firstVendorUrl: json["first_vendor_url"] ?? '--',
        firstSource: json["first_source"] ?? '--',
        firstVendorpriceDeliveryDate:
            json["first_vendorprice_delivery_date"] ?? '--',
        firstVendorpriceIsbackorder:
            json["first_vendorprice_isbackorder"] ?? '--',
        firstDeliveryText: json["first_delivery_text"] == null
            ? '--'
            : json["first_delivery_text"].toString(),
        firstVendorpriceStockText: json["first_vendorprice_stock_text"] == null
            ? '--'
            : json["first_vendorprice_stock_text"].toString(),
        firstVendorpriceDate: json["first_vendorprice_date"] ?? '--',
        firstVendorpriceStock: json["first_vendorprice_stock"] == null
            ? '--'
            : json["first_vendorprice_stock"].toString(),
        secondProductId: json["second_product_id"] ?? 0,
        secondVendorProductId: json["second_vendor_product_id"] ?? 0,
        secondVendorName: json["second_vendor_name"] ?? '--',
        secondVendorpricePrice: json["second_vendorprice_price"] ?? '--',
        secondVendorpriceFinalprice:
            json["second_vendorprice_finalprice"] ?? '--',
        secondVendorpriceShipping: json["second_vendorprice_shipping"] ?? '--',
        secondVendorpriceExtraDiscount:
            json["second_vendorprice_extra_discount"] ?? '--',
        secondVendorUrl: json["second_vendor_url"] ?? '--',
        secondSource: json["second_source"] ?? '--',
        secondVendorpriceDeliveryDate:
            json["second_vendorprice_delivery_date"] ?? '--',
        secondVendorpriceIsbackorder:
            json["second_vendorprice_isbackorder"] ?? '--',
        secondDeliveryText: json["second_delivery_text"] == null
            ? '--'
            : json["second_delivery_text"].toString(),
        secondVendorpriceStockText:
            json["second_vendorprice_stock_text"] == null
                ? '--'
                : json["second_vendorprice_stock_text"].toString(),
        secondVendorpriceDate: json["second_vendorprice_date"] ?? '--',
        secondVendorpriceStock: json["second_vendorprice_stock"] == null
            ? '--'
            : json["second_vendorprice_stock"].toString(),
        thirdProductId: json["third_product_id"] ?? 0,
        thirdVendorProductId: json["third_vendor_product_id"] ?? 0,
        thirdVendorName: json["third_vendor_name"] ?? '--',
        thirdVendorpricePrice: json["third_vendorprice_price"] ?? '--',
        thirdVendorpriceFinalprice:
            json["third_vendorprice_finalprice"] ?? '--',
        thirdVendorpriceShipping: json["third_vendorprice_shipping"] ?? '--',
        thirdVendorpriceExtraDiscount:
            json["third_vendorprice_extra_discount"] ?? '--',
        thirdVendorUrl: json["third_vendor_url"] ?? '--',
        thirdSource: json["third_source"] ?? '--',
        thirdVendorpriceDeliveryDate:
            json["third_vendorprice_delivery_date"] ?? '--',
        thirdVendorpriceIsbackorder:
            json["third_vendorprice_isbackorder"] ?? '--',
        thirdDeliveryText: json["third_delivery_text"] == null
            ? '--'
            : json["third_delivery_text"].toString(),
        thirdVendorpriceStockText: json["third_vendorprice_stock_text"] == null
            ? '--'
            : json["third_vendorprice_stock_text"].toString(),
        thirdVendorpriceDate: json["third_vendorprice_date"] ?? '--',
        thirdVendorpriceStock: json["third_vendorprice_stock"] == null
            ? '--'
            : json["third_vendorprice_stock"].toString(),
        fourthProductId: json["fourth_product_id"] ?? 0,
        fourthVendorProductId: json["fourth_vendor_product_id"] ?? 0,
        fourthVendorName: json["fourth_vendor_name"] ?? '--',
        fourthVendorpricePrice: json["fourth_vendorprice_price"] ?? '--',
        fourthVendorpriceFinalprice:
            json["fourth_vendorprice_finalprice"] ?? '--',
        fourthVendorpriceShipping: json["fourth_vendorprice_shipping"] ?? '--',
        fourthVendorpriceExtraDiscount:
            json["fourth_vendorprice_extra_discount"] ?? '--',
        fourthVendorUrl: json["fourth_vendor_url"] ?? '--',
        fourthSource: json["fourth_source"] ?? '--',
        fourthVendorpriceDeliveryDate:
            json["fourth_vendorprice_delivery_date"] ?? '--',
        fourthVendorpriceIsbackorder:
            json["fourth_vendorprice_isbackorder"] ?? '--',
        fourthDeliveryText: json["fourth_delivery_text"] == null
            ? '--'
            : json["fourth_delivery_text"].toString(),
        fourthVendorpriceStockText:
            json["fourth_vendorprice_stock_text"] == null
                ? '--'
                : json["fourth_vendorprice_stock_text"].toString(),
        fourthVendorpriceDate: json["fourth_vendorprice_date"] ?? '--',
        fourthVendorpriceStock: json["fourth_vendorprice_stock"] == null
            ? '--'
            : json["fourth_vendorprice_stock"].toString(),
        fifthProductId: json["fifth_product_id"] ?? 0,
        fifthVendorProductId: json["fifth_vendor_product_id"] ?? 0,
        fifthVendorName: json["fifth_vendor_name"] ?? '--',
        fifthVendorpricePrice: json["fifth_vendorprice_price"] ?? '--',
        fifthVendorpriceFinalprice:
            json["fifth_vendorprice_finalprice"] ?? '--',
        fifthVendorpriceShipping: json["fifth_vendorprice_shipping"] ?? '--',
        fifthVendorpriceExtraDiscount:
            json["fifth_vendorprice_extra_discount"] ?? '--',
        fifthVendorUrl: json["fifth_vendor_url"] ?? '--',
        fifthSource: json["fifth_source"] ?? '--',
        fifthVendorpriceDeliveryDate:
            json["fifth_vendorprice_delivery_date"] ?? '--',
        fifthVendorpriceIsbackorder:
            json["fifth_vendorprice_isbackorder"] ?? '--',
        fifthDeliveryText: json["fifth_delivery_text"] == null
            ? '--'
            : json["fifth_delivery_text"].toString(),
        fifthVendorpriceStockText: json["fifth_vendorprice_stock_text"] == null
            ? '--'
            : json["fifth_vendorprice_stock_text"].toString(),
        fifthVendorpriceDate: json["fifth_vendorprice_date"] ?? '--',
        fifthVendorpriceStock: json["fifth_vendorprice_stock"] == null
            ? '--'
            : json["fifth_vendorprice_stock"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "first_product_id": firstProductId,
        "first_vendor_product_id": firstVendorProductId,
        "first_vendor_name": firstVendorName,
        "first_vendorprice_price": firstVendorpricePrice,
        "first_vendorprice_finalprice": firstVendorpriceFinalprice,
        "first_vendorprice_shipping": firstVendorpriceShipping,
        "first_vendorprice_extra_discount": firstVendorpriceExtraDiscount,
        "first_vendor_url": firstVendorUrl,
        "first_source": firstSource,
        "first_vendorprice_delivery_date": firstVendorpriceDeliveryDate,
        "first_vendorprice_isbackorder": firstVendorpriceIsbackorder,
        "first_delivery_text": firstDeliveryText,
        "first_vendorprice_stock_text": firstVendorpriceStockText,
        "first_vendorprice_date": firstVendorpriceDate,
        "first_vendorprice_stock": firstVendorpriceStock,
        "second_product_id": secondProductId,
        "second_vendor_product_id": secondVendorProductId,
        "second_vendor_name": secondVendorName,
        "second_vendorprice_price": secondVendorpricePrice,
        "second_vendorprice_finalprice": secondVendorpriceFinalprice,
        "second_vendorprice_shipping": secondVendorpriceShipping,
        "second_vendorprice_extra_discount": secondVendorpriceExtraDiscount,
        "second_vendor_url": secondVendorUrl,
        "second_source": secondSource,
        "second_vendorprice_delivery_date": secondVendorpriceDeliveryDate,
        "second_vendorprice_isbackorder": secondVendorpriceIsbackorder,
        "second_delivery_text": secondDeliveryText,
        "second_vendorprice_stock_text": secondVendorpriceStockText,
        "second_vendorprice_date": secondVendorpriceDate,
        "second_vendorprice_stock": secondVendorpriceStock,
        "third_product_id": thirdProductId,
        "third_vendor_product_id": thirdVendorProductId,
        "third_vendor_name": thirdVendorName,
        "third_vendorprice_price": thirdVendorpricePrice,
        "third_vendorprice_finalprice": thirdVendorpriceFinalprice,
        "third_vendorprice_shipping": thirdVendorpriceShipping,
        "third_vendorprice_extra_discount": thirdVendorpriceExtraDiscount,
        "third_vendor_url": thirdVendorUrl,
        "third_source": thirdSource,
        "third_vendorprice_delivery_date": thirdVendorpriceDeliveryDate,
        "third_vendorprice_isbackorder": thirdVendorpriceIsbackorder,
        "third_delivery_text": thirdDeliveryText,
        "third_vendorprice_stock_text": thirdVendorpriceStockText,
        "third_vendorprice_date": thirdVendorpriceDate,
        "third_vendorprice_stock": thirdVendorpriceStock,
        "fourth_product_id": fourthProductId,
        "fourth_vendor_product_id": fourthVendorProductId,
        "fourth_vendor_name": fourthVendorName,
        "fourth_vendorprice_price": fourthVendorpricePrice,
        "fourth_vendorprice_finalprice": fourthVendorpriceFinalprice,
        "fourth_vendorprice_shipping": fourthVendorpriceShipping,
        "fourth_vendorprice_extra_discount": fourthVendorpriceExtraDiscount,
        "fourth_vendor_url": fourthVendorUrl,
        "fourth_source": fourthSource,
        "fourth_vendorprice_delivery_date": fourthVendorpriceDeliveryDate,
        "fourth_vendorprice_isbackorder": fourthVendorpriceIsbackorder,
        "fourth_delivery_text": fourthDeliveryText,
        "fourth_vendorprice_stock_text": fourthVendorpriceStockText,
        "fourth_vendorprice_date": fourthVendorpriceDate,
        "fourth_vendorprice_stock": fourthVendorpriceStock,
        "fifth_product_id": fifthProductId,
        "fifth_vendor_product_id": fifthVendorProductId,
        "fifth_vendor_name": fifthVendorName,
        "fifth_vendorprice_price": fifthVendorpricePrice,
        "fifth_vendorprice_finalprice": fifthVendorpriceFinalprice,
        "fifth_vendorprice_shipping": fifthVendorpriceShipping,
        "fifth_vendorprice_extra_discount": fifthVendorpriceExtraDiscount,
        "fifth_vendor_url": fifthVendorUrl,
        "fifth_source": fifthSource,
        "fifth_vendorprice_delivery_date": fifthVendorpriceDeliveryDate,
        "fifth_vendorprice_isbackorder": fifthVendorpriceIsbackorder,
        "fifth_delivery_text": fifthDeliveryText,
        "fifth_vendorprice_stock_text": fifthVendorpriceStockText,
        "fifth_vendorprice_date": fifthVendorpriceDate,
        "fifth_vendorprice_stock": fifthVendorpriceStock,
      };
}

class VendorProduct {
  //**************************************************************************//
  ///         PRESENT IN BOTH STAGING AND LIVE API RESPONSE (84 KEYS)        ///
  //**************************************************************************//
  final String vendorpriceDate;
  final String rpVariationSellPrice;
  final int productId;
  final int vendorProductId;
  final String productMpn;
  final String brandId;
  final String productName;
  final String productImage;
  final String gcode;
  final String msrp;
  final String brandName;
  final String brandKey;
  final dynamic mainImage;
  final String vendorUrl;
  final String vendorSku;
  final String materialGroup;
  final String secondarySku;
  final String vendorName;
  final String vendorpricePrice;
  final String vendorPriceFinalPrice;
  final String vendorpriceShipping;
  final String extraDiscount;
  final String atp;
  final String sales;
  final String sellPrice;
  final String z3Price;
  final String mapPrice;
  final String vk11;
  final String movingAverage;
  final String purchasePrice;
  final String saleAtpRatio;
  final String amountInvested;
  final String lastGoodReceipt;
  final String weight;
  final String days;
  final String rt;
  final String msp;
  final String rp;
  final String rpCriteria;
  final String currentDiscount;
  final String gpPercent;
  final String shipping;
  final String ruleName;
  final String currentGp;
  final String adjustedPrice;
  final String firstVendorPercentage;
  final String secondVendorPercentage;
  final String firstVendorPrice;
  final String firstVendorBasePrice;
  final String firstVendorPriceShipping;
  final String firstVendorExtraDiscount;
  final String firstVendorName;
  final String firstVendorUrl;
  final String secondVendorPrice;
  final String secondVendorBasePrice;
  final String secondVendorPriceShipping;
  final String secondVendorExtraDiscount;
  final String secondVendorName;
  final String secondVendorUrl;
  final String vendorpriceCount;
  final String thirdVendorName;
  final String thirdVendorUrl;
  final String thirdVendorPrice;
  final String thirdVendorBasePrice;
  final String thirdVendorPriceShipping;
  final String thirdVendorExtraDiscount;
  final String fourthVendorName;
  final String fourthVendorUrl;
  final String fourthVendorPrice;
  final String fourthVendorBasePrice;
  final String fourthVendorPriceShipping;
  final String fourthVendorExtraDiscount;
  final String fifthVendorName;
  final String fifthVendorUrl;
  final String fifthVendorPrice;
  final String fifthVendorBasePrice;
  final String fifthVendorPriceShipping;
  final String fifthVendorExtraDiscount;
  final String rpVariation;
  final String firstVendorProductId;
  final String secondVendorProductId;
  final String thirdVendorProductId;
  final String fourthVendorProductId;
  final String fifthVendorProductId;

  //**************************************************************************//
  ///   1 KEY PRESENT ONLY IN STAGING, ADDED CONTAINS KEY IMPLEMENTATION     ///
  //**************************************************************************//

  final String? competitorId;

  //**************************************************************************//
  /// 3 PARAMETERS ARE NOT AVAILABLE NOW IN BOTH LIVE AND STAGING APIS       ///
  //                                                                          //
  /// CONTAINS KEY IMPLEMENTATION ADDED BY RAHUL                             ///
  //**************************************************************************//

  final String? vendorBaseUrl;
  final String? competitor;
  final String? defaultcompetitor;

  //**************************************************************************//
  /// SISTER VENDOR DATA USING CONTAINS KEY IMPLEMENTATION (5 PARAMETER)     ///
  //                                                                          //
  ///                         INCLUDES NON-AVAILABLE KEYS                    ///
  //**************************************************************************//

  final String? sisterVendorFinalPrice;
  final String? sisterVendorBasePrice;
  final String? sisterExtraDiscount;
  final String? sisterVendorShipping;
  final String? sisterVendorPriceDate;

  //**************************************************************************//
  ///        PARAMETERS ONLY AVAILABLE IN LIVE API RESPONSE : 73             ///
  //**************************************************************************//

  final String productImage2;
  final String isSimilarProductGcode;
  final String websitePrice;
  final String z1Price;
  final String z2Price;
  final String z4Price;
  final String z5Price;
  final String z6Price;
  final String achievedGp;
  final String assumedMapPrice;
  final String source;
  final int vendorPricingId;
  final int competitorCount;
  final String rpCoupon;
  final String noticeRecommendedCoupon;
  final int rpCompertitorVendor;
  final String firstVendorSource;
  final String secondVendorSource;
  final String thirdVendorSource;
  final String fourthVendorSource;
  final String fifthVendorSource;
  final String vendorpriceIsbackorder;
  final String vendorpriceDeliveryDate;
  final String deliveryText;
  final String firstVendorDeliveryDate;
  final String firstVendorIsBackorder;
  final String firstVendorDeliveryTextGmc;
  final String firstVendorDeliveryTextWebsite;
  final String secondVendorDeliveryDate;
  final String secondVendorIsBackorder;
  final String secondVendorDeliveryTextGmc;
  final String secondVendorDeliveryTextWebsite;
  final String thirdVendorDeliveryDate;
  final String thirdVendorIsBackorder;
  final String thirdVendorDeliveryTextGmc;
  final String thirdVendorDeliveryTextWebsite;
  final String fourthVendorDeliveryDate;
  final String fourthVendorIsBackorder;
  final String fourthVendorDeliveryTextGmc;
  final String fourthVendorDeliveryTextWebsite;
  final String fifthVendorDeliveryDate;
  final String fifthVendorIsBackorder;
  final String fifthVendorDeliveryTextGmc;
  final String fifthVendorDeliveryTextWebsite;
  final String directVendor;
  final String competeByPercentage;
  final String competeByValue;
  final String competeByWhicheverLower;
  final String competeByWhicheverHigher;
  final String webSaleQty;
  final String productClicks;
  final String productCost;
  final String screenPageViews;
  final String averageEngagementTime;
  final String vendorpriceStockText;
  final String firstVendorStockTextWebsite;
  final String firstVendorPriceDate;
  final String firstVendorStock;
  final String secondVendorStockTextWebsite;
  final String secondVendorPriceDate;
  final String secondVendorStock;
  final String thirdVendorStockTextWebsite;
  final String thirdVendorPriceDate;
  final String thirdVendorStock;
  final String fourthVendorStockTextWebsite;
  final String fourthVendorPriceDate;
  final String fourthVendorStock;
  final String fifthVendorStockTextWebsite;
  final String fifthVendorPriceDate;
  final String fifthVendorStock;
  final String promotionalMessage;
  final String promotionalCode;
  final String promotionalDiscount;

  VendorProduct({
    //************************************************************************//
    ///         PRESENT IN BOTH STAGING AND LIVE API RESPONSE (84 KEYS)      ///
    //************************************************************************//
    required this.vendorpriceDate,
    required this.rpVariationSellPrice,
    required this.productId,
    required this.vendorProductId,
    required this.productMpn,
    required this.brandId,
    required this.productName,
    required this.productImage,
    required this.gcode,
    required this.msrp,
    required this.brandName,
    required this.brandKey,
    required this.mainImage,
    required this.vendorUrl,
    required this.vendorSku,
    required this.materialGroup,
    required this.secondarySku,
    required this.vendorName,
    required this.vendorpricePrice,
    required this.vendorPriceFinalPrice,
    required this.vendorpriceShipping,
    required this.extraDiscount,
    required this.atp,
    required this.sales,
    required this.sellPrice,
    required this.z3Price,
    required this.mapPrice,
    required this.vk11,
    required this.movingAverage,
    required this.purchasePrice,
    required this.saleAtpRatio,
    required this.amountInvested,
    required this.lastGoodReceipt,
    required this.weight,
    required this.days,
    required this.rt,
    required this.msp,
    required this.rp,
    required this.rpCriteria,
    required this.currentDiscount,
    required this.gpPercent,
    required this.shipping,
    required this.ruleName,
    required this.currentGp,
    required this.adjustedPrice,
    required this.firstVendorPercentage,
    required this.secondVendorPercentage,
    required this.firstVendorPrice,
    required this.firstVendorBasePrice,
    required this.firstVendorPriceShipping,
    required this.firstVendorExtraDiscount,
    required this.firstVendorName,
    required this.firstVendorUrl,
    required this.secondVendorPrice,
    required this.secondVendorBasePrice,
    required this.secondVendorPriceShipping,
    required this.secondVendorExtraDiscount,
    required this.secondVendorName,
    required this.secondVendorUrl,
    required this.vendorpriceCount,
    required this.thirdVendorName,
    required this.thirdVendorUrl,
    required this.thirdVendorPrice,
    required this.thirdVendorBasePrice,
    required this.thirdVendorPriceShipping,
    required this.thirdVendorExtraDiscount,
    required this.fourthVendorName,
    required this.fourthVendorUrl,
    required this.fourthVendorPrice,
    required this.fourthVendorBasePrice,
    required this.fourthVendorPriceShipping,
    required this.fourthVendorExtraDiscount,
    required this.fifthVendorName,
    required this.fifthVendorUrl,
    required this.fifthVendorPrice,
    required this.fifthVendorBasePrice,
    required this.fifthVendorPriceShipping,
    required this.fifthVendorExtraDiscount,
    required this.rpVariation,
    required this.firstVendorProductId,
    required this.secondVendorProductId,
    required this.thirdVendorProductId,
    required this.fourthVendorProductId,
    required this.fifthVendorProductId,

    //************************************************************************//
    ///   1 KEY PRESENT ONLY IN STAGING, ADDED CONTAINS KEY IMPLEMENTATION   ///
    //************************************************************************//

    required this.competitorId,

    //************************************************************************//
    /// 3 PARAMETERS ARE NOT AVAILABLE NOW IN BOTH LIVE AND STAGING APIS      //
    //                                                                        //
    /// CONTAINS KEY IMPLEMENTATION ADDED BY RAHUL                           ///
    //************************************************************************//

    required this.vendorBaseUrl,
    required this.competitor,
    required this.defaultcompetitor,

    //************************************************************************//
    /// SISTER VENDOR DATA USING CONTAINS KEY IMPLEMENTATION (5 PARAMETER)   ///
    //                                                                        //
    ///                         INCLUDES NON-AVAILABLE KEYS                  ///
    //************************************************************************//

    required this.sisterVendorFinalPrice,
    required this.sisterVendorBasePrice,
    required this.sisterExtraDiscount,
    required this.sisterVendorShipping,
    required this.sisterVendorPriceDate,

    //************************************************************************//
    ///        PARAMETERS ONLY AVAILABLE IN LIVE API RESPONSE : 73           ///
    //************************************************************************//

    required this.productImage2,
    required this.isSimilarProductGcode,
    required this.websitePrice,
    required this.z1Price,
    required this.z2Price,
    required this.z4Price,
    required this.z5Price,
    required this.z6Price,
    required this.achievedGp,
    required this.assumedMapPrice,
    required this.source,
    required this.vendorPricingId,
    required this.competitorCount,
    required this.rpCoupon,
    required this.noticeRecommendedCoupon,
    required this.rpCompertitorVendor,
    required this.firstVendorSource,
    required this.secondVendorSource,
    required this.thirdVendorSource,
    required this.fourthVendorSource,
    required this.fifthVendorSource,
    required this.vendorpriceIsbackorder,
    required this.vendorpriceDeliveryDate,
    required this.deliveryText,
    required this.firstVendorDeliveryDate,
    required this.firstVendorIsBackorder,
    required this.firstVendorDeliveryTextGmc,
    required this.firstVendorDeliveryTextWebsite,
    required this.secondVendorDeliveryDate,
    required this.secondVendorIsBackorder,
    required this.secondVendorDeliveryTextGmc,
    required this.secondVendorDeliveryTextWebsite,
    required this.thirdVendorDeliveryDate,
    required this.thirdVendorIsBackorder,
    required this.thirdVendorDeliveryTextGmc,
    required this.thirdVendorDeliveryTextWebsite,
    required this.fourthVendorDeliveryDate,
    required this.fourthVendorIsBackorder,
    required this.fourthVendorDeliveryTextGmc,
    required this.fourthVendorDeliveryTextWebsite,
    required this.fifthVendorDeliveryDate,
    required this.fifthVendorIsBackorder,
    required this.fifthVendorDeliveryTextGmc,
    required this.fifthVendorDeliveryTextWebsite,
    required this.directVendor,
    required this.competeByPercentage,
    required this.competeByValue,
    required this.competeByWhicheverLower,
    required this.competeByWhicheverHigher,
    required this.webSaleQty,
    required this.productClicks,
    required this.productCost,
    required this.screenPageViews,
    required this.averageEngagementTime,
    required this.vendorpriceStockText,
    required this.firstVendorStockTextWebsite,
    required this.firstVendorPriceDate,
    required this.firstVendorStock,
    required this.secondVendorStockTextWebsite,
    required this.secondVendorPriceDate,
    required this.secondVendorStock,
    required this.thirdVendorStockTextWebsite,
    required this.thirdVendorPriceDate,
    required this.thirdVendorStock,
    required this.fourthVendorStockTextWebsite,
    required this.fourthVendorPriceDate,
    required this.fourthVendorStock,
    required this.fifthVendorStockTextWebsite,
    required this.fifthVendorPriceDate,
    required this.fifthVendorStock,
    required this.promotionalMessage,
    required this.promotionalCode,
    required this.promotionalDiscount,
  });

  factory VendorProduct.fromJson(Map<String, dynamic> json) => VendorProduct(
        //************************************************************************//
        ///         PRESENT IN BOTH STAGING AND LIVE API RESPONSE (84 KEYS)      ///
        //************************************************************************//

        vendorpriceDate: json["vendorprice_date"] ?? '--',
        rpVariationSellPrice: json["rp_variation_sell_price"] ?? '--',
        productId: json["product_id"] ?? 0,
        vendorProductId: json["vendor_product_id"] ?? 0,
        productMpn: json["product_mpn"] ?? '--',
        brandId: json["brand_id"] == null ? '--' : json["brand_id"].toString(),
        productName: json["product_name"] ?? '--',
        productImage: json["product_image"] ?? '--',
        gcode: json["gcode"] ?? '--',
        msrp: json["msrp"] ?? '--',
        brandName: json["brand_name"] ?? '--',
        brandKey: json["brand_key"] ?? '--',
        mainImage: json["main_image"] ?? '--',
        vendorUrl: json["vendor_url"] ?? '--',
        vendorSku: json["vendor_sku"] ?? '--',
        materialGroup: json["material_group"] ?? '--',
        secondarySku: json["secondary_sku"] ?? '--',
        vendorName: json["vendor_name"] ?? '--',
        vendorpricePrice: json["vendorprice_price"] == null
            ? '--'
            : '\$${json["vendorprice_price"]}',
        vendorPriceFinalPrice: json["vendorprice_finalprice"] == null
            ? '--'
            : '\$${json["vendorprice_finalprice"]}',
        vendorpriceShipping: json["vendorprice_shipping"] == null
            ? '--'
            : '\$${json["vendorprice_shipping"]}',
        extraDiscount: json["ExtraDiscount"] ?? '--',
        atp: json["atp"] == null ? '0' : json["atp"].toString(),
        sales: json["sales"] == null ? '0' : json["sales"].toString(),
        sellPrice:
            json["sell_price"] == null ? '0.0' : json["sell_price"].toString(),
        z3Price: json["z3_price"] == null ? '0.0' : json["z3_price"].toString(),
        mapPrice:
            json["map_price"] == null ? '0.0' : json["map_price"].toString(),
        vk11: json["vk11"] ?? '--',
        movingAverage: json["moving_average"] ?? '--',
        purchasePrice: json["purchase_price"] ?? '--',
        saleAtpRatio: json["sale_atp_ratio"] ?? '--',
        amountInvested: json["amount_invested"] ?? '--',
        lastGoodReceipt: json["last_good_receipt"] ?? '--',
        weight: json["weight"] ?? '--',
        days: json["days"] == null ? '--' : json["days"].toString(),
        rt: json["rt"] == null ? '--' : '\$${json["rt"]}',
        msp: json["msp"] == null ? '0.00' : json["msp"].toString(),
        rp: json["rp"] == null ? '--' : '\$${json["rp"]}',
        rpCriteria: json["rp_criteria"] ?? '--',
        currentDiscount: json["current_discount"] ?? '--',
        gpPercent: json["gp_percent"] ?? '--',
        shipping:
            json["shipping"] == null ? '0.0' : json["shipping"].toString(),
        ruleName: json["rule_name"] ?? '--',
        currentGp: json["current_gp"] ?? '--',
        adjustedPrice: json["adjusted_price"] ?? '--',
        firstVendorPercentage: json["FirstVendorPercentage"] ?? '--',
        secondVendorPercentage: json["SecondVendorPercentage"] ?? '--',
        firstVendorPrice: json["FirstVendorPrice"] == null
            ? '--'
            : '\$${json["FirstVendorPrice"]}',
        firstVendorBasePrice: json["FirstVendorBasePrice"] == null
            ? '--'
            : '\$${json["FirstVendorBasePrice"]}',
        firstVendorPriceShipping: json["FirstVendorPriceShipping"] == null
            ? '--'
            : '\$${json["FirstVendorPriceShipping"]}',
        firstVendorExtraDiscount: json["FirstVendorExtraDiscount"] ?? '--',
        firstVendorName: json["FirstVendorName"] ?? '--',
        firstVendorUrl: json["FirstVendorUrl"] ?? '--',
        secondVendorPrice: json["SecondVendorPrice"] == null
            ? '--'
            : '\$${json["SecondVendorPrice"]}',
        secondVendorBasePrice: json["SecondVendorBasePrice"] == null
            ? '--'
            : '\$${json["SecondVendorBasePrice"]}',
        secondVendorPriceShipping: json["SecondVendorPriceShipping"] == null
            ? '--'
            : '\$${json["SecondVendorPriceShipping"]}',
        secondVendorExtraDiscount: json["SecondVendorExtraDiscount"] ?? '--',
        secondVendorName: json["SecondVendorName"] ?? '--',
        secondVendorUrl: json["SecondVendorUrl"] ?? '--',
        vendorpriceCount: json["vendorprice_count"] == null
            ? '--'
            : '\$${json["vendorprice_count"]}',
        thirdVendorName: json["ThirdVendorName"] ?? '--',
        thirdVendorUrl: json["ThirdVendorUrl"] ?? '--',
        thirdVendorPrice: json["ThirdVendorPrice"] == null
            ? '--'
            : '\$${json["ThirdVendorPrice"]}',
        thirdVendorBasePrice: json["ThirdVendorBasePrice"] == null
            ? '--'
            : '\$${json["ThirdVendorBasePrice"]}',
        thirdVendorPriceShipping: json["ThirdVendorPriceShipping"] == null
            ? '--'
            : '\$${json["ThirdVendorPriceShipping"]}',
        thirdVendorExtraDiscount: json["ThirdVendorExtraDiscount"] ?? '--',
        fourthVendorName: json["FourthVendorName"] ?? '--',
        fourthVendorUrl: json["FourthVendorUrl"] ?? '--',
        fourthVendorPrice: json["FourthVendorPrice"] == null
            ? '--'
            : '\$${json["FourthVendorPrice"]}',
        fourthVendorBasePrice: json["FourthVendorBasePrice"] == null
            ? '--'
            : '\$${json["FourthVendorBasePrice"]}',
        fourthVendorPriceShipping: json["FourthVendorPriceShipping"] == null
            ? '--'
            : '\$${json["FourthVendorPriceShipping"]}',
        fourthVendorExtraDiscount: json["FourthVendorExtraDiscount"] ?? '--',
        fifthVendorName: json["FifthVendorName"] ?? '--',
        fifthVendorUrl: json["FifthVendorUrl"] ?? '--',
        fifthVendorPrice: json["FifthVendorPrice"] == null
            ? '--'
            : '\$${json["FifthVendorPrice"]}',
        fifthVendorBasePrice: json["FifthVendorBasePrice"] == null
            ? '--'
            : '\$${json["FifthVendorBasePrice"]}',
        fifthVendorPriceShipping: json["FifthVendorPriceShipping"] == null
            ? '--'
            : '\$${json["FifthVendorPriceShipping"]}',
        fifthVendorExtraDiscount: json["FifthVendorExtraDiscount"] ?? '--',
        rpVariation: json["rp_variation"] ?? '--',
        firstVendorProductId: json["first_vendor_product_id"] == null
            ? '--'
            : json["first_vendor_product_id"].toString(),
        secondVendorProductId: json["second_vendor_product_id"] == null
            ? '--'
            : json["second_vendor_product_id"].toString(),
        thirdVendorProductId: json["third_vendor_product_id"] == null
            ? '--'
            : json["third_vendor_product_id"].toString(),
        fourthVendorProductId: json["fourth_vendor_product_id"] == null
            ? '--'
            : json["fourth_vendor_product_id"].toString(),
        fifthVendorProductId: json["fifth_vendor_product_id"] == null
            ? '--'
            : json["fifth_vendor_product_id"].toString(),

        //************************************************************************//
        ///   1 KEY PRESENT ONLY IN STAGING, ADDED CONTAINS KEY IMPLEMENTATION   ///
        //************************************************************************//

        competitorId: json.containsKey('rp_competitor_vendor_product_id')
            ? json["rp_competitor_vendor_product_id"] == null
                ? '--'
                : json["rp_competitor_vendor_product_id"].toString()
            : '--',

        //************************************************************************//
        /// 3 PARAMETERS ARE NOT AVAILABLE NOW IN BOTH LIVE AND STAGING APIS      //
        //                                                                        //
        /// CONTAINS KEY IMPLEMENTATION ADDED BY RAHUL                           ///
        //************************************************************************//

        vendorBaseUrl: json.containsKey('VendorBaseUrl')
            ? json["VendorBaseUrl"] ?? '--'
            : '--',
        competitor: json.containsKey('competitor')
            ? json["competitor"] == null
                ? '--'
                : json["competitor"].toString()
            : '--',
        defaultcompetitor: json.containsKey('defaultcompetitor')
            ? json["defaultcompetitor"] ?? '--'
            : '--',

        //************************************************************************//
        /// SISTER VENDOR DATA USING CONTAINS KEY IMPLEMENTATION (5 PARAMETER)   ///
        //                                                                        //
        ///                         INCLUDES NON-AVAILABLE KEYS                  ///
        //************************************************************************//

        sisterExtraDiscount: json.containsKey('VendorExtraDiscount')
            ? json['VendorExtraDiscount'] != null
                ? '${json['VendorExtraDiscount']}'
                : '--'
            : '--',
        sisterVendorBasePrice: json.containsKey('VendorBasePrice')
            ? json['VendorBasePrice'] != null
                ? '\$${json['VendorBasePrice']}'
                : '--'
            : '--',
        sisterVendorFinalPrice: json.containsKey('VendorPrice')
            ? json['VendorPrice'] != null
                ? '\$${json['VendorPrice']}'
                : '--'
            : '--',
        sisterVendorShipping: json.containsKey('VendorPriceShipping')
            ? json['VendorPriceShipping'] != null
                ? '\$${json['VendorPriceShipping']}'
                : '--'
            : '--',
        sisterVendorPriceDate: json.containsKey('VendorPriceDate')
            ? json['VendorPriceDate'].toString()
            : '--',

        //************************************************************************//
        ///        PARAMETERS ONLY AVAILABLE IN LIVE API RESPONSE : 73           ///
        //************************************************************************//

        productImage2: json["product_image2"] ?? '--',
        isSimilarProductGcode: json["isSimilarProductGcode"] ?? '--',
        websitePrice: json["website_price"] ?? '--',
        z1Price: json["z1_price"] ?? '--',
        z2Price: json["z2_price"] ?? '--',
        z4Price: json["z4_price"] ?? '--',
        z5Price: json["z5_price"] ?? '--',
        z6Price: json["z6_price"] ?? '--',
        achievedGp: json["achieved_gp"] ?? '--',
        assumedMapPrice: json["assumed_map_price"] ?? '0',
        source: json["source"] ?? '--',
        vendorPricingId: json["vendor_pricing_id"] ?? '--',
        competitorCount: json["competitor_count"] ?? 0,
        rpCoupon: json["rp_coupon"] ?? '--',
        noticeRecommendedCoupon: json["notice_recommended_coupon"] ?? '--',
        rpCompertitorVendor: json["rp_compertitor_vendor"] ?? 0,
        firstVendorSource: json["FirstVendorSource"] ?? '--',
        secondVendorSource: json["SecondVendorSource"] ?? '--',
        thirdVendorSource: json["ThirdVendorSource"] ?? '--',
        fourthVendorSource: json["FourthVendorSource"] ?? '--',
        fifthVendorSource: json["FifthVendorSource"] ?? '--',
        vendorpriceIsbackorder: json["vendorprice_isbackorder"]! ?? '--',
        vendorpriceDeliveryDate: json["vendorprice_delivery_date"] ?? '--',
        deliveryText: json["delivery_text"] ?? '--',
        firstVendorDeliveryDate: json["first_vendor_delivery_date"] ?? '--',
        firstVendorIsBackorder: json["first_vendor_is_backorder"] ?? '--',
        firstVendorDeliveryTextGmc:
            json["first_vendor_delivery_text_gmc"] ?? '--',
        firstVendorDeliveryTextWebsite:
            json["first_vendor_delivery_text_website"] ?? '--',
        secondVendorDeliveryDate: json["second_vendor_delivery_date"] ?? '--',
        secondVendorIsBackorder: json["second_vendor_is_backorder"] ?? '--',
        secondVendorDeliveryTextGmc:
            json["second_vendor_delivery_text_gmc"] ?? '--',
        secondVendorDeliveryTextWebsite:
            json["second_vendor_delivery_text_website"] ?? '--',
        thirdVendorDeliveryDate: json["third_vendor_delivery_date"] ?? '--',
        thirdVendorIsBackorder: json["third_vendor_is_backorder"] ?? '--',
        thirdVendorDeliveryTextGmc:
            json["third_vendor_delivery_text_gmc"] ?? '--',
        thirdVendorDeliveryTextWebsite:
            json["third_vendor_delivery_text_website"] ?? '--',
        fourthVendorDeliveryDate: json["fourth_vendor_delivery_date"] ?? '--',
        fourthVendorIsBackorder: json["fourth_vendor_is_backorder"] ?? '--',
        fourthVendorDeliveryTextGmc:
            json["fourth_vendor_delivery_text_gmc"] ?? '--',
        fourthVendorDeliveryTextWebsite:
            json["fourth_vendor_delivery_text_website"] ?? '--',
        fifthVendorDeliveryDate: json["fifth_vendor_delivery_date"] ?? '--',
        fifthVendorIsBackorder: json["fifth_vendor_is_backorder"] ?? '--',
        fifthVendorDeliveryTextGmc:
            json["fifth_vendor_delivery_text_gmc"] ?? '--',
        fifthVendorDeliveryTextWebsite:
            json["fifth_vendor_delivery_text_website"] ?? '--',
        directVendor: json["direct_vendor"] ?? '--',
        competeByPercentage: json["compete_by_percentage"] ?? '--',
        competeByValue: json["compete_by_value"] ?? '--',
        competeByWhicheverLower: json["compete_by_whichever_lower"] ?? '--',
        competeByWhicheverHigher: json["compete_by_whichever_higher"] ?? '--',
        webSaleQty: json["web_sale_qty"] ?? '--',
        productClicks: json["product_clicks"] ?? '--',
        productCost: json["product_cost"] ?? '--',
        screenPageViews: json["screenPageViews"] ?? '--',
        averageEngagementTime: json["averageEngagementTime"] ?? '--',
        vendorpriceStockText: json["vendorprice_stock_text"] ?? '--',
        firstVendorStockTextWebsite:
            json["first_vendor_stock_text_website"] ?? '--',
        firstVendorPriceDate: json["first_vendor_price_date"] ?? '--',
        firstVendorStock: json["first_vendor_stock"] ?? '--',
        secondVendorStockTextWebsite:
            json["second_vendor_stock_text_website"] ?? '--',
        secondVendorPriceDate: json["second_vendor_price_date"] ?? '--',
        secondVendorStock: json["second_vendor_stock"] ?? '--',
        thirdVendorStockTextWebsite:
            json["third_vendor_stock_text_website"] ?? '--',
        thirdVendorPriceDate: json["third_vendor_price_date"] ?? '--',
        thirdVendorStock: json["third_vendor_stock"] ?? '--',
        fourthVendorStockTextWebsite:
            json["fourth_vendor_stock_text_website"] ?? '--',
        fourthVendorPriceDate: json["fourth_vendor_price_date"] ?? '--',
        fourthVendorStock: json["fourth_vendor_stock"] ?? '--',
        fifthVendorStockTextWebsite:
            json["fifth_vendor_stock_text_website"] ?? '--',
        fifthVendorPriceDate: json["fifth_vendor_price_date"] ?? '--',
        fifthVendorStock: json["fifth_vendor_stock"] ?? '--',
        promotionalMessage: json["promotional_message"] ?? '--',
        promotionalCode: json["promotional_code"] ?? '--',
        promotionalDiscount: json["promotional_discount"] ?? '--',
      );

  Map<String, dynamic> toJson() {
    return {
      //**********************************************************************//
      ///         PRESENT IN BOTH STAGING AND LIVE API RESPONSE (84 KEYS)    ///
      //**********************************************************************//

      "vendorprice_date": vendorpriceDate,
      "rp_variation_sell_price": rpVariationSellPrice,
      "product_id": productId,
      "vendor_product_id": vendorProductId,
      "product_mpn": productMpn,
      "brand_id": brandId,
      "product_name": productName,
      "product_image": productImage,
      "gcode": gcode,
      "msrp": msrp,
      "brand_name": brandName,
      "brand_key": brandKey,
      "main_image": mainImage,
      "vendor_url": vendorUrl,
      "vendor_sku": vendorSku,
      "material_group": materialGroup,
      "secondary_sku": secondarySku,
      "vendor_name": vendorName,
      "vendorprice_price": vendorpricePrice,
      "vendorprice_finalprice": vendorPriceFinalPrice,
      "vendorprice_shipping": vendorpriceShipping,
      "ExtraDiscount": extraDiscount,
      "atp": atp,
      "sales": sales,
      "sell_price": sellPrice,
      "z3_price": z3Price,
      "map_price": mapPrice,
      "vk11": vk11,
      "moving_average": movingAverage,
      "purchase_price": purchasePrice,
      "sale_atp_ratio": saleAtpRatio,
      "amount_invested": amountInvested,
      "last_good_receipt": lastGoodReceipt,
      "weight": weight,
      "days": days,
      "rt": rt,
      "msp": msp,
      "rp": rp,
      "rp_criteria": rpCriteria,
      "current_discount": currentDiscount,
      "gp_percent": gpPercent,
      "shipping": shipping,
      "rule_name": ruleName,
      "current_gp": currentGp,
      "adjusted_price": adjustedPrice,
      "FirstVendorPercentage": firstVendorPercentage,
      "SecondVendorPercentage": secondVendorPercentage,
      "FirstVendorPrice": firstVendorPrice,
      "FirstVendorBasePrice": firstVendorBasePrice,
      "FirstVendorPriceShipping": firstVendorPriceShipping,
      "FirstVendorExtraDiscount": firstVendorExtraDiscount,
      "FirstVendorName": firstVendorName,
      "FirstVendorUrl": firstVendorUrl,
      "SecondVendorPrice": secondVendorPrice,
      "SecondVendorBasePrice": secondVendorBasePrice,
      "SecondVendorPriceShipping": secondVendorPriceShipping,
      "SecondVendorExtraDiscount": secondVendorExtraDiscount,
      "SecondVendorName": secondVendorName,
      "SecondVendorUrl": secondVendorUrl,
      "vendorprice_count": vendorpriceCount,
      "ThirdVendorName": thirdVendorName,
      "ThirdVendorUrl": thirdVendorUrl,
      "ThirdVendorPrice": thirdVendorPrice,
      "ThirdVendorBasePrice": thirdVendorBasePrice,
      "ThirdVendorPriceShipping": thirdVendorPriceShipping,
      "ThirdVendorExtraDiscount": thirdVendorExtraDiscount,
      "FourthVendorName": fourthVendorName,
      "FourthVendorUrl": fourthVendorUrl,
      "FourthVendorPrice": fourthVendorPrice,
      "FourthVendorBasePrice": fourthVendorBasePrice,
      "FourthVendorPriceShipping": fourthVendorPriceShipping,
      "FourthVendorExtraDiscount": fourthVendorExtraDiscount,
      "FifthVendorName": fifthVendorName,
      "FifthVendorUrl": fifthVendorUrl,
      "FifthVendorPrice": fifthVendorPrice,
      "FifthVendorBasePrice": fifthVendorBasePrice,
      "FifthVendorPriceShipping": fifthVendorPriceShipping,
      "FifthVendorExtraDiscount": fifthVendorExtraDiscount,
      "rp_variation": rpVariation,
      "first_vendor_product_id": firstVendorProductId,
      "second_vendor_product_id": secondVendorProductId,
      "third_vendor_product_id": thirdVendorProductId,
      "fourth_vendor_product_id": fourthVendorProductId,
      "fifth_vendor_product_id": fifthVendorProductId,

      //**********************************************************************//
      ///   1 KEY PRESENT ONLY IN STAGING, ADDED CONTAINS KEY IMPLEMENTATION ///
      //**********************************************************************//

      if (competitorId != null) "rp_competitor_vendor_product_id": competitorId,

      //**********************************************************************//
      /// 3 PARAMETERS ARE NOT AVAILABLE NOW IN BOTH LIVE AND STAGING APIS    //
      //                                                                      //
      /// CONTAINS KEY IMPLEMENTATION ADDED BY RAHUL                         ///
      //**********************************************************************//

      if (vendorBaseUrl != null) "VendorBaseUrl": vendorBaseUrl,
      if (competitor != null) "competitor": competitor,
      if (defaultcompetitor != null) "defaultcompetitor": defaultcompetitor,

      //**********************************************************************//
      /// SISTER VENDOR DATA USING CONTAINS KEY IMPLEMENTATION (5 PARAMETER) ///
      //                                                                      //
      ///                         INCLUDES NON-AVAILABLE KEYS                ///
      //**********************************************************************//

      if (sisterExtraDiscount != null)
        "VendorExtraDiscount": sisterExtraDiscount,
      if (sisterVendorBasePrice != null)
        "VendorBasePrice": sisterVendorBasePrice,
      if (sisterVendorFinalPrice != null) "VendorPrice": sisterVendorFinalPrice,
      if (sisterVendorShipping != null)
        "VendorPriceShipping": sisterVendorShipping,
      if (sisterVendorPriceDate != null)
        "VendorPriceDate": sisterVendorPriceDate,

      //**********************************************************************//
      ///        PARAMETERS ONLY AVAILABLE IN LIVE API RESPONSE : 73         ///
      //**********************************************************************//

      "product_image2": productImage2,
      "isSimilarProductGcode": isSimilarProductGcode,
      "website_price": websitePrice,
      "z1_price": z1Price,
      "z2_price": z2Price,
      "z4_price": z4Price,
      "z5_price": z5Price,
      "z6_price": z6Price,
      "achieved_gp": achievedGp,
      "assumed_map_price": assumedMapPrice,
      "source": source,
      "vendor_pricing_id": vendorPricingId,
      "competitor_count": competitorCount,
      "rp_coupon": rpCoupon,
      "notice_recommended_coupon": noticeRecommendedCoupon,
      "rp_compertitor_vendor": rpCompertitorVendor,
      "FirstVendorSource": firstVendorSource,
      "SecondVendorSource": secondVendorSource,
      "ThirdVendorSource": thirdVendorSource,
      "FourthVendorSource": fourthVendorSource,
      "FifthVendorSource": fifthVendorSource,
      "vendorprice_isbackorder": vendorpriceIsbackorder,
      "vendorprice_delivery_date": vendorpriceDeliveryDate,
      "delivery_text": deliveryText,
      "first_vendor_delivery_date": firstVendorDeliveryDate,
      "first_vendor_is_backorder": firstVendorIsBackorder,
      "first_vendor_delivery_text_gmc": firstVendorDeliveryTextGmc,
      "first_vendor_delivery_text_website": firstVendorDeliveryTextWebsite,
      "second_vendor_delivery_date": secondVendorDeliveryDate,
      "second_vendor_is_backorder": secondVendorIsBackorder,
      "second_vendor_delivery_text_gmc": secondVendorDeliveryTextGmc,
      "second_vendor_delivery_text_website": secondVendorDeliveryTextWebsite,
      "third_vendor_delivery_date": thirdVendorDeliveryDate,
      "third_vendor_is_backorder": thirdVendorIsBackorder,
      "third_vendor_delivery_text_gmc": thirdVendorDeliveryTextGmc,
      "third_vendor_delivery_text_website": thirdVendorDeliveryTextWebsite,
      "fourth_vendor_delivery_date": fourthVendorDeliveryDate,
      "fourth_vendor_is_backorder": fourthVendorIsBackorder,
      "fourth_vendor_delivery_text_gmc": fourthVendorDeliveryTextGmc,
      "fourth_vendor_delivery_text_website": fourthVendorDeliveryTextWebsite,
      "fifth_vendor_delivery_date": fifthVendorDeliveryDate,
      "fifth_vendor_is_backorder": fifthVendorIsBackorder,
      "fifth_vendor_delivery_text_gmc": fifthVendorDeliveryTextGmc,
      "fifth_vendor_delivery_text_website": fifthVendorDeliveryTextWebsite,
      "direct_vendor": directVendor,
      "compete_by_percentage": competeByPercentage,
      "compete_by_value": competeByValue,
      "compete_by_whichever_lower": competeByWhicheverLower,
      "compete_by_whichever_higher": competeByWhicheverHigher,
      "web_sale_qty": webSaleQty,
      "product_clicks": productClicks,
      "product_cost": productCost,
      "screenPageViews": screenPageViews,
      "averageEngagementTime": averageEngagementTime,
      "vendorprice_stock_text": vendorpriceStockText,
      "first_vendor_stock_text_website": firstVendorStockTextWebsite,
      "first_vendor_price_date": firstVendorPriceDate,
      "first_vendor_stock": firstVendorStock,
      "second_vendor_stock_text_website": secondVendorStockTextWebsite,
      "second_vendor_price_date": secondVendorPriceDate,
      "second_vendor_stock": secondVendorStock,
      "third_vendor_stock_text_website": thirdVendorStockTextWebsite,
      "third_vendor_price_date": thirdVendorPriceDate,
      "third_vendor_stock": thirdVendorStock,
      "fourth_vendor_stock_text_website": fourthVendorStockTextWebsite,
      "fourth_vendor_price_date": fourthVendorPriceDate,
      "fourth_vendor_stock": fourthVendorStock,
      "fifth_vendor_stock_text_website": fifthVendorStockTextWebsite,
      "fifth_vendor_price_date": fifthVendorPriceDate,
      "fifth_vendor_stock": fifthVendorStock,
      "promotional_message": promotionalMessage,
      "promotional_code": promotionalCode,
      "promotional_discount": promotionalDiscount,
    };
  }
}
