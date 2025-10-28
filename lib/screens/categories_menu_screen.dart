import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:minsellprice/model/category_model.dart';
import 'package:minsellprice/services/category_service.dart';
import 'package:minsellprice/widgets/category_widgets.dart';
import 'package:minsellprice/navigation/product_list_navigation.dart';

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

  void _onSubcategoryIconTap(SubCategory subcategory) {
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
