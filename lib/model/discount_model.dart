import 'dart:convert';

List<Discount> discountListModelFromJson(String str) => List<Discount>.from(
      json.decode(str).map(
            (x) => Discount.fromJson(x),
          ),
    );

class Discount {
  int discountId;
  int vendorId;
  String discountValue;
  String discountBrandType;
  int discountCount;
  String discountDate;
  String createdAt;
  String updatedAt;

  Discount({
    required this.discountId,
    required this.vendorId,
    required this.discountValue,
    required this.discountBrandType,
    required this.discountCount,
    required this.discountDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      discountId: json['discount_id'],
      vendorId: json['vendor_id'],
      discountValue: json['discount_value'],
      discountBrandType: json['discount_brand_type'],
      discountCount: json['discount_count'],
      discountDate: json['discount_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
