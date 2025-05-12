
import 'dart:convert';

ProductListingModel productListingModelFromJson(String str) => ProductListingModel.fromJson(json.decode(str));

String productListingModelToJson(ProductListingModel data) => json.encode(data.toJson());

class ProductListingModel {
  ProductListingModel({
    required this.status,
    required this.date,
    required this.vendorName,
    required this.response,
  });

  final String status;
  final String date;
  final String vendorName;
  final List<ProductListResponse> response;

  factory ProductListingModel.fromJson(Map<String, dynamic> json) => ProductListingModel(
    status: json["status"],
    date: json["date"],
    vendorName: json["vendor name"]['vendor_name'],
    response: List<ProductListResponse>.from(json["response"].map((x) => ProductListResponse.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "date": date,
    "vendor name": vendorName,
    "response": List<dynamic>.from(response.map((x) => x.toJson())),
  };
}

class ProductListResponse {
  ProductListResponse({
    required this.productMpn,
    required this.brandName,
    required this.brandKey,
    required this.productName,
    required this.productImage,
    required this.vendorName,
    required this.vendorpricePrice,
    required this.percentage,
    required this.firstLowestVendor,
    required this.firstLowestVendorPrice,
    required this.secondLowestVendor,
    required this.secondLowestVendorPrice,
    required this.competitor,
  });

  final String? productMpn;
  final String? brandName;
  final String ?brandKey;
  final String ?productName;
  final String? productImage;
  final String? vendorName;
  final String vendorpricePrice;
  final String? percentage;
  final String ?firstLowestVendor;
  final String ?firstLowestVendorPrice;
  final String ?secondLowestVendor;
  final String? secondLowestVendorPrice;
  final int? competitor;

  factory ProductListResponse.fromJson(Map<String, dynamic> json) => ProductListResponse(
    productMpn: json["product_mpn"]??'',
    brandName: json["brand_name"]??'',
    brandKey: json["brand_key"]??'',
    productName: json["product_name"]??'',
    productImage: json["product_image"]??'',
    vendorName: json["vendor_name"]??'',
    vendorpricePrice: json["vendorprice_price"]??'',
    percentage: json["percentage"]??'0%',
    firstLowestVendor: json["FirstLowestVendor"]??'',
    firstLowestVendorPrice: json["FirstLowestVendorPrice"]??'',
    secondLowestVendor: json["SecondLowestVendor"]??'',
    secondLowestVendorPrice: json["SecondLowestVendorPrice"]??'',
    competitor: json["competitor"]??0,
  );

  Map<String, dynamic> toJson() => {
    "product_mpn": productMpn,
    "brand_name": brandName,
    "brand_key": brandKey,
    "product_name": productName,
    "product_image": productImage,
    "vendor_name": vendorName,
    "vendorprice_price": vendorpricePrice,
    "percentage": percentage,
    "FirstLowestVendor": firstLowestVendor,
    "FirstLowestVendorPrice": firstLowestVendorPrice,
    "SecondLowestVendor": secondLowestVendor,
    "SecondLowestVendorPrice": secondLowestVendorPrice,
    "competitor": competitor,
  };
}

