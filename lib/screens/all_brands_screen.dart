import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:minsellprice/colors.dart';
import 'package:minsellprice/screens/product_list_screen/brand_product_list_screen.dart';
import 'package:minsellprice/size.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer';

class AllBrandsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> brands;
  final Database database;

  const AllBrandsScreen({
    Key? key,
    required this.brands,
    required this.database,
  }) : super(key: key);

  @override
  State<AllBrandsScreen> createState() => _AllBrandsScreenState();
}

class _AllBrandsScreenState extends State<AllBrandsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> _filteredBrands;

  @override
  void initState() {
    super.initState();
    _filteredBrands = widget.brands;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBrands = widget.brands.where((brand) {
    final name = brand['brand_name'].toString().replaceAll(' ', ' ').toLowerCase();
      final q = query.replaceAll(' ', ' ');
      return name.contains(q);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
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
          Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 5),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Center(
                  child: SizedBox(
                    height: 45,
                    width: w * .9,
                    child: TextFormField(
                      enabled: true,
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: 'Search by brand name...',
                        // suffixIcon: InkWell(
                        //   splashColor: AppColors.primary.withOpacity(.3),
                        //   child: Icon(
                        //     Icons.cancel_outlined,
                        //     color: AppColors.primary,
                        //     size: 30,
                        //   ),
                        // ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                        suffixIconColor: AppColors.primary,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
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
                    log('brandID ${brand['brand_id']}');
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 115,
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://www.minsellprice.com/Brand-logo-images/${brand['brand_name'].toString().replaceAll(' ', '-').toLowerCase()}.png',
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  'assets/images/no_image.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, left: 8.0, right: 8.0),
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
            ),
          ),
        ],
      ),
    );
  }
}
