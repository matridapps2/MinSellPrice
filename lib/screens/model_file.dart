// To parse this JSON data, do
//
//     final brandModel = brandModelFromJson(jsonString);

import 'dart:convert';

BrandsModel brandModelFromJson(String str) =>
    BrandsModel.fromJson(json.decode(str));

String brandModelToJson(BrandsModel data) => json.encode(data.toJson());

class BrandsModel {
  BrandsModel({
    required this.status,
    required this.response,
    required this.error,
  });

  final int status;
  final BrandResponse response;
  final dynamic error;

  factory BrandsModel.fromJson(Map<String, dynamic> json) => BrandsModel(
        status: json["status"],
        response: BrandResponse.fromJson(json["response"]),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "response": response.toJson(),
        "error": error,
      };
}

class BrandResponse {
  BrandResponse({
    required this.brands,
    required this.higherBy5Total,
    required this.responseHigherBy5To15,
    required this.responseHigherBy15,
    required this.higherBy5,
    required this.higherBy5To15,
    required this.higherBy15,
    required this.totalProducts,
  });

  final List<Brand> brands;
  final int higherBy5Total;
  final int responseHigherBy5To15;
  final int responseHigherBy15;
  final Map<String, String> higherBy5;
  final Map<String, String> higherBy5To15;
  final Map<String, String> higherBy15;
  final List<int> totalProducts;

  factory BrandResponse.fromJson(Map<String, dynamic> json) => BrandResponse(
        brands: List<Brand>.from(json["Brands"].map((x) => Brand.fromJson(x))),
        higherBy5Total: json["Higher by 5% total"],
        responseHigherBy5To15: json["Higher by 5 to 15% "],
        responseHigherBy15: json["Higher by 15% "],
        higherBy5: json["Higher by 5%"] == null
            ? {"no_data": "Scrapping is under progress"}
            : Map.from(json["Higher by 5%"])
                .map((k, v) => MapEntry<String, String>(k, v.toString())),
        higherBy5To15: json["Higher by 5 to 15%"] == null
            ? {"no_data": "Scrapping is under progress"}
            : Map.from(json["Higher by 5 to 15%"])
                .map((k, v) => MapEntry<String, String>(k, v)),
        higherBy15: json["Higher by 15%"] == null
            ? {"no_data": "Scrapping is under progress"}
            : Map.from(json["Higher by 15%"])
                .map((k, v) => MapEntry<String, String>(k, v)),
        totalProducts: List<int>.from(json["Total Products"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "Brands": List<dynamic>.from(brands.map((x) => x.toJson())),
        "Higher by 5% total": higherBy5Total,
        "Higher by 5 to 15% ": responseHigherBy5To15,
        "Higher by 15% ": responseHigherBy15,
        "Higher by 5%":
            Map.from(higherBy5).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "Higher by 5 to 15%": Map.from(higherBy5To15)
            .map((k, v) => MapEntry<String, dynamic>(k, v)),
        "Higher by 15%":
            Map.from(higherBy15).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "Total Products": List<dynamic>.from(totalProducts.map((x) => x)),
      };
}

class Brand {
  Brand({
    required this.brandName,
    required this.brandKey,
    required this.counts,
    required this.vendorProductsCounts,
    required this.lowestproduct,
    required this.nonProduct,
    required this.notGmc,
  });

  final String brandName;
  final String brandKey;
  final int counts;
  final int vendorProductsCounts;
  final int lowestproduct;
  final int nonProduct;
  final int notGmc;

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        brandName: json["brand_name"],
        brandKey: json["brand_key"],
        counts: json["counts"],
        vendorProductsCounts: json["VendorProductsCounts"],
        lowestproduct: json["lowestproduct"],
        nonProduct: json["non_product"],
        notGmc: json["not_gmc"],
      );

  Map<String, dynamic> toJson() => {
        "brand_name": brandName,
        "brand_key": brandKey,
        "counts": counts,
        "VendorProductsCounts": vendorProductsCounts,
        "lowestproduct": lowestproduct,
        "non_product": nonProduct,
        "not_gmc": notGmc,
      };
}
