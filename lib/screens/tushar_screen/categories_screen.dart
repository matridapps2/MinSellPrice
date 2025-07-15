import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minsellprice/colors.dart';
import 'package:minsellprice/dashboard_screen.dart';
import 'package:minsellprice/size.dart';
import 'package:minsellprice/screens/product_list_screen/brand_product_list_screen.dart';
import 'package:sqflite_common/sqlite_api.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen(
      {super.key, required this.database, required this.vendorId});

  final Database database;
  final int vendorId;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int selectedCategoryIndex = 0;
  late Future<Map<String, List<dynamic>>> _brandsFuture;
  List<Map<String, dynamic>> _homeGardenBrands = [];
  List<Map<String, dynamic>> _shoesApparels = [];

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Home & Garden',
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
    _initCall();
  }

  Future<void> _initCall() async {
    _brandsFuture = fetchBrands();
    final brandsData = await _brandsFuture;

    setState(() {
      _homeGardenBrands = (brandsData["Home & Garden Brands"] ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

      _shoesApparels = (brandsData["Shoes & Apparels"] ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

      categories[0]['subcategories'] = _homeGardenBrands.map((brand) {
        log('Processing Home & Garden brand: ${brand['brand_name']} with key: ${brand['brand_key']}');
        return {
          'name': brand['brand_name'] ?? 'Unknown Brand',
          'icon': Icons.home,
          'count': '${brand['total_products'] ?? 0}',
          'brand_id': brand['brand_id'],
          'brand_key': brand['brand_key'],
        };
      }).toList();

      categories[1]['subcategories'] = _shoesApparels.map((brand) {
        log('Processing Shoes & Apparels brand: ${brand['brand_name']} with key: ${brand['brand_key']}');
        return {
          'name': brand['brand_name'] ?? 'Unknown Brand',
          'icon': Icons.sports_soccer,
          'count': '${brand['total_products'] ?? 0}',
          'brand_id': brand['brand_id'],
          'brand_key': brand['brand_key'],
        };
      }).toList();
    });
  }

  Future<Map<String, List<dynamic>>> fetchBrands() async {
    try {
      log('Fetching brands for categories screen');
      final response = await http
          .get(
            Uri.parse('https://www.minsellprice.com/api/minsell-brand'),
          )
          .timeout(const Duration(seconds: 30));
      log('Brand API: https://www.minsellprice.com/api/minsell-brand');

      if (response.statusCode == 200) {
        log('Brand API status code: ${response.statusCode}');
        final Map<String, dynamic> jsonData = json.decode(response.body);

        final homeGardenBrands =
            jsonData["Home & Garden Brands"] as List<dynamic>;
        final shoesApparels = jsonData["Shoes & Apparels"] as List<dynamic>;

        log('Home & Garden Brands count: ${homeGardenBrands.length}');
        log('Shoes & Apparels count: ${shoesApparels.length}');

        return {
          "Home & Garden Brands": homeGardenBrands,
          "Shoes & Apparels": shoesApparels,
        };
      } else {
        log('Error Brand API: ${response.statusCode}');
        throw Exception('Failed to load brands: ${response.statusCode}');
      }
    } catch (e) {
      log("Exception In Brand API: ${e.toString()}");
      throw Exception('Error fetching brands: $e');
    }
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
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: _brandsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initCall();
                      });
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

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
                    }).toList(),
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
                                    SizedBox(height: 16),
                                    Text(
                                      'No brands available',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8),
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
                                                  BrandProductListScreen(
                                                brandId:
                                                    subcategory['brand_id'],
                                                brandName: subcategory['name'],
                                                database: widget.database,
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
