import 'dart:developer';

class ProductDetailsModel {
  final int? status;
  final String? message;
  final ProductDetailsData? data;
  final List<VendorProductData>? vendorProductData;

  ProductDetailsModel({
    this.status,
    this.message,
    this.data,
    this.vendorProductData,
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    log('ProductDetailsModel.fromJson called with: $json');

    // Handle different possible response structures
    List<VendorProductData>? vendorData;
    if (json['vendor_product_data'] != null) {
      try {
        vendorData = (json['vendor_product_data'] as List)
            .map((item) =>
                VendorProductData.fromJson(item as Map<String, dynamic>))
            .toList();
        log('Successfully parsed ${vendorData.length} vendor products');
      } catch (e) {
        log('Error parsing vendor_product_data: $e');
        vendorData = [];
      }
    }

    return ProductDetailsModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? ProductDetailsData.fromJson(json['data'])
          : (json['product_data'] != null
              ? ProductDetailsData.fromJson(json['product_data'])
              : null),
      vendorProductData: vendorData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
      'vendor_product_data':
          vendorProductData?.map((item) => item.toJson()).toList(),
    };
  }
}

class ProductDetailsData {
  final int? productId;
  final String? productName;
  final String? productSku;
  final String? msrp;
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
    this.msrp,
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
      msrp: json['msrp'],
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
      'msrp': msrp,
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

class VendorProductData {
  final int? brandId;
  final String? brandName;
  final String? brandKey;
  final int? productId;
  final String? productMpn;
  final String? msrp;
  final String? productImage;
  final int? vendorProductId;
  final double? vendorPriceDiscount;
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
    this.vendorPriceDiscount
  });

  factory VendorProductData.fromJson(Map<String, dynamic> json) {
    try {
      log('Parsing VendorProductData: $json');
      final vendorProduct = VendorProductData(
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
        vendorpriceExtraDiscount:
            json['vendorprice_extra_discount']?.toString(),
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
        vendorPriceDiscount: json['price_difference_percent'] as double?
      );
      log('Successfully parsed vendor: ${vendorProduct.vendorName} with price: ${vendorProduct.vendorpricePrice}');
      return vendorProduct;
    } catch (e) {
      log('Error parsing VendorProductData: $e');
      rethrow;
    }
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
      'price_difference_percent': vendorPriceDiscount
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