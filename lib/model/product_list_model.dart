import 'dart:convert';

// Helper function for brand product detail API
BrandProductDetailModel brandProductDetailModelFromJson(String str) {
  return BrandProductDetailModel.fromJson(json.decode(str));
}

String brandProductDetailModelToJson(BrandProductDetailModel data) {
  return json.encode(data.toJson());
}

List<ProductListModel> productListModelFromJson(String str) {
  return List<ProductListModel>.from(json.decode(str).map((x) {
    return ProductListModel.fromJson(x);
  }));
}

String productListModelToJson(List<ProductListModel> data) {
  return json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}

//****************************************************************************//
///                  MODEL MADE USING RESPONSE OF STAGING API                ///
//****************************************************************************//

///**************************************************************************///
//         TOTAL NO. OF KEYS IN THIS MODEL CLASS OF STAGING API : 93          //
///                                                                          ///
//            ACTUAL COUNT OF KEYS IN THE STAGING API RESPONSE : 90           //
///**************************************************************************///

class ProductListModel {
  final String? vendorBaseUrl;
  final String? competitor;
  final String? defaultcompetitor;
  final String? sisterVendorFinalPrice;
  final String? sisterVendorBasePrice;
  final String? sisterExtraDiscount;
  final String? sisterVendorShipping;
  final String? sisterVendorPriceDate;
  final int productId;
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
  final String msp;
  final String rp;
  final String rpCriteria;
  final String currentDiscount;
  final String gpPercent;
  final String shipping;
  final String currentGp;
  final String ruleName;
  final String adjustedPrice;
  final String firstVendorPercentage;
  final String secondVendorPercentage;
  final String firstVendorPrice;
  final String firstVendorBasePrice;
  final String firstVendorPriceShipping;
  final String firstVendorExtraDiscount;
  final String firstVendorName;
  final String firstVendorUrl;
  final String firstVendorProductId;
  final String secondVendorPrice;
  final String secondVendorBasePrice;
  final String secondVendorPriceShipping;
  final String secondVendorExtraDsicount;
  final String secondVendorName;
  final String secondVendorUrl;
  final String secondVendorProductId;
  final String vendorpriceCount;
  final String rt;
  final String rpVariation;
  final int vendorProductId;
  final String vendorPriceDate;
  final String rpSellVariation;
  final String thirdVendorName;
  final String thirdVendorUrl;
  final String thirdVendorFinalPrice;
  final String thirdVendorBasePrice;
  final String thirdVendorShipping;
  final String thirdVendorExtraDiscount;
  final String thirdVendorProductId;
  final String fourthVendorName;
  final String fourthVendorUrl;
  final String fourthVendorFinalPrice;
  final String fourthVendorBasePrice;
  final String fourthVendorShipping;
  final String fourthVendorExtraDiscount;
  final String fourthVendorProductId;
  final String fifthVendorName;
  final String fifthVendorUrl;
  final String fifthVendorFinalPrice;
  final String fifthVendorBasePrice;
  final String fifthVendorShipping;
  final String fifthVendorExtraDiscount;
  final String fifthVendorProductId;
  final String competitorId;

  ProductListModel({
    required this.firstVendorProductId,
    required this.secondVendorProductId,
    required this.thirdVendorProductId,
    required this.fourthVendorProductId,
    required this.fifthVendorProductId,
    required this.competitorId,
    required this.sisterExtraDiscount,
    required this.sisterVendorBasePrice,
    required this.sisterVendorPriceDate,
    required this.sisterVendorFinalPrice,
    required this.sisterVendorShipping,
    required this.vendorPriceDate,
    required this.rpSellVariation,
    required this.productId,
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
    required this.vendorBaseUrl,
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
    required this.rt,
    required this.weight,
    required this.days,
    required this.msp,
    required this.rp,
    required this.rpCriteria,
    required this.competitor,
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
    required this.secondVendorExtraDsicount,
    required this.secondVendorName,
    required this.secondVendorUrl,
    required this.vendorpriceCount,
    required this.defaultcompetitor,
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
    required this.rpVariation,
    required this.vendorProductId,
  });

  factory ProductListModel.fromJson(Map<String, dynamic> json) {
    return ProductListModel(
      //**********************************************************************//
      /// 3 PARAMETERS ARE NOT AVAILABLE NOW IN BOTH LIVE AND STAGING APIS    //
      //                                                                      //
      /// CONTAINS KEY IMPLEMENTATION ADDED BY RAHUL                         ///
      //**********************************************************************//

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

      //**********************************************************************//
      /// SISTER VENDOR DATA USING CONTAINS KEY IMPLEMENTATION (5 PARAMETER) ///
      //                                                                      //
      ///                         INCLUDES NON-AVAILABLE KEYS                ///
      //**********************************************************************//

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

      //**********************************************************************//
      ///         PRESENT IN BOTH STAGING AND LIVE API RESPONSE (84 KEYS)    ///
      //**********************************************************************//

      vendorPriceDate: json['vendorprice_date'] ?? '--',
      rpSellVariation: json['rp_variation_sell_price'] ?? '--',
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
      vendorpricePrice: json["vendorprice_price"] != null
          ? '\$${json["vendorprice_price"]}'
          : '--',
      vendorPriceFinalPrice: json["vendorprice_finalprice"] != null
          ? '\$${json["vendorprice_finalprice"]}'
          : '--',
      vendorpriceShipping: json["vendorprice_shipping"] != null
          ? '\$${json["vendorprice_shipping"]}'
          : '--',
      extraDiscount: json["ExtraDiscount"] ?? '--',
      atp: json["atp"] == null ? '0' : json["atp"].toString(),
      sales: json["sales"] ?? '0',
      sellPrice: json["sell_price"] ?? '0.0',
      z3Price: json["z3_price"] ?? '0.0',
      mapPrice: json["map_price"] ?? '0.0',
      vk11: json["vk11"] ?? '--',
      movingAverage: json["moving_average"] ?? '--',
      purchasePrice: json["purchase_price"] ?? '--',
      saleAtpRatio: json["sale_atp_ratio"] ?? "--",
      amountInvested: json["amount_invested"] ?? "",
      lastGoodReceipt: json["last_good_receipt"] ?? '--',
      weight: json["weight"] ?? '--',
      days: json["days"]?.toString() ?? '--',
      rt: '\$${json["rt"] ?? '--'}',
      msp: json["msp"] ?? '0.00',
      rp: '\$${json["rp"] ?? '--'}',
      rpCriteria: json["rp_criteria"] ?? '--',
      currentDiscount: json["current_discount"] ?? '--',
      gpPercent: json["gp_percent"] ?? '--',
      shipping: json["shipping"] ?? '0.0',
      ruleName: json["rule_name"] ?? '--',
      currentGp: json["current_gp"] ?? '--',
      adjustedPrice: json["adjusted_price"] ?? '--',
      firstVendorPercentage: json["FirstVendorPercentage"] ?? '--',
      secondVendorPercentage: json["SecondVendorPercentage"] ?? '--',
      firstVendorPrice: json["FirstVendorPrice"] != null
          ? '\$${json["FirstVendorPrice"]}'
          : '--',
      firstVendorBasePrice: json["FirstVendorBasePrice"] != null
          ? '\$${json["FirstVendorBasePrice"]}'
          : '--',
      firstVendorPriceShipping: json["FirstVendorPriceShipping"] != null
          ? '\$${json["FirstVendorPriceShipping"]}'
          : '--',
      firstVendorExtraDiscount: json["FirstVendorExtraDiscount"] ?? '--',
      firstVendorName: json["FirstVendorName"] ?? '--',
      firstVendorUrl: json["FirstVendorUrl"] ?? '--',
      secondVendorPrice: json["SecondVendorPrice"] != null
          ? '\$${json["SecondVendorPrice"]}'
          : '--',
      secondVendorBasePrice: json["SecondVendorBasePrice"] != null
          ? '\$${json["SecondVendorBasePrice"]}'
          : '--',
      secondVendorPriceShipping: json["SecondVendorPriceShipping"] != null
          ? '\$${json["SecondVendorPriceShipping"]}'
          : '--',
      secondVendorExtraDsicount: json["SecondVendorExtraDiscount"] ?? '--',
      secondVendorName: json["SecondVendorName"] ?? '--',
      secondVendorUrl: json["SecondVendorUrl"] ?? '--',
      vendorpriceCount: json["vendorprice_count"] != null
          ? '\$${json["vendorprice_count"].toString()}'
          : '--',
      thirdVendorName: json['ThirdVendorName'] ?? '--',
      thirdVendorUrl: json['ThirdVendorUrl'] ?? '--',
      thirdVendorFinalPrice: json['ThirdVendorPrice'] != null
          ? '\$${json['ThirdVendorPrice']}'
          : '--',
      thirdVendorBasePrice: json['ThirdVendorBasePrice'] != null
          ? '\$${json['ThirdVendorBasePrice']}'
          : '--',
      thirdVendorShipping: json['ThirdVendorPriceShipping'] != null
          ? '\$${json['ThirdVendorPriceShipping']}'
          : '--',
      thirdVendorExtraDiscount: json['ThirdVendorExtraDiscount'] ?? '--',
      fourthVendorName: json['FourthVendorName'] ?? '--',
      fourthVendorUrl: json['FourthVendorUrl'] ?? '--',
      fourthVendorFinalPrice: json['FourthVendorPrice'] != null
          ? '\$${json['FourthVendorPrice']}'
          : '--',
      fourthVendorBasePrice: json['FourthVendorBasePrice'] != null
          ? '\$${json['FourthVendorBasePrice']}'
          : '--',
      fourthVendorShipping: json['FourthVendorPriceShipping'] != null
          ? '\$${json['FourthVendorPriceShipping']}'
          : '--',
      fourthVendorExtraDiscount: json['FourthVendorExtraDiscount'] ?? '--',
      fifthVendorName: json['FifthVendorName'] ?? '--',
      fifthVendorUrl: json['FifthVendorUrl'] ?? '--',
      fifthVendorFinalPrice: json['FifthVendorPrice'] != null
          ? '\$${json['FifthVendorPrice']}'
          : '--',
      fifthVendorBasePrice: json['FifthVendorBasePrice'] != null
          ? '\$${json['FifthVendorBasePrice']}'
          : '--',
      fifthVendorShipping: json['FifthVendorPriceShipping'] != null
          ? '\$${json['FifthVendorPriceShipping']}'
          : '--',
      fifthVendorExtraDiscount: json['FifthVendorExtraDiscount'] ?? '--',
      rpVariation: json['rp_variation'] ?? '--',
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

      //**********************************************************************//
      ///                  PRESENT ONLY IN STAGING (1 KEY)                   ///
      //**********************************************************************//

      competitorId: json["rp_competitor_vendor_product_id"] == null
          ? '--'
          : json["rp_competitor_vendor_product_id"].toString(),

      //**********************************************************************//
      /// NOT IMPLEMENTED IN THIS MODEL CLASS (5 KEYS)                       ///
      //                                                                      //
      /// 1. "achieved_gp"                                                   ///
      //  2. "competitor_count"                                               //
      /// 3. "isSimilarProductGcode"                                         ///
      //  4. "source"                                                         //
      /// 5. "vendor_pricing_id"                                             ///
      //**********************************************************************//
    );
  }

  Map<String, dynamic> toJson() {
    return {
      //**********************************************************************//
      /// ONLY 59 OUT OF TOTAL 90 KEYS OF STAGING API RESPONSE IS ADDED IN   ///
      //  'TO JSON' METHOD                                                    //
      ///********************************************************************///

      if (vendorBaseUrl != null) "VendorBaseUrl": vendorBaseUrl,
      if (competitor != null) "competitor": competitor,
      if (defaultcompetitor != null) "defaultcompetitor": defaultcompetitor,
      "product_id": productId,
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
      "SecondVendorExtraDsicount": secondVendorExtraDsicount,
      "SecondVendorName": secondVendorName,
      "SecondVendorUrl": secondVendorUrl,
      "vendorprice_count": vendorpriceCount,
    };
  }
}

//****************************************************************************//
///                  MODEL FOR BRAND PRODUCT DETAIL API                     ///
//****************************************************************************//

class BrandProductDetailModel {
  final int brandId;
  final ProductData productData;
  final List<VendorProductData> vendorProductData;

  BrandProductDetailModel({
    required this.brandId,
    required this.productData,
    required this.vendorProductData,
  });

  factory BrandProductDetailModel.fromJson(Map<String, dynamic> json) {
    return BrandProductDetailModel(
      brandId: json['brand_id'] ?? 0,
      productData: ProductData.fromJson(json['product_data'] ?? {}),
      vendorProductData: (json['vendor_product_data'] as List<dynamic>?)
              ?.map((x) => VendorProductData.fromJson(x))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_id': brandId,
      'product_data': productData.toJson(),
      'vendor_product_data': vendorProductData.map((x) => x.toJson()).toList(),
    };
  }
}

class ProductData {
  final int brandId;
  final String brandName;
  final String brandKey;
  final int productId;
  final String productMpn;
  final String productName;
  final String msrp;
  final String productImage;

  ProductData({
    required this.brandId,
    required this.brandName,
    required this.brandKey,
    required this.productId,
    required this.productMpn,
    required this.productName,
    required this.msrp,
    required this.productImage,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      brandId: json['brand_id'] ?? 0,
      brandName: json['brand_name'] ?? '',
      brandKey: json['brand_key'] ?? '',
      productId: json['product_id'] ?? 0,
      productMpn: json['product_mpn'] ?? '',
      productName: json['product_name'] ?? '',
      msrp: json['msrp'] ?? '',
      productImage: json['product_image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_id': brandId,
      'brand_name': brandName,
      'brand_key': brandKey,
      'product_id': productId,
      'product_mpn': productMpn,
      'product_name': productName,
      'msrp': msrp,
      'product_image': productImage,
    };
  }
}

class VendorProductData {
  final int brandId;
  final String brandName;
  final String brandKey;
  final int productId;
  final String productMpn;
  final String msrp;
  final String productImage;
  final int vendorProductId;
  final String? vendorSku;
  final String? vk11;
  final String source;
  final String vendorpricePrice;
  final String vendorpriceFinalprice;
  final String? vendorpriceShipping;
  final String vendorpriceExtraDiscount;
  final String isSuspicious;
  final int vendorPricingId;
  final String vendorpriceDate;
  final String? vendorpriceDeliveryDate;
  final String vendorpriceIsbackorder;
  final String? vendorpriceOffers;
  final String? deliveryText;
  final String? vendorpriceStockText;
  final String? vendorpriceStock;
  final String vendorName;
  final String vendorWebsite;
  final String vendorUrl;
  final String vendorRawUrl;

  VendorProductData({
    required this.brandId,
    required this.brandName,
    required this.brandKey,
    required this.productId,
    required this.productMpn,
    required this.msrp,
    required this.productImage,
    required this.vendorProductId,
    this.vendorSku,
    this.vk11,
    required this.source,
    required this.vendorpricePrice,
    required this.vendorpriceFinalprice,
    this.vendorpriceShipping,
    required this.vendorpriceExtraDiscount,
    required this.isSuspicious,
    required this.vendorPricingId,
    required this.vendorpriceDate,
    this.vendorpriceDeliveryDate,
    required this.vendorpriceIsbackorder,
    this.vendorpriceOffers,
    this.deliveryText,
    this.vendorpriceStockText,
    this.vendorpriceStock,
    required this.vendorName,
    required this.vendorWebsite,
    required this.vendorUrl,
    required this.vendorRawUrl,
  });

  factory VendorProductData.fromJson(Map<String, dynamic> json) {
    return VendorProductData(
      brandId: json['brand_id'] ?? 0,
      brandName: json['brand_name'] ?? '',
      brandKey: json['brand_key'] ?? '',
      productId: json['product_id'] ?? 0,
      productMpn: json['product_mpn'] ?? '',
      msrp: json['msrp'] ?? '',
      productImage: json['product_image'] ?? '',
      vendorProductId: json['vendor_product_id'] ?? 0,
      vendorSku: json['vendor_sku'],
      vk11: json['vk11'],
      source: json['source'] ?? '',
      vendorpricePrice: json['vendorprice_price'] ?? '',
      vendorpriceFinalprice: json['vendorprice_finalprice'] ?? '',
      vendorpriceShipping: json['vendorprice_shipping'],
      vendorpriceExtraDiscount: json['vendorprice_extra_discount'] ?? '',
      isSuspicious: json['is_suspicious'] ?? '',
      vendorPricingId: json['vendor_pricing_id'] ?? 0,
      vendorpriceDate: json['vendorprice_date'] ?? '',
      vendorpriceDeliveryDate: json['vendorprice_delivery_date'],
      vendorpriceIsbackorder: json['vendorprice_isbackorder'] ?? '',
      vendorpriceOffers: json['vendorprice_offers'],
      deliveryText: json['delivery_text'],
      vendorpriceStockText: json['vendorprice_stock_text'],
      vendorpriceStock: json['vendorprice_stock'],
      vendorName: json['vendor_name'] ?? '',
      vendorWebsite: json['vendor_website'] ?? '',
      vendorUrl: json['vendor_url'] ?? '',
      vendorRawUrl: json['vendor_raw_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_id': brandId,
      'brand_name': brandName,
      'brand_key': brandKey,
      'product_id': productId,
      'product_mpn': productMpn,
      'msrp': msrp,
      'product_image': productImage,
      'vendor_product_id': vendorProductId,
      'vendor_sku': vendorSku,
      'vk11': vk11,
      'source': source,
      'vendorprice_price': vendorpricePrice,
      'vendorprice_finalprice': vendorpriceFinalprice,
      'vendorprice_shipping': vendorpriceShipping,
      'vendorprice_extra_discount': vendorpriceExtraDiscount,
      'is_suspicious': isSuspicious,
      'vendor_pricing_id': vendorPricingId,
      'vendorprice_date': vendorpriceDate,
      'vendorprice_delivery_date': vendorpriceDeliveryDate,
      'vendorprice_isbackorder': vendorpriceIsbackorder,
      'vendorprice_offers': vendorpriceOffers,
      'delivery_text': deliveryText,
      'vendorprice_stock_text': vendorpriceStockText,
      'vendorprice_stock': vendorpriceStock,
      'vendor_name': vendorName,
      'vendor_website': vendorWebsite,
      'vendor_url': vendorUrl,
      'vendor_raw_url': vendorRawUrl,
    };
  }
}
