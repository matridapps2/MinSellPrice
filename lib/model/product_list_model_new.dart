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
  final String brandName;
  final String brandKey;
  final int productCount;
  final int pageNo;
  final int previousPage;
  final int totalNoOfPages;
  final List<VendorProduct> brandProduct;

  ProductListModelNew({
    required this.brandName,
    required this.brandKey,
    required this.productCount,
    required this.pageNo,
    required this.previousPage,
    required this.totalNoOfPages,
    required this.brandProduct,
  });

  factory ProductListModelNew.fromJson(Map<String, dynamic> json) {
    return ProductListModelNew(
      brandName: json['brandName'] ?? '',
      brandKey: json['brand_key'] ?? '',
      productCount: json['productCount'] ?? 0,
      pageNo: int.tryParse(json['page_no']?.toString() ?? '') ?? 1,
      previousPage: json['previous_page'] ?? 1,
      totalNoOfPages: json['total_no_of_pages'] ?? 1,
      brandProduct: List<VendorProduct>.from(
        (json['brand_product'] ?? []).map((x) => VendorProduct.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'brandName': brandName,
        'brand_key': brandKey,
        'productCount': productCount,
        'page_no': pageNo,
        'previous_page': previousPage,
        'total_no_of_pages': totalNoOfPages,
        'brand_product':
            List<dynamic>.from(brandProduct.map((x) => x.toJson())),
      };
}

class VendorProduct {
  //**************************************************************************//
  ///         FIELDS FROM BRAND PRODUCTS API RESPONSE                        ///
  //**************************************************************************//
  final int productId;
  final String vendorpricePrice;
  final String firstVendorPrice;
  final String brandName;
  final String vendorName;
  final String msrp;
  final int vendorIdCount;
  final String vendorpriceDate;
  final String vendorUrl;
  final String productMpn;
  final String productName;
  final String productImage;
  final String imageName;
  final int totalCount;
  final double discountPercent;
  final List<LowestVendor>? lowestVendor;

  VendorProduct({
    //************************************************************************//
    ///         FIELDS FROM BRAND PRODUCTS API RESPONSE                      ///
    //************************************************************************//
    required this.productId,
    required this.vendorpricePrice,
    required this.firstVendorPrice,
    required this.vendorName,
    required this.msrp,
    required this.vendorIdCount,
    required this.vendorpriceDate,
    required this.vendorUrl,
    required this.productMpn,
    required this.productName,
    required this.productImage,
    required this.imageName,
    required this.totalCount,
    required this.brandName,
    required this.discountPercent,
    this.lowestVendor,
  });

  factory VendorProduct.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse discount percent
    double parseDiscountPercent(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        if (value.isEmpty || value == '--' || value == 'null') return 0.0;
        return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
      }
      return 0.0;
    }

    return VendorProduct(
      //************************************************************************//
      ///         FIELDS FROM BRAND PRODUCTS API RESPONSE                    ///
      //************************************************************************//

      productId: json["product_id"] ?? 0,
      vendorpricePrice: json["vendorprice_price"]?.toString() ?? '--',
      firstVendorPrice: json["firstVendorPrice"]?.toString() ?? '--',
      vendorName: json["vendor_name"]?.toString() ?? '--',
      vendorIdCount: json["vendorIdCount"] ?? 0,
      vendorpriceDate: json["vendorprice_date"]?.toString() ?? '--',
      msrp: json['msrp']?.toString() ?? '--',
      brandName: json["brand_name"]?.toString() ?? '--',
      vendorUrl: json["vendor_url"]?.toString() ?? '--',
      productMpn: json["product_mpn"]?.toString() ?? '--',
      productName: json["product_name"]?.toString() ?? '--',
      productImage: json["product_image"]?.toString() ?? '',
      imageName: json["image_name"]?.toString() ?? '',
      totalCount: json["total_count"] ?? 0,
      discountPercent: parseDiscountPercent(json["discount_percent"]),
      lowestVendor: json["lowest_vendor"] != null
          ? List<LowestVendor>.from(
              json["lowest_vendor"].map((x) => LowestVendor.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "vendorprice_price": vendorpricePrice,
      "firstVendorPrice": firstVendorPrice,
      "vendor_name": vendorName,
      "vendorIdCount": vendorIdCount,
      "vendorprice_date": vendorpriceDate,
      'msrp': msrp,
      "brand_name": brandName,
      "vendor_url": vendorUrl,
      "product_mpn": productMpn,
      "product_name": productName,
      "product_image": productImage,
      "image_name": imageName,
      "total_count": totalCount,
      "discount_percent": discountPercent,
      "lowest_vendor": lowestVendor != null
          ? List<dynamic>.from(lowestVendor!.map((x) => x.toJson()))
          : null,
    };
  }
}

class LowestVendor {
  final int vendorProductId;
  final int vendorId;
  final String vendorName;
  final String vendorpricePrice;
  final String vendorUrl;
  final String vendorpriceDate;
  final String source;

  LowestVendor({
    required this.vendorProductId,
    required this.vendorId,
    required this.vendorName,
    required this.vendorpricePrice,
    required this.vendorUrl,
    required this.vendorpriceDate,
    required this.source,
  });

  factory LowestVendor.fromJson(Map<String, dynamic> json) => LowestVendor(
        vendorProductId: json["vendor_product_id"] ?? 0,
        vendorId: json["vendor_id"] ?? 0,
        vendorName: json["vendor_name"]?.toString() ?? '',
        vendorpricePrice: json["vendorprice_price"]?.toString() ?? '',
        vendorUrl: json["vendor_url"]?.toString() ?? '',
        vendorpriceDate: json["vendorprice_date"]?.toString() ?? '',
        source: json["source"]?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        "vendor_product_id": vendorProductId,
        "vendor_id": vendorId,
        "vendor_name": vendorName,
        "vendorprice_price": vendorpricePrice,
        "vendor_url": vendorUrl,
        "vendorprice_date": vendorpriceDate,
        "source": source,
      };
}
