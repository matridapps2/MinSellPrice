import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ProductDetailsModel {
  final int? status;
  final String? message;
  final ProductDetailsData? data;

  ProductDetailsModel({
    this.status,
    this.message,
    this.data,
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailsModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? ProductDetailsData.fromJson(json['data'])
          : (json['product_data'] != null
              ? ProductDetailsData.fromJson(json['product_data'])
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class ProductDetailsData {
  final int? productId;
  final String? productName;
  final String? productSku;
  final String? brandName;
  final String? category;
  final String? description;
  final double? price;
  final double? originalPrice;
  final double? discountPercentage;
  final List<String>? images;
  final List<String>? specifications;
  final Map<String, dynamic>? features;
  final bool? inStock;
  final int? stockQuantity;
  final String? vendorId;
  final String? vendorName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Review>? reviews;
  final double? averageRating;
  final int? reviewCount;

  ProductDetailsData({
    this.productId,
    this.productName,
    this.productSku,
    this.brandName,
    this.category,
    this.description,
    this.price,
    this.originalPrice,
    this.discountPercentage,
    this.images,
    this.specifications,
    this.features,
    this.inStock,
    this.stockQuantity,
    this.vendorId,
    this.vendorName,
    this.createdAt,
    this.updatedAt,
    this.reviews,
    this.averageRating,
    this.reviewCount,
  });

  factory ProductDetailsData.fromJson(Map<String, dynamic> json) {
    return ProductDetailsData(
      productId: json['product_id'],
      productName: json['product_name'],
      productSku: json['product_sku'],
      brandName: json['brand_name'],
      category: json['category'],
      description: json['description'],
      price: json['price']?.toDouble(),
      originalPrice: json['original_price']?.toDouble(),
      discountPercentage: json['discount_percentage']?.toDouble(),
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      specifications: json['specifications'] != null
          ? List<String>.from(json['specifications'])
          : null,
      features: json['features'],
      inStock: json['in_stock'],
      stockQuantity: json['stock_quantity'],
      vendorId: json['vendor_id'],
      vendorName: json['vendor_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      reviews: json['reviews'] != null
          ? List<Review>.from(json['reviews'].map((x) => Review.fromJson(x)))
          : null,
      averageRating: json['average_rating']?.toDouble(),
      reviewCount: json['review_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'brand_name': brandName,
      'category': category,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'discount_percentage': discountPercentage,
      'images': images,
      'specifications': specifications,
      'features': features,
      'in_stock': inStock,
      'stock_quantity': stockQuantity,
      'vendor_id': vendorId,
      'vendor_name': vendorName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'reviews': reviews?.map((x) => x.toJson()).toList(),
      'average_rating': averageRating,
      'review_count': reviewCount,
    };
  }
}

class Review {
  final int? reviewId;
  final String? userName;
  final double? rating;
  final String? comment;
  final DateTime? reviewDate;
  final bool? verifiedPurchase;

  Review({
    this.reviewId,
    this.userName,
    this.rating,
    this.comment,
    this.reviewDate,
    this.verifiedPurchase,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['review_id'],
      userName: json['user_name'],
      rating: json['rating']?.toDouble(),
      comment: json['comment'],
      reviewDate: json['review_date'] != null
          ? DateTime.parse(json['review_date'])
          : null,
      verifiedPurchase: json['verified_purchase'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'review_date': reviewDate?.toIso8601String(),
      'verified_purchase': verifiedPurchase,
    };
  }
}

// API Service class for making HTTP requests
class ProductDetailsApiService {
  static const String baseUrl = 'https://www.minsellprice.com/api';

  static Future<ProductDetailsModel> getProductDetails({
    required String brandName,
    required String productMPN,
    required int productId,
  }) async {
    log('Product API running');
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/brands/$brandName/$productMPN?product_id=$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      log('Single Product API');
      log('$baseUrl/brands/$brandName/$productMPN?product_id=$productId');
      log('product api status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('Successfully API run: ${response.body}');
        return ProductDetailsModel.fromJson(json.decode(response.body));
      } else {
        log('product api status code: ${response.statusCode}');
        throw Exception(
            'Failed to load product details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product details: $e');
    }
  }
}

// Usage example:
// final productDetails = await ProductDetailsApiService.getProductDetails(
//   brandName: 'Bull Grills',
//   vendorId: '44000',
//   productId: 203034,
// );
