import 'package:flutter/material.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';

/// Modern brand dropdown widget for category product filtering
/// Supports multiple brand selection - products from all selected brands are combined
class BrandDropdownWidget extends StatefulWidget {
  final List<Map<String, dynamic>> brands;
  final List<String> selectedBrandKeys; // List of selected brand_keys for API filtering
  final Function(List<String>) onBrandsChanged; // Passes list of selected brand_keys

  const BrandDropdownWidget({
    super.key,
    required this.brands,
    this.selectedBrandKeys = const [],
    required this.onBrandsChanged,
  });

  @override
  State<BrandDropdownWidget> createState() => _BrandDropdownWidgetState();
}

class _BrandDropdownWidgetState extends State<BrandDropdownWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.brands.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded ? AppColors.primary : Colors.grey[300]!,
          width: _isExpanded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - Always visible
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(16),
                bottom: Radius.circular(_isExpanded ? 0 : 16),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.branding_watermark_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Label and selected brands
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Brand',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Show selected brands as chips or display text
                          if (widget.selectedBrandKeys.isEmpty)
                            Text(
                              'All Brands',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          else
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children:
                                  widget.selectedBrandKeys.map((brandKey) {
                                final brand = widget.brands.firstWhere(
                                  (b) => b['brand_key'] == brandKey,
                                  orElse: () {
                                    return {};
                                  },
                                );
                                final brandName =
                                    brand['brand_name'] as String? ?? brandKey;

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        brandName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () {
                                          // Remove this specific brand
                                          final currentSelections =
                                              List<String>.from(
                                                  widget.selectedBrandKeys);
                                          currentSelections.remove(brandKey);
                                          widget.onBrandsChanged(
                                              currentSelections);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 14,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                    // Clear all button (if brands are selected)
                    if (widget.selectedBrandKeys.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          widget.onBrandsChanged([]); // Clear all selections
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    if (widget.selectedBrandKeys.isNotEmpty)
                      const SizedBox(width: 8),
                    // Dropdown arrow
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Dropdown list - Expandable
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: _isExpanded ? _calculateDropdownHeight() : 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // "All Brands" option (clears all selections)
                    _buildBrandOption(
                      brandKey: null, // null means "All Brands"
                      brandName: 'All Brands',
                      productCount: null,
                      isSelected: widget.selectedBrandKeys.isEmpty,
                    ),
                    // Divider
                    if (widget.brands.isNotEmpty)
                      Divider(height: 1, color: Colors.grey[200]),
                    // Brand options
                    ...widget.brands.map((brand) {
                      final brandKey = brand['brand_key'] as String? ?? '';
                      final brandName = brand['brand_name'] as String? ?? '';
                      final productCount = brand['product_count'] as int? ?? 0;
                      final isSelected =
                          widget.selectedBrandKeys.contains(brandKey);

                      return _buildBrandOption(
                        brandKey: brandKey,
                        brandName: brandName,
                        productCount: productCount,
                        isSelected: isSelected,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandOption({
    required String? brandKey, // null means "All Brands"
    required String brandName,
    required int? productCount,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (brandKey == null) {
            // "All Brands" - clear all selections
            widget.onBrandsChanged([]);
          } else {
            // Toggle brand selection
            final currentSelections =
                List<String>.from(widget.selectedBrandKeys);
            if (isSelected) {
              // Remove from selection
              currentSelections.remove(brandKey);
            } else {
              // Add to selection
              currentSelections.add(brandKey);
            }
            widget.onBrandsChanged(currentSelections);
          }
          // Keep dropdown open for multiple selections
          // setState(() {
          //   _isExpanded = false;
          // });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.05)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              // Checkbox indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Brand name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brandKey == null ? 'All Brands' : brandName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isSelected ? AppColors.primary : Colors.grey[800],
                      ),
                    ),
                    if (productCount != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '$productCount products',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Cancel icon for selected brands (only show for actual brands, not "All Brands")
              if (isSelected && brandKey != null)
                GestureDetector(
                  onTap: () {
                    // Stop event propagation to prevent row tap
                    final currentSelections =
                        List<String>.from(widget.selectedBrandKeys);
                    currentSelections.remove(brandKey);
                    widget.onBrandsChanged(currentSelections);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateDropdownHeight() {
    // Calculate height based on number of items
    // Each item is approximately 60px, max height is 300px
    const itemHeight = 60.0;
    const maxHeight = 300.0;
    final itemCount = widget.brands.length + 1; // +1 for "All Brands"
    final calculatedHeight = itemCount * itemHeight;
    return calculatedHeight > maxHeight ? maxHeight : calculatedHeight;
  }
}
