class SavedProductModel {
  final int productId;
  final String email;
  final String oldPrice;
  final String productName;
  final String productImage;
  final String newPrice;
  final String productMPN;
  final String brandKey;
  final int isRead;
  final String DataNTime;

  SavedProductModel({
    required this.productMPN,
    required this.brandKey,
    required this.productId,
    required this.email,
    required this.oldPrice,
    required this.productName,
    required this.productImage,
    required this.newPrice,
    required this.isRead,
    required this.DataNTime,
  });

  factory SavedProductModel.fromJson(Map<String, dynamic> json) {
    return SavedProductModel(
      productId: json['product_id'] ?? 0,
      email: json['email'] ?? '',
      oldPrice: json['OldPrice'] ?? '0.00',
      productName: json['product_name'] ?? '',
      productImage: json['product_image'] ?? '',
      newPrice: json['NewPrice'] ?? '0.00',
      productMPN: json['product_mpn'] ?? '',
      brandKey: json['brand_key'] ?? '',
      isRead: json['isRead'] ?? 0,
      DataNTime: json['DataNTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'email': email,
      'OldPrice': oldPrice,
      'product_name': productName,
      'product_image': productImage,
      'NewPrice': newPrice,
      'product_mpn': productMPN,
      'brand_key': brandKey,
      'isRead': isRead,
      'DataNTime': DataNTime
    };
  }

  // Calculate savings amount
  double get savingsAmount {
    final old = double.tryParse(oldPrice) ?? 0.0;
    final newPriceValue = double.tryParse(newPrice) ?? 0.0;
    return old - newPriceValue;
  }

  // Calculate savings percentage
  double get savingsPercentage {
    final old = double.tryParse(oldPrice) ?? 0.0;
    if (old == 0) return 0.0;
    return ((savingsAmount / old) * 100);
  }

  // Format savings amount as string
  String get formattedSavings => '\$${savingsAmount.toStringAsFixed(2)}';

  // Format savings percentage as string
  String get formattedSavingsPercentage =>
      '${savingsPercentage.toStringAsFixed(1)}%';
}
