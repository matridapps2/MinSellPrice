import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minsellprice/screens/tushar_screen/product_list_screen/product_details_screen.dart';
import 'package:minsellprice/screens/tushar_screen/service_new/liked_preference_db.dart';
import 'package:sqflite/sqflite.dart';

class LikedProduct extends StatefulWidget {
  const LikedProduct({super.key, required this.database});

  final Database database;

  @override
  State<LikedProduct> createState() => _LikedProductState();
}

class _LikedProductState extends State<LikedProduct>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  String vendorShortName = '';
  String sisterVendorShortName = '';

  @override
  bool get wantKeepAlive => false; // Don't keep alive to ensure refresh

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Trigger a rebuild when returning to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getLoginData();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: returnLikedData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData ||
                snapshot.data == null ||
                snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No favourites yet!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Segoe UI',
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap the heart icon on products you love to add them here',
                      style: TextStyle(
                        fontFamily: 'Segoe UI',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            List<Map<String, dynamic>> onlyLikedProducts = [];

            // With the new database, all returned products are already liked
            for (Map<String, dynamic> element in snapshot.data!) {
              if (element['is_liked'] == 1) {
                onlyLikedProducts.add(element);
              }
            }

            if (onlyLikedProducts.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No favourites yet!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Segoe UI',
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap the heart icon on products you love to add them here',
                      style: TextStyle(
                        fontFamily: 'Segoe UI',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: GridView.builder(
                padding: const EdgeInsets.all(1.0),
                itemCount: onlyLikedProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  childAspectRatio: 8 / 18.2,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final item = onlyLikedProducts[index];

                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(
                                productId: item['product_id'],
                                brandName: item['brand_name'],
                                productMPN: item['product_mpn'],
                                productImage: item['product_image'],
                                productPrice: item['product_price'],
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  color: Colors.grey[100],
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: (item['product_image'] != null &&
                                          item['product_image']
                                              .toString()
                                              .isNotEmpty)
                                      ? Image.network(
                                          item['product_image'],
                                          fit: BoxFit.fill,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['product_name'] ?? 'Unknown Product',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['brand_name'] ?? 'Unknown Brand',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '\$${item['product_price'] ?? '0'}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            await _toggleLikeProduct(item);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Icon(
                                              item['is_liked'] == 1
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> returnLikedData() async {
    try {
      final data = await LikedPreferencesDB.getAllLikedProducts();
      return data;
    } catch (e) {
      return [];
    }
  }

  Future<void> getLoginData() async {
    // Note: Login data functionality removed since we're focusing only on liked products
    // If vendor information is needed, it can be added back with appropriate imports
  }

  Future<void> _toggleLikeProduct(Map<String, dynamic> item) async {
    try {
      // Remove the product from liked products using the new database
      await LikedPreferencesDB.removeLikedProduct(
        vendorProductId: item['vendor_product_id'],
      );

      // Refresh the screen to show updated list
      setState(() {});

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.favorite_border, color: Colors.white),
              SizedBox(width: 8),
              Text('Removed from favorites!'),
            ],
          ),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favorite status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
