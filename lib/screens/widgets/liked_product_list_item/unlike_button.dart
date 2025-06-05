import 'package:flutter/material.dart';
import 'package:shoppingmegamart/reposotory_services/database/database_functions.dart';
import 'package:sqflite/sqflite.dart';

class UnlikeButton extends StatelessWidget {
  final Database database;
  final VoidCallback callback;
  final int vendorId, productId, isNotified;
  final String productData;

  const UnlikeButton({
    super.key,
    required this.database,
    required this.callback,
    required this.vendorId,
    required this.productId,
    required this.isNotified,
    required this.productData,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await DatabaseHelper()
            .addAndUpdateProduct(
              db: database,
              vendorId: int.parse('$vendorId$productId'),
              productSku: productId,
              isLiked: 0,
              isNotified: isNotified,
              productData: productData,
            )
            .whenComplete(() => callback());
      },
      child: const Card(
        shape: CircleBorder(),
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(
            Icons.favorite,
          ),
        ),
      ),
    );
  }
}
