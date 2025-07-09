import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:minsellprice/colors.dart';
import 'package:minsellprice/screens/product_list_screen/brand_product_list_screen.dart';
import 'package:sqflite/sqflite.dart';

class BrandSearchScreen extends StatefulWidget {
  final List<Map<String, dynamic>> brands;
  final Database database;
  final String? initialSearchQuery;

  const BrandSearchScreen({
    Key? key,
    required this.brands,
    required this.database,
    this.initialSearchQuery,
  }) : super(key: key);

  @override
  State<BrandSearchScreen> createState() => _BrandSearchScreenState();
}

class _BrandSearchScreenState extends State<BrandSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> _filteredBrands;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _filteredBrands = widget.brands;
    _searchController.addListener(_onTextChanged);

    if (widget.initialSearchQuery != null &&
        widget.initialSearchQuery!.isNotEmpty) {
      _searchController.text = widget.initialSearchQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onSearchChanged();
      });
    }
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _onSearchChanged();
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredBrands = widget.brands;
      } else {
        _filteredBrands = widget.brands.where((brand) {
          final name = brand['brand_name'].toString().toLowerCase().trim();

          if (query.length == 1) {
            return name == query || name.startsWith(query);
          }
          return name == query ||
              name.startsWith(query) ||
              name.contains(query);
        }).toList();

        _filteredBrands.sort((a, b) {
          final nameA = a['brand_name'].toString().toLowerCase().trim();
          final nameB = b['brand_name'].toString().toLowerCase().trim();

          if (nameA == query && nameB != query) return -1;
          if (nameB == query && nameA != query) return 1;

          if (nameA.startsWith(query) && !nameB.startsWith(query)) return -1;
          if (nameB.startsWith(query) && !nameA.startsWith(query)) return 1;

          return nameA.compareTo(nameB);
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Brands'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, child) {
                return TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search brands by name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                );
              },
            ),
          ),
          // Results
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_filteredBrands.isEmpty) {
      final isSearchActive = _searchController.text.trim().isNotEmpty;

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearchActive ? Icons.search_off : Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              isSearchActive ? 'No Results Found' : 'No Brand',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontFamily: 'Segoe UI',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isSearchActive
                  ? 'No brands match your search "${_searchController.text}"'
                  : 'No brands available at the moment',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Segoe UI',
              ),
              textAlign: TextAlign.center,
            ),
            if (isSearchActive) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        childAspectRatio: 1,
      ),
      itemCount: _filteredBrands.length,
      itemBuilder: (context, index) {
        final brand = _filteredBrands[index];
        return GestureDetector(
          onTap: () {
            log('Brand object: $brand');
            log('Brand keys: ${brand.keys.toList()}');
            log('brandID ${brand['brand_id']}');
            log('brand_name: ${brand['brand_name']}');
            log('brand_key: ${brand['brand_key']}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BrandProductListScreen(
                  brandId: brand['brand_id'],
                  brandName: brand['brand_name'],
                  database: widget.database,
                  dataList: const [],
                ),
              ),
            );
          },
          child: Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.black),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 115,
                      child: _DebugBrandImageWidget(brand: brand),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, left: 8.0, right: 8.0),
                  child: Text(
                    brand['brand_name'].toString().trim(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'Segoe UI',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _DebugBrandImageWidget extends StatelessWidget {
  final Map<String, dynamic> brand;

  const _DebugBrandImageWidget({required this.brand});

  @override
  Widget build(BuildContext context) {
    log('DEBUG: _DebugBrandImageWidget brand data: $brand');
    log('DEBUG: Available keys: ${brand.keys.toList()}');

    String? brandName = brand['brand_name']?.toString();
    String? brandKey = brand['brand_key']?.toString();

    log('DEBUG: brand_name = $brandName');
    log('DEBUG: brand_key = $brandKey');

    String urlBrandName =
        brandName?.replaceAll(' ', '-').toLowerCase() ?? 'unknown';
    String urlBrandKey =
        brandKey?.replaceAll(' ', '-').toLowerCase() ?? 'unknown';

    String imageUrl1 =
        'https://growth.matridtech.net/brand-logo/brands/$urlBrandKey.png';
    String imageUrl2 =
        'https://www.minsellprice.com/Brand-logo-images/$urlBrandName.png';

    log('DEBUG: Trying imageUrl1: $imageUrl1');

    return CachedNetworkImage(
      imageUrl: imageUrl1,
      fit: BoxFit.contain,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) {
        log('DEBUG: Error with imageUrl1: $error');
        log('DEBUG: Trying imageUrl2: $imageUrl2');

        return CachedNetworkImage(
          imageUrl: imageUrl2,
          fit: BoxFit.contain,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) {
            log('DEBUG: Error with imageUrl2: $error');
            return Image.asset(
              'assets/images/no_image.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                log('DEBUG: Even fallback image failed: $error');
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
