import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:minsellprice/screens/product_list_screen/brand_product_list_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;

class AllBrandsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> brands;
  final Database database;

  const AllBrandsScreen({
    Key? key,
    required this.brands,
    required this.database,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Brands'),
        backgroundColor: const Color.fromARGB(255, 237, 63, 69),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: 1,
        ),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final brand = brands[index];
          return GestureDetector(
            onTap: () {
              developer.log('Brand object: $brand');
              developer.log('brandID ${brand['brand_id']}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BrandProductListScreen(
                    brandId: brand['brand_id'],
                    brandName: brand['brand_name'],
                    database: database,
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
                        child: CachedNetworkImage(
                          imageUrl: brand['brand_logo'],
                          fit: BoxFit.contain,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/no_image.png',
                            fit: BoxFit.contain,
                          ),
                        ),
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
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4.0, left: 8.0, right: 8.0, top: 4.0),
                    child: Text(
                      'Products: ${brand['product_count']}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 18,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
