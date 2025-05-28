import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoppingmegamart/model/product_list_model.dart';
import 'package:shoppingmegamart/reposotory_services/database/database_constants.dart';
import 'package:shoppingmegamart/reposotory_services/database/database_functions.dart';
import 'package:shoppingmegamart/services/extra_functions.dart';
import 'package:sqflite/sqflite.dart';

import 'widgets/liked_product_list_item/liked_item.dart';

class LikedProduct extends StatefulWidget {
  const LikedProduct(
      {super.key, required this.database, required this.vendorId});

  final int vendorId;
  final Database database;

  @override
  State<LikedProduct> createState() => _LikedProductState();
}

class _LikedProductState extends State<LikedProduct>
    with WidgetsBindingObserver {
  String vendorShortName = '';
  String sisterVendorShortName = '';

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

            for (Map<String, dynamic> element in snapshot.data!) {
              if (element[isLikedKey] == 1 &&
                  element[uniqueId].toString().contains('${widget.vendorId}')) {
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
                  final likedValue = item[isLikedKey];
                  if (likedValue != 1) {
                    return const SizedBox();
                  }

                  final notifiedValue = item[isNotifiedKey] ?? 0;
                  final productData = item[productDataKey];
                  if (productData == null) {
                    return const SizedBox();
                  }

                  ProductListModel? model;
                  try {
                    model = productData is Map<String, dynamic>
                        ? ProductListModel.fromJson(productData)
                        : ProductListModel.fromJson(
                            jsonDecode(productData as String)
                                as Map<String, dynamic>);
                  } catch (e) {
                    print('Error parsing product data: $e');
                    return const SizedBox();
                  }

                  if (model == null) {
                    return const SizedBox();
                  }

                  return GridTilesProducts(
                    model: model,
                    vendorId: widget.vendorId,
                    likedValue: likedValue,
                    notifiedValue: notifiedValue,
                    database: widget.database,
                    futureBuilderTriggerMethod: () => setState(() {}),
                    vendorShortName: vendorShortName,
                    sisterVendorShortName: sisterVendorShortName,
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
    final data = await DatabaseHelper().getData(db: widget.database) ?? [];
    return data;
  }

  Future<void> getLoginData() async {
    final loginData =
        await DatabaseHelper().getUserInformation(db: widget.database);

    vendorShortName = loginData[vendor_short_nameKey];
    sisterVendorShortName = loginData[sister_vendor_short_nameKey];
    setState(() {});
  }
}
