import 'package:flutter/material.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/model/category_model.dart';

/// Reusable category card widget
class CategoryCard extends StatelessWidget {
  final MainCategory category;
  final VoidCallback onTap;
  final VoidCallback? onIconTap;
  final bool isSelected;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.onIconTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Category Icon (only show if icon is not empty)
            if (category.icon.isNotEmpty) ...[
              GestureDetector(
                onTap: onIconTap,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      category.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            // Category Info (tappable area)
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primary : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${category.subcategories.length} subcategories',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Arrow Icon (tappable for navigation to subcategories)
            GestureDetector(
              onTap: onIconTap ??
                  onTap, // Use icon tap if available, otherwise fallback to category tap
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isSelected ? AppColors.primary : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Subcategory list widget
class SubcategoryList extends StatelessWidget {
  final List<SubCategory> subcategories;
  final Function(SubCategory) onSubcategoryTap;
  final Function(SubCategory)? onSubcategoryIconTap;
  final String? selectedSubcategoryId;

  const SubcategoryList({
    super.key,
    required this.subcategories,
    required this.onSubcategoryTap,
    this.onSubcategoryIconTap,
    this.selectedSubcategoryId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subcategories.length,
      itemBuilder: (context, index) {
        final subcategory = subcategories[index];
        final isSelected = selectedSubcategoryId == subcategory.id;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                // Subcategory name (tappable area)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSubcategoryTap(subcategory),
                    child: Text(
                      subcategory.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : Colors.black87,
                      ),
                    ),
                  ),
                ),
                if (subcategory.subSubcategories.isNotEmpty) ...[
                  Text(
                    '${subcategory.subSubcategories.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Arrow icon (tappable for navigation to sub-subcategories)
                GestureDetector(
                  onTap: () {
                    if (onSubcategoryIconTap != null) {
                      onSubcategoryIconTap!(subcategory);
                    }
                  },
                  child: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: isSelected ? AppColors.primary : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Sub-subcategory grid widget
class SubSubcategoryGrid extends StatelessWidget {
  final List<String> subSubcategories;
  final Function(String) onSubSubcategoryTap;
  final String? selectedSubSubcategoryId;

  const SubSubcategoryGrid({
    super.key,
    required this.subSubcategories,
    required this.onSubSubcategoryTap,
    this.selectedSubSubcategoryId,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.5,
      ),
      itemCount: subSubcategories.length,
      itemBuilder: (context, index) {
        final subSubcategory = subSubcategories[index];
        final isSelected = selectedSubSubcategoryId == subSubcategory;

        return GestureDetector(
          onTap: () => onSubSubcategoryTap(subSubcategory),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                _formatSubSubcategoryName(subSubcategory),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatSubSubcategoryName(String name) {
    return name
        .split('-')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }
}

/// Category breadcrumb widget
class CategoryBreadcrumb extends StatelessWidget {
  final List<Map<String, String>> breadcrumbs;
  final Function(String) onBreadcrumbTap;

  const CategoryBreadcrumb({
    super.key,
    required this.breadcrumbs,
    required this.onBreadcrumbTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Always start with "Category" (clickable)
            GestureDetector(
              onTap: () => onBreadcrumbTap('Category'),
              child: Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (breadcrumbs.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                '>',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Add breadcrumb items
            ...breadcrumbs.asMap().entries.map((entry) {
              final index = entry.key;
              final breadcrumb = entry.value;
              final isLast = index == breadcrumbs.length - 1;

              return Row(
                children: [
                  GestureDetector(
                    onTap: () => onBreadcrumbTap(breadcrumb['path']!),
                    child: Text(
                      breadcrumb['name']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isLast ? AppColors.primary : Colors.grey[600],
                        fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (!isLast) ...[
                    const SizedBox(width: 8),
                    Text(
                      '>',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

/// Category search bar widget
class CategorySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearchChanged;
  final String hintText;

  const CategorySearchBar({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    this.hintText = 'Search categories...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primary,
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  onPressed: () {
                    controller.clear();
                    onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

/// Category loading shimmer widget
class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}

/// Empty category state widget
class EmptyCategoryState extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyCategoryState({
    super.key,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
