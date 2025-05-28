import 'dart:convert';
import 'package:http/http.dart' as http;

class Brand {
  final String brandName;
  final int productCount;
  final String brandLogo;

  Brand({
    required this.brandName,
    required this.productCount,
    required this.brandLogo,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      brandName: json['brand_name'] as String,
      productCount: json['product_count'] as int,
      brandLogo: json['brand_logo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_name': brandName,
      'product_count': productCount,
      'brand_logo': brandLogo,
    };
  }
}

class BrandsResponse {
  final List<Brand> brands;

  BrandsResponse({required this.brands});

  factory BrandsResponse.fromJson(List<dynamic> json) {
    return BrandsResponse(
      brands: json.map((brand) => Brand.fromJson(brand)).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return brands.map((brand) => brand.toJson()).toList();
  }
}
