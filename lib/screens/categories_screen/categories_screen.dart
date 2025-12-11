import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/screens/categories_provider/categories_provider_file.dart';
import 'package:minsellprice/screens/product_list_screen/product_list.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common/sqlite_api.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen(
      {super.key, required this.database});

  final Database database;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Brands',
      'icon': Icons.home,
      'color': AppColors.primary,
      'subcategories': []
    },
    {
      'name': 'Shoes & Apparels',
      'icon': Icons.sports_soccer,
      'color': AppColors.primary,
      'subcategories': []
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  void _updateCategoriesWithProviderData(BrandsProvider brandsProvider) {

      categories[0]['subcategories'] =
          brandsProvider.homeGardenBrands.map((brand) {
        log('Processing  brand: ${brand['brand_name']} with key: ${brand['brand_key']}');
        return {
          'name': brand['brand_name'] ?? 'Unknown Brand',
          'icon': Icons.home,
          'count': '${brand['total_products'] ?? 0}',
          'brand_id': brand['brand_id'],
          'brand_key': brand['brand_key'],
        };
      }).toList();

      categories[1]['subcategories'] =
          brandsProvider.shoesApparels.map((brand) {
        log('Processing Shoes & Apparels brand: ${brand['brand_name']} with key: ${brand['brand_key']}');
        return {
          'name': brand['brand_name'] ?? 'Unknown Brand',
          'icon': Icons.sports_soccer,
          'count': '${brand['total_products'] ?? 0}',
          'brand_id': brand['brand_id'],
          'brand_key': brand['brand_key'],
        };
      }).toList();

  }

  Widget _buildBrandImage(Map<String, dynamic> subcategory) {
    String brandName =
        subcategory['name'].toString().replaceAll(' ', '-').toLowerCase();
    String brandKey = subcategory['brand_key']
            ?.toString()
            .replaceAll(' ', '-')
            .toLowerCase() ??
        brandName;

    log('Building brand image for: ${subcategory['name']}');
    log('Brand key: $brandKey');
    log('Brand name: $brandName');

    return Image.network(
      'https://www.minsellprice.com/Brand-logo-images/$brandName.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        log('Failed to load image for $brandName, trying alternative URL');
        return Image.network(
          'https://growth.matridtech.net/brand-logo/brands/$brandKey.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error2, stackTrace2) {
            log('Both image URLs failed for $brandName');
            return Container(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/images/no_image.png',
                  fit: BoxFit.fitWidth,
                ));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<BrandsProvider>(
        builder: (context, brandsProvider, child) {
          if (brandsProvider.state == BrandsState.loading ||
              brandsProvider.state == BrandsState.initial) {
            return const Center(child: CircularProgressIndicator());
          } else if (brandsProvider.state == BrandsState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    brandsProvider.errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => brandsProvider.retry(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Update categories with provider data
          _updateCategoriesWithProviderData(brandsProvider);

          return Row(
            children: [
              // Left Sidebar
              Container(
                width: w / 4.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    ...categories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      final isSelected = selectedCategoryIndex == index;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                selectedCategoryIndex = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? category['color'].withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border(
                                  left: BorderSide(
                                    color: isSelected
                                        ? category['color']
                                        : Colors.transparent,
                                    width: 4,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    category['icon'],
                                    color: isSelected
                                        ? category['color']
                                        : Colors.grey[600],
                                    size: 24,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    category['name'],
                                    style: TextStyle(
                                      color: isSelected
                                          ? category['color']
                                          : Colors.grey[700],
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Red separator line
              Container(
                width: 1,
                color: AppColors.primary,
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),

              // Right content area
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          categories[selectedCategoryIndex]['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: categories[selectedCategoryIndex]
                                    ['subcategories']
                                .isEmpty
                            ? Center(
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
                                      'No brands available',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Check back later for updates',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: categories[selectedCategoryIndex]
                                        ['subcategories']
                                    .length,
                                itemBuilder: (context, index) {
                                  final subcategory =
                                      categories[selectedCategoryIndex]
                                          ['subcategories'][index];
                                  final categoryColor =
                                      categories[selectedCategoryIndex]
                                          ['color'];

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 2,
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductList(
                                                brandId:
                                                    subcategory['brand_id'],
                                                brandName: subcategory['name'],
                                                dataList: const [],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: categoryColor
                                                        .withOpacity(0.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: _buildBrandImage(
                                                        subcategory),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  subcategory['name'],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
