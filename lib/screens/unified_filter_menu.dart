import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/model/product_list_model_new.dart';

/// Unified filter menu for all product list types
class UnifiedFilterMenu extends StatefulWidget {
  final List<VendorProduct> allProducts;
  final String displayName;
  final double maxPrice;
  final Function(
      List<String> vendors,
      int? priceSorting,
      RangeValues priceRange,
      bool inStockOnly,
      bool onSaleOnly)? onFiltersApplied;

  final List<String> currentVendorFilters;
  final int? currentPriceSorting;
  final RangeValues currentPriceRange;
  final bool currentInStockOnly;
  final bool currentOnSaleOnly;
  final Map<String, int> vendorProductCounts;
  final Map<String, String> vendorCodes;

  const UnifiedFilterMenu({
    super.key,
    required this.allProducts,
    required this.displayName,
    required this.maxPrice,
    this.onFiltersApplied,
    this.currentVendorFilters = const [],
    this.currentPriceSorting,
    this.currentPriceRange = const RangeValues(0, 1000),
    this.currentInStockOnly = false,
    this.currentOnSaleOnly = false,
    this.vendorProductCounts = const {},
    this.vendorCodes = const {},
  });

  @override
  State<UnifiedFilterMenu> createState() => _UnifiedFilterMenuState();
}

class _UnifiedFilterMenuState extends State<UnifiedFilterMenu> {
  int? tempPriceSorting;
  List<String> tempFilterVendor = [];
  RangeValues priceRange = const RangeValues(0, 1000);
  bool showInStockOnly = false;
  bool showOnSaleOnly = false;

  @override
  void initState() {
    super.initState();

    tempPriceSorting = widget.currentPriceSorting;
    tempFilterVendor = List.from(widget.currentVendorFilters);
    priceRange = widget.currentPriceRange;
    showInStockOnly = widget.currentInStockOnly;
    showOnSaleOnly = widget.currentOnSaleOnly;

    // Ensure price range starts from 0
    if (priceRange.start > 0) {
      priceRange = RangeValues(0, priceRange.end);
    }

    if (priceRange.end > widget.maxPrice) {
      priceRange = RangeValues(priceRange.start, widget.maxPrice);
    }

    // Debug vendor data and current filters
    log('=== UnifiedFilterMenu Initialization ===');
    log('Vendor data count: ${widget.vendorProductCounts.length}');
    log('Vendor data: ${widget.vendorProductCounts}');
    log('Vendor codes: ${widget.vendorCodes}');
    log('Current vendor filters: ${widget.currentVendorFilters}');
    log('Current price sorting: ${widget.currentPriceSorting}');
    log('Current price range: ${widget.currentPriceRange}');
    log('Current in stock only: ${widget.currentInStockOnly}');
    log('Current on sale only: ${widget.currentOnSaleOnly}');
    log('Temp filter vendor: $tempFilterVendor');
    log('=== End Initialization ===');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: w * .9,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          AppBar(
            elevation: 2,
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
            ),
            surfaceTintColor: Colors.white,
            toolbarHeight: .14 * w,
            backgroundColor: Colors.white,
            centerTitle: false,
            title: Text(
              'Filters',
              style: TextStyle(
                fontSize: w * .05,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            automaticallyImplyLeading: false,
            actionsPadding: const EdgeInsets.only(right: 15),
            actions: [
              TextButton(
                onPressed: () async {
                  setState(() {
                    tempPriceSorting = null;
                    tempFilterVendor.clear();
                    priceRange = RangeValues(0, widget.maxPrice);
                    showInStockOnly = false;
                    showOnSaleOnly = false;
                  });

                  log('Reset filters: Price range reset to 0 - ${widget.maxPrice}');
                },
                child: Text(
                  'Reset',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: w * .05),
                ),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Price Range'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          RangeSlider(
                            values: priceRange,
                            min: 0,
                            max: widget.maxPrice,
                            divisions:
                                (widget.maxPrice / 50).round().clamp(10, 40),
                            activeColor: AppColors.primary,
                            labels: RangeLabels(
                              '\$${NumberFormat('#,###').format(priceRange.start.round())}',
                              '\$${NumberFormat('#,###').format(priceRange.end.round())}',
                            ),
                            onChanged: (values) {
                              setState(() {
                                priceRange = values;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${NumberFormat('#,###').format(priceRange.start.round())}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '\$${NumberFormat('#,###').format(priceRange.end.round())}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sort By Section
                  _buildSectionTitle('Sort By'),
                  Card(
                    child: Column(
                      children: [
                        _buildSortOption('Price: Low to High', 1),
                        const Divider(height: 1),
                        _buildSortOption('Price: High to Low', 2),
                        const Divider(height: 1),
                        _buildSortOption('Name: A to Z', 3),
                        const Divider(height: 1),
                        _buildSortOption('Name: Z to A', 4),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Vendor Section
                  _buildSectionTitle('Vendors'),
                  Card(
                    child: Column(
                      children: List.generate(
                        _getUniqueVendors().length,
                        (index) {
                          final vendor = _getUniqueVendors()[index];
                          final productCount =
                              _getProductCountForVendor(vendor);
                          final isSelected = tempFilterVendor.contains(vendor);
                          return Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            child: CheckboxListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 2),
                              activeColor: AppColors.primary,
                              title: Text(
                                vendor.isNotEmpty ? vendor : 'Unknown Vendor',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                productCount > 0
                                    ? '$productCount ${productCount == 1 ? 'product' : 'products'}'
                                    : 'No products',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.8)
                                      : Colors.grey,
                                  fontWeight: isSelected
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    tempFilterVendor.add(vendor);
                                  } else {
                                    tempFilterVendor.remove(vendor);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _applyFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: w * .045,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, int value) {
    return RadioListTile<int>(
      dense: true,
      activeColor: AppColors.primary,
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      groupValue: tempPriceSorting,
      onChanged: (int? newValue) {
        setState(() {
          tempPriceSorting = newValue;
        });
      },
    );
  }

  List<String> _getUniqueVendors() {
    // Use vendor data from API instead of current page products
    if (widget.vendorProductCounts.isEmpty) {
      log('⚠️ No vendor data available in UnifiedFilterMenu');
      return [];
    }

    List<String> vendorList = widget.vendorProductCounts.keys.toList();
    vendorList.sort();

    log('UnifiedFilterMenu: Displaying ${vendorList.length} vendors');
    log('UnifiedFilterMenu vendor list: $vendorList');

    return vendorList;
  }

  int _getProductCountForVendor(String vendorName) {
    // Use complete vendor data from API
    int count = widget.vendorProductCounts[vendorName] ?? 0;
    log('UnifiedFilterMenu: Vendor "$vendorName" has $count products');
    return count;
  }

  void _applyFilters() {
    log('=== Applying Filters ===');
    log('Selected vendors: $tempFilterVendor');
    log('Price sorting: $tempPriceSorting');
    log('Price range: $priceRange');
    log('In stock only: $showInStockOnly');
    log('On sale only: $showOnSaleOnly');
    log('=== End Applying Filters ===');

    if (widget.onFiltersApplied != null) {
      widget.onFiltersApplied!(
        tempFilterVendor,
        tempPriceSorting,
        priceRange,
        showInStockOnly,
        showOnSaleOnly,
      );
    }
  }
}
