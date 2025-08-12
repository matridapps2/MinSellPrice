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
  final String brandName;
  final String vendorName;
  final int vendorIdCount;
  final String vendorpriceDate;
  final String vendorUrl;
  final String productMpn;
  final String productName;
  final String? productImage;
  final String? imageName;
  final int totalCount;

  VendorProduct({
    //************************************************************************//
    ///         FIELDS FROM BRAND PRODUCTS API RESPONSE                      ///
    //************************************************************************//
    required this.productId,
    required this.vendorpricePrice,
    required this.vendorName,
    required this.vendorIdCount,
    required this.vendorpriceDate,
    required this.vendorUrl,
    required this.productMpn,
    required this.productName,
    this.productImage,
    this.imageName,
    required this.totalCount,
    required this.brandName,

  });

  factory VendorProduct.fromJson(Map<String, dynamic> json) => VendorProduct(
        //************************************************************************//
        ///         FIELDS FROM BRAND PRODUCTS API RESPONSE                    ///
        //************************************************************************//

        productId: json["product_id"] ?? 0,
        vendorpricePrice: json["vendorprice_price"] ?? '--',
        vendorName: json["vendor_name"] ?? '--',
        vendorIdCount: json["vendorIdCount"] ?? 0,
        vendorpriceDate: json["vendorprice_date"] ?? '--',
        brandName: json["brand_name"] ?? '--',
        vendorUrl: json["vendor_url"] ?? '--',
        productMpn: json["product_mpn"] ?? '--',
        productName: json["product_name"] ?? '--',
        productImage: json["product_image"],
        imageName: json["image_name"],
        totalCount: json["total_count"] ?? 0,
      );

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "vendorprice_price": vendorpricePrice,
      "vendor_name": vendorName,
      "vendorIdCount": vendorIdCount,
      "vendorprice_date": vendorpriceDate,
      "brand_name": brandName,
      "vendor_url": vendorUrl,
      "product_mpn": productMpn,
      "product_name": productName,
      "product_image": productImage,
      "image_name": imageName,
      "total_count": totalCount,
    };
  }
}
