class BrandProduct {
  final int productId;
  final String productName;
  final String productImage;
  final String vendorPricePrice;
  final int brandId;

  BrandProduct({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.vendorPricePrice,
    required this.brandId,
  });

  factory BrandProduct.fromJson(Map<String, dynamic> json) {
    return BrandProduct(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      productImage: json['product_image'] ?? '',
      vendorPricePrice: json['vendorprice_price']?.toString() ?? '',
      brandId: json['brand_id'] ?? 0,
    );
  }
}
