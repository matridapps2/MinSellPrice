import 'dart:convert';

BrandProductDetailResponse brandProductDetailResponseFromJson(String str) {
  return BrandProductDetailResponse.fromJson(json.decode(str));
}

String brandProductDetailResponseToJson(BrandProductDetailResponse data) {
  return json.encode(data.toJson());
}

class BrandProductDetailResponse {
  final String brandName;
  final String brandKey;
  final int brandId;
  final ProductDetail productDetail;
  final List<VendorProductDetail> vendorProducts;

  BrandProductDetailResponse({
    required this.brandName,
    required this.brandKey,
    required this.brandId,
    required this.productDetail,
    required this.vendorProducts,
  });

  factory BrandProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return BrandProductDetailResponse(
      brandName: json['brandName'] ?? '',
      brandKey: json['brand_key'] ?? '',
      brandId: json['brand_id'] ?? 0,
      productDetail: ProductDetail.fromJson(json['product_detail'] ?? {}),
      vendorProducts: List<VendorProductDetail>.from(
        (json['vendor_products'] ?? [])
            .map((x) => VendorProductDetail.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'brandName': brandName,
        'brand_key': brandKey,
        'brand_id': brandId,
        'product_detail': productDetail.toJson(),
        'vendor_products': vendorProducts.map((x) => x.toJson()).toList(),
      };
}

class ProductDetail {
  final int productId;
  final String productName;
  final String productMpn;
  final String productImage;
  final String msrp;
  final String brandName;
  final String brandKey;

  ProductDetail({
    required this.productId,
    required this.productName,
    required this.productMpn,
    required this.productImage,
    required this.msrp,
    required this.brandName,
    required this.brandKey,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      productMpn: json['product_mpn'] ?? '',
      productImage: json['product_image'] ?? '',
      msrp: json['msrp'] ?? '',
      brandName: json['brand_name'] ?? '',
      brandKey: json['brand_key'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'product_name': productName,
        'product_mpn': productMpn,
        'product_image': productImage,
        'msrp': msrp,
        'brand_name': brandName,
        'brand_key': brandKey,
      };
}

class VendorProductDetail {
  final int vendorProductId;
  final String vendorName;
  final String vendorUrl;
  final String vendorpricePrice;
  final String vendorpriceDate;
  final String vendorpriceShipping;
  final String vendorpriceExtraDiscount;
  final String vendorSku;
  final String deliveryText;
  final String vendorpriceStockText;
  final int vendorpriceStock;
  final bool vendorpriceIsbackorder;
  final String vendorpriceOffers;
  final String vendorpriceDeliveryDate;
  final bool isSuspicious;
  final int vendorPricingId;

  VendorProductDetail({
    required this.vendorProductId,
    required this.vendorName,
    required this.vendorUrl,
    required this.vendorpricePrice,
    required this.vendorpriceDate,
    required this.vendorpriceShipping,
    required this.vendorpriceExtraDiscount,
    required this.vendorSku,
    required this.deliveryText,
    required this.vendorpriceStockText,
    required this.vendorpriceStock,
    required this.vendorpriceIsbackorder,
    required this.vendorpriceOffers,
    required this.vendorpriceDeliveryDate,
    required this.isSuspicious,
    required this.vendorPricingId,
  });

  factory VendorProductDetail.fromJson(Map<String, dynamic> json) {
    return VendorProductDetail(
      vendorProductId: json['vendor_product_id'] ?? 0,
      vendorName: json['vendor_name'] ?? '',
      vendorUrl: json['vendor_url'] ?? '',
      vendorpricePrice: json['vendorprice_price'] ?? '',
      vendorpriceDate: json['vendorprice_date'] ?? '',
      vendorpriceShipping: json['vendorprice_shipping'] ?? '',
      vendorpriceExtraDiscount: json['vendorprice_extra_discount'] ?? '',
      vendorSku: json['vendor_sku'] ?? '',
      deliveryText: json['delivery_text'] ?? '',
      vendorpriceStockText: json['vendorprice_stock_text'] ?? '',
      vendorpriceStock: json['vendorprice_stock'] ?? 0,
      vendorpriceIsbackorder: json['vendorprice_isbackorder'] ?? false,
      vendorpriceOffers: json['vendorprice_offers'] ?? '',
      vendorpriceDeliveryDate: json['vendorprice_delivery_date'] ?? '',
      isSuspicious: json['is_suspicious'] ?? false,
      vendorPricingId: json['vendor_pricing_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'vendor_product_id': vendorProductId,
        'vendor_name': vendorName,
        'vendor_url': vendorUrl,
        'vendorprice_price': vendorpricePrice,
        'vendorprice_date': vendorpriceDate,
        'vendorprice_shipping': vendorpriceShipping,
        'vendorprice_extra_discount': vendorpriceExtraDiscount,
        'vendor_sku': vendorSku,
        'delivery_text': deliveryText,
        'vendorprice_stock_text': vendorpriceStockText,
        'vendorprice_stock': vendorpriceStock,
        'vendorprice_isbackorder': vendorpriceIsbackorder,
        'vendorprice_offers': vendorpriceOffers,
        'vendorprice_delivery_date': vendorpriceDeliveryDate,
        'is_suspicious': isSuspicious,
        'vendor_pricing_id': vendorPricingId,
      };
}
