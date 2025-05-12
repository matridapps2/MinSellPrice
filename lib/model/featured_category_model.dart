import 'dart:convert';

class FeaturedCategoryModel {
  final int categoryId;
  final String categoryName;
  final String categoryKey;
  final int parentCategoryId;
  final String isActive;
  final String mainImage;
  final String thumbnailImage;
  final String homepageImage;
  final String createdAt;
  final String updatedAt;
  final int id;
  final int vendorId;
  final String isFeatured;

  FeaturedCategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryKey,
    required this.parentCategoryId,
    required this.isActive,
    required this.mainImage,
    required this.thumbnailImage,
    required this.homepageImage,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.vendorId,
    required this.isFeatured,
  });

  factory FeaturedCategoryModel.fromRawJson(String str) => FeaturedCategoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FeaturedCategoryModel.fromJson(Map<String, dynamic> json) => FeaturedCategoryModel(
    categoryId: json["category_id"]??0,
    categoryName: json["category_name"]??'',
    categoryKey: json["category_key"]??'',
    parentCategoryId: json["parent_category_id"]??0,
    isActive: json["is_active"]??0,
    mainImage: json["main_image"]??'',
    thumbnailImage: json["thumbnail_image"]??'',
    homepageImage: json["homepage_image"]??'',
    createdAt: json["created_at"]??'',
    updatedAt: json["updated_at"]??'',
    id: json["id"]??0,
    vendorId: json["vendor_id"]??0,
    isFeatured: json["is_featured"]??0,
  );

  Map<String, dynamic> toJson() => {
    "category_id": categoryId,
    "category_name": categoryName,
    "category_key": categoryKey,
    "parent_category_id": parentCategoryId,
    "is_active": isActive,
    "main_image": mainImage,
    "thumbnail_image": thumbnailImage,
    "homepage_image": homepageImage,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "id": id,
    "vendor_id": vendorId,
    "is_featured": isFeatured,
  };
}
