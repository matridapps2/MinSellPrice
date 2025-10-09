import 'dart:convert';

/// Category model for API response from MinSellPrice
CategoryResponse categoryResponseFromJson(String str) {
  return CategoryResponse.fromJson(json.decode(str));
}

String categoryResponseToJson(CategoryResponse data) {
  return json.encode(data.toJson());
}

class CategoryResponse {
  final String brandName;
  final String brandKey;
  final List<CategoryProduct> brandProduct;
  final List<CategoryVendor> vendors;

  CategoryResponse({
    required this.brandName,
    required this.brandKey,
    required this.brandProduct,
    required this.vendors,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      brandName: json['brandName'] ?? '',
      brandKey: json['brand_key'] ?? '',
      brandProduct: List<CategoryProduct>.from(
        (json['brand_product'] ?? []).map((x) => CategoryProduct.fromJson(x)),
      ),
      vendors: List<CategoryVendor>.from(
        (json['vendors'] ?? []).map((x) => CategoryVendor.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'brandName': brandName,
        'brand_key': brandKey,
        'brand_product':
            List<dynamic>.from(brandProduct.map((x) => x.toJson())),
        'vendors': List<dynamic>.from(vendors.map((x) => x.toJson())),
      };
}

class CategoryProduct {
  final int productId;
  final int brandId;
  final String brandName;
  final String vendorpricePrice;
  final String vendorName;
  final int vendorIdCount;
  final String vendorpriceDate;
  final String vendorUrl;
  final String productMpn;
  final String productName;
  final String? productImage;
  final String? imageName;
  final int totalCount;

  CategoryProduct({
    required this.productId,
    required this.brandId,
    required this.brandName,
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
  });

  factory CategoryProduct.fromJson(Map<String, dynamic> json) =>
      CategoryProduct(
        productId: json["product_id"] ?? 0,
        brandId: json["brand_id"] ?? 0,
        brandName: json["brand_name"] ?? '',
        vendorpricePrice: json["vendorprice_price"] ?? '0.00',
        vendorName: json["vendor_name"] ?? '',
        vendorIdCount: json["vendorIdCount"] ?? 0,
        vendorpriceDate: json["vendorprice_date"] ?? '',
        vendorUrl: json["vendor_url"] ?? '',
        productMpn: json["product_mpn"] ?? '',
        productName: json["product_name"] ?? '',
        productImage: json["product_image"],
        imageName: json["image_name"],
        totalCount: json["total_count"] ?? 0,
      );

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "brand_id": brandId,
      "brand_name": brandName,
      "vendorprice_price": vendorpricePrice,
      "vendor_name": vendorName,
      "vendorIdCount": vendorIdCount,
      "vendorprice_date": vendorpriceDate,
      "vendor_url": vendorUrl,
      "product_mpn": productMpn,
      "product_name": productName,
      "product_image": productImage,
      "image_name": imageName,
      "total_count": totalCount,
    };
  }
}

class CategoryVendor {
  final int vendorId;
  final String vendorCode;
  final String vendorName;
  final int productCount;
  final String productId;

  CategoryVendor({
    required this.vendorId,
    required this.vendorCode,
    required this.vendorName,
    required this.productCount,
    required this.productId,
  });

  factory CategoryVendor.fromJson(Map<String, dynamic> json) => CategoryVendor(
        vendorId: json["vendor_id"] ?? 0,
        vendorCode: json["vendor_code"] ?? '',
        vendorName: json["vendor_name"] ?? '',
        productCount: json["product_count"] ?? 0,
        productId: json["product_id"] ?? '',
      );

  Map<String, dynamic> toJson() {
    return {
      "vendor_id": vendorId,
      "vendor_code": vendorCode,
      "vendor_name": vendorName,
      "product_count": productCount,
      "product_id": productId,
    };
  }
}

/// Static category data model for main categories
class MainCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final List<SubCategory> subcategories;

  MainCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.subcategories,
  });
}

class SubCategory {
  final String id;
  final String name;
  final String parentId;
  final List<String> subSubcategories;

  SubCategory({
    required this.id,
    required this.name,
    required this.parentId,
    required this.subSubcategories,
  });
}

/// Static category data is now replaced by API calls
/// Use CategoryService.fetchCategories() to get categories from API
