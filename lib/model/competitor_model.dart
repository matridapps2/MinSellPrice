// To parse this JSON data, do
//
//     final competitorModel = competitorModelFromJson(jsonString);

import 'dart:convert';

List<CompetitorModel> competitorModelFromJson(String str) => List<CompetitorModel>.from(json.decode(str).map((x) => CompetitorModel.fromJson(x)));

String competitorModelToJson(List<CompetitorModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CompetitorModel {
  final String vendorName;
  final int totalProducts;
  final int totalBrands;
  final Map<String, TopBrand> topBrands;

  CompetitorModel({
    required this.vendorName,
    required this.totalProducts,
    required this.totalBrands,
    required this.topBrands,
  });

  factory CompetitorModel.fromJson(Map<String, dynamic> json) => CompetitorModel(
    vendorName: json["vendor_name"],
    totalProducts: json["total_products"],
    totalBrands: json["total_brands"],
    topBrands: Map.from(json["top_brands"]).map((k, v) => MapEntry<String, TopBrand>(k, TopBrand.fromJson(v))),
  );

  Map<String, dynamic> toJson() => {
    "vendor_name": vendorName,
    "total_products": totalProducts,
    "total_brands": totalBrands,
    "top_brands": Map.from(topBrands).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
  };
}

class TopBrand {
  final String image;
  final int count;

  TopBrand({
    required this.image,
    required this.count,
  });

  factory TopBrand.fromJson(Map<String, dynamic> json) => TopBrand(
    image: json["image"],
    count: json["count"],
  );

  Map<String, dynamic> toJson() => {
    "image": image,
    "count": count,
  };
}
