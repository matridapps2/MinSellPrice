class BrandProductApiResponse {
  final int? brandId;
  final ProductData? productData;
  final List<VendorProductData>? vendorProductData;

  BrandProductApiResponse({
    this.brandId,
    this.productData,
    this.vendorProductData,
  });

  factory BrandProductApiResponse.fromJson(Map<String, dynamic> json) {
    return BrandProductApiResponse(
      brandId: json['brand_id'] as int?,
      productData: json['product_data'] != null
          ? ProductData.fromJson(json['product_data'] as Map<String, dynamic>)
          : null,
      vendorProductData: json['vendor_product_data'] != null
          ? (json['vendor_product_data'] as List)
              .map((item) =>
                  VendorProductData.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_id': brandId,
      'product_data': productData?.toJson(),
      'vendor_product_data':
          vendorProductData?.map((item) => item.toJson()).toList(),
    };
  }
}

class ProductData {
  final int? brandId;
  final String? brandName;
  final String? brandKey;
  final int? productId;
  final String? productMpn;
  final String? productName;
  final String? msrp;
  final String? productImage;

  ProductData({
    this.brandId,
    this.brandName,
    this.brandKey,
    this.productId,
    this.productMpn,
    this.productName,
    this.msrp,
    this.productImage,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      brandId: json['brand_id'] as int?,
      brandName: json['brand_name'] as String?,
      brandKey: json['brand_key'] as String?,
      productId: json['product_id'] as int?,
      productMpn: json['product_mpn'] as String?,
      productName: json['product_name'] as String?,
      msrp: json['msrp'] as String?,
      productImage: json['product_image'] as String?,
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
  final int? brandId;
  final String? brandName;
  final String? brandKey;
  final int? productId;
  final String? productMpn;
  final String? msrp;
  final String? productImage;
  final int? vendorProductId;
  final String? vendorSku;
  final String? vk11;
  final String? source;
  final String? vendorpricePrice;
  final String? vendorpriceFinalPrice;
  final String? vendorpriceShipping;
  final String? vendorpriceExtraDiscount;
  final String? isSuspicious;
  final int? vendorPricingId;
  final String? vendorpriceDate;
  final String? vendorpriceDeliveryDate;
  final String? vendorpriceIsBackorder;
  final String? vendorpriceOffers;
  final String? deliveryText;
  final String? vendorpriceStockText;
  final String? vendorpriceStock;
  final String? vendorName;
  final String? vendorWebsite;
  final String? vendorUrl;
  final String? vendorRawUrl;

  VendorProductData({
    this.brandId,
    this.brandName,
    this.brandKey,
    this.productId,
    this.productMpn,
    this.msrp,
    this.productImage,
    this.vendorProductId,
    this.vendorSku,
    this.vk11,
    this.source,
    this.vendorpricePrice,
    this.vendorpriceFinalPrice,
    this.vendorpriceShipping,
    this.vendorpriceExtraDiscount,
    this.isSuspicious,
    this.vendorPricingId,
    this.vendorpriceDate,
    this.vendorpriceDeliveryDate,
    this.vendorpriceIsBackorder,
    this.vendorpriceOffers,
    this.deliveryText,
    this.vendorpriceStockText,
    this.vendorpriceStock,
    this.vendorName,
    this.vendorWebsite,
    this.vendorUrl,
    this.vendorRawUrl,
  });

  factory VendorProductData.fromJson(Map<String, dynamic> json) {
    return VendorProductData(
      brandId: json['brand_id'] as int?,
      brandName: json['brand_name'] as String?,
      brandKey: json['brand_key'] as String?,
      productId: json['product_id'] as int?,
      productMpn: json['product_mpn'] as String?,
      msrp: json['msrp']?.toString(),
      productImage: json['product_image'] as String?,
      vendorProductId: json['vendor_product_id'] as int?,
      vendorSku: json['vendor_sku']?.toString(),
      vk11: json['vk11']?.toString(),
      source: json['source'] as String?,
      vendorpricePrice: json['vendorprice_price']?.toString(),
      vendorpriceFinalPrice: json['vendorprice_finalprice']?.toString(),
      vendorpriceShipping: json['vendorprice_shipping']?.toString(),
      vendorpriceExtraDiscount: json['vendorprice_extra_discount']?.toString(),
      isSuspicious: json['is_suspicious']?.toString(),
      vendorPricingId: json['vendor_pricing_id'] as int?,
      vendorpriceDate: json['vendorprice_date'] as String?,
      vendorpriceDeliveryDate: json['vendorprice_delivery_date'] as String?,
      vendorpriceIsBackorder: json['vendorprice_isbackorder'] as String?,
      vendorpriceOffers: json['vendorprice_offers'] as String?,
      deliveryText: json['delivery_text'] as String?,
      vendorpriceStockText: json['vendorprice_stock_text'] as String?,
      vendorpriceStock: json['vendorprice_stock']?.toString(),
      vendorName: json['vendor_name'] as String?,
      vendorWebsite: json['vendor_website'] as String?,
      vendorUrl: json['vendor_url'] as String?,
      vendorRawUrl: json['vendor_raw_url'] as String?,
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
      'vendorprice_finalprice': vendorpriceFinalPrice,
      'vendorprice_shipping': vendorpriceShipping,
      'vendorprice_extra_discount': vendorpriceExtraDiscount,
      'is_suspicious': isSuspicious,
      'vendor_pricing_id': vendorPricingId,
      'vendorprice_date': vendorpriceDate,
      'vendorprice_delivery_date': vendorpriceDeliveryDate,
      'vendorprice_isbackorder': vendorpriceIsBackorder,
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

  // Helper method to get final price as double
  double get finalPriceAsDouble {
    if (vendorpriceFinalPrice == null) return 0.0;
    return double.tryParse(vendorpriceFinalPrice!) ?? 0.0;
  }

  // Helper method to get base price as double
  double get basePriceAsDouble {
    if (vendorpricePrice == null) return 0.0;
    return double.tryParse(vendorpricePrice!) ?? 0.0;
  }

  // Helper method to get shipping as double
  double get shippingAsDouble {
    if (vendorpriceShipping == null) return 0.0;
    return double.tryParse(vendorpriceShipping!) ?? 0.0;
  }

  // Helper method to check if vendor is suspicious
  bool get isSuspiciousVendor {
    return isSuspicious == "1";
  }

  // Helper method to get MSRP as double
  double get msrpAsDouble {
    if (msrp == null) return 0.0;
    return double.tryParse(msrp!) ?? 0.0;
  }
}
