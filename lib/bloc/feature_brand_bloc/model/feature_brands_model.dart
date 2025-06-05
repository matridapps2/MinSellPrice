import 'dart:convert';

class FeaturedBrandModel {
  final int brandId;
  final String brandName;
  final String brandKey;
  final String brandRawName;
  final String isActive;
  final dynamic mainImage;
  final dynamic thumbnailImage;
  final dynamic homepageImage;
  final int displayPosition;
  final int brandGroupId;
  final String brandType;
  final String isUrgent;
  final String isPicked;
  final String isPickedForBrandWise;
  final String createdAt;
  final String updatedAt;
  final int id;
  final int vendorId;
  final String isFeatured;

  FeaturedBrandModel({
    required this.brandId,
    required this.brandName,
    required this.brandKey,
    required this.brandRawName,
    required this.isActive,
    required this.mainImage,
    required this.thumbnailImage,
    required this.homepageImage,
    required this.displayPosition,
    required this.brandGroupId,
    required this.brandType,
    required this.isUrgent,
    required this.isPicked,
    required this.isPickedForBrandWise,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.vendorId,
    required this.isFeatured,
  });

  factory FeaturedBrandModel.fromRawJson(String str) =>
      FeaturedBrandModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FeaturedBrandModel.fromJson(Map<String, dynamic> json) =>
      FeaturedBrandModel(
        brandId: json["brand_id"],
        brandName: json["brand_name"],
        brandKey: json["brand_key"],
        brandRawName: json["brand_raw_name"],
        isActive: json["is_active"],
        mainImage: json["main_image"],
        thumbnailImage: json["thumbnail_image"],
        homepageImage: json["homepage_image"],
        displayPosition: json["display_position"],
        brandGroupId: json["brand_group_id"],
        brandType: json["brand_type"],
        isUrgent: json["is_urgent"],
        isPicked: json["is_picked"],
        isPickedForBrandWise: json["is_picked_for_brand_wise"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        id: json["id"],
        vendorId: json["vendor_id"],
        isFeatured: json["is_featured"],
      );

  Map<String, dynamic> toJson() => {
        "brand_id": brandId,
        "brand_name": brandName,
        "brand_key": brandKey,
        "brand_raw_name": brandRawName,
        "is_active": isActive,
        "main_image": mainImage,
        "thumbnail_image": thumbnailImage,
        "homepage_image": homepageImage,
        "display_position": displayPosition,
        "brand_group_id": brandGroupId,
        "brand_type": brandType,
        "is_urgent": isUrgent,
        "is_picked": isPicked,
        "is_picked_for_brand_wise": isPickedForBrandWise,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "id": id,
        "vendor_id": vendorId,
        "is_featured": isFeatured,
      };
}
