import 'dart:convert';
import 'dart:developer';
import 'category_model.dart';

/// API response model for categories endpoint
ApiCategoryResponse apiCategoryResponseFromJson(String str) {
  return ApiCategoryResponse.fromJson(json.decode(str));
}

String apiCategoryResponseToJson(ApiCategoryResponse data) {
  return json.encode(data.toJson());
}

class ApiCategoryResponse {
  final List<ApiCategory> categories;

  ApiCategoryResponse({
    required this.categories,
  });

  factory ApiCategoryResponse.fromJson(List<dynamic> json) {
    return ApiCategoryResponse(
      categories: List<ApiCategory>.from(
        json.map((x) => ApiCategory.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'categories': List<dynamic>.from(categories.map((x) => x.toJson())),
      };
}

class ApiCategory {
  final int categoryId;
  final String categoryName;
  final String categoryKey;
  final int? parentCategoryId;
  final String isActive;
  final String? mainImage;
  final String? thumbnailImage;
  final String? homepageImage;
  final int? includeMenu;
  final String createdAt;
  final String updatedAt;
  final List<ApiCategory> children;

  ApiCategory({
    required this.categoryId,
    required this.categoryName,
    required this.categoryKey,
    this.parentCategoryId,
    required this.isActive,
    this.mainImage,
    this.thumbnailImage,
    this.homepageImage,
    this.includeMenu,
    required this.createdAt,
    required this.updatedAt,
    required this.children,
  });

  factory ApiCategory.fromJson(Map<String, dynamic> json) {
    return ApiCategory(
      categoryId: json["category_id"] ?? 0,
      categoryName: json["category_name"] ?? '',
      categoryKey: json["category_key"] ?? '',
      parentCategoryId: json["parent_category_id"],
      isActive: json["is_active"] ?? '0',
      mainImage: json["main_image"],
      thumbnailImage: json["thumbnail_image"],
      homepageImage: json["homepage_image"],
      includeMenu: json["include_menu"],
      createdAt: json["created_at"] ?? '',
      updatedAt: json["updated_at"] ?? '',
      children: List<ApiCategory>.from(
        (json["children"] ?? []).map((x) => ApiCategory.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "category_id": categoryId,
      "category_name": categoryName,
      "category_key": categoryKey,
      "parent_category_id": parentCategoryId,
      "is_active": isActive,
      "main_image": mainImage,
      "thumbnail_image": thumbnailImage,
      "homepage_image": homepageImage,
      "include_menu": includeMenu,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "children": List<dynamic>.from(children.map((x) => x.toJson())),
    };
  }

  /// Convert API category to our internal MainCategory model
  MainCategory toMainCategory() {
    log('🔄 Converting API category to MainCategory: $categoryName');
    log('📁 Children count: ${children.length}');
    log('📁 Children: ${children.map((c) => c.categoryName).toList()}');

    return MainCategory(
      id: categoryKey,
      name: categoryName,
      icon: '', // No icons as requested
      description:
          'Browse products in $categoryName', // Generic description from API data
      subcategories: children.map((child) => child.toSubCategory()).toList(),
    );
  }

  /// Convert API category to SubCategory
  SubCategory toSubCategory() {
    log('🔄 Converting API category to SubCategory: $categoryName');
    log('📁 Sub-subcategories count: ${children.length}');
    log('📁 Sub-subcategories: ${children.map((c) => c.categoryKey).toList()}');

    return SubCategory(
      id: categoryKey,
      name: categoryName,
      parentId: parentCategoryId?.toString() ?? '',
      subSubcategories: children.map((child) => child.categoryKey).toList(),
    );
  }

  /// Check if category is active
  bool get isActiveCategory {
    return isActive == '1';
  }

  /// Check if category should be included in menu
  /// Returns true if includeMenu is 1 or null (null means include by default)
  bool get shouldIncludeInMenu => includeMenu == null || includeMenu == 1;

  /// Get display image (prioritize main_image, then thumbnail, then homepage)
  String? get displayImage => mainImage ?? thumbnailImage ?? homepageImage;
}
