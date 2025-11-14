import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:minsellprice/model/category_model.dart';
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/services/category_service.dart';
import 'package:minsellprice/widgets/category_widgets.dart';
import 'package:minsellprice/navigation/product_list_navigation.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/core/utils/toast_messages/common_toasts.dart';

class CategoriesMenuScreen extends StatefulWidget {
  const CategoriesMenuScreen({super.key});

  @override
  State<CategoriesMenuScreen> createState() => _CategoriesMenuScreenState();
}

class _CategoriesMenuScreenState extends State<CategoriesMenuScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // State variables
  List<MainCategory> _mainCategories = [];
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  String? _selectedSubSubcategoryId;
  List<Map<String, String>> _breadcrumbs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCategories();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load categories from API
      final categories =
          await CategoryService.fetchCategories(context: context);

      if (categories != null && categories.isNotEmpty) {
        setState(() {
          _mainCategories = categories;
          _isLoading = false;
        });

        log('✅ Loaded ${categories.length} main categories from API');
      } else {
        // Fallback to static data if API fails
        log('⚠️ API failed, using static data');
        _loadStaticCategories();
      }
    } catch (e) {
      log('❌ Error loading categories: $e');
      // Fallback to static data
      _loadStaticCategories();
    }
  }

  void _loadStaticCategories() {
    setState(() {
      _mainCategories = [
        MainCategory(
          id: 'grills-outdoor-cooking',
          name: 'Grills Outdoor Cooking',
          icon: '',
          description: 'Gas, Pellet, Charcoal Grills and BBQ Equipment',
          subcategories: [
            SubCategory(
              id: 'gas-grills',
              name: 'Gas Grills',
              parentId: 'grills-outdoor-cooking',
              subSubcategories: [
                'freestanding-gas-grills',
                'propane-grills',
                'natural-gas-grills',
                'portable-gas-grills'
              ],
            ),
            SubCategory(
              id: 'pellet-grills',
              name: 'Pellet Grills',
              parentId: 'grills-outdoor-cooking',
              subSubcategories: [
                'wifi-pellet-grills',
                'portable-pellet-grills',
                'freestanding-pellet-grills'
              ],
            ),
            SubCategory(
              id: 'kamado-grills',
              name: 'Kamado Grills',
              parentId: 'grills-outdoor-cooking',
              subSubcategories: [
                'freestanding-kamado-grills',
                'portable-kamado-grills'
              ],
            ),
            SubCategory(
              id: 'charcoal-grills',
              name: 'Charcoal Grills',
              parentId: 'grills-outdoor-cooking',
              subSubcategories: [
                'freestanding-charcoal-grills',
                'portable-charcoal-grills',
                'kettle-grills'
              ],
            ),
            SubCategory(
              id: 'bbq-smokers',
              name: 'BBQ Smokers',
              parentId: 'grills-outdoor-cooking',
              subSubcategories: [
                'electric-smokers',
                'charcoal-smokers',
                'pellet-smokers',
                'wood-smokers',
                'propane-smokers',
                'offset-smokers',
                'vertical-smokers'
              ],
            ),
          ],
        ),
      ];
      _isLoading = false;
      _errorMessage = null;
    });
    log('✅ Loaded static categories as fallback');
  }

  void _onCategoryTap(MainCategory category) {
    log('🎯 Category tapped: ${category.name} (ID: ${category.id})');

    // Navigate directly to product list for this category
    _navigateToProductList(
      categoryPath: category.id,
      categoryName: category.name,
    );
  }

  void _onSubcategoryTap(SubCategory subcategory) {
    // Navigate directly to product list for this subcategory
    _navigateToProductList(
      categoryPath: '$_selectedCategoryId/${subcategory.id}',
      categoryName: subcategory.name,
    );
  }

  void _onSubSubcategoryTap(String subSubcategory) {
    log('🎯 Sub-subcategory tapped: $subSubcategory');

    // Navigate directly to product list for this sub-subcategory
    _navigateToProductList(
      categoryPath:
          '$_selectedCategoryId/$_selectedSubcategoryId/$subSubcategory',
      categoryName: CategoryService.getCategoryDisplayName(subSubcategory),
    );
  }

  // Icon tap methods for navigation to subcategories
  void _onCategoryIconTap(MainCategory category) {
    log('🎯 Category icon tapped: ${category.name} (ID: ${category.id})');

    // Immediate state update without waiting
    if (mounted) {
      setState(() {
        _selectedCategoryId = category.id;
        _selectedSubcategoryId = null;
        _selectedSubSubcategoryId = null;
        _breadcrumbs = [
          {'name': category.name, 'path': category.id}
        ];
      });
      log('📂 Navigated to subcategories for: ${category.name}');
    }
  }

  void _onSubcategoryIconTap(SubCategory subcategory) {
    log('🎯 Subcategory icon tapped: ${subcategory.name} (ID: ${subcategory.id})');

    // Immediate state update without waiting
    if (mounted) {
      setState(() {
        _selectedSubcategoryId = subcategory.id;
        _selectedSubSubcategoryId = null;
        _breadcrumbs = [
          {
            'name': _getCategoryName(_selectedCategoryId!),
            'path': _selectedCategoryId!
          },
          {
            'name': subcategory.name,
            'path': '$_selectedCategoryId/${subcategory.id}'
          },
        ];
      });
      log('📂 Navigated to sub-subcategories for: ${subcategory.name}');
    }
  }

  void _onBreadcrumbTap(String path) {
    log('🔗 Breadcrumb tapped: $path');

    // Special case: if "Category" is tapped, go back to main screen
    if (path == 'Category' || path.isEmpty) {
      setState(() {
        _selectedCategoryId = null;
        _selectedSubcategoryId = null;
        _selectedSubSubcategoryId = null;
        _breadcrumbs.clear();
      });
      log('🏠 Navigated back to main categories');
      return;
    }

    final parts = path.split('/');
    setState(() {
      if (parts.length == 1) {
        // Main category
        _selectedCategoryId = parts[0];
        _selectedSubcategoryId = null;
        _selectedSubSubcategoryId = null;
        _breadcrumbs = [
          {'name': _getCategoryName(parts[0]), 'path': parts[0]}
        ];
      } else if (parts.length == 2) {
        // Subcategory
        _selectedCategoryId = parts[0];
        _selectedSubcategoryId = parts[1];
        _selectedSubSubcategoryId = null;
        _breadcrumbs = [
          {'name': _getCategoryName(parts[0]), 'path': parts[0]},
          {'name': _getSubcategoryName(parts[1]), 'path': path}
        ];
      } else if (parts.length == 3) {
        // Sub-subcategory
        _selectedCategoryId = parts[0];
        _selectedSubcategoryId = parts[1];
        _selectedSubSubcategoryId = parts[2];
        _breadcrumbs = [
          {'name': _getCategoryName(parts[0]), 'path': parts[0]},
          {
            'name': _getSubcategoryName(parts[1]),
            'path': '${parts[0]}/${parts[1]}'
          },
          {
            'name': CategoryService.getCategoryDisplayName(parts[2]),
            'path': path
          }
        ];
      }
    });
    log('🔗 Navigated to: $path');
  }

  void _navigateToProductList({
    required String categoryPath,
    required String categoryName,
  }) {
    log('🚀 Navigating to product list for: $categoryName');
    log('📂 Category path: $categoryPath');

    ProductListNavigation.navigateToCategoryProducts(
      context,
      categoryPath: categoryPath,
      categoryName: categoryName,
    );
  }

  String _getCategoryName(String categoryId) {
    final category = _mainCategories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => MainCategory(
        id: categoryId,
        name: CategoryService.getCategoryDisplayName(categoryId),
        icon: '',
        description: '',
        subcategories: [],
      ),
    );
    return category.name;
  }

  String _getSubcategoryName(String subcategoryId) {
    if (_selectedCategoryId == null) return '';

    final category = _mainCategories.firstWhere(
      (cat) => cat.id == _selectedCategoryId,
      orElse: () => MainCategory(
        id: '',
        name: '',
        icon: '',
        description: '',
        subcategories: [],
      ),
    );

    final subcategory = category.subcategories.firstWhere(
      (sub) => sub.id == subcategoryId,
      orElse: () => SubCategory(
        id: subcategoryId,
        name: CategoryService.getCategoryDisplayName(subcategoryId),
        parentId: '',
        subSubcategories: [],
      ),
    );

    return subcategory.name;
  }

  Widget _buildMainCategoriesView() {
    if (_isLoading) {
      return const CategoryShimmer();
    }

    if (_errorMessage != null) {
      return EmptyCategoryState(
        message: _errorMessage!,
        actionText: 'Retry',
        onAction: _loadCategories,
      );
    }

    if (_mainCategories.isEmpty) {
      return EmptyCategoryState(
        message: 'No categories available',
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _mainCategories.length,
        itemBuilder: (context, index) {
          final category = _mainCategories[index];
          return CategoryCard(
            category: category,
            isSelected: _selectedCategoryId == category.id,
            onTap: () => _onCategoryTap(category),
            onIconTap: () => _onCategoryIconTap(category),
          );
        },
      ),
    );
  }

  Widget _buildSubcategoriesView() {
    if (_selectedCategoryId == null) return const SizedBox.shrink();

    log('🔍 Looking for category with ID: $_selectedCategoryId');
    log('📋 Available categories: ${_mainCategories.map((c) => c.id).toList()}');

    final category = _mainCategories.firstWhere(
      (cat) => cat.id == _selectedCategoryId,
      orElse: () => MainCategory(
        id: '',
        name: '',
        icon: '',
        description: '',
        subcategories: [],
      ),
    );

    log('📂 Found category: ${category.name}');
    log('📁 Subcategories count: ${category.subcategories.length}');
    log('📁 Subcategories: ${category.subcategories.map((s) => s.name).toList()}');

    if (category.subcategories.isEmpty) {
      return EmptyCategoryState(
        message: 'No subcategories available for ${category.name}',
      );
    }

    return SubcategoryList(
      subcategories: category.subcategories,
      selectedSubcategoryId: _selectedSubcategoryId,
      onSubcategoryTap: _onSubcategoryTap,
      onSubcategoryIconTap: _onSubcategoryIconTap,
    );
  }

  Widget _buildSubSubcategoriesView() {
    if (_selectedCategoryId == null || _selectedSubcategoryId == null) {
      return const SizedBox.shrink();
    }

    final category = _mainCategories.firstWhere(
      (cat) => cat.id == _selectedCategoryId,
      orElse: () => MainCategory(
        id: '',
        name: '',
        icon: '',
        description: '',
        subcategories: [],
      ),
    );

    final subcategory = category.subcategories.firstWhere(
      (sub) => sub.id == _selectedSubcategoryId,
      orElse: () => SubCategory(
        id: '',
        name: '',
        parentId: '',
        subSubcategories: [],
      ),
    );

    if (subcategory.subSubcategories.isEmpty) {
      return EmptyCategoryState(
        message: 'No sub-subcategories available for ${subcategory.name}',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: subcategory.subSubcategories.map((item) {
          return GestureDetector(
            onTap: () => _onSubSubcategoryTap(item),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _formatSubSubcategoryName(item),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
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

  // ============================================
  // Vendor Price, Logo, Date Logic
  // Based on unified_product_list_screen.dart
  // ============================================

  /// Get vendors from product - matches unified_product_list_screen.dart logic
  List<Map<String, dynamic>> _getVendorsFromProduct(VendorProduct product) {
    List<Map<String, dynamic>> vendors = [];

    log('Getting vendors for product: ${product.productName}');
    log('Product vendor name: ${product.vendorName}');
    log('Product vendor URL: ${product.vendorUrl}');
    log('Product vendor price: ${product.vendorpricePrice}');
    log('Product lowestVendor: ${product.lowestVendor}');

    // Check if lowestVendor array exists and has data
    if (product.lowestVendor != null && product.lowestVendor!.isNotEmpty) {
      // Get all vendors from lowest_vendor array and convert to map format
      for (var lowestVendor in product.lowestVendor!) {
        final vendorData = {
          'name': lowestVendor.vendorName,
          'logo': _getVendorLogo(lowestVendor.vendorName),
          'price': lowestVendor.vendorpricePrice,
          'url': lowestVendor.vendorUrl,
          'date': lowestVendor.vendorpriceDate,
        };
        vendors.add(vendorData);
        log('Added lowest vendor: "${vendorData['name']}" with price: ${vendorData['price']} and URL: ${vendorData['url']}');
      }

      // Sort by vendorprice_price to get lowest prices first
      vendors.sort((a, b) {
        final priceA = _parsePrice(a['price']) ?? double.infinity;
        final priceB = _parsePrice(b['price']) ?? double.infinity;
        return priceA.compareTo(priceB);
      });

      // Take the lowest two vendors based on vendorprice_price
      final limitedVendors = vendors.take(2).toList();
      log('Selected ${limitedVendors.length} lowest vendor(s) from lowestVendor array based on vendorprice_price');
      return limitedVendors;
    } else {
      // No lowest_vendor data - fall back to current vendor logic
      if (product.vendorIdCount > 1) {
        // Show main vendor
        final currentVendor = {
          'name': product.vendorName,
          'logo': _getVendorLogo(product.vendorName),
          'price': product.vendorpricePrice,
          'url': product.vendorUrl,
          'date': product.vendorpriceDate,
        };
        vendors.add(currentVendor);
        log('Added main vendor: "${currentVendor['name']}" with URL: ${currentVendor['url']}');
      } else {
        // Only one vendor - show the main vendor
        final currentVendor = {
          'name': product.vendorName,
          'logo': _getVendorLogo(product.vendorName),
          'price': product.vendorpricePrice,
          'url': product.vendorUrl,
          'date': product.vendorpriceDate,
        };
        vendors.add(currentVendor);
        log('Single vendor - showing main vendor: "${currentVendor['name']}" with URL: ${currentVendor['url']}');
      }

      // Sort by price to show cheapest first
      vendors.sort((a, b) {
        final priceA = _parsePrice(a['price']) ?? 0;
        final priceB = _parsePrice(b['price']) ?? 0;
        return priceA.compareTo(priceB);
      });

      // Limit to maximum 2 vendors for display
      final limitedVendors = vendors.take(2).toList();

      log('Total vendors for product "${product.productName}": ${vendors.length}, showing: ${limitedVendors.length}');
      return limitedVendors;
    }
  }

  /// Get vendor logo URL
  String _getVendorLogo(String vendorName) {
    return 'https://growth.matridtech.net/vendor-logo/$vendorName.jpg';
  }

  /// Build vendor logo widget
  Widget _buildVendorLogoWidget(String vendorName) {
    String logoPath =
        'https://growth.matridtech.net/vendor-logo/$vendorName.jpg';

    return Image.network(
      logoPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            vendorName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
          ),
        );
      },
    );
  }

  /// Build individual vendor row - matches unified_product_list_screen.dart
  Widget _buildVendorRow(Map<String, dynamic> vendor) {
    log('Building vendor row for: "${vendor['name']}" with logo: ${vendor['logo']} and URL: ${vendor['url']}');
    return GestureDetector(
      onTap: () async {
        // Handle vendor URL tap using url_launcher
        if (vendor['url'] != null &&
            vendor['url'].isNotEmpty &&
            vendor['url'] != 'https://example.com') {
          try {
            log('Opening vendor URL: ${vendor['url']} for vendor: ${vendor['name']}');
            final Uri url = Uri.parse(vendor['url']);
            if (await canLaunchUrl(url)) {
              await launchUrl(
                url,
                mode:
                    LaunchMode.externalApplication, // Opens in external browser
              );
            } else {
              throw 'Could not launch $url';
            }
          } catch (e) {
            log('Error opening vendor URL: $e');
            // Fallback: show a toast message
            if (mounted) {
              CommonToasts.centeredMobile(
                  msg: 'Unable to open vendor website: ${vendor['name']}',
                  context: context);
            }
          }
        } else {
          log('Vendor ${vendor['name']} has no valid URL or is mock data');
          if (mounted) {
            CommonToasts.centeredMobile(
                msg: 'No website available for ${vendor['name']}',
                context: context);
          }
        }
      },
      child: Container(
        height: h * 0.15,
        margin: const EdgeInsets.only(bottom: 6.0),
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Vendor logo - using same pattern as unified_product_list_screen
            SizedBox(
              height: h * 0.038,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child:
                      _buildVendorLogoWidget(vendor['name']?.toString() ?? ''),
                ),
              ),
            ),
            const SizedBox(height: 3),
            // Vendor price
            Text(
              '\$${_formatPrice(vendor['price'])}',
              style: const TextStyle(
                color: Colors.blue,
                fontFamily: 'Segoe UI',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            // Vendor price date
            Text(
              _formatVendorDate(vendor['date']?.toString() ?? ''),
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'Segoe UI',
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Parse price consistently for filtering and display
  double? _parsePrice(String price) {
    try {
      if (price.isEmpty) return null;

      // Remove any existing formatting and parse the number
      final cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
      final double? priceValue = double.tryParse(cleanPrice);

      // Validate price is positive and reasonable
      if (priceValue == null || priceValue < 0 || priceValue > 1000000) {
        return null;
      }

      return priceValue;
    } catch (e) {
      log('Error parsing price "$price": $e');
      return null;
    }
  }

  /// Format price with comma separators for thousands
  String _formatPrice(String price) {
    try {
      final double? priceValue = _parsePrice(price);

      if (priceValue == null) {
        return price; // Return original if parsing fails
      }

      // Format with commas for thousands
      final formatter = NumberFormat('#,###.##');
      return formatter.format(priceValue);
    } catch (e) {
      log('Error formatting price: $e');
      return price; // Return original if formatting fails
    }
  }

  /// Format vendor date for display
  String _formatVendorDate(String date) {
    try {
      if (date.isEmpty || date == '0' || date == 'null') {
        return 'N/A';
      }

      // Try to parse the date (expected format: 2025-08-28)
      final DateTime? parsedDate = DateTime.tryParse(date);

      if (parsedDate != null) {
        // Format as "Sep 11, 2025" (MMM dd, yyyy)
        final formatter = DateFormat('MMM dd, yyyy');
        return formatter.format(parsedDate);
      }

      return date;
    } catch (e) {
      log('Error formatting vendor date "$date": $e');
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // Breadcrumb Navigation
          if (_breadcrumbs.isNotEmpty)
            CategoryBreadcrumb(
              breadcrumbs: _breadcrumbs,
              onBreadcrumbTap: _onBreadcrumbTap,
            ),

          // Content Area
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadCategories,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Categories
                    if (_selectedCategoryId == null) ...[
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Browse Categories',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      _buildMainCategoriesView(),
                    ],

                    // Subcategories
                    if (_selectedCategoryId != null &&
                        _selectedSubcategoryId == null) ...[
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Subcategories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      _buildSubcategoriesView(),
                    ],

                    // Sub-subcategories (Product Types)
                    if (_selectedCategoryId != null &&
                        _selectedSubcategoryId != null) ...[
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Product Types',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      _buildSubSubcategoriesView(),
                    ],
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
